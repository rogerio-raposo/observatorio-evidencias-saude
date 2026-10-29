"""Unmanaged, offline-only mappings of existing OES PostgreSQL tables.

No application writer is configured or enabled. PostgreSQL constraints,
composite foreign keys and triggers remain database-owned.
"""
from django.db import models
from django.db.models.functions import Now


class OesEntity(models.Model):
    entity_uuid = models.UUIDField(primary_key=True)
    oes_id = models.TextField(unique=True)
    entity_type = models.TextField()
    created_at = models.DateTimeField(db_default=Now())
    created_by = models.TextField(null=True)
    retired_at = models.DateTimeField(null=True)

    class Meta:
        managed = False
        db_table = '"core"."entity"'


class OesEntityVersion(models.Model):
    version_uuid = models.UUIDField(primary_key=True)
    entity_uuid = models.UUIDField()
    version_no = models.IntegerField()
    version_status = models.TextField()
    valid_from = models.DateTimeField(db_default=Now())
    valid_to = models.DateTimeField(null=True)
    supersedes_version_uuid = models.UUIDField(null=True)
    created_at = models.DateTimeField(db_default=Now())
    created_by = models.TextField(null=True)
    change_type = models.TextField()
    change_note = models.TextField(null=True)

    class Meta:
        managed = False
        db_table = '"core"."entity_version"'


class OesQuestion(models.Model):
    entity_uuid = models.UUIDField(primary_key=True)
    responsible_actor_id = models.TextField(null=True)

    class Meta:
        managed = False
        db_table = '"investigation"."question"'
        # Django permission metadata only; never manage or migrate the scientific table.
        permissions = [("prepare_question", "Can prepare an OES question")]


class OesQuestionVersion(models.Model):
    version_uuid = models.UUIDField(primary_key=True)
    entity_uuid = models.UUIDField()
    parent_question_entity_uuid = models.UUIDField(null=True)
    original_text = models.TextField()
    normalized_text = models.TextField(null=True)
    preparation_stage = models.TextField()
    question_type = models.TextField(null=True)
    structure_type = models.TextField(null=True)
    context_payload = models.JSONField(null=True)
    time_horizon_payload = models.JSONField(null=True)

    class Meta:
        managed = False
        db_table = '"investigation"."question_version"'


class OesQuestionCommandReceipt(models.Model):
    pk = models.CompositePrimaryKey("actor_id", "request_id")
    actor_id = models.TextField()
    request_id = models.TextField()
    fingerprint_sha256 = models.CharField(max_length=64)
    question_entity_uuid = models.UUIDField()
    question_id = models.TextField()
    resulting_version_uuid = models.UUIDField()
    resulting_version_no = models.IntegerField()
    command_kind = models.TextField()
    justification = models.TextField()
    committed_at = models.DateTimeField(db_default=Now())

    class Meta:
        managed = False
        db_table = '"investigation"."question_command_receipt"'
