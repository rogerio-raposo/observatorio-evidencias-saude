"""PF-I03: pure preflight contract for a future scientific Django session.

No connection, credential, model writes, or workflow. An observed session
must be supplied independently under a separately authorized READ ONLY gate.
"""
from evidence.question_preparation import PreparationHold

EXPECTED = {
    "alias": "oes_qprep_trial",
    "vendor": "postgresql",
    "database": "oes_sandbox",
    "session_user": "oes_qprep_login",
    "current_user": "oes_qprep_login",
    "search_path": "core, investigation, public",
    "transaction_read_only": "on",
}
TABLES = frozenset({
    "core.entity", "core.entity_version", "investigation.question",
    "investigation.question_version", "investigation.question_command_receipt",
})


def verify_observed_readonly_session(observed, tables):
    """Accept evidence, not self-declared readiness or a DB connection."""
    if not isinstance(observed, dict) or any(observed.get(k) != v for k, v in EXPECTED.items()):
        raise PreparationHold("HOLD: scientific Django session mismatch")
    if not isinstance(tables, dict) or set(tables) != TABLES:
        raise PreparationHold("HOLD: scientific table inventory mismatch")
    if any(type(v) is not bool or v is not True for v in tables.values()):
        raise PreparationHold("HOLD: scientific table unreadable")
    return "READ_ONLY_SESSION_CONTRACT_PASS"
