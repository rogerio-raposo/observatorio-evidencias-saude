from django.urls import path
from .views import catalog, detail, synthetic_path, evidence_sheet_n2
from .synthetic_pg_presentation import synthetic_pg_links
from .q0_synthetic_preview import q0_synthetic_preview
from .q0_access_status import q0_access_status

urlpatterns = [
    path("", catalog, name="home"),
    path("signals/<str:nct>/", detail, name="signal-detail"),
    path("synthetic-path/", synthetic_path, name="synthetic-path"),
    path("synthetic-pg-links/", synthetic_pg_links, name="synthetic-pg-links"),
    path("synthetic-q0-preview/", q0_synthetic_preview, name="q0-synthetic-preview"),
    path("synthetic-q0-access/", q0_access_status, name="q0-access-status"),
    path("evidence-sheets/<str:product_id>/", evidence_sheet_n2, name="evidence-sheet-n2"),
]
