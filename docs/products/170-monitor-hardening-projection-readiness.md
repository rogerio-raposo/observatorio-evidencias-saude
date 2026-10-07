# 170 — Monitor de Evidências: Especificação do Hardening de Projection Readiness

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **HARDENING_SPEC_READY**  
**Dependências:** Documentos 165–169; migration 021; MON-T01–T33  
**Migration autorizada após este documento:** `database/022_evidence_monitor_projection_hardening.sql`

---

# 1. Finalidade

Resolver os blockers PR-MON-01–05 do Documento 169 sem:

- alterar a identidade científica do Monitor;
- duplicar Search/SearchHit/currentness;
- implementar EvidenceMonitorView prematuramente;
- implementar Alert;
- antecipar a política transversal da Fase 4.

A migration 022 será:

> **aditiva e de hardening semântico.**

A View permanece candidata à migration 023.

---

# 2. Princípio

O renderer futuro deverá conseguir consumir uma projeção read-only sem:

- interpretar JSON livre para descobrir fatos metodológicos;
- escolher arbitrariamente uma categoria de impacto;
- considerar cobertura satisfeita sem saber quais requisitos existiam;
- esconder exceções de cobertura;
- ignorar drift temporal de Search;
- reescrever retrospectivamente o currentness produzido por um cycle.

Logo:

> **tudo que altera a interpretação metodológica da View deverá ser estruturado ou derivável de regras estruturadas.**

---

# 3. Estruturas adicionais

A migration 022 adicionará duas estruturas-filhas:

1. `maintenance.candidate_impact`;
2. `maintenance.monitor_source_requirement`.

As oito estruturas centrais da migration 021 permanecem.

O hardening passa a ter:

> **8 estruturas centrais + 2 estruturas auxiliares normalizadas.**

---

# 4. PR-MON-01 — `maintenance.candidate_impact`

## 4.1 Finalidade

Representar cardinalidade 1:N das dimensões de impacto de uma CandidateAssessment.

Uma CandidateAssessment retida poderá ter simultaneamente, por exemplo:

- quantitative;
- certainty;
- applicability;
- conclusion.

Isso implementa a regra do Documento 165:

> **uma mesma evidência poderá ocupar mais de uma categoria de impacto.**

---

# 5. DDL lógico de CandidateImpact

```sql
CREATE TABLE maintenance.candidate_impact (
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
    UNIQUE (candidate_assessment_uuid,impact_class)
);
```

Índice único parcial:

> no máximo um `is_primary=true` por CandidateAssessment.

---

# 6. Relação com campos legados de CandidateAssessment

A migration 021 já possui:

- `candidate_assessment.impact_class`;
- `candidate_assessment.impact_payload`.

Eles serão preservados para compatibilidade.

Nova semântica:

- `candidate_assessment.impact_class` = **primary impact summary**;
- `candidate_assessment.impact_payload` = summary payload legado;
- `candidate_impact[]` = fonte canônica para cardinalidade múltipla.

Para `decision='retained_for_impact'`:

1. exigir pelo menos um CandidateImpact;
2. exigir exatamente um CandidateImpact `is_primary=true`;
3. exigir que a classe primária = `candidate_assessment.impact_class`.

Para `excluded`:

- CandidateImpact não é obrigatório;
- `impact_class='none'` legado permanece aceitável.

---

# 7. Imutabilidade de CandidateImpact

CandidateImpact é parte do julgamento daquela CandidateAssessment concreta.

Logo:

- INSERT somente enquanto cycle estiver `planned|running`;
- UPDATE proibido;
- DELETE proibido.

Correção:

> superseder a CandidateAssessment e criar novos CandidateImpacts para a nova avaliação.

Não criar cadeia de supersession própria para CandidateImpact.

---

# 8. PR-MON-02 — `maintenance.monitor_source_requirement`

## 8.1 Finalidade

Separar:

- política descritiva em `source_policy_payload`;
- requisito operacional machine-readable.

O gate deixa de interpretar JSON livre como única fonte de obrigação.

---

# 9. DDL lógico de SourceRequirement

```sql
CREATE TABLE maintenance.monitor_source_requirement (
    source_requirement_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    requirement_code text NOT NULL,
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
    rationale text NOT NULL,
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
```

---

# 10. Source classes

O contrato não fixa lista global fechada de `required_value` para source class.

Classes de instância podem incluir:

- bibliographic;
- registry;
- regulatory;
- validity;
- citation_chaining;
- grey_literature;
- event_only;
- outras classes documentadas.

A classe vem de:

> `investigation.search.filters_payload.source_class`.

Mesmo uma fonte de vigilância não bibliográfica pode ser registrada como Search/execução de vigilância com result_count 0.

EvidenceEvent representa:

> **o sinal detectado**, não a execução da fonte.

---

# 11. Imutabilidade dos requisitos

SourceRequirement faz parte do plano daquela Monitor ProductVersion.

Regras:

- INSERT somente antes da existência de qualquer Monitoring Cycle para a versão;
- UPDATE proibido;
- DELETE proibido.

Mudança material de requisitos:

> nova Monitor ProductVersion.

---

# 12. Relação com `source_policy_payload`

`source_policy_payload` permanece como descrição rica do plano.

Para compatibilidade, estes campos conhecidos podem continuar existindo:

- `required_source_names`;
- `required_source_classes`;
- `minimum_bibliographic_sources`.

Quando presentes:

> **não podem contradizer os SourceRequirements normalizados.**

A migration 022 deverá detectar mismatch.

Requisitos machine-enforced novos:

> devem ser criados como SourceRequirement.

Um `requirement_kind` desconhecido:

> é rejeitado estruturalmente, em vez de ser silenciosamente ignorado.

---

# 13. Source policy issues

Helper candidato:

> `maintenance.monitor_source_policy_issues(monitor_product_version_uuid)`

Erros candidatos:

- `MISSING_NORMALIZED_SOURCE_REQUIREMENTS`;
- `SOURCE_POLICY_REQUIRED_NAME_NOT_NORMALIZED`;
- `SOURCE_POLICY_REQUIRED_CLASS_NOT_NORMALIZED`;
- `SOURCE_POLICY_MINIMUM_BIBLIOGRAPHIC_MISMATCH`.

A ausência de um mirror JSON não invalida um SourceRequirement normalizado.

O problema é:

> JSON declarar obrigação que não está normalizada.

---

# 14. Status por requisito

Criar helper:

> `maintenance.monitor_cycle_source_requirement_status(cycle_uuid)`

Saída mínima:

- requirement_uuid;
- requirement_code;
- requirement_kind;
- required_value;
- minimum_count;
- fulfilled;
- exception_applied;
- exception_method_decision_uuid;
- satisfied;
- evidence_payload.

`fulfilled=true` significa:

> execução observada satisfaz o requisito.

`exception_applied=true` significa:

> requisito não foi cumprido pela execução, mas existe exceção metodológica válida.

`satisfied=true`:

> fulfilled OR exception_applied.

A View futura deverá preservar essa distinção.

---

# 15. PR-MON-03 — exceções via MethodDecision

Não criar tabela paralela de exceções.

Reutilizar:

> `investigation.method_decision`

Exception code:

> `monitor_source_requirement_exception`

Contrato:

- InvestigationVersion = Monitor Investigation;
- stage = `search`;
- decision_code = `monitor_source_requirement_exception`;
- `impact_payload.cycle_uuid` = cycle;
- `impact_payload.requirement_code` = requisito;
- rationale obrigatório;
- requisito deve possuir `allow_exception=true`.

Satisfaz somente quando:

- record_status = active;
- resolution_status IN (`accepted`, `mitigated`).

Não satisfaz:

- open;
- rejected;
- rerouted;
- superseded.

---

# 16. Semântica de cobertura

`maintenance.monitor_cycle_source_coverage(cycle_uuid)` será redefinida.

Retorna true somente quando:

> **todos os SourceRequirements do Monitor estão satisfied.**

Além disso:

- sem SourceRequirement normalizado → false para ciclo formal;
- Search deve pertencer dinamicamente à Monitor Investigation;
- Search deve estar `completed`;
- Search temporalmente inválida não satisfaz requisito, salvo exceção temporal aceita.

---

# 17. PR-MON-04 — temporal consistency

Criar helper:

> `maintenance.monitor_cycle_temporal_issues(cycle_uuid)`

Erros candidatos:

- `CYCLE_WINDOW_BEFORE_BASELINE`;
- `CYCLE_WINDOW_AFTER_COMPLETION`;
- `MISSING_PREVIOUS_CYCLE_LINK`;
- `UNEXPLAINED_CYCLE_WINDOW_GAP`;
- `SEARCH_INVESTIGATION_DRIFT`;
- `SEARCH_OUTSIDE_CYCLE_WINDOW`;
- `SEARCH_NOT_COMPLETED`.

---

# 18. Baseline e primeira janela

Regra:

- `window_start_date < baseline_evidence_cutoff_date` = error;
- igualdade/overlap com baseline não é bloqueada universalmente;
- primeiro cycle iniciado após baseline + 1 dia gera gap apenas se houver intervalo descoberto real.

A migration não define periodicidade global.

---

# 19. Gaps entre cycles

Se:

> `current.window_start_date > previous.window_end_date + 1`

há gap temporal.

Pode ser aceito apenas por MethodDecision:

> `monitor_cycle_window_gap_exception`

Payload mínimo:

- `cycle_uuid`;
- `previous_cycle_uuid` quando houver;
- rationale no registro.

Somente active + accepted/mitigated resolve o gap.

Overlap temporal:

> permitido.

---

# 20. Search temporal exception

Search ligada ao cycle deve possuir:

> `executed_at::date` dentro da window.

Exceção documental:

> `monitor_search_temporal_exception`

Payload:

- `cycle_uuid`;
- `search_uuid`.

Somente active + accepted/mitigated permite a Search fora da janela.

Import histórico não será inferido a partir do timestamp.

---

# 21. Drift dinâmico de Search

A consistência não será verificada apenas no INSERT de CycleSearch.

Helpers/gates deverão reavaliar sempre:

- Search.investigation_version_uuid;
- Search.status;
- Search.executed_at;
- source_name;
- source_class.

Se uma Search vinculada for posteriormente alterada:

> o cycle poderá adquirir issue dinamicamente.

Não alterar o contrato global de Search na migration 022.

---

# 22. Cycle completion hardening

A função `maintenance.assert_monitor_cycle_lifecycle()` será substituída aditivamente.

Ao transicionar para `completed`, além das regras da 021, exigir:

1. source policy normalizada sem erro;
2. todos os SourceRequirements satisfied;
3. nenhum temporal error;
4. nenhum CandidateAssessment pending;
5. todo EvidenceEvent ativo avaliado;
6. toda CandidateAssessment `retained_for_impact` com CandidateImpact completo/coerente.

Isso impede criar cycle formalmente completo em estado que a futura View precisaria reinterpretar.

---

# 23. Histórico de cycles

Drift pode ocorrer depois do fechamento porque Search é transversal.

Logo, publication/readiness gate deverá examinar:

> **todos os cycles completed da Monitor ProductVersion, não apenas o latest cycle.**

Se um cycle histórico adquirir erro material por drift:

> Monitor formal torna-se bloqueado até resolução/versionamento apropriado.

Não reescrever o cycle histórico.

---

# 24. PR-MON-05 — CycleCurrencyState imutável

Adicionar guard:

> `maintenance.guard_cycle_currency_state_mutation()`

Após INSERT:

- UPDATE proibido;
- DELETE proibido.

A relação:

> Cycle → resulting CurrencyState

é fato histórico.

Correção de currentness:

- nova avaliação/cycle;
- nova CurrencyState;
- nunca overwrite silencioso do vínculo anterior.

---

# 25. Hardening issues do produto

Criar função:

> `product.evidence_monitor_projection_hardening_issues(product_version_uuid)`

Deverá incluir:

- source-policy normalization issues;
- errors de qualquer completed cycle;
- temporal/search drift;
- candidate impact inconsistency;
- historical cycle contract errors.

`product.evidence_monitor_is_publishable()` será redefinida para exigir:

1. nenhum error de `evidence_monitor_publication_issues`;
2. nenhum error de `evidence_monitor_projection_hardening_issues`.

Isso mantém a função 021 estável e evita reescrever todo o gate anterior.

---

# 26. Compatibilidade com o publication gate 021

A função:

> `product.evidence_monitor_publication_issues()`

não será removida.

Migration 022 acrescenta uma camada de hardening.

A EvidenceMonitorView futura poderá combinar:

- publication issues do contrato-base;
- projection hardening issues.

Nenhum blocker existente será reduzido.

---

# 27. Fixture M2 — atualização

A fixture formal M2 deverá adicionar:

- SourceRequirements normalizados;
- CandidateImpact para candidates retidos;
- ao menos um candidate com **duas categorias de impacto** para demonstrar cardinalidade;
- source policy JSON coerente.

Exemplo:

candidato científico do Cycle 2:

- primary = quantitative;
- secondary = certainty.

EvidenceEvent regulatório:

- primary = applicability.

---

# 28. Fixture M3 — atualização

A fixture M3 deverá possuir SourceRequirements normalizados.

Não precisa criar impactos se result_count=0 e nenhum candidate retido.

O blocker M3 da Fase 4 deve permanecer inalterado.

---

# 29. Testes de hardening

Suíte candidata:

> `database/f3-evidence-monitor-projection-hardening-tests.sql`

Testes mínimos:

- MONH-T01 — dois CandidateImpacts são preservados;
- MONH-T02 — exatamente um primary impact;
- MONH-T03 — primary child = legacy primary summary;
- MONH-T04 — duplicate impact class rejeitada;
- MONH-T05 — impact não pode ser inserido após cycle terminal;
- MONH-T06 — SourceRequirement kind desconhecido rejeitado;
- MONH-T07 — source requirements conhecidos são avaliados;
- MONH-T08 — JSON obrigatório não normalizado é detectado;
- MONH-T09 — accepted source exception satisfaz sem fingir fulfilled;
- MONH-T10 — open/rejected exception não satisfaz;
- MONH-T11 — Search fora da window é detectada;
- MONH-T12 — accepted temporal exception é auditável;
- MONH-T13 — Search Investigation drift é detectado;
- MONH-T14 — Search status drift é detectado;
- MONH-T15 — window antes do baseline é detectada;
- MONH-T16 — gap entre cycles sem rationale é detectado;
- MONH-T17 — accepted gap exception resolve o gap;
- MONH-T18 — CycleCurrencyState UPDATE bloqueado;
- MONH-T19 — CycleCurrencyState DELETE bloqueado;
- MONH-T20 — completed historical cycle drift bloqueia Monitor;
- MONH-T21 — MON-T01–T33 permanecem verdes;
- MONH-T22 — M3 Phase-4 blocker permanece;
- MONH-T23 — migration 022 re-aplica idempotentemente;
- MONH-T24 — rebuild-from-zero through 022 PASS.

---

# 30. Projection Readiness após hardening

A migration 022:

> **não declara READY automaticamente.**

Após PASS técnico:

1. registrar resultado técnico;
2. reexecutar adversarialmente PR-MON-01–05;
3. confirmar que a futura View não necessita inferência fora do banco;
4. somente então decidir READY/NOT_READY.

---

# 31. Migration 022 autorizada

Fica autorizada:

> `database/022_evidence_monitor_projection_hardening.sql`

Escopo:

- `candidate_impact`;
- `monitor_source_requirement`;
- guards de imutabilidade;
- source requirement status;
- source exceptions;
- temporal issues;
- dynamic Search revalidation;
- cycle completion hardening;
- product hardening issues;
- publishability wrapper hardening.

Não criar:

- EvidenceMonitorView;
- template;
- Alert;
- thresholds/cadências globais;
- regra transversal living;
- Fase 4.

---

# 32. Próxima etapa

> **Implementar migration 022 + atualizar fixture + executar MONH-T01–T24 + regressões/rebuild.**

Depois:

> **reexecutar o Projection Readiness Gate.**

---

**Decisão:** **PROJECTION_HARDENING_SPEC_READY — migration 022 autorizada.**
