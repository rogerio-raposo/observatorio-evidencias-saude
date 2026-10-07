-- F3 Evidence Alert tests A — AL-T01–T15
-- Requires migrations through 024 + Monitor fixtures + Alert fixtures.

BEGIN;

-- AL-T01
DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM product.product_version pv JOIN maintenance.evidence_alert a ON a.alert_product_version_uuid=pv.version_uuid
   WHERE pv.version_uuid='a7100000-0000-0000-0000-000000000001' AND pv.product_type='evidence_alert'
     AND pv.conclusion_text IS NULL AND a.classification='relevant' AND a.reassessment_priority='priority' AND a.lifecycle_status='evaluation')
 THEN RAISE EXCEPTION 'AL-T01 FAIL'; END IF;
END $t$;

-- AL-T02
DO $t$ BEGIN
 IF (SELECT count(*) FROM product.investigation_link WHERE product_version_uuid='a7100000-0000-0000-0000-000000000001' AND role='source_context')<>1
 OR maintenance.alert_context_investigation('a7100000-0000-0000-0000-000000000001')<>'e5100000-0000-0000-0000-000000000004'::uuid
 OR NOT EXISTS (SELECT 1 FROM maintenance.evidence_alert WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001'
                    AND target_product_version_uuid='e5100000-0000-0000-0000-000000000003' AND target_investigation_version_uuid IS NULL)
 THEN RAISE EXCEPTION 'AL-T02 FAIL'; END IF;
END $t$;

-- AL-T03
DO $t$ BEGIN
 IF (SELECT count(*) FROM maintenance.alert_source WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND source_role='primary')<>1
 OR NOT EXISTS (SELECT 1 FROM maintenance.alert_source WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND candidate_assessment_uuid='e5530000-0000-0000-0000-000000000002')
 OR NOT EXISTS (SELECT 1 FROM maintenance.alert_source WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND evidence_event_uuid='e5520000-0000-0000-0000-000000000001')
 THEN RAISE EXCEPTION 'AL-T03 FAIL'; END IF;
END $t$;

-- AL-T04
DO $t$ BEGIN
 IF (SELECT count(*) FROM maintenance.alert_affected_dimension WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001')<>2
 OR NOT EXISTS (SELECT 1 FROM maintenance.alert_affected_dimension WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND dimension_code='conclusion')
 OR NOT EXISTS (SELECT 1 FROM maintenance.alert_affected_dimension WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND dimension_code='certainty')
 THEN RAISE EXCEPTION 'AL-T04 FAIL'; END IF;
END $t$;

-- AL-T05
DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM maintenance.evidence_alert WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND verification_status='human_verified' AND verifier_actor_type='human_reviewer')
 OR product.assurance_level('a7100000-0000-0000-0000-000000000001')<>'A2'
 OR EXISTS (SELECT 1 FROM product.assurance_record WHERE product_version_uuid='a7100000-0000-0000-0000-000000000001' AND status='active' AND assurance_type='expert_independent_review' AND decision='approved')
 THEN RAISE EXCEPTION 'AL-T05 FAIL'; END IF;
END $t$;

-- AL-T06
DO $t$ BEGIN
 IF NOT product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000001') THEN RAISE EXCEPTION 'AL-T06 FAIL'; END IF;
END $t$;

-- AL-T07
DO $t$ BEGIN
 IF EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000001') WHERE severity='error')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000001') WHERE issue_code='NO_EXPERT_REVIEW_OF_ALERT' AND severity='warning')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000001') WHERE issue_code='TARGET_CURRENCY_UNDER_EVALUATION' AND severity='warning')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000001') WHERE issue_code='TARGET_ASSURANCE_BELOW_A2' AND severity='warning')
 THEN RAISE EXCEPTION 'AL-T07 FAIL'; END IF;
END $t$;

-- AL-T08
DO $t$ BEGIN
 IF product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000002')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000002') WHERE issue_code='MISSING_HUMAN_VERIFICATION' AND severity='error')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000002') WHERE issue_code='ASSURANCE_BELOW_A2' AND severity='error')
 THEN RAISE EXCEPTION 'AL-T08 FAIL'; END IF;
END $t$;

-- AL-T09
DO $t$ BEGIN
 IF NOT product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000003')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000003') WHERE issue_code='ALERT_SOURCE_OUTSIDE_MONITOR' AND severity='warning')
 OR NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000003') WHERE issue_code='CRITICAL_WITHOUT_EXPERT_REVIEW' AND severity='warning')
 THEN RAISE EXCEPTION 'AL-T09 FAIL'; END IF;
END $t$;

-- AL-T10
DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM maintenance.evidence_alert WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000003'
   AND target_investigation_version_uuid='e5100000-0000-0000-0000-000000000002' AND target_product_version_uuid IS NULL)
 THEN RAISE EXCEPTION 'AL-T10 FAIL'; END IF;
END $t$;

-- AL-T11 — wrong product type.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role,sequence_no)
  VALUES ('e5100000-0000-0000-0000-000000000005','e5100000-0000-0000-0000-000000000004','source_context',99);
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status)
  VALUES ('e5100000-0000-0000-0000-000000000005','e5100000-0000-0000-0000-000000000003','x','x',CURRENT_TIMESTAMP,'informational','routine','triage','x','x','ai_system','unverified');
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T11 FAIL'; END IF;
END $t$;

-- AL-T12 — target xor.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,target_investigation_version_uuid,headline,summary,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status)
  VALUES ('a7100000-0000-0000-0000-000000000002','e5100000-0000-0000-0000-000000000003','e5100000-0000-0000-0000-000000000002','x','x',CURRENT_TIMESTAMP,'informational','routine','triage','x','x','ai_system','unverified');
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T12 FAIL'; END IF;
END $t$;

-- AL-T13 — source type/locator mismatch.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_source(alert_source_uuid,alert_product_version_uuid,source_role,source_type,source_uri,description)
  VALUES ('a7200000-0000-0000-0000-000000000013','a7100000-0000-0000-0000-000000000001','supporting','artifact','https://example.invalid/mismatch','mismatch');
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T13 FAIL'; END IF;
END $t$;

-- AL-T14 — only one primary source.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_source(alert_source_uuid,alert_product_version_uuid,source_role,source_type,source_uri,description)
  VALUES ('a7200000-0000-0000-0000-000000000014','a7100000-0000-0000-0000-000000000001','primary','uri','https://example.invalid/second-primary','second primary');
 EXCEPTION WHEN unique_violation THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T14 FAIL'; END IF;
END $t$;

-- AL-T15 — duplicate affected dimension.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_affected_dimension(alert_product_version_uuid,dimension_code,rationale)
  VALUES ('a7100000-0000-0000-0000-000000000001','certainty','duplicate');
 EXCEPTION WHEN unique_violation THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T15 FAIL'; END IF;
END $t$;

SELECT 'AL-T01–T15 PASS — Evidence Alert base contract and gate semantics validated' AS evidence_alert_tests_a_status;

ROLLBACK;
