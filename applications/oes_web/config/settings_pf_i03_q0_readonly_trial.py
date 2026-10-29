"""Opt-in single-session PF-I03 scientific catalog probe; no ORM writer."""
import os
from .settings_pf_i03_q0_scientific_dormant import *  # noqa: F401,F403

if os.environ.get("OES_PF_I03_Q0_READONLY_OPT_IN") != "1":
    raise RuntimeError("HOLD: nominal PF-I03 readonly opt-in absent")
host = os.environ.get("OES_PF_I03_Q0_HOST", "")
password = os.environ.get("OES_PF_I03_Q0_PASSWORD", "")
if host != "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech" or not password:
    raise RuntimeError("HOLD: approved host or disposable credential absent")

DATABASES[PF_I03_SCIENTIFIC_ALIAS] = {
    "ENGINE": "django.db.backends.postgresql",
    "NAME": PF_I03_EXPECTED_DATABASE,
    "USER": PF_I03_EXPECTED_ROLE,
    "PASSWORD": password,
    "HOST": host,
    "PORT": "5432",
    "OPTIONS": {
        "sslmode": "require",
        "options": "-c default_transaction_read_only=on -c search_path=core,investigation,public",
    },
    "CONN_MAX_AGE": 0,
}
