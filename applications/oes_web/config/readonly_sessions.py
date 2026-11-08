"""Django DB sessions with read-only semantics, not another identity backend."""
from django.contrib.sessions.backends.db import SessionStore as DatabaseSessionStore
from django.contrib.sessions.middleware import SessionMiddleware
from django.http import HttpResponse
from django.utils.cache import patch_vary_headers


class ReadOnlySessionWrite(RuntimeError):
    pass


class SessionStore(DatabaseSessionStore):
    def _deny_write(self, *args, **kwargs):
        raise ReadOnlySessionWrite('HOLD: reader session persistence forbidden')

    save = create = delete = cycle_key = _deny_write

    @classmethod
    def clear_expired(cls):
        raise ReadOnlySessionWrite("HOLD: reader session cleanup forbidden")

    @classmethod
    async def aclear_expired(cls):
        cls.clear_expired()

    def flush(self):
        # Django Auth may flush on a changed password hash. Do not issue DELETE.
        self._session_cache = {}
        self._session_key = None
        self.modified = False
        self.accessed = True

    async def asave(self, *args, **kwargs):
        self._deny_write()

    acreate = adelete = acycle_key = asave

    async def aflush(self):
        self.flush()


class ReadOnlySessionMiddleware(SessionMiddleware):
    def __init__(self, get_response):
        from django.conf import settings
        from django.core.exceptions import ImproperlyConfigured
        super().__init__(get_response)
        if (self.SessionStore is not SessionStore or settings.SESSION_SAVE_EVERY_REQUEST
                or settings.CSRF_USE_SESSIONS):
            raise ImproperlyConfigured('HOLD: reader session configuration incompatible')

    def process_exception(self, request, exception):
        if isinstance(exception, ReadOnlySessionWrite):
            response = HttpResponse('Sessão de consulta indisponível.', status=503)
            response['Cache-Control'] = 'no-store'
            return response

    def process_response(self, request, response):
        session = getattr(request, 'session', None)
        if session is not None and (session.modified and not session.is_empty()):
            response = HttpResponse('Sessão de consulta indisponível.', status=503)
            response['Cache-Control'] = 'no-store'
            patch_vary_headers(response, ('Cookie',))
            return response
        # Only the unchanged/empty cases reach Django; no DB save or renewal.
        return super().process_response(request, response)
