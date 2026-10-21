"""T2-A1 synthetic multi-cycle, event integrity and receipt isolation checks."""
import unittest
from copy import deepcopy
from bridge import SyntheticCommandBridge
from repository import InMemoryScenarioRepository, RepositoryConflict
from t1_monitor_reference import SyntheticMonitorService, DomainError


class AdversarialCycleTests(unittest.TestCase):
    def setUp(self):
        self.repo = InMemoryScenarioRepository()
        self.bridge = SyntheticCommandBridge(self.repo)
        self.t1 = SyntheticMonitorService()
        self.sid = 'synthetic-A'
        self.args = dict(scenario_id=self.sid, target_version='target', monitor_version='monitor',
                         scientific_conclusion='Fictional conclusion', fixture_source='synthetic:fixture',
                         baseline_evidence_cutoff_date='2026-09-30', request_id='create')
        for service in (self.bridge, self.t1):
            service.create_scenario(**self.args)

    def both(self, name, *args, **kwargs):
        actual = getattr(self.bridge, name)(*args, **kwargs)
        expected = getattr(self.t1, name)(*args, **kwargs)
        self.assertEqual(actual, expected)
        self.assertEqual(self.bridge.snapshot(self.sid), self.t1.snapshot(self.sid))
        return actual

    def start(self, n, first, last):
        self.both('start_cycle', self.sid, cycle_no=n, window_start=first,
                  window_end=last, request_id=f'cycle-{n}')

    def complete(self, n):
        self.both('register_signal', self.sid, cycle_no=n, signal_id=f's{n}',
                  kind='evidence_event', source='synthetic:event', request_id=f'sig-{n}')
        self.both('record_assessment', self.sid, cycle_no=n, signal_id=f's{n}',
                  decision='excluded', impacts=[], rationale='fictional',
                  scenario_actor='fictional-actor', request_id=f'assess-{n}')
        self.both('close_cycle', self.sid, cycle_no=n, decision='no_update_needed',
                  rationale='fictional', scenario_actor='fictional-actor', request_id=f'close-{n}')

    def test_two_complete_cycles_parity_and_replay(self):
        self.start(1, '2026-10-01', '2026-10-02')
        self.complete(1)
        self.start(2, '2026-10-03', '2026-10-04')
        self.complete(2)
        self.assertEqual(self.bridge.replay_snapshot(self.sid), self.bridge.snapshot(self.sid))
        self.assertEqual(len(self.repo.list_events(self.sid)), 9)
        self.assertEqual(self.repo.read_snapshot(self.sid).revision, 9)

    def test_overlapping_or_unfinished_second_cycle_is_atomic(self):
        self.start(1, '2026-10-01', '2026-10-02')
        baseline = self.bridge.snapshot(self.sid)
        for request, first in [('incomplete', '2026-10-03'), ('overlap', '2026-10-02')]:
            with self.subTest(request=request):
                with self.assertRaises(DomainError):
                    self.bridge.start_cycle(self.sid, cycle_no=2, window_start=first,
                                            window_end='2026-10-04', request_id=request)
                self.assertEqual(self.bridge.snapshot(self.sid), baseline)
                self.assertIsNone(self.repo.read_receipt(self.sid, request))
        self.complete(1)
        after = self.bridge.snapshot(self.sid)
        with self.assertRaises(DomainError):
            self.bridge.start_cycle(self.sid, cycle_no=2, window_start='2026-10-02',
                                    window_end='2026-10-04', request_id='overlap-after-close')
        self.assertEqual(self.bridge.snapshot(self.sid), after)

    def test_mutated_event_detected_without_mutating_snapshot(self):
        self.start(1, '2026-10-01', '2026-10-02')
        pristine = self.bridge.snapshot(self.sid)
        self.repo._records[self.sid]['events'][1]['data']['window_end'] = '2026-10-10'
        with self.assertRaises(DomainError):
            self.bridge.replay_snapshot(self.sid)
        self.assertEqual(self.bridge.snapshot(self.sid), pristine)

    def test_receipt_isolation_across_scenarios_and_conflict(self):
        sid2 = 'synthetic-B'
        args2 = dict(self.args, scenario_id=sid2)
        self.bridge.create_scenario(**args2)
        self.start(1, '2026-10-01', '2026-10-02')
        old_b_receipt = self.repo.read_receipt(sid2, 'create')
        original_a = self.repo.read_receipt(self.sid, 'cycle-1')
        original_a.response['status'] = 'mutated'
        self.assertEqual(self.repo.read_receipt(self.sid, 'cycle-1').response['status'], 'running')
        self.assertEqual(self.repo.read_receipt(sid2, 'create'), old_b_receipt)
        with self.assertRaises(RepositoryConflict):
            self.bridge.start_cycle(self.sid, cycle_no=1, window_start='2026-10-01',
                                    window_end='2026-10-10', request_id='cycle-1')
        self.assertEqual(len(self.repo.list_events(self.sid)), 2)
        self.assertEqual(len(self.repo.list_events(sid2)), 1)


if __name__ == '__main__':
    unittest.main()
