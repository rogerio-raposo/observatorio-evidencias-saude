#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-s5-artifacts}"
mkdir -p "$out_dir"

ts="$(date --iso-8601=seconds)"
{
  echo "probe_scope=TOPI-N2-DCBTI-01 corrective preparation / B1R1"
  echo "probe_type=runtime_connectivity_only"
  echo "probe_started_at=$ts"
  echo "runner_os=${RUNNER_OS:-unknown}"
  echo "runner_arch=${RUNNER_ARCH:-unknown}"
  echo "github_run_id=${GITHUB_RUN_ID:-unknown}"
  echo "github_sha=${GITHUB_SHA:-unknown}"
  curl --version | head -n 1
} | tee "$out_dir/TOPI-B1R1-connectivity-runtime.txt"

probe_json() {
  local name="$1"
  local url="$2"
  local body="$out_dir/TOPI-B1R1-connectivity-${name}.json"
  local headers="$out_dir/TOPI-B1R1-connectivity-${name}.headers"
  local meta="$out_dir/TOPI-B1R1-connectivity-${name}.meta"

  {
    echo "name=$name"
    echo "url=$url"
    echo "attempted_at=$(date --iso-8601=seconds)"
  } > "$meta"

  http_code="$(
    curl --fail --silent --show-error --location       --connect-timeout 10 --max-time 20 --retry 2 --retry-delay 1       -D "$headers" -o "$body" -w '%{http_code}' "$url"
  )"

  echo "http_code=$http_code" >> "$meta"
  echo "completed_at=$(date --iso-8601=seconds)" >> "$meta"
  test "$http_code" = "200"
}

probe_json "pubmed-einfo"   "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed&retmode=json"

python3 - <<'PY'
import json
from pathlib import Path
p=Path("s5-artifacts/TOPI-B1R1-connectivity-pubmed-einfo.json")
d=json.loads(p.read_text())
info=d.get("einforesult",{}).get("dbinfo",[])
if not info or str(info[0].get("dbname","")).lower()!="pubmed":
    raise SystemExit("PubMed EInfo probe returned unexpected payload")
print("PUBMED_EUTILS_CONNECTIVITY=VERIFIED")
PY

probe_json "clinicaltrials-version"   "https://clinicaltrials.gov/api/v2/version"

python3 - <<'PY'
import json
from pathlib import Path
p=Path("s5-artifacts/TOPI-B1R1-connectivity-clinicaltrials-version.json")
d=json.loads(p.read_text())
v=d.get("apiVersion")
if not isinstance(v,str) or not v:
    raise SystemExit("ClinicalTrials.gov API v2 probe returned unexpected payload")
print(f"CLINICALTRIALS_GOV_API_V2_CONNECTIVITY=VERIFIED apiVersion={v}")
PY

{
  echo "PUBMED_EUTILS_CONNECTIVITY=VERIFIED"
  echo "CLINICALTRIALS_GOV_API_V2_CONNECTIVITY=VERIFIED"
  echo "probe_completed_at=$(date --iso-8601=seconds)"
  echo "NO_TARGET_SPECIFIC_QUERY_EXECUTED=true"
  echo "NO_MEASUREMENT_EVENT_EXECUTED=true"
  echo "B1R1_MATERIALIZATION_EXECUTED=false"
} | tee "$out_dir/TOPI-B1R1-connectivity-summary.txt"
