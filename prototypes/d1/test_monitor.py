import unittest
from monitor import DomainError, SyntheticMonitorService, render_demo


class SyntheticM2Tests(unittest.TestCase):
    def setUp(self):
        self.service = SyntheticMonitorService()
        self.service.create_scenario(scenario_id='D1-M2', target_version='target-v1',
            monitor_version='monitor-v1', scientific_conclusion='Original synthetic conclusion',
            fixture_source='synthetic:f3-monitor-m2', request_id='create')

    def test_cycle_and_scientific_conclusion(self):
        s = self.service
        s.start_cycle('D1-M2', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start1')
        signal = s.register_signal('D1-M2', cycle_no=1, signal_id='hit1', kind='search_hit',
                                   source='synthetic:hit1', request_id='signal1')
        self.assertTrue(signal['synthetic'])
        s.record_assessment('D1-M2', cycle_no=1, signal_id='hit1', decision='excluded', impacts=[],
                            rationale='Out of scope', scenario_actor='synthetic-reviewer', request_id='assess1')
        s.close_cycle('D1-M2', cycle_no=1, decision='no_update_needed', rationale='No impact',
                      scenario_actor='synthetic-reviewer', request_id='close1')
        s.start_cycle('D1-M2', cycle_no=2, window_start='2026-10-04', window_end='2026-10-06', request_id='start2')
        s.register_signal('D1-M2', cycle_no=2, signal_id='hit2', kind='search_hit',
                          source='synthetic:hit2', request_id='signal2')
        s.record_assessment('D1-M2', cycle_no=2, signal_id='hit2', decision='retained_for_impact',
                            impacts=['quantitative', 'certainty'], rationale='Possible impact',
                            scenario_actor='synthetic-reviewer', request_id='assess2')
        s.close_cycle('D1-M2', cycle_no=2, decision='evaluate_update', rationale='Review needed',
                      scenario_actor='synthetic-reviewer', request_id='close2')
        snap = s.snapshot('D1-M2')
        self.assertEqual(snap['target']['currency_status'], 'under_evaluation')
        self.assertEqual(snap['target']['scientific_conclusion'], 'Original synthetic conclusion')
        self.assertEqual(len(snap['cycles']), 2)
        self.assertEqual(len(snap['cycles'][1]['assessments'][0]['impacts']), 2)
        self.assertIn('DEMONSTRAÇÃO SINTÉTICA', render_demo(snap))
        self.assertFalse(snap['execution_disclosure']['canonical_sql_view_executed'])

    def test_identity_and_sequence(self):
        with self.assertRaises(DomainError):
            self.service.start_cycle('missing', cycle_no=1, window_start='2026-10-01', window_end='2026-10-02', request_id='a')
        with self.assertRaises(DomainError):
            self.service.start_cycle('D1-M2', cycle_no=2, window_start='2026-10-01', window_end='2026-10-02', request_id='a')

    def test_negative_provenance_and_immutability(self):
        s = self.service
        s.start_cycle('D1-M2', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        with self.assertRaises(DomainError):
            s.register_signal('D1-M2', cycle_no=1, signal_id='real', kind='search_hit', source='https://pubmed.ncbi.nlm.nih.gov/', request_id='real')
        s.register_signal('D1-M2', cycle_no=1, signal_id='s1', kind='evidence_event', source='synthetic:event', request_id='sig')
        with self.assertRaises(DomainError):
            s.close_cycle('D1-M2', cycle_no=1, decision='no_update_needed', rationale='x', scenario_actor='test', request_id='early')
        with self.assertRaises(DomainError):
            s.record_assessment('D1-M2', cycle_no=1, signal_id='s1', decision='retained_for_impact', impacts=[], rationale='x', scenario_actor='test', request_id='invalid')
        s.record_assessment('D1-M2', cycle_no=1, signal_id='s1', decision='excluded', impacts=[], rationale='not relevant', scenario_actor='test', request_id='assess')
        s.close_cycle('D1-M2', cycle_no=1, decision='no_update_needed', rationale='No impact', scenario_actor='test', request_id='close')
        with self.assertRaises(DomainError):
            s.record_assessment('D1-M2', cycle_no=1, signal_id='s1', decision='excluded', impacts=[], rationale='reassessment', scenario_actor='test', request_id='late')

    def test_idempotency_and_replay(self):
        s = self.service
        kwargs = dict(cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        first = s.start_cycle('D1-M2', **kwargs)
        self.assertEqual(first, s.start_cycle('D1-M2', **kwargs))
        self.assertEqual(len(s.snapshot('D1-M2')['cycles']), 1)
        with self.assertRaises(DomainError):
            s.start_cycle('D1-M2', cycle_no=1, window_start='2026-10-02', window_end='2026-10-05', request_id='start')
        self.assertEqual(s.snapshot('D1-M2'), s.snapshot('D1-M2'))

    def test_no_hidden_approvals(self):
        snap = self.service.snapshot('D1-M2')
        self.assertFalse(snap['execution_disclosure']['scientific_review_performed'])
        self.assertFalse(snap['execution_disclosure']['publication_gate_assessed'])
        self.assertNotIn('publishable', snap)


if __name__ == '__main__':
    unittest.main()

class HardenedIntegrityTests(unittest.TestCase):
    def setUp(self):
        self.s = SyntheticMonitorService()
        self.params = dict(scenario_id='SYN-02', target_version='target-v1', monitor_version='monitor-v1',
            scientific_conclusion='Synthetic immutable', fixture_source='synthetic:fixture-m2', request_id='create')
        self.s.create_scenario(**self.params)

    def test_create_idempotency_and_conflict(self):
        self.assertEqual(self.s.create_scenario(**self.params), self.s.snapshot('SYN-02'))
        with self.assertRaises(DomainError):
            self.s.create_scenario(**{**self.params, 'scientific_conclusion': 'altered'})
        with self.assertRaises(DomainError):
            self.s.create_scenario(**{**self.params, 'request_id': 'another'})

    def test_replay_reconstructs_and_detects_drift(self):
        s = self.s
        s.start_cycle('SYN-02', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        s.register_signal('SYN-02', cycle_no=1, signal_id='r1', kind='evidence_event', source='synthetic:r1', request_id='signal')
        s.record_assessment('SYN-02', cycle_no=1, signal_id='r1', decision='retained_for_impact',
            impacts=['applicability', 'certainty'], rationale='synthetic evaluation', scenario_actor='fixture-actor', request_id='assessment')
        s.close_cycle('SYN-02', cycle_no=1, decision='evaluate_update', rationale='synthetic decision', scenario_actor='fixture-actor', request_id='close')
        self.assertEqual(s.snapshot('SYN-02'), s.replay_snapshot('SYN-02'))
        s.repo.scenarios['SYN-02']['target_currency'] = 'current'
        with self.assertRaises(DomainError):
            s.replay_snapshot('SYN-02')

    def test_invalid_date_and_overlap(self):
        with self.assertRaises(DomainError):
            self.s.start_cycle('SYN-02', cycle_no=1, window_start='2026-02-30', window_end='2026-03-01', request_id='bad')
        self.s.start_cycle('SYN-02', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        self.s.close_cycle('SYN-02', cycle_no=1, decision='no_update_needed', rationale='no signal', scenario_actor='fixture', request_id='close')
        with self.assertRaises(DomainError):
            self.s.start_cycle('SYN-02', cycle_no=2, window_start='2026-10-03', window_end='2026-10-04', request_id='overlap')

    def test_pending_cannot_close(self):
        self.s.start_cycle('SYN-02', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        self.s.register_signal('SYN-02', cycle_no=1, signal_id='r', kind='search_hit', source='synthetic:r', request_id='signal')
        self.s.record_assessment('SYN-02', cycle_no=1, signal_id='r', decision='pending', impacts=[],
            rationale='review outstanding', scenario_actor='fixture', request_id='assessment')
        with self.assertRaises(DomainError):
            self.s.close_cycle('SYN-02', cycle_no=1, decision='no_update_needed', rationale='premature', scenario_actor='fixture', request_id='close')

    def test_receipts_return_defensive_copy(self):
        row = self.s.start_cycle('SYN-02', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        row['status'] = 'tampered'
        again = self.s.start_cycle('SYN-02', cycle_no=1, window_start='2026-10-02', window_end='2026-10-03', request_id='start')
        self.assertEqual(again['status'], 'running')
