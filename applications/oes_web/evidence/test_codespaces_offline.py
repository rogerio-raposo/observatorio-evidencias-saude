"""Configuration tests only; no Codespace, WSGI startup or PostgreSQL."""
import json
import os
from pathlib import Path
import runpy
from unittest.mock import patch
from django.test import SimpleTestCase
from evidence import test_mb_oc1_offline as fixture

ROOT=Path(__file__).resolve().parents[3]
CONFIG=ROOT/'applications/oes_web/config/gunicorn_codespaces.py'

class CodespacesPreparationTests(SimpleTestCase):
    def env(self):
        return {**fixture.PrivateProfileTests().env(),'OES_CODESPACES_WORKERS':'1',
                'OES_CODESPACES_HTTP_TIMEOUT_SECONDS':'30','OES_CODESPACES_PG_CONNECTION_BUDGET':'3'}

    def load(self,env):
        with patch.dict(os.environ,env,clear=True),patch('django.db.backends.postgresql.base.DatabaseWrapper.get_new_connection',side_effect=AssertionError('connection forbidden')):
            return runpy.run_path(str(CONFIG))

    def test_devcontainer_no_automatic_execution_forwarding_or_secrets(self):
        c=json.loads((ROOT/'.devcontainer/devcontainer.json').read_text())
        self.assertEqual(set(c),{'name','image','hostRequirements','workspaceFolder','portsAttributes','otherPortsAttributes','customizations'})
        self.assertEqual(c['image'],'mcr.microsoft.com/devcontainers/python:1-3.12-bookworm')
        self.assertEqual(c['hostRequirements'],{'cpus':2})
        self.assertTrue(c['workspaceFolder'].endswith('/applications/oes_web'))
        self.assertEqual(c['portsAttributes']['8000']['onAutoForward'],'ignore')
        self.assertEqual(c['otherPortsAttributes'],{'onAutoForward':'ignore'})
        self.assertFalse(c['customizations']['vscode']['settings']['remote.autoForwardPorts'])

    def test_wsgi_manual_and_transport_fail_closed(self):
        c=self.load(self.env())
        self.assertEqual(c['wsgi_app'],'config.wsgi:application')
        self.assertEqual(c['raw_env'],['DJANGO_SETTINGS_MODULE=config.settings_mb_oc1'])
        self.assertEqual(c['bind'],'127.0.0.1:8000')
        self.assertEqual(c['forwarded_allow_ips'],'')
        self.assertEqual(c['secure_scheme_headers'],{})
        self.assertEqual(c['worker_class'],'sync')
        for k in ('preload_app','reload','daemon','capture_output'):self.assertFalse(c[k])
        self.assertIsNone(c['accesslog'])

    def test_essential_values_and_capacity_required(self):
        for name in self.env():
            env=self.env();del env[name]
            with self.subTest(name=name),self.assertRaises(RuntimeError):self.load(env)
        for mutation in ({'OES_MB_OC1_ORIGIN':'http://oes.private.test'},
                         {'OES_CODESPACES_WORKERS':'0'},{'OES_CODESPACES_HTTP_TIMEOUT_SECONDS':'-1'},
                         {'OES_CODESPACES_WORKERS':'2'},{'OES_CODESPACES_PG_CONNECTION_BUDGET':'0'}):
            with self.subTest(mutation=mutation),self.assertRaises(RuntimeError):self.load({**self.env(),**mutation})

    def test_dependency_ranges(self):
        lines=(ROOT/'applications/oes_web/requirements.txt').read_text().splitlines()
        for requirement in ('Django>=5.2,<5.3','psycopg[binary]>=3.2,<4','gunicorn>=23,<24'):
            self.assertIn(requirement,lines)


class HttpsHostCsrfTests(SimpleTestCase):
    """Consumer-side HTTP contract in memory; never attests proxy provenance.

    Reuse the private builder, native middleware and actual held routes.
    DATABASES isn't installed: any unexpected DB access fails SimpleTestCase.
    """
    def setUp(self):
        from config.mb_oc1 import private_configuration
        self.environment = fixture.PrivateProfileTests().env()
        self.environment['OES_MB_OC1_TLS_TERMINATION'] = 'trusted_proxy'
        self.configuration = private_configuration(self.environment)
        http = {k: v for k, v in self.configuration.items() if k not in ('DATABASES', 'LOGGING')}
        self.enterContext(self.settings(**http))
        self.host = self.environment['OES_MB_OC1_HOST']
        self.origin = self.environment['OES_MB_OC1_ORIGIN']

    def request(self, *, host=None, secure=False, proto=None, **headers):
        from django.test import RequestFactory
        if proto is not None:
            headers['HTTP_X_FORWARDED_PROTO'] = proto
        return RequestFactory().get('/questions/q0/review/?view=synthetic',
            secure=secure, HTTP_HOST=host or self.host, **headers)

    def csrf_client(self):
        from django.conf import settings
        from django.http import HttpResponse
        from django.middleware.csrf import CsrfViewMiddleware, get_token
        from django.test import Client
        request = self.request(proto='https')
        token = get_token(request)
        response = CsrfViewMiddleware(lambda request: HttpResponse()).process_response(request, HttpResponse())
        client = Client(enforce_csrf_checks=True, HTTP_HOST=self.host)
        client.cookies[settings.CSRF_COOKIE_NAME] = response.cookies[settings.CSRF_COOKIE_NAME].value
        return client, token, response

    def test_proxy_selection_is_explicit_and_does_not_enable_release(self):
        from config.mb_oc1 import private_configuration, _require_release
        from evidence.question_preparation import PreparationHold
        for mode, expected in (('wsgi', None), ('trusted_proxy', ('HTTP_X_FORWARDED_PROTO', 'https'))):
            c = private_configuration({**self.environment, 'OES_MB_OC1_TLS_TERMINATION': mode})
            self.assertEqual(c['SECURE_PROXY_SSL_HEADER'], expected)
            with self.settings(SECURE_PROXY_SSL_HEADER=expected), self.assertRaises(PreparationHold):
                _require_release()
        for mode in ('', 'automatic', '*'):
            with self.assertRaises(RuntimeError):
                private_configuration({**self.environment, 'OES_MB_OC1_TLS_TERMINATION': mode})

    def test_is_secure_uses_first_stripped_component_or_wsgi_fallback(self):
        # A header overrides WSGI when configured, even if the peer is untrusted.
        for secure, proto, expected in (
                (False, None, False), (True, None, True),
                (False, 'https', True), (False, 'http', False),
                (True, 'http', False), (True, '', False),
                (False, 'https,http', True), (False, ' http , https ', False),
                (False, ' https , http ', True), (False, 'HTTPS', False)):
            with self.subTest(wsgi_secure=secure, proto=proto):
                self.assertEqual(self.request(secure=secure, proto=proto).is_secure(), expected)
        with self.settings(SECURE_PROXY_SSL_HEADER=None):
            self.assertFalse(self.request(proto='https').is_secure())
            self.assertTrue(self.request(secure=True, proto='http').is_secure())

    def test_forwarded_scheme_has_no_native_peer_authentication(self):
        for peer in ('127.0.0.1', '203.0.113.10'):
            self.assertTrue(self.request(proto='https', REMOTE_ADDR=peer).is_secure())
        # This deliberately demonstrates why offline acceptance isn't ingress sanitization.

    def test_http_redirect_preserves_nominal_authority_then_stops_when_secure(self):
        from django.test import Client
        client = Client(enforce_csrf_checks=True, HTTP_HOST=self.host)
        path = '/accounts/login/?next=%2Fquestions%2Fq0%2Fregister%2F'
        for proto in (None, 'http', 'http,https'):
            headers = {'HTTP_X_FORWARDED_HOST': 'unexpected.invalid', 'HTTP_X_FORWARDED_PORT': '9999'}
            if proto is not None:
                headers['HTTP_X_FORWARDED_PROTO'] = proto
            response = client.get(path, **headers)
            self.assertEqual(response.status_code, 301)
            self.assertEqual(response['Location'], self.origin + path)
            # Model the next original HTTPS request; backend transport remains HTTP.
            final = client.get(path, HTTP_X_FORWARDED_PROTO='https')
            self.assertEqual(final.status_code, 423)
            self.assertNotIn('Location', final)
        # Missing/wrong forwarded scheme at an HTTPS ingress would redirect again.
        self.assertEqual(client.get(path, HTTP_X_FORWARDED_PROTO='http').status_code, 301)

    def test_nominal_host_and_absolute_urls_ignore_forwarded_host_and_port(self):
        from django.conf import settings
        self.assertFalse(settings.USE_X_FORWARDED_HOST)
        self.assertFalse(settings.USE_X_FORWARDED_PORT)
        self.assertEqual(settings.ALLOWED_HOSTS, [self.host])
        self.assertEqual(settings.CSRF_TRUSTED_ORIGINS, [self.origin])
        for authority in (self.host, self.host.upper() + ':443', self.host + '.'):
            with self.subTest(authority=authority):
                r = self.request(host=authority, proto='https',
                    HTTP_X_FORWARDED_HOST='unexpected.invalid', HTTP_X_FORWARDED_PORT='9999')
                self.assertEqual(r.get_host(), authority)  # Native validation preserves representation.
                self.assertEqual(r.build_absolute_uri(), 'https://' + authority + r.get_full_path())
                self.assertEqual(r.get_port(), '80')  # Backend SERVER_PORT, not X-Forwarded-Port.

    def test_unexpected_host_is_rejected_even_if_forwarded_host_is_approved(self):
        from django.core.exceptions import DisallowedHost
        from django.test import Client
        for authority in ('unexpected.invalid', self.host + '.unexpected.invalid', self.host + ',unexpected.invalid'):
            with self.subTest(authority=authority):
                r = self.request(host=authority, proto='https', HTTP_X_FORWARDED_HOST=self.host)
                with self.assertRaises(DisallowedHost):
                    r.get_host()
                with self.assertRaises(DisallowedHost):
                    r.build_absolute_uri()
                response = Client().get('/accounts/login/', HTTP_HOST=authority,
                    HTTP_X_FORWARDED_PROTO='https', HTTP_X_FORWARDED_HOST=self.host)
                self.assertEqual(response.status_code, 400)

    def test_forwarded_host_selection_is_explicit_reversible_and_only_configuration(self):
        from config.mb_oc1 import private_configuration, _require_release
        from evidence.question_preparation import PreparationHold
        name = 'OES_CODESPACES_USE_X_FORWARDED_HOST'
        for mode in ('wsgi', 'trusted_proxy'):
            baseline = private_configuration({**self.environment, 'OES_MB_OC1_TLS_TERMINATION': mode})
            self.assertFalse(baseline['USE_X_FORWARDED_HOST'])
            for value in ('1', '0', '1', '0'):
                with self.subTest(mode=mode, value=value):
                    candidate = private_configuration({**self.environment,
                        'OES_MB_OC1_TLS_TERMINATION': mode, name: value})
                    self.assertEqual(candidate, {**baseline, 'USE_X_FORWARDED_HOST': value == '1'})
                    self.assertFalse(candidate['USE_X_FORWARDED_PORT'])
                    # Full candidate config cannot release the actual source gate.
                    http = {k: v for k, v in candidate.items() if k not in ('DATABASES', 'LOGGING')}
                    with self.settings(**http), self.assertRaises(PreparationHold):
                        _require_release()
        for value in ('', 'true', 'False', 'automatic', '2', ' 1 ', None, True, 1):
            with self.subTest(invalid=value), self.assertRaises(RuntimeError):
                private_configuration({**self.environment, name: value})

    def test_selected_forwarded_host_validates_nominal_authority_and_absolute_urls(self):
        from django.core.exceptions import DisallowedHost
        from django.test import Client
        from config.mb_oc1 import private_configuration
        c = private_configuration({**self.environment, 'OES_CODESPACES_USE_X_FORWARDED_HOST': '1'})
        with self.settings(USE_X_FORWARDED_HOST=c['USE_X_FORWARDED_HOST']):
            request = self.request(host='backend.invalid:8000', proto='https',
                HTTP_X_FORWARDED_HOST=self.host, HTTP_X_FORWARDED_PORT='9999')
            self.assertEqual(request.get_host(), self.host)
            self.assertEqual(request.build_absolute_uri(), self.origin + request.get_full_path())
            self.assertEqual(request.get_port(), '80')
            for authority in ('unexpected.invalid', self.host + '.unexpected.invalid',
                    self.host + ',unexpected.invalid', 'unexpected.invalid,' + self.host, ''):
                with self.subTest(authority=authority):
                    # Even an approved conventional Host cannot override a bad forwarded Host.
                    request = self.request(proto='https', HTTP_X_FORWARDED_HOST=authority)
                    with self.assertRaises(DisallowedHost):
                        request.get_host()
                    with self.assertRaises(DisallowedHost):
                        request.build_absolute_uri()
                    response = Client().get('/accounts/login/', HTTP_HOST=self.host,
                        HTTP_X_FORWARDED_PROTO='https', HTTP_X_FORWARDED_HOST=authority)
                    self.assertEqual(response.status_code, 400)
            # Native Django falls back only when the header is absent, validating Host too.
            self.assertEqual(self.request(proto='https').get_host(), self.host)
            with self.assertRaises(DisallowedHost):
                self.request(host='backend.invalid:8000', proto='https').get_host()
        with self.assertRaises(DisallowedHost):
            self.request(host='backend.invalid:8000', proto='https', HTTP_X_FORWARDED_HOST=self.host).get_host()

    def test_selected_forwarded_host_redirects_to_nominal_https_without_loop(self):
        from django.test import Client
        with self.settings(USE_X_FORWARDED_HOST=True):
            client = Client(HTTP_HOST='backend.invalid:8000', HTTP_X_FORWARDED_HOST=self.host)
            path = '/accounts/login/?next=%2Fquestions%2Fq0%2Fregister%2F'
            response = client.get(path, HTTP_X_FORWARDED_PROTO='http')
            self.assertEqual(response.status_code, 301)
            self.assertEqual(response['Location'], self.origin + path)
            final = client.get(path, HTTP_X_FORWARDED_PROTO='https')
            self.assertEqual(final.status_code, 423)
            self.assertNotIn('Location', final)

    def test_selected_forwarded_host_csrf_and_mutating_routes_remain_held(self):
        from config.mb_oc1 import _require_release
        with self.settings(USE_X_FORWARDED_HOST=True):
            client, token, _ = self.csrf_client()
            client.defaults.update(HTTP_HOST='backend.invalid:8000',
                HTTP_X_FORWARDED_HOST=self.host, HTTP_X_FORWARDED_PROTO='https')
            for headers, value, expected in (
                    ({'HTTP_ORIGIN': self.origin}, token, 423),
                    ({'HTTP_ORIGIN': 'https://backend.invalid:8000'}, token, 403),
                    ({'HTTP_ORIGIN': 'https://unexpected.invalid'}, token, 403),
                    ({'HTTP_ORIGIN': self.origin}, '', 403),
                    ({'HTTP_ORIGIN': self.origin}, 'invalid!', 403),
                    ({'HTTP_REFERER': self.origin + '/accounts/login/'}, token, 423),
                    ({'HTTP_REFERER': 'https://backend.invalid:8000/'}, token, 403),
                    ({}, token, 403)):
                with self.subTest(headers=headers, expected=expected):
                    response = client.post('/questions/q0/register/',
                        {'csrfmiddlewaretoken': value}, **headers)
                    self.assertEqual(response.status_code, expected)
            with patch('config.mb_oc1._require_release', wraps=_require_release) as release, \
                 patch('evidence.forms.prepare_q0_submission', side_effect=AssertionError('writer reached')), \
                 patch('evidence.forms.prepare_q0_reference', side_effect=AssertionError('reader reached')):
                for path in ('/accounts/login/', '/accounts/logout/', '/questions/q0/register/', '/questions/q0/review/'):
                    self.assertEqual(client.post(path, {'csrfmiddlewaretoken': token},
                        HTTP_ORIGIN=self.origin).status_code, 423)
                # The GET-only reference view rejects POST before even consulting release.
                self.assertEqual(release.call_count, 3)

    def test_csrf_origin_and_token_matrix_reaches_only_the_held_view(self):
        from config.mb_oc1 import _require_release
        client, token, _ = self.csrf_client()
        wrong = ('a' if token[0] != 'a' else 'b') + token[1:]
        for origin, value, expected in (
                (self.origin, token, 423), ('https://unexpected.invalid', token, 403),
                ('http://' + self.host, token, 403), ('null', token, 403),
                (self.origin, None, 403), (self.origin, 'invalid!', 403),
                (self.origin, wrong, 403)):
            with self.subTest(origin=origin, token_case=expected):
                data = {} if value is None else {'csrfmiddlewaretoken': value}
                with patch('config.mb_oc1._require_release', wraps=_require_release) as release, \
                     patch('evidence.forms.prepare_q0_submission', side_effect=AssertionError('form/backend reached')):
                    response = client.post('/questions/q0/register/', data,
                        HTTP_X_FORWARDED_PROTO='https', HTTP_ORIGIN=origin)
                self.assertEqual(response.status_code, expected)
                self.assertEqual(release.call_count, int(expected == 423))

    def test_https_referer_is_required_without_origin_and_origin_takes_precedence(self):
        client, token, _ = self.csrf_client()
        for referer, expected in ((None, 403), ('invalid', 403),
                ('http://' + self.host + '/', 403), ('https://unexpected.invalid/', 403),
                (self.origin + '/accounts/login/', 423)):
            with self.subTest(referer=referer):
                headers = {} if referer is None else {'HTTP_REFERER': referer}
                response = client.post('/questions/q0/register/', {'csrfmiddlewaretoken': token},
                    HTTP_X_FORWARDED_PROTO='https', **headers)
                self.assertEqual(response.status_code, expected)
        for origin, referer, expected in ((self.origin, 'https://unexpected.invalid/', 423),
                ('https://unexpected.invalid', self.origin + '/', 403)):
            response = client.post('/questions/q0/register/', {'csrfmiddlewaretoken': token},
                HTTP_X_FORWARDED_PROTO='https', HTTP_ORIGIN=origin, HTTP_REFERER=referer)
            self.assertEqual(response.status_code, expected)

    def test_valid_csrf_keeps_all_private_mutating_routes_at_423(self):
        client, token, _ = self.csrf_client()
        with patch('evidence.forms.prepare_q0_submission', side_effect=AssertionError('writer reached')), \
             patch('evidence.forms.prepare_q0_reference', side_effect=AssertionError('reader reached')):
            for path in ('/accounts/login/', '/accounts/logout/', '/questions/q0/register/', '/questions/q0/review/'):
                with self.subTest(path=path):
                    response = client.post(path, {'csrfmiddlewaretoken': token},
                        HTTP_X_FORWARDED_PROTO='https', HTTP_ORIGIN=self.origin)
                    self.assertEqual(response.status_code, 423)

    def test_csrf_and_session_cookie_flags_from_native_middleware(self):
        from django.conf import settings
        from django.contrib.sessions.middleware import SessionMiddleware
        from django.contrib.sessions.backends.db import SessionStore
        from django.http import HttpResponse
        for forwarded in (False, True):
            with self.subTest(forwarded=forwarded), self.settings(USE_X_FORWARDED_HOST=forwarded):
                _, _, csrf_response = self.csrf_client()
                request = self.request(proto='https', host='backend.invalid:8000' if forwarded else self.host,
                    HTTP_X_FORWARDED_HOST=self.host)
                request.COOKIES[settings.SESSION_COOKIE_NAME] = 'a' * 32
                middleware = SessionMiddleware(lambda request: HttpResponse())
                middleware.process_request(request)
                # Stub only persistence: real cookie emission isn't a DB session proof.
                with patch.object(SessionStore, 'load', return_value={}), patch.object(SessionStore, 'save') as save:
                    request.session['offline'] = True
                    response = middleware.process_response(request, HttpResponse())
                save.assert_called_once()
                for cookie in (csrf_response.cookies[settings.CSRF_COOKIE_NAME], response.cookies[settings.SESSION_COOKIE_NAME]):
                    self.assertTrue(cookie['secure'])
                    self.assertTrue(cookie['httponly'])
                    self.assertEqual(cookie['samesite'], 'Lax')
