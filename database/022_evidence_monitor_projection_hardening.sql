-- OES-DBM-2026-0022
-- Fase 3 — Evidence Monitor projection-readiness hardening
-- Depends on: migrations 002–021
-- Date: 2026-10-06
-- Additive semantic hardening; does not create EvidenceMonitorView.

BEGIN;

-- ---------------------------------------------------------------------------
-- CANDIDATE IMPACTS — normalized 1:N impact cardinality
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.candidate_impact (
    candidate_impact_uuid uuid PRIMARY KEY,
    candidate_assessment_uuid uuid NOT NULL
        REFERENCES maintenance.candidate_assessment(candidate_assessment_uuid),
    impact_class text NOT NULL CHECK (
        impact_class IN (
            'quantitative',
            'certainty',
            'applicability',
            'conclusion',
            'validity',
            'scope'
        )
    ),
    is_primary boolean NOT NULL DEFAULT false,
    impact_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text,
    sequence_no integer,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (candidate_assessment_uuid,impact_class),
    CHECK (jsonb_typeof(impact_payload)='object')
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_candidate_impact_primary
    ON maintenance.candidate_impact(candidate_assessment_uuid)
    WHERE is_primary;

CREATE OR REPLACE FUNCTION maintenance.assert_candidate_impact_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    ca maintenance.candidate_assessment%ROWTYPE;
    cycle_status text;
BEGIN
    SELECT * INTO ca
      FROM maintenance.candidate_assessment
     WHERE candidate_assessment_uuid=NEW.candidate_assessment_uuid;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'CandidateImpact requires an existing CandidateAssessment';
    END IF;

    SELECT mc.execution_status INTO cycle_status
      FROM maintenance.monitor_cycle mc
     WHERE mc.cycle_uuid=ca.cycle_uuid;

    IF cycle_status NOT IN ('planned','running') THEN
        RAISE EXCEPTION
            'CandidateImpact can be added only while MonitorCycle is open';
    END IF;

    IF ca.record_status<>'active'
       OR ca.decision<>'retained_for_impact' THEN
        RAISE EXCEPTION
            'CandidateImpact requires an active retained_for_impact CandidateAssessment';
    END IF;

    IF NEW.is_primary
       AND ca.impact_class IS DISTINCT FROM NEW.impact_class THEN
        RAISE EXCEPTION
            'Primary CandidateImpact must match CandidateAssessment impact_class summary';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_candidate_impact_consistency
    ON maintenance.candidate_impact;
CREATE TRIGGER tr_candidate_impact_consistency
BEFORE INSERT ON maintenance.candidate_impact
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_candidate_impact_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_candidate_impact_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'CandidateImpact is immutable; supersede the CandidateAssessment instead';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_candidate_impact_immutable
    ON maintenance.candidate_impact;
CREATE TRIGGER tr_candidate_impact_immutable
BEFORE UPDATE OR DELETE ON maintenance.candidate_impact
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_candidate_impact_mutation();

-- ---------------------------------------------------------------------------
-- NORMALIZED SOURCE REQUIREMENTS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.monitor_source_requirement (
    source_requirement_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    requirement_code text NOT NULL CHECK (
        length(btrim(requirement_code))>0
    ),
    requirement_kind text NOT NULL CHECK (
        requirement_kind IN (
            'source_name',
            'source_class',
            'minimum_distinct_bibliographic_sources'
        )
    ),
    required_value text,
    minimum_count integer,
    allow_exception boolean NOT NULL DEFAULT true,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    sequence_no integer,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (monitor_product_version_uuid,requirement_code),
    CHECK (
        (
            requirement_kind IN ('source_name','source_class')
            AND length(btrim(COALESCE(required_value,'')))>0
            AND minimum_count IS NULL
        )
        OR
        (
            requirement_kind='minimum_distinct_bibliographic_sources'
            AND required_value IS NULL
            AND minimum_count IS NOT NULL
            AND minimum_count>0
        )
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_monitor_source_requirement_value
    ON maintenance.monitor_source_requirement(
        monitor_product_version_uuid,requirement_kind,required_value
    )
    WHERE requirement_kind IN ('source_name','source_class');

CREATE UNIQUE INDEX IF NOT EXISTS ux_monitor_source_requirement_min_bib
    ON maintenance.monitor_source_requirement(monitor_product_version_uuid)
    WHERE requirement_kind='minimum_distinct_bibliographic_sources';

CREATE OR REPLACE FUNCTION maintenance.assert_monitor_source_requirement()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    ptype text;
BEGIN
    SELECT pv.product_type INTO ptype
      FROM product.product_version pv
     WHERE pv.version_uuid=NEW.monitor_product_version_uuid;

    IF ptype IS DISTINCT FROM 'evidence_monitor' THEN
        RAISE EXCEPTION
            'SourceRequirement requires an evidence_monitor ProductVersion';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_definition md
         WHERE md.monitor_product_version_uuid=NEW.monitor_product_version_uuid
    ) THEN
        RAISE EXCEPTION
            'SourceRequirement requires MonitorDefinition';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle mc
         WHERE mc.monitor_product_version_uuid=NEW.monitor_product_version_uuid
    ) THEN
        RAISE EXCEPTION
            'SourceRequirements are frozen once the first MonitorCycle exists; create a new Monitor ProductVersion';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_monitor_source_requirement_consistency
    ON maintenance.monitor_source_requirement;
CREATE TRIGGER tr_monitor_source_requirement_consistency
BEFORE INSERT ON maintenance.monitor_source_requirement
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_monitor_source_requirement();

CREATE OR REPLACE FUNCTION maintenance.guard_monitor_source_requirement_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'SourceRequirement is immutable within a Monitor ProductVersion';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_monitor_source_requirement_immutable
    ON maintenance.monitor_source_requirement;
CREATE TRIGGER tr_monitor_source_requirement_immutable
BEFORE UPDATE OR DELETE ON maintenance.monitor_source_requirement
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_monitor_source_requirement_mutation();

-- ---------------------------------------------------------------------------
-- METHOD-DECISION EXCEPTION HELPER
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.has_monitor_method_exception(
    p_investigation_version_uuid uuid,
    p_decision_code text,
    p_cycle_uuid uuid,
    p_ref_key text DEFAULT NULL,
    p_ref_value text DEFAULT NULL
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $q$
    SELECT EXISTS (
        SELECT 1
          FROM investigation.method_decision md
         WHERE md.investigation_version_uuid=p_investigation_version_uuid
           AND md.record_status='active'
           AND md.stage='search'
           AND md.decision_code=p_decision_code
           AND md.resolution_status IN ('accepted','mitigated')
           AND md.impact_payload->>'cycle_uuid'=p_cycle_uuid::text
           AND (
                p_ref_key IS NULL
                OR jsonb_extract_path_text(md.impact_payload,p_ref_key)=p_ref_value
           )
    );
$q$;

-- ---------------------------------------------------------------------------
-- SOURCE-POLICY NORMALIZATION ISSUES
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_source_policy_issues(
    p_monitor_product_version_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    policy jsonb;
    val text;
    min_bib integer;
BEGIN
    SELECT md.source_policy_payload INTO policy
      FROM maintenance.monitor_definition md
     WHERE md.monitor_product_version_uuid=p_monitor_product_version_uuid;

    IF policy IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_MONITOR_DEFINITION','error',
            'MonitorDefinition/source policy is absent';
        RETURN;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_source_requirement msr
         WHERE msr.monitor_product_version_uuid=p_monitor_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_NORMALIZED_SOURCE_REQUIREMENTS','error',
            'Monitor source policy has no normalized SourceRequirement rows';
        RETURN;
    END IF;

    FOR val IN
        SELECT jsonb_array_elements_text(
            COALESCE(policy->'required_source_names','[]'::jsonb)
        )
    LOOP
        IF NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_source_requirement msr
             WHERE msr.monitor_product_version_uuid=p_monitor_product_version_uuid
               AND msr.requirement_kind='source_name'
               AND msr.required_value=val
        ) THEN
            RETURN QUERY SELECT
                'SOURCE_POLICY_REQUIRED_NAME_NOT_NORMALIZED','error',
                format(
                    'Declared required source name %s is not normalized',
                    val
                );
        END IF;
    END LOOP;

    FOR val IN
        SELECT jsonb_array_elements_text(
            COALESCE(policy->'required_source_classes','[]'::jsonb)
        )
    LOOP
        IF NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_source_requirement msr
             WHERE msr.monitor_product_version_uuid=p_monitor_product_version_uuid
               AND msr.requirement_kind='source_class'
               AND msr.required_value=val
        ) THEN
            RETURN QUERY SELECT
                'SOURCE_POLICY_REQUIRED_CLASS_NOT_NORMALIZED','error',
                format(
                    'Declared required source class %s is not normalized',
                    val
                );
        END IF;
    END LOOP;

    IF policy ? 'minimum_bibliographic_sources' THEN
        BEGIN
            min_bib:=(policy->>'minimum_bibliographic_sources')::integer;
        EXCEPTION WHEN others THEN
            RETURN QUERY SELECT
                'SOURCE_POLICY_MINIMUM_BIBLIOGRAPHIC_MISMATCH','error',
                'minimum_bibliographic_sources is not a valid integer';
            RETURN;
        END;

        IF NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_source_requirement msr
             WHERE msr.monitor_product_version_uuid=p_monitor_product_version_uuid
               AND msr.requirement_kind=
                   'minimum_distinct_bibliographic_sources'
               AND msr.minimum_count=min_bib
        ) THEN
            RETURN QUERY SELECT
                'SOURCE_POLICY_MINIMUM_BIBLIOGRAPHIC_MISMATCH','error',
                format(
                    'Declared minimum_bibliographic_sources=%s is not normalized',
                    min_bib
                );
        END IF;
    END IF;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- SEARCH TEMPORAL ACCEPTABILITY
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_search_temporally_acceptable(
    p_cycle_uuid uuid,
    p_search_uuid uuid
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    c maintenance.monitor_cycle%ROWTYPE;
    s investigation.search%ROWTYPE;
    monitor_inv uuid;
BEGIN
    SELECT * INTO c
      FROM maintenance.monitor_cycle
     WHERE cycle_uuid=p_cycle_uuid;

    SELECT * INTO s
      FROM investigation.search
     WHERE search_uuid=p_search_uuid;

    IF NOT FOUND OR c.cycle_uuid IS NULL THEN
        RETURN false;
    END IF;

    monitor_inv:=maintenance.monitor_primary_investigation(
        c.monitor_product_version_uuid
    );

    IF monitor_inv IS NULL
       OR s.investigation_version_uuid<>monitor_inv
       OR s.status<>'completed' THEN
        RETURN false;
    END IF;

    IF s.executed_at::date BETWEEN c.window_start_date AND c.window_end_date THEN
        RETURN true;
    END IF;

    RETURN maintenance.has_monitor_method_exception(
        monitor_inv,
        'monitor_search_temporal_exception',
        c.cycle_uuid,
        'search_uuid',
        s.search_uuid::text
    );
END;
$fn$;

-- ---------------------------------------------------------------------------
-- SOURCE REQUIREMENT STATUS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_source_requirement_status(
    p_cycle_uuid uuid
)
RETURNS TABLE (
    source_requirement_uuid uuid,
    requirement_code text,
    requirement_kind text,
    required_value text,
    minimum_count integer,
    fulfilled boolean,
    exception_applied boolean,
    exception_method_decision_uuid uuid,
    satisfied boolean,
    evidence_payload jsonb
)
LANGUAGE sql
STABLE
AS $q$
WITH cycle_context AS (
    SELECT
        mc.cycle_uuid,
        mc.monitor_product_version_uuid,
        maintenance.monitor_primary_investigation(
            mc.monitor_product_version_uuid
        ) AS monitor_investigation_version_uuid
      FROM maintenance.monitor_cycle mc
     WHERE mc.cycle_uuid=p_cycle_uuid
),
req AS (
    SELECT msr.*,cc.monitor_investigation_version_uuid
      FROM cycle_context cc
      JOIN maintenance.monitor_source_requirement msr
        ON msr.monitor_product_version_uuid=
           cc.monitor_product_version_uuid
),
eval AS (
    SELECT
        r.*,
        CASE
            WHEN r.requirement_kind='source_name' THEN EXISTS (
                SELECT 1
                  FROM maintenance.cycle_search cs
                  JOIN investigation.search s
                    ON s.search_uuid=cs.search_uuid
                 WHERE cs.cycle_uuid=p_cycle_uuid
                   AND s.source_name=r.required_value
                   AND maintenance.monitor_search_temporally_acceptable(
                       p_cycle_uuid,s.search_uuid
                   )
            )
            WHEN r.requirement_kind='source_class' THEN EXISTS (
                SELECT 1
                  FROM maintenance.cycle_search cs
                  JOIN investigation.search s
                    ON s.search_uuid=cs.search_uuid
                 WHERE cs.cycle_uuid=p_cycle_uuid
                   AND s.filters_payload->>'source_class'=r.required_value
                   AND maintenance.monitor_search_temporally_acceptable(
                       p_cycle_uuid,s.search_uuid
                   )
            )
            WHEN r.requirement_kind=
                 'minimum_distinct_bibliographic_sources' THEN (
                SELECT count(DISTINCT s.source_name)
                  FROM maintenance.cycle_search cs
                  JOIN investigation.search s
                    ON s.search_uuid=cs.search_uuid
                 WHERE cs.cycle_uuid=p_cycle_uuid
                   AND s.filters_payload->>'source_class'='bibliographic'
                   AND maintenance.monitor_search_temporally_acceptable(
                       p_cycle_uuid,s.search_uuid
                   )
            ) >= r.minimum_count
            ELSE false
        END AS is_fulfilled
      FROM req r
),
exceptions AS (
    SELECT
        e.*,
        md.method_decision_uuid AS exception_uuid
      FROM eval e
      LEFT JOIN LATERAL (
          SELECT md0.method_decision_uuid
            FROM investigation.method_decision md0
           WHERE e.allow_exception
             AND md0.investigation_version_uuid=
                 e.monitor_investigation_version_uuid
             AND md0.record_status='active'
             AND md0.stage='search'
             AND md0.decision_code='monitor_source_requirement_exception'
             AND md0.resolution_status IN ('accepted','mitigated')
             AND md0.impact_payload->>'cycle_uuid'=p_cycle_uuid::text
             AND md0.impact_payload->>'requirement_code'=
                 e.requirement_code
           ORDER BY md0.decided_at DESC,md0.method_decision_uuid
           LIMIT 1
      ) md ON true
)
SELECT
    e.source_requirement_uuid,
    e.requirement_code,
    e.requirement_kind,
    e.required_value,
    e.minimum_count,
    e.is_fulfilled,
    (NOT e.is_fulfilled AND e.exception_uuid IS NOT NULL) AS exception_applied,
    CASE
        WHEN NOT e.is_fulfilled THEN e.exception_uuid
        ELSE NULL
    END,
    (e.is_fulfilled OR e.exception_uuid IS NOT NULL) AS satisfied,
    jsonb_build_object(
        'matched_search_uuids',
        COALESCE((
            SELECT jsonb_agg(x.search_uuid ORDER BY x.search_uuid)
              FROM (
                SELECT DISTINCT s.search_uuid
                  FROM maintenance.cycle_search cs
                  JOIN investigation.search s
                    ON s.search_uuid=cs.search_uuid
                 WHERE cs.cycle_uuid=p_cycle_uuid
                   AND maintenance.monitor_search_temporally_acceptable(
                       p_cycle_uuid,s.search_uuid
                   )
                   AND (
                        (e.requirement_kind='source_name'
                         AND s.source_name=e.required_value)
                        OR
                        (e.requirement_kind='source_class'
                         AND s.filters_payload->>'source_class'=e.required_value)
                        OR
                        (e.requirement_kind=
                         'minimum_distinct_bibliographic_sources'
                         AND s.filters_payload->>'source_class'='bibliographic')
                   )
              ) x
        ),'[]'::jsonb),
        'exception_method_decision_uuid',
        CASE
            WHEN NOT e.is_fulfilled AND e.exception_uuid IS NOT NULL
            THEN to_jsonb(e.exception_uuid)
            ELSE 'null'::jsonb
        END
    ) AS evidence_payload
  FROM exceptions e
 ORDER BY e.sequence_no NULLS LAST,e.requirement_code;
$q$;

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_source_coverage(
    p_cycle_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $q$
    SELECT
        EXISTS (
            SELECT 1
              FROM maintenance.monitor_source_requirement msr
              JOIN maintenance.monitor_cycle mc
                ON mc.monitor_product_version_uuid=
                   msr.monitor_product_version_uuid
             WHERE mc.cycle_uuid=p_cycle_uuid
        )
        AND NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_cycle_source_requirement_status(
                   p_cycle_uuid
              ) rs
             WHERE NOT rs.satisfied
        );
$q$;

-- ---------------------------------------------------------------------------
-- TEMPORAL ISSUES
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_temporal_issues(
    p_cycle_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    c maintenance.monitor_cycle%ROWTYPE;
    prev maintenance.monitor_cycle%ROWTYPE;
    baseline date;
    monitor_inv uuid;
    cs record;
    gap_start date;
    gap_ref_key text;
    gap_ref_value text;
BEGIN
    SELECT * INTO c
      FROM maintenance.monitor_cycle
     WHERE cycle_uuid=p_cycle_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_CYCLE','error','Monitor cycle does not exist';
        RETURN;
    END IF;

    SELECT pv.evidence_cutoff_date INTO baseline
      FROM product.product_version pv
     WHERE pv.version_uuid=c.monitor_product_version_uuid;

    monitor_inv:=maintenance.monitor_primary_investigation(
        c.monitor_product_version_uuid
    );

    IF baseline IS NOT NULL
       AND c.window_start_date<baseline THEN
        RETURN QUERY SELECT
            'CYCLE_WINDOW_BEFORE_BASELINE','error',
            format(
                'Cycle window starts %s before Monitor baseline cutoff %s',
                c.window_start_date,baseline
            );
    END IF;

    IF c.execution_status IN ('completed','incomplete','cancelled')
       AND c.completed_at IS NOT NULL
       AND c.window_end_date>c.completed_at::date THEN
        RETURN QUERY SELECT
            'CYCLE_WINDOW_AFTER_COMPLETION','error',
            format(
                'Cycle window ends %s after completion date %s',
                c.window_end_date,c.completed_at::date
            );
    END IF;

    IF c.cycle_no>1 AND c.previous_cycle_uuid IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PREVIOUS_CYCLE_LINK','error',
            'Cycle number greater than 1 requires previous_cycle_uuid';
    END IF;

    IF c.previous_cycle_uuid IS NOT NULL THEN
        SELECT * INTO prev
          FROM maintenance.monitor_cycle
         WHERE cycle_uuid=c.previous_cycle_uuid;

        IF prev.cycle_uuid IS NOT NULL
           AND c.window_start_date>prev.window_end_date+1 THEN
            gap_ref_key:='previous_cycle_uuid';
            gap_ref_value:=prev.cycle_uuid::text;

            IF NOT maintenance.has_monitor_method_exception(
                monitor_inv,
                'monitor_cycle_window_gap_exception',
                c.cycle_uuid,
                gap_ref_key,
                gap_ref_value
            ) THEN
                RETURN QUERY SELECT
                    'UNEXPLAINED_CYCLE_WINDOW_GAP','error',
                    format(
                        'Gap exists between previous cycle end %s and current cycle start %s',
                        prev.window_end_date,c.window_start_date
                    );
            END IF;
        END IF;
    ELSIF c.cycle_no=1
          AND baseline IS NOT NULL
          AND c.window_start_date>baseline+1 THEN
        IF NOT maintenance.has_monitor_method_exception(
            monitor_inv,
            'monitor_cycle_window_gap_exception',
            c.cycle_uuid,
            NULL,
            NULL
        ) THEN
            RETURN QUERY SELECT
                'UNEXPLAINED_CYCLE_WINDOW_GAP','error',
                format(
                    'Gap exists between baseline cutoff %s and first cycle start %s',
                    baseline,c.window_start_date
                );
        END IF;
    END IF;

    FOR cs IN
        SELECT
            s.search_uuid,
            s.investigation_version_uuid,
            s.executed_at,
            s.status
          FROM maintenance.cycle_search l
          JOIN investigation.search s
            ON s.search_uuid=l.search_uuid
         WHERE l.cycle_uuid=c.cycle_uuid
    LOOP
        IF cs.investigation_version_uuid IS DISTINCT FROM monitor_inv THEN
            RETURN QUERY SELECT
                'SEARCH_INVESTIGATION_DRIFT','error',
                format(
                    'Linked Search %s no longer belongs to Monitor Investigation',
                    cs.search_uuid
                );
        END IF;

        IF cs.status<>'completed' THEN
            RETURN QUERY SELECT
                'SEARCH_NOT_COMPLETED','error',
                format(
                    'Linked Search %s is not completed',
                    cs.search_uuid
                );
        END IF;

        IF cs.executed_at IS NULL
           OR cs.executed_at::date<c.window_start_date
           OR cs.executed_at::date>c.window_end_date THEN
            IF NOT maintenance.has_monitor_method_exception(
                monitor_inv,
                'monitor_search_temporal_exception',
                c.cycle_uuid,
                'search_uuid',
                cs.search_uuid::text
            ) THEN
                RETURN QUERY SELECT
                    'SEARCH_OUTSIDE_CYCLE_WINDOW','error',
                    format(
                        'Linked Search %s execution timestamp is outside cycle window',
                        cs.search_uuid
                    );
            END IF;
        END IF;
    END LOOP;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- CYCLE LIFECYCLE HARDENING
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.assert_monitor_cycle_lifecycle()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    prev_monitor uuid;
    prev_no integer;
    prev_window_end date;
    active_operational_status text;
    product_type_value text;
    baseline date;
    monitor_inv uuid;
    temporal_error_count integer;
    policy_error_count integer;
BEGIN
    SELECT pv.product_type,pv.evidence_cutoff_date
      INTO product_type_value,baseline
      FROM product.product_version pv
     WHERE pv.version_uuid=NEW.monitor_product_version_uuid;

    IF product_type_value IS DISTINCT FROM 'evidence_monitor'
       OR NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_definition md
             WHERE md.monitor_product_version_uuid=NEW.monitor_product_version_uuid
       )
       OR NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_target mt
             WHERE mt.monitor_product_version_uuid=NEW.monitor_product_version_uuid
       ) THEN
        RAISE EXCEPTION
            'MonitorCycle requires a configured evidence_monitor ProductVersion';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM maintenance.monitor_source_policy_issues(
               NEW.monitor_product_version_uuid
          )
         WHERE severity='error'
    ) THEN
        RAISE EXCEPTION
            'MonitorCycle requires normalized, internally consistent source policy';
    END IF;

    IF NEW.window_start_date<baseline THEN
        RAISE EXCEPTION
            'MonitorCycle window cannot start before Monitor baseline cutoff';
    END IF;

    IF NEW.started_at IS NOT NULL
       AND NEW.planned_at IS NOT NULL
       AND NEW.started_at<NEW.planned_at THEN
        RAISE EXCEPTION 'MonitorCycle started_at cannot precede planned_at';
    END IF;

    IF NEW.completed_at IS NOT NULL
       AND NEW.started_at IS NOT NULL
       AND NEW.completed_at<NEW.started_at THEN
        RAISE EXCEPTION 'MonitorCycle completed_at cannot precede started_at';
    END IF;

    IF NEW.execution_status IN ('completed','incomplete','cancelled')
       AND NEW.completed_at IS NOT NULL
       AND NEW.window_end_date>NEW.completed_at::date THEN
        RAISE EXCEPTION
            'MonitorCycle window cannot end after completion date';
    END IF;

    monitor_inv:=maintenance.monitor_primary_investigation(
        NEW.monitor_product_version_uuid
    );

    IF NEW.previous_cycle_uuid IS NOT NULL THEN
        SELECT monitor_product_version_uuid,cycle_no,window_end_date
          INTO prev_monitor,prev_no,prev_window_end
          FROM maintenance.monitor_cycle
         WHERE cycle_uuid=NEW.previous_cycle_uuid;

        IF prev_monitor IS NULL
           OR prev_monitor<>NEW.monitor_product_version_uuid
           OR prev_no>=NEW.cycle_no THEN
            RAISE EXCEPTION
                'previous_cycle_uuid must reference an earlier cycle of the same Monitor';
        END IF;

        IF NEW.window_start_date>prev_window_end+1
           AND NOT maintenance.has_monitor_method_exception(
                monitor_inv,
                'monitor_cycle_window_gap_exception',
                NEW.cycle_uuid,
                'previous_cycle_uuid',
                NEW.previous_cycle_uuid::text
           ) THEN
            RAISE EXCEPTION
                'MonitorCycle contains an unexplained gap after previous cycle';
        END IF;
    ELSIF NEW.cycle_no>1 THEN
        RAISE EXCEPTION
            'cycle_no > 1 requires previous_cycle_uuid';
    ELSIF NEW.cycle_no=1
          AND NEW.window_start_date>baseline+1
          AND NOT maintenance.has_monitor_method_exception(
              monitor_inv,
              'monitor_cycle_window_gap_exception',
              NEW.cycle_uuid,
              NULL,
              NULL
          ) THEN
        RAISE EXCEPTION
            'First MonitorCycle contains an unexplained gap after baseline';
    END IF;

    IF NEW.execution_status='running' AND NEW.started_at IS NULL THEN
        RAISE EXCEPTION 'running cycle requires started_at';
    END IF;

    IF NEW.execution_status IN ('completed','incomplete')
       AND NEW.started_at IS NULL THEN
        RAISE EXCEPTION 'completed/incomplete cycle requires started_at';
    END IF;

    IF NEW.execution_status IN ('completed','incomplete','cancelled')
       AND NEW.completed_at IS NULL THEN
        RAISE EXCEPTION 'terminal cycle requires completed_at';
    END IF;

    IF NEW.execution_status='completed' THEN
        IF NEW.completeness_status<>'complete' THEN
            RAISE EXCEPTION
                'completed cycle requires completeness_status=complete';
        END IF;

        IF NEW.maintenance_decision IS NULL
           OR btrim(COALESCE(NEW.decision_rationale,''))=''
           OR btrim(COALESCE(NEW.decided_by,''))=''
           OR NEW.actor_type IS NULL THEN
            RAISE EXCEPTION
                'completed cycle requires decision, rationale and decision actor';
        END IF;

        IF NOT maintenance.monitor_cycle_source_coverage(NEW.cycle_uuid) THEN
            RAISE EXCEPTION
                'completed cycle does not satisfy normalized source requirements';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM maintenance.cycle_search l
              JOIN investigation.search s
                ON s.search_uuid=l.search_uuid
             WHERE l.cycle_uuid=NEW.cycle_uuid
               AND (
                    s.investigation_version_uuid<>monitor_inv
                    OR s.status<>'completed'
                    OR (
                        (
                            s.executed_at IS NULL
                            OR s.executed_at::date<NEW.window_start_date
                            OR s.executed_at::date>NEW.window_end_date
                        )
                        AND NOT maintenance.has_monitor_method_exception(
                            monitor_inv,
                            'monitor_search_temporal_exception',
                            NEW.cycle_uuid,
                            'search_uuid',
                            s.search_uuid::text
                        )
                    )
               )
        ) THEN
            RAISE EXCEPTION
                'completed cycle has invalid or temporally incompatible Search linkage';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM maintenance.candidate_assessment ca
             WHERE ca.cycle_uuid=NEW.cycle_uuid
               AND ca.record_status='active'
               AND ca.decision='pending'
        ) THEN
            RAISE EXCEPTION
                'completed cycle cannot retain pending CandidateAssessment';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM maintenance.evidence_event ee
             WHERE ee.cycle_uuid=NEW.cycle_uuid
               AND ee.status='active'
               AND NOT EXISTS (
                    SELECT 1
                      FROM maintenance.candidate_assessment ca
                     WHERE ca.cycle_uuid=NEW.cycle_uuid
                       AND ca.record_status='active'
                       AND ca.origin_type='evidence_event'
                       AND ca.origin_evidence_event_uuid=ee.evidence_event_uuid
               )
        ) THEN
            RAISE EXCEPTION
                'completed cycle cannot contain unassessed active EvidenceEvent';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM maintenance.candidate_assessment ca
             WHERE ca.cycle_uuid=NEW.cycle_uuid
               AND ca.record_status='active'
               AND ca.decision='retained_for_impact'
               AND (
                    (SELECT count(*)
                       FROM maintenance.candidate_impact ci
                      WHERE ci.candidate_assessment_uuid=
                            ca.candidate_assessment_uuid)=0
                    OR
                    (SELECT count(*)
                       FROM maintenance.candidate_impact ci
                      WHERE ci.candidate_assessment_uuid=
                            ca.candidate_assessment_uuid
                        AND ci.is_primary)<>1
                    OR NOT EXISTS (
                        SELECT 1
                          FROM maintenance.candidate_impact ci
                         WHERE ci.candidate_assessment_uuid=
                               ca.candidate_assessment_uuid
                           AND ci.is_primary
                           AND ci.impact_class=ca.impact_class
                    )
               )
        ) THEN
            RAISE EXCEPTION
                'retained candidate requires normalized impacts with one matching primary impact';
        END IF;
    END IF;

    IF NEW.maintenance_decision='no_update_needed'
       AND NEW.execution_status<>'completed' THEN
        RAISE EXCEPTION
            'no_update_needed requires a completed cycle';
    END IF;

    IF NEW.execution_status IN ('incomplete','cancelled')
       AND NEW.maintenance_decision='no_update_needed' THEN
        RAISE EXCEPTION
            'incomplete/cancelled cycle cannot assert no_update_needed';
    END IF;

    IF NEW.verification_status='unverified' THEN
        IF NEW.verified_by IS NOT NULL
           OR NEW.verifier_actor_type IS NOT NULL
           OR NEW.verified_at IS NOT NULL THEN
            RAISE EXCEPTION
                'unverified cycle cannot contain verifier metadata';
        END IF;
    ELSIF NEW.verification_status='ai_verified' THEN
        IF NEW.verifier_actor_type<>'ai_system'
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'ai_verified cycle requires AI verifier metadata';
        END IF;
    ELSIF NEW.verification_status IN ('human_verified','human_consensus') THEN
        IF NEW.verifier_actor_type NOT IN ('human_reviewer','human_expert')
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'human verified cycle requires human verifier metadata';
        END IF;
    END IF;

    IF NEW.execution_status='running' THEN
        SELECT ms.operational_status
          INTO active_operational_status
          FROM maintenance.monitor_state ms
         WHERE ms.monitor_product_version_uuid=NEW.monitor_product_version_uuid
           AND ms.record_status='active';

        IF active_operational_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION
                'Only operationally active Monitor can start a running cycle';
        END IF;
    END IF;

    IF TG_OP='UPDATE' THEN
        IF OLD.execution_status IN ('completed','incomplete','cancelled') THEN
            RAISE EXCEPTION
                'Terminal MonitorCycle is immutable';
        END IF;

        IF OLD.execution_status='planned'
           AND NEW.execution_status NOT IN (
               'planned','running','completed','incomplete','cancelled'
           ) THEN
            RAISE EXCEPTION 'Invalid cycle transition';
        END IF;

        IF OLD.execution_status='running'
           AND NEW.execution_status NOT IN (
               'running','completed','incomplete','cancelled'
           ) THEN
            RAISE EXCEPTION 'Invalid cycle transition';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- CYCLE ISSUES — replace with normalized coverage + temporal issues
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_issues(
    p_cycle_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    c maintenance.monitor_cycle%ROWTYPE;
    t maintenance.monitor_target%ROWTYPE;
BEGIN
    SELECT * INTO c
      FROM maintenance.monitor_cycle
     WHERE cycle_uuid=p_cycle_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_CYCLE','error','Monitor cycle does not exist';
        RETURN;
    END IF;

    SELECT * INTO t
      FROM maintenance.monitor_target
     WHERE monitor_product_version_uuid=c.monitor_product_version_uuid;

    RETURN QUERY
    SELECT ti.issue_code,ti.severity,ti.message
      FROM maintenance.monitor_cycle_temporal_issues(c.cycle_uuid) ti;

    IF c.execution_status='completed'
       AND NOT maintenance.monitor_cycle_source_coverage(c.cycle_uuid) THEN
        RETURN QUERY SELECT
            'INCOMPLETE_REQUIRED_SOURCE_COVERAGE','error',
            'Completed cycle does not satisfy normalized source requirements';
    END IF;

    IF c.execution_status='completed'
       AND EXISTS (
            SELECT 1
              FROM maintenance.candidate_assessment ca
             WHERE ca.cycle_uuid=c.cycle_uuid
               AND ca.record_status='active'
               AND ca.decision='pending'
       ) THEN
        RETURN QUERY SELECT
            'PENDING_CYCLE_CANDIDATE','error',
            'Completed cycle still has pending candidate assessments';
    END IF;

    IF c.execution_status='completed'
       AND EXISTS (
            SELECT 1
              FROM maintenance.evidence_event ee
             WHERE ee.cycle_uuid=c.cycle_uuid
               AND ee.status='active'
               AND NOT EXISTS (
                    SELECT 1
                      FROM maintenance.candidate_assessment ca
                     WHERE ca.cycle_uuid=c.cycle_uuid
                       AND ca.record_status='active'
                       AND ca.origin_type='evidence_event'
                       AND ca.origin_evidence_event_uuid=ee.evidence_event_uuid
               )
       ) THEN
        RETURN QUERY SELECT
            'UNASSESSED_MATERIAL_EVENT','error',
            'Completed cycle contains active EvidenceEvent without CandidateAssessment';
    END IF;

    IF c.execution_status='completed'
       AND EXISTS (
            SELECT 1
              FROM maintenance.candidate_assessment ca
             WHERE ca.cycle_uuid=c.cycle_uuid
               AND ca.record_status='active'
               AND ca.decision='retained_for_impact'
               AND (
                    (SELECT count(*)
                       FROM maintenance.candidate_impact ci
                      WHERE ci.candidate_assessment_uuid=
                            ca.candidate_assessment_uuid)=0
                    OR
                    (SELECT count(*)
                       FROM maintenance.candidate_impact ci
                      WHERE ci.candidate_assessment_uuid=
                            ca.candidate_assessment_uuid
                        AND ci.is_primary)<>1
                    OR NOT EXISTS (
                        SELECT 1
                          FROM maintenance.candidate_impact ci
                         WHERE ci.candidate_assessment_uuid=
                               ca.candidate_assessment_uuid
                           AND ci.is_primary
                           AND ci.impact_class=ca.impact_class
                    )
               )
       ) THEN
        RETURN QUERY SELECT
            'CANDIDATE_IMPACT_INCOMPLETE','error',
            'Retained CandidateAssessment lacks coherent normalized CandidateImpact rows';
    END IF;

    IF c.execution_status<>'completed'
       AND c.maintenance_decision='no_update_needed' THEN
        RETURN QUERY SELECT
            'NO_UPDATE_FROM_INCOMPLETE_CYCLE','error',
            'Incomplete cycle cannot assert no update needed';
    END IF;

    IF c.execution_status='completed'
       AND t.target_product_version_uuid IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
              FROM maintenance.cycle_currency_state ccs
             WHERE ccs.cycle_uuid=c.cycle_uuid
       ) THEN
        RETURN QUERY SELECT
            'MISSING_CYCLE_CURRENCY_STATE','error',
            'Completed Product-target cycle requires resulting target CurrencyState';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM maintenance.evidence_event ee
          JOIN maintenance.candidate_assessment ca
            ON ca.origin_evidence_event_uuid=ee.evidence_event_uuid
           AND ca.cycle_uuid=ee.cycle_uuid
           AND ca.record_status='active'
         WHERE ee.cycle_uuid=c.cycle_uuid
           AND ee.status='invalidated'
           AND ca.decision='retained_for_impact'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_EVENT_RETAINED','error',
            'Invalidated EvidenceEvent remains retained for impact';
    END IF;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- CYCLE → CURRENCY STATE IMMUTABILITY
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.guard_cycle_currency_state_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'CycleCurrencyState is immutable; record a new cycle/currentness assessment instead';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_cycle_currency_state_immutable
    ON maintenance.cycle_currency_state;
CREATE TRIGGER tr_cycle_currency_state_immutable
BEFORE UPDATE OR DELETE ON maintenance.cycle_currency_state
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_cycle_currency_state_mutation();

-- ---------------------------------------------------------------------------
-- PRODUCT-LEVEL PROJECTION HARDENING ISSUES
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_monitor_projection_hardening_issues(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    c record;
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.product_version pv
         WHERE pv.version_uuid=p_product_version_uuid
           AND pv.product_type='evidence_monitor'
    ) THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT spi.issue_code,spi.severity,spi.message
      FROM maintenance.monitor_source_policy_issues(
           p_product_version_uuid
      ) spi;

    FOR c IN
        SELECT mc.cycle_uuid,mc.cycle_no
          FROM maintenance.monitor_cycle mc
         WHERE mc.monitor_product_version_uuid=p_product_version_uuid
           AND mc.execution_status='completed'
         ORDER BY mc.cycle_no
    LOOP
        RETURN QUERY
        SELECT
            ci.issue_code,
            ci.severity,
            format(
                'Cycle %s (%s): %s',
                c.cycle_no,c.cycle_uuid,ci.message
            )
          FROM maintenance.monitor_cycle_issues(c.cycle_uuid) ci
         WHERE ci.severity='error';
    END LOOP;
END;
$fn$;

CREATE OR REPLACE FUNCTION product.evidence_monitor_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $q$
    SELECT
        NOT EXISTS (
            SELECT 1
              FROM product.evidence_monitor_publication_issues(
                   p_product_version_uuid
              )
             WHERE severity='error'
        )
        AND NOT EXISTS (
            SELECT 1
              FROM product.evidence_monitor_projection_hardening_issues(
                   p_product_version_uuid
              )
             WHERE severity='error'
        );
$q$;

COMMIT;
