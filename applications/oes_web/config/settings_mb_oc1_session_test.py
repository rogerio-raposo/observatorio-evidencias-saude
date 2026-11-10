"""SQLite-only test harness. Not a private/operational profile or release."""
from .settings_auth_session_test import *  # noqa: F401,F403
DATABASES['oes_q0_writer'] = {'ENGINE': 'django.db.backends.dummy'}
DATABASES['oes_synthetic_reader'] = {'ENGINE': 'django.db.backends.dummy'}
DEBUG = False
ALLOWED_HOSTS = ['testserver']
ROOT_URLCONF = 'config.urls_mb_oc1'
MB_OC1_CONFIGURED = True
SESSION_COOKIE_NAME = 'oes_mb_oc1_session'
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_SAVE_EVERY_REQUEST = False
LOGIN_REDIRECT_URL = '/questions/q0/register/'
LOGOUT_REDIRECT_URL = '/accounts/login/'
