"""OES D2-E2/A1: NCBI E-utilities client; no network calls on import.

Network execution requires a separate, express authorization.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from xml.etree import ElementTree as ET

BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
USER_AGENT = "OES-D2-E2-Probe/0.1 (public bibliographic metadata)"
SEED_PMIDS = ("33328044", "41343796", "40075149", "42240717")
MAX_RECORDS = 20


class RetrievalError(RuntimeError):
    """Response from E-utilities is missing or malformed."""


def build_url(endpoint: str, params: dict[str, str | int]) -> str:
    if endpoint not in {"esearch.fcgi", "esummary.fcgi"}:
        raise ValueError("Unsupported E-utilities endpoint")
    return f"{BASE_URL}/{endpoint}?{urlencode(params)}"


def esearch(term: str, *, retmax: int = MAX_RECORDS, opener=urlopen) -> dict:
    """Query PubMed using ESearch; no call unless explicitly invoked."""
    if not term.strip():
        raise ValueError("Search term must not be empty")
    if not 0 <= retmax <= MAX_RECORDS:
        raise ValueError("retmax out of bounds")
    url = build_url("esearch.fcgi", {
        "db": "pubmed", "term": term, "retmode": "json", "retmax": retmax,
        "sort": "pub_date", "tool": "OES-D2-E2",
    })
    request = Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with opener(request, timeout=20) as response:
            payload = json.loads(response.read().decode("utf-8"))
        result = payload["esearchresult"]
        ids = result["idlist"]
        total = int(result["count"])
        if not isinstance(ids, list) or not all(str(x).isdigit() for x in ids):
            raise ValueError("Invalid PMID list")
        if total < len(ids):
            raise ValueError("Count smaller than returned IDs")
        return {"query": term, "count": total, "pmids": [str(x) for x in ids],
                "endpoint": "esearch.fcgi", "url": url,
                "retrieved_at_utc": datetime.now(timezone.utc).isoformat(),
                "query_translation": result.get("querytranslation"),
                "warnings": result.get("warninglist", {})}
    except (KeyError, ValueError, json.JSONDecodeError, UnicodeError) as exc:
        raise RetrievalError("Malformed ESearch response") from exc


def esummary(pmids: list[str], *, opener=urlopen) -> list[dict]:
    """Retrieve public metadata for at most 20 PubMed records."""
    if not pmids:
        return []
    if len(pmids) > MAX_RECORDS or any(not x.isdigit() for x in pmids):
        raise ValueError("Invalid PMID list")
    url = build_url("esummary.fcgi", {
        "db": "pubmed", "id": ",".join(pmids), "retmode": "json",
        "tool": "OES-D2-E2",
    })
    request = Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with opener(request, timeout=20) as response:
            result = json.loads(response.read().decode("utf-8"))["result"]
        records = []
        for pmid in pmids:
            item = result[pmid]
            records.append({
                "pmid": pmid, "title": item.get("title"),
                "pubdate": item.get("pubdate"), "epubdate": item.get("epubdate"),
                "source": item.get("source"), "doi": next(
                    (x.get("value") for x in item.get("articleids", [])
                     if x.get("idtype") == "doi"), None),
            })
        return records
    except (KeyError, ValueError, UnicodeError, TypeError) as exc:
        raise RetrievalError("Malformed ESummary response") from exc


def report(term: str, *, opener=urlopen) -> dict:
    """Perform 2 HTTPS requests, no file writes or scientific judgments."""
    found = esearch(term, opener=opener)
    return {
        "status": "retrieval_only",
        "source": "NCBI PubMed E-utilities",
        "product_id": "OES-P-2026-000401",
        "baseline_date": "2026-10-04",
        "search": found,
        "records": esummary(found["pmids"], opener=opener),
        "limits": ["Not an exhaustive review", "No eligibility or impact decision",
                   "No ProductVersion/currentness/GRADE changes"],
    }
