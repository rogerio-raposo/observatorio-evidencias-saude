# OES — Continuidade CP170

**Data:** 2026-10-19  
**Checkpoint:** CP170  
**Anterior:** CP169  
**HEAD de entrada:** `f928807e76b74dc32b65fe3a707c72232c721c55`  
**Modo:** alto  
**Estado:** ensaio PG18 de diferenças estruturais e falhas artificiais 031–036 verificado, escopo somente sintético; Neon intocado.

## Freshness Gate

O ponteiro apontava CP169; comparação com main = `identical`, 0 drift. Documento 125 e workflow PG18 do CP161 relidos. Nenhum consentimento para criar branch Neon ou executar migrations nele.

## Marco

**Documento 126:** `docs/governance/126-ensaio-pg18-comparacao-estrutural-e-falhas-031-036.md`.

Artefatos:
- `scripts/oes_f4_pg18_031_036_fault_rehearsal.py`: ensaio PG18 exclusivo de GitHub Actions; baseline 001–030, snapshots de catálogos antes/depois 031–036, clones descartáveis e injeções de falha; proibido Neon.
- `.github/workflows/f4-pg18-031-036-fault-rehearsal.yml`: workflow PG18 CI automática sintética, `contents:read`, sem segredos Neon.

A primeira execução `39349451906` (commit `96178dc9cf09bed274ecdf4d4285587330a4629e`, job `118389922941`) falhou por erro no comparador: tentou consultar `maintenance.contract_epoch` antes de 031. Falha preservada. O comparador foi corrigido prospectivamente.

**Run correto:** `39349564581`, commit testado `46af0a575e30d640dedd97edf84315ebc5f6f310`, job `118390284507`, `completed/success`; **29/29 verificações PASS**. Artifact `12233090040` recuperado, ZIP válido, SHA-256 **`6aea06318fb097c66066a75e13b8e03ae23ff52c6c7cf07a9bfffb9009431a3e`** igual ao GitHub.

## Achados e interpretação

- Aplicação normal de 031–036 sobre baseline 001–030 em banco PG18 descartável, com snapshots `pg_class/pg_attribute/pg_constraint/pg_index/pg_trigger/pg_proc`, seed `contract_epoch` quando presente. Alterações estruturais detectadas em cada stage.
- 031–033: erro induzido imediatamente antes de `COMMIT` interno; inventário observado após erro idêntico ao inventário prévio. **Rollback estrutural no cenário testado**, não prova de reversão universal de DML sobre dados preexistentes.
- 034 e 036: **replay negativo controlado** contra clone já instalado; erro após DROP e antes de CREATE deixa trigger ausente. Não é falha da instalação regular.
- 035: erro entre duas funções; primeira ficou instalada e segunda ausente em cenário descartável. Prova de instalação parcial no caminho sem wrapper explícito.
- Instalação normal terminou com seeds estruturais 031/032 e triggers 034/036 presentes.
- Relatório inclui **0 pós-condições validadas** e `grandfathering_populated_fixture_tested=false`. Contagens de diferenças incluem entradas de catálogo, não tabelas ou registros científicos.

## Gates e controles

- `BRG_04 = STATIC_INVENTORY_VERIFIED_HISTORICAL_COMMIT_ONLY`
- `BRG_05 = PG18_36_SCHEMA_INSTALL_HISTORICAL_AND_031_036_FAULT_OBSERVATIONS_PINNED_COMMIT`
- `BRG_06 = LEDGER_SYNTHETIC_MODEL_ONLY_NOT_OPERATIONAL`
- `BRG_07 = SUPERVISOR_SYNTHETIC_MODEL_ONLY_NOT_OPERATIONAL`
- `POSTCONDITIONS = 36_UNREVIEWED_ZERO_VALIDATED_NO_AUTOMATION`
- `GRANDFATHERING_032_POPULATED_FIXTURE = NOT_TESTED`
- `BRG_03 = ACL_TLS_SECRETS_NOT_VERIFIED`
- `BRG_08 = INDEPENDENT_BACKUP_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## Continuidade

Após novo `Prossiga`, fazer ensaio PG18 descartável com fixture **sintético e constraint-consistente** para grandfathering de 032, comparar seed e rollback sobre registros preexistentes; posteriormente, testes comportamentais de functions/triggers 034–036. Qualquer promoção das pós-condições ou integração ao runner exige revisão especializada/decisão separada em modo alto. Não executar SQL nem criar recursos no Neon por `Prossiga` genérico.

**STOP — pausa obrigatória após reconciliação STATE/CHANGELOG/README.**

**Fim CP170.**