# OES — Continuidade CP247

**2026-10-22 | anterior CP246 | DOCUMENTARY_CHECKPOINT_SOURCE_STAGED_UNPUBLISHED_SA05_OPEN | A2-G5/T2-A2 OPERATION NOT_AUTHORIZED**

## 1. Autoridade e fonte

Ponteiro vigente `archive/handoffs/oes/README.md`; Documento 222 em `docs/governance/222-d1-t2-a2-g4-fabrica-conexoes-sa05-cp247.md`; CP anterior `archive/handoffs/oes/OES_Continuidade_2026-10-22_CP246.md` e Documento 221. Autoridade estrita Documento 218: `ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`. Freshness Gate base: `main` HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, ponteiro CP246, comparação `identical`.

CP247 documenta **A1–A7 pós-CP246 e publicação A8 exclusivamente documental**. Conferir HEAD final, diff exato e ponteiro após commit. Os seis arquivos de código `prototypes/d1_t2/a2/` **não foram publicados**; staging local `/mnt/data/oes_cp243_staging/prototypes/d1_t2/a2/` tem hashes registrados no Documento 222, sem garantia de existência em outra conversa.

## 2. Achados SA-05 e evolução

A1 triou limites da propriedade/identidade da conexão; A2 introduziu `DedicatedConnectionFactory`; A3 identificou R1/R2; A4 introduziu `ConnectionAcquisitionError`, checagem de interface e consumo one-shot; A5 identificou R3 (`commit` ausente na checagem); A6 exigiu `commit` chamável; A7 revisou estaticamente a correção. **SA05-R1/R2/R3 mitigadas textualmente, R3 revisada adversarialmente**, sem testes. **SA-05 GLOBAL ABERTA/ALTA:** exclusividade real, pooling, papel, banco, TLS, origem da conexão e integridade de contrato não demonstradas. SA-02 ainda condicionada a SA-05.

SA-03 parcial; SA-06, SA-07, SA-08 e SA-10 abertas; SA-11/SA-12 mitigadas/revisadas somente estaticamente. A2-G4 não aceita nem publicada tecnicamente.

## 3. Proibições e histórico preservado

Sem import/compilação/execução do adaptador, testes, driver, CI, SQL, Neon, secrets, grants, DDL/DML, migrações, alterações `oes-sandbox`, dados reais, pagamentos, deployment ou promoção. Psycopg 3.3.6 apenas referência estática. A2-G5/T2-A2 runtime `NOT_AUTHORIZED`. T1 36 e T2-A1 75 PASS somente históricos; F01–F07 documentais, L1–L4/O-01–O-10 pendentes; 36 migrações `UNREVIEWED`, Fase4 `NOT_READY`, Fase5 `NOT_STARTED`, D1 sintético prioritário e D2 factual diferido.

## 4. Retomada exata

**A1 pós-CP247:** sob novo `Prossiga`, executar **triagem adversarial estática SA-07**, numérica/JSONB, com Freshness Gate e integridade de staging, sem executar/importar codec, Psycopg, banco ou testes. Decidir apenas possível próxima correção textual; SA-08, SA-10, SA-06 depois, em atividades individuais. Se os arquivos locais estiverem ausentes/divergentes, reportar bloqueio e recuperar controladamente.

CP194: uma atividade por `Prossiga`, checkpoint após 3–5 atividades ou risco, Freshness Gate no início e antes do commit, comunicação de progresso, STOP.

**STOP — CP247 documental.**
