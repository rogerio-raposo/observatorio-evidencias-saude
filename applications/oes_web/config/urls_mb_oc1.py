"""Only the MB-OC1 auth/Q0 journey, never historical readers or Q1/Q2."""
from django.urls import path
from evidence.views import MBLoginView, MBLogoutView, q0_registration, q0_reference

urlpatterns = [path('accounts/login/', MBLoginView.as_view(), name='mb-login'),
               path('accounts/logout/', MBLogoutView.as_view(), name='mb-logout'),
               path('questions/q0/register/', q0_registration, name='q0-register'),
               path('questions/q0/review/', q0_reference, name='q0-review'),
               path('', q0_registration, name='home')]
