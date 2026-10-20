# 147 — Closure estática de dependências dos wrappers 031–033 e guards 034–036

**OES | 2026-10-20 (America/Recife) | CP191 | modo médio**  
**Status:** `G1_WRAPPER_CLOSURE_STATICALLY_MAPPED_NOT_APPROVED`. Evidência exclusivamente documental, não execução nem prova PostgreSQL.

## 1. Base e autorização

Freshness Gate CP190/main `53cbd7dad1d21594fe66ba60b589f421d4179de9`: identical, ahead/behind 0; ponteiro CP190, handoff, Documento 146 e continuidade verificados. Fonte: leitura direta de wrappers 031/032/033, todos os 14 arquivos subordinados e arquivos 034–036 no GitHub. Autorização vigente `PREPARE_G1_DOCUMENTARY_ONLY`, sem SQL/branch/role/migration Neon, nenhum SQL executado, CI/PG18, novo epoch, consulta PubMed/ClinicalTrials ou serviço pago.

## 2. Closure sintática de inclusões por wrapper

| Entrada canônica | Inclusões observadas, na ordem | Pré-dependência declarada |
|---|---|---|
| 031_propagation_rebaseline_contract.sql | 031a propagation_core → 031b propagation_signal_adapter → 031c rebaseline_core → 031d propagation_rebaseline_helpers → 031e rebaseline_child_validators | migrations 001–030 |
| 032_temporal_calibration_prerequisites.sql | 032a temporal_calibration_core → 032b temporal_cadence_contract → 032c temporal_sla_contract → 032d temporal_sla_runtime | migrations 001–031 |
| 033_non_normative_temporal_observation.sql | 033a temporal_observation_core → 033b temporal_measurement_core → 033c temporal_observation_guards → 033d temporal_observation_helpers_views → 033e temporal_observation_issue_validators | migrations 001–032 |

**Contagem:** 3 entrypoints wrapper + 14 inclusões `\\ir`. Nenhuma inclusão interna adicional encontrada nos 14 fragmentos examinados; cada wrapper é um artefato lógico. Compatibilidade requer um cliente que processe `\\ir` no diretório relativo correto. A contagem não demonstra sucesso de execução nem validação de ordenação em PG18.

## 3. Objetos e referências relevantes

**031a–031e:** tabelas `maintenance.contract_epoch`, `propagation_assessment`, `propagation_candidate`, `propagation_path`, `propagation_path_step`, `rebaseline_decision` e vínculos de versão, policy, monitor, risk, coverage, SLA, signal e workflow. Referenciam `core.entity_version`, `product.product_version`, `investigation.investigation_version`, `maintenance.update_decision`, `update_policy`, `monitor_cycle`, `update_signal`, `sla_rule` e `sla_instance`, dentre outros. Também criam validators/guards e funções de issues. Não é exclusivamente código para primeira medição.

**032a–032d:** infraestrutura de dossier/authority/basis/candidates de calibração, `cadence_contract`, `cadence_obligation`, `cadence_observation`, `fixed_deadline_source`, funções de calendário, SLA e readiness. Referenciam objetos científicos versionados, artifact, monitor e update. **Presença de infra temporal não cria calibragem normativa nem legitima SLA/cadence em P-B.**

**033a:** tabelas `temporal_observation_plan`, `source`, `epoch`, `epoch_source`, `authority`; dependências de `product.product_version`, `investigation.investigation_version` e `artifact.artifact`. **033b:** `temporal_measurement_opportunity`, `temporal_measurement_event`, `temporal_measurement_opportunity_resolution`, `temporal_measurement_item`, `temporal_measurement_item_timepoint`, `temporal_measurement_event_artifact`, `temporal_observation_deviation`. Referenciam `investigation.search`, `investigation.search_hit` e artifact.

**033c:** triggers e validação de freeze, identity, authority, epoch lifecycle, event append e proibitivos de mutação. **033d:** helpers e views de status/readiness sem garantia de autorização. **033e:** issue validators de plan/epoch/event. Sem essas guardas, mera criação de tabelas não representa P-B seguro.

## 4. Encadeamento 033 → 034 → 035 → 036

| Arquivo | Dependência diretamente observável | Invariante prevista |
|---|---|---|
| 034 | `maintenance.temporal_observation_epoch`, `temporal_measurement_opportunity`, `temporal_observation_epoch_source`, authority e deviations; provistos por 033 | `started_at` deve anteceder a primeira opportunity, autoridade aprovada e ausência de desvio material; instala trigger de ativação |
| 035 | `temporal_observation_epoch`/plan/source, artifacts, authority, helpers de 033 e cronologia de 034 no percurso de ativação | `temporal_activation_preflight`/state são funções STABLE/read-only de checagem; não ativam epoch |
| 036 | `temporal_measurement_event` e `temporal_measurement_opportunity` de 033b | Primeira `completed` por epoch-source exige `novelty_state=not_applicable`, `new_identifier_count=NULL`; instala trigger BEFORE INSERT |

**Implicação:** a camada mínima conceitual de P-B precisa de 033 e hardening 034–036 **mais todas as dependências reais necessárias**. A closure completa dos objetos que vêm de 001–030 e 031–032 **não foi provada**; não é seguro remover 031/032 só por seu nome ou função aparente.

## 5. Riscos abertos antes de qualquer proposta de instalação

1. Executar wrappers via conector SQL que não entende `\\ir` deixaria o contrato incompleto; caminhos relativos precisam ser fixados.
2. O uso de `CREATE OR REPLACE FUNCTION` e de `DROP TRIGGER/CREATE TRIGGER` exige análise de DDL privilegiado e evidência externa; não assumir migração irrelevante ou invariantes imutáveis.
3. Vínculos cross-schema e ordem de views/funções exigem closure de dependências com pós-condições concretas; revisão textual parcial não valida `pg_catalog`.
4. Calibração 032 e observação não normativa 033 têm finalidades diferentes; não converter frequência/SLA em norma por presença de tabelas.
5. Bootstrap de status/authority/freeze para um novo epoch exige decisão futura distinta; scripts B1R1, fixtures e readouts não integram o bootstrap de um piloto factual.
6. Catálogo de 36 migrations continua `UNREVIEWED`, pós-condições aprovadas 0; matriz 034–036 tem 36 requisitos `NOT_COLLECTED`, modelo de roles tem 12 controles pendentes.

## 6. Próximo checkpoint candidato

**CP192, somente após novo `Prossiga` e Freshness Gate:** mapear **arestas de dependência entre a camada temporal 031–036 e objetos/entrypoints prévios 001–030**, em escopo estritamente estático, com decisão sobre quais arestas precisam de prova e se a instalação reduzida é sequer plausível. Sem gerar um plano de instalação autorizado; prioridade a evitar trabalho redundante.

BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 parcial; P-B não autorizado, B1R1 EXPIRED_NOT_EXECUTED, M3 BLOCKED, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.

**STOP.**
