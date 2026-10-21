"""Initial tests of the separate T2-A1 Python/memory boundary."""
import unittest
from repository import InMemoryScenarioRepository, RepositoryConflict


class RepositoryBoundaryTests(unittest.TestCase):
    def setUp(self):
        self.repo = InMemoryScenarioRepository()

    def command(self, scenario="synthetic-A", request="r1", fingerprint="f1"):
        return self.repo.begin_command(scenario, request, fingerprint)

    def create(self, scenario="synthetic-A"):
        with self.command(scenario) as u:
            self.assertIsNone(u.read_scenario())
            u.stage_scenario({"synthetic": True, "value": 1}, expected_revision=0)
            u.append_event("scenario_created", {"synthetic": True}, sequence=1)
            u.stage_receipt({"status": "created"})
            self.assertEqual(u.commit(), 1)

    def test_commit_is_atomic_logical_record(self):
        self.create()
        self.assertEqual(self.repo.read_snapshot("synthetic-A").revision, 1)
        self.assertEqual(len(self.repo.list_events("synthetic-A")), 1)
        self.assertEqual(self.repo.read_receipt("synthetic-A", "r1").response, {"status": "created"})

    def test_context_without_commit_rolls_back(self):
        with self.command() as u:
            u.stage_scenario({"synthetic": True}, 0)
            u.append_event("scenario_created", {}, 1)
            u.stage_receipt("created")
        self.assertIsNone(self.repo.read_snapshot("synthetic-A"))
        self.assertEqual(self.repo.list_events("synthetic-A"), [])
        self.assertIsNone(self.repo.read_receipt("synthetic-A", "r1"))

    def test_injected_failure_discards_all_stages(self):
        with self.assertRaisesRegex(RuntimeError, "injected"):
            with self.command() as u:
                u.stage_scenario({"synthetic": True}, 0)
                u.append_event("created", {}, 1)
                raise RuntimeError("injected")
        self.assertIsNone(self.repo.read_snapshot("synthetic-A"))
        self.assertEqual(self.repo.list_events("synthetic-A"), [])

    def test_partial_commit_is_rejected(self):
        with self.command() as u:
            u.stage_scenario({"synthetic": True}, 0)
            with self.assertRaises(RepositoryConflict):
                u.commit()
        self.assertIsNone(self.repo.read_snapshot("synthetic-A"))

    def test_idempotency_receipt_read_and_payload_conflict(self):
        self.create()
        with self.command() as u:
            self.assertEqual(u.find_receipt().response, {"status": "created"})
        with self.assertRaises(RepositoryConflict):
            with self.command(fingerprint="other") as u:
                u.find_receipt()
        self.assertEqual(len(self.repo.list_events("synthetic-A")), 1)

    def test_defensive_copies_isolate_callers(self):
        self.create()
        state = self.repo.read_snapshot("synthetic-A")
        state.data["value"] = 99
        event = self.repo.list_events("synthetic-A")
        event[0]["kind"] = "tampered"
        receipt = self.repo.read_receipt("synthetic-A", "r1")
        receipt.response["status"] = "tampered"
        self.assertEqual(self.repo.read_snapshot("synthetic-A").data["value"], 1)
        self.assertEqual(self.repo.list_events("synthetic-A")[0]["kind"], "scenario_created")
        self.assertEqual(self.repo.read_receipt("synthetic-A", "r1").response["status"], "created")

    def test_scenario_isolation_and_revisions(self):
        self.create("synthetic-A")
        self.create("synthetic-B")
        with self.command(request="r2", fingerprint="f2") as u:
            state = u.read_scenario()
            state.data["value"] = 2
            u.stage_scenario(state.data, state.revision)
            u.append_event("updated", {"value": 2}, 2)
            u.stage_receipt("ok")
            self.assertEqual(u.commit(), 2)
        self.assertEqual(self.repo.read_snapshot("synthetic-B").revision, 1)
        self.assertEqual(self.repo.read_snapshot("synthetic-A").data["value"], 2)
        self.assertEqual(len(self.repo.list_events("synthetic-B")), 1)

    def test_duplicate_stage_and_wrong_sequence_rejected(self):
        with self.command() as u:
            with self.assertRaises(RepositoryConflict):
                u.stage_scenario({"synthetic": True}, 1)
            u.stage_scenario({"synthetic": True}, 0)
            with self.assertRaises(RepositoryConflict):
                u.stage_scenario({"synthetic": True}, 0)
            with self.assertRaises(RepositoryConflict):
                u.append_event("created", {}, 2)
        self.assertIsNone(self.repo.read_snapshot("synthetic-A"))


if __name__ == "__main__":
    unittest.main()
