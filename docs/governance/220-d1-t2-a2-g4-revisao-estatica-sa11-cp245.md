# Documento 220 — D1/T2-A2: revisão estática pós-CP244, SA-11 e bloqueios de publicação (CP245)

**OES | 2026-10-22 | DOCUMENTARY_CHECKPOINT_STATIC_SOURCE_UNPUBLISHED_SA11_BLOCKED | A2-G5 E T2-A2 OPERACIONAL NOT_AUTHORIZED**

## 1. Natureza do registro e autoridade

CP245 consolida **exclusivamente documentalmente** as seis atividades técnicas estáticas A1–A6 pós-CP244 e a atividade de publicação documental A7. Autoridade de código: Documento 218/CP243, `APPROVED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`. Fonte de continuidade CP244: Documento 219, `archive/handoffs/oes/OES_Continuidade_2026-10-22_CP244.md`, mais Docs 216–217.

**Aprovação de escrita de fonte não autoriza execução.** Nenhum dos seis arquivos técnicos é publicado neste checkpoint, e o pacote não atinge `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED` nem `A2-G4_COMPLETED`. As alegações abaixo são **inspeções textuais de código não executado**, não evidências de comportamento PostgreSQL.

Freshness Gate inicial para esta publicação: `main` HEAD `4c9ec2df9255cb103b7b4e0e7390b60853f873cf`, `identical`, ponteiro CP244; o diretório `prototypes/d1_t2/a2/` continua ausente do GitHub. Exigir Freshness Gate imediatamente antes de qualquer commit. CP245 altera somente arquivos canônicos de documentação e continuidade.

## 2. Sequência A1–A6 pós-CP244

| Atividade | Trabalho no staging local | Parecer restrito |
|---|---|---|
| A1 | Correção SA-02 em `errors.py`, `repository.py`, `bridge.py`, `README.md`: `RollbackNotConfirmed`, condição explícita para retry de `23505` | Mitigação candidata, sem teste |
| A2 | Revisão adversarial SA-02; atualização somente do README | Mitigação textual observada; SA-05/SA-06 ainda condicionantes |
| A3 | Refinamento `repository.py`/`errors.py` e README: fábrica exclusiva por contrato, `Connection.closed`, inspeção de estado e rastreabilidade de rollback | SA-05 não encerrada: exclusividade, origem, papel, TLS não comprovados |
| A4 | Revisão adversarial do ciclo de vida; só README | Detectada falha de limpeza pós-COMMIT potencialmente invisível ao chamador; SA-06 ainda alta |
| A5 | Refinamento `errors.py`, `repository.py`, `bridge.py` e README: `CommitConfirmedCleanupFailed`; preparar cópia da resposta antes de COMMIT | Comunicação de falha pós-COMMIT mitigada textualmente |
| A6 | Revisão adversarial SA-06; somente README | **SA-11 NOVO: bloqueio alto de aceitação estática** em exceção pré-COMMIT com rollback falho no `__exit__` |

A7 publica **somente** este documento, o handoff, o ponteiro e atualizações cumulativas STATE/CHANGELOG. Não ocorreram instalações, imports/compilação/execução do adaptador, testes, SQL, consultas/conexões Neon, CI, fixture, DDL/DML, grants, migrações, deploy, custos ou acesso a dados reais.

## 3. Inventário de staging local — não persistência canônica

No ambiente desta conversa foram encontrados exatamente seis arquivos em `/mnt/data/oes_cp243_staging/prototypes/d1_t2/a2/`. Os hashes abaixo foram computados como operação **de leitura dos bytes dos arquivos**, sem importar ou executar código; **não constituem prova de validade, segurança, disponibilidade futura ou existência no GitHub**.

| Arquivo | SHA-256 da cópia local no momento do checkpoint |
|---|---|
| `__init__.py` | `ad38331d4c7cad003386219a74d5eb3c6492b8d716b0bc52e77c53e8c6fd74cc` |
| `errors.py` | `41c81a84217517df98f582ecd3026d5b830b948c2da7355bf018dfddd2d4ce28` |
| `codec.py` | `f22c181f7775d4bdc67841a37815e7917ba332b5cc2e38616b4c64ce797cef11` |
| `repository.py` | `3342b499cb3877a6349d43fe4b31cdb1f6146e3651bf623f777416dda693af62` |
| `bridge.py` | `b8288630ff75d8b62a81ca9b230aa214f4d1ba7ba97964cfa6986d8dcb748e70` |
| `README.md` | `ae5a4bf146d243e270b3139ad8953bf7d19a3758ccc0c246c0c9cc3298122527` |

Não presumir preservação de staging ao mudar de conversa/ambiente. Na retomada, verificar existência e hashes; se ausentes/divergentes, STOP e recuperar/controlar diferenças antes de continuar.

## 4. Matriz adversarial pós-A6 — interpretação estritamente estática

| Achado | Estado | Restrição ou risco |
|---|---|---|
| SA-01 | Mitigação estrutural anterior, sem teste | Commit/rollback e limpeza sem confirmação operacional |
| SA-02 | Mitigação textual após A1–A3, condicionada a SA-05 | Retry de colisão só com rollback e fechamento reportados; não equivale a prova |
| SA-03 | Mitigação parcial | Contagem/estrutura de eventos e recibos não demonstram vínculo semântico total |
| SA-04 | Mitigação estrutural anterior, sem teste | Filhos sem cenário e visibilidade concorrente exigem cuidado |
| SA-05 — ALTA | **ABERTA** | Checks passivos não atestam fábrica exclusiva, papel, banco, TLS, não compartilhamento |
| SA-06 — ALTA | Mitigação textual parcial, **ABERTA** | Exceção `CommitConfirmedCleanupFailed` visibiliza cleanup pós-commit; classificação de abortos/reconciliação não provada |
| SA-07 — MODERADA | ABERTA | Precisão/limites/round-trip JSONB não demonstrados |
| SA-08 — ALTA | ABERTA | Replay e correlação entre recibos/eventos não totalmente verificáveis pelo schema |
| SA-09 | Mitigação estrutural anterior, sem teste | Evitar rollback duplicado e mascaramento de erros |
| SA-10 — MODERADA | ABERTA | Mapeamento SQLSTATE contextual incompleto |
| **SA-11 — ALTA/BLOQUEADOR** | **NOVO, ABERTO** | Exceção pré-COMMIT + rollback falho dentro do `__exit__` pode propagar apenas erro primário, sem tipo que ateste rollback não confirmado |

**SA-11 (detalhamento):** diferentemente de SA-02 (falha SQL na rotina de commit seguida de rollback falho), SA-11 pode ocorrer se `bridge.py` ou outro chamador lança `DomainError`, `RepositoryConflict` ou outra exceção dentro de `with uow` antes da chamada de `commit()`, e `repository.py.__exit__` falha ao reverter trabalho pendente. Anexar somente uma nota ao erro primário não garante a consumidores uma classificação estruturada de `ROLLBACK_UNCONFIRMED`. **Proposta para próxima atividade:** codificar uma exceção tipada ou outra representação inequívoca que impeça tratar a transação como seguramente revertida; conservar erro primário em encadeamento e diagnóstico de rollback/fechamento acessível sob redação sensível; distinguir de `CommitOutcomeUnknown`, que se refere a confirmação iniciada e não conhecida. Revisar efeito no fluxo de retry sem automaticamente executá-lo.

**SA-06:** `CommitConfirmedCleanupFailed` indica que `conn.commit()` retornou normalmente e houve falha de limpeza reportada; não permite retry e não deve ser interpretada como `OUTCOME_UNKNOWN`. Ainda não prova durabilidade material, fechamento efetivo do backend ou reconciliação.

A2-G4 **não está aceita nem publicada tecnicamente**. Não ampliar schema, privileges ou escopo técnico para contornar riscos; o esquema atual não prova semanticamente todos os invariantes.

## 5. Fronteira operacional, histórico e plano

Psycopg `3.3.6`, distribuição `psycopg`, é **somente referência de API** para escrita. Nenhuma instalação autorizada. Ambiente Neon Free sintético, app role `oes_t2a2_app` somente em etapa futura independente; `oes_t2a2_runtime` não utilizar, `oes_t2a2_owner` não utilizar como runtime; não tocar `oes-sandbox`. Sem SQL, CI, testes, conexões, novos objetos, GRANTs, dados factuais/reais, pagamentos ou gates científicos/operacionais.

T1 36 PASS e T2-A1 75 PASS são **históricos** e não foram reexecutados. A2-G2/E `COMPLETED_STRUCTURAL_ONLY`, A2-G3 `COMPLETED_MINIMAL_GRANTS_VERIFIED`; F01–F07 somente documentalmente endereçados, L1–L4 pendentes, O-01–O-10 não executados, 36 migrações `UNREVIEWED`. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. Prioridade D0 fechado → D1 sintético → D2 factual diferido → governança completa posteriormente.

## 6. Ponto exato de retomada e STOP

**A1 pós-CP245, somente após novo `Prossiga`:** executar uma atividade **estática de correção SA-11**, delimitada aos seis arquivos técnicos autorizados (prioridade `repository.py`, `errors.py`, `bridge.py` se necessário, e README); não importar, compilar, executar, testar ou publicar código nesta atividade automaticamente. Primeiro verificar Freshness Gate e hashes do staging; após correção, realizar uma revisão adversarial independente em atividade separada. Não declarar SA-11 PASS nem A2-G4 concluída sem evidência cabível.

CP194: um `Prossiga` autoriza uma atividade interna; checkpoint após 3–5 atividades ou risco, com progresso, Freshness Gate no início e antes do commit, relatório e STOP.

**STOP — CP245 documental exclusivamente; código-fonte A2 permanece fora do GitHub.**
