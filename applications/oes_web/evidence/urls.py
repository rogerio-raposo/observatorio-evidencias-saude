from django.urls import path
from .views import catalog, detail

urlpatterns = [
    path("", catalog, name="home"),
    path("signals/<str:nct>/", detail, name="signal-detail"),
]
