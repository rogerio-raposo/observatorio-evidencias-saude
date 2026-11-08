"""Q0 application and UI tests: synthetic users, no DB or HTTP write."""
from contextlib import contextmanager
from dataclasses import dataclass, replace
from types import SimpleNamespace
from unittest.mock import Mock, patch
from uuid import UUID

from django.core.exceptions import PermissionDenied
from django.http import QueryDict
from django.template.loader import render_to_string
from django.test import SimpleTestCase, RequestFactory
from django.urls import reverse

from preparer_identity.models import PreparerIdentity
from evidence.question_preparation import (
    QuestionCommand, PreparationHold, PreparationConflict, command_fingerprint,
    submit_authenticated_question_command, register_authenticated_q0,
    review_registered_q0, validate_register_q0,
)
from evidence.question_uow_offline import OfflineQuestionUnitOfWork, Receipt
from evidence.question_orm_q0_dormant import DormantQ0OrmPort
from evidence.forms import Q0RegistrationForm, Q0_MESSAGES, q0_failure_message
from evidence.views import q0_registration

CANONICAL = "evidence.question_orm_q0_connected_recipe_dormant._review_q0_persistence_d1"


class Q0FunctionalServiceTests(SimpleTestCase):
    def setUp(self):
        self.user = Mock(pk=42, is_authenticated=True, is_active=True, is_staff=False, is_superuser=False)
        self.user.has_perm.return_value = True
        self.command = QuestionCommand("q0-request-1", "OES-SYNTH-Q0-GENERAL", 0, "  Pergunta sintética?\n")
        self.actor = "oes:actor:12345678-1234-4234-8234-123456789abc"
        self.lookup = self.enterContext(patch("preparer_identity.resolver.PreparerIdentity.objects.using"))
        self.lookup.return_value.get.return_value = SimpleNamespace(actor_uuid=UUID(self.actor.removeprefix("oes:actor:")))
        self.repo = Mock()
        self.repo.find_receipt.return_value = None
        self.repo.current_question.return_value = None
        self.repo.can_access_question.return_value = True
        self.events = []
        self.exit_failure = False
        @contextmanager
        def atomic():
            self.events.append("begin simulated")
            try:
                yield
            except Exception:
                self.events.append("rollback simulated")
                raise
            self.events.append("commit simulated")
            if self.exit_failure:
                raise RuntimeError("synthetic lost ack")
        @contextmanager
        def repository():
            yield self.repo
        self.verifier = Mock(return_value={"readback_verified": True})
        self.port = DormantQ0OrmPort(atomic_factory=atomic, repository_factory=repository,
            readback_verifier=self.verifier, writer_alias="oes_q0_writer", read_alias="oes_synthetic_reader")

    def simulated_canonical(self):
        # Application delegation boundary only; production has no backend injection.
        # Protocol/authorization/resolver/port/UoW below are the EXISTING components.
        def execute(*, user, command):
            return submit_authenticated_question_command(user=user, command=command,
                unit_of_work=OfflineQuestionUnitOfWork(self.port))
        return self.enterContext(patch(CANONICAL, side_effect=execute))

    def receipt(self, **changes):
        return replace(Receipt(self.actor, self.command.request_id, command_fingerprint(self.command),
                               self.command.question_id, 1, "REGISTER_Q0"), **changes)

    def test_valid_q0_reuses_protocol_five_writes_receipt_and_persisted_actor(self):
        canonical = self.simulated_canonical()
        result = register_authenticated_q0(user=self.user, command=self.command)
        self.assertEqual(result, {"status": "PREPARATORY_ONLY", "question_id": self.command.question_id, "version": 1})
        canonical.assert_called_once_with(user=self.user, command=self.command)
        self.lookup.assert_called_once_with("default")
        self.lookup.return_value.get.assert_called_once_with(user_id=42)
        self.repo.lock_request.assert_called_once_with(self.actor, self.command.request_id)
        self.assertEqual([c[0] for c in self.repo.method_calls if c[0].startswith("insert_")],
            ["insert_entity", "insert_question", "insert_entity_version", "insert_question_version", "insert_receipt"])
        self.assertEqual(self.repo.insert_question_version.call_args.args[2], self.command.original_text)
        self.assertEqual(self.repo.insert_receipt.call_args.args[0], self.receipt())
        self.verifier.assert_called_once()

    def test_anonymous_inactive_admin_or_unpermitted_denied_before_backend(self):
        with patch(CANONICAL) as canonical:
            for attr in ("is_authenticated", "is_active", "is_staff", "is_superuser"):
                original = getattr(self.user, attr)
                setattr(self.user, attr, not original)
                with self.subTest(attr=attr), self.assertRaises(PermissionDenied):
                    register_authenticated_q0(user=self.user, command=self.command)
                setattr(self.user, attr, original)
            self.user.has_perm.return_value = False
            with self.assertRaises(PermissionDenied):
                register_authenticated_q0(user=self.user, command=self.command)
            canonical.assert_not_called()
        self.lookup.assert_not_called()

    def test_absent_persistent_identity_never_uses_user_pk_as_actor(self):
        self.simulated_canonical()
        self.lookup.return_value.get.side_effect = PreparerIdentity.DoesNotExist
        with self.assertRaises(PreparationHold):
            register_authenticated_q0(user=self.user, command=self.command)
        self.repo.lock_request.assert_not_called()

    def test_original_text_whitespace_empty_non_string_or_too_long_rejected(self):
        with patch(CANONICAL) as canonical:
            for text in ("", " \n\t ", None, 1, "q" * 10001, "Synthetic\x00?"):
                with self.subTest(text_type=type(text)), self.assertRaises(PreparationHold):
                    register_authenticated_q0(user=self.user, command=replace(self.command, original_text=text))
            canonical.assert_not_called()

    def test_identifiers_and_non_q0_commands_rejected_before_backend(self):
        invalid = [replace(self.command, **{key:value}) for key, value in (
            ("request_id", "space key"), ("request_id", "q" * 129), ("question_id", "../bad"),
            ("question_id", "q\n"), ("expected_version", True), ("expected_version", 1),
            ("normalized_text", "Q1"), ("justification", "Q2 payload"))]
        @dataclass(frozen=True)
        class ExtendedCommand(QuestionCommand):
            methodological_class: str = "INT"
        invalid.append(ExtendedCommand("r", "q", 0, "Synthetic?"))
        with patch(CANONICAL) as canonical:
            for command in invalid:
                with self.subTest(command=command), self.assertRaises(PreparationHold):
                    register_authenticated_q0(user=self.user, command=command)
            canonical.assert_not_called()

    def test_same_request_replay_is_authorized_and_idempotent_without_new_write(self):
        self.simulated_canonical()
        first = register_authenticated_q0(user=self.user, command=self.command)
        self.repo.reset_mock()
        self.repo.find_receipt.return_value = self.receipt()
        second = register_authenticated_q0(user=self.user, command=self.command)
        self.assertEqual(first, second)
        self.repo.can_access_question.assert_called_once_with(self.command.question_id, self.actor)
        self.repo.insert_entity.assert_not_called()
        self.repo.insert_receipt.assert_not_called()

    def test_fingerprint_conflict_and_existing_question_preserve_conflict(self):
        self.simulated_canonical()
        self.repo.find_receipt.return_value = self.receipt(fingerprint="b" * 64)
        with self.assertRaises(PreparationConflict):
            register_authenticated_q0(user=self.user, command=self.command)
        self.repo.find_receipt.return_value = None
        self.repo.current_question.return_value = {"version":1, "original_text":"Existing synthetic"}
        with self.assertRaises(PreparationConflict):
            register_authenticated_q0(user=self.user, command=self.command)
        self.repo.insert_entity.assert_not_called()

    def test_changed_text_same_request_cannot_silently_become_new_request(self):
        self.simulated_canonical()
        self.repo.find_receipt.return_value = self.receipt()
        with self.assertRaises(PreparationConflict):
            register_authenticated_q0(user=self.user, command=replace(self.command, original_text="Other synthetic?"))
        self.repo.lock_request.assert_called_once_with(self.actor, self.command.request_id)
        self.repo.insert_receipt.assert_not_called()

    def test_fifth_write_failure_stays_hold_and_blocks_automatic_port_reuse(self):
        self.simulated_canonical()
        self.repo.insert_receipt.side_effect = RuntimeError("synthetic failure")
        with self.assertRaises(PreparationHold):
            register_authenticated_q0(user=self.user, command=self.command)
        with self.assertRaisesRegex(PreparationHold, "no automatic retry"):
            register_authenticated_q0(user=self.user, command=self.command)
        self.repo.insert_receipt.assert_called_once()
        self.assertEqual(self.port.last_uncertain_q0["request_id"], self.command.request_id)

    def test_commit_ack_and_readback_failures_never_promoted_to_success(self):
        self.simulated_canonical()
        self.exit_failure = True
        with self.assertRaises(PreparationHold):
            register_authenticated_q0(user=self.user, command=self.command)
        self.assertEqual(len([e for e in self.events if e=="begin simulated"]), 1)
        self.repo.insert_receipt.assert_called_once()
        self.assertIn("Guarde os identificadores", q0_failure_message(PreparationHold()))

    def test_actor_parameter_cannot_be_supplied_and_public_source_gate_stays_hold(self):
        with self.assertRaises(TypeError):
            register_authenticated_q0(user=self.user, command=self.command, actor_id="browser-controlled")
        with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
            register_authenticated_q0(user=self.user, command=self.command)
        self.assertEqual(self.events, [])

    def test_recovery_reuses_d3_without_submission_or_retry(self):
        observation = {"outcome":"INDETERMINATE", "automatic_retry":False}
        with patch("evidence.question_orm_q0_evidence_dormant._recover_q0_commit_evidence", return_value=observation) as recover, patch(CANONICAL) as submit:
            result = review_registered_q0(user=self.user, command=self.command)
            self.assertIs(result, observation)
            recover.assert_called_once_with(user=self.user, command=self.command)
            submit.assert_not_called()

    def test_real_recovery_blueprint_also_holds(self):
        with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
            review_registered_q0(user=self.user, command=self.command)


class Q0FormTests(SimpleTestCase):
    def setUp(self):
        self.data = {"request_id":"q0-request-form", "question_id":"OES-SYNTH-Q0-FORM", "original_text":"  Pergunta sintética?\n"}

    def test_form_constructs_exact_q0_preserving_original_and_request(self):
        form = Q0RegistrationForm(self.data)
        self.assertTrue(form.is_valid(), form.errors)
        command = form.to_command()
        self.assertEqual(command, QuestionCommand(self.data["request_id"], self.data["question_id"], 0, self.data["original_text"]))
        self.assertEqual(form.to_command(), command)
        self.assertIs(validate_register_q0(command), command)

    def test_invalid_text_identifiers_and_lengths_have_messages(self):
        for key, value in (("original_text", "  "), ("original_text", "q"*10001), ("original_text", "Synthetic\x00?"),
                ("request_id", "bad key"), ("question_id", ""), ("question_id", "q"*129)):
            form = Q0RegistrationForm({**self.data, key:value})
            with self.subTest(key=key):
                self.assertFalse(form.is_valid())
                self.assertIn(key, form.errors)
                with self.assertRaises(PreparationHold):
                    form.to_command()

    def test_browser_actor_and_q1_q2_fields_cannot_change_identity_or_command(self):
        for key in ("actor_id", "user_id", "preparer_id", "normalized_text", "justification", "expected_version", "methodological_class"):
            form = Q0RegistrationForm({**self.data, key:"forged"})
            with self.subTest(key=key):
                self.assertFalse(form.is_valid())
                self.assertIn("Dados adicionais", str(form.non_field_errors()))

    def test_duplicate_fields_rejected_without_silent_request_selection(self):
        data = QueryDict("request_id=a&request_id=b&question_id=Q&original_text=Synthetic")
        self.assertFalse(Q0RegistrationForm(data).is_valid())

    def test_bound_invalid_form_renders_accessible_errors_and_escapes_original(self):
        form = Q0RegistrationForm({**self.data, "question_id":"", "original_text":"<script>fake()</script>"})
        self.assertFalse(form.is_valid())
        html = render_to_string("evidence/q0_registration.html", {"form":form, "messages":Q0_MESSAGES})
        self.assertIn("Informe o identificador da questão.", html)
        self.assertIn('aria-invalid="true"', html)
        self.assertIn('id_question_id_error', html)
        self.assertNotIn("<script>fake()</script>", html)
        self.assertIn("&lt;script&gt;", html)
        self.assertIn(self.data["request_id"], html)

    def test_conflict_uncertain_and_permission_messages_do_not_expose_errors(self):
        self.assertEqual(q0_failure_message(PreparationConflict("SECRET")), Q0_MESSAGES["conflict"])
        self.assertEqual(q0_failure_message(PermissionDenied("SECRET")), Q0_MESSAGES["unauthorized"])
        for error in (PreparationHold("SECRET"), RuntimeError("SECRET")):
            self.assertEqual(q0_failure_message(error), Q0_MESSAGES["uncertain"])
            self.assertNotIn("SECRET", q0_failure_message(error))

    def test_only_explicit_no_write_observation_can_describe_this_attempt_as_not_started(self):
        error = PreparationHold("SECRET")
        error.q0_observation = {"outcome":"ABSENT", "scope":"THIS_ATTEMPT", "automatic_retry":False}
        self.assertEqual(q0_failure_message(error), Q0_MESSAGES["before_write"])
        for observation in ({"outcome":"ABSENT", "scope":"Q0_RECORDS", "automatic_retry":False},
                {"outcome":"INDETERMINATE"}, {"outcome":"PERSISTED"}):
            error.q0_observation = observation
            self.assertEqual(q0_failure_message(error), Q0_MESSAGES["uncertain"])


class Q0RegistrationInterfaceTests(SimpleTestCase):
    def setUp(self):
        self.user = Mock(pk=42, is_authenticated=True, is_active=True, is_staff=False, is_superuser=False)
        self.user.has_perm.return_value = True
        self.factory = RequestFactory()
        self.url = reverse("q0-register")

    def test_authenticated_bound_preparer_gets_accessible_source_held_form(self):
        request = self.factory.get(self.url)
        request.user = self.user
        with patch("preparer_identity.resolver.persisted_preparer_actor_id", return_value="synthetic-actor") as identity, patch(CANONICAL) as backend:
            response = q0_registration(request)
        self.assertEqual(response.status_code, 200)
        html = response.content.decode()
        for field in ("request_id", "question_id", "original_text"):
            self.assertIn(f'for="id_{field}"', html)
            self.assertIn(f'id="id_{field}"', html)
            self.assertIn(f'id_{field}_helptext', html)
        self.assertIn('type="submit" disabled', html)
        self.assertIn('role="status"', html)
        self.assertIn('aria-describedby="q0-write-hold"', html)
        self.assertIn('aria-current="page"', html)
        self.assertNotIn('name="actor_id"', html)
        self.assertNotIn('synthetic-actor', html)
        self.assertNotIn('name="expected_version"', html)
        identity.assert_called_once_with(self.user)
        backend.assert_not_called()

    def test_anonymous_and_unpermitted_get_have_no_form_or_identity_query(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 403)
        request = self.factory.get(self.url)
        self.user.has_perm.return_value = False
        request.user = self.user
        with patch("preparer_identity.resolver.persisted_preparer_actor_id") as identity:
            response = q0_registration(request)
            self.assertEqual(response.status_code, 403)
            self.assertNotIn('<form', response.content.decode())
            identity.assert_not_called()

    def test_missing_or_unavailable_binding_shows_sanitized_hold(self):
        request = self.factory.get(self.url)
        request.user = self.user
        for error in (PreparationHold("SECRET"), RuntimeError("SECRET")):
            with patch("preparer_identity.resolver.persisted_preparer_actor_id", side_effect=error):
                response = q0_registration(request)
                self.assertEqual(response.status_code, 503)
                self.assertIn("confirmar o vínculo", response.content.decode())
                self.assertNotIn('SECRET', response.content.decode())
                self.assertNotIn('<form', response.content.decode())

    def test_post_put_patch_delete_hold_before_accessing_user_body_or_backend(self):
        for method in ("post", "put", "patch", "delete"):
            request = getattr(self.factory, method)(self.url, {"actor_id":"forged", "original_text":"Synthetic"})
            # Deliberately no request.user: gate must precede even authorization.
            with patch("preparer_identity.resolver.persisted_preparer_actor_id") as identity, patch(CANONICAL) as backend, patch("evidence.forms.Q0RegistrationForm") as form:
                response = q0_registration(request)
                self.assertEqual(response.status_code, 423)
                identity.assert_not_called()
                backend.assert_not_called()
                form.assert_not_called()
        self.assertEqual(self.client.post(self.url, {"original_text":"Synthetic"}).status_code, 423)

    def test_navigation_discovers_new_flow_without_changing_synthetic_preview(self):
        response = self.client.get(reverse("home"))
        self.assertContains(response, self.url)
        preview = self.client.get(reverse("q0-synthetic-preview"))
        self.assertContains(preview, "PRÉVIA ESTÁTICA SINTÉTICA")
        self.assertNotContains(preview, '<form')
