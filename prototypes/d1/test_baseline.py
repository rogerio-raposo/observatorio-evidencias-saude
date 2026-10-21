"""Synthetic baseline: explicit provenance, temporal guard and deterministic replay."""
import unittest
from monitor import DomainError, SyntheticMonitorService, render_demo


class BaselineTests(unittest.TestCase):
    def create(self, baseline='2026-10-01'):
        s = SyntheticMonitorService()
        s.create_scenario(scenario_id='BASE', target_version='target-1',
                          monitor_version='monitor-1', scientific_conclusion='Synthetic original',
                          fixture_source='synthetic:baseline-fixture',
                          baseline_evidence_cutoff_date=baseline, request_id='create')
        return s

    def test_baseline_is_exposed_and_distinct_from_cycle_cutoff(self):
        s = self.create()
        s.start_cycle('BASE', cycle_no=1, window_start='2026-10-02',
                      window_end='2026-10-04', request_id='cycle')
        snap = s.snapshot('BASE')
        self.assertEqual(snap['baseline_evidence_cutoff_date'], '2026-10-01')
        self.assertEqual(snap['cycles'][0]['window_end'], '2026-10-04')
        text = render_demo(snap)
        self.assertIn('Baseline de evidência sintético do Monitor: 2026-10-01', text)
        self.assertIn('2026-10-02 a 2026-10-04', text)
        self.assertEqual(s.replay_snapshot('BASE'), snap)

    def test_invalid_baseline_has_no_side_effects(self):
        for baseline in ('2026-02-30', '', 'not-a-date'):
            with self.subTest(baseline=baseline):
                s = SyntheticMonitorService()
                with self.assertRaises(DomainError):
                    s.create_scenario(scenario_id='BASE', target_version='target-1',
                        monitor_version='monitor-1', scientific_conclusion='Synthetic',
                        fixture_source='synthetic:fixture',
                        baseline_evidence_cutoff_date=baseline, request_id='create')
                self.assertEqual(s.repo.scenarios, {})
                self.assertEqual(s.repo.receipts, {})

    def test_cycle_must_start_strictly_after_baseline(self):
        s = self.create()
        for start in ('2026-09-30', '2026-10-01'):
            with self.subTest(start=start):
                before = s.snapshot('BASE')
                with self.assertRaisesRegex(DomainError, 'after synthetic baseline'):
                    s.start_cycle('BASE', cycle_no=1, window_start=start,
                                  window_end='2026-10-03', request_id='start-'+start)
                self.assertEqual(s.snapshot('BASE'), before)

    def test_baseline_cannot_change_through_idempotent_creation(self):
        s = self.create()
        before = s.snapshot('BASE')
        with self.assertRaises(DomainError):
            s.create_scenario(scenario_id='BASE', target_version='target-1',
                              monitor_version='monitor-1', scientific_conclusion='Synthetic original',
                              fixture_source='synthetic:baseline-fixture',
                              baseline_evidence_cutoff_date='2026-09-30', request_id='create')
        self.assertEqual(s.snapshot('BASE'), before)


if __name__ == '__main__':
    unittest.main()
