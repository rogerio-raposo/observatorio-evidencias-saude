"""OES A2-G4: static-only PostgreSQL orchestration of five synthetic commands.

NOT EXECUTION VALIDATED. Not authorized to import, run, test, or connect.
No database operation occurs merely by importing or constructing this bridge.
T1 remains the single canonical source of domain behavior.
"""
from __future__ import annotations

from copy import deepcopy
from typing import Any

from prototypes.d1.monitor import DomainError, InMemoryRepository, SyntheticMonitorService
from prototypes.d1_t2.a1.repository import RepositoryConflict
from .codec import fingerprint
from .repository import PostgresScenarioRepository


class SyntheticPostgresCommandBridge:
    """Experimental facade retaining T2-A1 signatures and observable semantics.

    The provided repository must be injected explicitly. Connection opening is
    delegated to its Unit of Work, never to this class's constructor.
    """

    def __init__(self, repository: PostgresScenarioRepository) -> None:
        if not isinstance(repository, PostgresScenarioRepository):
            raise TypeError("explicit PostgresScenarioRepository required")
        self.repo = repository

    @staticmethod
    def _service(scenario_id: str, state: dict | None) -> SyntheticMonitorService:
        return SyntheticMonitorService(InMemoryRepository(
            scenarios={scenario_id: deepcopy(state)} if state is not None else {}))

    def _execute(self, scenario_id: str, request_id: str, payload: dict,
                 method: str, params: dict) -> dict:
        fp = fingerprint(payload)
        # Only a known collision of the *scenario* PK during creation can be
        # re-evaluated. No general retry, and never retry uncertain COMMIT.
        for attempt in range(2):
            # Hold the UoW reference across context exit, so a SQLSTATE alone
            # can never authorize retry without explicit cleanup confirmation.
            uow = self.repo.begin_command(scenario_id, request_id, fp)
            try:
                with uow:
                    receipt = uow.find_receipt()
                    if receipt is not None:
                        if method == "create_scenario":
                            state = uow.read_scenario()
                            if state is None:
                                raise RepositoryConflict("receipt without scenario")
                            return self._service(scenario_id, state.data).snapshot(scenario_id)
                        return deepcopy(receipt.response)

                    prior = uow.read_scenario()
                    if method == "create_scenario" and prior is not None:
                        raise DomainError("scenario already exists")
                    if method != "create_scenario" and prior is None:
                        raise DomainError("unknown scenario")

                    events = uow.list_events()  # Never use an external repository read.
                    if prior is not None:
                        if (prior.revision != len(events)
                                or prior.data.get("events") != events):
                            raise RepositoryConflict("scenario and events disagree")
                    elif events:
                        raise RepositoryConflict("events without scenario")

                    service = self._service(scenario_id, prior.data if prior else None)
                    result = getattr(service, method)(**params)
                    state = service.repo.scenarios[scenario_id]
                    generated = state["events"]
                    if len(generated) != len(events) + 1 or generated[:-1] != events:
                        raise RepositoryConflict("unexpected domain event sequence")
                    last = generated[-1]
                    uow.stage_scenario(state, prior.revision if prior else 0)
                    uow.append_event(last["kind"], last["data"], last["sequence"])
                    uow.stage_receipt(result)
                    # Prepare the outward return before COMMIT, so deepcopy
                    # cannot fail after a known confirmation and obscure it.
                    stable_result = deepcopy(result)
                    uow.commit()  # Only confirmation path; context exit never commits.
                    return stable_result
            except Exception as exc:
                # The precise scenario-PK 23505 is necessary but never
                # sufficient: UoW must also attest successful rollback and
                # connection release. Unknown COMMIT or cleanup never retries.
                diagnostic = getattr(exc, "diag", None)
                if not (method == "create_scenario" and attempt == 0
                        and getattr(exc, "sqlstate", None) == "23505"
                        and getattr(diagnostic, "constraint_name", None)
                            == "scenario_pkey"
                        and uow.safe_to_retry_create_collision):
                    raise
                # Fresh protected transaction rechecks receipt and scenario.
        raise RepositoryConflict("creation collision resolution exhausted")

    def create_scenario(self, *, scenario_id: str, target_version: str,
                        monitor_version: str, scientific_conclusion: str,
                        fixture_source: str, baseline_evidence_cutoff_date: str,
                        request_id: str) -> dict:
        payload = {"action": "create", "target_version": target_version,
                   "monitor_version": monitor_version,
                   "scientific_conclusion": scientific_conclusion,
                   "fixture_source": fixture_source,
                   "baseline_evidence_cutoff_date": baseline_evidence_cutoff_date}
        return self._execute(scenario_id, request_id, payload, "create_scenario", dict(
            scenario_id=scenario_id, target_version=target_version,
            monitor_version=monitor_version, scientific_conclusion=scientific_conclusion,
            fixture_source=fixture_source,
            baseline_evidence_cutoff_date=baseline_evidence_cutoff_date,
            request_id=request_id))

    def start_cycle(self, scenario_id: str, *, cycle_no: int,
                    window_start: str, window_end: str, request_id: str) -> dict:
        payload = {"action": "start", "cycle_no": cycle_no,
                   "start": window_start, "end": window_end}
        return self._execute(scenario_id, request_id, payload, "start_cycle", dict(
            scenario_id=scenario_id, cycle_no=cycle_no,
            window_start=window_start, window_end=window_end,
            request_id=request_id))

    def register_signal(self, scenario_id: str, *, cycle_no: int, signal_id: str,
                        kind: str, source: str, request_id: str) -> dict:
        payload = {"action": "signal", "cycle_no": cycle_no,
                   "signal_id": signal_id, "kind": kind, "source": source}
        return self._execute(scenario_id, request_id, payload, "register_signal", dict(
            scenario_id=scenario_id, cycle_no=cycle_no, signal_id=signal_id,
            kind=kind, source=source, request_id=request_id))

    def record_assessment(self, scenario_id: str, *, cycle_no: int, signal_id: str,
                          decision: str, impacts: list[str], rationale: str,
                          scenario_actor: str, request_id: str) -> dict:
        payload = {"action": "assessment", "cycle_no": cycle_no,
                   "signal_id": signal_id, "decision": decision,
                   "impacts": impacts, "rationale": rationale,
                   "scenario_actor": scenario_actor}
        return self._execute(scenario_id, request_id, payload, "record_assessment", dict(
            scenario_id=scenario_id, cycle_no=cycle_no, signal_id=signal_id,
            decision=decision, impacts=impacts, rationale=rationale,
            scenario_actor=scenario_actor, request_id=request_id))

    def close_cycle(self, scenario_id: str, *, cycle_no: int, decision: str,
                    rationale: str, scenario_actor: str, request_id: str) -> dict:
        payload = {"action": "close", "cycle_no": cycle_no,
                   "decision": decision, "rationale": rationale,
                   "scenario_actor": scenario_actor}
        return self._execute(scenario_id, request_id, payload, "close_cycle", dict(
            scenario_id=scenario_id, cycle_no=cycle_no, decision=decision,
            rationale=rationale, scenario_actor=scenario_actor,
            request_id=request_id))

    def snapshot(self, scenario_id: str) -> dict:
        state, _events, _receipts = self.repo.read_consistent_snapshot(scenario_id)
        if state is None:
            raise DomainError("unknown scenario")
        return self._service(scenario_id, state.data).snapshot(scenario_id)

    def replay_snapshot(self, scenario_id: str) -> dict:
        """Candidate T2-A1-style replay, not independent event reconstruction.

        Repository cross-checks state/events/receipts from one MVCC snapshot.
        T1 replay then processes persisted state; deeper replay needs A2-G5.
        """
        state, _events, _receipts = self.repo.read_consistent_snapshot(scenario_id)
        if state is None:
            raise DomainError("unknown scenario")
        return self._service(scenario_id, state.data).replay_snapshot(scenario_id)
