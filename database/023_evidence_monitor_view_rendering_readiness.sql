-- OES-DBM-2026-0023
-- Fase 3 — EvidenceMonitorView 0.1 rendering-readiness projection
-- Depends on: migrations 002–022
-- Date: 2026-10-06
-- Read-only projection. Does not alter Monitor persistence or start Phase 4.

BEGIN;

-- ---------------------------------------------------------------------------
-- TARGET PROJECTION
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_monitor_target_projection(
    p_monitor_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $target$
WITH mt AS (
    SELECT *
      FROM maintenance.monitor_target
     WHERE monitor_product_version_uuid=p_monitor_product_version_uuid
),
target_product AS (
    SELECT
        pv.*,
        pe.oes_id AS product_id,
        ev.version_no,
        ev.version_status,
        cs.currency_status,
        cs.assessed_at AS currency_assessed_at,
        cs.assessed_by AS currency_assessed_by,
        cs.rationale AS currency_rationale
      FROM mt
      JOIN product.product_version pv
        ON pv.version_uuid=mt.target_product_version_uuid
      JOIN core.entity pe
        ON pe.entity_uuid=pv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=pv.version_uuid
      LEFT JOIN LATERAL (
          SELECT *
            FROM product.currency_state cs0
           WHERE cs0.product_version_uuid=pv.version_uuid
             AND cs0.record_status='active'
           ORDER BY cs0.assessed_at DESC,cs0.currency_state_uuid
           LIMIT 1
      ) cs ON true
),
target_product_inv AS (
    SELECT
        iv.*,
        ie.oes_id AS investigation_id,
        iev.version_no AS investigation_version_no,
        iev.version_status AS investigation_version_status
      FROM mt
      JOIN product.investigation_link il
        ON il.product_version_uuid=mt.target_product_version_uuid
       AND il.role='primary'
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity ie
        ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version iev
        ON iev.version_uuid=iv.version_uuid
     ORDER BY il.sequence_no NULLS LAST,iv.version_uuid
     LIMIT 1
),
target_inv AS (
    SELECT
        iv.*,
        ie.oes_id AS investigation_id,
        iev.version_no AS investigation_version_no,
        iev.version_status AS investigation_version_status
      FROM mt
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=mt.target_investigation_version_uuid
      JOIN core.entity ie
        ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version iev
        ON iev.version_uuid=iv.version_uuid
),
dep AS (
    SELECT de.*
      FROM mt
      JOIN provenance.dependency_edge de
        ON de.source_version_uuid=COALESCE(
             mt.target_product_version_uuid,
             mt.target_investigation_version_uuid
           )
       AND de.target_version_uuid=p_monitor_product_version_uuid
       AND de.dependency_type='maintenance_surveillance_target'
     ORDER BY CASE de.status WHEN 'active' THEN 0 ELSE 1 END,de.created_at DESC
     LIMIT 1
)
SELECT COALESCE((
    SELECT CASE
        WHEN mt.target_product_version_uuid IS NOT NULL THEN
            jsonb_build_object(
                'target_type','product_version',
                'target_product_version_uuid',tp.version_uuid,
                'target_product_entity_uuid',tp.entity_uuid,
                'target_product_id',tp.product_id,
                'target_product_type',tp.product_type,
                'title',tp.title,
                'version_no',tp.version_no,
                'version_status',tp.version_status,
                'editorial_status',tp.status,
                'publication_date',tp.publication_date,
                'baseline_evidence_cutoff_date',tp.evidence_cutoff_date,
                'depth_level',tpi.depth_level,
                'maintenance_level',tpi.maintenance_level,
                'primary_investigation_id',tpi.investigation_id,
                'primary_investigation_version_uuid',tpi.version_uuid,
                'assurance_level',product.assurance_level(tp.version_uuid),
                'currency',jsonb_build_object(
                    'status',tp.currency_status,
                    'assessed_at',tp.currency_assessed_at,
                    'assessed_by',tp.currency_assessed_by,
                    'rationale',tp.currency_rationale
                ),
                'scientific_conclusion',tp.conclusion_text,
                'applicability_summary',tp.applicability_summary,
                'limitations_summary',tp.limitations_summary,
                'linkage_rationale',mt.rationale,
                'dependency',CASE
                    WHEN dep.source_version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'source_version_uuid',dep.source_version_uuid,
                        'target_version_uuid',dep.target_version_uuid,
                        'dependency_type',dep.dependency_type,
                        'derivation_rule',dep.derivation_rule,
                        'status',dep.status
                    )
                END
            )
        ELSE
            jsonb_build_object(
                'target_type','investigation_version',
                'target_investigation_version_uuid',ti.version_uuid,
                'target_investigation_entity_uuid',ti.entity_uuid,
                'target_investigation_id',ti.investigation_id,
                'version_no',ti.investigation_version_no,
                'version_status',ti.investigation_version_status,
                'investigation_type',ti.investigation_type,
                'depth_level',ti.depth_level,
                'maintenance_level',ti.maintenance_level,
                'objective',ti.objective,
                'baseline_evidence_cutoff_date',ti.evidence_cutoff_date,
                'status',ti.status,
                'assurance_level',NULL,
                'currency',NULL,
                'scientific_conclusion',NULL,
                'linkage_rationale',mt.rationale,
                'dependency',CASE
                    WHEN dep.source_version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'source_version_uuid',dep.source_version_uuid,
                        'target_version_uuid',dep.target_version_uuid,
                        'dependency_type',dep.dependency_type,
                        'derivation_rule',dep.derivation_rule,
                        'status',dep.status
                    )
                END
            )
        END
      FROM mt
      LEFT JOIN target_product tp ON true
      LEFT JOIN target_product_inv tpi ON true
      LEFT JOIN target_inv ti ON true
      LEFT JOIN dep ON true
),'{}'::jsonb);
$target$;

-- ---------------------------------------------------------------------------
-- CYCLE PROJECTION
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_projection(
    p_cycle_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $cycle$
WITH c AS (
    SELECT *
      FROM maintenance.monitor_cycle
     WHERE cycle_uuid=p_cycle_uuid
)
SELECT COALESCE((
    SELECT jsonb_build_object(
        'cycle_uuid',c.cycle_uuid,
        'cycle_no',c.cycle_no,
        'previous_cycle_uuid',c.previous_cycle_uuid,
        'window',jsonb_build_object(
            'start_date',c.window_start_date,
            'end_date',c.window_end_date
        ),
        'execution',jsonb_build_object(
            'planned_at',c.planned_at,
            'started_at',c.started_at,
            'completed_at',c.completed_at,
            'status',c.execution_status,
            'completeness_status',c.completeness_status,
            'payload',c.execution_payload
        ),
        'searches',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'search_uuid',s.search_uuid,
                    'oes_search_id',s.oes_search_id,
                    'search_role',cs.search_role,
                    'sequence_no',cs.sequence_no,
                    'source_name',s.source_name,
                    'platform',s.platform,
                    'source_class',s.filters_payload->>'source_class',
                    'exact_strategy',s.exact_strategy,
                    'filters',s.filters_payload,
                    'executed_at',s.executed_at,
                    'result_count',s.result_count,
                    'strategy_version',s.strategy_version,
                    'operator',s.operator,
                    'status',s.status,
                    'temporally_acceptable',
                        maintenance.monitor_search_temporally_acceptable(
                            c.cycle_uuid,s.search_uuid
                        ),
                    'export_artifact_uuid',s.export_artifact_uuid,
                    'search_hits',COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'search_hit_uuid',sh.search_hit_uuid,
                                'oes_search_hit_id',sh.oes_search_hit_id,
                                'report_entity_uuid',sh.report_entity_uuid,
                                'report_id',re.oes_id,
                                'source_record_id',sh.source_record_id,
                                'raw_title',sh.raw_title,
                                'raw_authors',sh.raw_authors,
                                'raw_year',sh.raw_year,
                                'raw_identifier',sh.raw_identifier,
                                'source_rank',sh.source_rank,
                                'resolution_status',sh.resolution_status,
                                'imported_at',sh.imported_at
                            )
                            ORDER BY sh.source_rank NULLS LAST,sh.search_hit_uuid
                        )
                          FROM investigation.search_hit sh
                          LEFT JOIN core.entity re
                            ON re.entity_uuid=sh.report_entity_uuid
                         WHERE sh.search_uuid=s.search_uuid
                    ),'[]'::jsonb)
                )
                ORDER BY cs.sequence_no NULLS LAST,s.executed_at,s.search_uuid
            )
              FROM maintenance.cycle_search cs
              JOIN investigation.search s
                ON s.search_uuid=cs.search_uuid
             WHERE cs.cycle_uuid=c.cycle_uuid
        ),'[]'::jsonb),
        'source_requirement_status',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'source_requirement_uuid',rs.source_requirement_uuid,
                    'requirement_code',rs.requirement_code,
                    'requirement_kind',rs.requirement_kind,
                    'required_value',rs.required_value,
                    'minimum_count',rs.minimum_count,
                    'fulfilled',rs.fulfilled,
                    'exception_applied',rs.exception_applied,
                    'exception_method_decision_uuid',
                        rs.exception_method_decision_uuid,
                    'satisfied',rs.satisfied,
                    'evidence',rs.evidence_payload
                )
                ORDER BY rs.requirement_code
            )
              FROM maintenance.monitor_cycle_source_requirement_status(
                   c.cycle_uuid
              ) rs
        ),'[]'::jsonb),
        'temporal_issues',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code',ti.issue_code,
                    'severity',ti.severity,
                    'message',ti.message
                )
                ORDER BY ti.severity,ti.issue_code,ti.message
            )
              FROM maintenance.monitor_cycle_temporal_issues(
                   c.cycle_uuid
              ) ti
        ),'[]'::jsonb),
        'events',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'evidence_event_uuid',ee.evidence_event_uuid,
                    'event_type',ee.event_type,
                    'event_date',ee.event_date,
                    'detected_at',ee.detected_at,
                    'report_relation_uuid',ee.report_relation_uuid,
                    'affected_version_uuid',ee.affected_version_uuid,
                    'source_artifact_uuid',ee.source_artifact_uuid,
                    'source_uri',ee.source_uri,
                    'description',ee.description,
                    'event_payload',ee.event_payload,
                    'detected_by',ee.detected_by,
                    'actor_type',ee.actor_type,
                    'verification_status',ee.verification_status,
                    'verified_by',ee.verified_by,
                    'verifier_actor_type',ee.verifier_actor_type,
                    'verified_at',ee.verified_at,
                    'status',ee.status
                )
                ORDER BY ee.detected_at,ee.evidence_event_uuid
            )
              FROM maintenance.evidence_event ee
             WHERE ee.cycle_uuid=c.cycle_uuid
        ),'[]'::jsonb),
        'candidates',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'candidate_assessment_uuid',ca.candidate_assessment_uuid,
                    'origin_type',ca.origin_type,
                    'origin',jsonb_build_object(
                        'search_hit_uuid',ca.origin_search_hit_uuid,
                        'entity_uuid',ca.origin_entity_uuid,
                        'entity_id',oe.oes_id,
                        'entity_type',oe.entity_type,
                        'evidence_event_uuid',ca.origin_evidence_event_uuid
                    ),
                    'resolved_target',CASE
                        WHEN ca.resolved_target_entity_uuid IS NULL THEN NULL
                        ELSE jsonb_build_object(
                            'entity_uuid',ca.resolved_target_entity_uuid,
                            'entity_id',rte.oes_id,
                            'entity_type',rte.entity_type
                        )
                    END,
                    'candidate_kind',ca.candidate_kind,
                    'decision',ca.decision,
                    'exclusion_reason',ca.exclusion_reason,
                    'primary_impact_class',ca.impact_class,
                    'legacy_impact_payload',ca.impact_payload,
                    'impacts',COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'candidate_impact_uuid',ci.candidate_impact_uuid,
                                'impact_class',ci.impact_class,
                                'is_primary',ci.is_primary,
                                'impact_payload',ci.impact_payload,
                                'rationale',ci.rationale,
                                'sequence_no',ci.sequence_no
                            )
                            ORDER BY
                                CASE WHEN ci.is_primary THEN 0 ELSE 1 END,
                                ci.sequence_no NULLS LAST,
                                ci.impact_class
                        )
                          FROM maintenance.candidate_impact ci
                         WHERE ci.candidate_assessment_uuid=
                               ca.candidate_assessment_uuid
                    ),'[]'::jsonb),
                    'assessed_by',ca.assessed_by,
                    'actor_type',ca.actor_type,
                    'verification_status',ca.verification_status,
                    'verified_by',ca.verified_by,
                    'verifier_actor_type',ca.verifier_actor_type,
                    'verified_at',ca.verified_at,
                    'assessed_at',ca.assessed_at,
                    'record_status',ca.record_status,
                    'supersedes_candidate_assessment_uuid',
                        ca.supersedes_candidate_assessment_uuid
                )
                ORDER BY ca.assessed_at,ca.candidate_assessment_uuid
            )
              FROM maintenance.candidate_assessment ca
              LEFT JOIN core.entity oe
                ON oe.entity_uuid=ca.origin_entity_uuid
              LEFT JOIN core.entity rte
                ON rte.entity_uuid=ca.resolved_target_entity_uuid
             WHERE ca.cycle_uuid=c.cycle_uuid
        ),'[]'::jsonb),
        'maintenance_decision',jsonb_build_object(
            'decision',c.maintenance_decision,
            'rationale',c.decision_rationale,
            'decided_by',c.decided_by,
            'actor_type',c.actor_type
        ),
        'verification',jsonb_build_object(
            'status',c.verification_status,
            'verified_by',c.verified_by,
            'verifier_actor_type',c.verifier_actor_type,
            'verified_at',c.verified_at
        ),
        'escalation_recommendation',c.escalation_recommendation,
        'resulting_target_currency',COALESCE((
            SELECT jsonb_build_object(
                'currency_state_uuid',cs.currency_state_uuid,
                'product_version_uuid',cs.product_version_uuid,
                'currency_status',cs.currency_status,
                'assessed_at',cs.assessed_at,
                'assessed_by',cs.assessed_by,
                'rationale',cs.rationale,
                'record_status',cs.record_status
            )
              FROM maintenance.cycle_currency_state ccs
              JOIN product.currency_state cs
                ON cs.currency_state_uuid=ccs.currency_state_uuid
             WHERE ccs.cycle_uuid=c.cycle_uuid
        ),'null'::jsonb),
        'issues',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code',ci.issue_code,
                    'severity',ci.severity,
                    'message',ci.message
                )
                ORDER BY ci.severity,ci.issue_code,ci.message
            )
              FROM maintenance.monitor_cycle_issues(c.cycle_uuid) ci
        ),'[]'::jsonb)
    )
      FROM c
),'{}'::jsonb);
$cycle$;

-- ---------------------------------------------------------------------------
-- EVIDENCE MONITOR VIEW
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_monitor_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $view$
WITH
pv AS (
    SELECT
        pv.*,
        pe.oes_id AS product_id,
        ev.version_no,
        ev.version_status,
        cs.currency_status,
        cs.assessed_at AS currency_assessed_at,
        cs.assessed_by AS currency_assessed_by,
        cs.rationale AS currency_rationale
      FROM product.product_version pv
      JOIN core.entity pe
        ON pe.entity_uuid=pv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=pv.version_uuid
      LEFT JOIN LATERAL (
          SELECT *
            FROM product.currency_state cs0
           WHERE cs0.product_version_uuid=pv.version_uuid
             AND cs0.record_status='active'
           ORDER BY cs0.assessed_at DESC,cs0.currency_state_uuid
           LIMIT 1
      ) cs ON true
     WHERE pv.version_uuid=p_product_version_uuid
),
inv AS (
    SELECT
        iv.*,
        ie.oes_id AS investigation_id,
        iev.version_no AS investigation_version_no,
        iev.version_status AS investigation_version_status
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity ie
        ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version iev
        ON iev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='primary'
     ORDER BY il.sequence_no NULLS LAST,iv.version_uuid
     LIMIT 1
),
q AS (
    SELECT
        qv.*,
        qe.oes_id AS question_id
      FROM inv
      JOIN investigation.investigation_question iq
        ON iq.investigation_version_uuid=inv.version_uuid
       AND iq.role='primary'
      JOIN investigation.question_version qv
        ON qv.version_uuid=iq.question_version_uuid
      JOIN core.entity qe
        ON qe.entity_uuid=qv.entity_uuid
     ORDER BY iq.sequence_no NULLS LAST,qv.version_uuid
     LIMIT 1
),
def AS (
    SELECT *
      FROM maintenance.monitor_definition
     WHERE monitor_product_version_uuid=p_product_version_uuid
),
op AS (
    SELECT *
      FROM maintenance.monitor_state
     WHERE monitor_product_version_uuid=p_product_version_uuid
       AND record_status='active'
     ORDER BY effective_at DESC,monitor_state_uuid
     LIMIT 1
),
mt AS (
    SELECT *
      FROM maintenance.monitor_target
     WHERE monitor_product_version_uuid=p_product_version_uuid
),
base_issues AS (
    SELECT *
      FROM product.evidence_monitor_publication_issues(
           p_product_version_uuid
      )
),
hard_issues AS (
    SELECT *
      FROM product.evidence_monitor_projection_hardening_issues(
           p_product_version_uuid
      )
),
latest_cycle AS (
    SELECT *
      FROM maintenance.monitor_cycle
     WHERE monitor_product_version_uuid=p_product_version_uuid
     ORDER BY cycle_no DESC,cycle_uuid
     LIMIT 1
),
latest_completed AS (
    SELECT *
      FROM maintenance.monitor_cycle
     WHERE monitor_product_version_uuid=p_product_version_uuid
       AND execution_status='completed'
     ORDER BY cycle_no DESC,cycle_uuid
     LIMIT 1
)
SELECT jsonb_build_object(
    'schema_version','oes.evidence_monitor_view/0.1',

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
            'publication_date',pv.publication_date,
            'baseline_evidence_cutoff_date',pv.evidence_cutoff_date
        )
          FROM pv
    ),'{}'::jsonb),

    'question',COALESCE((
        SELECT jsonb_build_object(
            'question_id',q.question_id,
            'question_entity_uuid',q.entity_uuid,
            'question_version_uuid',q.version_uuid,
            'original_text',q.original_text,
            'normalized_text',q.normalized_text,
            'question_type',q.question_type,
            'structure_type',q.structure_type,
            'context',q.context_payload,
            'time_horizon',q.time_horizon_payload
        )
          FROM q
    ),'{}'::jsonb),

    'monitor_investigation',COALESCE((
        SELECT jsonb_build_object(
            'investigation_id',inv.investigation_id,
            'investigation_entity_uuid',inv.entity_uuid,
            'investigation_version_uuid',inv.version_uuid,
            'version_no',inv.investigation_version_no,
            'version_status',inv.investigation_version_status,
            'investigation_type',inv.investigation_type,
            'depth_level',inv.depth_level,
            'maintenance_level',inv.maintenance_level,
            'objective',inv.objective,
            'protocol_artifact_uuid',inv.protocol_artifact_uuid,
            'start_date',inv.start_date,
            'baseline_evidence_cutoff_date',inv.evidence_cutoff_date,
            'status',inv.status
        )
          FROM inv
    ),'{}'::jsonb),

    'protocol',COALESCE((
        SELECT jsonb_build_object(
            'artifact_uuid',a.artifact_uuid,
            'artifact_type',a.artifact_type,
            'storage_key',a.storage_key,
            'content_hash',a.content_hash,
            'hash_algorithm',a.hash_algorithm,
            'mime_type',a.mime_type,
            'created_at',a.created_at,
            'status',a.status
        )
          FROM inv
          JOIN artifact.artifact a
            ON a.artifact_uuid=inv.protocol_artifact_uuid
    ),'{}'::jsonb),

    'monitor_plan',jsonb_build_object(
        'surveillance_scope',COALESCE(
            (SELECT surveillance_scope_payload FROM def),
            '{}'::jsonb
        ),
        'source_policy',COALESCE(
            (SELECT source_policy_payload FROM def),
            '{}'::jsonb
        ),
        'source_requirements',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'source_requirement_uuid',msr.source_requirement_uuid,
                    'requirement_code',msr.requirement_code,
                    'requirement_kind',msr.requirement_kind,
                    'required_value',msr.required_value,
                    'minimum_count',msr.minimum_count,
                    'allow_exception',msr.allow_exception,
                    'rationale',msr.rationale,
                    'sequence_no',msr.sequence_no
                )
                ORDER BY msr.sequence_no NULLS LAST,msr.requirement_code
            )
              FROM maintenance.monitor_source_requirement msr
             WHERE msr.monitor_product_version_uuid=p_product_version_uuid
        ),'[]'::jsonb),
        'strategy_policy',COALESCE(
            (SELECT strategy_policy_payload FROM def),
            '{}'::jsonb
        ),
        'cadence_policy',COALESCE(
            (SELECT cadence_policy_payload FROM def),
            '{}'::jsonb
        ),
        'impact_policy',COALESCE(
            (SELECT impact_policy_payload FROM def),
            '{}'::jsonb
        ),
        'escalation_policy',COALESCE(
            (SELECT escalation_policy_payload FROM def),
            '{}'::jsonb
        )
    ),

    'operational_state',COALESCE((
        SELECT jsonb_build_object(
            'monitor_state_uuid',op.monitor_state_uuid,
            'status',op.operational_status,
            'effective_at',op.effective_at,
            'rationale',op.rationale,
            'changed_by',op.changed_by,
            'actor_type',op.actor_type
        )
          FROM op
    ),'{}'::jsonb),

    'monitor_currency',COALESCE((
        SELECT jsonb_build_object(
            'status',pv.currency_status,
            'assessed_at',pv.currency_assessed_at,
            'assessed_by',pv.currency_assessed_by,
            'rationale',pv.currency_rationale
        )
          FROM pv
    ),'{}'::jsonb),

    'target',
        product.evidence_monitor_target_projection(
            p_product_version_uuid
        ),

    'latest_cycle',COALESCE((
        SELECT maintenance.monitor_cycle_projection(lc.cycle_uuid)
          FROM latest_cycle lc
    ),'{}'::jsonb),

    'latest_completed_cycle',COALESCE((
        SELECT maintenance.monitor_cycle_projection(lc.cycle_uuid)
          FROM latest_completed lc
    ),'{}'::jsonb),

    'cycles',COALESCE((
        SELECT jsonb_agg(
            maintenance.monitor_cycle_projection(mc.cycle_uuid)
            ORDER BY mc.cycle_no,mc.cycle_uuid
        )
          FROM maintenance.monitor_cycle mc
         WHERE mc.monitor_product_version_uuid=p_product_version_uuid
    ),'[]'::jsonb),

    'method_decisions',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'method_decision_uuid',md.method_decision_uuid,
                'decision_type',md.decision_type,
                'stage',md.stage,
                'decision_code',md.decision_code,
                'planned',md.planned_flag,
                'rationale',md.rationale,
                'risk',md.risk_payload,
                'mitigation',md.mitigation_payload,
                'impact',md.impact_payload,
                'resolution_status',md.resolution_status,
                'decided_by',md.decided_by,
                'decided_at',md.decided_at,
                'linked_artifact_uuid',md.linked_artifact_uuid
            )
            ORDER BY md.decided_at,md.method_decision_uuid
        )
          FROM inv
          JOIN investigation.method_decision md
            ON md.investigation_version_uuid=inv.version_uuid
           AND md.record_status='active'
           AND (
                md.decision_code LIKE 'monitor_%'
                OR md.decision_type IN ('protocol_deviation','method_change')
           )
    ),'[]'::jsonb),

    'quality_controls',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'quality_control_uuid',qc.quality_control_uuid,
                'stage',qc.stage,
                'control_type',qc.control_type,
                'control_code',qc.scope_payload->>'control_code',
                'actor',qc.actor,
                'actor_type',qc.actor_type,
                'qualification',qc.qualification_payload,
                'independent',qc.independent_flag,
                'decision',qc.decision,
                'scope',qc.scope_payload,
                'agreement',qc.agreement_payload,
                'discrepancy',qc.discrepancy_payload,
                'resolution',qc.resolution_payload,
                'performed_at',qc.performed_at,
                'evidence_artifact_uuid',qc.evidence_artifact_uuid,
                'notes',qc.notes
            )
            ORDER BY qc.performed_at,qc.quality_control_uuid
        )
          FROM inv
          JOIN investigation.quality_control_record qc
            ON qc.investigation_version_uuid=inv.version_uuid
           AND qc.record_status='active'
    ),'[]'::jsonb),

    'update_lineage',jsonb_build_object(
        'target_dependency',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'source_version_uuid',de.source_version_uuid,
                    'target_version_uuid',de.target_version_uuid,
                    'dependency_type',de.dependency_type,
                    'derivation_rule',de.derivation_rule,
                    'status',de.status
                )
                ORDER BY de.source_version_uuid,de.dependency_type
            )
              FROM mt
              JOIN provenance.dependency_edge de
                ON de.source_version_uuid=COALESCE(
                     mt.target_product_version_uuid,
                     mt.target_investigation_version_uuid
                   )
               AND de.target_version_uuid=p_product_version_uuid
               AND de.dependency_type='maintenance_surveillance_target'
        ),'[]'::jsonb),
        'derived_updates',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'provenance_uuid',pr.provenance_uuid,
                    'target_version_uuid',pr.target_version_uuid,
                    'field_path',pr.field_path,
                    'source_location',pr.source_location,
                    'process_type',pr.process_type,
                    'process_record_uuid',pr.process_record_uuid,
                    'actor',pr.actor,
                    'status',pr.status,
                    'invalidated_at',pr.invalidated_at,
                    'invalidation_reason',pr.invalidation_reason
                )
                ORDER BY pr.target_version_uuid,pr.provenance_uuid
            )
              FROM provenance.record pr
             WHERE pr.process_type='monitor_cycle'
               AND pr.process_record_uuid IN (
                    SELECT mc.cycle_uuid
                      FROM maintenance.monitor_cycle mc
                     WHERE mc.monitor_product_version_uuid=
                           p_product_version_uuid
               )
        ),'[]'::jsonb)
    ),

    'limitations',COALESCE((
        SELECT jsonb_build_object(
            'limitations_summary',pv.limitations_summary,
            'applicability_summary',pv.applicability_summary
        )
          FROM pv
    ),'{}'::jsonb),

    'audit',jsonb_build_object(
        'synthetic_fixture',COALESCE((
            SELECT pv.intended_audience='architecture_validation'
              FROM pv
        ),false),
        'assurance_level',
            product.assurance_level(p_product_version_uuid),
        'target_assurance_level',(
            SELECT CASE
                WHEN mt.target_product_version_uuid IS NULL THEN NULL
                ELSE product.assurance_level(
                    mt.target_product_version_uuid
                )
            END
              FROM mt
        ),
        'required_assurance_level',(
            SELECT CASE
                WHEN inv.maintenance_level='M2' THEN 'A2'
                ELSE NULL
            END
              FROM inv
        ),
        'publishable',
            product.evidence_monitor_is_publishable(
                p_product_version_uuid
            ),
        'monitor_operational_status',
            (SELECT operational_status FROM op),
        'monitor_currency_status',
            (SELECT currency_status FROM pv),
        'target_currency_status',(
            SELECT CASE
                WHEN mt.target_product_version_uuid IS NULL THEN NULL
                ELSE (
                    SELECT cs.currency_status
                      FROM product.currency_state cs
                     WHERE cs.product_version_uuid=
                           mt.target_product_version_uuid
                       AND cs.record_status='active'
                     ORDER BY cs.assessed_at DESC,cs.currency_state_uuid
                     LIMIT 1
                )
            END
              FROM mt
        ),
        'maintenance_level',
            (SELECT maintenance_level FROM inv),
        'baseline_evidence_cutoff_date',
            (SELECT evidence_cutoff_date FROM pv),
        'latest_completed_cycle_uuid',
            (SELECT cycle_uuid FROM latest_completed),
        'latest_completed_cycle_cutoff_date',
            (SELECT window_end_date FROM latest_completed),
        'latest_cycle_verification_status',
            (SELECT verification_status FROM latest_cycle),
        'pending_candidate_count',COALESCE((
            SELECT count(*)
              FROM maintenance.candidate_assessment ca
              JOIN maintenance.monitor_cycle mc
                ON mc.cycle_uuid=ca.cycle_uuid
             WHERE mc.monitor_product_version_uuid=p_product_version_uuid
               AND ca.record_status='active'
               AND ca.decision='pending'
        ),0),
        'active_event_count',COALESCE((
            SELECT count(*)
              FROM maintenance.evidence_event ee
              JOIN maintenance.monitor_cycle mc
                ON mc.cycle_uuid=ee.cycle_uuid
             WHERE mc.monitor_product_version_uuid=p_product_version_uuid
               AND ee.status='active'
        ),0),
        'required_source_coverage_satisfied',COALESCE((
            SELECT maintenance.monitor_cycle_source_coverage(
                lc.cycle_uuid
            )
              FROM latest_completed lc
        ),false),
        'invalidated_dependencies',EXISTS (
            SELECT 1
              FROM base_issues
             WHERE issue_code='INVALIDATED_DEPENDENCY'
               AND severity='error'
        ),
        'm3_transversal_update_policy_operational',false,
        'publication_issues',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code',bi.issue_code,
                    'severity',bi.severity,
                    'message',bi.message
                )
                ORDER BY bi.severity,bi.issue_code,bi.message
            )
              FROM base_issues bi
        ),'[]'::jsonb),
        'projection_hardening_issues',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code',hi.issue_code,
                    'severity',hi.severity,
                    'message',hi.message
                )
                ORDER BY hi.severity,hi.issue_code,hi.message
            )
              FROM hard_issues hi
        ),'[]'::jsonb),
        'assurance_records',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'assurance_uuid',ar.assurance_uuid,
                    'assurance_type',ar.assurance_type,
                    'actor',ar.actor,
                    'actor_type',ar.actor_type,
                    'independent',ar.independent_flag,
                    'decision',ar.decision,
                    'performed_at',ar.performed_at,
                    'notes',ar.notes,
                    'evidence',ar.evidence_payload
                )
                ORDER BY ar.performed_at,ar.assurance_uuid
            )
              FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
               AND ar.status='active'
        ),'[]'::jsonb)
    )
);
$view$;

COMMIT;
