-- OES-DBM-2026-0026
-- Fase 3 — EvidenceAlertView 0.1
-- Depends on: migrations 002–025
-- Date: 2026-10-06
-- Read-only projection. No classification/urgency/currentness inference.

BEGIN;

CREATE OR REPLACE FUNCTION product.evidence_alert_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $view$
WITH
pv AS (
    SELECT pv0.*,pe.oes_id AS product_id,ev.version_no,ev.version_status
      FROM product.product_version pv0
      JOIN core.entity pe ON pe.entity_uuid=pv0.entity_uuid
      JOIN core.entity_version ev ON ev.version_uuid=pv0.version_uuid
     WHERE pv0.version_uuid=p_product_version_uuid
),
a AS (
    SELECT * FROM maintenance.evidence_alert
     WHERE alert_product_version_uuid=p_product_version_uuid
),
ctx AS (
    SELECT iv.*,ie.oes_id AS investigation_id,ev.version_no,ev.version_status
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity ie ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version ev ON ev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='source_context'
     ORDER BY il.sequence_no NULLS LAST,iv.version_uuid
     LIMIT 1
),
tp AS (
    SELECT tpv.*,te.oes_id AS target_product_id,tev.version_no,tev.version_status,
           cs.currency_status,cs.assessed_at AS currency_assessed_at,
           cs.assessed_by AS currency_assessed_by,cs.rationale AS currency_rationale
      FROM a
      JOIN product.product_version tpv
        ON tpv.version_uuid=a.target_product_version_uuid
      JOIN core.entity te ON te.entity_uuid=tpv.entity_uuid
      JOIN core.entity_version tev ON tev.version_uuid=tpv.version_uuid
      LEFT JOIN LATERAL (
          SELECT cs0.* FROM product.currency_state cs0
           WHERE cs0.product_version_uuid=tpv.version_uuid
             AND cs0.record_status='active'
           ORDER BY cs0.assessed_at DESC,cs0.currency_state_uuid
           LIMIT 1
      ) cs ON true
),
tpi AS (
    SELECT iv.*,ie.oes_id AS investigation_id
      FROM tp
      LEFT JOIN product.investigation_link il
        ON il.product_version_uuid=tp.version_uuid AND il.role='primary'
      LEFT JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      LEFT JOIN core.entity ie ON ie.entity_uuid=iv.entity_uuid
     ORDER BY il.sequence_no NULLS LAST
     LIMIT 1
),
ti AS (
    SELECT iv.*,ie.oes_id AS investigation_id,ev.version_no,ev.version_status
      FROM a
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=a.target_investigation_version_uuid
      JOIN core.entity ie ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version ev ON ev.version_uuid=iv.version_uuid
),
base_issues AS (
    SELECT * FROM product.evidence_alert_publication_issues(p_product_version_uuid)
),
hard_issues AS (
    SELECT * FROM product.evidence_alert_projection_hardening_issues(p_product_version_uuid)
)
SELECT jsonb_build_object(
 'schema_version','oes.evidence_alert_view/0.1',
 'identity',COALESCE((
    SELECT jsonb_build_object(
      'product_id',pv.product_id,
      'product_entity_uuid',pv.entity_uuid,
      'product_version_uuid',pv.version_uuid,
      'version_no',pv.version_no,
      'version_status',pv.version_status,
      'product_type',pv.product_type,
      'title',pv.title,
      'intended_audience',pv.intended_audience,
      'editorial_status',pv.status,
      'information_cutoff_date',pv.evidence_cutoff_date,
      'publication_date',pv.publication_date
    ) FROM pv
 ),'{}'::jsonb),
 'source_context',COALESCE((
    SELECT jsonb_build_object(
      'investigation_id',ctx.investigation_id,
      'investigation_entity_uuid',ctx.entity_uuid,
      'investigation_version_uuid',ctx.version_uuid,
      'version_no',ctx.version_no,
      'version_status',ctx.version_status,
      'investigation_type',ctx.investigation_type,
      'depth_level',ctx.depth_level,
      'maintenance_level',ctx.maintenance_level,
      'objective',ctx.objective,
      'evidence_cutoff_date',ctx.evidence_cutoff_date,
      'status',ctx.status
    ) FROM ctx
 ),'{}'::jsonb),
 'alert',COALESCE((
    SELECT jsonb_build_object(
      'headline',a.headline,
      'summary',a.summary,
      'signal_date',a.signal_date,
      'detected_at',a.detected_at,
      'issued_at',a.issued_at,
      'classification',a.classification,
      'reassessment_priority',a.reassessment_priority,
      'lifecycle_status',a.lifecycle_status,
      'justification',a.justification,
      'assessed_by',a.assessed_by,
      'actor_type',a.actor_type,
      'verification',jsonb_build_object(
         'status',a.verification_status,
         'verified_by',a.verified_by,
         'verifier_actor_type',a.verifier_actor_type,
         'verified_at',a.verified_at
      ),
      'resolution_rationale',a.resolution_rationale,
      'incorporated_version_uuid',a.incorporated_version_uuid,
      'incorporated_currency_state_uuid',a.incorporated_currency_state_uuid
    ) FROM a
 ),'{}'::jsonb),
 'target',COALESCE((
    SELECT CASE WHEN a.target_product_version_uuid IS NOT NULL THEN
      jsonb_build_object(
        'target_type','product_version',
        'target_product_id',tp.target_product_id,
        'target_product_entity_uuid',tp.entity_uuid,
        'target_product_version_uuid',tp.version_uuid,
        'product_type',tp.product_type,
        'title',tp.title,
        'version_no',tp.version_no,
        'version_status',tp.version_status,
        'editorial_status',tp.status,
        'publication_date',tp.publication_date,
        'evidence_cutoff_date',tp.evidence_cutoff_date,
        'depth_level',tpi.depth_level,
        'maintenance_level',tpi.maintenance_level,
        'primary_investigation_id',tpi.investigation_id,
        'assurance_level',product.assurance_level(tp.version_uuid),
        'currency',jsonb_build_object(
           'status',tp.currency_status,
           'assessed_at',tp.currency_assessed_at,
           'assessed_by',tp.currency_assessed_by,
           'rationale',tp.currency_rationale
        ),
        'scientific_conclusion',tp.conclusion_text,
        'applicability_summary',tp.applicability_summary,
        'limitations_summary',tp.limitations_summary
      )
    ELSE
      jsonb_build_object(
        'target_type','investigation_version',
        'target_investigation_id',ti.investigation_id,
        'target_investigation_entity_uuid',ti.entity_uuid,
        'target_investigation_version_uuid',ti.version_uuid,
        'version_no',ti.version_no,
        'version_status',ti.version_status,
        'investigation_type',ti.investigation_type,
        'depth_level',ti.depth_level,
        'maintenance_level',ti.maintenance_level,
        'objective',ti.objective,
        'evidence_cutoff_date',ti.evidence_cutoff_date,
        'status',ti.status,
        'assurance_level',NULL,
        'currency',NULL,
        'scientific_conclusion',NULL
      ) END
      FROM a
      LEFT JOIN tp ON true
      LEFT JOIN tpi ON true
      LEFT JOIN ti ON true
 ),'{}'::jsonb),
 'sources',COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'alert_source_uuid',s.alert_source_uuid,
        'source_role',s.source_role,
        'source_type',s.source_type,
        'source_date',s.source_date,
        'description',s.description,
        'sequence_no',s.sequence_no,
        'candidate_assessment_uuid',s.candidate_assessment_uuid,
        'evidence_event_uuid',s.evidence_event_uuid,
        'source_entity_version_uuid',s.source_entity_version_uuid,
        'source_artifact_uuid',s.source_artifact_uuid,
        'source_uri',s.source_uri,
        'source_entity',CASE WHEN s.source_entity_version_uuid IS NULL THEN NULL ELSE (
            SELECT jsonb_build_object(
              'entity_id',e.oes_id,'entity_type',e.entity_type,
              'version_status',ev.version_status,
              'dependency_active',EXISTS(
                 SELECT 1 FROM provenance.dependency_edge de
                  WHERE de.source_version_uuid=s.source_entity_version_uuid
                    AND de.target_version_uuid=p_product_version_uuid
                    AND de.dependency_type='maintenance_alert_source'
                    AND de.status='active'
              )
            )
              FROM core.entity_version ev JOIN core.entity e ON e.entity_uuid=ev.entity_uuid
             WHERE ev.version_uuid=s.source_entity_version_uuid
        ) END,
        'monitor_origin',CASE
          WHEN s.candidate_assessment_uuid IS NOT NULL THEN (
            SELECT jsonb_build_object(
              'monitor_product_version_uuid',mc.monitor_product_version_uuid,
              'monitor_product_id',me.oes_id,
              'cycle_uuid',mc.cycle_uuid,
              'cycle_no',mc.cycle_no,
              'candidate_decision',ca.decision,
              'candidate_record_status',ca.record_status
            )
              FROM maintenance.candidate_assessment ca
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ca.cycle_uuid
              JOIN product.product_version mpv ON mpv.version_uuid=mc.monitor_product_version_uuid
              JOIN core.entity me ON me.entity_uuid=mpv.entity_uuid
             WHERE ca.candidate_assessment_uuid=s.candidate_assessment_uuid
          )
          WHEN s.evidence_event_uuid IS NOT NULL THEN (
            SELECT jsonb_build_object(
              'monitor_product_version_uuid',mc.monitor_product_version_uuid,
              'monitor_product_id',me.oes_id,
              'cycle_uuid',mc.cycle_uuid,
              'cycle_no',mc.cycle_no,
              'event_type',ee.event_type,
              'event_status',ee.status
            )
              FROM maintenance.evidence_event ee
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ee.cycle_uuid
              JOIN product.product_version mpv ON mpv.version_uuid=mc.monitor_product_version_uuid
              JOIN core.entity me ON me.entity_uuid=mpv.entity_uuid
             WHERE ee.evidence_event_uuid=s.evidence_event_uuid
          )
          ELSE NULL END,
        'issues',COALESCE((
           SELECT jsonb_agg(jsonb_build_object(
                    'code',si.issue_code,'severity',si.severity,'message',si.message
                  ) ORDER BY si.severity,si.issue_code)
             FROM maintenance.evidence_alert_source_issues(p_product_version_uuid) si
            WHERE si.alert_source_uuid=s.alert_source_uuid
        ),'[]'::jsonb)
      ) ORDER BY s.sequence_no NULLS LAST,s.alert_source_uuid
    )
      FROM maintenance.alert_source s
     WHERE s.alert_product_version_uuid=p_product_version_uuid
 ),'[]'::jsonb),
 'affected_dimensions',COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
       'dimension_code',d.dimension_code,
       'rationale',d.rationale,
       'sequence_no',d.sequence_no
    ) ORDER BY d.sequence_no NULLS LAST,d.dimension_code)
      FROM maintenance.alert_affected_dimension d
     WHERE d.alert_product_version_uuid=p_product_version_uuid
 ),'[]'::jsonb),
 'lineage',jsonb_build_object(
    'dependencies',COALESCE((
       SELECT jsonb_agg(jsonb_build_object(
          'source_version_uuid',de.source_version_uuid,
          'target_version_uuid',de.target_version_uuid,
          'dependency_type',de.dependency_type,
          'derivation_rule',de.derivation_rule,
          'status',de.status
       ) ORDER BY de.dependency_type,de.source_version_uuid,de.target_version_uuid)
         FROM provenance.dependency_edge de
        WHERE de.source_version_uuid=p_product_version_uuid
           OR de.target_version_uuid=p_product_version_uuid
    ),'[]'::jsonb)
 ),
 'limitations',COALESCE((
    SELECT jsonb_build_object(
      'summary',pv.limitations_summary,
      'applicability_summary',pv.applicability_summary
    ) FROM pv
 ),'{}'::jsonb),
 'audit',jsonb_build_object(
    'synthetic_fixture',COALESCE((SELECT intended_audience='architecture_validation' FROM pv),false),
    'assurance_level',product.assurance_level(p_product_version_uuid),
    'target_assurance_level',(
       SELECT CASE WHEN a.target_product_version_uuid IS NULL THEN NULL
              ELSE product.assurance_level(a.target_product_version_uuid) END FROM a
    ),
    'verification_status',(SELECT verification_status FROM a),
    'verifier_actor_type',(SELECT verifier_actor_type FROM a),
    'publishable',product.evidence_alert_is_publishable(p_product_version_uuid),
    'expert_independent_review_present',EXISTS(
       SELECT 1 FROM product.assurance_record ar
        WHERE ar.product_version_uuid=p_product_version_uuid
          AND ar.status='active'
          AND ar.assurance_type='expert_independent_review'
          AND ar.decision='approved'
    ),
    'publication_issues',COALESCE((
       SELECT jsonb_agg(jsonb_build_object(
          'code',bi.issue_code,'severity',bi.severity,'message',bi.message
       ) ORDER BY bi.severity,bi.issue_code,bi.message)
         FROM base_issues bi
    ),'[]'::jsonb),
    'projection_hardening_issues',COALESCE((
       SELECT jsonb_agg(jsonb_build_object(
          'code',hi.issue_code,'severity',hi.severity,'message',hi.message
       ) ORDER BY hi.severity,hi.issue_code,hi.message)
         FROM hard_issues hi
    ),'[]'::jsonb),
    'assurance_records',COALESCE((
       SELECT jsonb_agg(jsonb_build_object(
          'assurance_uuid',ar.assurance_uuid,
          'assurance_type',ar.assurance_type,
          'actor',ar.actor,
          'actor_type',ar.actor_type,
          'independent',ar.independent_flag,
          'decision',ar.decision,
          'performed_at',ar.performed_at,
          'notes',ar.notes
       ) ORDER BY ar.performed_at,ar.assurance_uuid)
         FROM product.assurance_record ar
        WHERE ar.product_version_uuid=p_product_version_uuid
          AND ar.status='active'
    ),'[]'::jsonb)
 )
);
$view$;

COMMIT;
