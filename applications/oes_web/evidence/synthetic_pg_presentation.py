"""Read-only technical demonstration of synthetic PostgreSQL Study/Report links.

Uses the already gated PG-A4 reader, never enables database access itself.
"""
from django.db import DatabaseError
from django.http import Http404
from django.shortcuts import render

from .synthetic_pg_reader import list_synthetic_study_report_links

TEMPLATE = "evidence/synthetic_pg_links.html"


def synthetic_pg_links(request):
    if request.method != "GET":
        raise Http404
    try:
        links = list_synthetic_study_report_links()
    except (DatabaseError, RuntimeError):
        # Fail closed: do not expose credentials, SQL, driver errors or topology.
        return render(request, TEMPLATE, {"hold": True}, status=503)
    return render(request, TEMPLATE, {"hold": False, "links": links})
