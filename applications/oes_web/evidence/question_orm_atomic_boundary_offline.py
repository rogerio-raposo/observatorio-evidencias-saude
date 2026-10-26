"""Fail-closed Django atomic boundary for the existing offline Q0/Q1 UoW.

No default writer, alias, connection, or transaction factory is provided.
Test doubles can exercise entry, success, rollback and replay behavior. This
is NOT a connected Django/Neon transaction adapter.
"""
from contextlib import contextmanager

from .question_preparation import PreparationHold


class OfflineDjangoAtomicPort:
    """Provide begin() for OfflineQuestionUnitOfWork via injected fakes only."""

    def __init__(self, *, atomic_factory=None, transaction_factory=None):
        if atomic_factory is None or transaction_factory is None:
            raise PreparationHold("HOLD: connected transaction boundary unavailable")
        if not callable(atomic_factory) or not callable(transaction_factory):
            raise PreparationHold("HOLD: invalid offline transaction factories")
        self._atomic_factory = atomic_factory
        self._transaction_factory = transaction_factory

    @contextmanager
    def begin(self):
        # The atomic factory must be an offline fake, never Django's real
        # transaction.atomic; the actual writer alias remains unauthorized.
        with self._atomic_factory():
            with self._transaction_factory() as tx:
                yield tx
