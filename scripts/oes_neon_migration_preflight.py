#!/usr/bin/env python3
"""Offline, read-only OES Neon migration inventory. Never connects or runs SQL."""
import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

MANIFEST = "database/f4-neon-sandbox-schema-migration-manifest.txt"
WORKFLOW = ".github/workflows/validate-s5.yml"
EXPECTED_PARTS = {
    "031": ["031a_propagation_core.sql", "031b_propagation_signal_adapter.sql", "031c_rebaseline_core.sql", "031d_propagation_rebaseline_helpers.sql", "031e_rebaseline_child_validators.sql"],
    "032": ["032a_temporal_calibration_core.sql", "032b_temporal_cadence_contract.sql", "032c_temporal_sla_contract.sql", "032d_temporal_sla_runtime.sql"],
    "033": ["033a_temporal_observation_core.sql", "033b_temporal_measurement_core.sql", "033c_temporal_observation_guards.sql", "033d_temporal_observation_helpers_views.sql", "033e_temporal_observation_issue_validators.sql"],
}
ENTRY_RE = re.compile(r"^\s*psql -v ON_ERROR_STOP=1 -f (database/[A-Za-z0-9_./-]+\.sql)\s+2>&1\s*\|\s*tee\s+", re.M)
INCLUDE_RE = re.compile(r"^\s*\\ir\s+([^\s]+)\s*$", re.M)
ANY_INCLUDE_RE = re.compile(r"^\s*\\i(?:r)?(?:\s|$)", re.M)
SHA_RE = re.compile(r"^[0-9a-f]{40}$")

class PreflightFailure(Exception):
    pass

def ensure(condition, message):
    if not condition:
        raise PreflightFailure(message)

def read_repo_file(root, name):
    ensure(not Path(name).is_absolute() and ".." not in Path(name).parts, f"unsafe path: {name}")
    path = root / name
    ensure(path.is_file() and not path.is_symlink() and path.resolve().is_relative_to(root.resolve()), f"missing/unsafe file: {name}")
    return path.read_bytes()

def git_cmd(root, *args):
    p = subprocess.run(["git", "-C", str(root), *args], capture_output=True, text=True, check=False)
    ensure(p.returncode == 0, f"git check failed: {' '.join(args)}")
    return p.stdout.strip()

def parse_workflow(text):
    start = text.find("- name: Install baseline through migration 029")
    ensure(start >= 0, "S5 migration installation step not found")
    end = text.find("\n      - name:", start + 1)
    ensure(end > start, "S5 installation step end not found")
    commands = ENTRY_RE.findall(text[start:end])
    ensure(len(commands) == 36 and len(set(commands)) == 36, "S5 installation command count/uniqueness mismatch")
    return commands

def inspect(root, expected_head=None, skip_git_check=False):
    if not skip_git_check:
        ensure(expected_head and SHA_RE.fullmatch(expected_head), "40-character --expected-head required")
        observed = git_cmd(root, "rev-parse", "HEAD")
        ensure(observed == expected_head, "git HEAD does not match expected HEAD")
        ensure(not git_cmd(root, "status", "--porcelain", "--untracked-files=no"), "tracked changes in checkout")
    else:
        observed = "SYNTHETIC_TEST_ONLY"
    manifest_raw = read_repo_file(root, MANIFEST)
    workflow_raw = read_repo_file(root, WORKFLOW)
    entries = [line.strip() for line in manifest_raw.decode("utf-8").splitlines() if line.strip() and not line.lstrip().startswith("#")]
    ensure(len(entries) == 36 and len(set(entries)) == 36, "manifest count/uniqueness mismatch")
    ensure(entries[0] == "database/poc-s1.sql" and entries[-1] == "database/036_temporal_first_measurement_semantics.sql", "unexpected migration bounds")
    workflow_entries = parse_workflow(workflow_raw.decode("utf-8"))
    ensure(entries == workflow_entries, "manifest order differs from S5 commands")
    fingerprints = []
    fragments = []
    for entry in entries:
        source = read_repo_file(root, entry)
        if not skip_git_check:
            git_cmd(root, "ls-files", "--error-unmatch", "--", entry)
        fingerprints.append((entry, hashlib.sha256(source).hexdigest()))
        source_text = source.decode("utf-8")
        referenced = INCLUDE_RE.findall(source_text)
        ensure(len(referenced) == len(ANY_INCLUDE_RE.findall(source_text)), f"unsupported include syntax: {entry}")
        mig = Path(entry).name[:3]
        ensure(referenced == EXPECTED_PARTS.get(mig, []), f"unexpected include dependencies: {entry}")
        for part in referenced:
            include_path = str(Path(entry).parent / part)
            fragment_raw = read_repo_file(root, include_path)
            ensure(not ANY_INCLUDE_RE.search(fragment_raw.decode("utf-8")), f"nested include forbidden: {include_path}")
            if not skip_git_check:
                git_cmd(root, "ls-files", "--error-unmatch", "--", include_path)
            fragments.append((include_path, hashlib.sha256(fragment_raw).hexdigest()))
    ensure(len(fragments) == 14 and len(set(p for p, _ in fragments)) == 14, "fragment count/uniqueness mismatch")
    # Hash a canonical, unambiguous inventory representation, not a SQL execution transcript.
    lines = [f"{name}\t{digest}\n" for name, digest in fingerprints + fragments]
    inventory_digest = hashlib.sha256("".join(lines).encode("utf-8")).hexdigest()
    return {
        "status": "STATIC_INVENTORY_VALIDATED_ONLY",
        "sql_executed": False,
        "neon_accessed": False,
        "git_head": observed,
        "entry_count": len(fingerprints),
        "fragment_count": len(fragments),
        "inventory_sha256": inventory_digest,
        "manifest_sha256": hashlib.sha256(manifest_raw).hexdigest(),
        "workflow_sha256": hashlib.sha256(workflow_raw).hexdigest(),
        "entries": [{"path": p, "sha256": h} for p, h in fingerprints],
        "fragments": [{"path": p, "sha256": h} for p, h in fragments],
    }

def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", type=Path, default=Path.cwd())
    ap.add_argument("--expected-head", help="immutable Git commit SHA; mandatory outside unit tests")
    args = ap.parse_args(argv)
    try:
        result = inspect(args.root.resolve(), args.expected_head)
    except (PreflightFailure, UnicodeError, OSError) as exc:
        print(json.dumps({"status": "BLOCKED", "reason": str(exc), "sql_executed": False, "neon_accessed": False}, ensure_ascii=False), file=sys.stderr)
        return 2
    print(json.dumps(result, sort_keys=True, indent=2))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
