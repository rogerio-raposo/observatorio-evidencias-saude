-- OES migration 033a — temporal observation plan/source/epoch/authority core

CREATE TABLE IF NOT EXISTS maintenance.temporal_observation_plan (
    observation_plan_uuid uuid PRIMARY KEY,
    plan_code text NOT NULL,
    plan_version integer NOT NULL CHECK (plan_version >= 1),
    supersedes_observation_plan_uuid uuid REFERENCES maintenance.temporal_observation_plan(observation_plan_uuid),
    target_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
    calibration_object text NOT NULL CHECK (calibration_object = 'cadence'),
    readiness_scope text NOT NULL CHECK (readiness_scope IN ('policy_aggregate','source_specific')),
    specification_artifact_uuid uuid NOT NULL REFERENCES artifact.artifact(artifact_uuid),
    prepared_at timestamptz NOT NULL,
    created_by text NOT NULL,
    actor_type text NOT NULL CHECK (actor_type IN ('ai_system','human_reviewer','human_expert','owner')),
    record_status text NOT NULL DEFAULT 'active' CHECK (record_status IN ('active','superseded','invalidated')),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(plan_code,plan_version),
    CHECK ((target_product_version_uuid IS NOT NULL)::integer +
           (target_investigation_version_uuid IS NOT NULL)::integer = 1),
    CHECK (supersedes_observation_plan_uuid IS NULL OR supersedes_observation_plan_uuid <> observation_plan_uuid)
);

CREATE INDEX IF NOT EXISTS ix_temporal_observation_plan_product
    ON maintenance.temporal_observation_plan(target_product_version_uuid);
CREATE INDEX IF NOT EXISTS ix_temporal_observation_plan_investigation
    ON maintenance.temporal_observation_plan(target_investigation_version_uuid);

CREATE TABLE IF NOT EXISTS maintenance.temporal_observation_source (
    observation_source_uuid uuid PRIMARY KEY,
    observation_plan_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_plan(observation_plan_uuid),
    source_code text NOT NULL,
    source_name text NOT NULL,
    source_class text NOT NULL,
    inclusion_status text NOT NULL CHECK (inclusion_status IN ('included','deferred','excluded','unassessed')),
    interface_code text,
    access_mode text NOT NULL CHECK (access_mode IN ('programmatic','manual','hybrid','unresolved')),
    runtime_connectivity_required boolean NOT NULL DEFAULT false,
    time_semantics_payload jsonb NOT NULL,
    source_definition_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    inclusion_rationale text NOT NULL,
    debt_reason_code text,
    reassessment_trigger text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by text NOT NULL,
    UNIQUE(observation_plan_uuid,source_code),
    CHECK (length(trim(source_code)) > 0),
    CHECK (
      (inclusion_status='deferred' AND debt_reason_code IS NOT NULL AND reassessment_trigger IS NOT NULL)
      OR inclusion_status<>'deferred'
    ),
    CHECK (inclusion_status <> 'included' OR debt_reason_code IS NULL)
);

CREATE INDEX IF NOT EXISTS ix_temporal_observation_source_plan
    ON maintenance.temporal_observation_source(observation_plan_uuid);

CREATE TABLE IF NOT EXISTS maintenance.temporal_observation_epoch (
    observation_epoch_uuid uuid PRIMARY KEY,
    observation_plan_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_plan(observation_plan_uuid),
    epoch_code text NOT NULL,
    epoch_status text NOT NULL DEFAULT 'draft'
      CHECK (epoch_status IN ('draft','authorized_non_normative','active','completed','invalidated')),
    measurement_design_artifact_uuid uuid NOT NULL REFERENCES artifact.artifact(artifact_uuid),
    start_boundary_at timestamptz NOT NULL,
    review_boundary_at timestamptz NOT NULL,
    started_at timestamptz,
    completed_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by text NOT NULL,
    UNIQUE(observation_plan_uuid,epoch_code),
    CHECK (review_boundary_at > start_boundary_at),
    CHECK (started_at IS NULL OR started_at >= start_boundary_at),
    CHECK (completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at)
);

CREATE INDEX IF NOT EXISTS ix_temporal_observation_epoch_plan
    ON maintenance.temporal_observation_epoch(observation_plan_uuid);

CREATE TABLE IF NOT EXISTS maintenance.temporal_observation_epoch_source (
    epoch_source_uuid uuid PRIMARY KEY,
    observation_epoch_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_epoch(observation_epoch_uuid),
    observation_source_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_source(observation_source_uuid),
    query_strategy_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    interface_config_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    baseline_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    measurement_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
    schedule_definition_artifact_uuid uuid NOT NULL REFERENCES artifact.artifact(artifact_uuid),
    runtime_interface_code text NOT NULL,
    measurement_schedule_payload jsonb NOT NULL,
    runtime_connectivity_status text NOT NULL DEFAULT 'unverified'
      CHECK (runtime_connectivity_status IN ('unverified','verified','blocked')),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(observation_epoch_uuid,observation_source_uuid)
);

CREATE INDEX IF NOT EXISTS ix_temporal_observation_epoch_source_epoch
    ON maintenance.temporal_observation_epoch_source(observation_epoch_uuid);

CREATE TABLE IF NOT EXISTS maintenance.temporal_observation_authority (
    observation_authority_uuid uuid PRIMARY KEY,
    observation_plan_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_plan(observation_plan_uuid),
    observation_epoch_uuid uuid REFERENCES maintenance.temporal_observation_epoch(observation_epoch_uuid),
    authority_domain text NOT NULL
      CHECK (authority_domain IN ('operational_execution','data_governance','scientific_methodological')),
    decision text NOT NULL CHECK (decision IN ('approved','revise','rejected','withdrawn')),
    actor text NOT NULL,
    actor_type text NOT NULL CHECK (actor_type IN ('human_reviewer','human_expert','owner')),
    decision_artifact_uuid uuid NOT NULL REFERENCES artifact.artifact(artifact_uuid),
    decided_at timestamptz NOT NULL,
    limitations_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_temporal_observation_authority_scope
    ON maintenance.temporal_observation_authority(observation_plan_uuid,observation_epoch_uuid,authority_domain,decided_at);
