from django.http import Http404
from django.shortcuts import render
from .services import get_signal
from .presentation import build_presentation

def detail(request, nct):
    if request.method != "GET":
        raise Http404
    signal = get_signal(nct)
    if signal is None:
        raise Http404
    return render(request, "evidence/signal_detail.html",
                  {"signal": signal, **build_presentation(signal)})
