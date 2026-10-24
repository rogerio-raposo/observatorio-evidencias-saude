-- OES PG-A4-G2-B: SYNTHETIC_TECHNICAL_ONLY.
-- PREPARATION ONLY. DO NOT EXECUTE without separate G2-B write approval.
-- Target: br-gentle-hall-b6jaxehf / oes_sandbox, never production.
-- Single atomic transaction. IDs reserved solely for this synthetic fixture.
BEGIN;
DO $$
BEGIN
  IF current_database() <> 'oes_sandbox' THEN
    RAISE EXCEPTION 'Incorrect database';
  END IF;
  IF EXISTS (SELECT 1 FROM core.entity WHERE oes_id LIKE 'OES-PG-A4-G2B-%') THEN
    RAISE EXCEPTION 'Fixture already exists: refusing duplicate load';
  END IF;
  IF EXISTS (SELECT 1 FROM core.entity WHERE entity_uuid IN (
    'a4000000-0000-4000-8000-000000000001','a4000000-0000-4000-8000-000000000002',
    'a4000000-0000-4000-8000-000000000003','a4000000-0000-4000-8000-000000000004')) THEN
    RAISE EXCEPTION 'Synthetic fixture UUID collision';
  END IF;
END $$;

INSERT INTO core.entity (entity_uuid,oes_id,entity_type,created_by) VALUES
('a4000000-0000-4000-8000-000000000001','OES-PG-A4-G2B-STUDY-1','Study','SYNTHETIC_TECHNICAL_ONLY'),
('a4000000-0000-4000-8000-000000000002','OES-PG-A4-G2B-STUDY-2','Study','SYNTHETIC_TECHNICAL_ONLY'),
('a4000000-0000-4000-8000-000000000003','OES-PG-A4-G2B-REPORT-1','Report','SYNTHETIC_TECHNICAL_ONLY'),
('a4000000-0000-4000-8000-000000000004','OES-PG-A4-G2B-REPORT-2','Report','SYNTHETIC_TECHNICAL_ONLY');

INSERT INTO core.entity_version (version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note) VALUES
('a4100000-0000-4000-8000-000000000001','a4000000-0000-4000-8000-000000000001',1,'current','SYNTHETIC_TECHNICAL_ONLY','initial','Synthetic study 1'),
('a4100000-0000-4000-8000-000000000002','a4000000-0000-4000-8000-000000000002',1,'current','SYNTHETIC_TECHNICAL_ONLY','initial','Synthetic study 2'),
('a4100000-0000-4000-8000-000000000003','a4000000-0000-4000-8000-000000000003',1,'current','SYNTHETIC_TECHNICAL_ONLY','initial','Synthetic report 1'),
('a4100000-0000-4000-8000-000000000004','a4000000-0000-4000-8000-000000000004',1,'current','SYNTHETIC_TECHNICAL_ONLY','initial','Synthetic report 2');

INSERT INTO evidence.study(entity_uuid) VALUES
('a4000000-0000-4000-8000-000000000001'),('a4000000-0000-4000-8000-000000000002');
INSERT INTO evidence.report(entity_uuid) VALUES
('a4000000-0000-4000-8000-000000000003'),('a4000000-0000-4000-8000-000000000004');

INSERT INTO evidence.study_version(version_uuid,entity_uuid,study_type,title_or_label,status) VALUES
('a4100000-0000-4000-8000-000000000001','a4000000-0000-4000-8000-000000000001','synthetic','SYNTHETIC_TECHNICAL_ONLY Study 1','synthetic'),
('a4100000-0000-4000-8000-000000000002','a4000000-0000-4000-8000-000000000002','synthetic','SYNTHETIC_TECHNICAL_ONLY Study 2','synthetic');
INSERT INTO evidence.report_version(version_uuid,entity_uuid,report_type,title,status) VALUES
('a4100000-0000-4000-8000-000000000003','a4000000-0000-4000-8000-000000000003','synthetic','SYNTHETIC_TECHNICAL_ONLY Report 1','synthetic'),
('a4100000-0000-4000-8000-000000000004','a4000000-0000-4000-8000-000000000004','synthetic','SYNTHETIC_TECHNICAL_ONLY Report 2','synthetic');

-- N:M: Study 1 -> Report 1 and 2; Study 2 -> Report 1.
INSERT INTO evidence.study_report_link(link_uuid,study_entity_uuid,report_entity_uuid,relation_type,evidence_note,status) VALUES
('a4200000-0000-4000-8000-000000000001','a4000000-0000-4000-8000-000000000001','a4000000-0000-4000-8000-000000000003','synthetic_report','SYNTHETIC_TECHNICAL_ONLY','active'),
('a4200000-0000-4000-8000-000000000002','a4000000-0000-4000-8000-000000000001','a4000000-0000-4000-8000-000000000004','synthetic_report','SYNTHETIC_TECHNICAL_ONLY','active'),
('a4200000-0000-4000-8000-000000000003','a4000000-0000-4000-8000-000000000002','a4000000-0000-4000-8000-000000000003','synthetic_report','SYNTHETIC_TECHNICAL_ONLY','active');

INSERT INTO provenance.record(provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,source_value,process_type,actor,status) VALUES
('a4300000-0000-4000-8000-000000000001','a4100000-0000-4000-8000-000000000001','title_or_label','a4100000-0000-4000-8000-000000000003','synthetic-fixture', '{"marker":"SYNTHETIC_TECHNICAL_ONLY"}'::jsonb,'synthetic_test','SYNTHETIC_TECHNICAL_ONLY','active');

DO $$
DECLARE n integer;
BEGIN
 SELECT count(*) INTO n FROM evidence.study_report_link
 WHERE link_uuid IN ('a4200000-0000-4000-8000-000000000001','a4200000-0000-4000-8000-000000000002','a4200000-0000-4000-8000-000000000003');
 IF n <> 3 THEN RAISE EXCEPTION 'Expected three synthetic N:M links, got %',n; END IF;
 SELECT count(*) INTO n FROM provenance.record WHERE provenance_uuid='a4300000-0000-4000-8000-000000000001';
 IF n <> 1 THEN RAISE EXCEPTION 'Expected one synthetic provenance, got %',n; END IF;
END $$;
COMMIT;

-- Do NOT execute cleanup by inference. Deletion of fixture is a separate gate.
-- If authorized later: delete provenance, links, study/report versions,
-- study/report rows, core.entity_version, core.entity, all by exact IDs.
