"""Offline-only byte-preserving evidence packaging (OES D2-E5-A3).

No HTTP, imports of application frameworks, or database operations.
The caller must supply observed provenance; this module cannot attest to it.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import tempfile
from datetime import datetime
from pathlib import Path
from urllib.parse import parse_qsl, urlsplit

MAX_BYTES = 2_000_000
MAX_STUDIES = 20
NCT = re.compile(r"NCT[0-9]{8}\Z")


def _utc(value: str) -> bool:
    try:
        date = datetime.fromisoformat(value)
        return date.tzinfo is not None and date.utcoffset() is not None
    except (TypeError, ValueError):
        return False


def _validate(raw: bytes) -> tuple[dict, list[str]]:
    if not isinstance(raw, bytes) or len(raw) > MAX_BYTES:
        raise ValueError("Expected raw bytes within 2 MB cap")
    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeError, ValueError) as exc:
        raise ValueError("Invalid UTF-8 JSON") from exc
    if not isinstance(payload, dict) or not isinstance(payload.get("studies"), list):
        raise ValueError("Expected object with studies list")
    records = payload["studies"]
    if len(records) > MAX_STUDIES:
        raise ValueError("Too many studies")
    ids = []
    for record in records:
        if not isinstance(record, dict):
            raise ValueError("Study must be object")
        protocol = record.get("protocolSection")
        ident = protocol.get("identificationModule") if isinstance(protocol, dict) else None
        nct = ident.get("nctId") if isinstance(ident, dict) else None
        if not isinstance(nct, str) or NCT.fullmatch(nct) is None:
            raise ValueError("Invalid NCT identifier")
        ids.append(nct)
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate NCT identifier")
    total = payload.get("totalCount")
    if total is not None and (type(total) is not int or total < len(ids)):
        raise ValueError("Invalid totalCount")
    token = payload.get("nextPageToken")
    if token is not None and not isinstance(token, str):
        raise ValueError("Invalid nextPageToken")
    return payload, ids


def package_evidence(raw: bytes, provenance: dict, destination: Path) -> dict:
    """Create a complete package in a NEW destination; never overwrite.

    The returned manifest describes caller-supplied provenance, not authenticated
    origin. A failing validation/write leaves no published package.
    """
    payload, ids = _validate(raw)
    required = ("activity_id", "observation_id", "repository_commit_sha",
                "github_run_id", "run_attempt", "requested_url_exact",
                "started_at_utc", "completed_at_utc", "source_http_status",
                "response_content_type")
    if not isinstance(provenance, dict) or any(k not in provenance for k in required):
        raise ValueError("Incomplete provenance")
    if not all(isinstance(provenance[k], str) and provenance[k] for k in
               ("activity_id", "observation_id", "repository_commit_sha", "requested_url_exact")):
        raise ValueError("Invalid identifier or URL")
    if (type(provenance["github_run_id"]) is not int or provenance["github_run_id"] < 1
            or type(provenance["run_attempt"]) is not int or provenance["run_attempt"] < 1):
        raise ValueError("Invalid run identity")
    if provenance["source_http_status"] != 200 or type(provenance["source_http_status"]) is not int:
        raise ValueError("Only successful HTTP 200 responses supported")
    if "application/json" not in str(provenance["response_content_type"]).lower():
        raise ValueError("Expected JSON response content type")
    if not _utc(provenance["started_at_utc"]) or not _utc(provenance["completed_at_utc"]):
        raise ValueError("Missing timezone-aware timestamps")
    if datetime.fromisoformat(provenance["completed_at_utc"]) < datetime.fromisoformat(provenance["started_at_utc"]):
        raise ValueError("Completion before start")
    url = provenance["requested_url_exact"]
    parts = urlsplit(url)
    if parts.scheme != "https" or parts.netloc != "clinicaltrials.gov" or parts.path != "/api/v2/studies" or parts.fragment or parts.username or parts.password:
        raise ValueError("Unexpected source URL")
    pairs = parse_qsl(parts.query, keep_blank_values=True)
    if not pairs or any(k == "pageToken" for k, _ in pairs):
        raise ValueError("Unexpected query or pagination request")
    partial = (bool(payload.get("nextPageToken")) or payload.get("totalCount") is None
               or payload["totalCount"] > len(ids))
    manifest = {
        "schema_version": "oes.d2.e5.evidence/1",
        "activity_id": provenance["activity_id"],
        "observation_id": provenance["observation_id"],
        "repository_commit_sha": provenance["repository_commit_sha"],
        "github_run_id": provenance["github_run_id"],
        "run_attempt": provenance["run_attempt"],
        "source_name": "ClinicalTrials.gov API v2",
        "api_version_if_observed": provenance.get("api_version_if_observed"),
        "method": "GET",
        "requested_url_exact": url,
        "requested_parameters": [{"name": k, "value": v} for k, v in pairs],
        "started_at_utc": provenance["started_at_utc"],
        "completed_at_utc": provenance["completed_at_utc"],
        "source_http_status": 200,
        "response_content_type": provenance["response_content_type"],
        "response_bytes": len(raw),
        "raw_sha256": hashlib.sha256(raw).hexdigest(),
        "returned_count": len(ids),
        "total_count_if_provided": payload.get("totalCount"),
        "next_page_token_present": bool(payload.get("nextPageToken")),
        "nct_ids_in_return_order": ids,
        "scope_status": "PARTIAL_FIRST_PAGE_ONLY" if partial else "PASS_TECHNICAL_QUERY_ONLY",
        "scientific_appraisal_performed": False,
        "limitations": ["Metadata observation only", "No scientific assessment",
                        "Not proof of search completeness", "Artifact is not durable archiving"],
    }
    summary = {"schema_version": manifest["schema_version"],
               "observation_id": manifest["observation_id"],
               "status": manifest["scope_status"], "returned_count": len(ids),
               "raw_sha256": manifest["raw_sha256"], "scientific_appraisal_performed": False}
    dest = Path(destination)
    if dest.exists() or not dest.parent.is_dir():
        raise FileExistsError("Destination must be new and parent must exist")
    temp = Path(tempfile.mkdtemp(prefix=".oes-e5-staging-", dir=dest.parent))
    try:
        (temp / "response.raw.json").write_bytes(raw)
        for name, data in (("manifest.json", manifest), ("summary.json", summary)):
            (temp / name).write_text(json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True) + "\n",
                                     encoding="utf-8")
        if hashlib.sha256((temp / "response.raw.json").read_bytes()).hexdigest() != manifest["raw_sha256"]:
            raise IOError("Hash verification failed")
        if set(x.name for x in temp.iterdir()) != {"response.raw.json", "manifest.json", "summary.json"}:
            raise IOError("Incomplete staging directory")
        if dest.exists():
            raise FileExistsError("Destination created concurrently")
        os.rename(temp, dest)
    finally:
        if temp.exists():
            shutil.rmtree(temp)
    return manifest
