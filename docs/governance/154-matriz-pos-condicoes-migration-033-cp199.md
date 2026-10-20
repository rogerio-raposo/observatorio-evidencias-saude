# 154 — Matriz documental de pós-condições da migração 033 (CP199)

**OES | Fase 4 | 2026-10-20 | modo médio**  
**Classificação:** `G1_MIG_033_POSTCONDITIONS_DRAFT_ONLY`, sem execução, aprovação de migrações ou homologação BRG-06.

## 1. Continuidade, escopo e autoridade

Freshness Gate CP198/main `4ef4ff7b80873cfa2ece7aae09c1e3ea347d6c6d`, identical, ahead/behind zero. Consolidação das atividades internas A1–A3 e formalização A4 conforme protocolo equilibrado. Fontes: wrapper `database/033_non_normative_temporal_observation.sql`; fragmentos `033a_temporal_observation_core.sql`, `033b_temporal_measurement_core.sql`, `033c_temporal_observation_guards.sql`, `033d_temporal_observation_helpers_views.sql`, `033e_temporal_observation_issue_validators.sql`. Revisão textual estática, sem SQL, Neon, CI, PubMed/ClinicalTrials, novo epoch ou custo.

## 2. Inventário declarado

| Fragmento | Tabelas | Funções | Triggers | Views |
|---|---:|---:|---:|---:|
| 033a | 5 | 0 | 0 | 0 |
| 033b | 7 | 0 | 0 | 0 |
| 033c | 0 | 22 | 23 | 0 |
| 033d | 0 | 2 | 0 | 2 |
| 033e | 0 | 3 | 0 | 0 |
| **Total** | **12** | **27** | **23** | **2** |

Os 23 triggers de 033c estão declarados diretamente, com `DROP TRIGGER IF EXISTS` anterior, `BEFORE` e `FOR EACH ROW`. Não se deve confundir sua presença com prova de comportamento correto.

## 3. Pós-condições estruturais propostas

| ID | Verificação futura | Critério de falha |
|---|---|---|
| M033-TAB | Consultas `pg_class`, `pg_namespace`, `pg_attribute` para 12 tabelas de plano, fonte, epoch, autoridade, oportunidades, eventos, resolução, itens, timepoints, artefatos e desvios | Ausência/DDL incompatível |
| M033-FUN | `pg_proc`/assinaturas/atributos/definições para 27 funções | Função ausente ou incompatível |
| M033-TRG | `pg_trigger`, `pg_get_triggerdef`, eventos BEFORE/ROW, função, tabela, estado habilitado para 23 triggers | Trigger ausente, desligado ou vinculado incorretamente |
| M033-VIEW | `pg_views`/`pg_get_viewdef` para `temporal_measurement_replay_v` e `temporal_measurement_readiness_evidence_v` | View ausente ou projeção divergente |
| M033-FK | `pg_constraint`, FKs efetivas, estado `convalidated`, targets | Chave ausente/não validada/errada |
| M033-RECEIPT | Hash do wrapper + cinco fragmentos; registro independente e coerência do catálogo | Fonte incompatível ou execução indeterminada |

## 4. Matriz comportamental proposta

**Epoch** (função `maintenance.assert_temporal_epoch_lifecycle()`):
- Inserção exige `draft` e artefato de desenho ativo.
- Transição `draft → authorized_non_normative` exige fontes e materialização completa das oportunidades, alvo atual, conectividade necessária verificada, artefatos ativos e autoridade operacional posterior ao congelamento do desenho.
- `authorized_non_normative → active` exige `started_at` e pré-condições de autoridade e atualidade.
- `active → completed` exige `completed_at` no limite aplicável, oportunidades resolvidas, alvo atual e ausência de desvios impeditivos.
- `draft`, `authorized_non_normative` e `active` podem transitar para `invalidated`; outras mudanças de estado são rejeitadas.

**Eventos** (função `maintenance.assert_temporal_measurement_event_append()`):
- `attempt_no` deve ser consecutivo; oportunidade resolvida não admite tentativa; execução anterior `completed` impede repetição.
- Epoch deve estar `active`, alvo ainda atual, `effort_payload` válido, artefato de falha ativo quando presente e referência de busca científica no escopo correto da investigação.
- Incluir cenários negativos isolados por regra, além de casos positivos autorizados. Testes de concorrência de `max(attempt_no)` são necessários; verificação estática não assegura serialização.

**Imutabilidade e autoridade:** comprovar rejeição de UPDATE/DELETE das linhas históricas, vínculo de artefatos ativos e autoridade coerente. Controles adicionais 034–036 exigem reconciliação separada; a migração 033 isolada **não** libera medição factual.

## 5. Modelo de evidência e limites

Cada regra deverá possuir identificador, caminho/sha do artefato, assinatura/DDL alvo, consulta de catálogo somente leitura revisada, expectativa inequívoca, resultado observado e revisor independente. Ensaios comportamentais e rollback somente em ambiente descartável e sob nova autorização expressa. Nada neste documento promove `REVIEWED` ou aprova pós-condições.

## 6. Continuidade e bloqueios

O catálogo continua com 36 migrações `UNREVIEWED`, zero pós-condições aprovadas; BRG-03/06/07/08 BLOCKED, 04/05 históricos, 09 parcial; 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos. B1R1 expirado, P-B/novo epoch não autorizados, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED.

**Próximo `Prossiga`:** A1 do bloco subsequente, revisão documental das pós-condições de 034–036 e de suas interdependências, começando pela 034. **STOP.**
