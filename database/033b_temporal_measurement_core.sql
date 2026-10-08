-- OES migration 033b — opportunities, attempts, resolutions, items and deviations

CREATE TABLE IF NOT EXISTS maintenance.temporal_measurement_opportunity (
    measurement_opportunity_uuid uuid PRIMARY KEY,
    epoch_source_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_epoch_source(epoch_source_uuid),
    opportunity_no integer NOT NULL CHECK (opportunity_no >= 1),
    planned_for timestamptz NOT NULL,
    opportunity_origin text NOT NULL CHECK (opportunity_origin='frozen_opportunity_set'),
    schedule_snapshot_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(epoch_source_uuid,opportunity_no),
    UNIQUE(epoch_source_uuid,planned_for)
);

CREATE INDEX IF NOT EXISTS ix_temporal_measurement_opportunity_source
    ON maintenance.temporal_measurement_opportunity(epoch_source_uuid,planned_for);

CREATE TABLE IF NOT EXISTS maintenance.temporal_measurement_event (
    measurement_event_uuid uuid PRIMARY KEY,
    measurement_opportunity_uuid uuid NOT NULL REFERENCES maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid),
    attempt_no integer NOT NULL CHECK (attempt_no >= 1),
    execution_status text NOT NULL CHECK (execution_status IN ('completed','partial','failed','indeterminate')),
    execution_started_at timestamptz NOT NULL,
    execution_completed_at timestamptz,
    novelty_state text NOT NULL CHECK (novelty_state IN ('zero_new','new_items','unknown','not_applicable')),
    raw_result_count bigint CHECK (raw_result_count IS NULL OR raw_result_count >= 0),
    raw_result_count_status text NOT NULL CHECK (raw_result_count_status IN ('known','unknown','not_applicable')),
    materialized_identifier_count integer CHECK (materialized_identifier_count IS NULL OR materialized_identifier_count >= 0),
    new_identifier_count integer CHECK (new_identifier_count IS NULL OR new_identifier_count >= 0),
    failure_attribution text NOT NULL CHECK (failure_attribution IN ('source_confirmed','oes_confirmed','mixed','unknown','not_applicable')),
    failure_evidence_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    scientific_search_uuid uuid REFERENCES investigation.search(search_uuid),
    effort_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    operator text NOT NULL,
    actor_type text NOT NULL CHECK (actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(measurement_opportunity_uuid,attempt_no),
    CHECK (execution_completed_at IS NULL OR execution_completed_at >= execution_started_at),
    CHECK ((raw_result_count_status='known' AND raw_result_count IS NOT NULL)
       OR (raw_result_count_status<>'known' AND raw_result_count IS NULL)),
    CHECK (novelty_state <> 'zero_new' OR new_identifier_count = 0),
    CHECK (novelty_state <> 'new_items' OR new_identifier_count > 0),
    CHECK (failure_attribution NOT IN ('source_confirmed','mixed') OR failure_evidence_artifact_uuid IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS ix_temporal_measurement_event_opportunity
    ON maintenance.temporal_measurement_event(measurement_opportunity_uuid,attempt_no);

CREATE TABLE IF NOT EXISTS maintenance.temporal_measurement_opportunity_resolution (
    opportunity_resolution_uuid uuid PRIMARY KEY,
    measurement_opportunity_uuid uuid NOT NULL UNIQUE
      REFERENCES maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid),
    resolution_status text NOT NULL
      CHECK (resolution_status IN ('completed','failed_closed','not_executed','indeterminate_closed','invalidated')),
    terminal_measurement_event_uuid uuid REFERENCES maintenance.temporal_measurement_event(measurement_event_uuid),
    reason_code text NOT NULL,
    reason_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    resolved_at timestamptz NOT NULL,
    resolved_by text NOT NULL,
    actor_type text NOT NULL CHECK (actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maintenance.temporal_measurement_item (
    measurement_item_uuid uuid PRIMARY KEY,
    measurement_event_uuid uuid NOT NULL REFERENCES maintenance.temporal_measurement_event(measurement_event_uuid),
    source_identifier text NOT NULL,
    source_locator text,
    item_state text NOT NULL CHECK (item_state IN ('new_to_epoch','reobserved','updated_record','indeterminate')),
    oes_detected_at timestamptz NOT NULL,
    search_hit_uuid uuid REFERENCES investigation.search_hit(search_hit_uuid),
    source_record_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(measurement_event_uuid,source_identifier),
    CHECK (length(trim(source_identifier)) > 0)
);

CREATE INDEX IF NOT EXISTS ix_temporal_measurement_item_event
    ON maintenance.temporal_measurement_item(measurement_event_uuid);

CREATE TABLE IF NOT EXISTS maintenance.temporal_measurement_item_timepoint (
    measurement_item_timepoint_uuid uuid PRIMARY KEY,
    measurement_item_uuid uuid NOT NULL REFERENCES maintenance.temporal_measurement_item(measurement_item_uuid),
    semantic_code text NOT NULL,
    source_field text,
    raw_value text,
    precision text NOT NULL CHECK (precision IN ('second','minute','hour','day','month','year','interval','unknown')),
    timezone_name text,
    lower_bound_at timestamptz,
    upper_bound_at timestamptz,
    observability_status text NOT NULL CHECK (observability_status IN ('observed','bounded','not_observable','not_applicable')),
    source_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(measurement_item_uuid,semantic_code),
    CHECK (upper_bound_at IS NULL OR lower_bound_at IS NULL OR upper_bound_at >= lower_bound_at),
    CHECK (observability_status <> 'bounded' OR (lower_bound_at IS NOT NULL AND upper_bound_at IS NOT NULL)),
    CHECK (observability_status NOT IN ('not_observable','not_applicable') OR (lower_bound_at IS NULL AND upper_bound_at IS NULL))
);

CREATE TABLE IF NOT EXISTS maintenance.temporal_measurement_event_artifact (
    measurement_event_uuid uuid NOT NULL REFERENCES maintenance.temporal_measurement_event(measurement_event_uuid),
    artifact_uuid uuid NOT NULL REFERENCES artifact.artifact(artifact_uuid),
    artifact_role text NOT NULL
      CHECK (artifact_role IN ('query_snapshot','result_snapshot','identifier_set','failure_evidence','source_documentation','other')),
    sequence_no integer CHECK (sequence_no IS NULL OR sequence_no >= 1),
    PRIMARY KEY(measurement_event_uuid,artifact_uuid,artifact_role)
);

CREATE TABLE IF NOT EXISTS maintenance.temporal_observation_deviation (
    deviation_uuid uuid PRIMARY KEY,
    observation_epoch_uuid uuid NOT NULL REFERENCES maintenance.temporal_observation_epoch(observation_epoch_uuid),
    measurement_opportunity_uuid uuid REFERENCES maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid),
    measurement_event_uuid uuid REFERENCES maintenance.temporal_measurement_event(measurement_event_uuid),
    deviation_type text NOT NULL
      CHECK (deviation_type IN ('execution_delay','source_access','runtime_change','query_change','interface_change','source_scope_change','authority_change','data_governance','other')),
    materiality text NOT NULL CHECK (materiality IN ('non_material','new_epoch_required','invalidating')),
    description text NOT NULL,
    evidence_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recorded_by text NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_temporal_observation_deviation_epoch
    ON maintenance.temporal_observation_deviation(observation_epoch_uuid);
