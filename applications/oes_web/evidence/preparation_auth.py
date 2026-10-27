"""PF-I02-I01-A: deny-by-default preparer authorization scaffold (offline only)."""
from django.core.exceptions import PermissionDenied

PREPARE_QUESTION_PERMISSION = "evidence.prepare_question"


def require_question_preparer(user):
    """Only active non-admin users with explicit preparation permission may proceed."""
    if (getattr(user, "is_authenticated", False) is not True
            or getattr(user, "is_active", False) is not True
            or getattr(user, "is_staff", True) is not False
            or getattr(user, "is_superuser", True) is not False
            or not callable(getattr(user, "has_perm", None))
            or user.has_perm(PREPARE_QUESTION_PERMISSION) is not True):
        raise PermissionDenied("HOLD: question preparation not authorized")
    return True
