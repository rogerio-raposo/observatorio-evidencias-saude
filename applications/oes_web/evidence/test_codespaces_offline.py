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
