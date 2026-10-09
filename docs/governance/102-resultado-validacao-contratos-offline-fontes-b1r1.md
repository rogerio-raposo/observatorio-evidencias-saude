# 102 — Resultado de Validação dos Contratos Offline de Resposta das Fontes

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 9 de outubro de 2026  
**Status:** **TECHNICALLY_VALIDATED — SYNTHETIC_OFFLINE_ONLY — NO_FACTUAL_SOURCE_QUERY**  
**Decisão de escopo:** Documento 101 / CP145  
**Modo de implementação:** médio

## 1. Resultado

> **F4_OFFLINE_SOURCE_IMPLEMENTATION = DONE**  
> **F4_OFFLINE_SOURCE_CI_PROOF = PASS**  
> **F4_OFFLINE_SOURCE_CASES = 34_OF_34_PASS**  
> **FROZEN_INTERFACE_ARTIFACTS = UNCHANGED**  
> **B1R1_ACTIVATION = NOT_STARTED**

Implementações:

- `scripts/temporal_source_offline_contracts.py`: validadores determinísticos ESearch JSON e ClinicalTrials.gov API v2 de respostas **artificiais**, sem HTTP/SQL;
- `scripts/validate_temporal_source_offline_contracts.py`: 34 casos de validação;
- `tests/fixtures/f4-temporal-sources-offline/README.md`: declaração de fixtures sintéticas, geradas em memória;
- `.github/workflows/validate-s5.yml`: step `F4-OFFLINE-SOURCE-CONTRACTS`, com `push.paths` dos arquivos novos.

Os validadores verificam request identity com referência aos artifacts congelados; envelopes JSON, contagens, identificadores, paginação e sua terminação, token reuse/ciclo, erro de fonte/rede artificial, NCTId/PMID únicos, elementos mínimos quando disponíveis e fail-closed de completeness.

## 2. Evidência de GitHub Actions

**Run canônica:** 248 / `37935448109`, `success`.  
**HEAD técnico validado:** `6db14ba5107062bec6afa69607c4ff23b23acf7a`.  
**Job:** `postgres-s5`, ID `113836220414`, `success`.  
**Etapa offline:** `F4-OFFLINE-SOURCE-CONTRACTS — 34 synthetic response scenarios`, `success`.  
**Artifact:** `11617672877` / `oes-s5-evidence-37935448109`.  
**Digest:** `sha256:77e26b176458ec70f82333c1ea5149269b2a4ec641c7eb580741876dff7c494d`.  
**Expiração registrada:** `2026-12-08T13:15:32Z`.

No log factual da CI, cada `OFF-P01–P12`, `OFF-C01–C16`, `OFF-X01–X06` aparece individualmente com `PASS`, seguidos de:

> `F4-OFFLINE-SOURCE-CONTRACTS PASS — OFF-P01–P12 OFF-C01–C16 OFF-X01–X06 (34/34)`

e

> `F4-OFFLINE-SOURCE-CONTRACTS VERIFIED — 34 cases; no HTTP, no PostgreSQL writes`.

Na mesma run:
- `F4-ISE` sintético integrado de 24 testes: `success`;
- `TOPI-B1R1-PRE-DAY19-READINESS PASS`: `PREPARATION_READY`, activation window `WAIT` e zero mutation;
- `S5-T16 PASS`: rebuild;
- `TOPI-B1R1-AUTH-REBUILD PASS`: B1 invalidated, B1R1 authorized_non_normative, `started_at=NULL`, sem MeasurementEvent.

## 3. Runs intermediárias e correções

A run **246 / `37935300519`** falhou na definição do workflow (nenhum job de validação executado): ao editar o YAML, o metacaractere `$'` em uma substituição literal expandiu indevidamente parte do conteúdo. Foi corrigida a inserção da etapa, restaurando o YAML íntegro.

A run **247 / `37935405834`** foi iniciada com a etapa corrigida, mas anterior à correção de framing de Git blob SHA no harness. **Não é a evidência canônica.** A run 248 supersede as duas para fins de avaliação positiva desta implementação.

A correção de hash foi restrita à função de teste que calcula SHA-1 no formato Git blob `blob <length>\0<bytes>`, sem alterar qualquer frozen artifact.

## 4. Cobertura e reservas de validade

- Os 34 cenários são artificiais; não representam responses efetivamente recebidas das APIs.
- `retrieval_completeness=complete` atesta apenas o parsing e integridade da **fixture**, nunca uma Opportunity factual.
- Não há cliente HTTP ou request científica na biblioteca; o harness usa Python padrão e não escreve SQL.
- A verificação de ausência de rede no teste transversal inclui inspeções de código. Não equivale a isolamento de rede imposto por ambiente; nenhuma garantia adicional deve ser inferida.
- `minimal_records` preserva campos devolvidos pela fixture; não fabrica timestamps para datas ausentes.
- O relatório offline não contém `execution_status`, `execution_started_at`, `MeasurementEvent` ou `OpportunityResolution` factual.
- Não foram desenvolvidos cliente de rede, scheduler, persistência operacional, calibração normativa ou M3.
- Não alterar os artifacts v2, queries congeladas, horários do B1R1 ou o Documento 101 histórico. O Documento 101 preserva a decisão anterior a esta implementação.

## 5. Próximo passo

A preparação adicional offline está validada. Antes do dia 19, qualquer novo bloco técnico deve ter objetivo concreto e não deve alterar contratos congelados. Um próximo bloco potencial é um **gate adversarial de interface entre parser offline, runbook e persistência factual**, somente leitura, para verificar ausência de transformação automática indevida de relatórios sintéticos em eventos reais. Alternativamente, manter a preparação em repouso até a janela factual.

Após checkpoint, aguardar instrução do usuário.

## 6. Estado preservado

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**  
> **B1 = INVALIDATED**  
> **B1R1 = AUTHORIZED_NON_NORMATIVE**  
> **B1R1_STARTED_AT = NULL**  
> **ACTIVATION = NOT_STARTED**  
> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**  
> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**  
> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**  
> **PRE_DAY19_PREPARATION_STATUS = PREPARATION_READY**  
> **ACTIVATION_WINDOW_CURRENT_STATE = WAIT**  
> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**  
> **PHASE_5 = NOT_STARTED**

**Fim do Documento 102**
