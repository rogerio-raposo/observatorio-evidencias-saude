# OES — Continuidade CP246

**2026-10-22 | anterior CP245 | DOCUMENTARY_CHECKPOINT_STATIC_SOURCE_UNPUBLISHED_RESIDUAL_RISKS | A2-G5/T2-A2 OPERATION NOT_AUTHORIZED**

## 1. Autoridade e checkpoint

Ponteiro canônico `archive/handoffs/oes/README.md`; Documento 221 `docs/governance/221-d1-t2-a2-g4-revisoes-sa11-sa12-sa06-cp246.md`; handoff anterior `archive/handoffs/oes/OES_Continuidade_2026-10-22_CP245.md`. Baseline `main` `b9bd139265a1f3f12006c579dbe2e956bb179995`, `identical`, ponteiro CP245. CP246 registra **A1–A6 pós-CP245 e publicação A7 somente documental**. Após publicação, verificar HEAD, ancestralidade, cinco arquivos do diff e ponteiro.

A aprovação Documento 218 `ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE` continua válida só para criação, revisão estática e eventual publicação controlada de seis arquivos técnicos. **Nenhum arquivo `prototypes/d1_t2/a2/` foi enviado ao GitHub** nesta etapa; staging exclusivamente local, com SHA-256 de seis arquivos no Documento 221 (sem garantia de permanência após mudança de conversa).

## 2. Correções/revisões estáticas desde CP245

A1 corrigiu SA-11 com `RollbackNotConfirmed` tipada nos caminhos pré-COMMIT; A2 revisou e identificou SA-12; A3 corrigiu SA-12 por `ConnectionCloseNotConfirmed`, separando close de rollback; A4 revisou SA-12; A5 estendeu `CommitOutcomeUnknown` com diagnósticos de fechamento; A6 revisou o ramo canônico de `with`. **Tudo estático, não testado**. SA-11 e SA-12 mitigadas e revisadas textualmente; SA-06 parcialmente mitigada, **aberta** para reconciliação, classificação e cobertura de ciclo de vida. SA-05 (ALTA), SA-07 (MODERADA), SA-08 (ALTA), SA-10 (MODERADA) seguem abertas; SA-03 parcial. SA-02 depende de SA-05. Sem aceitação A2-G4.

## 3. Limites preservados

Sem imports/compilação/execução do adaptador, testes, CI, SQL, Neon, Psycopg instalado, credenciais, grants, schema, dados reais, custos, deploy, `oes-sandbox` ou promoção. T1 36 PASS/T2-A1 75 PASS apenas históricos; A2-G2/E estrutural e A2-G3 mínimas concessões históricas, A2-G5/T2-A2 runtime `NOT_AUTHORIZED`. F01–F07 documentais, L1–L4/O-01–O-10 pendentes, 36 migrations `UNREVIEWED`; Fase4 `NOT_READY`, Fase5 `NOT_STARTED`; D0 encerrado, D1 sintético prioritário e D2 factual diferido.

## 4. Ponto exato de retomada

**A1 pós-CP246, sob novo `Prossiga`:** triagem adversarial **somente estática** SA-05: separar verificações de contrato possíveis sem execução das garantias dependentes de runtime (fábrica de conexão exclusiva, role, banco, TLS, ciclo de vida), sem acessar banco/CI/driver ou ampliar permissão. Verificar HEAD/ponteiro, existência e hashes de staging, ler Documento 221. Após triagem, decidir uma próxima atividade de correção limitada e posterior revisão; SA-07/08/10/06 seguem agenda. Não publicar pacote A2 automaticamente.

CP194: um `Prossiga` = uma atividade; Freshness Gate inicial/pré-commit; checkpoint por risco ou a cada 3–5 atividades; progresso e STOP.

**STOP — CP246 documental, código técnico não publicado.**
