"""GET-only illustrative Q0 preparation preview; no writer, database or real user."""
from django.http import Http404
from django.shortcuts import render

def q0_synthetic_preview(request):
    if request.method != "GET":
        raise Http404
    return render(request, "evidence/q0_synthetic_preview.html", {
        "example": {
            "question_id": "OES-SYNTH-Q0-PREVIEW",
            "original_text": "Qual é a pergunta sintética para demonstrar a preparação?",
            "stage": "q0_draft",
            "version": 1,
        },
    })
