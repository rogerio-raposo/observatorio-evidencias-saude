"""Offline-only Django-first Q0/Q1 transaction blueprint.

Generates ORM QuerySets for structural contract tests. Never evaluates a
QuerySet, opens a connection, or enables writes. This is NOT a live backend.
"""
from django.db.models import OuterRef, Subquery, Exists

from .models import (
    OesEntity, OesEntityVersion, OesQuestion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)


def scoped_current_question(*, question_id, actor_id):
    """Join via UUID fields explicitly; composite FKs remain PostgreSQL-owned.

    Deliberately split into queries: QuerySets are lazy. Connected execution
    must assemble/validate the matching version and original text within
    transaction.atomic(using=approved_writer) under a cooperative question lock.
    """
    if not isinstance(question_id, str) or not question_id:
        raise ValueError("invalid question_id")
    if not isinstance(actor_id, str) or not actor_id:
        raise ValueError("invalid actor_id")
    entity_ids = OesEntity.objects.filter(oes_id=question_id, entity_type="Question").values("entity_uuid")
    scoped_questions = OesQuestion.objects.filter(
        entity_uuid__in=entity_ids, responsible_actor_id=actor_id
    ).values("entity_uuid")
    # Match BOTH columns of the database-owned composite FK. A matching
    # question_version is mandatory before a Q1 transition may use this state.
    question_versions = OesQuestionVersion.objects.filter(
        version_uuid=OuterRef("version_uuid"),
        entity_uuid=OuterRef("entity_uuid"),
    )
    versions = OesEntityVersion.objects.filter(
        entity_uuid__in=scoped_questions, version_status="current", valid_to__isnull=True
    ).annotate(
        has_question_version=Exists(question_versions),
        q0_original_text=Subquery(question_versions.values("original_text")[:1]),
    ).filter(has_question_version=True).order_by("-version_no")
    return versions


def request_receipt(*, actor_id, request_id):
    if not isinstance(actor_id, str) or not actor_id:
        raise ValueError("invalid actor_id")
    if not isinstance(request_id, str) or not request_id:
        raise ValueError("invalid request_id")
    return OesQuestionCommandReceipt.objects.filter(
        actor_id=actor_id, request_id=request_id
    )


def q1_version_transition(*, version_uuid, entity_uuid, expected_version):
    """Conditional UPDATE *plan*, never executed; no implicit write permission."""
    if type(expected_version) is not int or expected_version < 1:
        raise ValueError("invalid version")
    if version_uuid is None or entity_uuid is None:
        raise ValueError("missing version identity")
    return OesEntityVersion.objects.filter(
        version_uuid=version_uuid, entity_uuid=entity_uuid,
        version_no=expected_version, version_status="current", valid_to__isnull=True
    )


def required_atomic_contract():
    """Human-readable contract, not a connection or executable unit of work."""
    return (
        "approved_writer_alias_only",
        "transaction.atomic(using=approved_writer_alias)",
        "same_connection_for_advisory_lock_and_orm",
        "Q0_Q1_ledger_single_commit_or_rollback",
        "no_uncoordinated_responsibility_mutations",
        "no_automatic_retry_on_uncertain_commit",
    )
