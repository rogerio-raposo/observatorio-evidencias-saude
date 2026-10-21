"""T2-A1 read-only replay and injected UoW failure tests, memory only."""
import unittest
from unittest.mock import patch
from copy import deepcopy
from bridge import SyntheticCommandBridge
from repository import InMemoryScenarioRepository, MemoryUnitOfWork
from t1_monitor_reference import DomainError

class ReplayAndFailureTests(unittest.TestCase):
    def setUp(self):
        self.bridge = SyntheticCommandBridge()
        self.sid = 'synthetic-case'
        self.create = dict(scenario_id=self.sid, target_version='target-fixture',
            monitor_version='monitor-fixture', scientific_conclusion='Synthetic conclusion',
            fixture_source='synthetic:fixture', baseline_evidence_cutoff_date='2026-10-01',
            request_id='create')
        self.bridge.create_scenario(**self.create)

    def cycle(self):
        self.bridge.start_cycle(self.sid,cycle_no=1,window_start='2026-10-02',
            window_end='2026-10-03',request_id='cycle')

    def test_replay_creation_is_read_only_and_equivalent(self):
        before = self.bridge.snapshot(self.sid)
        receipt = self.bridge.repo.read_receipt(self.sid,'create')
        self.assertEqual(self.bridge.replay_snapshot(self.sid), before)
        self.assertEqual(self.bridge.repo.read_receipt(self.sid,'create'), receipt)
        self.assertEqual(self.bridge.snapshot(self.sid), before)

    def test_replay_full_cycle_equivalent(self):
        self.cycle()
        self.bridge.register_signal(self.sid,cycle_no=1,signal_id='s1',
            kind='search_hit',source='synthetic:hit',request_id='signal')
        self.bridge.record_assessment(self.sid,cycle_no=1,signal_id='s1',
            decision='retained_for_impact',impacts=['scope','certainty'],
            rationale='synthetic',scenario_actor='fictional',request_id='assessment')
        self.bridge.close_cycle(self.sid,cycle_no=1,decision='evaluate_update',
            rationale='synthetic',scenario_actor='fictional',request_id='close')
        before = self.bridge.snapshot(self.sid)
        self.assertEqual(self.bridge.replay_snapshot(self.sid), before)
        self.assertEqual(self.bridge.snapshot(self.sid), before)

    def test_replay_detects_divergent_event_storage(self):
        self.cycle()
        prior = self.bridge.snapshot(self.sid)
        self.bridge.repo._records[self.sid]['events'][-1]['kind'] = 'tampered'
        with self.assertRaisesRegex(DomainError, 'stored events disagree'):
            self.bridge.replay_snapshot(self.sid)
        self.assertEqual(self.bridge.snapshot(self.sid), prior)

    def test_injected_commit_failure_leaves_no_partial_effects(self):
        before = self.bridge.snapshot(self.sid)
        receipts = deepcopy(self.bridge.repo._records[self.sid]['receipts'])
        events = self.bridge.repo.list_events(self.sid)
        with patch.object(MemoryUnitOfWork, 'commit', side_effect=RuntimeError('synthetic failure')):
            with self.assertRaisesRegex(RuntimeError, 'synthetic failure'):
                self.cycle()
        self.assertEqual(self.bridge.snapshot(self.sid), before)
        self.assertEqual(self.bridge.repo.list_events(self.sid), events)
        self.assertEqual(self.bridge.repo._records[self.sid]['receipts'], receipts)

if __name__ == '__main__':
    unittest.main()
