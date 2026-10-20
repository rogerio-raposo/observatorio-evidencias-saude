# OES — Continuidade CP178

**Data:** 2026-10-20 (America/Recife)  
**Checkpoint:** CP178  
**Anterior:** CP177  
**HEAD de entrada:** 73280fd0fdc7f0dd440feee0f741299d1d34e476  
**Commit técnico:** 909922efd400b237181445c5a206f97b3fcc19e9  
**Modo:** alto  
**Estado:** PostgreSQL 18 descartável, ADMIN FALSE, cadeias transitivas SET/INHERIT, falhas de completude de recibos, 40/40 PASS, nenhuma operação Neon.

## 1. Freshness Gate e autorização

Template canônico, ponteiro CP177, handoff integral, STATE/CHANGELOG e Documento 133 consultados. HEAD CP177/main identical, 0 ahead e 0 behind. Prossiga autorizou um checkpoint de ensaios sintéticos e documentação, excluindo Neon, custos, B1R1 e Fase 5.

## 2. Entregas

Documento 134: docs/governance/134-ensaio-pg18-cadeias-transitivas-delegacao-falhas-auditoria.md.

- scripts/oes_f4_pg18_role_transitivity_audit_adversarial.py
- .github/workflows/f4-pg18-role-transitivity-audit-adversarial-synthetic.yml

PostgreSQL 18 allowlisted em serviço de CI efêmero; migrations 001–036 aplicadas somente nesse serviço; três LOGIN, owner NOLOGIN e três roles intermediárias artificiais; seis memberships ADMIN FALSE. Guard 034 da tabela real de teste modificado somente na fixture.

## 3. CI e artifact

Run 39410126403 / job 118585562919, commit técnico 909922efd400b237181445c5a206f97b3fcc19e9: completed/success, 40/40 PASS em checks.tsv e logs, marcador CP178_PG18_SYNTHETIC_LIMITED_PASS.

Artifact 12259205919 f4-pg18-role-transitivity-audit-cp178: 11 arquivos, testzip()=None, SHA256 4577ddde26943d00c05e7dc9b4143ab288d106aa4692ee5e04a1e641f3be5c46 igual ao digest GitHub.

## 4. Resultados com limitações

- ADMIN FALSE negou delegações diretas; SET ROLE owner seguido de GRANT owner também falhou na fixture.
- SET TRUE transitivo permitiu assumir owner e executar DDL contra guard 034.
- INHERIT TRUE transitivo com SET FALSE permitiu DDL proprietário sem SET ROLE.
- SET FALSE/INHERIT FALSE bloquearam o caminho negativo testado.
- Falha simulada deixou attempt sem result, detectado como trilha incompleta sem provar se houve execução; não ocorreu queda real de controlador.
- Sessão SQL fora do wrapper desabilitou/reabilitou trigger, não deixou recibos novos e passou pela verificação local de cadeia.
- Alteração conjunta de JSONL e âncora SHA256 enganou o validador. Recibos no runner não equivalem a auditoria externa independente ou imutável.

## 5. Gates e invariantes

BRG-03 = NEON_AND_EXTERNAL_AUDIT_NOT_VERIFIED; BRG-04/05 = HISTORICAL_PINNED_SYNTHETIC_ONLY; BRG-06 = LEDGER_NOT_OPERATIONAL; BRG-07 = SUPERVISOR_RUNNER_FENCING_NOT_APPROVED; BRG-08 = INDEPENDENT_RESTORE_NOT_CONFIGURED; BRG-09 = OWNER_BILLING_PENDING.

36 migrations UNREVIEWED; zero pós-condições aprovadas, auto flags FALSE; 36 requisitos 034–036 NOT_COLLECTED; 12 controles de roles não satisfeitos. Nenhum SQL/branch/migration Neon, nenhum serviço pago. B1R1 EXPIRED_NOT_EXECUTED; Fase 5 NOT_STARTED.

## 6. Ponto exato de retomada

Após novo Prossiga e Freshness Gate, próximo candidato é desenho de contenção de direitos de proprietário indiretos e garantia de auditoria fora do mesmo domínio de confiança, com revisão humana especializada e aprovação específica antes de qualquer Neon/custo. Nenhuma fase ou gate foi promovido.

**STOP — pausa obrigatória após atualização atômica do checkpoint, ponteiro, STATE.md, CHANGELOG.md e confirmação do HEAD.**

**Fim CP178.**
