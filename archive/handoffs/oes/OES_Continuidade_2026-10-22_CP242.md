# OES — Continuidade CP242

**2026-10-22 | anterior CP241 | A2-G4 AUTHORIZATION_PROPOSAL_DOCUMENTARY_ONLY | A2-G4/G5 E T2-A2 NOT_AUTHORIZED**

## 1. Natureza e base canônica

CP242 consolida **quatro atividades A1–A4 pós-CP241**, mais o checkpoint documental A5, **sem aprovação técnica**: minuta inicial de código-fonte A2-G4, revisão adversarial AA-01–AA-09, consolidação da minuta e avaliação final AF-01–AF-05. Fonte canônica: Documento 217, `docs/governance/217-d1-t2-a2-g4-minuta-autorizacao-estatica-cp242.md`; Documento 216/CP241, Documentos 197 e 205–215, T1/T2-A1 e template de continuidade CP194. Base GitHub anterior: `main` HEAD `1f08c1f7081cce09a231f01140d4d1bf6b9a479d`; verificação inicial `identical`. Confirmar HEAD novo e ponteiro na retomada.

## 2. O que está deliberadamente pronto e o que não está

Documento 217 apresenta **somente proposta** `ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY`, seis arquivos técnicos candidatos em `prototypes/d1_t2/a2/`, código sem execução, sem novos arquivos técnicos, sem alterações em T1/T2-A1, sem novas cópias T1, importação canônica e exceções preservadas semanticamente, Psycopg 3 não instalado, JSONB explícito, UoW com commit explícito e rollback de saídas não confirmadas, `CommitOutcomeUnknown`, `READ COMMITTED`/lock como hipótese, colisão de criação por rollback+nova transação, replay consistente, nenhum retry automático por padrão.

AA-01–AA-09 e AF-01–AF-05 foram **endereçados no texto**, não encerrados por prova operacional. **AF-03 ainda requer decisão expressa sobre versão/distribuição Psycopg 3 ou exceção estática muito delimitada antes de qualquer autorização técnica**; AF-01 diferencia identidade de exceções em módulos distintos; AF-02 separa seis arquivos técnicos e registro de checkpoint; AF-04 condiciona incerteza ao estágio e evidência; AF-05 limita status futuro a `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`.

## 3. Proibições e evidências preservadas

A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`. A2-G2/P1 `COMPLETED_WITH_LIMITATIONS`, P2 `COMPLETED_WITH_SECURITY_FINDINGS`, E `COMPLETED_STRUCTURAL_ONLY`, A2-G3 `COMPLETED_MINIMAL_GRANTS_VERIFIED`. **A2-G4 (código), A2-G5 (testes) e implementação T2-A2 NOT_AUTHORIZED**. Nenhum código, SQL, Neon, CI, driver, teste, fixture, grant, segredo, conexão ou custo foi executado no bloco A1–A5. Neon Free sandbox sintético exclusivamente, sem tocar `oes-sandbox`; `oes_t2a2_app` candidato app; `oes_t2a2_runtime` proibido; owner elevado; TLS comprovado somente até endpoint cliente Psycopg.

T1 36 PASS históricos, T2-A1 75 PASS históricos incluindo T1; F01–F07 somente documentalmente endereçados; L1–L4 e O-01–O-10 pendentes; 36 migrações `UNREVIEWED`; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. Não promover prova ou classificação científica.

## 4. Retomada delimitada

**A1 pós-CP242:** preparar documentalmente submissão e decisão sobre versão/distribuição Psycopg 3, alternativa AF-03 e texto final de autorização **sem implementá-la**, somente sob novo `Prossiga`. Após análise, o proprietário poderá aprovar **expressamente** escopo técnico independente. **Um `Prossiga` simples não aprova a minuta.**

Protocolo CP194: uma atividade interna por `Prossiga`, checkpoint em 3–5 atividades ou antecipação por risco, mensagens de progresso, Freshness Gate no início e antes de commit, reporte `NÃO PERSISTIDO`/`PERSISTIDO`, STOP ao checkpoint. Ponteiro: `archive/handoffs/oes/README.md`.

**STOP.**
