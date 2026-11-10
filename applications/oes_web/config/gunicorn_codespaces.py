"""Manual configuration only; loading this file never imports Django or connects."""
import os
from pathlib import Path
from config.mb_oc1 import private_configuration

# Reuse the pure validator; no real values or defaults are supplied here.
private_configuration(os.environ)

def _positive(name):
    value = os.environ.get(name, '')
    if not value.isascii() or not value.isdecimal() or len(value) > 9 or int(value) <= 0:
        raise RuntimeError('HOLD: explicit positive Codespaces execution budget required')
    return int(value)

workers = _positive('OES_CODESPACES_WORKERS')
timeout = _positive('OES_CODESPACES_HTTP_TIMEOUT_SECONDS')
if workers * 3 > _positive('OES_CODESPACES_PG_CONNECTION_BUDGET'):
    raise RuntimeError('HOLD: insufficient approved PostgreSQL connection budget')

chdir = str(Path(__file__).resolve().parents[1])
wsgi_app = 'config.wsgi:application'
raw_env = ['DJANGO_SETTINGS_MODULE=config.settings_mb_oc1']
bind = '127.0.0.1:8000'
worker_class = 'sync'
threads = 1
preload_app = False
reload = False
daemon = False
# Do not infer trust from loopback or accept arbitrary forwarded schemes.
forwarded_allow_ips = ''
secure_scheme_headers = {}
accesslog = None
errorlog = '-'
capture_output = False
