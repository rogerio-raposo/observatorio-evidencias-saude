"""Read-only presentation mapping for vetted OES documentary sources."""
from dataclasses import dataclass

ROOT = "https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/"
DOCUMENTS = {
    "Documento 247": ("docs/governance/247-d2-ctgov-e3-primeira-recuperacao-estruturada-parcial-cp265.md", "Documento 247"),
    "Documento 248": ("docs/governance/248-d2-ctgov-e4-conciliacao-documental-20-ncts.md", "Documento 248"),
    "Documento products/154": ("docs/products/154-reconciliacao-listas-artigos-clusters-reports-ovr01-dcbti.md", "Documento 154"),
}
IDENTITY_LABELS = {
    "KNOWN_DOCUMENTED": "Identidade documentada",
    "NOT_IDENTIFIED_IN_SCOPED_INVENTORY": "Não identificado no inventário consultado",
}

@dataclass(frozen=True)
class SourceLink:
    label: str
    url: str

def source_links(source_ref):
    """Map only explicitly verified document references; never parse arbitrary URLs."""
    return tuple(SourceLink(label=label, url=ROOT + path) for key, (path, label)
                 in DOCUMENTS.items() if key in source_ref)

def build_presentation(signal):
    return {
        "identity_label": IDENTITY_LABELS[signal.identity_state],
        "provenance_links": source_links(signal.provenance),
        "milestones": tuple({"item": milestone, "links": source_links(milestone.source_ref)}
                             for milestone in signal.milestones),
    }
