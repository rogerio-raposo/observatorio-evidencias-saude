"""OES D1-T1: bounded, synthetic-only negative tests for S1-S5."""
import unittest
from copy import deepcopy
from monitor import DomainError, SyntheticMonitorService, render_demo


class S1S5AdversarialTests(unittest.TestCase):
    def setUp(self):
        self.s = SyntheticMonitorService()
        self.s.create_scenario(scenario_id='S1-S5', target_version='target-v1',
            monitor_version='monitor-v1', scientific_conclusion='Immutable synthetic conclusion',
            fixture_source='synthetic:adversarial-fixture', request_id='create')

    def start(self):
        return self.s.start_cycle('S1-S5', cycle_no=1, window_start='2026-10-02',
            window_end='2026-10-03', request_id='start')

    def signal(self):
        return self.s.register_signal('S1-S5', cycle_no=1, signal_id='signal-1',
            kind='evidence_event', source='synthetic:event-1', request_id='signal')

    def test_s1_rejects_duplicate_cycle_identity_without_side_effects(self):
        self.start()
        before = self.s.snapshot('S1-S5')
        with self.assertRaises(DomainError):
            self.s.start_cycle('S1-S5', cycle_no=1, window_start='2026-10-04',
                window_end='2026-10-05', request_id='other-start')
        self.assertEqual(self.s.snapshot('S1-S5'), before)
        self.assertNotIn(('S1-S5', 'other-start'), self.s.repo.receipts)

    def test_s2_rejects_external_signal_provenance_without_side_effects(self):
        self.start()
        before = self.s.snapshot('S1-S5')
        with self.assertRaises(DomainError):
            self.s.register_signal('S1-S5', cycle_no=1, signal_id='external',
                kind='search_hit', source='https://example.org/article', request_id='external')
        self.assertEqual(self.s.snapshot('S1-S5'), before)
        self.assertNotIn(('S1-S5', 'external'), self.s.repo.receipts)

    def test_s3_rejects_duplicate_signal_and_conflicting_idempotency(self):
        self.start()
        self.signal()
        before = self.s.snapshot('S1-S5')
        with self.assertRaises(DomainError):
            self.s.register_signal('S1-S5', cycle_no=1, signal_id='signal-1',
                kind='search_hit', source='synthetic:another', request_id='other-signal')
        with self.assertRaises(DomainError):
            self.s.register_signal('S1-S5', cycle_no=1, signal_id='signal-2',
                kind='evidence_event', source='synthetic:other', request_id='signal')
        self.assertEqual(self.s.snapshot('S1-S5'), before)

    def test_s4_rejects_unknown_and_duplicated_impacts_without_side_effects(self):
        self.start()
        self.signal()
        before = self.s.snapshot('S1-S5')
        for impacts, req in [(['certainty', 'certainty'], 'dup-impact'),
                             (['unsupported'], 'bad-impact')]:
            with self.subTest(impacts=impacts):
                with self.assertRaises(DomainError):
                    self.s.record_assessment('S1-S5', cycle_no=1, signal_id='signal-1',
                        decision='retained_for_impact', impacts=impacts,
                        rationale='fictional', scenario_actor='fictional-actor', request_id=req)
                self.assertEqual(self.s.snapshot('S1-S5'), before)
                self.assertNotIn(('S1-S5', req), self.s.repo.receipts)

    def test_s4_rejects_trivial_close_when_impact_retained(self):
        self.start()
        self.signal()
        self.s.record_assessment('S1-S5', cycle_no=1, signal_id='signal-1',
            decision='retained_for_impact', impacts=['validity', 'scope'],
            rationale='fictional', scenario_actor='fictional-actor', request_id='assess')
        before = self.s.snapshot('S1-S5')
        with self.assertRaises(DomainError):
            self.s.close_cycle('S1-S5', cycle_no=1, decision='no_update_needed',
                rationale='inconsistent', scenario_actor='fictional-actor', request_id='close')
        self.assertEqual(self.s.snapshot('S1-S5'), before)
        self.assertEqual(self.s.replay_snapshot('S1-S5'), before)

    def test_s5_snapshot_and_render_remain_explicitly_noncanonical(self):
        self.start()
        self.signal()
        self.s.record_assessment('S1-S5', cycle_no=1, signal_id='signal-1',
            decision='retained_for_impact', impacts=['validity', 'scope'],
            rationale='fictional', scenario_actor='fictional-actor', request_id='assess')
        self.s.close_cycle('S1-S5', cycle_no=1, decision='evaluate_update',
            rationale='evaluate only', scenario_actor='fictional-actor', request_id='close')
        snap = self.s.snapshot('S1-S5')
        self.assertEqual(snap['schema_version'], 'oes.d1.monitor_snapshot/0.1')
        self.assertTrue(snap['synthetic'])
        self.assertEqual(snap['target']['currency_status'], 'under_evaluation')
        self.assertEqual(snap['target']['scientific_conclusion'], 'Immutable synthetic conclusion')
        self.assertFalse(snap['execution_disclosure']['canonical_sql_view_executed'])
        output = render_demo(snap)
        for expected in ('validity, scope', 'fictional-actor',
                         'Baseline de evidência do Monitor: não registrado',
                         'Sem buscas factuais'):
            self.assertIn(expected, output)
        counterfeit = deepcopy(snap)
        counterfeit['schema_version'] = 'oes.evidence_monitor_view/0.1'
        with self.assertRaises(DomainError):
            render_demo(counterfeit)


if __name__ == '__main__':
    unittest.main()
