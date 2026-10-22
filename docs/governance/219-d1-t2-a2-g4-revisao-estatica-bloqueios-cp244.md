# Documento 219 — D1/T2-A2: continuidade da implementação estática A2-G4 e bloqueio de publicação (CP244)

**OES | 2026-10-22 | STATIC_SOURCE_STAGED_UNPUBLISHED_REVIEW_BLOCKED | A2-G5 E T2-A2 OPERACIONAL NOT_AUTHORIZED**

## 1. Autoridade, proveniência e alcance

Este documento consolida **exclusivamente** a preparação de código-fonte e suas duas inspeções estáticas A1–A6 pós-CP243, sob a aprovação específica do proprietário registrada no **Documento 218/CP243**:

`APPROVED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`.

Essa aprovação continua válida **somente** para a criação, revisão estática e eventual publicação controlada de seis arquivos técnicos em `prototypes/d1_t2/a2/`. O objetivo do CP244 é preservar o diagnóstico e o bloqueio; **nenhum dos seis arquivos técnicos integra este checkpoint**. Os arquivos estão em área de preparação local da conversa, não constituem artefatos canônicos persistidos no GitHub, e sua disponibilidade futura não é garantida sem publicação ou transferência explícita. Este documento não constitui prova de implementação funcional, aceitação estática, execução, testes, dados ou acesso ao banco.

O Freshness Gate do CP243 confirmou `main` HEAD `17ee5152a4ba1903b080c2abbcfa731fdea5aeaa`, comparação `identical`, com ponteiro único CP243. Antes desta publicação, `prototypes/d1_t2/` continha somente `a1/` em GitHub, sem diretório `a2/`. Exigir novo Freshness Gate para qualquer escrita posterior.

## 2. Histórico delimitado: atividades pós-CP243

| Atividade | Trabalho reportado | Evidência e limite |
|---|---|---|
| A1 | Preparação estática de `errors.py` e `codec.py`; fingerprint T1 e JSONB com import Psycopg diferido | Não publicado ou executado |
| A2 | Rascunho estático de `repository.py`, UoW, transação, leitura e commit explícito | Não publicado; hipóteses ainda não validadas |
| A3 | Rascunho de `bridge.py` com cinco comandos, idempotência e replay/snapshot | Não publicado; sem prova diferencial |
| A4 | Revisão adversarial e preparação de `__init__.py` e `README.md`; achados SA-01–SA-09 | Publicação técnica bloqueada por achados |
| A5 | Ajustes estáticos em `repository.py` e `README.md` para SA-01, SA-02, SA-03, SA-04, SA-09 | Mitigações parciais sem execução |
| A6 | Segunda revisão adversarial, `README.md` atualizado, SA-02 reaberto e SA-10 adicionado | **Bloqueio de publicação mantido** |

Não foi executado ou importado o código do adaptador, instalado Psycopg, executado teste, CI, SQL, conexão Neon, consulta transacional de aplicação, fixture, migration, DDL/DML, grant, alteração de segredo, custo ou deploy. A A7 publica **apenas** o registro documental desta situação.

## 3. Inventário do código de preparação: não é código canônico do GitHub

Os seis arquivos estão em área local `/mnt/data/oes_cp243_staging/prototypes/d1_t2/a2/` **no ambiente desta conversa**; esses caminhos não são links permanentes de recuperação do projeto. Inventário textual e checksums SHA-256 observados sem import ou execução dos módulos:

| Arquivo | SHA-256 da cópia de preparação |
|---|---|
| `__init__.py` | `ad38331d4c7cad003386219a74d5eb3c6492b8d716b0bc52e77c53e8c6fd74cc` |
| `errors.py` | `180d4d9a4f15646f5ebe9fdbb467195449427dcd90726cf27b667bf6fe5c8359` |
| `codec.py` | `f22c181f7775d4bdc67841a37815e7917ba332b5cc2e38616b4c64ce797cef11` |
| `repository.py` | `a5af3545df94ad0c6657b398728aafe5e1779cac535eba2dd3786ebdda015e52` |
| `bridge.py` | `ab292dc11415ead097090080b7f83632a96f39ed21b533cdb37ea13489270242` |
| `README.md` | `238c357e3ee707a6074ad31af8f205b660b4cdbc0686ed8f1801a8addd21067a` |

Os hashes identificam **cópias de preparação**, não blobs Git ou verificação de qualidade. A revisão de A6 está descrita no README local e consolidada abaixo. A inexistência do código no GitHub impede afirmar qualquer aceite de publicação técnica.

## 4. Revisão adversarial — SA-01–SA-10

| Achado | Estado documental pós-A6 | Risco/condição |
|---|---|---|
| SA-01 — rollback após commit confirmado | Mitigação estrutural observada | Fechamento e visibilidade de falha de cleanup ainda não comprovados |
| **SA-02 — rollback não confirmado com retry** | **REABERTO; BLOQUEADOR CRÍTICO** | `bridge.py` pode repetir criação por `23505` mesmo se `repository.py` não comprovar rollback |
| SA-03 — integridade de recibos | Mitigação parcial | Contagem, sequência e igualdade estrutural não provam associação semântica |
| SA-04 — ausência de cenário e filhos | Mitigação estática observada em leitura independente | Criação concorrente pode tornar filhos visíveis sob `READ COMMITTED`; não usar ausência inicial como prova de corrupção |
| SA-05 — fábrica/conexão | PENDENTE / ALTA | Não estão comprovados nova conexão, sessão limpa, não compartilhamento, banco, role, TLS, timeouts |
| SA-06 — commit indeterminado | PENDENTE / ALTA | Evidência insuficiente para diferenciar `OUTCOME_UNKNOWN` de aborto confirmado; fechamento pós-commit sem observabilidade completa |
| SA-07 — JSONB | PENDENTE / MODERADA | Precisão, intervalo e round-trip numérico não demonstrados |
| SA-08 — replay e recibos | PENDENTE / ALTA | Replay T1 compara eventos/estado, mas schema não associa semanticamente recibos individuais a eventos |
| SA-09 — rollback duplicado em leitura | Mitigação estrutural observada | Depende de prova futura do comportamento real de conexão |
| SA-10 — SQLSTATE contextual | NOVO / MODERADA | Mapeamento incompleto de falhas além da colisão específica |

**Mecanismo exato de SA-02:** um `INSERT` pode lançar `SQLSTATE 23505`; o rollback de limpeza também pode falhar; `repository.py` conserva a exceção SQL primária e anota falha secundária, mas `bridge.py` examina apenas SQLSTATE/constraint para iniciar outra tentativa, **sem condição de rollback confirmado**. Isso viola a exigência expressa dos Documentos 216–218. A preservação do SQLSTATE **não é** prova de transação encerrada. Ação futura prioritária: tornar estado de rollback explicitamente acessível à ponte ou emitir falha de infraestrutura que bloqueie inequivocamente a repetição; preservar contexto do erro sem tentativa automática se resultado/limpeza permanecer incerto.

SA-05, SA-06, SA-07, SA-08 e SA-10 exigem delimitação de contrato, inspeção estática e, quando cabível, validação **somente depois de autorização independente**. Não fazer novas tabelas, colunas, GRANTs ou consultas Neon por conveniência. Não alegar que todas as invariantes de integridade são demonstráveis a partir do schema atual.

## 5. Decisão de publicação: fronteiras separadas

**APROVADO PELO PROPRIETÁRIO:** preparar, revisar estaticamente e eventualmente publicar os seis arquivos técnicos, nos limites do Documento 218.

**DECISÃO DESTA ATIVIDADE:** publicar **somente** Documento 219, handoff CP244, ponteiro, STATE e CHANGELOG. A aprovação de código permanece vigente, mas o código em staging **não será publicado nesta etapa** devido a SA-02 e riscos residuais. A constatação de código preparado não atribui `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED` nem `A2-G4_COMPLETED`.

**PROIBIDO:** rodar, importar operacionalmente ou compilar adaptador, instalar dependências, testes T1/T2-A1/T2-A2, CI, SQL, Neon, DDL/DML, alterar grant/role, fixtures, dados reais, `oes-sandbox`, APIs, deploy, custos, descarte, promoção científica/operacional. Psycopg `3.3.6`, distribuição `psycopg`, continua sendo **apenas referência estática de API**. `oes_t2a2_runtime` proibido e `oes_t2a2_owner` não é runtime.

## 6. Controles históricos preservados

T1 `CLOSED_SYNTHETIC_LOCAL_ONLY`, 36 testes históricos PASS; T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`, 75 testes acumulados históricos PASS (39 A1 + 36 T1). Nenhum desses testes foi reexecutado em A1–A7. A2-G2/E `COMPLETED_STRUCTURAL_ONLY`; A2-G3 `COMPLETED_MINIMAL_GRANTS_VERIFIED`. **A2-G4 código estático aprovado, porém bloqueado para publicação técnica; A2-G5 e T2-A2 operacional NOT_AUTHORIZED**. F01–F07 permanecem somente documentalmente endereçados, L1–L4 condicionantes, O-01–O-10 não executados, 36 migrações `UNREVIEWED`; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. Prioridade D0 fechado → D1 sintético → D2 factual diferido → governança operacional posteriormente.

## 7. Ponto exato de retomada

**A1 pós-CP244, somente após novo `Prossiga`:** corrigir **estaticamente** SA-02 no código em preparação (interface de resultado de rollback e bloqueio de retry); revisar efeitos nos caminhos de conflito, fechamento e commit incerto; não executar/importar/testar código e não publicar código técnico automaticamente. Se as cópias locais não estiverem disponíveis na nova sessão, reconhecer a limitação e exigir recuperação controlada; nunca apresentar o documento como substituto dos arquivos-fonte ausentes.

Depois, priorizar SA-05–SA-08 e SA-10, nova revisão adversarial e deliberação sobre eventual publicação técnica. Protocolo CP194: um `Prossiga` = uma atividade; checkpoint conforme relevância/risco; Freshness Gate no início e antes de commit; progresso e STOP.

**STOP — CP244 documental exclusivamente, sem publicação do adaptador.**
