-- Migration 031 fragment E — rebaseline child consistency validators
-- Loaded by 031_propagation_rebaseline_contract.sql.
-- Mechanical implementation of Document 35/36 invariants.

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_policy_link()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.rebaseline_decision%ROWTYPE; op maintenance.update_policy%ROWTYPE; np maintenance.update_policy%ROWTYPE;
BEGIN
  SELECT * INTO d FROM maintenance.rebaseline_decision WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  IF NEW.old_update_policy_uuid IS NOT NULL THEN
    SELECT * INTO op FROM maintenance.update_policy WHERE update_policy_uuid=NEW.old_update_policy_uuid;
    IF COALESCE(op.target_product_version_uuid,op.target_investigation_version_uuid)
       IS DISTINCT FROM COALESCE(d.old_target_product_version_uuid,d.old_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'Old policy target mismatch'; END IF;
  END IF;
  IF NEW.new_update_policy_uuid IS NOT NULL THEN
    SELECT * INTO np FROM maintenance.update_policy WHERE update_policy_uuid=NEW.new_update_policy_uuid;
    IF COALESCE(np.target_product_version_uuid,np.target_investigation_version_uuid)
       IS DISTINCT FROM COALESCE(d.new_target_product_version_uuid,d.new_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'New policy target mismatch'; END IF;
  END IF;
  IF NEW.policy_disposition='replace_with_new_policy'
     AND (NEW.old_update_policy_uuid IS NULL OR NEW.new_update_policy_uuid IS NULL)
  THEN RAISE EXCEPTION 'replace_with_new_policy requires old/new policies'; END IF;
  IF d.decision_stage='activated'
     AND NEW.policy_disposition='replace_with_new_policy'
     AND np.record_status IS DISTINCT FROM 'active'
  THEN RAISE EXCEPTION 'Activated rebaseline requires active new policy'; END IF;
  IF d.decision_stage='activated'
     AND NEW.policy_disposition IN ('pending','maintenance_policy_required')
  THEN RAISE EXCEPTION 'Pending/missing policy blocks activated rebaseline'; END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_policy_link_consistency ON maintenance.rebaseline_policy_link;
CREATE TRIGGER tr_rebaseline_policy_link_consistency BEFORE INSERT ON maintenance.rebaseline_policy_link
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_policy_link();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_monitor_link()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.rebaseline_decision%ROWTYPE; omt maintenance.monitor_target%ROWTYPE; nmt maintenance.monitor_target%ROWTYPE;
        old_entity uuid; new_entity uuid; pt text;
BEGIN
  SELECT * INTO d FROM maintenance.rebaseline_decision WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  IF NEW.old_monitor_product_version_uuid IS NOT NULL THEN
    SELECT product_type,entity_uuid INTO pt,old_entity FROM product.product_version WHERE version_uuid=NEW.old_monitor_product_version_uuid;
    SELECT * INTO omt FROM maintenance.monitor_target WHERE monitor_product_version_uuid=NEW.old_monitor_product_version_uuid;
    IF pt IS DISTINCT FROM 'evidence_monitor'
       OR COALESCE(omt.target_product_version_uuid,omt.target_investigation_version_uuid)
          IS DISTINCT FROM COALESCE(d.old_target_product_version_uuid,d.old_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'Old Monitor target mismatch'; END IF;
  END IF;
  IF NEW.new_monitor_product_version_uuid IS NOT NULL THEN
    SELECT product_type,entity_uuid INTO pt,new_entity FROM product.product_version WHERE version_uuid=NEW.new_monitor_product_version_uuid;
    SELECT * INTO nmt FROM maintenance.monitor_target WHERE monitor_product_version_uuid=NEW.new_monitor_product_version_uuid;
    IF pt IS DISTINCT FROM 'evidence_monitor'
       OR COALESCE(nmt.target_product_version_uuid,nmt.target_investigation_version_uuid)
          IS DISTINCT FROM COALESCE(d.new_target_product_version_uuid,d.new_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'New Monitor target mismatch'; END IF;
  END IF;
  IF NEW.monitor_disposition='continue_same_monitor_lineage'
     AND (old_entity IS NULL OR new_entity IS NULL OR old_entity<>new_entity)
  THEN RAISE EXCEPTION 'continue_same_monitor_lineage requires same Monitor entity'; END IF;
  IF NEW.monitor_disposition='replace_with_new_monitor_entity'
     AND (old_entity IS NULL OR new_entity IS NULL OR old_entity=new_entity)
  THEN RAISE EXCEPTION 'replace_with_new_monitor_entity requires distinct Monitor entities'; END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_monitor_link_consistency ON maintenance.rebaseline_monitor_link;
CREATE TRIGGER tr_rebaseline_monitor_link_consistency BEFORE INSERT ON maintenance.rebaseline_monitor_link
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_monitor_link();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_risk_profile_link()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.rebaseline_decision%ROWTYPE; sp maintenance.update_risk_profile%ROWTYPE; tp maintenance.update_risk_profile%ROWTYPE;
BEGIN
  SELECT * INTO d FROM maintenance.rebaseline_decision WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  IF NEW.source_update_risk_profile_uuid IS NOT NULL THEN
    SELECT * INTO sp FROM maintenance.update_risk_profile WHERE update_risk_profile_uuid=NEW.source_update_risk_profile_uuid;
    IF COALESCE(sp.target_product_version_uuid,sp.target_investigation_version_uuid)
       IS DISTINCT FROM COALESCE(d.old_target_product_version_uuid,d.old_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'Source risk profile target mismatch'; END IF;
  END IF;
  IF NEW.target_update_risk_profile_uuid IS NOT NULL THEN
    SELECT * INTO tp FROM maintenance.update_risk_profile WHERE update_risk_profile_uuid=NEW.target_update_risk_profile_uuid;
    IF COALESCE(tp.target_product_version_uuid,tp.target_investigation_version_uuid)
       IS DISTINCT FROM COALESCE(d.new_target_product_version_uuid,d.new_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'Target risk profile target mismatch'; END IF;
  END IF;
  IF NEW.profile_disposition='carry_forward_authorized'
     AND (sp.authority_status IS DISTINCT FROM 'authoritative'
       OR tp.assessment_kind IS DISTINCT FROM 'carry_forward'
       OR tp.carried_forward_from_profile_uuid IS DISTINCT FROM NEW.source_update_risk_profile_uuid)
  THEN RAISE EXCEPTION 'carry_forward_authorized requires physical authoritative carry-forward'; END IF;
  IF NEW.profile_disposition='target_profile_available' AND NEW.target_update_risk_profile_uuid IS NULL
  THEN RAISE EXCEPTION 'target_profile_available requires target profile'; END IF;
  IF d.decision_stage='activated' AND NEW.profile_disposition='pending'
  THEN RAISE EXCEPTION 'Pending risk-profile disposition blocks activated rebaseline'; END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_risk_profile_link_consistency ON maintenance.rebaseline_risk_profile_link;
CREATE TRIGGER tr_rebaseline_risk_profile_link_consistency BEFORE INSERT ON maintenance.rebaseline_risk_profile_link
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_risk_profile_link();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_coverage_item()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.rebaseline_decision%ROWTYPE; cutoff date;
BEGIN
  SELECT * INTO d FROM maintenance.rebaseline_decision WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  IF d.new_target_product_version_uuid IS NOT NULL THEN
    SELECT evidence_cutoff_date INTO cutoff FROM product.product_version WHERE version_uuid=d.new_target_product_version_uuid;
  ELSE
    SELECT evidence_cutoff_date INTO cutoff FROM investigation.investigation_version WHERE version_uuid=d.new_target_investigation_version_uuid;
  END IF;
  IF NEW.coverage_code='incorporated_through_new_target_cutoff'
     AND NEW.window_end_date IS NOT NULL AND NEW.window_end_date IS DISTINCT FROM cutoff
  THEN RAISE EXCEPTION 'Incorporated coverage must end exactly at new target cutoff'; END IF;
  IF NEW.coverage_code='post_cutoff_pending_assessment'
     AND NEW.window_start_date IS NOT NULL AND NEW.window_start_date<=cutoff
  THEN RAISE EXCEPTION 'Post-cutoff coverage must start after new target cutoff'; END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_coverage_consistency ON maintenance.rebaseline_coverage_item;
CREATE TRIGGER tr_rebaseline_coverage_consistency BEFORE INSERT ON maintenance.rebaseline_coverage_item
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_coverage_item();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_sla_rule_link()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE pl maintenance.rebaseline_policy_link%ROWTYPE; oldr maintenance.sla_rule%ROWTYPE; newr maintenance.sla_rule%ROWTYPE;
BEGIN
  SELECT * INTO pl FROM maintenance.rebaseline_policy_link WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  IF NEW.old_sla_rule_uuid IS NOT NULL THEN
    SELECT * INTO oldr FROM maintenance.sla_rule WHERE sla_rule_uuid=NEW.old_sla_rule_uuid;
    IF pl.old_update_policy_uuid IS NULL OR oldr.update_policy_uuid<>pl.old_update_policy_uuid
    THEN RAISE EXCEPTION 'Old SLA rule must belong to old rebaseline policy'; END IF;
  END IF;
  IF NEW.new_sla_rule_uuid IS NOT NULL THEN
    SELECT * INTO newr FROM maintenance.sla_rule WHERE sla_rule_uuid=NEW.new_sla_rule_uuid;
    IF pl.new_update_policy_uuid IS NULL OR newr.update_policy_uuid<>pl.new_update_policy_uuid
    THEN RAISE EXCEPTION 'New SLA rule must belong to new rebaseline policy'; END IF;
    IF NEW.old_sla_rule_uuid IS NOT NULL AND newr.supersedes_sla_rule_uuid IS NOT DISTINCT FROM NEW.old_sla_rule_uuid
    THEN RAISE EXCEPTION 'Cross-policy SLA lineage cannot use supersedes_sla_rule_uuid'; END IF;
  END IF;
  IF NEW.rule_disposition='adopt_new_rule' AND NEW.new_sla_rule_uuid IS NULL
  THEN RAISE EXCEPTION 'adopt_new_rule requires new SLA rule'; END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_sla_rule_link_consistency ON maintenance.rebaseline_sla_rule_link;
CREATE TRIGGER tr_rebaseline_sla_rule_link_consistency BEFORE INSERT ON maintenance.rebaseline_sla_rule_link
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_sla_rule_link();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_open_signal_disposition()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE pl maintenance.rebaseline_policy_link%ROWTYPE; olds maintenance.update_signal%ROWTYPE; news maintenance.update_signal%ROWTYPE;
BEGIN
  SELECT * INTO pl FROM maintenance.rebaseline_policy_link WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  SELECT * INTO olds FROM maintenance.update_signal WHERE update_signal_uuid=NEW.old_update_signal_uuid;
  IF pl.old_update_policy_uuid IS NOT NULL AND olds.update_policy_uuid<>pl.old_update_policy_uuid
  THEN RAISE EXCEPTION 'Old signal must belong to old policy'; END IF;
  IF NEW.signal_disposition='create_new_signal_on_new_target' AND NEW.new_update_signal_uuid IS NULL
  THEN RAISE EXCEPTION 'create_new_signal_on_new_target requires new signal'; END IF;
  IF NEW.new_update_signal_uuid IS NOT NULL THEN
    SELECT * INTO news FROM maintenance.update_signal WHERE update_signal_uuid=NEW.new_update_signal_uuid;
    IF pl.new_update_policy_uuid IS NULL OR news.update_policy_uuid<>pl.new_update_policy_uuid
    THEN RAISE EXCEPTION 'New signal must belong to new policy'; END IF;
  END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_open_signal_consistency ON maintenance.rebaseline_open_signal_disposition;
CREATE TRIGGER tr_rebaseline_open_signal_consistency BEFORE INSERT ON maintenance.rebaseline_open_signal_disposition
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_open_signal_disposition();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_workflow_link()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.rebaseline_decision%ROWTYPE; oldw maintenance.workflow_round%ROWTYPE; neww maintenance.workflow_round%ROWTYPE;
BEGIN
  SELECT * INTO d FROM maintenance.rebaseline_decision WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  SELECT * INTO oldw FROM maintenance.workflow_round WHERE workflow_round_uuid=NEW.old_workflow_round_uuid;
  IF COALESCE(oldw.target_product_version_uuid,oldw.target_investigation_version_uuid)
     IS DISTINCT FROM COALESCE(d.old_target_product_version_uuid,d.old_target_investigation_version_uuid)
  THEN RAISE EXCEPTION 'Old workflow target must equal old rebaseline target'; END IF;
  IF NEW.workflow_disposition='old_round_produced_new_target'
     AND COALESCE(oldw.result_product_version_uuid,oldw.result_investigation_version_uuid)
       IS DISTINCT FROM COALESCE(d.new_target_product_version_uuid,d.new_target_investigation_version_uuid)
  THEN RAISE EXCEPTION 'Old workflow result must equal new rebaseline target'; END IF;
  IF NEW.workflow_disposition='open_new_round_independently' AND NEW.new_workflow_round_uuid IS NULL
  THEN RAISE EXCEPTION 'open_new_round_independently requires new workflow'; END IF;
  IF NEW.new_workflow_round_uuid IS NOT NULL THEN
    SELECT * INTO neww FROM maintenance.workflow_round WHERE workflow_round_uuid=NEW.new_workflow_round_uuid;
    IF COALESCE(neww.target_product_version_uuid,neww.target_investigation_version_uuid)
       IS DISTINCT FROM COALESCE(d.new_target_product_version_uuid,d.new_target_investigation_version_uuid)
    THEN RAISE EXCEPTION 'New workflow target must equal new rebaseline target'; END IF;
  END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_workflow_link_consistency ON maintenance.rebaseline_workflow_link;
CREATE TRIGGER tr_rebaseline_workflow_link_consistency BEFORE INSERT ON maintenance.rebaseline_workflow_link
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_workflow_link();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_sla_instance_disposition()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE pl maintenance.rebaseline_policy_link%ROWTYPE; oldi maintenance.sla_instance%ROWTYPE; newi maintenance.sla_instance%ROWTYPE;
        oldr maintenance.sla_rule%ROWTYPE; newr maintenance.sla_rule%ROWTYPE;
BEGIN
  SELECT * INTO pl FROM maintenance.rebaseline_policy_link WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;
  SELECT * INTO oldi FROM maintenance.sla_instance WHERE sla_instance_uuid=NEW.old_sla_instance_uuid;
  SELECT * INTO oldr FROM maintenance.sla_rule WHERE sla_rule_uuid=oldi.sla_rule_uuid;
  IF pl.old_update_policy_uuid IS NOT NULL AND oldr.update_policy_uuid<>pl.old_update_policy_uuid
  THEN RAISE EXCEPTION 'Old SLA instance must belong to old policy'; END IF;
  IF NEW.new_sla_instance_uuid IS NOT NULL THEN
    SELECT * INTO newi FROM maintenance.sla_instance WHERE sla_instance_uuid=NEW.new_sla_instance_uuid;
    SELECT * INTO newr FROM maintenance.sla_rule WHERE sla_rule_uuid=newi.sla_rule_uuid;
    IF pl.new_update_policy_uuid IS NULL OR newr.update_policy_uuid<>pl.new_update_policy_uuid
    THEN RAISE EXCEPTION 'New SLA instance must belong to new policy'; END IF;
    IF newi.supersedes_sla_instance_uuid IS NOT NULL
    THEN RAISE EXCEPTION 'New cross-policy obligation cannot be represented as SLA rebase of old obligation'; END IF;
  END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_rebaseline_sla_instance_consistency ON maintenance.rebaseline_sla_instance_disposition;
CREATE TRIGGER tr_rebaseline_sla_instance_consistency BEFORE INSERT ON maintenance.rebaseline_sla_instance_disposition
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_sla_instance_disposition();
