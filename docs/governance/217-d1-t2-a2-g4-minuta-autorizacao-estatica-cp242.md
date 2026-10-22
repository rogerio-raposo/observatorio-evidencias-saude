# Documento 217 — D1/T2-A2: minuta revisada de autorização estática A2-G4 (CP242)

**OES | 2026-10-22 | AUTHORIZATION_PROPOSAL_DOCUMENTARY_ONLY | A2-G4/G5 E T2-A2 NOT_AUTHORIZED**

## 1. Natureza, proveniência e efeito da publicação

Este documento consolida **apenas documentalmente** quatro atividades A1–A4 pós-CP241: proposta preliminar de autorização A2-G4, revisão adversarial **AA-01–AA-09**, minuta revisada, avaliação final de suficiência **AF-01–AF-05**. A fonte técnica é o **Documento 216/CP241**, acrescido dos Docs 197, 205–207, 211–215 e do código T1/T2-A1 do GitHub.

**Parecer:** `SUFFICIENT_FOR_DOCUMENTARY_PERSISTENCE_WITH_CONDITIONS`. **Publicar a minuta não significa aprová-la.** O rótulo `PROPOSED_NOT_APPROVED` é obrigatório para qualquer reprodução ou resumo desta proposta. A2-G4 (implementação), A2-G5 (testes), implementação T2-A2 e promoção de fases **permanecem NOT_AUTHORIZED**. Não converter hipótese, design, aceite estático ou inspeção documental em validação de runtime.

O protocolo CP194 continua: cada `Prossiga` permite uma única atividade interna; checkpoints normalmente a cada três a cinco atividades; Freshness Gate no começo e antes do commit; STOP ao registrar checkpoint. Para executar qualquer implementação, exigir decisão expressa autônoma e um `Prossiga` subsequente conforme o escopo aprovado.

## 2. Objetivo da autorização FUTURA — estritamente código-fonte

**Minuta candidata:** `OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY`.

Se especificamente aprovada, permitir apenas **escrever, revisar estaticamente e publicar** um pacote Python experimental PostgreSQL para os cinco comandos sintéticos `create_scenario`, `start_cycle`, `register_signal`, `record_assessment` e `close_cycle`. O código conterá instruções SQL parametrizadas, **não executadas**. A intenção é materializar para revisão o contrato documental do Documento 216, não comprovar funcionamento, conectividade, isolamento efetivo, idempotência persistente ou segurança operacional.

**Não autorizar implicitamente:** importar operacionalmente módulos, executar/compilar código, instalar driver/dependências, testes locais ou remotos, transações SQL, conectar Neon, criar dados, rodar CI, atualizar infraestrutura, modificar schema/roles/grants, despesas, deploy, APIs ou dados reais.

## 3. Lista fechada de arquivos técnicos

Único diretório candidato: `prototypes/d1_t2/a2/`, ainda inexistente no Freshness Gate CP241.

| Arquivo técnico | Responsabilidade exclusiva |
|---|---|
| `__init__.py` | Marca do pacote, sem conexão nem efeitos ao import |
| `repository.py` | Repositório PostgreSQL, Unit of Work e SQL parametrizada |
| `bridge.py` | Orquestração experimental dos cinco comandos e leituras coerentes |
| `errors.py` | Erros exclusivos de infraestrutura e confirmação incerta |
| `codec.py` | Conversão Python/JSONB e fingerprint histórico |
| `README.md` | Dependências, limites, hipóteses, contrato e critérios de aceite estático |

A autorização de **implementação** não inclui outros arquivos nem modificações em `prototypes/d1/` ou `prototypes/d1_t2/a1/`. Não criar `requirements.txt`, `pyproject.toml`, lockfiles, Dockerfile, workflow, API, fixtures, migrations, testes, config cloud, DSNs ou scripts operacionais sem novo ato.

**AF-02:** arquivos estritamente documentais de governança (novo documento de decisão/handoff, ponteiro, STATE e CHANGELOG) formam fronteira separada e poderão integrar um checkpoint de publicação **quando expressamente autorizado**; não expandem os seis arquivos técnicos nem dispensam Freshness Gate.

## 4. Identidade canônica do domínio e exceções (AA-01 / AF-01)

A única fonte canônica de domínio candidato será `prototypes.d1.monitor`, a partir da raiz normal de importação do repositório, sem copiar `monitor.py`, sem usar a cópia `a1/t1_monitor_reference.py` como novo runtime, sem `sys.path` dinâmico, sem duplicação de módulos e sem reimplementação de regras científicas sintéticas.

A ponte T2-A1 histórica importa `t1_monitor_reference` e `repository` como módulos locais, ao passo que o novo pacote candidato importará módulos por caminhos de pacote. **Classes Python carregadas a partir de nomes de módulo diferentes não têm identidade garantida**, ainda que o conteúdo seja byte a byte idêntico. Portanto, preservar **a semântica observável e o mapeamento explícito das exceções**, não prometer identidade absoluta entre processos ou contextos de importação distintos. A origem canônica e o contrato de importação de `RepositoryConflict` (definido em T2-A1) deverão ser especificados para que o novo pacote não crie acidentalmente uma segunda classe com mesmo nome; o núcleo T1 e os legados permanecerão inalterados.

Diferença intencional do histórico: determinadas reutilizações inválidas de request geram `RepositoryConflict` na ponte T2-A1, mas `DomainError` no T1 direto. Esse contraste deve continuar explicitamente reconhecido e validado futuramente.

## 5. Dependências Psycopg 3 (AA-04 / AF-03)

Biblioteca candidata única: **Psycopg 3**, com APIs documentadas e adaptação JSONB explícita. Não autorizar instalação nem atualização de dependências nesta proposta estática.

**Condição prévia obrigatória à autorização técnica:** o ato decisório deve escolher, de forma explícita, (a) uma versão/distribuição de referência de Psycopg suficientemente determinada para orientar o código, **ou** (b) uma exceção formal e restrita que permita escrever apenas contra a API major 3, deixando versão/distribuição exatas como impedimento à execução futura. **Não escolher versão arbitrária nem inferir que a execução esteja autorizada.** A biblioteca binária/compilada, libpq, conexões e TLS permanecem dependências ambientais não verificadas pela escrita de arquivos.

Imports de dependências deverão ser inertes e, quando apropriado, diferidos. Importar o pacote ou construir objetos **não poderá estabelecer conexão**, iniciar SQL, ler segredos, instalar pacotes ou acionar efeitos externos. A simples presença de referências de API não atesta que elas funcionem.

## 6. Repository/Unit of Work, concorrência e commit explícito (AA-02, AA-07)

Preservar API de cinco comandos do Documento 216. A UoW experimental deverá aceitar cenário/request/fingerprint, proteger leitura de estado/evento/recibo na mesma transação/conexão, preparar estado + um evento + um recibo e confirmar atomicamente.

Para cenário existente: hipótese `READ COMMITTED` com bloqueio transacional do cenário **antes** das leituras dependentes e verificação de revisão; essa coerência pressupõe o mesmo protocolo para todos os escritores. Para criação inexistente: unicidade de cenário, colisão reconhecida pela constraint e contexto, rollback da tentativa, **nova** transação e rechecagem de recibo/identidade. Não pressupor bloqueio de linha inexistente por `SELECT FOR UPDATE`. Para snapshot/replay independente: candidato `REPEATABLE READ READ ONLY`. Esses níveis não são comprovados neste documento.

**Commit explicitamente solicitado:** sair normalmente de `with` sem chamada explícita de `uow.commit()` deverá reverter qualquer trabalho preparado. O contexto Psycopg não poderá realizar confirmação implícita das alterações da UoW. `commit` exige cenário/evento/recibo completos; não admitir commit duplo, reentrada incompatível ou uso após encerramento. Falhas/cancelamentos conhecidos fecham ou revertem conforme o estado; desconexão durante confirmação é tratada como resultado potencialmente incerto.

Em particular, `a1/bridge.py` chama `repo.list_events` fora da UoW, embora o `RLock` intraprocesso o proteja historicamente. **Não transportar esse padrão** para PostgreSQL; colocar a leitura dentro da fronteira transacional experimental.

## 7. Semântica idempotente, revisão e JSONB (AA-05)

Cada comando novo bem-sucedido prepara **exatamente** um cenário criado/atualizado, um evento novo, um recibo persistente, uma revisão incrementada em 1. A criação inicia em revisão/sequência 1. Para cenário íntegro, revisão = quantidade de eventos = quantidade de recibos de comandos novos. Uma repetição idempotente não modifica nenhum deles. Essas invariantes não decorrem integralmente das restrições físicas já criadas.

Fingerprint: **SHA-256 sobre `encoded(payload).encode("utf-8")` do Python histórico**, calculado antes de adaptação JSONB; não recalcular sobre representação JSONB. Distinguir `NULL` SQL de `null` JSON e adaptar explicitamente `scenario.state`, `event.payload`, `receipt.response`.

- Repetição de `create_scenario`, mesmo request e payload: retornar **snapshot corrente**, obtido sob visão protegida.
- Repetição de outros comandos: retornar resposta original armazenada.
- Mesmo request com fingerprint divergente: erro histórico apropriado, sem efeito.
- Criação de cenário já existente com outro request: `DomainError`.
- Não alterar baseline/conclusão científica sintéticos, impossibilidade de reavaliar sinal já avaliado, estados distintos de projeção ou regras de ciclos.

**Limite RF-02 preservado:** `Receipt.response: Any` do repositório genérico T2-A1 **não equivale** a suporte ilimitado a objetos Python arbitrários pelo JSONB. Contrato de compatibilidade restrito às respostas e valores dos cinco comandos sintéticos; valores não representáveis devem falhar explicitamente antes do commit, sem coerção silenciosa. Somente futura prova diferencial estabelece alcance real.

## 8. Erro de commit indeterminado (AA-03 / AF-04)

**Representação candidata estática:** `CommitOutcomeUnknown(RuntimeError)` em `errors.py`, exclusivamente infraestrutura. A classe não deve implicar confirmação nem rollback, não deve executar reconciliação em construtor e não deve sobrescrever `DomainError` ou `RepositoryConflict`. Contexto mínimo pode identificar cenário/request sem DSN, senha, token, credencial ou dados clínicos.

Distinguir etapas **transação ativa → alterações preparadas → commit iniciado → confirmação conhecida ou desconhecida**. Nem toda exceção de conexão é automaticamente resultado incerto: avaliar estágio e evidência. Se desconectar durante COMMIT, manter `OUTCOME_UNKNOWN` até reconciliação apropriada, sem retry cego. A consulta futura de recibo por cenário/request/fingerprint só demonstra confirmação quando **integridade e invariantes relevantes** também forem verificadas. Ausência imediata de recibo não demonstra rollback.

A implementação poderá expressar estaticamente o protocolo, mas não provar reconciliação ou durabilidade sem execução e testes autonomamente autorizados.

## 9. SQLSTATE, retries e ciclo de vida (AA-08)

Classificar erros PostgreSQL por SQLSTATE **e contexto**: `23505` sob constraint específica, `40001` falha de serialização, `40P01` deadlock, `55P03` lock não disponível, `57014` cancelamento, classe `08` conectividade, `25P02` transação abortada e `42501` privilégio insuficiente. Não converter erro SQL genérico em `RepositoryConflict` nem em `DomainError`.

**Nenhum retry automático habilitado por padrão.** Retries de transação completa somente se aborto conhecido e política futura expressamente autorizada, com limites e backoff. Timeouts, quantidade máxima e distribuição/versão do driver requerem decisão específica antes de execução. Não inventar valores de produção nem tomar os 5s/1s dos preflights como padrão operacional.

## 10. Segurança, ambiente e segregação de gates

Neon Free sintético candidato: `oes-d1-t2-a2-synthetic`, branch `synthetic-main`, banco `oes_t2a2_synthetic`, schema `oes_t2a2_proto`, tabelas `scenario`, `event`, `receipt`. Nenhuma interação com Neon é autorizada por este documento. O único papel candidato de aplicação é `oes_t2a2_app`; `oes_t2a2_runtime` proibido; `oes_t2a2_owner` não pode servir como runtime. CP240 documenta SELECT/INSERT nas três tabelas e UPDATE limitado a `scenario.revision`/`scenario.state`; sem CREATE/DELETE/TRUNCATE no papel app. Não elevar privilégios por conveniência.

Não armazenar connection strings, segredos ou material pessoal/sensível. Não alterar `oes-sandbox`. Não executar DDL, DML, GRANT/REVOKE, deploy, API, migrations canônicas, busca factual, CI ou fixtures. TLS `verify-full` do cliente Psycopg→endpoint foi observado anteriormente, **sem comprovação de TLS ponta a ponta até o backend nem da configuração do plugin Neon**. Sem serviços pagos, cartões, upgrade ou consumo não proporcional fora de escopo autorizado.

**AF-02:** atos documentais/checkpoints e código são autorizações distintas. **AF-05:** concluir escrita/inspeção estática, se aprovada, poderá gerar somente `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`, nunca `IMPLEMENTED_OPERATIONALLY_VALIDATED`.

## 11. Critérios de aceitação estática (AA-06, AA-09, AF-05)

Exigir inspeção de conteúdo e diff (não execução) que demonstre, no escopo autorizado:
1. Só seis arquivos técnicos foram criados em `prototypes/d1_t2/a2/`;
2. T1/T2-A1 permaneceram inalterados e não se criou novo núcleo T1;
3. Estratégia de import canônico e identidade/mapeamento de exceções estão explicitados sem prometer identidade entre contextos distintos;
4. Imports/construtores não acionam conexão, SQL ou efeitos externos;
5. Commit explícito, rollback em saídas não confirmadas e `CommitOutcomeUnknown` estão representados;
6. Leitura transacional de estado/eventos/recibos, colisões e revisão foram preservadas documentalmente;
7. Semântica histórica de idempotência, fingerprint e respostas está refletida;
8. SQL parametrizada, identificação de schema, JSONB explícito e ausência de segredos foram inspecionados;
9. Dependências e parâmetros não definidos estão rotulados, nunca inventados como validados;
10. Não houve execução de Python do adaptador, testes, imports operacionais, SQL, CI, Neon ou instalação;
11. Publicação, se autorizada, usou Freshness Gate e SHA com diff verificado;
12. Nenhum oráculo O-01–O-10 foi declarado PASS sem execução.

**Status máximo alcançável:** `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`, exclusivamente após execução da etapa de código **sob autorização futura** e publicação verificada. A publicação desta minuta **não** alcança esse estado.

## 12. Rastreabilidade dos achados AA-01–AA-09 / AF-01–AF-05

| Achado | Resposta documental candidata |
|---|---|
| AA-01 | Domínio canônico único, sem cópia, imports controlados (§4) |
| AA-02 | Commit explícito, rollback em saída normal sem commit (§6) |
| AA-03 | `CommitOutcomeUnknown` e limites de reconciliação (§8) |
| AA-04 | Psycopg 3 como dependência de fonte, decisão de versão/distribuição (§5) |
| AA-05 | JSONB explícito, fingerprint Python, tipos limitados (§7) |
| AA-06 | Escrita de código distinta de execução e testes (§2, §10–11) |
| AA-07 | Sem efeitos em imports/construtores (§5–6, §11) |
| AA-08 | SQLSTATE, retries desabilitados por padrão, limites (§9) |
| AA-09 | Aceitação estática verificável e não-PASS (§11) |
| AF-01 | Identidade semântica versus identidade Python entre módulos (§4) |
| AF-02 | Limite técnico de seis arquivos versus registros de governança (§3, §10) |
| AF-03 | Driver/versão ou exceção explícita **antes de aprovação técnica** (§5) |
| AF-04 | Commit incerto condicionado por estágio e invariantes (§8) |
| AF-05 | Status máximo `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED` (§10–11) |

Todos os achados são **endereçados apenas no texto**. RA-01–RA-10, F01–F07, L1–L4, O-01–O-10 e E01–E12 continuam vinculados ao Documento 216 e anteriores, sem alegação de prova operacional.

## 13. Fórmula para eventual decisão independente — NÃO APROVADA

> **PROPOSED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY** — Considerar autorização futura **exclusiva** para criar, revisar estaticamente e publicar, em `prototypes/d1_t2/a2/`, os seis arquivos especificados no Documento 217, preservando bytes dos legados T1/T2-A1, importação e semânticas históricas, commit explícito, resultado incerto distinguível, fingerprint legado, menor privilégio e proibições do Documento 216. A aprovação deve decidir previamente AF-03 (Psycopg versão/distribuição ou exceção estática explicitamente limitada), registrar critérios e exigir novo Freshness Gate antes de execução. **Não autorizar** instalação, import/execução Python, testes, SQL, Neon, CI, fixtures, credenciais, novos grants, DDL, migrations, deploy, custos, descarte, dados reais ou promoção de gates. A2-G5 e demais operações requerem decisões próprias.

**Status desta fórmula:** `PROPOSED_NOT_APPROVED`. `Prossiga` após este checkpoint **não equivale a aprovação da fórmula**; permite somente a próxima atividade documental delimitada.

## 14. Continuidade e STOP

T1 `CLOSED_SYNTHETIC_LOCAL_ONLY`: 36 PASS históricos; T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`: 75 PASS históricos (39 próprios + 36 T1). A2-G2/E `COMPLETED_STRUCTURAL_ONLY`; A2-G3 `COMPLETED_MINIMAL_GRANTS_VERIFIED`; **A2-G4/G5 e T2-A2 NOT_AUTHORIZED**. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`. D0 editorial concluído → D1 sintético prioritário → D2 factual diferido.

**Próximo `Prossiga`:** somente preparação documental da submissão da minuta e fechamento explícito de AF-03 (sem escolher versão por presunção); depois, decisão expressa e separada do proprietário, se desejada. Não implementar por inferência. **STOP.**
