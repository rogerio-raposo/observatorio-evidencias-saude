from django.urls import path
from evidence.views import q0_reference

urlpatterns = [path('questions/q0/review/', q0_reference, name='q0-review'),
               path('', q0_reference, name='home')]
