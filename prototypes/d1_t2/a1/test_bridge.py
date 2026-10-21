"""Tests of first two T1 commands staged by T2-A1 Unit of Work."""
import unittest
from copy import deepcopy
from bridge import SyntheticCommandBridge
from repository import InMemoryScenarioRepository, RepositoryConflict
from t1_monitor_reference import SyntheticMonitorService, DomainError


class BridgeTests(unittest.TestCase):
    def setUp(self):
        self.bridge = SyntheticCommandBridge()
        self.legacy = SyntheticMonitorService()
        self.args = dict(scenario_id='case-synthetic', target_version='t1',
            monitor_version='m1', scientific_conclusion='Fictional',
            fixture_source='synthetic:only', baseline_evidence_cutoff_date='2026-10-01',
            request_id='create')

    def create(self):
        expected = self.legacy.create_scenario(**self.args)
        actual = self.bridge.create_scenario(**self.args)
        self.assertEqual(actual, expected)

    def test_creation_snapshot_parity(self):
        self.create()
        self.assertEqual(self.bridge.snapshot('case-synthetic'), self.legacy.snapshot('case-synthetic'))
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')), 1)

    def test_start_cycle_snapshot_parity(self):
        self.create()
        kwargs=dict(cycle_no=1, window_start='2026-10-02', window_end='2026-10-03',request_id='cycle')
        self.assertEqual(self.bridge.start_cycle('case-synthetic',**kwargs),
                         self.legacy.start_cycle('case-synthetic',**kwargs))
        self.assertEqual(self.bridge.snapshot('case-synthetic'), self.legacy.snapshot('case-synthetic'))
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')), 2)

    def test_repeat_create_maintains_t1_current_snapshot_semantics(self):
        self.create()
        self.bridge.start_cycle('case-synthetic',cycle_no=1,window_start='2026-10-02',window_end='2026-10-03',request_id='cycle')
        self.legacy.start_cycle('case-synthetic',cycle_no=1,window_start='2026-10-02',window_end='2026-10-03',request_id='cycle')
        self.assertEqual(self.bridge.create_scenario(**self.args), self.legacy.create_scenario(**self.args))
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')),2)

    def test_idempotent_start_returns_original_response(self):
        self.create()
        kwargs=dict(cycle_no=1,window_start='2026-10-02',window_end='2026-10-03',request_id='cycle')
        first=self.bridge.start_cycle('case-synthetic',**kwargs)
        self.assertEqual(first,self.bridge.start_cycle('case-synthetic',**kwargs))
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')),2)

    def test_invalid_window_does_not_commit_any_stage(self):
        self.create()
        before=self.bridge.snapshot('case-synthetic')
        with self.assertRaises(DomainError):
            self.bridge.start_cycle('case-synthetic',cycle_no=1,window_start='2026-09-30',window_end='2026-10-03',request_id='bad')
        self.assertEqual(before,self.bridge.snapshot('case-synthetic'))
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic','bad'))

    def test_conflicting_reuse_rejected(self):
        self.create()
        args=deepcopy(self.args); args['fixture_source']='synthetic:different'
        with self.assertRaises(RepositoryConflict):
            self.bridge.create_scenario(**args)
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')),1)

    def test_unknown_scenario(self):
        with self.assertRaises(DomainError):
            self.bridge.start_cycle('missing',cycle_no=1,window_start='2026-10-02',window_end='2026-10-03',request_id='x')

    def test_two_scenarios_independent(self):
        self.create()
        args=deepcopy(self.args); args['scenario_id']='other'
        self.bridge.create_scenario(**args)
        self.assertEqual(self.bridge.repo.read_snapshot('other').revision,1)
        self.assertEqual(self.bridge.repo.read_snapshot('case-synthetic').revision,1)

if __name__ == '__main__':
    unittest.main()
