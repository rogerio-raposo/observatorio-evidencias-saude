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

    def test_signal_parity_and_receipt(self):
        self.create()
        args = dict(cycle_no=1, window_start='2026-10-02',
                    window_end='2026-10-03', request_id='cycle')
        self.bridge.start_cycle('case-synthetic', **args)
        self.legacy.start_cycle('case-synthetic', **args)
        sig = dict(cycle_no=1, signal_id='s1', kind='search_hit',
                   source='synthetic:hit', request_id='sig')
        result = self.bridge.register_signal('case-synthetic', **sig)
        self.assertEqual(result, self.legacy.register_signal('case-synthetic', **sig))
        self.assertEqual(self.bridge.snapshot('case-synthetic'), self.legacy.snapshot('case-synthetic'))
        self.assertEqual(self.bridge.register_signal('case-synthetic', **sig), result)
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')), 3)

    def test_signal_invalid_source_has_no_side_effects(self):
        self.create()
        self.bridge.start_cycle('case-synthetic', cycle_no=1,
            window_start='2026-10-02', window_end='2026-10-03', request_id='cycle')
        before = self.bridge.snapshot('case-synthetic')
        with self.assertRaises(DomainError):
            self.bridge.register_signal('case-synthetic', cycle_no=1,
                signal_id='bad', kind='search_hit', source='https://example.org', request_id='bad')
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic', 'bad'))

    def test_signal_request_conflict_and_duplicate_id(self):
        self.create()
        self.bridge.start_cycle('case-synthetic', cycle_no=1,
            window_start='2026-10-02', window_end='2026-10-03', request_id='cycle')
        self.bridge.register_signal('case-synthetic', cycle_no=1,
            signal_id='s1', kind='search_hit', source='synthetic:hit', request_id='sig')
        before = self.bridge.snapshot('case-synthetic')
        with self.assertRaises(RepositoryConflict):
            self.bridge.register_signal('case-synthetic', cycle_no=1,
                signal_id='s2', kind='search_hit', source='synthetic:hit', request_id='sig')
        with self.assertRaises(DomainError):
            self.bridge.register_signal('case-synthetic', cycle_no=1,
                signal_id='s1', kind='search_hit', source='synthetic:hit', request_id='new')
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic', 'new'))

    def assessment_setup(self):
        self.create()
        start = dict(cycle_no=1, window_start='2026-10-02',
                     window_end='2026-10-03', request_id='cycle')
        signal = dict(cycle_no=1, signal_id='s1', kind='search_hit',
                      source='synthetic:hit', request_id='sig')
        for service in (self.bridge, self.legacy):
            service.start_cycle('case-synthetic', **start)
            service.register_signal('case-synthetic', **signal)

    def test_assessment_multivalued_impacts_parity_and_receipt(self):
        self.assessment_setup()
        params = dict(cycle_no=1, signal_id='s1', decision='retained_for_impact',
                      impacts=['certainty', 'scope'], rationale='synthetic-only',
                      scenario_actor='fictional-actor', request_id='assess')
        result = self.bridge.record_assessment('case-synthetic', **params)
        self.assertEqual(result, self.legacy.record_assessment('case-synthetic', **params))
        self.assertEqual(self.bridge.snapshot('case-synthetic'), self.legacy.snapshot('case-synthetic'))
        self.assertEqual(self.bridge.record_assessment('case-synthetic', **params), result)
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')), 4)

    def test_assessment_invalid_impact_is_atomic(self):
        self.assessment_setup()
        before = self.bridge.snapshot('case-synthetic')
        with self.assertRaises(DomainError):
            self.bridge.record_assessment('case-synthetic', cycle_no=1,
                signal_id='s1', decision='retained_for_impact',
                impacts=['certainty', 'certainty'], rationale='synthetic',
                scenario_actor='fictional-actor', request_id='invalid-impact')
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic', 'invalid-impact'))

    def test_assessment_pending_preserves_t1_no_reassessment_semantics(self):
        self.assessment_setup()
        pending = dict(cycle_no=1, signal_id='s1', decision='pending', impacts=[],
                       rationale='synthetic pending', scenario_actor='fictional-actor',
                       request_id='pending')
        self.assertEqual(self.bridge.record_assessment('case-synthetic', **pending),
                         self.legacy.record_assessment('case-synthetic', **pending))
        before = self.bridge.snapshot('case-synthetic')
        amended = dict(pending, decision='excluded', request_id='second')
        with self.assertRaises(DomainError):
            self.bridge.record_assessment('case-synthetic', **amended)
        with self.assertRaises(DomainError):
            self.legacy.record_assessment('case-synthetic', **amended)
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)
        self.assertEqual(self.bridge.snapshot('case-synthetic'), self.legacy.snapshot('case-synthetic'))
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic', 'second'))

    def test_assessment_request_conflict_and_missing_signal(self):
        self.assessment_setup()
        params = dict(cycle_no=1, signal_id='s1', decision='excluded', impacts=[],
                      rationale='fictional', scenario_actor='fictional-actor',
                      request_id='assess')
        self.bridge.record_assessment('case-synthetic', **params)
        before = self.bridge.snapshot('case-synthetic')
        with self.assertRaises(RepositoryConflict):
            self.bridge.record_assessment('case-synthetic', **dict(params, rationale='changed'))
        with self.assertRaises(DomainError):
            self.bridge.record_assessment('case-synthetic', **dict(params, signal_id='missing', request_id='missing'))
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic', 'missing'))

    def test_full_flow_close_parity_and_conclusion_immutable(self):
        self.assessment_setup()
        assessment = dict(cycle_no=1, signal_id='s1', decision='retained_for_impact',
                          impacts=['certainty', 'scope'], rationale='fictional',
                          scenario_actor='fictional-actor', request_id='assess')
        for service in (self.bridge, self.legacy):
            service.record_assessment('case-synthetic', **assessment)
        close = dict(cycle_no=1, decision='evaluate_update', rationale='fictional',
                     scenario_actor='fictional-actor', request_id='close')
        result = self.bridge.close_cycle('case-synthetic', **close)
        self.assertEqual(result, self.legacy.close_cycle('case-synthetic', **close))
        snap = self.bridge.snapshot('case-synthetic')
        self.assertEqual(snap, self.legacy.snapshot('case-synthetic'))
        self.assertEqual(snap['target']['scientific_conclusion'], 'Fictional')
        self.assertEqual(snap['target']['currency_status'], 'under_evaluation')
        self.assertEqual(len(self.bridge.repo.list_events('case-synthetic')), 5)
        self.assertEqual(self.bridge.close_cycle('case-synthetic', **close), result)

    def test_close_rejects_unassessed_signal_atomically(self):
        self.assessment_setup()
        before = self.bridge.snapshot('case-synthetic')
        with self.assertRaises(DomainError):
            self.bridge.close_cycle('case-synthetic', cycle_no=1, decision='no_update_needed',
                rationale='fictional', scenario_actor='fictional-actor', request_id='bad-close')
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)
        self.assertIsNone(self.bridge.repo.read_receipt('case-synthetic', 'bad-close'))

    def test_close_rejects_pending_and_retained_no_update(self):
        for decision, impacts, close_decision in [
            ('pending', [], 'evaluate_update'),
            ('retained_for_impact', ['validity'], 'no_update_needed')]:
            with self.subTest(decision=decision):
                bridge = SyntheticCommandBridge()
                bridge.create_scenario(**self.args)
                bridge.start_cycle('case-synthetic', cycle_no=1, window_start='2026-10-02',
                                   window_end='2026-10-03', request_id='cycle')
                bridge.register_signal('case-synthetic', cycle_no=1, signal_id='s1',
                                       kind='search_hit', source='synthetic:hit', request_id='sig')
                bridge.record_assessment('case-synthetic', cycle_no=1, signal_id='s1',
                    decision=decision, impacts=impacts, rationale='fictional',
                    scenario_actor='fictional-actor', request_id='assess')
                before = bridge.snapshot('case-synthetic')
                with self.assertRaises(DomainError):
                    bridge.close_cycle('case-synthetic', cycle_no=1, decision=close_decision,
                        rationale='fictional', scenario_actor='fictional-actor', request_id='close')
                self.assertEqual(bridge.snapshot('case-synthetic'), before)
                self.assertIsNone(bridge.repo.read_receipt('case-synthetic', 'close'))

    def test_close_rejects_request_conflict_without_new_event(self):
        self.assessment_setup()
        self.bridge.record_assessment('case-synthetic', cycle_no=1, signal_id='s1',
            decision='excluded', impacts=[], rationale='fictional',
            scenario_actor='fictional-actor', request_id='assess')
        close = dict(cycle_no=1, decision='no_update_needed', rationale='fictional',
                     scenario_actor='fictional-actor', request_id='close')
        self.bridge.close_cycle('case-synthetic', **close)
        before = self.bridge.snapshot('case-synthetic')
        with self.assertRaises(RepositoryConflict):
            self.bridge.close_cycle('case-synthetic', **dict(close, decision='outdated'))
        self.assertEqual(self.bridge.snapshot('case-synthetic'), before)

if __name__ == '__main__':
    unittest.main()
