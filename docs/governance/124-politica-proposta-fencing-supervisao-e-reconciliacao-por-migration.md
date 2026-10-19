# 124 — Política proposta de exclusividade, supervisão e reconciliação por migration (Fase 4)

**OES — 2026-10-19 — modo alto**  
**Classificação:** GOVERNANCE_PROPOSAL — STATIC_DRAFT_VERIFIED — OPERATIONAL_POLICY_NOT_APPROVED — NO_NEON_MUTATION.  
**Base:** Política canônica `docs/architecture/30-politica-migracoes.md`; Documento 113; provas CP163–CP167; HEAD de entrada `0d884ab84e449398ec0367a08364cfde1e5cb8f8`. Freshness Gate CP167/main = `identical`, zero commits de drift.

## 1. Decisão explícita — não confundir cooperação com fencing real

**Advisory lock de sessão é exclusão cooperativa**, não barreira imposta a todo DDL. O PostgreSQL somente aplica seu significado quando todos os clientes relevantes respeitam o protocolo; lock de sessão persiste até liberação ou fim da sessão, e não acompanha rollback. [Documentação PostgreSQL 18](https://www.postgresql.org/docs/18/explicit-locking.html), §13.3.5.

Os experimentos CP165 demonstraram que um subprocesso SQL em voo **pode fazer COMMIT depois de o guardião perder o lock**. Logo:

1. É **proibido** denominar a solução atual de *strong fencing* ou afirmar *exactly-once execution*.
2. O rótulo correto da proposta é **SERIALIZAÇÃO COOPERATIVA + INTENÇÃO DURÁVEL FAIL-CLOSED + RECONCILIAÇÃO**, ainda não operacional.
3. Para obter fencing efetivo de escrita, o próprio caminho de escrita precisaria validar um token de época/capacidade atualizado atomicamente, ou executar dentro de conexão/transação controlada; as migrations legadas não fazem essa validação. Um token mantido somente no supervisor **não impede** um backend antigo de continuar escrevendo.
4. Sem adequação dessas migrations, a perda de confirmação só permite estado `uncertain_requires_reconciliation`, nunca repetição automática ou recibo presumido.

`pg_cancel_backend(pid)` solicita cancelamento; retorno `true` confirma envio do sinal, **não garante** que uma operação anterior não tenha feito commit. `pg_terminate_backend(pid, timeout)` tem semântica dependente do timeout e requer privilégios adequados. [Documentação PostgreSQL 18](https://www.postgresql.org/docs/18/functions-admin.html), §9.28.2.

## 2. Identidade, escopo e precedência dos controles propostos

**Chave de ledger e claim:** identificadores estáveis do ambiente (provider/project ID, branch ID não-default, database ID/nome), migration ordinal + ID governado, identidade de tentativa imutável. Não confundir branch GitHub com branch do banco ou branch Neon `production`.

**Identidade de conteúdo:** HEAD Git (40 hex), caminho do entrypoint, SHA-256 dos bytes do SQL, dependências `\ir` com caminhos + hashes ordenados, digest do inventário; divergência em qualquer parte é `DRIFT_BLOCKED`.

**Lock cooperativo:** identificador determinístico com namespace por database/ambiente, tomado em conexão dedicada mantida ociosa pelo guardião e comprovado antes de cada subprocesso; conjunto de sessões simultâneas precisa seguir a mesma regra. O lock nunca constitui prova de migration aplicada.

**Claim durável:** inserir `prepared` com chave única atômica (com verificação de ambiente + hash) **antes** de começar SQL. Um SELECT de elegibilidade separado de INSERT não é garantia de ausência de race. Se o claim foi persistido, qualquer reentrada — mesmo com lock disponível — deve parar e exigir reconciliação.

**Evidência externa:** evento append-only também fora do mesmo banco, versão/hash/log com redaction e UTC, armazenados sem token, senha, URL de conexão ou registros clínicos. Trigger append-only sozinho não neutraliza administrador privilegiado nem substitui armazenamento independente.

## 3. Máquina de estados proposta — não operacional

| Estado | Descrição | Direito automático |
|---|---|---|
| `prepared` | Intent durável antes de execução; SQL pode nem ter começado | Bloqueia replay |
| `in_progress` | Processo iniciado e identificado, com logs e contexto | Não libera próximo |
| `applied` | Confirmado conforme caminho transacional seguro ou evidência pós-condição validada | Bloqueia replay; libera próxima apenas com política aprovada |
| `failed_verified_rollback` | Rollback **provado**, inclusive SQL/seed, sem commit parcial | Nova execução apenas com autorização/reconciliação deliberada |
| `uncertain_requires_reconciliation` | Resultado desconhecido, recibo ausente, crash ou desconexão | Bloqueia replay, próximo arquivo e promoção |

Eventos de tentativas são append-only. A decisão de reconciliação deve apontar para evidências, aprovador/revisor, instante UTC, hashes e fingerprints observados. **Não permitir mudança silenciosa de `prepared` para `applied` por existência de uma única tabela.**

## 4. Dois caminhos de atomicidade e seus requisitos

### T — mesmo backend/transação

Somente quando um arquivo e **todos os fragmentos** não contêm controle transacional incompatível nem comando PostgreSQL não transacional e os efeitos podem ser verificados. Executor e recibo final devem compartilhar **a mesma transação e backend**. Exigir prova de rollback com erro injetado. Não envolver múltiplas transações sob a afirmação de atomicidade única.

### L — commits legados independentes

Wrappers 031, 032 e 033 têm `BEGIN/COMMIT` internos e incluem, respectivamente, 5, 4 e 5 fragmentos. SQL 034, 035 e 036 foi observado sem wrapper transacional externo explícito; seus comandos independentes podem confirmar separadamente em `psql -f` autocommit. Esses grupos **não** recebem caminho T automaticamente.

Para L, o claim durável antecede a migration; o guardião monitora processo e backend identificados; a detecção de falha proíbe novos comandos, tenta cancelar/encerrar em voo sob políticas de privilégio revisadas e, **independentemente do resultado de cancelamento**, preserva `uncertain` até verificação pós-condição e reconciliação humana. Nem `psql --single-transaction` nem wrapping automático são aprovados para os arquivos legados.

## 5. Supervisão e queda de controladores

Pré-condições de spawn (todas obrigatórias): lock retido, claim durável exclusivo, identidade/hash fixados, predecessor conferido, branch/database/role/TLS compatíveis, log externo pronto, sem tentativa incerta anterior.

Durante SQL: capturar PID do subprocesso **e** `pg_backend_pid()` com `application_name` exclusivo de tentativa, confirmar identidade antes de sinalizar, impor timeouts, monitorar perda do guardião e interromper spawning. Não confiar somente no teste prévio `guardian.poll()`: existe janela TOCTOU entre checagem e spawn, que precisa de mecanismo de coordenação mais forte ou aceitação explícita de modo incerto.

Após perda: revogar a sequência; registrar `uncertain`; procurar backend em voo sem confundir ausência atual com ausência de commit; não sinalizar PID que já possa ter sido reutilizado; não produzir `applied` automático; solicitar reconciliação independente.

Após falha do supervisor principal, não presumir que logs no próprio processo foram persistidos. Um novo supervisor deve primeiro adquirir exclusividade e consultar intents e evidências persistentes, **sem disparar SQL automaticamente**.

## 6. Catálogo de pós-condições por migration

Artefato recém-criado: `database/f4-reconciliation-postconditions-draft.json`. Ele corresponde em ordem aos **36 entrypoints** de `database/f4-neon-sandbox-schema-migration-manifest.txt`. Todos os 36 possuem `review_state=UNREVIEWED`, `postconditions=[]`, `review_evidence=[]` e flags `automated_reconciliation_allowed=false`, `automatic_replay_allowed=false`, `migration_execution_allowed=false`. Inclui **apenas observações textuais sobre as fronteiras de transação de 031–036**, não uma classificação normativa.

Linter `scripts/oes_f4_reconciliation_catalog_lint.py`: recusa entradas ausentes, extras ou reordenadas, caminhos inseguros, campos de promoção prematura, hashes de origem mal formados, ativação automática ou pós-condições não revisadas. Testes `tests/test_oes_f4_reconciliation_catalog_lint.py` usam 11 cenários puramente sintéticos. CI `.github/workflows/f4-reconciliation-catalog-static.yml` usa **apenas checkout e Python**, sem PostgreSQL, sem SQL e sem Neon.

**Limite da prova:** validação documental = 36/36 caminhos alinhados e **0/36 migrations com pós-condições aprovadas**. O `source_head_when_created` é informação histórica de criação do catálogo, não certificação de equivalência de hashes ao HEAD atual.

Para cada migration, uma versão **futura separada** do catálogo deverá ser revisada quanto a:
- relações, colunas, constraints VALIDATED, índices, triggers ativos e definição de funções (não apenas nome);
- seed estrutural e ausência de seed científico indevido; contagens, invariantes e marcadores canônicos;
- classificação de transação (T/L/exception), janelas de commit e cenários de falha antes/depois;
- fingerprints reproduzíveis, dependências anteriores, execução com papel de menor privilégio;
- detectabilidade de efeitos parciais e capacidade real de diferenciar `not applied` de `partially applied`;
- revisores, evidência CI, fonte SQL e escopo ambiental.

Uma migration com pós-condição ambígua ou incompleta = **RECONCILIATION_BLOCKED**, nunca `applied` presumido.

## 7. Prova da CI estática do catálogo e seus limites

Run GitHub Actions `39282514522`, commit `52f796f3b500e550335c06a33c761369804fd3e6`. Logs recuperados: `Ran 11 tests`, `OK`, `FAIL_CLOSED_DRAFT_CATALOG_ONLY`. Artifact `f4-reconciliation-catalog-draft-only` ID `12201766282` baixado e inspecionado. Digest SHA-256 ZIP `208b607dfd72d6ddde9710cef0da0fea093e562fd92a2e76d3e82a3e0f832e8b` confere com API GitHub; `lint.json` e seu SHA-256 conferidos; `commit.txt` confere.

`lint.json`: 36 entradas, **0 revisadas, 0 pós-condições validadas, `sql_executed=false`, `neon_accessed=false`, `neon_write_authorized=false`**. Digest SHA-256 do catálogo: `c76b9291974a6afd1fdeab33d20e8d74563331be68a2989d4013a45d066e4e62`. Digest SHA-256 do manifesto: `0b73466a374b933f1125c1d513aa4f952ad4141be92ac854f6cff35b641bd6df`. O status administrativo `completed/success` precisa ser observado em metadados antes de ser declarado; logs/artifact são evidência da execução da etapa estática.

## 8. Gates impeditivos e decisões futuras

- **BRG-04:** inventário de 36+14 verificado em commit fixado anterior; não promove o catálogo a revisado.
- **BRG-05:** instalação PG18 sequencial verificada em commit anterior; não cobre schema persistente nem privileges.
- **BRG-06:** modelo sintético de ledger testado, **ledger real não aprovado/implantado**.
- **BRG-07:** guardião e supervisor sintéticos testados, **fencing real e runner das 36 migrations não construídos**.
- **BRG-03:** TLS, ACL, separação de roles e segredos não verificados.
- **BRG-08:** backup independente com restore verificado não existente.
- **BRG-09:** consumo/billing no console do owner pendente.
- **BRG-01/02:** autorização específica para branch Neon e sua criação continuam ausentes.
- **BRG-10:** synthetic-only obrigatório; B1R1 expirou sem execução, Fase 5 não iniciada.

**Decisão do bloco:** aprovar apenas a **redação do desenho provisório para discussão técnica**; não aprovar política normativa de migração, *fencing* efetivo, catálogo de pós-condições, executor, ledger ou qualquer ação no Neon. O documento 30 permanece canônico e **não foi alterado**.

**Próximo checkpoint recomendado:** desenvolver revisão de pós-condições **em ambiente descartável e com especialistas responsáveis**, começando por 031–036; depois testar cancelamento/commit incerto com identidades de sessão e receber avaliação formal da governança técnica. Não permitir mudanças em Neon por `Prossiga` genérico.

**Fim do Documento 124.**