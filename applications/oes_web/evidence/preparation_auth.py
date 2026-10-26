"""PF-I02-I01-A: deny-by-default preparer authorization scaffold (offline only)."""
from django.core.exceptions import PermissionDenied

PREPARE_QUESTION_PERMISSION = "evidence.prepare_question"

def require_question_preparer(user):
    """Gate for a future Q0→Q1 service; never grant by superuser/staff alone."""
    if (not getattr(user, "is_authenticated", False)
            or not user.has_perm(PREPARE_QUESTION_PERMISSION)):
        raise PermissionDenied("HOLD: question preparation not authorized")
    return True
