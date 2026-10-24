# Documento 263 — PG-A4-G1: CI comprovada e gate PG-A4-G2

**OES | 2026-10-24 | Base CP271 | HEAD validado `124cf31e4f505430588318084c8a83a7c5b560ef` | G1_OFFLINE_CI_PASS / G2_NOT_AUTHORIZED**

## 1. Resultado factual G1
Workflow manual `.github/workflows/oes-django-vertical-slice-validation.yml`, run [40102803355](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40102803355), executado para `main` no commit `124cf31e4f505430588318084c8a83a7c5b560ef`, conclusão `success`. Log do job confirmou `manage.py check` sem problemas e `Ran 32 tests` / `OK`; entre os testes estão os novos testes locais `test_disabled_by_default` e `test_projection_and_parameterized_read`. A advertência do Django sobre `override_settings(DATABASES=...)` não bloqueou os testes; sua remoção é aperfeiçoamento posterior não crítico. Nenhuma conexão Neon foi demonstrada pela CI e não houve fixtures no banco.

Componentes versionados: `applications/oes_web/config/settings.py` (alias `oes_synthetic_reader` opt-in, endpoint fixado à branch sintética), `evidence/synthetic_pg_reader.py` (consulta parametrizada read-only), `evidence/tests/test_synthetic_pg_reader.py`, `requirements.txt` (psycopg) e README. As views antigas continuam usando JSON. Sem Django migrations no esquema PoC.

## 2. Gate proporcional proposto para G2
**G2-A — prova de conexão Django sem dados:** após autorização específica, executar em ambiente descartável/privado, sem senha em código, log, artifact ou GitHub Actions, uma única consulta Django através de `oes_synthetic_reader` contra projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, endpoint `ep-wispy-dream-b6021bw0`, banco `oes_sandbox`, usuário `oes_pg_a4_reader`. A consulta vazia (ausência de fixtures depois do rollback de PG-A3) é PASS apenas para conexão/autenticação/consulta e não para projeção com vínculos.

**G2-B — prova relacional com dados sintéticos:** requer **aprovação adicional para inserções**, com uma fixture SQL versionada e inteiramente artificial (2 Study, 2 Report, N:M, provenance). Antes de executar: conferir cabeçalhos/hash, rever instruções, verificar quotas Free e IDs, usar role de escrita apenas para carga controlada; leitura Django exclusivamente com role `oes_pg_a4_reader`. Registrar cardinalidade, versões e identidade `SYNTHETIC_TECHNICAL_ONLY`, não mapear NCT para Study. Limpeza reversível ou descarte somente por autorização específica.

**Segurança:** o GitHub Actions atual não possui credenciais da branch; não criar secrets ou job conectado por inferência. Não transmitir senha por chat e não usar usuário proprietário no Django. Desvio de branch/role/credenciais/custos ⇒ STOP.

## 3. Estado
`PG_A4_G1_OFFLINE_CI_PASS_32_OF_32 / PG_A4_G2_NOT_AUTHORIZED / PG_A3_CLOSED_SYNTHETIC_RESTRICTED`. CP271 continua vigente. D2-E6-G1 permanece bloqueado, 36 migrations UNREVIEWED, Fase 5 NOT_STARTED, readiness NOT_READY. Próxima decisão: autorizar somente **G2-A (conexão Django sem dados)**, sem G2-B ou modificações Neon por inferência. STOP.
