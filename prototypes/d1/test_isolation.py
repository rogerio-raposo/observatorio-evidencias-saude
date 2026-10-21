"""D1-T1/S6: tests of sequential in-memory isolation, cleanup and replay only."""
import unittest
from copy import deepcopy
from monitor import DomainError, InMemoryRepository, SyntheticMonitorService


class IsolationAndDisposalTests(unittest.TestCase):
    def create(self, service, scenario_id):
        return service.create_scenario(
            scenario_id=scenario_id, target_version=f'{scenario_id}-target',
            monitor_version=f'{scenario_id}-monitor', scientific_conclusion=f'{scenario_id} fiction',
            fixture_source='synthetic:s6-isolation', request_id='create')

    def test_independent_repositories_do_not_share_mutations_or_receipts(self):
        left, right = SyntheticMonitorService(), SyntheticMonitorService()
        self.create(left, 'same-id')
        self.create(right, 'same-id')
        before_right = right.snapshot('same-id')
        left.start_cycle('same-id', cycle_no=1, window_start='2026-10-02',
                         window_end='2026-10-03', request_id='start')
        self.assertEqual(right.snapshot('same-id'), before_right)
        self.assertNotIn(('same-id', 'start'), right.repo.receipts)
        self.assertEqual(len(right.snapshot('same-id')['cycles']), 0)

    def test_two_scenarios_in_one_repository_remain_independent(self):
        repo = InMemoryRepository()
        service = SyntheticMonitorService(repo)
        self.create(service, 'A')
        self.create(service, 'B')
        before_b = service.snapshot('B')
        service.start_cycle('A', cycle_no=1, window_start='2026-10-02',
                            window_end='2026-10-03', request_id='start')
        service.close_cycle('A', cycle_no=1, decision='no_update_needed',
                            rationale='synthetic', scenario_actor='fictional', request_id='close')
        self.assertEqual(service.snapshot('B'), before_b)
        self.assertEqual(service.replay_snapshot('A'), service.snapshot('A'))
        self.assertEqual(service.replay_snapshot('B'), before_b)
        self.assertNotIn(('B', 'start'), repo.receipts)

    def test_replay_is_read_only_and_repeatable(self):
        service = SyntheticMonitorService()
        self.create(service, 'R')
        service.start_cycle('R', cycle_no=1, window_start='2026-10-02',
                            window_end='2026-10-03', request_id='start')
        before_scenarios = deepcopy(service.repo.scenarios)
        before_receipts = deepcopy(service.repo.receipts)
        first = service.replay_snapshot('R')
        self.assertEqual(first, service.replay_snapshot('R'))
        first['cycles'].clear()
        self.assertEqual(service.repo.scenarios, before_scenarios)
        self.assertEqual(service.repo.receipts, before_receipts)

    def test_explicit_repository_disposal_discards_all_synthetic_data(self):
        repo = InMemoryRepository()
        service = SyntheticMonitorService(repo)
        self.create(service, 'D')
        service.start_cycle('D', cycle_no=1, window_start='2026-10-02',
                            window_end='2026-10-03', request_id='start')
        self.assertTrue(repo.scenarios)
        self.assertTrue(repo.receipts)
        # Only in-memory cleanup: not secure deletion, filesystem wiping or DB cleanup.
        repo.scenarios.clear()
        repo.receipts.clear()
        self.assertEqual(repo.scenarios, {})
        self.assertEqual(repo.receipts, {})
        with self.assertRaises(DomainError):
            service.snapshot('D')
        self.create(service, 'D')
        self.assertEqual(len(service.snapshot('D')['cycles']), 0)

    def test_failed_command_does_not_modify_another_scenario(self):
        service = SyntheticMonitorService()
        self.create(service, 'A')
        self.create(service, 'B')
        before_b = service.snapshot('B')
        before_receipts = deepcopy(service.repo.receipts)
        with self.assertRaises(DomainError):
            service.start_cycle('A', cycle_no=1, window_start='bad-date',
                                window_end='2026-10-03', request_id='invalid')
        self.assertEqual(service.snapshot('B'), before_b)
        self.assertEqual(service.repo.receipts, before_receipts)


if __name__ == '__main__':
    unittest.main()
