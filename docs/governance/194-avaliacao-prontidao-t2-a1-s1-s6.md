# Documento 194 — D1-T2/A1: avaliação de prontidão técnica S1–S6

**OES | 2026-10-21 | avaliação documental baseada no código publicado | NÃO É ENCERRAMENTO**

## 1. Escopo e fontes
Autorização vigente: Documento 192, `PYTHON_IN_MEMORY_REPOSITORY_BOUNDARY_ONLY`. Examinar somente a implementação Python sintética em `prototypes/d1_t2/a1/`, a baseline T1 `prototypes/d1/`, a rastreabilidade T1 e os Documentos 190 e 193. Freshness Gate HEAD `6fc1d1e3bf4ea655057df8d74ba811894014c06d`; ponteiro CP220 vigente. T1 permanece `CLOSED_SYNTHETIC_LOCAL_ONLY`. Nenhuma operação de banco, SQL, Neon, CI, cloud, serviço pago ou consulta científica foi autorizada/realizada.

**Evidência histórica:** 19 testes de ponte, 8 de repositório, 4 de replay/atomicidade e 4 adversariais de ciclos (35 T2-A1), além dos 36 T1: **71/71 PASS reportados na execução local anterior**. Esses testes **não foram reexecutados nesta avaliação documental**; a presente revisão distingue código publicado, teste histórico e lacunas ainda abertas.

## 2. Matriz de rastreabilidade T2-A1

| Controle | Evidência efetivamente existente no código/testes | Limites e decisão |
|---|---|---|
| **S1 — Identidades e vínculos** | `test_creation_snapshot_parity`, `test_two_scenarios_independent`, `test_signal_request_conflict_and_duplicate_id`; cenário, ciclos e sinais no serviço T1 | Cobertura parcial de chaves demonstrativas; sem FK ou esquema canônico; suficiente apenas para interface local |
| **S2 — Proveniência sintética** | `test_signal_invalid_source_has_no_side_effects`; regras `synthetic:` do T1 | Prefixo textual não atesta proveniência real ou autenticação; nenhuma ingestão factual |
| **S3 — Idempotência e eventos** | `test_idempotency_receipt_read_and_payload_conflict`, `test_assessment_request_conflict_and_missing_signal`, `test_replay_creation_is_read_only_and_equivalent`, `test_receipt_isolation_across_scenarios_and_conflict` | Idempotência restrita à memória e vida do processo; não há recuperação durável nem concorrência interprocessos |
| **S4 — Avaliação/decisão** | `test_assessment_multivalued_impacts_parity_and_receipt`, `test_assessment_pending_preserves_t1_no_reassessment_semantics`, `test_full_flow_close_parity_and_conclusion_immutable` | `pending` não tem caminho de reavaliação; conservar semântica T1, não alterar sem decisão específica |
| **S5 — Snapshot/estado** | `test_full_flow_close_parity_and_conclusion_immutable`, `test_two_complete_cycles_parity_and_replay`; quatro dimensões de status e baseline mantidos via T1 | `oes.d1.monitor_snapshot/0.1` sintético, não equivale à View SQL canônica |
| **S6 — Replay, isolamento e descarte** | `test_replay_full_cycle_equivalent`, `test_replay_detects_divergent_event_storage`, `test_mutated_event_detected_without_mutating_snapshot`, `test_injected_commit_failure_leaves_no_partial_effects` | Replay em memória sem reinício de processo; adulteração testada por mutação interna da fixture; sem garantia de descarte seguro ou persistência |

## 3. Achados de código e limites técnicos

1. **Cinco comandos presentes:** `create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`, com ponte para `MemoryUnitOfWork`.
2. **Atomicidade local delimitada:** `commit()` publica a cópia de trabalho do registro sob `RLock`; exceções anteriores ao commit não publicam estado/evento/recibo. O teste de falha injeta exceção substituindo `commit` antes de qualquer publicação; **não demonstra falha durante a operação interna de publicação**, recuperação de resultado incerto ou atomicidade multiprocesso.
3. **Integridade do log:** `replay_snapshot()` compara eventos do estado com `list_events()` e delega a reconstrução ao serviço T1. Detecta mutações testadas, mas ambas as listas provêm do mesmo repositório; uma adulteração coordenada de estado e log não representa prova criptográfica de imutabilidade.
4. **Cópia T1:** `t1_monitor_reference.py` permanece cópia de `prototypes/d1/monitor.py` com blob SHA `8db88e36d8b3d8a6fe3c92523fba9fd1b1a86ef9`, conferido no incremento anterior. Manter verificação automática/local de equivalência para evitar divergência futura.
5. **Divergência de identidade de erros:** conflitos de recibo levantados pela nova camada são `RepositoryConflict`, enquanto o serviço T1 original sinaliza certos conflitos como `DomainError`. Os testes existentes verificam efeitos e valores, mas essa diferença faz parte de uma eventual matriz de compatibilidade que precisa ser explicitada. Não alterar silenciosamente comportamento público.
6. **Semânticas históricas:** criação repetida devolve snapshot corrente (não o recibo original), e `pending` não admite substituição. Ambos permanecem sob escopo aprovado de preservação.
7. **Documentação desatualizada:** README experimental registra 19+8 testes e não incorpora os últimos oito casos (replay e ciclos), o que impede fechamento documental sem atualização.
8. **Não existem** persistence driver, tabelas, transações SQL, CI remota, revisão científica ou gate promovido. Não inferir confiabilidade de produção com base em `RLock`.

## 4. Critérios de aceitação para recomendar encerramento técnico T2-A1

| Critério | Situação neste exame |
|---|---|
| Cinco comandos e teste diferencial positivo T1 | **Atendido nos cenários testados** |
| T1 original preservado, 36/36 regressão histórica | **Atendido historicamente; revalidar no HEAD de encerramento** |
| Matriz S1–S6 com exclusões explícitas | **Atendido documentalmente** neste Documento 194 |
| Rollback, idempotência e replay local | **Parcialmente atendido**, limites descritos no §3 |
| Teste de integridade de cópia T1 automatizado | **Pendente** |
| Matriz final de exceções e semântica idêntica ou divergência documentada | **Pendente** |
| README e comandos/contagem de testes atualizados | **Pendente** |
| Teste final local vinculado a HEAD e relatório de evidências | **Pendente** |
| Encerramento expresso do proprietário | **Pendente** |

**Parecer:** `T2_A1_TECHNICAL_READINESS_PARTIAL / NOT_CLOSED`. A implementação fornece evidência suficiente para prosseguir ao endurecimento final e preparar uma futura solicitação de encerramento restrito, mas **não** para declarar encerramento agora. A matriz S1–S6 demonstra apenas comportamento sintético local, sem certificação científica ou garantia de banco.

## 5. Próxima atividade proposta e proibições

Sob novo `Prossiga`, realizar **uma** atividade T2-A1 exclusivamente Python local para teste automatizado de integridade da cópia T1, auditoria de exceções e atualização documental coerente; depois executar todas as suítes, aplicar Freshness Gate e registrar provas. Manter T1 intacto e `pending`/criação repetida sem mudanças.

**NÃO AUTORIZADO:** T2-A2, SQL, PostgreSQL, Neon, driver de banco, CI remota, rede/nuvem, implantação, API pública, dados factuais, custos e mudanças de gates. CP220 permanece vigente até checkpoint próprio. STOP.
