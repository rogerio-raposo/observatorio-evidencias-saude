"""Fail-closed synthetic preparer provisioning tests; zero SQL/database calls."""
from uuid import uuid4
from django.test import SimpleTestCase
from preparer_identity.provisioning_plan_offline import (
    Outcome, ProvisioningHold, SyntheticIdentityPlan,
    classify_readback, execute_provisioning,
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
