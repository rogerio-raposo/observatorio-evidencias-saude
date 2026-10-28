"""Isolated authentication-store identity; never resides in scientific PostgreSQL."""
import uuid
from django.conf import settings
from django.db import models

class PreparerIdentity(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="oes_preparer_identity")
    actor_uuid = models.UUIDField(unique=True, default=uuid.uuid4, editable=False)
