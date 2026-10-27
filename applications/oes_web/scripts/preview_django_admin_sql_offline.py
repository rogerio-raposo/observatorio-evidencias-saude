"""Generate review-only SQL with Django sqlmigrate against disposable local PostgreSQL."""
import os
import pathlib
import subprocess
import sys

if os.getenv("OES_LOCAL_SQL_INVENTORY") != "1":
    raise SystemExit("HOLD: offline gate disabled")

os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings_migration_inventory"
import django
django.setup()
from django.db.migrations.loader import MigrationLoader

apps = {"auth", "contenttypes", "sessions"}
loader = MigrationLoader(None)
ordered = []
for app in sorted(apps):
    for leaf in loader.graph.leaf_nodes(app):
        for node in loader.graph.forwards_plan(leaf):
            if node[0] in apps and node not in ordered:
                ordered.append(node)
if len(ordered) != 15:
    raise SystemExit(f"HOLD: migration inventory drift ({len(ordered)} instead of 15)")
out = pathlib.Path("migration-sql-evidence")
out.mkdir(exist_ok=True)
summary = [f"Django {django.get_version()} | PostgreSQL local disposable | no Neon", "SQL preview only: RunPython and post_migrate effects are not rendered by sqlmigrate."]
for app, name in ordered:
    result = subprocess.run(
        [sys.executable, "manage.py", "sqlmigrate", app, name, "--database", "default", "--settings", "config.settings_migration_inventory"],
        text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False,
    )
    if result.returncode != 0:
        raise SystemExit(f"HOLD: sqlmigrate {app}.{name} failed: {result.stderr[-1500:]}")
    (out / f"{app}.{name}.sql").write_text(result.stdout, encoding="utf-8")
    summary.append(f"{app}.{name}: {len(result.stdout.splitlines())} preview lines")
(out / "SUMMARY.txt").write_text("\n".join(summary) + "\n", encoding="utf-8")
print("\n".join(summary))
