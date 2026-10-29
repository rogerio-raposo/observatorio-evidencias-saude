from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = "development-only-not-for-deployment"
DEBUG = True
ALLOWED_HOSTS = ["127.0.0.1", "localhost", "testserver"]
ROOT_URLCONF = "config.urls"
INSTALLED_APPS = ["django.contrib.auth", "django.contrib.contenttypes", "django.contrib.sessions", "django.contrib.staticfiles", "evidence"]
MIDDLEWARE = ["django.middleware.security.SecurityMiddleware", "django.contrib.sessions.middleware.SessionMiddleware", "django.middleware.common.CommonMiddleware", "django.middleware.csrf.CsrfViewMiddleware", "django.contrib.auth.middleware.AuthenticationMiddleware"]
TEMPLATES = [{"BACKEND": "django.template.backends.django.DjangoTemplates", "DIRS": [], "APP_DIRS": True, "OPTIONS": {}}]
DATABASES = {}
# Experimental PG-A4: off unless explicitly enabled; never use owner credentials.
import os
if os.getenv("OES_PG_A4_ENABLED") == "1":
    if not os.getenv("OES_PG_A4_HOST") or not os.getenv("OES_PG_A4_PASSWORD"):
        raise RuntimeError("PG-A4 host and password are required")
    if os.environ["OES_PG_A4_HOST"] not in ("ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech", "ep-wispy-dream-b6021bw0-pooler.c-2.sa-east-1.aws.neon.tech"):
        raise RuntimeError("PG-A4 requires the approved synthetic endpoint")
    # Django requires a default alias even when only a named connection is used.
    # Dummy engine never opens a database; the experimental reader is explicit.
    DATABASES["default"] = {"ENGINE": "django.db.backends.dummy"}
    DATABASES["oes_synthetic_reader"] = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_pg_a4_reader",
        "PASSWORD": os.environ["OES_PG_A4_PASSWORD"],
        "HOST": os.environ["OES_PG_A4_HOST"],
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require", "options": "-c default_transaction_read_only=on"},
        "CONN_MAX_AGE": 0,
    }
# Marco B: explicit, dormant-by-default three-alias configuration for offline review.
# No writer connection is initiated here. This flag is NOT an execution gate.
if os.getenv("OES_Q0_MULTI_ALIAS_ENABLED") == "1":
    if os.getenv("OES_PG_A4_ENABLED") != "1":
        raise RuntimeError("HOLD: independent PG-A4 reader must be configured")
    _host = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
    _required = ("OES_Q0_AUTH_PASSWORD", "OES_Q0_WRITER_PASSWORD")
    if any(not os.getenv(name) for name in _required):
        raise RuntimeError("HOLD: separate auth and writer credentials required")
    if os.environ["OES_PG_A4_HOST"] != _host:
        raise RuntimeError("HOLD: direct same-branch endpoint required")
    if len({os.environ["OES_Q0_AUTH_PASSWORD"],
            os.environ["OES_Q0_WRITER_PASSWORD"],
            os.environ["OES_PG_A4_PASSWORD"]}) != 3:
        raise RuntimeError("HOLD: database identities require distinct credentials")
    DATABASES["default"] = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_auth_trial_login",
        "PASSWORD": os.environ["OES_Q0_AUTH_PASSWORD"],
        "HOST": _host,
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require"},
        "CONN_MAX_AGE": 0,
    }
    DATABASES["oes_q0_writer"] = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_qprep_login",
        "PASSWORD": os.environ["OES_Q0_WRITER_PASSWORD"],
        "HOST": _host,
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require"},
        "CONN_MAX_AGE": 0,
    }

STATIC_URL = "/static/"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# PF-I02-I01-A: offline scaffold only. No database-backed login or user creation.
# DB-backed session and authentication operations remain unavailable until gated.
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SAMESITE = "Lax"
# Deployment must override development-only settings through a separate gate.
