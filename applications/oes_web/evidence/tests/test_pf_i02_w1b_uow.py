"""W1B: transactional fake validates adapter protocol without SQL or Neon."""
from copy import deepcopy
from unittest.mock import Mock
from django.test import SimpleTestCase
from evidence.question_preparation import QuestionCommand, PreparationConflict, PreparationHold, submit_question_command
from evidence.question_uow_offline import OfflineQuestionUnitOfWork

class FakePort:
    def __init__(self):
        self.questions={}; self.receipts={}; self.fail_commit=False
    def begin(self):
        return FakeTransaction(self)
class FakeTransaction:
    def __init__(self,port): self.port=port
    def __enter__(self):
        self.questions=deepcopy(self.port.questions)
        self.receipts=deepcopy(self.port.receipts)
        return self
    def __exit__(self,t,v,tb):
        if t is None:
            if self.port.fail_commit:
                raise TimeoutError("simulated uncertain commit")
            self.port.questions=self.questions
            self.port.receipts=self.receipts
        return False
    def lock_request(self,actor,req): pass
    def find_receipt(self,actor,req): return self.receipts.get((actor,req))
    def current_question(self,qid,actor,lock):
        state=self.questions.get(qid)
        return deepcopy(state) if state and state["actor"]==actor else None
    def can_access_question(self,qid,actor):
        state=self.questions.get(qid)
        return bool(state and state["actor"]==actor)
    def register_q0(self,c,actor):
        self.questions[c.question_id]={"actor":actor,"version":1,"original_text":c.original_text,"normalized_text":None}
    def propose_q1(self,c,actor):
        self.questions[c.question_id].update(version=c.expected_version+1,normalized_text=c.normalized_text)
    def save_receipt(self,r): self.receipts[(r.actor_id,r.request_id)]=r

class OfflineUnitOfWorkTests(SimpleTestCase):
    def setUp(self):
        self.port=FakePort()
        self.backend=OfflineQuestionUnitOfWork(self.port)
        self.user=Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=5)
        self.user.has_perm.return_value=True
        self.q0=QuestionCommand("request-a","OES-Q-SYN",0,"Pergunta sintética?")
    def send(self,c,who=None):
        return submit_question_command(user=who or self.user,command=c,unit_of_work=self.backend)
    def test_q0_q1_and_original_preserved(self):
        self.assertEqual(self.send(self.q0)["version"],1)
        q1=QuestionCommand("request-b","OES-Q-SYN",1,"Pergunta sintética?","Pergunta sintética normalizada","justificativa")
        self.assertEqual(self.send(q1)["version"],2)
        self.assertEqual(self.port.questions["OES-Q-SYN"]["original_text"],self.q0.original_text)
        self.assertEqual(len(self.port.receipts),2)
        receipt=self.port.receipts[("5","request-b")]
        self.assertEqual(receipt.command_kind,"PROPOSE_Q1")
        self.assertEqual(receipt.justification,"justificativa")
    def test_replay_returns_same_receipt(self):
        first=self.send(self.q0)
        self.assertEqual(self.send(self.q0),first)
        self.assertEqual(len(self.port.receipts),1)
    def test_request_key_reuse_with_different_payload_denied(self):
        self.send(self.q0)
        altered=QuestionCommand("request-a","OES-Q-SYN",0,"Texto diferente")
        with self.assertRaises(PreparationConflict):self.send(altered)
        self.assertEqual(len(self.port.receipts),1)
    def test_stale_version_rejected(self):
        self.send(self.q0)
        stale=QuestionCommand("request-b","OES-Q-SYN",3,"Pergunta sintética?","Q1","motivo")
        with self.assertRaises(PreparationConflict):self.send(stale)
        self.assertEqual(self.port.questions["OES-Q-SYN"]["version"],1)
    def test_cross_actor_denied(self):
        self.send(self.q0)
        stranger=Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=6)
        stranger.has_perm.return_value=True
        q1=QuestionCommand("request-c","OES-Q-SYN",1,"Pergunta sintética?","Q1","motivo")
        with self.assertRaises(PreparationConflict): self.send(q1,who=stranger)
    def test_atomic_rollback_on_commit_failure(self):
        self.port.fail_commit=True
        with self.assertRaisesRegex(PreparationHold,"outcome uncertain"): self.send(self.q0)
        self.assertEqual(self.port.questions,{})
        self.assertEqual(self.port.receipts,{})
    def test_q0_rejects_nonzero_revision(self):
        c=QuestionCommand("request-x","OES-Q-SYN",1,"Pergunta sintética?")
        with self.assertRaises(PreparationHold):self.send(c)
    def test_anonymous_denied_before_transaction(self):
        anonymous=Mock(is_authenticated=False,pk=None)
        from django.core.exceptions import PermissionDenied
        with self.assertRaises(PermissionDenied):self.send(self.q0,who=anonymous)
        self.assertEqual(self.port.questions,{})

    def test_replay_denied_after_scope_revoked(self):
        self.send(self.q0)
        self.port.questions["OES-Q-SYN"]["actor"]="different"
        with self.assertRaises(PreparationConflict): self.send(self.q0)

    def test_replay_old_request_after_q1(self):
        self.send(self.q0)
        self.send(QuestionCommand("request-b","OES-Q-SYN",1,"Pergunta sintética?","Q1","motivo"))
        self.assertEqual(self.send(self.q0)["version"],1)

    def test_question_request_id_length_rejected(self):
        with self.assertRaises(PreparationHold):
            self.send(QuestionCommand("x"*129,"OES-Q-SYN",0,"Pergunta sintética?"))
