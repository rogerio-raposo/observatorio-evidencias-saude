# Documento 221 — D1/T2-A2: continuidade da revisão estática A2-G4, SA-11/SA-12 e SA-06 (CP246)

**OES | 2026-10-22 | DOCUMENTARY_CHECKPOINT_STATIC_SOURCE_UNPUBLISHED_RESIDUAL_RISKS | A2-G5/T2-A2_RUNTIME_NOT_AUTHORIZED**

## 1. Finalidade, autoridade e limite da evidência

Este documento consolida as atividades A1–A6 pós-CP245, seguidas por A7 exclusivamente documental: não encerra, aceita, executa nem publica o adaptador técnico PostgreSQL. A autorização específica A2-G4 continua sendo a do Documento 218/CP243: `APPROVED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`. Os Documentos 216/217 definem condições de contrato e aprovação, o Documento 219 registra CP244, e o Documento 220 registra CP245 e SA-11 inicialmente bloqueador.

**Declaração de evidência:** todas as alterações e revisões A1–A6 referem-se a **código-fonte em staging local**, sem execução/import/compilação do adaptador, sem testes, SQL, CI, conexão Neon ou verificações de semântica PostgreSQL. Uma mitigação “textual/estática” significa somente que caminhos concretos foram encontrados por inspeção do texto; **não é teste PASS, evidência de eficácia em runtime, conclusão A2-G4 nem autorização A2-G5**. O GitHub `main` continua sem `prototypes/d1_t2/a2/`; T1 e T2-A1 não foram modificados nesta sequência.

Freshness Gate antes da preparação: HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, ponteiro CP245, comparação `identical`. Novo Freshness Gate obrigatório imediatamente antes de qualquer atualização `main`; diff deste checkpoint restrito a cinco arquivos de documentação e continuidade.

## 2. Atividades A1–A6 pós-CP245

| Atividade | Intervenção no staging | Parecer limitado |
|---|---|---|
| **A1** | Correção SA-11 em `repository.py`, `errors.py` e README: exceção `RollbackNotConfirmed` tipada também para rollback falho durante `__exit__` anterior ao COMMIT | Candidata; não testada |
| **A2** | Revisão adversarial SA-11; somente README | Mitigação textual observada; **SA-12 novo**: fechamento falho após rollback retornado pode permanecer somente anotado |
| **A3** | Correção estática SA-12 em `errors.py`, `repository.py` e README: `ConnectionCloseNotConfirmed`, preservação das causas e extensão a leituras independentes | Candidata; não testada |
| **A4** | Revisão adversarial SA-12; somente README | Mitigação textual observada; observabilidade residual SA-06 no caminho de COMMIT incerto |
| **A5** | Refinamento SA-06 em `errors.py`, `repository.py` e README: `CommitOutcomeUnknown` recebe `close_error`, `close_observation_error`, `connection_closed_observed` após saída do contexto | Candidata; classificação de COMMIT incerto mantida |
| **A6** | Revisão adversarial independente de SA-06; somente README | Diagnósticos estáticos coerentes para o caminho canônico; SA-06 **ainda aberta** pela cobertura, classificação e reconciliação |

A atividade **A7** é apenas a publicação documental deste Documento 221, do handoff CP246, do ponteiro, STATE e CHANGELOG. Nenhum arquivo do pacote A2 integra o commit.

## 3. Inventário da cópia de preparação (SHA-256, não canônico)

Local de observação nesta conversa: `/mnt/data/oes_cp243_staging/prototypes/d1_t2/a2/`. Foram constatados exatamente os seis nomes abaixo e calculados hashes sobre o **conteúdo dos arquivos**, sem interpretar ou executar seus módulos. Esta área não tem garantias de disponibilidade durável ou acesso em outra conversa.

| Arquivo | SHA-256 (staging local, pré-CP246) |
|---|---|
| `README.md` | `301a6ae5d0396bac0b5ed5324e92a5a4338854432a9c6a9fb424ad091e5c5c70` |
| `__init__.py` | `ad38331d4c7cad003386219a74d5eb3c6492b8d716b0bc52e77c53e8c6fd74cc` |
| `bridge.py` | `b8288630ff75d8b62a81ca9b230aa214f4d1ba7ba97964cfa6986d8dcb748e70` |
| `codec.py` | `f22c181f7775d4bdc67841a37815e7917ba332b5cc2e38616b4c64ce797cef11` |
| `errors.py` | `c6e13bc031544ea632173b8171a7cd017c83d349f28eda6c3376b3912653bfae` |
| `repository.py` | `bc58d3fc735d1149616c1fba8ee7922eb8bf4a017d1e5ab65c5f47ad751b3b33` |

**Atenção:** hashes de cópias locais não são hashes de objetos Git do adaptador, nem certificam qualidade, tipagem, semântica de PostgreSQL ou aprovação. Na retomada, conferir existência e integridade; se ausentes/divergentes, não reconstruir resultados fictícios nem tratar este documento como substituto dos arquivos.

## 4. Situação adversarial consolidada: SA-01–SA-12

| Identificador | Situação pós-CP245 | Limite de inferência |
|---|---|---|
| SA-01 | Mitigação estrutural anteriormente observada | Sem prova operacional de ciclo de vida |
| SA-02 | Mitigação textual revisada | Retry `23505` continua dependente de fábrica exclusiva/limpeza comprovada (SA-05) |
| SA-03 | **Parcial** | Pareamento recibo–comando–evento não é integralmente demonstrável |
| SA-04 | Mitigação estrutural anteriormente observada | Concurrency/visibilidade ainda não testadas |
| **SA-05 (ALTA)** | **ABERTA** | Propriedade exclusiva, conexão nova, papel, banco, TLS e configuração operacional não são comprováveis por checagens passivas isoladas |
| **SA-06 (ALTA)** | **ABERTA; mitigação parcial adicional** | `CommitConfirmedCleanupFailed` comunica fechamento falho após COMMIT retornado; `CommitOutcomeUnknown` ganha diagnósticos de close na saída normal de `with`. Não resolve resultado no servidor, reconciliação ou classificação de aborto conhecido. Fora do fluxo canônico de contexto, atributos podem ficar `None` |
| **SA-07 (MODERADA)** | **ABERTA** | Faixa, precisão e round-trip numérico JSONB não demonstrados |
| **SA-08 (ALTA)** | **ABERTA** | Replay/eventos e correspondência semântica dos recibos não integralmente demonstrados |
| SA-09 | Mitigação estrutural anteriormente observada | Sem execução ou comparação diferencial |
| **SA-10 (MODERADA)** | **ABERTA** | SQLSTATE contextual e mapeamento de erros ainda delimitados parcialmente |
| SA-11 | Mitigação textual, **revisada** | Rollback falho pré-COMMIT em `__exit__` passa a ser tipado; não é rollback certificado no servidor |
| SA-12 | Mitigação textual, **revisada** | Falha de close após rollback que retornou normalmente passa a ter tipo distinto; não comprova propriedade da conexão |

**Sem novo PASS:** nenhuma revisão estática atesta funcionamento real, isolamento efetivo, durabilidade, idempotência sob corrida, fidelidade JSONB ou autoriza A2-G5. SA-05, SA-06, SA-07, SA-08, SA-10 e SA-03 parcial continuam impedindo declaração de fonte aceita. Mensagens públicas das novas exceções são constantes, mas `__cause__` e atributos internos podem conter dados brutos do driver: vedar logs e serialização sem redação adequada.

## 5. Decisão de publicação e limites não negociáveis

**Publicar somente cinco arquivos documentais deste CP246.** Os seis arquivos técnicos continuam fora do GitHub e não são `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`. Não interpretar a existência de staging como preservação operacional. Psycopg `3.3.6` é somente referência **estática de API**: nenhuma instalação, import/compilação, execução, conexão, CI ou teste foi autorizada. Não alterar T1/T2-A1, grants, papel ou banco, migrations, schema, `oes-sandbox`, API ou serviços pagos. Para ambiente futuro, papel de app pretendido `oes_t2a2_app`; `oes_t2a2_owner` não é role runtime; `oes_t2a2_runtime` não deve ser usado.

Preservar T1 **36 testes PASS históricos** e T2-A1 **75 PASS históricos** (incluindo os 36 T1), sem alegar rerun. A2-G2/E somente estrutural, A2-G3 concessões mínimas previamente verificadas; A2-G5 e operação T2-A2 `NOT_AUTHORIZED`; F01–F07 documentais, L1–L4 e O-01–O-10 pendentes, 36 migrations `UNREVIEWED`; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. Prioridade D0 encerrado → D1 sintético → D2 factual diferido → governança operacional posteriormente.

## 6. Retomada precisa

**A1 pós-CP246 (somente após novo `Prossiga`):** realizar uma atividade de **triagem adversarial estática do bloqueio SA-05**, separando (a) obrigações atestáveis textualmente pela API/fábrica, (b) garantias que dependem de execução/infraestrutura ainda não autorizada, e (c) possíveis salvaguardas de código nos seis arquivos já aprovados. Não acessar conexão, Neon ou ambiente, nem instalar driver; não prometer fechar SA-05 só com inspeção. Se surgirem correções, tratar como atividade seguinte e submeter a nova revisão. Prosseguir depois com SA-07, SA-08, SA-10 e SA-06 sem ampliar schema ou gates implicitamente. Se staging não estiver disponível, reportar bloqueio em vez de inventar arquivos.

Protocolo CP194: cada `Prossiga` autoriza uma atividade delimitada; checkpoints normalmente em 3–5 atividades, antecipados por risco; Freshness Gate inicial/pré-commit e mensagens de progresso; STOP ao final.

**STOP — CP246 exclusivamente documental.**
