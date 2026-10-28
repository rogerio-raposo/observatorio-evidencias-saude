"""Fail-closed database routing for the isolated auth integration sandbox.

Never migrate application tables to a scientific PostgreSQL alias.
"""
AUTH_APPS = frozenset({"auth", "contenttypes", "sessions", "preparer_identity"})

class AuthSandboxRouter:
    def db_for_read(self, model, **hints):
        if model._meta.app_label in AUTH_APPS:
            return "default"
        return "oes_scientific_hold"

    def db_for_write(self, model, **hints):
        if model._meta.app_label in AUTH_APPS:
            return "default"
        return "oes_scientific_hold"

    def allow_relation(self, obj1, obj2, **hints):
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        if db != "default":
            return False
        return app_label in AUTH_APPS
