# 151 — Consolidação de evidências transacionais G1-MIG / BRG-06 (A1–A4)

**OES | Fase 4 | CP196 | 2026-10-20 (America/Recife) | modo médio**  
**Resultado:** `BRG06_STATIC_CI_ERROR_PROPAGATION_OBSERVED — GATE_BLOCKED`. Exclusivamente documental. Freshness Gate pré-publicação: CP195/main `c94a0e3839abe562c168411e8d0ab386fc790fab` identical.

## Escopo e evidência

Quatro atividades internas A1–A4 consolidadas após CP195, na autorização `PREPARE_G1_DOCUMENTARY_ONLY`. Fonte direta: `database/f4-reconciliation-postconditions-draft.json`, wrappers 031–033, seus 14 fragmentos e `.github/workflows/validate-s5.yml`. Nenhum SQL foi executado, nenhuma CI disparada, nenhuma operação Neon, fonte científica ou custo.

## Resultados

| Atividade | Achado verificável | Ressalva |
|---|---|---|
| A1 | 36 entradas no catálogo, 36 `UNREVIEWED`, zero pós-condições, zero habilitações de execução; 30 fronteiras `UNREVIEWED` | Catálogo draft não é ledger nem prova de aplicação |
| A2 | 031–033 `INTERNAL_BEGIN_COMMIT_OBSERVED`; 034–036 `NO_WRAPPER_BEGIN_COMMIT_OBSERVED`; todas ainda `review_state=UNREVIEWED` | Classificação sintática não equivale a boundary testada |
| A3 | Inspeção textual dos 14 fragmentos dos wrappers não identificou `COMMIT`/`ROLLBACK`/`SAVEPOINT` explícitos e identificou quatro blocos `DO` | Inspeção não valida efeitos dinâmicos ou rollback em falha |
| A4 | Workflow `validate-s5.yml` usa `set -euo pipefail` no passo de migrações, `psql -v ON_ERROR_STOP=1 -f ... 2>&1 \| tee ...` nas entradas 001–036 | Evidência estática de propagação de código de erro nesse contexto, não prova funcional nem recuperação |

**Correção de incerteza:** na A3, a propagação de falha em `psql | tee` estava em aberto; a leitura da configuração do passo em A4 comprovou `set -euo pipefail`. No bash desse passo, erro não mascarado de `psql` deve tornar o pipeline malsucedido e acionar `set -e`. Não generalizar a conclusão a outros workflows nem a execução fora desse contexto. `ON_ERROR_STOP=1` não garante que cada statement seja atômico; wrappers 031–033 usam transação explícita, mas não houve teste de falha/rollback.

## Pendências decisivas BRG-06

1. Revisar as 36 entradas quanto a boundary e hashes exatos, incluindo closure dos 14 subordinados.
2. Especificar pós-condições por objeto/FK/trigger/permissão e evidência externa.
3. Demonstrar ledger/recibos de aplicação e comportamento seguro em estado incerto; proibir replay automático até validação.
4. Comprovar em teste descartável autorizado (futuro) falha injetada e rollback integral, sem escrita factual nem custo não autorizado.
5. Integrar BRG-03/07/08 e privilégios mínimos, auditoria independente, backup/restauração antes de qualquer operação factual.

**Estado:** 36 migrations `UNREVIEWED`, zero pós-condições aprovadas, 36 evidências 034–036 `NOT_COLLECTED`, 12 controles de roles não satisfeitos; BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 parcial. B1R1 `EXPIRED_NOT_EXECUTED`, P-B/novo epoch não autorizados, M3 BLOCKED, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.

## Próximo bloco

Após novo `Prossiga`, A1: especificar **modelo de pós-condições documentais por classe de migration**, iniciando pela 031–036, sem alterar JSON canônico, promover review_state, executar SQL ou ativar CI. Persistir após 3–5 atividades ou gatilho material. **STOP.**
