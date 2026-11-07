"""GET-only fixed Q0→Q1→Q2 illustration; never submits a command or uses a UoW."""
from django.http import Http404
from django.shortcuts import render

from .question_preparation import QuestionCommand
from .pf_i03_q2_routing_offline import Q2RoutingProposal


def q0_synthetic_preview(request):
    if request.method != "GET":
        raise Http404
    # Reuse the existing data contracts only. No presenter requiring an actor,
    # transaction, receipt, FakePort, or persistence is invoked by this view.
    q0 = QuestionCommand(
        request_id="request-synthetic-preview-q0",
        question_id="OES-SYNTH-Q0-PREVIEW",
        expected_version=0,
        original_text="Uma intervenção sintética melhora um desfecho sintético?",
    )
    q1 = QuestionCommand(
        request_id="request-synthetic-preview-q1",
        question_id=q0.question_id,
        expected_version=1,
        original_text=q0.original_text,
        normalized_text="Em adultos sintéticos, a intervenção sintética A, comparada ao controle sintético B, melhora o desfecho sintético C em quatro semanas?",
        justification="Delimitar população, comparação, desfecho e horizonte de tempo para tornar a pergunta mais precisa, preservando o texto original.",
    )
    q2 = Q2RoutingProposal(
        question_id=q1.question_id,
        q1_version=2,
        operational_question=q1.normalized_text,
        population="Adultos sintéticos",
        exposure_or_intervention="Intervenção sintética A",
        comparator="Controle sintético B",
        outcomes=("Desfecho sintético C em quatro semanas",),
        methodological_class="INT",
        depth="N2",
        maintenance="M1",
        routing_justification="Exemplo de proposta para uma pergunta de intervenção; classe, profundidade e manutenção são apenas ilustrativas e dependem de revisão humana.",
    )
    return render(request, "evidence/q0_synthetic_preview.html", {
        "example": {
            "question_id": q0.question_id,
            "original_text": q0.original_text,
            "stage": "q0_draft",
            "version": 1,
        },
        "q0": q0, "q1": q1, "q2": q2,
    })
