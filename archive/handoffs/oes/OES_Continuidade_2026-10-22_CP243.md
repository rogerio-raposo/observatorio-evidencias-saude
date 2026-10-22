# OES — Continuidade CP243

**2026-10-22 | CP242 anterior | A2-G4_STATIC_CODE_ONLY_APPROVED_NOT_STARTED | A2-G5/T2-A2 OPERATION NOT_AUTHORIZED**

## Decisão expressa agora canônica
Documento 218 em `docs/governance/218-d1-t2-a2-g4-autorizacao-estatica-cp243.md` registra declaração explícita do proprietário **“Modo médio. Aprovada”** em resposta à fórmula `APPROVED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`. O `Prossiga` posterior autorizou somente esta **formalização**. CP243 não inclui implementação nem ensaios.

Base GitHub CP242 HEAD `2b06d2812d534e78979e9cc18d6a909383b4d40e`; Freshness Gate inicial `identical`. Confirmar novo HEAD e ponteiro na retomada.

## Fronteira da execução futura
Autorização de código estático e eventual publicação para **exatamente seis arquivos** em `prototypes/d1_t2/a2/`: `__init__.py`, `repository.py`, `bridge.py`, `errors.py`, `codec.py`, `README.md`. Preservar byte a byte T1/T2-A1, importar domínio T1 canônico, reconhecer diferenças de identidade de exceções em contextos de import distintos, commit explícito sem commit implícito em contexto, idempotência semântica e fingerprint Python, JSONB limitado, `CommitOutcomeUnknown` e ausência de retry automático, segurança e SQL parametrizada no código **não executado**. Psycopg `3.3.6`, distribuição `psycopg`, somente **referência de API**, não instalada. Artefatos de governança são separados da lista técnica fechada.

**NÃO AUTORIZADO:** instalar driver, rodar/importar/compilar código do adaptador, executar testes ou CI, SQL, conectar Neon, dados, fixtures, DDL/GRANT, descarte, deploy, dados reais, serviços pagos, `oes-sandbox` ou promoção científica/operacional. A2-G5 e runtime T2-A2 `NOT_AUTHORIZED`.

## Evidências e próximos passos
T1 36 e T2-A1 75 PASS somente históricos; F01–F07 documentalmente endereçados; L1–L4 e O-01–O-10 pendentes; Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. **A2-G4 aprovado para código, ainda não iniciado**.

**Próximo `Prossiga`**: uma atividade estreita de implementação **somente estática** dos módulos iniciais `errors.py`/`codec.py` do A2-G4 e definição de imports, sem publicação por atividade se checkpoint não necessário. Em seguida STOP. Protocolo CP194, Freshness Gate e pausa obrigatória após checkpoint permanecem. **STOP.**
