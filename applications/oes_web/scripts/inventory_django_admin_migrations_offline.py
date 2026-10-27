"""PF-I04/P1: inventory Django administrative migration graph, without any DB."""
import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
import django
django.setup()
from django.db.migrations.loader import MigrationLoader

EXPECTED = {"auth", "contenttypes", "sessions"}
loader = MigrationLoader(None)
ordered = []
for app in sorted(EXPECTED):
    leaves = loader.graph.leaf_nodes(app)
    for leaf in leaves:
        for node in loader.graph.forwards_plan(leaf):
            if node[0] in EXPECTED and node not in ordered:
                ordered.append(node)
print("Django:", django.get_version())
print("Administrative migration graph (offline; no SQL generated):")
for app, name in ordered:
    migration = loader.disk_migrations[(app, name)]
    print(f"{app}.{name}: " + ", ".join(type(op).__name__ for op in migration.operations))
print("Total:", len(ordered))
