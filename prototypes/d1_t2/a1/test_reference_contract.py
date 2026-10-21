"""T2-A1 regression guard: immutable T1 copy and explicitly mapped errors."""
import hashlib
import unittest
from pathlib import Path
from bridge import SyntheticCommandBridge
from repository import RepositoryConflict
from t1_monitor_reference import DomainError, SyntheticMonitorService


class ReferenceAndErrorContractTests(unittest.TestCase):
    def test_reference_matches_t1_baseline(self):
        here = Path(__file__).resolve().parent
        reference = (here / 't1_monitor_reference.py').read_bytes()
        t1_path = here.parents[1] / 'd1' / 'monitor.py'
        self.assertTrue(t1_path.is_file(), 'T1 baseline must be mounted next to T2 tests')
        self.assertEqual(reference, t1_path.read_bytes())
        self.assertEqual(hashlib.sha256(reference).hexdigest(), hashlib.sha256(t1_path.read_bytes()).hexdigest())

    def test_creation_conflict_exception_is_explicitly_different(self):
        create = dict(scenario_id='synthetic-a', target_version='target',
                      monitor_version='monitor', scientific_conclusion='Fictional',
                      fixture_source='synthetic:test', baseline_evidence_cutoff_date='2026-10-01',
                      request_id='create')
        bridge, legacy = SyntheticCommandBridge(), SyntheticMonitorService()
        bridge.create_scenario(**create)
        legacy.create_scenario(**create)
        changed = dict(create, fixture_source='synthetic:changed')
        with self.assertRaises(RepositoryConflict):
            bridge.create_scenario(**changed)
        with self.assertRaises(DomainError):
            legacy.create_scenario(**changed)
        self.assertEqual(bridge.snapshot('synthetic-a'), legacy.snapshot('synthetic-a'))

    def test_domain_invalid_origin_still_raises_domain_error(self):
        args = dict(scenario_id='synthetic-a', target_version='target',
                    monitor_version='monitor', scientific_conclusion='Fictional',
                    fixture_source='external', baseline_evidence_cutoff_date='2026-10-01',
                    request_id='create')
        bridge, legacy = SyntheticCommandBridge(), SyntheticMonitorService()
        with self.assertRaises(DomainError):
            bridge.create_scenario(**args)
        with self.assertRaises(DomainError):
            legacy.create_scenario(**args)
        self.assertIsNone(bridge.repo.read_snapshot('synthetic-a'))

    def test_duplicate_scenario_with_new_request_preserves_domain_error(self):
        args = dict(scenario_id='synthetic-a', target_version='target',
                    monitor_version='monitor', scientific_conclusion='Fictional',
                    fixture_source='synthetic:test', baseline_evidence_cutoff_date='2026-10-01',
                    request_id='create')
        bridge, legacy = SyntheticCommandBridge(), SyntheticMonitorService()
        bridge.create_scenario(**args)
        legacy.create_scenario(**args)
        with self.assertRaises(DomainError):
            bridge.create_scenario(**dict(args, request_id='new'))
        with self.assertRaises(DomainError):
            legacy.create_scenario(**dict(args, request_id='new'))


if __name__ == '__main__':
    unittest.main()
