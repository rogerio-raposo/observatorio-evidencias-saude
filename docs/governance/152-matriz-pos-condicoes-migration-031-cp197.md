# 152 — Matriz preliminar de pós-condições da migração 031 e consolidação A1–A4

**OES | Fase 4 | CP197 | 2026-10-20 | Modo médio**  
**Estado:** `G1_MIG_031_POSTCONDITIONS_DRAFT_ONLY` — nenhum objeto validado em PostgreSQL e nenhuma aprovação BRG-06.

## 1. Autoridade e método

Freshness Gate CP196/main `65d4d102d1ed010b655d6faf2a9e9b474cad28b7`: identical, 0 ahead/behind. Revisão documental de cinco fragmentos `database/031a...` a `031e...`, wrapper 031, catálogo `database/f4-reconciliation-postconditions-draft.json` e continuidade CP196. Consolidam-se as atividades internas A1–A3 e a formalização A4. Nenhum SQL executado, Neon, CI, queries científicas ou custo.

## 2. Inventário de objetos declarado nos fragmentos

| Fragmento | Tabelas `CREATE TABLE` | Definições `CREATE FUNCTION` | Triggers declarados diretamente |
|---|---:|---:|---:|
| 031a | 5 | 6 | 6 |
| 031b | 0 | 2 | 0 |
| 031c | 10 | 2 | 3 |
| 031d | 0 | 4 | 0 |
| 031e | 0 | 8 | 8 |
| **Total textual** | **15** | **22** | **17** |

Em `031c`, um bloco `DO` percorre **nove** tabelas auxiliares `rebaseline_*`, criando mais **nove triggers dinâmicos** via `format`. Total **26 triggers esperados** (17 diretos + 9 dinâmicos); contagem estática, não verificação de objetos existentes no banco.

As nove tabelas cobertas são: `rebaseline_version_chain_step`, `rebaseline_policy_link`, `rebaseline_monitor_link`, `rebaseline_risk_profile_link`, `rebaseline_coverage_item`, `rebaseline_sla_rule_link`, `rebaseline_sla_instance_disposition`, `rebaseline_open_signal_disposition` e `rebaseline_workflow_link`. Cada trigger chama `maintenance.guard_immutable_snapshot()` em UPDATE/DELETE.

## 3. Matriz verificável proposta

| ID | Pós-condição proposta | Prova futura somente leitura | Critério de falha |
|---|---|---|---|
| M031-TAB | 15 tabelas declaradas existem no schema `maintenance` | Inspeção de `pg_class`/`pg_namespace`, estrutura de colunas | Objeto ausente, tipo ou coluna incompatível |
| M031-FUN | 22 definições de funções esperadas | `pg_proc`, `pg_get_function_identity_arguments`, `pg_get_functiondef` com hash/versionamento da fonte | Assinatura, retorno, corpo ou atributos divergentes |
| M031-TRG-DIRECT | 17 triggers criados diretamente | `pg_trigger`, `pg_get_triggerdef`, `tgenabled`, função/relacionamento | Trigger ausente, desabilitado, alvo ou definição incompatível |
| M031-TRG-DYNAMIC | 9 triggers `tr_<tabela>_immutable` criados em loop | Correspondência exata trigger-tabela-função/UPDATE/DELETE | Cardinalidade ou vínculo divergente |
| M031-FK | Todas FKs de 031a/031c e adaptador 031b | `pg_constraint` (`contype='f'`, `convalidated`, `pg_get_constraintdef`) | FK ausente, não validada ou destino incorreto |
| M031-ADAPT-COL | `maintenance.update_signal_source.propagation_candidate_uuid` UUID | `pg_attribute`/`pg_type` e nulabilidade | Coluna ausente ou tipo divergente |
| M031-ADAPT-FK | FK `fk_update_signal_source_propagation_candidate` | Constraint vinculada a `maintenance.propagation_candidate` | Ausente, inválida ou referência divergente |
| M031-ADAPT-CHECK | `update_signal_source_type_v031_check` e `update_signal_source_locator_v031_check` | `pg_constraint` e expressões canônicas | CHECK ausente, não validada ou divergente |
| M031-ADAPT-LEGACY | Regras antigas selecionadas e substituídas pelo `DO` de 031b | Comparação antes/depois de nomes e expressões de CHECK | CHECK incompatível residual ou regra não pretendida removida |
| M031-GUARDS | Rejeição de INSERT inválido e UPDATE/DELETE de snapshots | Testes negativos em ambiente descartável autorizado; transação com rollback | Escrita indevida aceita |
| M031-TX | Efeito atômico do wrapper 031 em erro induzido | Recibo independente + teste de falha/rollback autorizado | Aplicação parcial, estado incerto ou replay não justificado |

**Notas de integridade:** a presença sintática do objeto não assegura execução correta dos guards; contagens não substituem comparação de DDL, assinaturas e permissões. A regra M031-ADAPT-LEGACY exige baseline prévio para evitar concluir indevidamente que uma constraint foi removida com segurança. O uso de `CREATE TABLE IF NOT EXISTS` exige verificação de identidade estrutural, não apenas existência.

## 4. Evidência documental e autoridade

- As tabelas 031a incluem `contract_epoch`, `propagation_assessment`, `propagation_candidate`, `propagation_path`, `propagation_path_step`.
- As tabelas 031c incluem `rebaseline_decision` e as nove tabelas auxiliares acima.
- 031b altera tabela existente `update_signal_source` com coluna UUID, FK e duas CHECKs; um bloco `DO` remove CHECKs anteriores conforme expressões, razão para revisão adicional.
- O ledger do catálogo permanece `DRAFT_ALL_ENTRIES_UNREVIEWED`: 36/36 `UNREVIEWED`, zero pós-condições aprovadas. Esta matriz **não** altera o catálogo e não concede autorização para SQL, CI ou migração.

## 5. Continuidade

Protocolo equilibrado: quatro atividades A1–A4 consolidadas em CP197, um commit documental. Próximo `Prossiga`: novo bloco, atividade A1 de revisão estática de pós-condições do wrapper 032 (quatro fragmentos), replicando e aperfeiçoando a matriz, sem execução.

BRG-03/06/07/08 BLOCKED, BRG-04/05 históricos, BRG-09 parcial; 36 evidências 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos; B1R1 expirado, novo epoch/P-B não autorizado, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED.

**STOP.**
