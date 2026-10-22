# OES — Continuidade CP248

**2026-10-22 | CP248 DOCUMENTAL ANTECIPADO POR RISCO DE PERDA | A2-G4_PRESERVATION_BRANCH_EXISTS_UNVALIDATED | A2-G5/T2-A2 OPERATION NOT_AUTHORIZED**

## 1. Referências de continuidade

Fonte canônica: `main`, `archive/handoffs/oes/README.md`, Documento 223 `docs/governance/223-d1-t2-a2-g4-preservacao-branch-isolada-cp248.md` e CP anterior `archive/handoffs/oes/OES_Continuidade_2026-10-22_CP247.md`. CP248 registra **a decisão aprovada pelo proprietário de criar branch segregada de preservação**, sem avanço técnico sobre SA-07.

Branch de recuperação: `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`. **Commit fixo:** `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, descendente direto do HEAD CP247 `7f3b25aa5563455a98e01c7c358118dfe9c38546`. Cópia contém exatamente seis arquivos em `prototypes/d1_t2/a2/`; hashes Git individuais no Documento 223, hashes SHA-256 locais do CP247 no Documento 222. A branch foi comparada ao commit salvo com resultado `identical` antes do checkpoint; conferir novamente em futura retomada, sem presumir que refs não possam mudar. A branch não foi declarada protegida contra exclusão.

## 2. Fronteira e estado

**Somente o checkpoint documental é publicado em `main`.** Código experimental preservado apenas na branch própria; nenhuma promoção, merge, PR, teste, CI, import/compilação/execução, SQL/Neon, driver, grants, segredo, API, dado real, custo ou deploy. A2-G4 código estático aprovado mas não aceito; A2-G5/T2-A2 runtime `NOT_AUTHORIZED`. Fonte técnica CP247: SA-05 global ABERTA/ALTA, SA05-R1/R2/R3 mitigadas estaticamente; SA-02 depende de SA-05; SA-03 parcial; SA-06, SA-07, SA-08, SA-10 abertas; SA-11/12 mitigadas apenas estaticamente. T1 36 e T2-A1 75 PASS históricos, Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrações UNREVIEWED, D1 sintético prioritário, D2 factual diferido.

## 3. Retomada exata

**A1 pós-CP248, após novo `Prossiga`: triagem adversarial somente estática SA-07, compatibilidade codec/JSONB numérico.** Ler o `codec.py` preservado no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1` e os contratos canônicos; sem executar, compilar ou importar código, sem SQL/Neon/CI, sem editar `main` ou a branch de preservação. Se uma correção futura for necessária, avaliar explicitamente uma branch separada de trabalho.

Aplicar Freshness Gate ao `main` e à branch, protocolo CP194 (uma atividade por `Prossiga`, progresso, checkpoints sob risco, STOP). Se os hashes ou a branch divergirem, reportar e reconciliar antes de agir.

**STOP — CP248 exclusivamente documental.**
