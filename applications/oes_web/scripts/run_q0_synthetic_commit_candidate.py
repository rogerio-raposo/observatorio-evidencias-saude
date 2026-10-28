"""One-shot synthetic Q0 commit candidate. Not wired to Django URLs or workflows.

Requires separately configured OES_Q0_COMMIT_EXPLICIT_APPROVAL and temporary
OES_QPREP_LOGIN_PASSWORD; never accepts an owner role or a public HTTP request.
Persistence is intentional; this script must not be rerun automatically.
"""
import os
import sys
from contextlib import contextmanager
from pathlib import Path
from uuid import uuid4

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
if os.getenv("OES_Q0_COMMIT_EXPLICIT_APPROVAL") != "ONE_SYNTHETIC_Q0_COMMIT":
    sys.exit("NOT_RUN: synthetic commit gate disabled")
password = os.getenv("OES_QPREP_LOGIN_PASSWORD")
if not password:
    sys.exit("NOT_RUN: temporary Q0 login credential unavailable")
if os.getenv("DJANGO_SETTINGS_MODULE", "config.settings") != "config.settings":
    sys.exit("NOT_RUN: unexpected Django settings")
os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings"

from django.conf import settings
if settings.DATABASES:
    sys.exit("NOT_RUN: existing database configuration is not isolated")
ALIAS = "oes_qprep_commit_trial"
settings.DATABASES = {
    "default": {"ENGINE": "django.db.backends.dummy"},
    ALIAS: {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_qprep_login",
        "PASSWORD": password,
        "HOST": "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech",
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require", "connect_timeout": 10},
        "CONN_MAX_AGE": 0,
    },
}
import django
django.setup()
from django.db import connections, transaction
from evidence.models import (
    OesEntity, OesEntityVersion, OesQuestion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)
from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
from evidence.question_orm_q0_dormant import DormantQ0OrmPort
from evidence.question_uow_offline import OfflineQuestionUnitOfWork
from evidence.question_preparation import (
    QuestionCommand, PreparationConflict, command_fingerprint,
)

class _TrialRepository(DjangoQ0Repository):
    def __init__(self, alias):
        if alias != ALIAS:
            raise RuntimeError("unexpected alias")
        self.alias = alias

@contextmanager
def _repository():
    yield _TrialRepository(ALIAS)

def _execute(command, actor):
    port = DormantQ0OrmPort(
        atomic_factory=lambda: transaction.atomic(using=ALIAS),
        repository_factory=_repository,
    )
    return OfflineQuestionUnitOfWork(port).execute(
        command=command, actor_id=actor, fingerprint=command_fingerprint(command),
    )

def _verify_five(command, actor):
    entity = OesEntity.objects.using(ALIAS).get(oes_id=command.question_id)
    question = OesQuestion.objects.using(ALIAS).get(pk=entity.pk)
    version = OesEntityVersion.objects.using(ALIAS).get(
        entity_uuid=entity.pk, version_no=1, version_status="current",
    )
    qversion = OesQuestionVersion.objects.using(ALIAS).get(pk=version.pk)
    receipt = OesQuestionCommandReceipt.objects.using(ALIAS).get(
        actor_id=actor, request_id=command.request_id,
    )
    if not (
        entity.entity_type == "Question"
        and question.responsible_actor_id == actor
        and qversion.entity_uuid == entity.pk
        and qversion.original_text == command.original_text
        and qversion.preparation_stage == "q0_draft"
        and qversion.normalized_text is None
        and receipt.question_entity_uuid == entity.pk
        and receipt.resulting_version_uuid == version.pk
        and receipt.resulting_version_no == 1
        and receipt.fingerprint_sha256 == command_fingerprint(command)
    ):
        raise RuntimeError("persisted Q0 invariants mismatch")
    return (entity.pk, version.pk)

def main():
    conn = connections[ALIAS]
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT session_user, current_user, current_database(), "
                "current_setting('transaction_read_only'), "
                "pg_has_role(current_user, 'oes_qprep_writer', 'USAGE')"
            )
            if cur.fetchone() != (
                "oes_qprep_login", "oes_qprep_login", "oes_sandbox", "off", True
            ):
                raise RuntimeError("Q0 connection identity or mode mismatch")
        nonce = uuid4().hex
        actor = "oes_synthetic_q0"
        command = QuestionCommand(
            "commit_" + nonce, "OES-SYNTH-Q0-COMMIT-" + nonce, 0,
            "Synthetic Q0 controlled commit; no factual research data.",
        )
        result = _execute(command, actor)
        if result != {"status": "PREPARATORY_ONLY",
                       "question_id": command.question_id, "version": 1}:
            raise RuntimeError("unexpected Q0 commit result")
        before = _verify_five(command, actor)
        replay = _execute(command, actor)
        after = _verify_five(command, actor)
        if replay != result or after != before:
            raise RuntimeError("idempotent replay mismatch")
        altered = QuestionCommand(
            command.request_id, command.question_id, 0,
            "Different synthetic content must conflict.",
        )
        try:
            _execute(altered, actor)
        except PreparationConflict:
            pass
        else:
            raise RuntimeError("conflicting replay accepted")
        if _verify_five(command, actor) != before:
            raise RuntimeError("conflicting replay changed persistent records")
        print("PASS Q0_SYNTHETIC_COMMIT_REPLAY_CONFLICT_READBACK")
    finally:
        conn.close()

try:
    main()
except BaseException as exc:
    # A failure after a possible commit is INCONCLUSIVE; never auto-retry.
    sys.exit("INCONCLUSIVE_Q0_COMMIT: " + type(exc).__name__)
