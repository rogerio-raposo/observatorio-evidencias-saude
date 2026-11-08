from django.http import Http404
from django.shortcuts import render
from .services import get_signal, list_signals
from .presentation import build_presentation, IDENTITY_LABELS

def catalog(request):
    if request.method != "GET":
        raise Http404
    signals = list_signals()
    entries = tuple({"signal": signal,
                     "identity_label": IDENTITY_LABELS[signal.identity_state]}
                    for signal in signals)
    return render(request, "evidence/signal_catalog.html", {"entries": entries})

def detail(request, nct):
    if request.method != "GET":
        raise Http404
    signal = get_signal(nct)
    if signal is None:
        raise Http404
    return render(request, "evidence/signal_detail.html",
                  {"signal": signal, **build_presentation(signal)})


def synthetic_path(request):
    """Static, separately labelled synthetic receipt; never invoke P1-A3."""
    if request.method != "GET":
        raise Http404
    from .p2_presentation import load_example, SyntheticPresentationHold
    try:
        receipt = load_example()
    except SyntheticPresentationHold:
        return render(request, "evidence/synthetic_path.html", {"hold": True}, status=503)
    return render(request, "evidence/synthetic_path.html", {"receipt": receipt, "hold": False})

def evidence_sheet_n2(request, product_id):
    """Read-only restricted historical sheet. Never opens Investigation."""
    if request.method != "GET":
        raise Http404
    if product_id != "OES-P-2026-000401":
        raise Http404
    from .n2_historical import load_historical_n2, present_markdown, N2Hold
    from django.utils.safestring import mark_safe
    try:
        body = load_historical_n2()
    except N2Hold:
        return render(request, "evidence/evidence_sheet_n2.html", {"hold": True}, status=503)
    return render(request, "evidence/evidence_sheet_n2.html", {"body_html": mark_safe(present_markdown(body)), "hold": False})


def q0_registration(request):
    """Source-held HTTP boundary: reject writes before identity/form/backend work."""
    from django.http import HttpResponse
    if request.method != "GET":
        return HttpResponse(
            "HOLD: registro Q0 bloqueado. Nenhuma escrita foi iniciada; não reenvie automaticamente.",
            status=423, content_type="text/plain; charset=utf-8",
        )
    from django.core.exceptions import PermissionDenied
    from .preparation_auth import require_question_preparer
    from preparer_identity.resolver import persisted_preparer_actor_id
    from .forms import Q0RegistrationForm, Q0_MESSAGES
    context = {"messages": Q0_MESSAGES, "form": None}
    try:
        require_question_preparer(request.user)
    except PermissionDenied:
        context["access_message"] = Q0_MESSAGES["unauthorized"]
        return render(request, "evidence/q0_registration.html", context, status=403)
    except Exception:
        context["access_message"] = Q0_MESSAGES["identity"]
        return render(request, "evidence/q0_registration.html", context, status=503)
    try:
        persisted_preparer_actor_id(request.user)
    except Exception:
        context["access_message"] = Q0_MESSAGES["identity"]
        return render(request, "evidence/q0_registration.html", context, status=503)
    # No request/session identifier is generated on GET, errors or reloads.
    context["form"] = Q0RegistrationForm()
    return render(request, "evidence/q0_registration.html", context)
