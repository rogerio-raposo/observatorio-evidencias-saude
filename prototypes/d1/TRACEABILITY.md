# OES D1-T1 — Matriz de rastreabilidade S1–S6

**Data:** 2026-10-21  
**Base efetivamente executada:** `768e2190ecde8a8713b80fd2bb378449f2d49033`  
**Escopo:** Python padrão, cenário M2 exclusivamente sintético, persistência em memória.  
**Comando:** `python -m unittest discover -s . -p 'test_*.py' -v`  
**Resultado local:** `Ran 36 tests in 0.016s`; `OK`; zero falhas. Todos os seis arquivos da base executada foram comparados por hash Git ao HEAD. Nenhuma CI remota.

## Evidência localizada por critério

| Critério | Testes representativos publicados | Limitação ou pendência |
|---|---|---|
| S1 — Identidades | `test_identity_and_sequence`, `test_rejects_same_monitor_and_target_identity`, `test_s1_rejects_duplicate_cycle_identity_without_side_effects` | IDs são strings demonstrativas; não há validação integral dos relacionamentos OES-P1 |
| S2 — Proveniência | `test_rejects_non_synthetic_fixture_source`, `test_negative_provenance_and_immutability`, `test_s2_rejects_external_signal_provenance_without_side_effects` | Prefixo `synthetic:` é declaração do cenário, não prova de autenticidade de uma fonte |
| S3 — Registro e idempotência | `test_idempotency_and_replay`, `test_s3_rejects_duplicate_signal_and_conflicting_idempotency`, `test_signal_failure_is_atomic` | Sem transações interprocessos ou concorrência; registros só em memória |
| S4 — Avaliação/decisão | `test_cycle_and_scientific_conclusion`, `test_pending_cannot_close`, `test_s4_rejects_unknown_and_duplicated_impacts_without_side_effects`, `test_corrupt_conclusion_rejects_close_without_side_effects`, `test_close_failure_is_atomic` | Atores são fictícios; não houve revisão de evidência, inferência científica ou assurance reais |
| S5 — Snapshot e apresentação | `test_four_distinct_states_and_missing_baseline` (nome histórico do teste), `test_renders_multiple_impacts_and_explicit_decision`, `test_rejects_disclosure_of_unperformed_operation`, `test_baseline_is_exposed_and_distinct_from_cycle_cutoff`, `test_s5_snapshot_and_render_remain_explicitly_noncanonical` | Saída `oes.d1.monitor_snapshot/0.1` não equivale a `oes.evidence_monitor_view/0.1` |
| S6 — Auditoria e descarte | `test_replay_reconstructs_and_detects_drift`, `test_replay_is_read_only_and_repeatable`, `test_independent_repositories_do_not_share_mutations_or_receipts`, `test_explicit_repository_disposal_discards_all_synthetic_data`, `test_create_failure_leaves_no_scenario_or_receipt` | Limpeza em memória não é apagamento seguro; sem resiliência de processo, disco, rede ou concorrência |

## Critérios A–F do Documento 171

| Critério | Resultado desta revisão |
|---|---|
| A — Suíte local no HEAD | Evidência disponível: 36/36 PASS e hashes conferidos |
| B — Mapeamento S1–S6 | Evidência documental disponível nesta matriz; abrangência restrita a T1 |
| C — Rejeição sem mutação parcial | Casos positivos e falhas injetadas passam no modelo sequencial em memória; não constitui garantia geral |
| D — Conteúdo do snapshot | Baseline sintético e cutoff separados; quatro dimensões, impactos, decisões, histórico e disclosure contemplados no demonstrador |
| E — Isolamento/limpeza | Casos locais de isolamento e descarte passam; sem persistência/concurrency claims |
| F — Versão/documentação | Arquivos e comando identificados; documentação atualizada com esta matriz |

**Conclusão técnica:** há evidência suficiente para **submeter** T1 à avaliação de encerramento, restrita ao demonstrador sintético local, mas este arquivo **não declara encerramento, homologação, aprovação científica ou autorização de T2**. A decisão de encerramento permanece reservada ao proprietário. O checkpoint canônico permanece CP217 até atualização específica.

**Não realizado:** PostgreSQL/Neon, SQL, CI remota, deployment cloud, API pública, buscas PubMed/ClinicalTrials, serviços pagos, alterações de gates e testes diferenciais contra a View SQL canônica.
