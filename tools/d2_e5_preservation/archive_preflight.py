"""Offline GitHub archival preflight; produces a plan, never publishes data."""
import hashlib
import json
import re
from pathlib import Path

from preserve import MAX_BYTES, MAX_STUDIES, _validate

ID = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]{0,79}\Z")
NAMES = ("response.raw.json", "manifest.json", "summary.json")
PREFIX = "artifacts/d2/clinicaltrials-gov/observations"


def prepare_archival_plan(package_dir, existing_paths=()):
    """Fail closed on invalid packages, path collisions and inconsistent metadata.

    existing_paths: trusted listing of already existing repository paths. This
    does not replace the live Freshness Gate immediately before a GitHub commit.
    """
    folder = Path(package_dir)
    if not folder.is_dir() or folder.is_symlink():
        raise ValueError("Expected actual evidence directory")
    entries = list(folder.iterdir())
    if len(entries) != 3 or {p.name for p in entries} != set(NAMES):
        raise ValueError("Evidence package must contain exactly three files")
    if any(not p.is_file() or p.is_symlink() for p in entries):
        raise ValueError("Unexpected file type or symlink")
    raw = (folder / NAMES[0]).read_bytes()
    if len(raw) > MAX_BYTES:
        raise ValueError("Raw JSON exceeds cap")
    payload, ids = _validate(raw)
    def load(name):
        data = json.loads((folder / name).read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError("Expected JSON object: " + name)
        return data
    manifest, summary = load(NAMES[1]), load(NAMES[2])
    digest = hashlib.sha256(raw).hexdigest()
    observation = manifest.get("observation_id")
    if not isinstance(observation, str) or ID.fullmatch(observation) is None:
        raise ValueError("Unsafe observation ID")
    if manifest.get("schema_version") != "oes.d2.e5.evidence/1":
        raise ValueError("Unexpected manifest version")
    if manifest.get("raw_sha256") != digest or manifest.get("response_bytes") != len(raw):
        raise ValueError("Raw body digest/size mismatch")
    if manifest.get("returned_count") != len(ids) or manifest.get("nct_ids_in_return_order") != ids:
        raise ValueError("NCT list/count mismatch")
    if manifest.get("total_count_if_provided") != payload.get("totalCount"):
        raise ValueError("Total count mismatch")
    if manifest.get("next_page_token_present") is not bool(payload.get("nextPageToken")):
        raise ValueError("Pagination flag mismatch")
    partial = (bool(payload.get("nextPageToken")) or payload.get("totalCount") is None
               or payload["totalCount"] > len(ids))
    scope = "PARTIAL_FIRST_PAGE_ONLY" if partial else "PASS_TECHNICAL_QUERY_ONLY"
    if manifest.get("scope_status") != scope or manifest.get("scientific_appraisal_performed") is not False:
        raise ValueError("Invalid scope/appraisal flags")
    if (summary.get("observation_id") != observation
            or summary.get("raw_sha256") != digest
            or summary.get("returned_count") != len(ids)
            or summary.get("status") != scope
            or summary.get("scientific_appraisal_performed") is not False
            or summary.get("schema_version") != manifest["schema_version"]):
        raise ValueError("Summary/manifest mismatch")
    root = PREFIX + "/" + observation
    paths = [root + "/" + n for n in NAMES]
    existing = set(existing_paths)
    if any(not isinstance(s, str) for s in existing):
        raise ValueError("Invalid existing path listing")
    if root in existing or any(x.startswith(root + "/") for x in existing):
        raise FileExistsError("Observation directory already exists")
    if any(x in existing for x in paths):
        raise FileExistsError("Collision")
    files = [{"path": paths[i], "sha256": hashlib.sha256((folder / name).read_bytes()).hexdigest(),
              "bytes": (folder / name).stat().st_size} for i, name in enumerate(NAMES)]
    return {
        "classification": "OFFLINE_PREFLIGHT_PASS_PUBLICATION_NOT_AUTHORIZED",
        "observation_id": observation,
        "destination": root,
        "files": files,
        "source_scope": scope,
        "content_review": "REQUIRED_NOT_PERFORMED",
        "live_head_freshness_gate": "REQUIRED_BEFORE_PUBLICATION",
        "github_publication": "NOT_PERFORMED",
        "durably_archived": False,
        "limitations": [
            "No factual JSON content approval is implied",
            "No external GitHub HEAD or repository listing verified by offline code",
            "No scientific appraisal or durable-archive claim",
        ],
    }
