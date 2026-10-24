"""Produce a clearly synthetic three-file E6 artifact, without HTTP."""
import json
from pathlib import Path
from e6_capture import build_package

def main():
    raw = json.dumps({
        "synthetic_notice": "SYNTHETIC ONLY; not fetched from ClinicalTrials.gov",
        "studies": [{"protocolSection": {"identificationModule": {
            "nctId": "NCT00000001", "briefTitle": "SYNTHETIC PLACEHOLDER"}}}],
        "totalCount": 1
    }, separators=(",", ":")).encode("utf-8")
    folder = Path("synthetic-artifact")
    plan = build_package(raw, "2026-10-24T00:00:00+00:00",
        "2026-10-24T00:00:01+00:00", "application/json", folder,
        1, 1, "a" * 40, "SYNTHETIC-E6-A3-TRANSPORT")
    if len(plan["files"]) != 3:
        raise ValueError("Package incomplete")
    for name in ("manifest.json", "summary.json"):
        file = folder / name
        item = json.loads(file.read_text(encoding="utf-8"))
        item["synthetic_fixture"] = True
        item["synthetic_notice"] = "ALL ORIGIN/HTTP/RUN FIELDS ARE ARTIFICIAL; NO LIVE GET"
        file.write_text(json.dumps(item, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    # Validate again after explicit synthetic labels are added.
    from archive_preflight import prepare_archival_plan
    check = prepare_archival_plan(folder)
    if check["files"][0]["sha256"] != plan["files"][0]["sha256"]:
        raise ValueError("Recheck failed")
    print(json.dumps({"status": "SYNTHETIC_ONLY_PENDING_ARTIFACT_UPLOAD",
        "sha256": check["files"][0]["sha256"], "files": len(check["files"])}))

if __name__ == "__main__":
    main()
