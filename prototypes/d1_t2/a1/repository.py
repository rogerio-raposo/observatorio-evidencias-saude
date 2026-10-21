"""OES T2-A1: synthetic-only in-memory repository boundary (not a database)."""
from __future__ import annotations
from copy import deepcopy
from dataclasses import dataclass
from threading import RLock
from typing import Any, Protocol


class RepositoryConflict(ValueError):
    """Invalid duplicate, revision, or event sequence."""


@dataclass(frozen=True)
class ScenarioState:
    revision: int
    data: dict[str, Any]


@dataclass(frozen=True)
class Receipt:
    fingerprint: str
    response: Any
    revision: int


class ScenarioRepository(Protocol):
    def begin_command(self, scenario_id: str, request_id: str, fingerprint: str) -> "MemoryUnitOfWork": ...
    def read_snapshot(self, scenario_id: str) -> ScenarioState | None: ...
    def list_events(self, scenario_id: str) -> list[dict]: ...
    def read_receipt(self, scenario_id: str, request_id: str) -> Receipt | None: ...


class InMemoryScenarioRepository:
    """Synchronous repository; one Python-process lock, no durable or DB semantics."""

    def __init__(self) -> None:
        self._records: dict[str, dict] = {}
        self._lock = RLock()

    def begin_command(self, scenario_id: str, request_id: str, fingerprint: str) -> "MemoryUnitOfWork":
        if not all((scenario_id, request_id, fingerprint)):
            raise RepositoryConflict("scenario, request and fingerprint required")
        return MemoryUnitOfWork(self, scenario_id, request_id, fingerprint)

    def _record(self, scenario_id: str) -> dict:
        return self._records.get(scenario_id, {"revision": 0, "state": None, "events": [], "receipts": {}})

    def read_snapshot(self, scenario_id: str) -> ScenarioState | None:
        with self._lock:
            r = self._record(scenario_id)
            return ScenarioState(r["revision"], deepcopy(r["state"])) if r["state"] is not None else None

    def list_events(self, scenario_id: str) -> list[dict]:
        with self._lock:
            return deepcopy(self._record(scenario_id)["events"])

    def read_receipt(self, scenario_id: str, request_id: str) -> Receipt | None:
        with self._lock:
            return deepcopy(self._record(scenario_id)["receipts"].get(request_id))


class MemoryUnitOfWork:
    """One logical command: stage state/event/receipt; publish one record on commit."""

    def __init__(self, repo: InMemoryScenarioRepository, scenario_id: str,
                 request_id: str, fingerprint: str) -> None:
        self.repo, self.scenario_id = repo, scenario_id
        self.request_id, self.fingerprint = request_id, fingerprint
        self._active = False
        self._finished = False
        self._staged: set[str] = set()

    def __enter__(self) -> "MemoryUnitOfWork":
        self.repo._lock.acquire()
        self._active = True
        self._work = deepcopy(self.repo._record(self.scenario_id))
        return self

    def __exit__(self, *_: object) -> None:
        self._finished = True
        self._active = False
        self.repo._lock.release()

    def _check(self) -> None:
        if not self._active or self._finished:
            raise RepositoryConflict("unit of work is not active")

    def find_receipt(self) -> Receipt | None:
        self._check()
        r = self._work["receipts"].get(self.request_id)
        if r is not None and r.fingerprint != self.fingerprint:
            raise RepositoryConflict("request reused with different payload")
        return deepcopy(r)

    def read_scenario(self) -> ScenarioState | None:
        self._check()
        r = self._work
        return ScenarioState(r["revision"], deepcopy(r["state"])) if r["state"] is not None else None

    def stage_scenario(self, state: dict, expected_revision: int) -> None:
        self._check()
        if "state" in self._staged or expected_revision != self._work["revision"]:
            raise RepositoryConflict("duplicate stage or stale revision")
        if not isinstance(state, dict) or not state.get("synthetic") is True:
            raise RepositoryConflict("synthetic scenario required")
        self._work["state"] = deepcopy(state)
        self._staged.add("state")

    def append_event(self, kind: str, data: dict, sequence: int) -> None:
        self._check()
        if "event" in self._staged or not kind or not isinstance(data, dict):
            raise RepositoryConflict("invalid or duplicate event")
        if sequence != len(self._work["events"]) + 1:
            raise RepositoryConflict("invalid event sequence")
        self._work["events"].append({"sequence": sequence, "kind": kind, "data": deepcopy(data)})
        self._staged.add("event")

    def stage_receipt(self, response: Any) -> None:
        self._check()
        if "receipt" in self._staged or self.request_id in self._work["receipts"]:
            raise RepositoryConflict("duplicate receipt")
        self._work["receipts"][self.request_id] = Receipt(
            self.fingerprint, deepcopy(response), self._work["revision"] + 1)
        self._staged.add("receipt")

    def commit(self) -> int:
        self._check()
        if self._staged != {"state", "event", "receipt"}:
            raise RepositoryConflict("state, event and receipt must commit together")
        self._work["revision"] += 1
        self.repo._records[self.scenario_id] = deepcopy(self._work)
        self._finished = True
        return self._work["revision"]

    def rollback(self) -> None:
        self._check()
        self._finished = True
