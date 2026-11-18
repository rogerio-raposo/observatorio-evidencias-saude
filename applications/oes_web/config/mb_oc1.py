"""Private experimental profile; no network, release closed by default."""
import re
from urllib.parse import urlsplit

PG_HOST = 'ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech'


def private_configuration(environ):
    if any(environ.get(k) not in (None, '', '0') for k in (
            'OES_PG_A4_ENABLED', 'OES_Q0_MULTI_ALIAS_ENABLED', 'OES_Q0_RECOVERY_READONLY_ENABLED')):
        raise RuntimeError('HOLD: legacy and MB-OC1 profiles cannot be combined')
    release_mode = environ.get('OES_MB_OC1_RELEASE_MODE', 'HOLD')
    if release_mode not in ('HOLD', 'PRIVATE_SYNTHETIC_Q0'):
        raise RuntimeError('HOLD: invalid MB-OC1 experimental release mode')
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
    # Experimental Codespaces candidate (Doc 362, §5.1), not proxy attestation
    # or operational authorization. Unset/0 preserves conventional Host; 1 opts in.
    forwarded_host = environ.get('OES_CODESPACES_USE_X_FORWARDED_HOST', '0')
    if forwarded_host not in ('0', '1'):
        raise RuntimeError('HOLD: invalid Codespaces forwarded-host selection')
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
        USE_X_FORWARDED_HOST=forwarded_host == '1', USE_X_FORWARDED_PORT=False,
        X_FRAME_OPTIONS='DENY', SECURE_CONTENT_TYPE_NOSNIFF=True, SECURE_REFERRER_POLICY='same-origin',
        SECURE_PROXY_SSL_HEADER=('HTTP_X_FORWARDED_PROTO', 'https') if tls == 'trusted_proxy' else None,
        SESSION_COOKIE_SECURE=True, SESSION_COOKIE_HTTPONLY=True, SESSION_COOKIE_SAMESITE='Lax',
        SESSION_COOKIE_NAME='oes_mb_oc1_session', SESSION_COOKIE_PATH='/', SESSION_COOKIE_DOMAIN=None,
        SESSION_COOKIE_AGE=seconds, SESSION_SAVE_EVERY_REQUEST=False,
        CSRF_COOKIE_SECURE=True, CSRF_COOKIE_HTTPONLY=True, CSRF_COOKIE_SAMESITE='Lax', CSRF_USE_SESSIONS=False,
        SESSION_ENGINE='django.contrib.sessions.backends.db',
        DATABASES=databases, MB_OC1_CONFIGURED=True, MB_OC1_RELEASE_MODE=release_mode,
        ROOT_URLCONF='config.urls_mb_oc1',
        LOGGING={'version': 1, 'disable_existing_loggers': False,
            'handlers': {'mb_oc1_console': {'class': 'logging.StreamHandler'}},
            'loggers': {'evidence.question_orm_q0_connected_recipe_dormant':
                {'handlers': ['mb_oc1_console'], 'level': 'INFO', 'propagate': False}}},
        LOGIN_URL='/accounts/login/', LOGIN_REDIRECT_URL='/questions/q0/register/', LOGOUT_REDIRECT_URL='/accounts/login/')


def _require_release():
    # Configuration capability, not operational authorization. All callers use
    # require_mb_oc1(), which also checks the private application profile.
    from django.conf import settings
    from evidence.question_preparation import PreparationHold
    if getattr(settings, 'MB_OC1_RELEASE_MODE', 'HOLD') != 'PRIVATE_SYNTHETIC_Q0':
        raise PreparationHold('HOLD: MB-OC1 experimental release not selected')


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
