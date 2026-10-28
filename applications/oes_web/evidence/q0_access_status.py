"""GET-only diagnostic: authorization does not enable Q0 writing."""
from django.core.exceptions import PermissionDenied
from django.db import DatabaseError
from django.http import Http404, JsonResponse
from .preparation_auth import require_question_preparer

def q0_access_status(request):
    if request.method != "GET":
        raise Http404
    try:
        require_question_preparer(request.user)
    except PermissionDenied:
        return JsonResponse({"status": "HOLD", "q0_write_enabled": False}, status=403)
    except (DatabaseError, RuntimeError):
        return JsonResponse({"status": "HOLD", "q0_write_enabled": False}, status=503)
    return JsonResponse({"status": "AUTHORIZED_SYNTHETIC_SCOPE_ONLY", "q0_write_enabled": False})
