from django.urls import path
from .views import catalog, detail, synthetic_path, evidence_sheet_n2
from .synthetic_pg_presentation import synthetic_pg_links

urlpatterns = [
    path("", catalog, name="home"),
    path("signals/<str:nct>/", detail, name="signal-detail"),
    path("synthetic-path/", synthetic_path, name="synthetic-path"),
    path("synthetic-pg-links/", synthetic_pg_links, name="synthetic-pg-links"),
    path("evidence-sheets/<str:product_id>/", evidence_sheet_n2, name="evidence-sheet-n2"),
]
