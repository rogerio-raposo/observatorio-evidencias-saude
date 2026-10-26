"""PF-I02 W1: offline command tests; no DB/network/user creation."""
from dataclasses import dataclass
from unittest.mock import Mock
from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from evidence.question_preparation import (QuestionCommand,PreparationHold,
    submit_question_command,command_fingerprint)


class QuestionPreparationOfflineTests(SimpleTestCase):
    def setUp(self):
        self.actor=Mock(is_authenticated=True,pk=7)
        self.actor.has_perm.return_value=True
        self.q0=QuestionCommand("req-1","OES-Q-TEST",0,"Pergunta sintética?")
    def test_fail_closed_without_backend(self):
        with self.assertRaisesRegex(PreparationHold,"persistence unavailable"):
            submit_question_command(user=self.actor,command=self.q0)
    def test_anonymous_denied(self):
        self.actor.is_authenticated=False
        with self.assertRaises(PermissionDenied):
            submit_question_command(user=self.actor,command=self.q0)
    def test_unprivileged_denied(self):
        self.actor.has_perm.return_value=False
        with self.assertRaises(PermissionDenied):
            submit_question_command(user=self.actor,command=self.q0)
    def test_injected_mock_receipt(self):
        uow=Mock()
        uow.execute.return_value={"status":"PREPARATORY_ONLY","question_id":"OES-Q-TEST","version":1}
        result=submit_question_command(user=self.actor,command=self.q0,unit_of_work=uow)
        self.assertEqual(result["version"],1)
        self.assertEqual(uow.execute.call_args.kwargs["actor_id"],"7")
    def test_fingerprint_deterministic(self):
        self.assertEqual(command_fingerprint(self.q0),command_fingerprint(self.q0))
        self.assertNotEqual(command_fingerprint(self.q0),command_fingerprint(
            QuestionCommand("req-1","OES-Q-TEST",0,"Outra pergunta?")))
    def test_invalid_revision_and_q1(self):
        for cmd in [QuestionCommand("a","Q",-1,"Q0"),
                    QuestionCommand("a","Q",0,"Q0","Q1","")]:
            with self.subTest(cmd=cmd),self.assertRaises(PreparationHold):
                submit_question_command(user=self.actor,command=cmd,unit_of_work=Mock())
    def test_uncertain_backend_failure_holds(self):
        uow=Mock()
        uow.execute.side_effect=TimeoutError()
        with self.assertRaisesRegex(PreparationHold,"outcome uncertain"):
            submit_question_command(user=self.actor,command=self.q0,unit_of_work=uow)
    def test_invalid_receipt_holds(self):
        uow=Mock()
        uow.execute.return_value={"status":"OPENED_E9","question_id":"OES-Q-TEST","version":1}
        with self.assertRaises(PreparationHold):
            submit_question_command(user=self.actor,command=self.q0,unit_of_work=uow)
    def test_no_http_write_routes(self):
        for path in ("/questions/","/questions/new/","/questions/OES-Q-TEST/"):
            self.assertEqual(self.client.post(path).status_code,404)
