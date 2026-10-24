from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = "development-only-not-for-deployment"
DEBUG = True
ALLOWED_HOSTS = ["127.0.0.1", "localhost", "testserver"]
ROOT_URLCONF = "config.urls"
INSTALLED_APPS = ["django.contrib.staticfiles", "evidence"]
MIDDLEWARE = ["django.middleware.common.CommonMiddleware"]
TEMPLATES = [{"BACKEND": "django.template.backends.django.DjangoTemplates", "DIRS": [], "APP_DIRS": True, "OPTIONS": {}}]
DATABASES = {}
# Experimental PG-A4: off unless explicitly enabled; never use owner credentials.
import os
if os.getenv("OES_PG_A4_ENABLED") == "1":
    if not os.getenv("OES_PG_A4_HOST") or not os.getenv("OES_PG_A4_PASSWORD"):
        raise RuntimeError("PG-A4 host and password are required")
    if os.environ["OES_PG_A4_HOST"] not in ("ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech", "ep-wispy-dream-b6021bw0-pooler.c-2.sa-east-1.aws.neon.tech"):
        raise RuntimeError("PG-A4 requires the approved synthetic endpoint")
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
STATIC_URL = "/static/"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
