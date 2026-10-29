"""Fail-closed synthetic preparer provisioning tests; zero SQL/database calls."""
from uuid import uuid4
from django.test import SimpleTestCase
from preparer_identity.provisioning_plan_offline import (
    Outcome, ProvisioningHold, SyntheticIdentityPlan,
    classify_readback, execute_provisioning, PROVISIONING_SEQUENCE, review_provisioning_sequence,
)


class SyntheticProvisioningOfflineTests(SimpleTestCase):
    def test_synthetic_identity_contract(self):
        plan = SyntheticIdentityPlan("oes_synth_preparer_trial1", uuid4())
        self.assertEqual(plan.permission, "evidence.prepare_question")
        for name in ("admin", "oes_synth_preparer_A", "oes_synth_preparer_!" ):
            with self.assertRaises(ProvisioningHold):
                SyntheticIdentityPlan(name, uuid4())
        with self.assertRaises(ProvisioningHold):
            SyntheticIdentityPlan("oes_synth_preparer_trial1", uuid4(), "auth.change_user")

    def test_connected_entrypoint_always_hold(self):
        with self.assertRaises(ProvisioningHold):
            execute_provisioning()

    def test_readback_requires_complete_independent_proof(self):
        good = dict(user_found=True, identity_found=True, permission_found=True,
                    flags_valid=True, same_user_link=True, same_actor_uuid=True,
                    no_extra_access=True, read_complete=True, independent_reader=True)
        self.assertEqual(classify_readback(**good), Outcome.COMMITTED_VERIFIED)
        for key in good:
            changed = dict(good, **{key: False})
            self.assertEqual(classify_readback(**changed), Outcome.UNCERTAIN_OR_DIVERGENT)
        self.assertEqual(classify_readback(**dict(good, user_found=False, identity_found=False,
                                                 permission_found=False)),
                         Outcome.NOT_COMMITTED_VERIFIED)
        self.assertEqual(classify_readback(**dict(good, same_actor_uuid=None)),
                         Outcome.UNCERTAIN_OR_DIVERGENT)

    def test_permission_definition_does_not_count_as_user_permission_link(self):
        # A pre-existing content type/auth_permission is not trial evidence.
        # The classifier accepts only the exact user's assigned permission link.
        absent = dict(user_found=False, identity_found=False,
                      permission_found=False, flags_valid=False,
                      same_user_link=False, same_actor_uuid=False,
                      no_extra_access=False, read_complete=True,
                      independent_reader=True)
        self.assertEqual(classify_readback(**absent), Outcome.NOT_COMMITTED_VERIFIED)
        self.assertEqual(classify_readback(**dict(absent, permission_found=True)),
                         Outcome.UNCERTAIN_OR_DIVERGENT)
        self.assertEqual(classify_readback(**dict(absent, read_complete=False)),
                         Outcome.UNCERTAIN_OR_DIVERGENT)
        self.assertEqual(classify_readback(**dict(absent, independent_reader=False)),
                         Outcome.UNCERTAIN_OR_DIVERGENT)

    def test_single_use_sequence_is_inert_and_immutable(self):
        self.assertEqual(review_provisioning_sequence(), PROVISIONING_SEQUENCE)
        self.assertEqual(len(PROVISIONING_SEQUENCE), len(set(PROVISIONING_SEQUENCE)))
        self.assertLess(PROVISIONING_SEQUENCE.index("BEGIN_ATOMIC"),
                        PROVISIONING_SEQUENCE.index("CREATE_ONE_USER_WITH_UNUSABLE_PASSWORD"))
        self.assertLess(PROVISIONING_SEQUENCE.index("COMMIT_ONCE"),
                        PROVISIONING_SEQUENCE.index("INDEPENDENT_READBACK_BEFORE_DECLARING_SUCCESS"))
        with self.assertRaises(ProvisioningHold):
            review_provisioning_sequence(PROVISIONING_SEQUENCE[:-1])
        with self.assertRaises(ProvisioningHold):
            review_provisioning_sequence(PROVISIONING_SEQUENCE + ("COMMIT_ONCE",))

    def test_connected_composition_remains_unconditionally_blocked(self):
        from preparer_identity.connected_provisioning_dormant import (
            execute_connected_provisioning, _review_single_use_transaction,
        )
        with self.assertRaises(ProvisioningHold):
            execute_connected_provisioning()
        with self.assertRaises(ProvisioningHold):
            _review_single_use_transaction(plan=None, alias="default",
                                           read_alias="oes_synthetic_reader")
