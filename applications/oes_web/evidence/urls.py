from django.urls import path
from .views import detail

urlpatterns = [
    path("", detail, {"nct": "NCT01438697"}, name="home"),
    path("signals/<str:nct>/", detail, name="signal-detail"),
]
