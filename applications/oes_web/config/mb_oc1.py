"""Private profile validation only. No network; operational release SOURCE HOLD."""
import re
from urllib.parse import urlsplit

PG_HOST = 'ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech'


def private_configuration(environ):
    if any(environ.get(k) not in (None, '', '0') for k in (
            'OES_PG_A4_ENABLED', 'OES_Q0_MULTI_ALIAS_ENABLED', 'OES_Q0_RECOVERY_READONLY_ENABLED')):
        raise RuntimeError('HOLD: legacy and MB-OC1 profiles cannot be combined')
    from .q0_limits import execution_limits, limited_options
    limits = execution_limits(environ)
    key = environ.get('OES_MB_OC1_SECRET_KEY', '')
    host = environ.get('OES_MB_OC1_HOST', '')
    origin = environ.get('OES_MB_OC1_ORIGIN', '')
    if (len(key) < 50 or key.startswith('development-') or host in ('localhost', 'testserver')
            or not re.fullmatch(r'[A-Za-z0-9](?:[A-Za-z0-9.-]{0,251}[A-Za-z0-9])?', host)
            or '.' not in host or '..' in host or '*' in host):
        raise RuntimeError('HOLD: incomplete MB-OC1 private configuration')
    try:
        parsed = urlsplit(origin)
        parsed.port  # Validate an explicit port without supplying a default.
        seconds = int(environ.get('OES_MB_OC1_SESSION_SECONDS', ''))
    except (ValueError, TypeError):
        raise RuntimeError('HOLD: invalid MB-OC1 origin/session') from None
    if (parsed.scheme != 'https' or parsed.hostname != host or parsed.username is not None or parsed.password is not None
            or parsed.path or parsed.query or parsed.fragment or seconds <= 0
            or environ.get('OES_MB_OC1_PG_HOST') != PG_HOST):
        raise RuntimeError('HOLD: incompatible MB-OC1 origin/database')
    tls = environ.get('OES_MB_OC1_TLS_TERMINATION')
    if tls not in ('wsgi', 'trusted_proxy'):
        raise RuntimeError('HOLD: MB-OC1 TLS termination must be explicit')
    names = ['OES_MB_OC1_AUTH_PASSWORD', 'OES_MB_OC1_READER_PASSWORD', 'OES_MB_OC1_WRITER_PASSWORD']
    passwords = [environ.get(n, '') for n in names]
    if any(not isinstance(p, str) or not p for p in passwords) or len(set(passwords)) != len(passwords):
        raise RuntimeError('HOLD: MB-OC1 credentials must be present and segregated')
    def database(user, password, options):
        return {'ENGINE': 'django.db.backends.postgresql', 'NAME': 'oes_sandbox',
                'HOST': PG_HOST, 'PORT': '5432', 'USER': user, 'PASSWORD': password,
                'OPTIONS': limited_options({'sslmode': 'require', 'options': options}, limits), 'CONN_MAX_AGE': 0,
                'ATOMIC_REQUESTS': False}
    databases = {'default': database('oes_auth_trial_login', passwords[0],
                    '-c search_path=django_auth,public'),
                 'oes_synthetic_reader': database('oes_pg_a4_reader', passwords[1], '-c default_transaction_read_only=on')}
    databases['oes_q0_writer'] = database('oes_qprep_login', passwords[2], '')
    return dict(DEBUG=False, SECRET_KEY=key, SECRET_KEY_FALLBACKS=[], ALLOWED_HOSTS=[host],
        CSRF_TRUSTED_ORIGINS=[origin], SECURE_SSL_REDIRECT=True,
        X_FRAME_OPTIONS='DENY', SECURE_CONTENT_TYPE_NOSNIFF=True, SECURE_REFERRER_POLICY='same-origin',
        SECURE_PROXY_SSL_HEADER=('HTTP_X_FORWARDED_PROTO', 'https') if tls == 'trusted_proxy' else None,
        SESSION_COOKIE_SECURE=True, SESSION_COOKIE_HTTPONLY=True, SESSION_COOKIE_SAMESITE='Lax',
        SESSION_COOKIE_NAME='oes_mb_oc1_session', SESSION_COOKIE_PATH='/', SESSION_COOKIE_DOMAIN=None,
        SESSION_COOKIE_AGE=seconds, SESSION_SAVE_EVERY_REQUEST=False,
        CSRF_COOKIE_SECURE=True, CSRF_COOKIE_HTTPONLY=True, CSRF_COOKIE_SAMESITE='Lax', CSRF_USE_SESSIONS=False,
        SESSION_ENGINE='django.contrib.sessions.backends.db',
        DATABASES=databases, MB_OC1_CONFIGURED=True,
        ROOT_URLCONF='config.urls_mb_oc1',
        LOGGING={'version': 1, 'disable_existing_loggers': False,
            'handlers': {'mb_oc1_console': {'class': 'logging.StreamHandler'}},
            'loggers': {'evidence.question_orm_q0_connected_recipe_dormant':
                {'handlers': ['mb_oc1_console'], 'level': 'INFO', 'propagate': False}}},
        LOGIN_URL='/accounts/login/', LOGIN_REDIRECT_URL='/questions/q0/register/', LOGOUT_REDIRECT_URL='/accounts/login/')


def _require_release():
    # The MB-OC1.3 decision and reviewed source activation are still absent.
    from evidence.question_preparation import PreparationHold
    raise PreparationHold('HOLD: MB-OC1 operational release not authorized')


def require_mb_oc1():
    _require_release()
    from django.conf import settings
    from evidence.question_preparation import PreparationHold
    if (settings.DEBUG or getattr(settings, 'MB_OC1_CONFIGURED', False) is not True
            or getattr(settings, 'MB_OC1_ROLE', None) is not None
            or settings.ROOT_URLCONF != 'config.urls_mb_oc1'
            or settings.SESSION_ENGINE != 'django.contrib.sessions.backends.db'
            or set(settings.DATABASES) != {'default', 'oes_q0_writer', 'oes_synthetic_reader'}):
        raise PreparationHold('HOLD: MB-OC1 private application unavailable')
