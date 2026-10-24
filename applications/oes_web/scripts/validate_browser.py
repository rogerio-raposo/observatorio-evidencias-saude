#!/usr/bin/env python3
"""Validate actual localhost Django rendering with headless Chromium; no remote HTTP."""
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from urllib.error import URLError
from urllib.parse import urlparse
from urllib.request import urlopen

from playwright.sync_api import sync_playwright

APP_DIR = Path(__file__).resolve().parents[1]
OUT = APP_DIR / "browser-evidence"
BASE = "http://127.0.0.1:8000"
ROUTES = {
    "catalog": "/",
    "known": "/signals/NCT01438697/",
    "unreconciled": "/signals/NCT07836491/",
}
SIZES = {
    "desktop": {"width": 1440, "height": 900},
    "tablet": {"width": 810, "height": 900},
    "mobile": {"width": 390, "height": 844},
}
SOURCE_PREFIX = "https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/docs/"


def ensure(condition, why):
    if not condition:
        raise AssertionError(why)


def local_requests_only(route):
    if urlparse(route.request.url).hostname == "127.0.0.1":
        route.continue_()
    else:
        route.abort()


def wait_for_django(server):
    deadline = time.monotonic() + 35
    while time.monotonic() < deadline:
        if server.poll() is not None:
            raise RuntimeError("Django exited before readiness")
        try:
            with urlopen(BASE + "/", timeout=1) as response:
                if response.status == 200:
                    return
        except (URLError, TimeoutError, ConnectionError):
            pass
        time.sleep(0.25)
    raise RuntimeError("Django did not respond on loopback")


def validate_page(page, name, size):
    page_errors = []
    bad_local_requests = []
    page.on("pageerror", lambda e: page_errors.append(str(e)))
    page.on("requestfailed", lambda req: (
        bad_local_requests.append(req.url)
        if urlparse(req.url).hostname == "127.0.0.1" else None
    ))
    response = page.goto(BASE + ROUTES[name], wait_until="networkidle", timeout=15000)
    tag = size + "/" + name
    ensure(response is not None and response.status == 200, tag + ": HTML HTTP status")
    css = page.locator('link[rel="stylesheet"]')
    ensure(css.count() == 1, tag + ": stylesheet missing")
    ensure(urlparse(css.get_attribute("href") or "").path == "/static/evidence/styles.css",
           tag + ": stylesheet path is incorrect")
    ensure(page.evaluate("getComputedStyle(document.body).backgroundColor")
           == "rgb(245, 247, 249)", tag + ": stylesheet not applied")
    ensure(page.evaluate("document.documentElement.scrollWidth <= window.innerWidth + 1"),
           tag + ": horizontal overflow")
    ensure(page.locator("main").count() == 1, tag + ": main landmark missing")
    if name == "catalog":
        ensure(page.get_by_role("heading", name="Catálogo documental de sinais").count() == 1,
               tag + ": catalog heading")
        ensure(page.locator("ul.catalog > li").count() == 2, tag + ": two fixtures required")
        ensure(all(page.get_by_role("link", name=nct).count() == 1
                   for nct in ("NCT01438697", "NCT07836491")), tag + ": signal links")
        ensure("não é inventário completo" in page.locator("main").inner_text(),
               tag + ": incomplete-inventory disclosure absent")
    else:
        nct = "NCT01438697" if name == "known" else "NCT07836491"
        ensure(page.get_by_role("heading", name="Sinal de evidência: " + nct).count() == 1,
               tag + ": signal heading")
        ensure(page.get_by_role("heading", name="Trajetória documental retrospectiva").count() == 1,
               tag + ": documentary chronology")
        ensure(page.get_by_role("heading", name="Limitações e avaliação científica").count() == 1,
               tag + ": limitations")
        content = page.locator("main").inner_text()
        ensure("Avaliação humana pendente" in content, tag + ": review limitation absent")
        if name == "known":
            ensure("Ritterband 2017" in content and "Shaffer 2020" in content,
                   tag + ": existing linked reports")
            ensure(page.locator('section[aria-labelledby="identity-title"] dd ul li').count() == 2,
                   tag + ": must present exactly two reports")
        else:
            ensure("Não reconciliado" in content and "Nenhum vínculo estabelecido" in content,
                   tag + ": unreconciled status missing")
            ensure("Ritterband 2017" not in content and "Shaffer 2020" not in content,
                   tag + ": invented report link")
        source_links = page.locator('a[target="_blank"]')
        ensure(source_links.count() > 0, tag + ": documentary links missing")
        for link in source_links.all():
            url = link.get_attribute("href") or ""
            rel = link.get_attribute("rel") or ""
            ensure(url.startswith(SOURCE_PREFIX), tag + ": unexpected source URL " + url)
            ensure("noopener" in rel and "noreferrer" in rel, tag + ": rel safeguards absent")

    ensure(not page_errors, tag + ": JavaScript errors " + str(page_errors))
    ensure(not bad_local_requests, tag + ": failed local requests " + str(bad_local_requests))
    screenshot = OUT / "screenshots" / size / (name + ".png")
    screenshot.parent.mkdir(parents=True, exist_ok=True)
    page.screenshot(path=str(screenshot), full_page=True)
    return {"viewport": size, "page": name, "status": "PASS",
            "css_applied": True, "horizontal_overflow": False,
            "screenshot": str(screenshot.relative_to(OUT))}


def validate_navigation(browser):
    context = browser.new_context(viewport=SIZES["desktop"])
    context.route("**/*", local_requests_only)
    try:
        page = context.new_page()
        page.goto(BASE + "/", wait_until="networkidle")
        page.keyboard.press("Tab")
        ensure(page.evaluate("document.activeElement.textContent.trim()") == "NCT01438697",
               "Keyboard focus should reach first catalog signal")
        page.get_by_role("link", name="NCT01438697").click()
        ensure(urlparse(page.url).path == ROUTES["known"], "Catalog -> known navigation")
        page.get_by_role("link", name="Identidade indeterminada").click()
        ensure(urlparse(page.url).path == ROUTES["unreconciled"],
               "Known -> unreconciled navigation")
    finally:
        context.close()


def main():
    import django
    OUT.mkdir(parents=True, exist_ok=True)
    result = {
        "status": "FAIL", "commit": os.environ.get("GITHUB_SHA", "local-unverified"),
        "python": sys.version.split()[0], "django": django.get_version(),
        "scope": "Local actual Django + Chromium; not scientific or production homologation",
        "checks": [],
    }
    logfile = (OUT / "django-server.log").open("w", encoding="utf-8")
    server = None
    try:
        server = subprocess.Popen(
            [sys.executable, "manage.py", "runserver", "--noreload", "127.0.0.1:8000"],
            cwd=APP_DIR, stdout=logfile, stderr=subprocess.STDOUT,
        )
        wait_for_django(server)
        with urlopen(BASE + "/static/evidence/styles.css", timeout=5) as css:
            ensure(css.status == 200 and "body{" in css.read().decode("utf-8"),
                   "Django is not serving expected CSS")
        with sync_playwright() as pw:
            browser = pw.chromium.launch(headless=True)
            try:
                result["chromium"] = browser.version
                for size, viewport in SIZES.items():
                    context = browser.new_context(viewport=viewport, device_scale_factor=1)
                    context.route("**/*", local_requests_only)
                    try:
                        for name in ROUTES:
                            page = context.new_page()
                            try:
                                check = validate_page(page, name, size)
                                result["checks"].append(check)
                                print("PASS", size, name, flush=True)
                            finally:
                                page.close()
                    finally:
                        context.close()
                validate_navigation(browser)
                result["navigation"] = "PASS"
                result["status"] = "PASS"
            finally:
                browser.close()
    except Exception as exc:
        result["error"] = type(exc).__name__ + ": " + str(exc)
        print("FAIL:", result["error"], file=sys.stderr, flush=True)
        raise
    finally:
        if server is not None:
            server.terminate()
            try:
                server.wait(timeout=8)
            except subprocess.TimeoutExpired:
                server.kill()
                server.wait()
        logfile.close()
        (OUT / "results.json").write_text(
            json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8",
        )
        print("BROWSER_VALIDATION_STATUS=" + result["status"], flush=True)


if __name__ == "__main__":
    main()
