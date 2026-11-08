"""PF-I03-A3: offline Q2 and routing proposals, not scientific decisions.

No SQL, HTTP routes, Investigation creation, persistence, or E9 activation.
"""
from dataclasses import dataclass
from .preparation_auth import require_question_preparer
from .question_preparation import PreparationHold

METHODS = frozenset(("INT", "SAF", "DIA", "PRO", "PRE", "ETI", "FREQ", "QUAL", "SYS", "MAP"))
DEPTHS = frozenset(("N0", "N1", "N2", "N3", "N4"))
MAINTENANCE = frozenset(("M0", "M1", "M2", "M3"))


@dataclass(frozen=True)
class Q2RoutingProposal:
    question_id: str
    q1_version: int
    operational_question: str
    population: str
    exposure_or_intervention: str
    comparator: str
    outcomes: tuple[str, ...]
    methodological_class: str
    depth: str
    maintenance: str
    routing_justification: str


def present_q2_routing_proposal(*, user, q1_readback, proposal):
    """Present a provisional proposal only after explicit preparer authorization."""
    require_question_preparer(user)
    if type(proposal) is not Q2RoutingProposal or type(q1_readback) is not dict:
        raise PreparationHold("HOLD: invalid Q2 proposal/readback")
    if (set(q1_readback) != {
            "question_id", "version", "original_text", "proposed_normalized_text",
            "justification", "state", "scientific_review", "q2", "routing", "e9"
        } or q1_readback["state"] != "PREPARATORY_ONLY"
            or q1_readback["scientific_review"] != "NOT_PERFORMED"
            or q1_readback["q2"] != "NOT_EXECUTED"
            or q1_readback["routing"] != "NOT_AUTHORIZED"
            or q1_readback["e9"] != "BLOCKED"
            or type(q1_readback["version"]) is not int
            or q1_readback["version"] < 2
            or type(proposal.q1_version) is not int
            or proposal.q1_version != q1_readback["version"]
            or type(proposal.question_id) is not str
            or not proposal.question_id.startswith("OES-SYNTH-Q0-")
            or proposal.question_id != q1_readback["question_id"]):
        raise PreparationHold("HOLD: Q1 provenance or boundary mismatch")
    texts = (proposal.operational_question, proposal.population,
             proposal.exposure_or_intervention, proposal.comparator,
             proposal.routing_justification)
    if (any(type(value) is not str or not value.strip() for value in texts)
            or type(proposal.outcomes) is not tuple or not proposal.outcomes
            or any(type(value) is not str or not value.strip() for value in proposal.outcomes)
            or proposal.methodological_class not in METHODS
            or proposal.depth not in DEPTHS
            or proposal.maintenance not in MAINTENANCE):
        raise PreparationHold("HOLD: incomplete or invalid Q2/routing proposal")
    return {
        "question_id": proposal.question_id,
        "based_on_q1_version": proposal.q1_version,
        "original_text": q1_readback["original_text"],
        "normalized_text": q1_readback["proposed_normalized_text"],
        "operational_question": proposal.operational_question,
        "population": proposal.population,
        "exposure_or_intervention": proposal.exposure_or_intervention,
        "comparator": proposal.comparator,
        "outcomes": proposal.outcomes,
        "methodological_class": proposal.methodological_class,
        "depth": proposal.depth,
        "maintenance": proposal.maintenance,
        "routing_justification": proposal.routing_justification,
        "state": "PROPOSED_OFFLINE_ONLY",
        "admissibility": "NOT_DECIDED",
        "scientific_review": "NOT_PERFORMED",
        "investigation": "NOT_OPENED",
        "e9": "BLOCKED",
    }


def present_authenticated_q2_routing(*, user, q1_command, proposal, unit_of_work=None):
    """Synthetic authenticated projection from an existing offline Q1 receipt.

    No client-supplied actor or Q1 presentation dict is accepted as provenance.
    No command is submitted, no Q2/route receipt or version is persisted.
    """
    from .question_preparation import review_authenticated_q1_offline, validate_propose_q1
    from .pf_i03_q1_offline import _present_q1_receipt
    require_question_preparer(user)
    validate_propose_q1(q1_command)
    if (type(proposal) is not Q2RoutingProposal
            or not q1_command.question_id.startswith("OES-SYNTH-Q0-")
            or proposal.question_id != q1_command.question_id
            or type(proposal.q1_version) is not int
            or proposal.q1_version != q1_command.expected_version + 1):
        raise PreparationHold("HOLD: synthetic Q1 reference required")
    receipt = review_authenticated_q1_offline(user=user, command=q1_command, unit_of_work=unit_of_work)
    q1 = _present_q1_receipt(q1_command, receipt)
    result = present_q2_routing_proposal(user=user, q1_readback=q1, proposal=proposal)
    result["provenance"] = {"source": "OFFLINE_Q1_RECEIPT_VERIFIED", "actor_id": receipt.actor_id,
        "request_id": receipt.request_id, "question_id": receipt.question_id,
        "q1_version": receipt.version, "fingerprint": receipt.fingerprint,
        "command_kind": receipt.command_kind}
    result["certainty"] = "NOT_ASSESSED"
    result["limitations"] = "Dados sintéticos; recibo verificado no port offline. Sem prova de persistência PostgreSQL Q1 ou Q2 e sem avaliação científica."
    return result
