-- F3 Evidence Alert projection hardening tests — ALT-H01–H12
-- Requires migrations through 025 + Monitor fixtures + Alert fixtures.

BEGIN;

-- ALT-H01 — supporting source can be assembled before publication (Alert B).
INSERT INTO maintenance.alert_source(
 alert_source_uuid,alert_product_version_uuid,source_role,source_type,source_uri,description,sequence_no
) VALUES (
 'a7200000-0000-0000-0000-000000000101','a7100000-0000-0000-0000-000000000002',
 'supporting','uri','https://example.invalid/prepublication-support','prepublication supporting source',90
);

-- ALT-H02 — affected dimension can be assembled before publication.
INSERT INTO maintenance.alert_affected_dimension(
 alert_product_version_uuid,dimension_code,rationale,sequence_no
) VALUES (
 'a7100000-0000-0000-0000-000000000002','certainty','prepublication dimension assembly',90
);

-- ALT-H03 — source INSERT after publication is blocked.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_source(alert_source_uuid,alert_product_version_uuid,source_role,source_type,source_uri,description,sequence_no)
  VALUES ('a7200000-0000-0000-0000-000000000103','a7100000-0000-0000-0000-000000000001','supporting','uri','https://example.invalid/postpublication','must block',99);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'ALT-H03 FAIL — post-publication source INSERT accepted'; END IF;
END $t$;

-- ALT-H04 — dimension INSERT after publication is blocked.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO maintenance.alert_affected_dimension(alert_product_version_uuid,dimension_code,rationale,sequence_no)
  VALUES ('a7100000-0000-0000-0000-000000000001','validity','must block',99);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'ALT-H04 FAIL — post-publication dimension INSERT accepted'; END IF;
END $t$;

-- ALT-H05 — source_context INSERT after publication is blocked.
DO $t$ DECLARE blocked boolean:=false; BEGIN
 BEGIN
  INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role,sequence_no)
  VALUES ('a7100000-0000-0000-0000-000000000001','e5100000-0000-0000-0000-000000000002','source_context',99);
 EXCEPTION WHEN others THEN blocked:=true; END;
 IF NOT blocked THEN RAISE EXCEPTION 'ALT-H05 FAIL — post-publication source_context INSERT accepted'; END IF;
END $t$;

-- ALT-H06 — source_context DELETE and published ProductVersion material update are blocked.
DO $t$ DECLARE blocked_delete boolean:=false; blocked_update boolean:=false; BEGIN
 BEGIN
  DELETE FROM product.investigation_link
   WHERE product_version_uuid='a7100000-0000-0000-0000-000000000001' AND role='source_context';
 EXCEPTION WHEN others THEN blocked_delete:=true; END;
 BEGIN
  UPDATE product.product_version SET title='mutated published alert'
   WHERE version_uuid='a7100000-0000-0000-0000-000000000001';
 EXCEPTION WHEN others THEN blocked_update:=true; END;
 IF NOT blocked_delete OR NOT blocked_update THEN RAISE EXCEPTION 'ALT-H06 FAIL — published Alert material state not sealed'; END IF;
END $t$;

-- ALT-H07 — supporting EvidenceEvent drift is dynamically detected.
SAVEPOINT alt_h07;
UPDATE maintenance.evidence_event SET status='invalidated'
 WHERE evidence_event_uuid='e5520000-0000-0000-0000-000000000001';
DO $t$ BEGIN
 IF NOT EXISTS (
   SELECT 1 FROM product.evidence_alert_projection_hardening_issues('a7100000-0000-0000-0000-000000000001')
    WHERE issue_code='ALERT_SOURCE_EVENT_NOT_ACTIVE' AND severity='error'
 ) OR product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000001')
 THEN RAISE EXCEPTION 'ALT-H07 FAIL — supporting EvidenceEvent drift not detected'; END IF;
END $t$;
ROLLBACK TO SAVEPOINT alt_h07;
RELEASE SAVEPOINT alt_h07;

-- ALT-H08 — EntityVersion source without maintenance_alert_source edge is detected.
INSERT INTO maintenance.alert_source(
 alert_source_uuid,alert_product_version_uuid,source_role,source_type,source_entity_version_uuid,description,sequence_no
) VALUES (
 'a7200000-0000-0000-0000-000000000108','a7100000-0000-0000-0000-000000000002',
 'supporting','entity_version','e5100000-0000-0000-0000-000000000001','question-version source for lineage test',91
);
DO $t$ BEGIN
 IF NOT EXISTS (
   SELECT 1 FROM product.evidence_alert_projection_hardening_issues('a7100000-0000-0000-0000-000000000002')
    WHERE issue_code='MISSING_ALERT_SOURCE_DEPENDENCY' AND severity='error'
 ) THEN RAISE EXCEPTION 'ALT-H08 FAIL — missing source dependency not detected'; END IF;
END $t$;

-- ALT-H09 — correct EntityVersion source edge resolves the lineage issue.
INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
 'e5100000-0000-0000-0000-000000000001','a7100000-0000-0000-0000-000000000002',
 'maintenance_alert_source','alert_source','active'
);
DO $t$ BEGIN
 IF EXISTS (
   SELECT 1 FROM product.evidence_alert_projection_hardening_issues('a7100000-0000-0000-0000-000000000002')
    WHERE issue_code='MISSING_ALERT_SOURCE_DEPENDENCY'
 ) THEN RAISE EXCEPTION 'ALT-H09 FAIL — valid source dependency not honored'; END IF;
END $t$;

-- ALT-H10 — source dependency drift is detected dynamically.
SAVEPOINT alt_h10;
UPDATE provenance.dependency_edge SET status='inactive'
 WHERE source_version_uuid='e5100000-0000-0000-0000-000000000001'
   AND target_version_uuid='a7100000-0000-0000-0000-000000000002'
   AND dependency_type='maintenance_alert_source';
DO $t$ BEGIN
 IF NOT EXISTS (
   SELECT 1 FROM product.evidence_alert_projection_hardening_issues('a7100000-0000-0000-0000-000000000002')
    WHERE issue_code='MISSING_ALERT_SOURCE_DEPENDENCY' AND severity='error'
 ) THEN RAISE EXCEPTION 'ALT-H10 FAIL — source dependency drift not detected'; END IF;
END $t$;
ROLLBACK TO SAVEPOINT alt_h10;
RELEASE SAVEPOINT alt_h10;

-- ALT-H11 — formal Monitor-derived Alert A remains publishable after hardening.
DO $t$ BEGIN
 IF EXISTS (SELECT 1 FROM product.evidence_alert_projection_hardening_issues('a7100000-0000-0000-0000-000000000001') WHERE severity='error')
 OR NOT product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000001')
 THEN RAISE EXCEPTION 'ALT-H11 FAIL — valid Alert A regressed'; END IF;
END $t$;

-- ALT-H12 — direct critical Alert C remains publishable; no Phase-4 automation is introduced.
DO $t$ BEGIN
 IF EXISTS (SELECT 1 FROM product.evidence_alert_projection_hardening_issues('a7100000-0000-0000-0000-000000000003') WHERE severity='error')
 OR NOT product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000003')
 OR EXISTS (SELECT 1 FROM product.currency_state WHERE product_version_uuid='a7100000-0000-0000-0000-000000000003')
 THEN RAISE EXCEPTION 'ALT-H12 FAIL — direct critical Alert regressed or gained scientific currency'; END IF;
END $t$;

SELECT 'ALT-H01–H12 PASS — Evidence Alert published sealing and dynamic source lineage validated' AS evidence_alert_hardening_status;

ROLLBACK;
