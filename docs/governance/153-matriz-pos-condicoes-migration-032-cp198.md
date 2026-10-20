# 153 — Matriz documental de pós-condições da migração 032 (CP198)

**OES | Fase 4 | 2026-10-20 | modo médio**  
**Classificação:** `G1_MIG_032_POSTCONDITIONS_DRAFT_ONLY`, sem SQL executado, sem aprovação BRG-06.

## 1. Escopo e autoridade

Freshness Gate CP197/main `c6f799a5bff6f50344ca65ec7cb384f9440f174a` identical, zero ahead/behind. Bloco equilibrado de quatro atividades internas A1–A4: inspeção estática dos arquivos `database/032a_temporal_calibration_core.sql`, `032b_temporal_cadence_contract.sql`, `032c_temporal_sla_contract.sql`, `032d_temporal_sla_runtime.sql` e wrapper `032_temporal_calibration_prerequisites.sql`. A autorização `PREPARE_G1_DOCUMENTARY_ONLY` não permite executar migrações nem homologar pós-condições.

## 2. Inventário declarado no código

| Fragmento | Tabelas `CREATE TABLE` | Funções `CREATE FUNCTION` | Triggers `CREATE TRIGGER` (inclusive CONSTRAINT) |
|---|---:|---:|---:|
| 032a | 6 | 6 | 7 |
| 032b | 3 | 10 | 8 |
| 032c | 1 | 22 | 6 |
| 032d | 0 | 18 | 2 |
| **Total textual** | **10** | **56** | **23** |

Dos 23 triggers, **19 convencionais e quatro constraint triggers**. Os quatro são:

- `tr_temporal_calibration_dossier_complete` em `maintenance.temporal_calibration_dossier`, AFTER INSERT OR UPDATE;
- `tr_cadence_contract_complete` em `maintenance.cadence_contract`, AFTER INSERT OR UPDATE;
- `tr_sla_calendar_candidate_match` em `maintenance.sla_calendar_version`, AFTER INSERT;
- `tr_sla_rule_candidate_match` em `maintenance.sla_rule`, AFTER INSERT.

Os quatro usam `DEFERRABLE INITIALLY DEFERRED`, `FOR EACH ROW`. A auditoria deverá comparar o vínculo trigger/tabela/função, eventos e semântica de diferimento, não apenas cardinalidade. Cada declaração é precedida por `DROP TRIGGER IF EXISTS`; não foi identificado loop de criação dinâmica de triggers equivalente ao de 031c. Contagem de código não é comprovação de objetos no banco.

## 3. Alterações de tabelas anteriores

| Tabela preexistente | Coluna adicionada | Tipo / relação |
|---|---|---|
| `maintenance.update_policy` | `cadence_contract_uuid` | UUID, FK a `maintenance.cadence_contract` |
| `maintenance.sla_calendar_version` | `temporal_calibration_dossier_uuid` | UUID, FK a `maintenance.temporal_calibration_dossier` |
| `maintenance.sla_rule` | `temporal_calibration_dossier_uuid` | UUID, FK ao dossiê |
| `maintenance.sla_rule` | `fixed_deadline_source_uuid` | UUID, FK a `maintenance.fixed_deadline_source` |
| `maintenance.sla_instance` | `due_calculation_payload` | JSONB |
| `maintenance.sla_pause` | `due_extension_eligible` | BOOLEAN |
| `maintenance.sla_pause` | `accountable_pause_seconds` | NUMERIC |

São sete colunas em cinco tabelas anteriores, criadas com `ADD COLUMN IF NOT EXISTS`: existência não atesta tipo ou FK compatíveis. Algumas tabelas anteriores também recebem ou substituem triggers, requerendo leitura do estado final.

## 4. Pós-condições propostas (não aprovadas)

| ID | Teste somente leitura futuro | Falha a detectar |
|---|---|---|
| M032-TAB | `pg_class`, `pg_namespace`, colunas, tipos e constraints das 10 tabelas | Ausência ou DDL divergente |
| M032-FUN | `pg_proc`, assinaturas, retornos, linguagem, atributos e função declarada das 56 definições | Função ausente ou diferente |
| M032-TRG | `pg_trigger`/`pg_get_triggerdef`/estado habilitado para 23 triggers | Trigger ausente, desabilitado, tabela, função, evento ou momento incorreto |
| M032-CONSTRAINT-TRG | Verificar `tgdeferrable`, `tginitdeferred`, nível ROW e eventos dos quatro constraint triggers | Execução imediata indevida, não diferível ou vínculo incorreto |
| M032-ALTER | `pg_attribute`/`pg_type` das sete colunas acrescidas | Tipo, nulabilidade ou coluna incompatível |
| M032-FK | `pg_constraint` e `convalidated` das FKs novas e referenciadas | FK ausente, destino diferente ou não validada |
| M032-GUARD | Testes negativos específicos, mediante autorização de ambiente descartável | Invariantes violadas sem rejeição |
| M032-DEFERRED | Testes com erro na confirmação de transação, em ambiente autorizado | Constraint trigger não interrompe transação inválida |
| M032-TX | Recibo, SHA-256 e teste de rollback independente (futuro) | Estado parcial ou aplicação não reconciliável |

**Observações:** cada requisito de evidência deverá vincular SHA da fonte, objeto, definição esperada, query de verificação versionada, resultado, instante, executor e revisão independente. Nenhum teste listado foi aplicado ao PostgreSQL. O `CREATE TABLE IF NOT EXISTS` e `ADD COLUMN IF NOT EXISTS` não validam equivalência estrutural. A leitura de SQL não comprova sucesso de transações nem comportamento de triggers.

## 5. Gates e retomada

`database/f4-reconciliation-postconditions-draft.json` continua com 36 entradas `UNREVIEWED`, zero pós-condições aprovadas; não foi modificado. BRG-03/06/07/08 BLOCKED; BRG-04/05 históricos; BRG-09 parcial; 36 requisitos 034–036 NOT_COLLECTED, 12 controles de papéis insatisfeitos. B1R1 expirado, novo epoch/P-B não autorizados, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED.

Próxima atividade sob `Prossiga`: novo bloco A1, inventário documental das pós-condições de 033a–e (cinco fragmentos), sem execução, com comunicação intermediária de progresso.

**STOP.**
