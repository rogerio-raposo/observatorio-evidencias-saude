-- OES Fase 3 — EvidenceMapView rendering-readiness tests
-- Requires migration 017 + formal synthetic Evidence Map fixture.

-- EMV-T01 — schema remains backward-compatible 0.1 and synthetic fixture is explicit.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF v->>'schema_version'<>'oes.evidence_map_view/0.1' THEN
        RAISE EXCEPTION 'EMV-T01 FAIL — unexpected schema version %',v->>'schema_version';
    END IF;
    IF COALESCE((v#>>'{audit,synthetic_fixture}')::boolean,false)<>true THEN
        RAISE EXCEPTION 'EMV-T01 FAIL — synthetic fixture disclosure absent';
    END IF;
END;
$test$;

-- EMV-T02 — canonical map conclusion is projected; renderer need not infer narrative.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF COALESCE(v#>>'{conclusion,text}','') NOT LIKE 'Synthetic evidence is distributed%' THEN
        RAISE EXCEPTION 'EMV-T02 FAIL — conclusion not projected: %',v->'conclusion';
    END IF;
END;
$test$;

-- EMV-T03 — protocol and codebook carry auditable artifact metadata.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF v#>>'{protocol,content_hash}' <> 'synthetic-map-protocol-sha256'
       OR v#>>'{codebook,content_hash}' <> 'synthetic-map-codebook-sha256'
       OR COALESCE(v#>>'{protocol,storage_key}','')=''
       OR COALESCE(v#>>'{codebook,storage_key}','')=''
    THEN
        RAISE EXCEPTION 'EMV-T03 FAIL — protocol/codebook metadata incomplete';
    END IF;
END;
$test$;

-- EMV-T04 — reviewer assignments are exposed and remain qualified/role-specific.
DO $test$
DECLARE v jsonb; n integer;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    n:=jsonb_array_length(v->'reviewer_assignments');
    IF n<>6 THEN
        RAISE EXCEPTION 'EMV-T04 FAIL — expected 6 active reviewer assignments, found %',n;
    END IF;
    IF NOT EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'reviewer_assignments') x
         WHERE x->>'role'='search_peer_reviewer'
           AND x->>'actor_type'='human_expert'
           AND COALESCE((x->>'independent')::boolean,false)=true
    ) THEN
        RAISE EXCEPTION 'EMV-T04 FAIL — search peer reviewer assignment absent';
    END IF;
    IF NOT EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'reviewer_assignments') x
         WHERE x->>'role'='data_verifier'
           AND x->>'actor_type'='human_reviewer'
    ) THEN
        RAISE EXCEPTION 'EMV-T04 FAIL — data verifier assignment absent';
    END IF;
END;
$test$;

-- EMV-T05 — method controls expose search, screening and classification stages.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF jsonb_array_length(v->'method_controls')<>3 THEN
        RAISE EXCEPTION 'EMV-T05 FAIL — expected 3 active method controls';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v->'method_controls') x
         WHERE x->>'control_type'='search_strategy_peer_review'
           AND x->>'decision'='passed'
    ) THEN RAISE EXCEPTION 'EMV-T05 FAIL — search control absent'; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v->'method_controls') x
         WHERE x->>'control_type'='screening_secondary_verification'
           AND x->>'decision'='passed'
    ) THEN RAISE EXCEPTION 'EMV-T05 FAIL — screening control absent'; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v->'method_controls') x
         WHERE x->>'control_code'='map_classification_verification'
           AND x->>'decision'='passed'
    ) THEN RAISE EXCEPTION 'EMV-T05 FAIL — classification control absent'; END IF;
END;
$test$;

-- EMV-T06 — lineage is complete for framework + four active MapItems.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF jsonb_array_length(v->'lineage')<>5 THEN
        RAISE EXCEPTION 'EMV-T06 FAIL — expected 5 map lineage edges, found %',
            jsonb_array_length(v->'lineage');
    END IF;
    IF COALESCE((v#>>'{audit,lineage_available}')::boolean,false)<>true THEN
        RAISE EXCEPTION 'EMV-T06 FAIL — lineage_available not true';
    END IF;
    IF COALESCE((v#>>'{audit,invalidated_dependencies}')::boolean,false)<>false THEN
        RAISE EXCEPTION 'EMV-T06 FAIL — unexpected invalidated dependency';
    END IF;
END;
$test$;

-- EMV-T07 — references include Report B reachable only through Study B linkage.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF NOT EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'references') x
         WHERE x->>'report_id'='OES-RP-2026-001102'
           AND EXISTS (
                SELECT 1
                  FROM jsonb_array_elements_text(x->'source_locations') s(loc)
                 WHERE s.loc LIKE 'study_report_link:%'
           )
    ) THEN
        RAISE EXCEPTION 'EMV-T07 FAIL — Study-linked Report B not projected';
    END IF;
END;
$test$;

-- EMV-T08 — rendering-readiness additions do not change cells or gate semantics.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF jsonb_array_length(v->'cells')<>4
       OR COALESCE((v#>>'{audit,publishable}')::boolean,false)<>true
       OR v#>>'{audit,assurance_level}'<>'A3'
       OR COALESCE((v#>>'{audit,search_controls_satisfied}')::boolean,false)<>true
       OR COALESCE((v#>>'{audit,classification_controls_satisfied}')::boolean,false)<>true
    THEN
        RAISE EXCEPTION 'EMV-T08 FAIL — pre-existing map semantics changed: %',v->'audit';
    END IF;
END;
$test$;

-- EMV-T09 — selection flow remains traceable and expanded without recomputation in renderer.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF (v#>>'{selection_flow,search_hits}')::integer<>4
       OR (v#>>'{selection_flow,unique_report_targets}')::integer<>2
       OR (v#>>'{selection_flow,screening_decisions}')::integer<>8
       OR (v#>>'{selection_flow,title_abstract_decisions}')::integer<>4
       OR (v#>>'{selection_flow,full_text_decisions}')::integer<>4
    THEN
        RAISE EXCEPTION 'EMV-T09 FAIL — selection flow unexpected: %',v->'selection_flow';
    END IF;
END;
$test$;

SELECT 'EMV-T01–T09 PASS — EvidenceMapView rendering readiness projection validated'
AS evidence_map_view_tests_status;
