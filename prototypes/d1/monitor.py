"""OES D1 T1 — isolated, synthetic-only M2 application kernel.

Not an implementation of product.evidence_monitor_view/0.1 or a scientific review.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from hashlib import sha256
import json
from datetime import date
from typing import Any


class DomainError(ValueError):
    pass


def digest(value: str) -> str:
    return sha256(value.encode('utf-8')).hexdigest()


def encoded(value: Any) -> str:
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(',', ':'))


@dataclass
class InMemoryRepository:
    scenarios: dict[str, dict] = field(default_factory=dict)
    receipts: dict[tuple[str, str], tuple[str, Any]] = field(default_factory=dict)


class SyntheticMonitorService:
    """D1-T1 boundary: domain transitions, immutable event log, no external I/O."""

    def __init__(self, repository: InMemoryRepository | None = None):
        self.repo = repository if repository is not None else InMemoryRepository()

    def _idempotent(self, scenario_id: str, request_id: str, payload: dict, action):
        if not request_id:
            raise DomainError('request_id is required')
        key = (scenario_id, request_id)
        fingerprint = digest(encoded(payload))
        if key in self.repo.receipts:
            old, result = self.repo.receipts[key]
            if old != fingerprint:
                raise DomainError('request_id reused with different payload')
            return json.loads(encoded(result))
        result = action()
        self.repo.receipts[key] = (fingerprint, json.loads(encoded(result)))
        return json.loads(encoded(result))

    @staticmethod
    def _append(s: dict, kind: str, data: dict):
        s['events'].append({'sequence': len(s['events']) + 1, 'kind': kind, 'data': json.loads(encoded(data))})

    def create_scenario(self, *, scenario_id: str, target_version: str, monitor_version: str,
                        scientific_conclusion: str, fixture_source: str, request_id: str) -> dict:
        if not all((scenario_id, target_version, monitor_version, scientific_conclusion, fixture_source)):
            raise DomainError('identities, scientific conclusion and provenance are mandatory')
        if not request_id:
            raise DomainError('request_id is required')
        create_payload = {'action': 'create', 'target_version': target_version,
                          'monitor_version': monitor_version, 'scientific_conclusion': scientific_conclusion,
                          'fixture_source': fixture_source}
        fingerprint = digest(encoded(create_payload))
        key = (scenario_id, request_id)
        if key in self.repo.receipts:
            if self.repo.receipts[key][0] != fingerprint:
                raise DomainError('request_id reused with different payload')
            return self.snapshot(scenario_id)
        if scenario_id in self.repo.scenarios:
            raise DomainError('scenario already exists')
        s = {'scenario_id': scenario_id, 'synthetic': True, 'fixture_source': fixture_source,
             'target_version': target_version, 'monitor_version': monitor_version,
             'scientific_conclusion': scientific_conclusion, 'conclusion_hash': digest(scientific_conclusion),
             'target_currency': 'current', 'monitor_currency': 'current',
             'monitor_operational_status': 'active', 'monitor_editorial_status': 'draft',
             'cycles': [], 'events': []}
        self.repo.scenarios[scenario_id] = s
        self._append(s, 'scenario_created', {'target_version': target_version, 'monitor_version': monitor_version,
                                             'fixture_source': fixture_source, 'scientific_conclusion': scientific_conclusion,
                                             'executed_by': 'python_service'})
        self.repo.receipts[key] = (fingerprint, scenario_id)
        return self.snapshot(scenario_id)

    def _scenario(self, scenario_id: str) -> dict:
        try:
            return self.repo.scenarios[scenario_id]
        except KeyError:
            raise DomainError('unknown scenario') from None

    def _cycle(self, s: dict, cycle_no: int) -> dict:
        for c in s['cycles']:
            if c['cycle_no'] == cycle_no:
                return c
        raise DomainError('unknown cycle')

    def start_cycle(self, scenario_id: str, *, cycle_no: int, window_start: str, window_end: str,
                    request_id: str) -> dict:
        s = self._scenario(scenario_id)
        p = {'action': 'start', 'cycle_no': cycle_no, 'start': window_start, 'end': window_end}
        def run():
            try:
                start_day, end_day = date.fromisoformat(window_start), date.fromisoformat(window_end)
            except (ValueError, TypeError):
                raise DomainError('cycle dates must be valid ISO dates') from None
            if cycle_no != len(s['cycles']) + 1 or start_day > end_day:
                raise DomainError('invalid cycle number or time window')
            if s['cycles'] and (s['cycles'][-1]['status'] != 'completed'
                                or start_day <= date.fromisoformat(s['cycles'][-1]['window_end'])):
                raise DomainError('previous cycle incomplete or windows overlap')
            c = {'cycle_no': cycle_no, 'window_start': window_start, 'window_end': window_end,
                 'status': 'running', 'signals': [], 'assessments': [], 'decision': None}
            s['cycles'].append(c)
            self._append(s, 'cycle_started', {'cycle_no': cycle_no, 'window_start': window_start,
                                              'window_end': window_end})
            return {'cycle_no': cycle_no, 'status': 'running'}
        return self._idempotent(scenario_id, request_id, p, run)

    def register_signal(self, scenario_id: str, *, cycle_no: int, signal_id: str, kind: str,
                        source: str, request_id: str) -> dict:
        s = self._scenario(scenario_id)
        p = {'action': 'signal', 'cycle_no': cycle_no, 'signal_id': signal_id, 'kind': kind, 'source': source}
        def run():
            c = self._cycle(s, cycle_no)
            if c['status'] != 'running' or not signal_id or not source.startswith('synthetic:'):
                raise DomainError('cycle closed, missing id or non-synthetic source')
            if kind not in ('search_hit', 'evidence_event') or any(v['signal_id'] == signal_id for v in c['signals']):
                raise DomainError('invalid or duplicate signal')
            v = {'signal_id': signal_id, 'kind': kind, 'source': source, 'synthetic': True}
            c['signals'].append(v)
            self._append(s, 'signal_registered', {'cycle_no': cycle_no, **v})
            return dict(v)
        return self._idempotent(scenario_id, request_id, p, run)

    def record_assessment(self, scenario_id: str, *, cycle_no: int, signal_id: str, decision: str,
                          impacts: list[str], rationale: str, scenario_actor: str, request_id: str) -> dict:
        s = self._scenario(scenario_id)
        p = {'action': 'assessment', 'cycle_no': cycle_no, 'signal_id': signal_id, 'decision': decision,
             'impacts': impacts, 'rationale': rationale, 'scenario_actor': scenario_actor}
        def run():
            c = self._cycle(s, cycle_no)
            if c['status'] != 'running' or signal_id not in {x['signal_id'] for x in c['signals']}:
                raise DomainError('cycle closed or signal not found')
            if any(x['signal_id'] == signal_id for x in c['assessments']):
                raise DomainError('assessment already exists')
            if decision not in ('pending', 'excluded', 'retained_for_impact') or not rationale or not scenario_actor:
                raise DomainError('invalid decision, rationale or actor')
            valid = {'quantitative', 'certainty', 'applicability', 'conclusion', 'validity', 'scope'}
            if len(impacts) != len(set(impacts)) or any(i not in valid for i in impacts):
                raise DomainError('duplicate or unknown impact category')
            if decision == 'retained_for_impact' and not impacts:
                raise DomainError('retained candidate requires impact')
            if decision != 'retained_for_impact' and impacts:
                raise DomainError('nonretained candidate cannot have impacts')
            row = {'signal_id': signal_id, 'decision': decision, 'impacts': list(impacts),
                   'rationale': rationale, 'scenario_actor': scenario_actor,
                   'executed_by': 'python_service', 'verification': 'not_performed'}
            c['assessments'].append(row)
            self._append(s, 'assessment_recorded', {'cycle_no': cycle_no, **row})
            return dict(row)
        return self._idempotent(scenario_id, request_id, p, run)

    def close_cycle(self, scenario_id: str, *, cycle_no: int, decision: str, rationale: str,
                    scenario_actor: str, request_id: str) -> dict:
        s = self._scenario(scenario_id)
        p = {'action': 'close', 'cycle_no': cycle_no, 'decision': decision,
             'rationale': rationale, 'scenario_actor': scenario_actor}
        def run():
            c = self._cycle(s, cycle_no)
            mapping = {'no_update_needed': 'current', 'evaluate_update': 'under_evaluation',
                       'update_recommended': 'update_recommended', 'outdated': 'outdated'}
            if c['status'] != 'running' or decision not in mapping or not rationale or not scenario_actor:
                raise DomainError('invalid cycle close')
            if len(c['signals']) != len(c['assessments']) or any(a['decision'] == 'pending' for a in c['assessments']):
                raise DomainError('all signals require terminal assessment')
            if decision == 'no_update_needed' and any(a['decision'] == 'retained_for_impact' for a in c['assessments']):
                raise DomainError('retained impact requires a nontrivial decision')
            c['decision'] = {'value': decision, 'rationale': rationale, 'scenario_actor': scenario_actor,
                             'executed_by': 'python_service', 'verification': 'not_performed'}
            c['status'] = 'completed'
            s['target_currency'] = mapping[decision]
            self._append(s, 'cycle_closed', {'cycle_no': cycle_no, 'decision': dict(c['decision']),
                                             'target_currency': s['target_currency']})
            if digest(s['scientific_conclusion']) != s['conclusion_hash']:
                raise DomainError('scientific conclusion integrity violation')
            return {'cycle_no': cycle_no, 'status': 'completed', 'target_currency': s['target_currency']}
        return self._idempotent(scenario_id, request_id, p, run)

    def replay_snapshot(self, scenario_id: str) -> dict:
        """Rebuild state from event log; compare with live snapshot, no external I/O."""
        original = self.snapshot(scenario_id)
        events = original['event_log']
        if [e['sequence'] for e in events] != list(range(1, len(events) + 1)):
            raise DomainError('noncontiguous event sequence')
        fresh = SyntheticMonitorService()
        for event in events:
            d, kind = event['data'], event['kind']
            rid = 'replay-' + str(event['sequence'])
            if kind == 'scenario_created':
                fresh.create_scenario(scenario_id=scenario_id, target_version=d['target_version'],
                    monitor_version=d['monitor_version'], scientific_conclusion=d['scientific_conclusion'],
                    fixture_source=d['fixture_source'], request_id=rid)
            elif kind == 'cycle_started':
                fresh.start_cycle(scenario_id, cycle_no=d['cycle_no'], window_start=d['window_start'],
                    window_end=d['window_end'], request_id=rid)
            elif kind == 'signal_registered':
                fresh.register_signal(scenario_id, cycle_no=d['cycle_no'], signal_id=d['signal_id'],
                    kind=d['kind'], source=d['source'], request_id=rid)
            elif kind == 'assessment_recorded':
                fresh.record_assessment(scenario_id, cycle_no=d['cycle_no'], signal_id=d['signal_id'],
                    decision=d['decision'], impacts=d['impacts'], rationale=d['rationale'],
                    scenario_actor=d['scenario_actor'], request_id=rid)
            elif kind == 'cycle_closed':
                v = d['decision']
                fresh.close_cycle(scenario_id, cycle_no=d['cycle_no'], decision=v['value'],
                    rationale=v['rationale'], scenario_actor=v['scenario_actor'], request_id=rid)
            else:
                raise DomainError('unknown historical event')
        reconstructed = fresh.snapshot(scenario_id)
        if reconstructed != original:
            raise DomainError('replay diverges from stored state')
        return reconstructed

    def snapshot(self, scenario_id: str) -> dict:
        s = self._scenario(scenario_id)
        return json.loads(encoded({'schema_version': 'oes.d1.monitor_snapshot/0.1', 'synthetic': True,
             'scenario_id': s['scenario_id'], 'fixture_source': s['fixture_source'],
             'target': {'product_version_uuid': s['target_version'], 'scientific_conclusion': s['scientific_conclusion'],
                        'scientific_conclusion_hash': s['conclusion_hash'], 'currency_status': s['target_currency']},
             'monitor': {'product_version_uuid': s['monitor_version'], 'editorial_status': s['monitor_editorial_status'],
                         'operational_status': s['monitor_operational_status'], 'currency_status': s['monitor_currency']},
             'cycles': s['cycles'], 'event_log': s['events'],
             'execution_disclosure': {'python_services_executed': True, 'canonical_sql_view_executed': False,
               'factual_search_performed': False, 'scientific_review_performed': False,
               'publication_gate_assessed': False}}))


def render_demo(snapshot: dict) -> str:
    """Small demonstrator, not the canonical EvidenceMonitorView template."""
    if snapshot.get('schema_version') != 'oes.d1.monitor_snapshot/0.1' or not snapshot.get('synthetic'):
        raise DomainError('only synthetic D1 snapshots supported')
    lines = ['# OES D1 — Monitor M2 sintético', '',
             '**DEMONSTRAÇÃO SINTÉTICA — NÃO É MONITOR CIENTÍFICO REAL**', '',
             'Cenário: ' + snapshot['scenario_id'],
             'Monitor: ' + snapshot['monitor']['product_version_uuid'],
             'Produto-alvo: ' + snapshot['target']['product_version_uuid'],
             'Currentness do alvo: ' + snapshot['target']['currency_status'],
             'Conclusão científica sintética (inalterada): ' + snapshot['target']['scientific_conclusion'], '']
    for c in snapshot['cycles']:
        lines += [f"## Ciclo {c['cycle_no']} — {c['status']}",
                  f"Janela: {c['window_start']} a {c['window_end']}",
                  f"Sinais: {len(c['signals'])}; avaliações: {len(c['assessments'])}",
                  'Decisão: ' + (c['decision']['value'] if c['decision'] else 'pendente'), '']
    lines += ['*Sem buscas factuais, revisão científica, gate de publicação ou execução da View SQL canônica.*']
    return '\n'.join(lines) + '\n'
