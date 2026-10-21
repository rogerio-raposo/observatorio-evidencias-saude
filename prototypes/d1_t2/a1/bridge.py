"""T2-A1 incremental bridge: T1 create/start through in-memory Unit of Work.

Only synthetic Python data; T1 reference copied without edits for testing.
No PostgreSQL, SQL, network, or persistence. Not a complete T2 service.
"""
from __future__ import annotations
from copy import deepcopy
from hashlib import sha256
import json
from repository import InMemoryScenarioRepository, RepositoryConflict
from t1_monitor_reference import InMemoryRepository, SyntheticMonitorService, encoded, DomainError


class SyntheticCommandBridge:
    def __init__(self, repository: InMemoryScenarioRepository | None = None):
        self.repo = repository if repository is not None else InMemoryScenarioRepository()

    def _execute(self, scenario_id: str, request_id: str, payload: dict, method: str, params: dict):
        fingerprint = sha256(encoded(payload).encode('utf-8')).hexdigest()
        with self.repo.begin_command(scenario_id, request_id, fingerprint) as uow:
            old_receipt = uow.find_receipt()
            if old_receipt is not None:
                # Preserve historical T1 creation semantics: return current snapshot,
                # rather than the original create response.
                if method == 'create_scenario':
                    return self.snapshot(scenario_id)
                return deepcopy(old_receipt.response)
            prior = uow.read_scenario()
            if method == 'create_scenario' and prior is not None:
                raise DomainError('scenario already exists')
            if method != 'create_scenario' and prior is None:
                raise DomainError('unknown scenario')
            old_events = self.repo.list_events(scenario_id)
            ephemeral = InMemoryRepository(
                scenarios={scenario_id: deepcopy(prior.data)} if prior else {})
            service = SyntheticMonitorService(ephemeral)
            result = getattr(service, method)(**params)
            state = ephemeral.scenarios[scenario_id]
            events = state['events']
            if len(events) != len(old_events) + 1 or events[:-1] != old_events:
                raise RepositoryConflict('unexpected domain event sequence')
            last = events[-1]
            uow.stage_scenario(state, prior.revision if prior else 0)
            uow.append_event(last['kind'], last['data'], last['sequence'])
            uow.stage_receipt(result)
            uow.commit()
            return deepcopy(result)

    def create_scenario(self, *, scenario_id: str, target_version: str,
                        monitor_version: str, scientific_conclusion: str,
                        fixture_source: str, baseline_evidence_cutoff_date: str,
                        request_id: str) -> dict:
        payload = {'action': 'create', 'target_version': target_version,
                   'monitor_version': monitor_version,
                   'scientific_conclusion': scientific_conclusion,
                   'fixture_source': fixture_source,
                   'baseline_evidence_cutoff_date': baseline_evidence_cutoff_date}
        return self._execute(scenario_id, request_id, payload, 'create_scenario',
            dict(scenario_id=scenario_id, target_version=target_version,
                 monitor_version=monitor_version,
                 scientific_conclusion=scientific_conclusion,
                 fixture_source=fixture_source,
                 baseline_evidence_cutoff_date=baseline_evidence_cutoff_date,
                 request_id=request_id))

    def start_cycle(self, scenario_id: str, *, cycle_no: int,
                    window_start: str, window_end: str, request_id: str) -> dict:
        payload = {'action': 'start', 'cycle_no': cycle_no,
                   'start': window_start, 'end': window_end}
        return self._execute(scenario_id, request_id, payload, 'start_cycle',
            dict(scenario_id=scenario_id, cycle_no=cycle_no,
                 window_start=window_start, window_end=window_end,
                 request_id=request_id))

    def register_signal(self, scenario_id: str, *, cycle_no: int, signal_id: str,
                        kind: str, source: str, request_id: str) -> dict:
        payload = {'action': 'signal', 'cycle_no': cycle_no,
                   'signal_id': signal_id, 'kind': kind, 'source': source}
        return self._execute(scenario_id, request_id, payload, 'register_signal',
            dict(scenario_id=scenario_id, cycle_no=cycle_no, signal_id=signal_id,
                 kind=kind, source=source, request_id=request_id))

    def record_assessment(self, scenario_id: str, *, cycle_no: int, signal_id: str,
                          decision: str, impacts: list[str], rationale: str,
                          scenario_actor: str, request_id: str) -> dict:
        payload = {'action': 'assessment', 'cycle_no': cycle_no,
                   'signal_id': signal_id, 'decision': decision,
                   'impacts': impacts, 'rationale': rationale,
                   'scenario_actor': scenario_actor}
        return self._execute(scenario_id, request_id, payload, 'record_assessment',
            dict(scenario_id=scenario_id, cycle_no=cycle_no, signal_id=signal_id,
                 decision=decision, impacts=impacts, rationale=rationale,
                 scenario_actor=scenario_actor, request_id=request_id))

    def close_cycle(self, scenario_id: str, *, cycle_no: int, decision: str,
                    rationale: str, scenario_actor: str, request_id: str) -> dict:
        payload = {'action': 'close', 'cycle_no': cycle_no, 'decision': decision,
                   'rationale': rationale, 'scenario_actor': scenario_actor}
        return self._execute(scenario_id, request_id, payload, 'close_cycle',
            dict(scenario_id=scenario_id, cycle_no=cycle_no, decision=decision,
                 rationale=rationale, scenario_actor=scenario_actor, request_id=request_id))

    def snapshot(self, scenario_id: str) -> dict:
        record = self.repo.read_snapshot(scenario_id)
        if record is None:
            raise DomainError('unknown scenario')
        service = SyntheticMonitorService(InMemoryRepository(
            scenarios={scenario_id: deepcopy(record.data)}))
        return service.snapshot(scenario_id)
