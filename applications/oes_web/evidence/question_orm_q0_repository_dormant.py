"""Dormant Q0 Django ORM repository implementation.

This module is deliberately uninstantiable until a distinct connected gate.
It is not a Django setting, a writer factory, or an application backend.
The ORM methods show the exact five canonical writes without an SQL adapter.
"""
from .models import (
    OesEntity, OesQuestion, OesEntityVersion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)
from .question_preparation import PreparationHold


class DjangoQ0Repository:
    """Concrete ORM mapping; all entry points remain fail-closed."""

    def __init__(self, *, alias=None):
        # Even a caller supplying an alias cannot activate this repository.
        # Future connected work requires an explicit, reviewed source change.
        raise PreparationHold("HOLD: Django ORM writer gate G2 not authorized")

    def insert_entity(self, entity_uuid, question_id, actor_id):
        return OesEntity.objects.using(self.alias).create(
            entity_uuid=entity_uuid, oes_id=question_id,
            entity_type="Question", created_by=actor_id,
        )

    def insert_question(self, entity_uuid, actor_id):
        return OesQuestion.objects.using(self.alias).create(
            entity_uuid=entity_uuid, responsible_actor_id=actor_id,
        )

    def insert_entity_version(self, version_uuid, entity_uuid, actor_id):
        return OesEntityVersion.objects.using(self.alias).create(
            version_uuid=version_uuid, entity_uuid=entity_uuid, version_no=1,
            version_status="current", created_by=actor_id,
            change_type="initial",
        )

    def insert_question_version(self, version_uuid, entity_uuid, original_text):
        return OesQuestionVersion.objects.using(self.alias).create(
            version_uuid=version_uuid, entity_uuid=entity_uuid,
            original_text=original_text, normalized_text=None,
            preparation_stage="q0_draft",
        )

    def insert_receipt(self, receipt, entity_uuid, version_uuid):
        return OesQuestionCommandReceipt.objects.using(self.alias).create(
            actor_id=receipt.actor_id, request_id=receipt.request_id,
            fingerprint_sha256=receipt.fingerprint,
            question_entity_uuid=entity_uuid, question_id=receipt.question_id,
            resulting_version_uuid=version_uuid,
            resulting_version_no=receipt.version,
            command_kind=receipt.command_kind,
            justification=receipt.justification,
        )

    def lock_request(self, actor_id, request_id):
        raise PreparationHold("HOLD: advisory request lock not implemented")

    def lock_question(self, question_id):
        raise PreparationHold("HOLD: advisory question lock not implemented")

    def find_receipt(self, actor_id, request_id):
        raise PreparationHold("HOLD: connected receipt read not implemented")

    def current_question(self, question_id, actor_id):
        raise PreparationHold("HOLD: connected Q0 scope read not implemented")

    def can_access_question(self, question_id, actor_id):
        raise PreparationHold("HOLD: connected scope read not implemented")
