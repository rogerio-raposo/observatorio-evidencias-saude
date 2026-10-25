"""P1-A3 minimal offline composition. No database, external I/O or scientific inference."""
from e6_private_pg_offline import prepare_observation, PersistenceHold


def compose_synthetic_path(*, raw, provenance, association, bridge, documentary_resolver):
    """Associate explicitly declared synthetic IDs; return sanitized documentary receipt.

    The caller owns the fresh in-memory bridge and vetted documentary resolver.
    No persistence or D2-I-C connected readback is implied.
    """
    try:
        prepared = prepare_observation(raw, provenance)
        if not isinstance(association, dict) or set(association) != {
            "observation_id", "signal_id", "scenario_id", "documentary_nct"
        }:
            raise ValueError("invalid association")
        obs, signal_id, scenario_id, nct = (association[k] for k in
            ("observation_id", "signal_id", "scenario_id", "documentary_nct"))
        if obs != prepared.observation_id or not all(
            isinstance(x, str) and x.strip() for x in (obs, signal_id, scenario_id)
        ):
            raise ValueError("mismatched association")
        if nct is not None and (not isinstance(nct, str) or not nct.strip()):
            raise ValueError("invalid documentary reference")
        if bridge is None or not callable(documentary_resolver):
            raise ValueError("missing injected components")
        signal = documentary_resolver(nct) if nct is not None else None
        if nct is not None and (
            signal is None or signal.nct != nct
            or signal.identity_state not in {
                "KNOWN_DOCUMENTED", "NOT_IDENTIFIED_IN_SCOPED_INVENTORY"
            }
        ):
            raise ValueError("unvetted documentary reference")
        bridge.create_scenario(
            scenario_id=scenario_id, target_version="synthetic:target-v1",
            monitor_version="synthetic:monitor-v1",
            scientific_conclusion="SYNTHETIC_ONLY_NO_SCIENTIFIC_DECISION",
            fixture_source="synthetic:p1-a3", baseline_evidence_cutoff_date="2026-10-01",
            request_id="p1:create")
        bridge.start_cycle(scenario_id, cycle_no=1, window_start="2026-10-02",
                           window_end="2026-10-03", request_id="p1:start")
        bridge.register_signal(scenario_id, cycle_no=1, signal_id=signal_id,
                               kind="search_hit", source="synthetic:p1-a3",
                               request_id="p1:signal")
        replay = bridge.replay_snapshot(scenario_id)
        if not replay.get("synthetic") or not any(
            entry.get("kind") == "signal_registered"
            and entry.get("data", {}).get("signal_id") == signal_id
            for entry in replay.get("events", [])
        ):
            raise ValueError("invalid replay")
        return {
            "status": "SYNTHETIC_PATH_VERIFIED_OFFLINE",
            "observation_id": obs, "sha256": prepared.sha256,
            "payload_bytes": prepared.byte_count, "signal_id": signal_id,
            "documentary_nct": nct,
            "identity_state": signal.identity_state if signal is not None else None,
            "evidence_boundary": "SYNTHETIC_TECHNICAL_ONLY",
            "scientific_decision": "NOT_PERFORMED",
        }
    except Exception:
        raise PersistenceHold("HOLD: synthetic composition failed; no verified receipt") from None
