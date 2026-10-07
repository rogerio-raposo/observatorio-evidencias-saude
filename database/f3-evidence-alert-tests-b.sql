-- F3 Evidence Alert tests B — AL-T16–T29
-- Requires migrations through 024 + Monitor fixtures + Alert fixtures.

BEGIN;

-- Reusable temporary Alert Product shell for rejected insert scenarios.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('a7000000-0000-0000-0000-000000000090','OES-P-ALT-TMP090','Product','test');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type)
VALUES ('a7100000-0000-0000-0000-000000000090','a7000000-0000-0000-0000-000000000090',1,'draft','test','test');
INSERT INTO product.product(entity_uuid)
VALUES ('a7000000-0000-0000-0000-000000000090');
INSERT INTO product.product_version(version_uuid,entity_uuid,product_type,title,evidence_cutoff_date,status)
VALUES ('a7100000-0000-0000-0000-000000000090','a7000000-0000-0000-0000-000000000090','evidence_alert','Temporary Alert shell',DATE '2026-10-06','draft');
INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role)
VALUES ('a7100000-0000-0000-0000-000000000090','e5100000-0000-0000-0000-000000000004','source_context');

-- AL-T16 — invalid human verification semantics.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at)
  VALUES ('a7100000-0000-0000-0000-000000000090','e5100000-0000-0000-0000-000000000003','T16','T16',CURRENT_TIMESTAMP,'informational','routine','evaluation','T16','ai','ai_system','human_verified','ai','ai_system',CURRENT_TIMESTAMP);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T16 FAIL'; END IF;
END $t$;

-- AL-T17 — triage cannot be formally issued.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status,issued_at)
  VALUES ('a7100000-0000-0000-0000-000000000090','e5100000-0000-0000-0000-000000000003','T17','T17',CURRENT_TIMESTAMP,'informational','routine','triage','T17','ai','ai_system','unverified',CURRENT_TIMESTAMP);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T17 FAIL'; END IF;
END $t$;

-- AL-T18a — incorporated requires linkage.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status)
  VALUES ('a7100000-0000-0000-0000-000000000090','e5100000-0000-0000-0000-000000000003','T18','T18',CURRENT_TIMESTAMP,'relevant','priority','incorporated','T18','ai','ai_system','unverified');
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T18a FAIL'; END IF;
END $t$;

-- AL-T18b — valid CurrencyState incorporation is accepted.
INSERT INTO maintenance.evidence_alert(
 alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,
 classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,
 verification_status,incorporated_currency_state_uuid
) VALUES (
 'a7100000-0000-0000-0000-000000000090','e5100000-0000-0000-0000-000000000003',
 'T18B','T18B',CURRENT_TIMESTAMP,'relevant','priority','incorporated','T18B','ai','ai_system',
 'unverified','e5300000-0000-0000-0000-000000000003'
);

DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM maintenance.evidence_alert
  WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000090'
    AND lifecycle_status='incorporated'
    AND incorporated_currency_state_uuid='e5300000-0000-0000-0000-000000000003')
 THEN RAISE EXCEPTION 'AL-T18b FAIL'; END IF;
END $t$;

-- A second temporary shell for discarded/date tests because the first now has an immutable Alert row.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('a7000000-0000-0000-0000-000000000091','OES-P-ALT-TMP091','Product','test');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type)
VALUES ('a7100000-0000-0000-0000-000000000091','a7000000-0000-0000-0000-000000000091',1,'draft','test','test');
INSERT INTO product.product(entity_uuid) VALUES ('a7000000-0000-0000-0000-000000000091');
INSERT INTO product.product_version(version_uuid,entity_uuid,product_type,title,evidence_cutoff_date,status)
VALUES ('a7100000-0000-0000-0000-000000000091','a7000000-0000-0000-0000-000000000091','evidence_alert','Temporary Alert shell 91',DATE '2026-10-06','draft');
INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role)
VALUES ('a7100000-0000-0000-0000-000000000091','e5100000-0000-0000-0000-000000000004','source_context');

-- AL-T19 — discarded requires resolution rationale.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status)
  VALUES ('a7100000-0000-0000-0000-000000000091','e5100000-0000-0000-0000-000000000003','T19','T19',CURRENT_TIMESTAMP,'informational','routine','discarded','T19','ai','ai_system','unverified');
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T19 FAIL'; END IF;
END $t$;

-- AL-T20 — EvidenceAlert rows are immutable.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN UPDATE maintenance.evidence_alert SET classification='critical'
  WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001';
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T20 FAIL'; END IF;
END $t$;

-- AL-T21 — AlertSource rows are immutable.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN UPDATE maintenance.alert_source SET description='changed'
  WHERE alert_source_uuid='a7200000-0000-0000-0000-000000000001';
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T21 FAIL'; END IF;
END $t$;

-- AL-T22 — affected dimensions are immutable.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN UPDATE maintenance.alert_affected_dimension SET rationale='changed'
  WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000001' AND dimension_code='certainty';
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T22 FAIL'; END IF;
END $t$;

-- AL-T23 — signal_date cannot exceed Alert cutoff.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.evidence_alert(alert_product_version_uuid,target_product_version_uuid,headline,summary,signal_date,detected_at,classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,verification_status,resolution_rationale)
  VALUES ('a7100000-0000-0000-0000-000000000091','e5100000-0000-0000-0000-000000000003','T23','T23',DATE '2026-10-07',CURRENT_TIMESTAMP,'informational','routine','discarded','T23','ai','ai_system','unverified','discarded for test');
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T23 FAIL'; END IF;
END $t$;

-- Insert a valid discarded row to prove rationale semantics.
INSERT INTO maintenance.evidence_alert(
 alert_product_version_uuid,target_product_version_uuid,headline,summary,detected_at,
 classification,reassessment_priority,lifecycle_status,justification,assessed_by,actor_type,
 verification_status,resolution_rationale
) VALUES (
 'a7100000-0000-0000-0000-000000000091','e5100000-0000-0000-0000-000000000003',
 'T19 valid','T19 valid',CURRENT_TIMESTAMP,'informational','routine','discarded',
 'T19 valid','ai','ai_system','unverified','Signal was assessed and discarded in this synthetic test'
);

-- AL-T24 — source_date cannot exceed Alert cutoff.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_source(alert_source_uuid,alert_product_version_uuid,source_role,source_type,source_uri,source_date,description,sequence_no)
  VALUES ('a7200000-0000-0000-0000-000000000024','a7100000-0000-0000-0000-000000000001','supporting','uri','https://example.invalid/future',DATE '2026-10-07','future',99);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T24 FAIL'; END IF;
END $t$;

-- AL-T25 — Monitor-derived source must match source_context Investigation.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_source(alert_source_uuid,alert_product_version_uuid,source_role,source_type,candidate_assessment_uuid,description,sequence_no)
  VALUES ('a7200000-0000-0000-0000-000000000025','a7100000-0000-0000-0000-000000000003','supporting','candidate_assessment','e5530000-0000-0000-0000-000000000002','wrong context',99);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'AL-T25 FAIL'; END IF;
END $t$;

-- AL-T26 — target dependency is dynamically required.
UPDATE provenance.dependency_edge SET status='inactive'
 WHERE source_version_uuid='e5100000-0000-0000-0000-000000000003'
   AND target_version_uuid='a7100000-0000-0000-0000-000000000001'
   AND dependency_type='maintenance_alert_target';
DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000001')
  WHERE issue_code='MISSING_TARGET_DEPENDENCY' AND severity='error')
 THEN RAISE EXCEPTION 'AL-T26 FAIL'; END IF;
END $t$;
UPDATE provenance.dependency_edge SET status='active'
 WHERE source_version_uuid='e5100000-0000-0000-0000-000000000003'
   AND target_version_uuid='a7100000-0000-0000-0000-000000000001'
   AND dependency_type='maintenance_alert_target';

-- AL-T27 — invalidated upstream provenance dynamically blocks publication.
-- Use Alert B so the history-preserving provenance row can remain until transaction rollback.
INSERT INTO provenance.record(provenance_uuid,target_version_uuid,field_path,process_type,process_record_uuid,actor,status,invalidated_at,invalidation_reason)
VALUES ('a7700000-0000-0000-0000-000000000027','a7100000-0000-0000-0000-000000000002','alert.synthetic_test','evidence_alert_test','a7100000-0000-0000-0000-000000000002','test','invalidated',CURRENT_TIMESTAMP,'Synthetic invalidation for AL-T27');
DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM product.evidence_alert_publication_issues('a7100000-0000-0000-0000-000000000002')
  WHERE issue_code='INVALIDATED_DEPENDENCY' AND severity='error')
 THEN RAISE EXCEPTION 'AL-T27 FAIL'; END IF;
END $t$;

-- AL-T28 — Alert A remains publishable because the adversarial invalidation is isolated to Alert B.
DO $t$ BEGIN
 IF NOT product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000001')
 THEN RAISE EXCEPTION 'AL-T28 FAIL'; END IF;
END $t$;

-- AL-T29 — critical/urgent does not create Alert currency or mutate scientific target state.
DO $t$ BEGIN
 IF EXISTS (SELECT 1 FROM product.currency_state WHERE product_version_uuid='a7100000-0000-0000-0000-000000000003')
 OR NOT EXISTS (SELECT 1 FROM maintenance.evidence_alert WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000003' AND classification='critical' AND reassessment_priority='urgent')
 OR NOT EXISTS (SELECT 1 FROM product.currency_state WHERE product_version_uuid='e5100000-0000-0000-0000-000000000003' AND record_status='active' AND currency_status='under_evaluation')
 THEN RAISE EXCEPTION 'AL-T29 FAIL'; END IF;
END $t$;

SELECT 'AL-T16–T29 PASS — Evidence Alert lifecycle, immutability, lineage and Phase-4 boundary validated' AS evidence_alert_tests_b_status;

ROLLBACK;
