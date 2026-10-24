"""D2-E6-A2: one authorized GET -> E5-A3 package -> E5-A5 preflight.

No GitHub commits, retries, redirects, pagination or external dependencies.
Do not execute --connected until separately authorized by the owner.
"""
import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote, urlencode
from urllib.request import HTTPRedirectHandler, Request, build_opener

from archive_preflight import prepare_archival_plan
from preserve import package_evidence

PARAMS = [
    ("query.cond", "Insomnia"),
    ("query.term", 'SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"'),
    ("sort", "@relevance"),
    ("pageSize", "20"),
    ("countTotal", "true"),
    ("format", "json"),
]
URL = "https://clinicaltrials.gov/api/v2/studies?" + urlencode(PARAMS, quote_via=quote)


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, request, fp, code, msg, headers, newurl):
        return None


def utc():
    return datetime.now(timezone.utc).isoformat()


def capture_once(opener=None):
    opener = opener or build_opener(NoRedirect())
    started = utc()
    request = Request(URL, headers={"Accept": "application/json",
                                   "User-Agent": "OES-D2-E6-A2/0.1 (single authorized metadata GET)"},
                      method="GET")
    with opener.open(request, timeout=20) as response:
        if response.status != 200:
            raise ValueError("Unexpected HTTP status")
        ctype = response.headers.get("Content-Type", "")
        if "application/json" not in ctype.lower():
            raise ValueError("Unexpected content type")
        raw = response.read(2_000_001)
        if len(raw) > 2_000_000:
            raise ValueError("Response over cap")
    return raw, started, utc(), ctype


# Unknown fields trigger HOLD before packaging, not a privacy guarantee.
_TOP_LEVEL = {"studies", "totalCount", "nextPageToken"}
_STUDY = {"protocolSection", "derivedSection", "hasResults"}
_SECTIONS = {"identificationModule", "statusModule", "sponsorCollaboratorsModule",
    "oversightModule", "descriptionModule", "conditionsModule", "designModule",
    "armsInterventionsModule", "outcomesModule", "eligibilityModule",
    "contactsLocationsModule", "referencesModule", "ipdSharingStatementModule"}

def preupload_structure_gate(raw):
    try:
        data = json.loads(raw)
    except (ValueError, UnicodeError, TypeError) as exc:
        raise ValueError("HOLD: invalid JSON") from exc
    if not isinstance(data, dict) or set(data) - _TOP_LEVEL:
        raise ValueError("HOLD: unexpected top-level fields")
    if not isinstance(data.get("studies"), list):
        raise ValueError("HOLD: invalid studies list")
    for item in data["studies"]:
        if not isinstance(item, dict) or set(item) - _STUDY:
            raise ValueError("HOLD: unexpected study fields")
        protocol = item.get("protocolSection")
        if not isinstance(protocol, dict) or set(protocol) - _SECTIONS:
            raise ValueError("HOLD: unexpected protocol sections")

def build_package(raw, started, finished, ctype, target, run_id, attempt, sha, observation):
    provenance = {
        "activity_id": "OES/D2-E6-A2/CONTROLLED_FACTUAL_CAPTURE",
        "observation_id": observation,
        "repository_commit_sha": sha,
        "github_run_id": run_id,
        "run_attempt": attempt,
        "requested_url_exact": URL,
        "started_at_utc": started,
        "completed_at_utc": finished,
        "source_http_status": 200,
        "response_content_type": ctype,
    }
    preupload_structure_gate(raw)
    package_evidence(raw, provenance, target)
    # Labels apply only to this E6 factual review package, not historical E5 bundles.
    for name in ("manifest.json", "summary.json"):
        path = target / name
        metadata = json.loads(path.read_text(encoding="utf-8"))
        metadata["data_classification"] = "RAW_SOURCE_DATA"
        metadata["scientific_review_status"] = "NOT_SCIENTIFICALLY_REVIEWED"
        metadata["artifact_retention"] = "TEMPORARY_ARTIFACT"
        path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    plan = prepare_archival_plan(target)
    if plan["classification"] != "OFFLINE_PREFLIGHT_PASS_PUBLICATION_NOT_AUTHORIZED":
        raise ValueError("Preflight not approved")
    return plan


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--connected", action="store_true")
    parser.add_argument("--output", default="evidence-package")
    args = parser.parse_args()
    if not args.connected or os.environ.get("OES_E6_CONNECTED_APPROVAL") != "OWNER_APPROVED_SINGLE_GET":
        raise SystemExit("STOP: connected execution requires separate owner approval")
    run_id = int(os.environ["GITHUB_RUN_ID"])
    attempt = int(os.environ["GITHUB_RUN_ATTEMPT"])
    sha = os.environ["GITHUB_SHA"]
    observation = f"E6-R1-{run_id}-{attempt}"
    raw, started, finished, ctype = capture_once()
    plan = build_package(raw, started, finished, ctype, Path(args.output),
                         run_id, attempt, sha, observation)
    print(json.dumps({"status": "TEMPORARY_PACKAGE_READY_REVIEW_REQUIRED",
                      "observation_id": observation,
                      "source_scope": plan["source_scope"],
                      "raw_sha256": plan["files"][0]["sha256"],
                      "publication": "NOT_AUTHORIZED"}, sort_keys=True))


if __name__ == "__main__":
    main()
