"""Unconfigured by default; source release remains closed even with full config."""
import os
from .mb_oc1 import private_configuration
_private = private_configuration(os.environ)
from .settings import *  # noqa: E402,F401,F403
globals().update(_private)
del _private
MIDDLEWARE = [*MIDDLEWARE, "django.middleware.clickjacking.XFrameOptionsMiddleware"]
