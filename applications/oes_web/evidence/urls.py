from django.urls import path
from .views import catalog, detail, synthetic_path, evidence_sheet_n2

urlpatterns = [
    path("", catalog, name="home"),
    path("signals/<str:nct>/", detail, name="signal-detail"),
    path("synthetic-path/", synthetic_path, name="synthetic-path"),
    path("evidence-sheets/<str:product_id>/", evidence_sheet_n2, name="evidence-sheet-n2"),
]
