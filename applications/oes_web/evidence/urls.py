from django.urls import path
from .views import catalog, detail, synthetic_path

urlpatterns = [
    path("", catalog, name="home"),
    path("signals/<str:nct>/", detail, name="signal-detail"),
    path("synthetic-path/", synthetic_path, name="synthetic-path"),
]
