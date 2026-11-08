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


def _prepare_q0_registration_response(request):
    """Unrouted F1 response adapter; operational methods still stop at 423."""
    from .forms import prepare_q0_submission
    status, context = prepare_q0_submission(user=request.user, data=request.POST)
    context["offline_preparation"] = True
    return render(request, "evidence/q0_registration.html", context, status=status)


def q1_proposal(request):
    """Read-only form scaffold. No operational Q1 submission/backend."""
    from django.http import HttpResponse
    if request.method != "GET":
        return HttpResponse("HOLD: proposta Q1 bloqueada; nenhuma escrita foi iniciada.", status=423)
    from .forms import Q1ProposalForm, Q0_MESSAGES
    from .preparation_auth import require_question_preparer
    from preparer_identity.resolver import persisted_preparer_actor_id
    from django.core.exceptions import PermissionDenied
    context = {"form": None}
    try:
        require_question_preparer(request.user)
        persisted_preparer_actor_id(request.user)
    except PermissionDenied:
        context["result_message"] = Q0_MESSAGES["unauthorized"]
        return render(request, "evidence/q1_proposal.html", context, status=403)
    except Exception:
        context["result_message"] = Q0_MESSAGES["identity"]
        return render(request, "evidence/q1_proposal.html", context, status=503)
    context["form"] = Q1ProposalForm()
    return render(request, "evidence/q1_proposal.html", context)


def q2_routing(request):
    """Presentation GET only; no Q2 submission or backend access from HTTP."""
    from django.http import HttpResponse
    if request.method != "GET":
        return HttpResponse("HOLD: proposta Q2/roteamento bloqueada; nenhuma escrita foi iniciada.", status=423)
    from django.core.exceptions import PermissionDenied
    from .forms import Q2RoutingForm, Q0_MESSAGES
    from .preparation_auth import require_question_preparer
    from preparer_identity.resolver import persisted_preparer_actor_id
    context = {"form": None}
    try:
        require_question_preparer(request.user)
        persisted_preparer_actor_id(request.user)
    except PermissionDenied:
        context["result_message"] = Q0_MESSAGES["unauthorized"]
        return render(request, "evidence/q2_routing.html", context, status=403)
    except Exception:
        context["result_message"] = Q0_MESSAGES["identity"]
        return render(request, "evidence/q2_routing.html", context, status=503)
    context["form"] = Q2RoutingForm()
    return render(request, "evidence/q2_routing.html", context)
