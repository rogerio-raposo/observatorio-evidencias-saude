# OES — D1/T2-A2, A2-G4 — PostgreSQL experimental adapter

**Status:** `STATIC_REMEDIATION_PARTIAL_REVIEW_PENDING_NOT_PERSISTED`  
**Checkpoint de origem:** CP243 (22 de outubro de 2026)  
**Autoridade:** Documento 218, `ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY`, Psycopg `3.3.6` **somente como referência estática de API**.

Este pacote é um **rascunho estático sintético, não executado e não validado**. A autorização A2-G4 cobre apenas a escrita, inspeção e eventual publicação controlada destes seis arquivos. Não autoriza instalação de Psycopg, importação operacional, compilação ou execução de módulos, testes, SQL, acesso Neon, CI, fixtures, alterações de schema/grants, infraestrutura, dados reais, custos ou promoção de gates. A2-G5 e a utilização operacional de T2-A2 permanecem `NOT_AUTHORIZED`.

## Arquivos de código-fonte do pacote — lista técnica fechada

| Arquivo | Responsabilidade candidata |
|---|---|
| `__init__.py` | Delimitação do pacote, sem importações antecipadas ou efeitos colaterais |
| `errors.py` | Erros de infraestrutura, incluindo `CommitOutcomeUnknown` |
| `codec.py` | Fingerprint Python legado e adaptação JSONB com importação diferida do Psycopg |
| `repository.py` | Repositório PostgreSQL, Unit of Work, transações e consultas de snapshot |
| `bridge.py` | Ponte experimental para os cinco comandos e projeções/replay sintéticos |
| `README.md` | Escopo, requisitos, riscos adversariais e limites de evidência |

Nenhum outro arquivo técnico é coberto pelo Documento 218. Não modificar `prototypes/d1/` nem `prototypes/d1_t2/a1/`, e não duplicar o núcleo `prototypes.d1.monitor`. Os arquivos de governança são uma fronteira documental distinta.

## Contratos preservados no desenho

- Cinco comandos: `create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`.
- Origem canônica T1: `prototypes.d1.monitor`; origem de estruturas e conflitos A1: `prototypes.d1_t2.a1.repository`; **identidade de classes entre módulos importados sob nomes diferentes não é presumida**.
- SHA-256 sobre `encoded(payload).encode("utf-8")` do T1; não sobre serialização JSONB do banco.
- Repetição de criação com mesmo request/payload deve devolver **snapshot corrente**; outras repetições devolvem resposta original; divergência de fingerprint deve falhar sem efeitos.
- Estado, evento e recibo por comando novo devem ser atômicos, com revisão/sequência contínuas. Escritores de cenários existentes devem adquirir bloqueio antes das leituras dependentes; ausência inicial usa unicidade, rollback da colisão e nova transação.
- Somente confirmação **explícita** pode efetivar escritas; sair da Unit of Work sem commit deve reverter. Não realizar retry automático, especialmente após COMMIT incerto.
- Leituras de snapshot/replay candidatas usam `REPEATABLE READ READ ONLY`. Compatibilidade JSONB limitada aos cinco comandos, não a todo `Any` Python.
- Apenas `oes_t2a2_app` poderá ser considerado para **execução futura separadamente aprovada**; não usar `oes_t2a2_runtime` ou `oes_t2a2_owner` como runtime. Sem acesso a `oes-sandbox`.

Estes são **requisitos e intenção do código**, não garantias demonstradas.

## Revisão adversarial estática A4 pós-CP243 — bloqueios e limitações

Os achados a seguir foram identificados por **leitura estática**, sem executar código, instalar drivers, importar o pacote ou tocar o banco. Nenhum teste foi realizado. Sua correção e uma segunda revisão são necessárias antes de declarar o pacote estaticamente aceitável para publicação como implementação revisada.

| Identificador | Gravidade | Achado e ação obrigatória |
|---|---|---|
| `SA-01` | **CRÍTICA** | `PostgresUnitOfWork.__exit__()` tenta `rollback()` mesmo após `commit()` confirmado. Falhas de rollback/fechamento podem mascarar o resultado já confirmado. Rastrear explicitamente estado de commit e separar liberação de conexão de reversão de uma transação ainda ativa, preservando resultado conhecido. |
| `SA-02` | **ALTA** | Após erro anterior ao commit, falha na chamada de `rollback()` dentro de `commit()` ou `__exit__()` pode substituir a exceção original, incluindo SQLSTATE/constraint `scenario_pkey` usado para resolver criação concorrente. Preservar causa principal e relatar falha secundária de limpeza sem transformar resultado em sucesso. |
| `SA-03` | **ALTA** | Na escrita, a ponte compara a revisão e a lista de eventos, mas não valida integralmente os recibos/revisões já persistidos antes de confirmar comando novo ou devolver repetição. Integrar verificações de integridade equivalentes ao alcance declarado, sem criar novos direitos. |
| `SA-04` | **MODERADA** | `read_consistent_snapshot()` não carrega eventos/recibos se `scenario` estiver ausente, de modo que `_validate_loaded` não observaria órfãos mesmo quando fosse relevante detectar corrupção. Ajustar o contrato da ausência; PK/FK documentadas são defesa estrutural, não prova independente de todas as invariantes. |
| `SA-05` | **ALTA** | A fábrica de conexões é injetada, mas o código não demonstra, por si só, conexão nova/limpa, identidade de role/banco, TLS ou não compartilhamento entre transações. Definir pré-condições verificáveis e deixar enforcement operacional para gates futuros; nunca alegar menor privilégio efetivo no código estático. |
| `SA-06` | **MODERADA** | Qualquer erro em `conn.commit()` vira `CommitOutcomeUnknown`, mesmo quando um driver futuro possa oferecer prova conclusiva de aborto. A classificação deve depender de estágio/evidência sem assumir rollback em falhas de rede. |
| `SA-07` | **MODERADA** | `jsonb_value()` normaliza por serialização JSON genérica, mas não estabelece equivalência irrestrita de chaves, precisão/range numérico ou round-trip JSONB PostgreSQL; rever coerções e explicitar o subconjunto realmente aceito. |
| `SA-08` | **ALTA** | O replay T1 reconstrói os eventos do estado e os compara ao snapshot, enquanto `_validate_loaded` só verifica cardinalidade, sequência/revisão e igualdade dos eventos; isso não comprova associação semântica entre cada recibo e o respectivo comando/evento. Distinguir verificações implementáveis da prova futura O-05/O-09; jamais relatar replay durável como comprovado. |
| `SA-09` | **MODERADA** | A leitura consistente efetua `rollback()` no fluxo normal e novamente na limpeza final; exceções de limpeza podem mascarar erro ou leitura anterior. Separar liberação normal, erro de consulta e cleanup. |

**Parecer histórico da A4:** `STOP_BEFORE_STATIC_SOURCE_PUBLICATION_PENDING_REMEDIATION`. Os seis arquivos foram mantidos na área temporária de preparação. A5 aplicou correções estáticas delimitadas, descritas a seguir. Nenhuma dessas mudanças foi importada, executada ou testada.

## Correção estática A5 pós-CP243 — revisão adversarial ainda pendente

| Identificador | Alteração de fonte A5 | Resultado documental, **não testado** |
|---|---|---|
| `SA-01` | Unit of Work registra `PENDING`, `COMMITTED`, `ROLLED_BACK`, `OUTCOME_UNKNOWN` e estados de falha. `__exit__` só solicita rollback quando ainda `PENDING`; ao sair após commit confirmado, apenas fecha a conexão, sem converter resultado conhecido em erro por falha de close. | **Mitigado estaticamente; requer nova revisão.** Falha de close é registrada no objeto como `cleanup_failed`, sem garantia de telemetria futura. |
| `SA-02` | Erro pré-COMMIT preserva sua exceção SQL original mesmo se rollback ou close falhar. Limpeza secundária anota texto genérico sem credenciais, quando a exceção aceita `add_note`. | **Mitigado estaticamente; requer prova posterior.** Diagnósticos SQLSTATE/constraint não devem ser perdidos pela limpeza. |
| `SA-03` | `find_receipt()`, `read_scenario()`, `list_events()` e `commit()` passam por `_ensure_integrity()` para **cenários existentes**; eventos e recibos são carregados sob bloqueio do cenário, e `_validate_loaded()` verifica cardinalidades, revisões, sequência e eventos do estado. Para criação inicialmente ausente, não se fazem leituras independentes de filhos sob `READ COMMITTED`: uma criação concorrente poderia aparecer depois do `SELECT FOR UPDATE` que não encontrou linha, produzindo falso diagnóstico de corrupção. A PK do cenário e a FK dos filhos delimitam a colisão na operação de `INSERT`, seguida de rollback e nova transação na ponte. | **Mitigação estrutural, não semântica completa.** Associação entre fingerprint, request e evento permanece sem oráculo provado (`SA-08`); a corrida de criação ainda não foi testada. |
| `SA-04` | Snapshot de leitura carrega `event` e `receipt` mesmo se não houver linha `scenario`, permitindo a `_validate_loaded()` verificar ausência de registros órfãos na visão read-only. | **Mitigado estaticamente**, sem garantia de detecção de toda corrupção possível. |
| `SA-09` | Leitura independente realiza só uma tentativa de rollback na liberação final; na presença de erro primário, falhas de limpeza são secundárias, sem substituição da causa. | **Mitigado estaticamente; requer revisão.** |

**Pendências não resolvidas integralmente em A5:** `SA-05` (fábrica de conexões, isolamento de sessão, role, TLS, evidência de posse), `SA-06` (diferenciar commit indeterminado de aborto conclusivamente demonstrado), `SA-07` (coerções e precisão do JSONB) e `SA-08` (prova independente de associação semântica de recibos e replay). O contrato do Documento 218 proíbe resolver essas pendências por SQL, importação ou execução nesta etapa.

**Risco residual:** estados de transação e erros de limpeza foram representados na fonte, mas comportamento sob falhas de drivers, conexão fechada e efeitos após COMMIT exige autorização de testes posteriores. A5 **não** torna o pacote apto à publicação sem nova inspeção adversarial estática. Seu estado não é `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`.

## Invariantes e limites de teste

O Documento 216 define RA-01–RA-10, RF-01–RF-05 e os oráculos O-01–O-10. O Documento 217 acrescenta AA-01–AA-09 e AF-01–AF-05. Esta revisão acrescenta **SA-01–SA-09** como achados internos da fonte inicial; nenhum deles significa teste PASS nem substitui os critérios canônicos.

T1 tinha 36 testes PASS históricos; T2-A1 totalizava 75 PASS históricos, incluindo os 36 T1. **Nenhum resultado foi reexecutado aqui**. O máximo estado permitido após implementação, revisão e publicação futuras devidamente autorizadas será `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`.


## Segunda revisão adversarial A6 pós-CP243 — resultado e bloqueios remanescentes

**Escopo e evidência:** somente leitura e inspeção textual dos seis arquivos A2, cotejo com Documento 218 e contratos históricos T1/T2-A1. Nenhum módulo importado, compilado ou executado; nenhuma dependência instalada, teste, SQL, conexão Neon ou CI. O GitHub `main` permaneceu no CP243 (`17ee5152a4ba1903b080c2abbcfa731fdea5aeaa`, comparação `identical`). As referências de linha abaixo são relativas à versão A5 dos arquivos de código; esta A6 altera apenas este README.

| Achado | Avaliação A6 | Criticidade / consequência | Ação requerida |
|---|---|---|---|
| SA-01 | **Mitigação estrutural observada**: `repository.py:120-133` não executa rollback após `COMMITTED` ou `OUTCOME_UNKNOWN`. Falha de fechamento após commit confirmado permanece registrada apenas no objeto da UoW, que pode deixar de ser acessível à ponte. | Risco de observabilidade; não demonstra transação segura. | Preservar resultado conhecido e definir visibilidade do erro de limpeza, sem reclassificar commit. |
| SA-02 | **REABERTO / BLOQUEADOR**: em `repository.py:254-260,285-293`, falha de rollback pré-COMMIT preserva a exceção SQL `23505` e somente registra `cleanup_failed`. Em `bridge.py:78-87`, a lógica de colisão olha apenas SQLSTATE/constraint e realiza nova tentativa, mesmo sem rollback comprovado. | **CRÍTICA**: retry condicionado incorretamente; viola exigência de rollback confirmado antes da nova transação. | Distinguir rollback comprovado de falha de rollback na cadeia de erro/resultado, manter causa SQL original e bloquear absolutamente a repetição quando o rollback não for confirmado. Não usar exceção genérica `23505` como prova de limpeza. |
| SA-03 | **Mitigação estrutural parcial**: `repository.py:140-190,337-353` verifica eventos, recibos e revisões antes de comandos em cenário existente. Associação semântica individual não demonstrada. | ALTA residual. | Limitar garantia a coerência estrutural e tratar SA-08 separadamente. |
| SA-04 | **Mitigação estática observada**: `read_consistent_snapshot()` lê coleções mesmo na ausência de cenário (`repository.py:47-65`). O caminho de criação sem linha não as lê na mesma transação devido à corrida válida sob `READ COMMITTED`. | Limite de prova; a prevenção efetiva de órfãos depende das FKs e da disciplina de escritores. | Conservar essa distinção e validar operacionalmente depois. |
| SA-05 | **PENDENTE / ALTA**: apenas `autocommit=False` é checado (`repository.py:52-54,99-109`). Conexão nova, sem transação prévia, sessão não compartilhada, banco/role app, TLS e timeouts são contratos do chamador não verificados no código. | Precondições essenciais de conexão não comprovadas. | Especificar interface da fábrica e proibir execução até preflight independente; não inferir ambiente seguro a partir de tipo `Callable`. |
| SA-06 | **PENDENTE / ALTA**: qualquer exceção de `conn.commit()` vira `CommitOutcomeUnknown` (`repository.py:261-268`), sem critérios para distinguir aborto conclusivamente provado. Falha de close pós-COMMIT pode ser silenciada no retorno da ponte. | Semântica de resultado e rastreabilidade ainda incompletas, embora classificação conservadora não afirme rollback falso. | Registrar estados/evidência e mapear somente casos realmente demonstráveis sem retry cego; reconciliação continua dependente de gate. |
| SA-07 | **PENDENTE / MODERADA**: `codec.py:40-64` verifica caracteres inválidos e números não finitos, mas `json.loads`/`json.dumps` não provam compatibilidade de precisão, faixa numérica nem equivalência no round-trip JSONB PostgreSQL. | Potencial incompatibilidade de domínio de valores. | Declarar subconjunto aceito e critérios posteriores de comparação; não alegar `Any` universal. |
| SA-08 | **PENDENTE / ALTA**: `bridge.py:152-161` executa replay T1 do log armazenado no estado após comparação com eventos persistidos, mas `_validate_loaded` confirma apenas quantidades, sequências e eventos; não vincula semanticamente cada recibo a payload/método/evento. | Replay de domínio parcial; integridade/idempotência durável não comprovadas. | Preservar limites do schema e exigir oráculos futuros O-03, O-05, O-06, O-09; não afirmar prova impossível sem informação adicional. |
| SA-09 | **Mitigação estática observada**: leitura consistente tem apenas uma limpeza final (`repository.py:47-74`), preservando erro primário. | Ainda sem prova de comportamento do driver. | Manter inspeção e observar em testes futuros somente após nova autorização. |
| SA-10 (novo) | SQLSTATE além da colisão específica não possui classificação contextual explícita; erros de infraestrutura podem chegar como exceções não normalizadas. | MODERADA; lacuna entre código candidato e Documento 216/217. | Delimitar mapeamento sem ocultar SQLSTATE e sem tratar todo erro como `RepositoryConflict` ou `DomainError`. |

**Parecer A6:** `STATIC_SOURCE_PUBLICATION_BLOCKED_ROLLBACK_RETRY_CONTRACT`. A correção A5 reduziu problemas de cleanup e integridade estrutural, mas **SA-02 permanece bloqueador inequívoco**. SA-05/SA-06 e SA-08 continuam condicionantes substanciais. Não declarar `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`, não publicar os seis arquivos como incremento estaticamente aceito e não iniciar A2-G5.

**Próxima atividade recomendada:** checkpoint **exclusivamente documental** de risco e continuidade, depois correção estática explícita de SA-02 e revisão dos demais itens. O checkpoint documental não pode classificar o código de staging como persistido, executado ou testado. Exigir novo `Prossiga` e Freshness Gate. **STOP.**

## A1 pós-CP244 — remediação estritamente estática de SA-02 (não validada)

**Status:** `SA-02_STATIC_REMEDIATION_CANDIDATE_NOT_REVIEWED_NOT_PERSISTED`. Freshness Gate GitHub CP244 confirmado `identical`; os seis arquivos de staging tiveram hashes conferidos contra o Documento 219 antes da edição. Nenhum código Python do adaptador foi importado, compilado, executado ou testado. Nenhuma conexão, SQL, Neon, driver, CI ou alteração GitHub.

**Causa:** a versão A6 preservava o `SQLSTATE 23505` original mesmo quando `conn.rollback()` falhava, e `bridge.py` admitia reavaliação de criação por SQLSTATE/constraint somente, sem saber se a conexão fora encerrada corretamente.

**Correção candidata:**

1. `repository.py`: no erro de escrita pré-COMMIT, `rollback()` bem-sucedido define `ROLLED_BACK_AFTER_WRITE_FAILURE`. Se `rollback()` falha, define `ROLLBACK_UNCONFIRMED`, sinaliza `cleanup_failed=True` e lança `RollbackNotConfirmed` preservando a exceção original como causa, **sem promover sua SQLSTATE à exceção externa**.
2. `errors.py`: `RollbackNotConfirmed(AdapterInfrastructureError)` explicita que nenhuma retentativa é segura após rollback não confirmado.
3. `repository.py`: a propriedade `safe_to_retry_create_collision` só é verdadeira após rollback pré-COMMIT confirmado, saída de contexto e fechamento de conexão sem falha registrada; não é garantia operacional de fechamento do servidor ou segurança do driver.
4. `bridge.py`: além do `SQLSTATE 23505` específico de `scenario_pkey`, exige a propriedade de conclusão transacional antes da única reavaliação permitida. Erro de rollback, erro de close, conflito não específico, tentativa seguinte e commit incerto **não autorizam retry**.

**Limites:** é uma correção textual de contrato, sujeita a nova revisão adversarial e posterior prova operacional autorizada. `SA-02` não é dado como PASS ou resolvido operacionalmente. SA-05, SA-06, SA-07, SA-08 e SA-10 permanecem pendentes, assim como SA-03 parcial e os demais controles. Não publicar o pacote técnico como aceito nesta atividade. Próximo `Prossiga`: inspeção adversarial estática de SA-02 e interações com encerramento/commit incerto, dentro do protocolo CP194.

## A2 pós-CP244 — revisão adversarial estática de SA-02 (somente inspeção textual)

**Status:** `SA-02_SOURCE_GUARD_OBSERVED_CONDITIONED_ON_SA-05_NOT_EXECUTION_VALIDATED`. Freshness Gate `main` CP244 HEAD `4c9ec2df9255cb103b7b4e0e7390b60853f873cf`, comparação `identical`. Esta atividade inspecionou texto-fonte; não importou, compilou, executou ou testou o adaptador, não instalou Psycopg, não executou SQL/Neon/CI e não publicou código no GitHub.

### Evidência textual delimitada (versão de código A1 pós-CP244)

| Caso examinado | Leitura de código | Parecer estático |
|---|---|---|
| Erro de escrita anterior a COMMIT e `rollback()` lança | `repository.py:271-283` define `ROLLBACK_UNCONFIRMED` e lança `RollbackNotConfirmed` (`errors.py:27-32`) com o erro de escrita como causa; `bridge.py:81-91` exige exceção externa `sqlstate=23505`. | Bloqueia reavaliação pela lógica apresentada; resultado operacional não comprovado. |
| Erro de escrita e `rollback()` retorna normalmente | `repository.py:284-285` define `ROLLED_BACK_AFTER_WRITE_FAILURE` e relança o erro original. `__exit__` fecha a conexão (`repository.py:137-150`). | A ponte só pode reavaliar a colisão conhecida após a saída do `with`; exige verificação das demais condições. |
| `close()` lança erro ao encerrar tentativa revertida | `_dispose_connection` registra a falha (`repository.py:321-341`); `__exit__` define `cleanup_failed=True`; `safe_to_retry_create_collision` exige `not cleanup_failed`. | Falha reportada de fechamento impede retry. |
| COMMIT lança exceção | `repository.py:286-295` define `OUTCOME_UNKNOWN` e propaga `CommitOutcomeUnknown`; `bridge.py:85-91` não reconhece essa classe como colisão admissível. | Não há retry cego a partir dessa exceção. Permanecem SA-06 e reconciliação futura. |
| Colisão em outro objeto ou nova tentativa | `bridge.py:85-90` exige `method=create_scenario`, primeira tentativa, `sqlstate=23505` e constraint `scenario_pkey`, além da condição da UoW. | Não se observou retry genérico, mas a denominação da constraint precisa ser comprovada no gate operacional. |

### Ressalva de aceite: fecho da conexão não comprovado por propriedade

**SA-05 impacta o encerramento de SA-02.** `repository.py:139` define `self._conn=None` **antes** de `_dispose_connection`; logo, a condição `self._conn is None` em `safe_to_retry_create_collision` (`repository.py:99-111`) não demonstra que a conexão Psycopg ficou fechada. O código considera retorno de `conn.close()` sem exceção suficiente, mas não consulta `conn.closed` nem comprova exclusividade/proveniência da conexão fornecida pela fábrica. A API Psycopg 3 documenta o atributo de conexão `closed`, porém isso não prova ausência de compartilhamento nem segurança de rede. **Não declarar “close comprovado” nem SA-02 encerrado integralmente sem explicitar/verificar o contrato de posse e fechamento**. Recomenda-se exigir fábrica de conexão nova e exclusiva e verificação observável de fechamento no limite estrito permitido à implementação estática, antes de novo parecer de aceitação.

**Rastreabilidade residual:** `_rollback_preserving_error()` (`repository.py:310-318`) preserva a exceção da escrita e acrescenta nota genérica quando o rollback falha, porém a exceção concreta de rollback não é associada de forma acessível ao `RollbackNotConfirmed` exterior. Essa perda reduz diagnóstico e exigirá decisão de como preservar ambos os erros sem vazar segredos. Não autoriza retentativa.

**SA-06 continua aberta:** qualquer erro lançado por `conn.commit()` é classificado conservadoramente como resultado incerto, sem evidência de aborto definitivo; falhas de `close()` após COMMIT conhecido são armazenadas no objeto da UoW, mas podem não ser visíveis ao chamador da ponte. Não transformar fechamento posterior em rollback e não presumir confirmação quando houve exceção de COMMIT.

**Parecer A2:** a via crítica originalmente apontada em SA-02 (repetir após falha explícita de rollback) está **mitigada textualmente**. Persistem condicionantes de SA-05/SA-06 e rastreabilidade de erros; nenhuma verificação operacional foi realizada. `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED` **não é atribuível** porque os seis arquivos ainda não foram publicados e permanecem pendências. Próxima atividade delimitada recomendada: reforçar estaticamente o contrato de posse/fechamento de conexão e a rastreabilidade de rollback no mesmo escopo aprovado; depois nova inspeção adversarial. **STOP.**

## A3 pós-CP244 — contrato de posse e fechamento, revisão estática pendente

**Estado:** `CONNECTION_LIFECYCLE_STATIC_REMEDIATION_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`. Freshness Gate CP244 `main` = `4c9ec2df9255cb103b7b4e0e7390b60853f873cf`, `identical`. Alterados textualmente apenas `repository.py`, `errors.py` e este README, sem importar/compilar/executar adaptador, testes, driver, SQL, CI, Neon ou publicação GitHub.

### Condições adicionadas

- `PostgresScenarioRepository` exige **por contrato** `connection_factory` capaz de entregar uma conexão Psycopg 3 **nova, exclusiva, não reutilizada e não proveniente de pool** por operação. Verificação de exclusividade/identidade entre processos **não é tecnicamente demonstrada** pela inspeção passiva e continua como SA-05 para avaliação em gate futuro; não se cria nova conexão ao importar/construir repositório.
- `_require_clean_owned_connection` consulta somente propriedades passivas antes de qualquer SQL do comando: `closed is False`, `autocommit is False`, `info.status.name == "OK"` e `info.transaction_status.name == "IDLE"`. Falta de informação/estado anormal aborta a tentativa. Essas condições **não** demonstram role `oes_t2a2_app`, banco, origem da conexão, TLS, ausência histórica de reutilização nem integridade do servidor. Tais comprovações exigem autorização posterior independente.
- `_dispose_connection` registra separadamente erro de rollback, erro de `close()` e falha de observação de `conn.closed`. Retorno normal de `close()` **sem `closed is True`** não conta como fechamento confirmado. `safe_to_retry_create_collision` não confunde mais `self._conn is None` com prova de fechamento; requer indicador explícito observado **e** ausência de falha em cleanup, além de `ROLLED_BACK_AFTER_WRITE_FAILURE`.
- Em erro de escrita pré-COMMIT seguido de falha de `rollback()`, `RollbackNotConfirmed` expõe ao diagnóstico controlado `rollback_error`, mantém o erro de escrita original em `__cause__` e pode receber `close_error`/`close_observation_error` quando o contexto sair. A mensagem pública não inclui texto de exceções do driver, DSN, segredos ou payload. **Não serializar/logar exceções internas brutas sem política de redação.** Nenhum SQLSTATE original pode autorizar retry nessas condições.
- Falha de cleanup após `COMMITTED` não muda COMMIT confirmado para rollback e continua podendo ficar invisível para o chamador da ponte; SA-06 permanece em aberto. `OUTCOME_UNKNOWN` nunca pode gerar retry cego.

### Estado da revisão

`SA-02`: mitigação textual reforçada, **não PASS**, condicionada à revisão adversarial da A3 e à verificação futura da fábrica; `SA-05`: ainda **PENDENTE / ALTA** pela impossibilidade de prova de exclusividade, role, TLS e proveniência apenas com propriedades de conexão; `SA-06`: **PENDENTE / ALTA** para confirmação incerta e visibilidade do fechamento após commit. `SA-07`, `SA-08`, `SA-10` seguem pendentes. Nenhuma nova tabela, grant, role, fluxo operacional ou dependência foi introduzida. Código permanece apenas em staging, nunca publicado nem testado.

**Próxima atividade recomendada:** revisão adversarial textual das três alterações A3 e de seus efeitos nos caminhos de rollback, retry, pré-condição de conexão e commit incerto; depois considerar checkpoint documental conforme CP194. **STOP.**

## A4 pós-CP244 — revisão adversarial do ciclo de vida e propagação de erros (somente texto)

**Estado:** `CONNECTION_LIFECYCLE_STATIC_REVIEW_WITH_REMAINING_FINDINGS_NOT_PERSISTED`. Freshness Gate CP244 em `main` HEAD `4c9ec2df9255cb103b7b4e0e7390b60853f873cf`, comparação `identical`. Inspeção do texto dos seis arquivos de staging; sem imports, compilação, execução de código Python do adaptador, testes, instalação, SQL, Neon, CI ou publicação técnica. **Esta atividade modifica apenas o README de staging.**

### Matriz adversarial pós-A3

| Cenário/controle | Evidência textual inspecionada | Parecer de revisão |
|---|---|---|
| Pré-condições de conexão | `repository.py:118-141`, `346-366`: fábrica fornecida explicitamente; `closed is False`, `autocommit is False`, `info.status.name == "OK"`, `info.transaction_status.name == "IDLE"`; `_dispose_connection()` no caminho de falha de entrada. | Rejeição de estados visivelmente inadequados presente; **não comprova** identidade de banco, role, TLS, não compartilhamento, nem que a fábrica entregue conexão nova. **SA-05 segue aberta**. |
| Rollback pré-COMMIT falha durante erro de escrita | `repository.py:283-295`, `320-328`, `errors.py:27-39`: resultado `ROLLBACK_UNCONFIRMED`, `RollbackNotConfirmed` com erro original em `__cause__` e falha de rollback em `rollback_error`. | SA-02 protegida **na estrutura textual**; nenhuma retentativa admissível sem rollback confirmado. |
| Rollback pré-COMMIT sucede e fechamento falha | `repository.py:105-116`, `143-162`, `331-400`: exige `ROLLED_BACK_AFTER_WRITE_FAILURE`, `_connection_closed_observed=True` e `cleanup_failed=False`; relatório distingue falha de `close()` de falha da observação de `conn.closed`. | Erro de fechamento conhecido ou observação não confirmada bloqueia retry. **Não prova** liberação servidor/conexão exclusiva. |
| Reavaliação de colisão | `bridge.py:35-93`: só `create_scenario` na tentativa 0 com `23505` e constraint `scenario_pkey`, depois de `with uow` e de `safe_to_retry_create_collision`. | Não se encontrou repetição após rollback expressamente não confirmado ou COMMIT incerto. Dependência de SA-05 e hipótese sobre nome da constraint permanecem. |
| COMMIT levanta | `repository.py:296-306` e `errors.py:14-24`: outcome `OUTCOME_UNKNOWN` e exceção distinta; `__exit__` fecha sem reverter nem reclassificar o resultado. | Comportamento conservador contra retry cego; **SA-06 segue aberta** quanto a evidências de aborto comprovado/reconciliação. |
| **COMMIT confirmado, mas `close()` falha ou `conn.closed` não confirma fechamento** | `repository.py:143-162`: `_dispose_connection()` registra erro e `cleanup_failed`, porém, se outcome `COMMITTED` e `exc is None`, `__exit__` não o propaga. `bridge.py:79-80` pode retornar a resposta. | **Lacuna alta de visibilidade SA-06.** A confirmação transacional não deve ser reclassificada como rollback ou desconhecida; é necessária política tipada de reporte de **falha de limpeza pós-commit com commit confirmado**, sem expor diagnósticos sensíveis e sem alterar silenciosamente contrato público. |
| Saída antecipada sem commit | `repository.py:143-162`: quando outcome `PENDING`, solicita rollback e fecha; se ausência de exceção primária e cleanup falha, lança `AdapterInfrastructureError`. | Proteção textual observada; se havia exceção primária, a falha de cleanup é anotada sem substituí-la, mantendo limites de observabilidade. |
| Multiplicidade de falhas | `repository.py:331-343`, `369-400`: `_DisposalReport` conserva `rollback_error`, `close_error` e `close_observation_error`; `.error` seleciona a primeira causa para encadeamento. Para `RollbackNotConfirmed`, `__exit__` atribui ambas as causas de fechamento. | Informações internas não estão todas na exceção pública genérica; é necessário contrato de diagnóstico controlado para não vazar mensagens do driver. |

**Verificação de documentação externa (somente leitura):** documentação oficial Psycopg 3 sobre connection context e `ConnectionInfo.status`/`transaction_status` confirma que `with conn` pode fazer commit na saída normal e que `OK`/`BAD`, `IDLE`/`INERROR` são estados distinguíveis. Não comprova comportamento concreto de nenhuma instância do OES e não transforma inspeção textual em teste.

### Juízo adversarial de A4

- **SA-02:** mitigação da condição original **observada na fonte**, mas não `PASS`, não demonstrada sob falhas reais; segurança depende de SA-05 e das hipóteses da fábrica.
- **SA-05 (ALTA):** permanece aberta; propriedades de conexão são checks locais, não atestação de posse, role, TLS, versão/ambiente ou não compartilhamento.
- **SA-06 (ALTA):** permanece aberta, especialmente porque falhas de limpeza *após commit confirmado* podem ficar invisíveis ao chamador. Não chamar essa situação de `CommitOutcomeUnknown`; distinguir confirmação do commit do sucesso de liberação de recursos.
- **SA-03/SA-07/SA-08/SA-10:** mantidas as pendências documentadas; este exame não as resolve.
- **Nenhuma correção Python nesta atividade.** O próximo incremento apropriado é **deliberar estaticamente um mecanismo observável e não secreto para limpeza pós-COMMIT, sem misturar resultados confirmados e incertos**, seguido de revisão adversarial. Qualquer publicação técnica continua bloqueada até evidência documental suficiente; A2-G5 e execução operacional seguem não autorizados.

**STOP — A4 pós-CP244 concluída apenas como revisão textual; código técnico ainda não publicado.**

## A5 pós-CP244 — SA-06: visibilidade tipada da falha de limpeza pós-COMMIT (fonte estática)

**Estado:** `SA-06_POST_COMMIT_CLEANUP_VISIBILITY_STATIC_CANDIDATE_NOT_REVIEWED_NOT_PERSISTED`. Freshness Gate CP244 (`4c9ec2df9255cb103b7b4e0e7390b60853f873cf`) `identical`. Esta atividade alterou textualmente apenas `errors.py`, `repository.py`, `bridge.py` e este README, sem importar/compilar/executar adaptador, testes, SQL, CI, driver, Neon ou publicação GitHub.

- Nova exceção específica `CommitConfirmedCleanupFailed(AdapterInfrastructureError)`: `conn.commit()` retornou normalmente; `close()` falhou ou `conn.closed` não confirmou fechamento. A exceção não é `CommitOutcomeUnknown` e não instrui retry. A mensagem pública é constante e não incorpora o diagnóstico do Psycopg; `close_error` e `close_observation_error` ficam disponíveis **somente para diagnóstico controlado**, sujeitos a redação de informações sensíveis. `commit_confirmed=True` significa **confirmação observada pelo cliente**, não prova de durabilidade material em qualquer falha futura.
- Se uma operação terminar normalmente após COMMIT confirmado, `PostgresUnitOfWork.__exit__` agora **levanta** `CommitConfirmedCleanupFailed` quando `_DisposalReport.error` indicar falha de limpeza pós-COMMIT; não transforma COMMITTED em OUTCOME_UNKNOWN ou rollback. Se já houver uma exceção após o COMMIT, conserva-a e adiciona nota **não sensível** sobre confirmação e falha de limpeza. Nenhum dos dois caminhos permite retry de criação pela `bridge.py`.
- `bridge.py` prepara `stable_result = deepcopy(result)` **antes** de `uow.commit()`, removendo a cópia como possível erro Python depois do COMMIT. A resposta continua semanticamente independente de alterações posteriores. Qualquer exceção anterior ao COMMIT aciona a via pendente de cleanup já prevista.
- O tratamento de `CommitOutcomeUnknown` permanece distinto e conservador: exceção durante `conn.commit()` não é convertida em commit confirmado, nem permite repetição automática. SA-02 conserva condição de rollback/fechamento confirmados para reavaliação por colisão `23505`.
- **SA-06 permanece PENDENTE**: a correção é textual, não uma prova de eventos reais, não classifica todos os abortos definitivos, não verifica reconciliação nem garante recursos liberados no servidor. SA-05 (proveniência/posse/role/TLS), SA-03/07/08/10 também permanecem pendentes. A nova exceção constitui um resultado **de infraestrutura** observável que não equivale ao retorno histórico de sucesso; qualquer compatibilidade sob falha deverá ser avaliada em revisão estática e, em etapa separadamente autorizada, por testes.

**Próximo passo restrito:** revisão adversarial da separação `COMMITTED`/`OUTCOME_UNKNOWN`, exceção nova e fluxo de cópia antes do COMMIT, com inspeção apenas de código-fonte, seguida de decisão de checkpoint CP245. Não atribuir PASS, não publicar o pacote técnico automaticamente. **STOP.**

## A6 pós-CP244 — revisão adversarial estática da correção SA-06 (somente texto)

**Estado:** `SA-06_STATICALLY_MITIGATED_WITH_RESIDUAL_BLOCKERS_NOT_PERSISTED`. Freshness Gate: CP244, `main` HEAD `4c9ec2df9255cb103b7b4e0e7390b60853f873cf`, comparação `identical`. Seis arquivos de staging identificados por inspeção/hashes. **Somente este README foi acrescido; nenhum arquivo Python editado ou executado.** Não houve importação/compilação/testes, SQL, conexão Neon, instalação, CI, deploy ou publicação GitHub.

### Matriz adversarial A6

| Caso / requisito | Evidência textual | Parecer delimitado |
|---|---|---|
| COMMIT retorna normalmente; fechamento sem erro | `repository.py:314-324`, `143-180`; `bridge.py:79-83` | A confirmação é explícita e a resposta é preparada antes dela; no caminho normal retorna a resposta já preparada. **Não validado por execução.** |
| COMMIT confirmado, mas `close()` falha ou `conn.closed` não confirma encerramento | `repository.py:159-169`, `387-418`; `errors.py:27-45` | `CommitConfirmedCleanupFailed` comunica confirmação observada ao cliente e falha de limpeza sem classificar o COMMIT como `OUTCOME_UNKNOWN`, nem autorizar retry. Diagnóstico bruto permanece em atributos internos e exige política de redação. |
| COMMIT levanta exceção | `repository.py:314-321`; `errors.py:14-24` | `CommitOutcomeUnknown` permanece distinta e a ponte não a captura como `23505` retryable. Classificação conservadora não demonstra reconciliação ou aborto definitivo. |
| Preparação de retorno | `bridge.py:69-83` | `deepcopy(result)` antecede `uow.commit()`; não há `deepcopy` do resultado após confirmação no fluxo principal. |
| Erro `23505` de criação com rollback/close confirmados | `repository.py:104-116`, `301-313`, `143-158`; `bridge.py:84-96` | Reavaliação restrita a uma tentativa, à constraint `scenario_pkey` e ao status de reversão/fechamento observado. SA-02 mitigado textual, ainda condicionado a SA-05. |
| **Exceção pré-COMMIT antes de `commit()` seguida de falha de rollback no `__exit__`** | `repository.py:143-180` com `pending=True`, `exc is not None`: o relatório assinala erro e anota a exceção primária, mas não expõe necessariamente uma exceção tipada `RollbackNotConfirmed`; `bridge.py:45-78` pode gerar erros de domínio/conflito antes de `uow.commit()` | **Novo SA-11, ALTA/BLOQUEADOR DE ACEITAÇÃO ESTÁTICA.** O consumidor externo pode receber a exceção primária sem indicador estruturado de rollback não confirmado. Não confundir com SA-02 específico de falha SQL dentro de `commit()`; exigir proteção genérica para qualquer falha de rollback pré-COMMIT. |
| Fábrica de conexões, papel, TLS, exclusividade | `repository.py:36-45`, `118-141`, `364-384` | SA-05 ainda ALTA: checks passivos de estado não atestam origem, propriedade exclusiva, role/banco/TLS. |

### Parecer e condições de continuidade

- **SA-06:** comunicação da falha de cleanup **após COMMIT confirmado** mitigada no código estático; não PASS, não prova de durabilidade operacional nem classificação completa de aborto confirmado.
- **SA-02:** mitigação textual específica de colisão e rollback/close, dependente de SA-05; nenhum teste de falha injetada autorizado.
- **SA-11 (NOVO — ALTA/BLOQUEADOR):** saída de contexto por erro pré-COMMIT com rollback falho preserva apenas o erro primário e uma nota; requer contrato tipado ou estrutura equivalente para comunicar reversão não comprovada e impedir reexecução por qualquer chamador, mantendo causa original e erro da limpeza para diagnóstico seguro. O tratamento não pode tornar um rollback incerto equivalente a COMMIT incerto.
- **SA-05/SA-07/SA-08/SA-10:** permanecem pendentes nas gravidades anteriores; SA-03 também segue mitigação parcial. A estrutura de schema atual não demonstra associação semântica integral de recibos a eventos.
- **Decisão sobre publicação:** **não publicar os seis arquivos técnicos como implementação estática aceita**. O próximo checkpoint recomendado é **CP245 exclusivamente documental**, consolidando A1–A6 pós-CP244 e a restrição SA-11; somente depois retomar uma atividade de correção estática SA-11 sob novo `Prossiga`, sem instalar, executar, importar, testar, SQL, Neon ou CI.

**STOP — A6 pós-CP244 concluída por revisão estática; README em staging, GitHub não alterado.**

## A1 pós-CP245 — correção estática SA-11: rollback pré-COMMIT não confirmado

**Status:** `SA11_STATIC_REMEDIATION_CANDIDATE_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`. Freshness Gate CP245 `main` HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, comparação `identical`. Inventário pré-edição de seis arquivos e hashes coincidentes com o Documento 220. Somente `repository.py`, `errors.py` e este README foram alterados textualmente; não houve importação, compilação ou execução do adaptador, testes, SQL, Neon, CI, instalação ou publicação no GitHub.

- **SA-11 / `PostgresUnitOfWork.__exit__`:** quando a saída ocorre com transação `PENDING`, inclusive com uma exceção pré-COMMIT (domínio, conflito ou infraestrutura), o relatório de limpeza com `rollback_error` produz **`RollbackNotConfirmed` tipada**, sem simplesmente retransmitir a exceção original. `failure.__cause__` conserva a falha anterior quando existente; `rollback_error`, `close_error` e `close_observation_error` ficam em atributos distintos para diagnóstico com redação sensível. Se não havia exceção original, o erro do rollback é a causa. A Unit of Work marca `ROLLBACK_UNCONFIRMED`, desativa qualquer condição de retry seguro e não reclassifica isso como `CommitOutcomeUnknown`.
- **Entrada de contexto:** falha ao iniciar UoW também recebe `RollbackNotConfirmed` tipada se o rollback de limpeza falhar; a exceção primária continua encadeada como causa. A conexão não é automaticamente tratada como segura.
- **Rollback explícito:** se `rollback()` falhar, produz a mesma exceção tipada; fechamento posterior pode acrescentar diagnósticos de encerramento. Em rollback que retorna normalmente, o estado é `ROLLED_BACK`.
- **Sem mudança de autorização ou interfaces de domínio:** `bridge.py` não foi alterado; só permite a reavaliação de colisão `23505` com `safe_to_retry_create_collision=True` após rollback e fechamento confirmados. A nova exceção de infraestrutura não tem SQLSTATE para ser confundida com colisão. `CommitOutcomeUnknown` (COMMIT iniciado e incerto) e `CommitConfirmedCleanupFailed` (COMMIT retornou normalmente, limpeza falhou) permanecem distintas.

**Riscos e fronteiras:** esta é **mitigação apenas estática**, não prova de rollback no PostgreSQL. Um rollback que retorna normalmente ainda depende do contrato do driver; fechamento de conexão não demonstra reversão confirmada no servidor. Falha exclusiva de `close()` após rollback bem-sucedido continua classificada como limpeza incompleta, impedindo retry seguro, mas sem classe de rollback não confirmado. SA-05 (fábrica/posse/TLS/role), SA-06 (COMMIT/reconciliação), SA-07 (JSONB), SA-08 (replay/recibos), SA-10 (SQLSTATE contextual) e SA-03 parcial permanecem. A correção de SA-11 requer **revisão adversarial separada**, não atribuir PASS nem publicar o pacote técnico automaticamente.

**Próxima atividade:** A2 pós-CP245, revisão adversarial de todos os caminhos que podem gerar `RollbackNotConfirmed`, dos diagnósticos, de `__enter__`/`__exit__`/`rollback()` e da interação com `bridge.py`, somente por inspeção textual. **STOP.**

## A2 pós-CP245 — revisão adversarial estática independente de SA-11

**Estado:** `SA11_TYPED_ROLLBACK_PATHS_STATICALLY_REVIEWED_RESIDUAL_CLOSE_VISIBILITY_NOT_VALIDATED_NOT_PERSISTED`. Freshness Gate: ponteiro CP245, `main` HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, comparação `identical`. Seis arquivos de staging presentes; hashes verificados por leitura de bytes, sem importar, compilar nem executar o adaptador. Esta atividade modifica **somente este README**, sem alterar módulos Python, SQL, banco de dados, CI ou GitHub.

### Matriz de caminhos de exceção — apenas inspeção de fonte

| Caminho examinado | Evidência (linhas na versão A1 pós-CP245) | Parecer estático |
|---|---|---|
| Falha em `__enter__` e rollback também falha | `repository.py:118–149`; `errors.py:48–62` | `RollbackNotConfirmed` tipada, `__cause__` preserva erro de entrada, erros de limpeza preservados separadamente; não há UoW devolvida ao chamador. |
| Exceção anterior a `commit()` em `with uow`, rollback de `__exit__` falha | `repository.py:151–173`; `bridge.py:45–83` | **SA-11 original mitigado textualmente**: tipada, causa original preservada e `_outcome=ROLLBACK_UNCONFIRMED`, sem caminho de retry no bridge. |
| Saída normal sem `commit()`, rollback falha | `repository.py:151–173` | Tipada, causa é o erro do próprio rollback. Não há commit implícito. |
| `rollback()` explícito falha | `repository.py:346–357` | Tipada, resultado interno não confirmado; o contexto apenas fecha a conexão posteriormente, sem segundo rollback. |
| Escrita SQL falha em `commit()` e rollback de recuperação falha | `repository.py:284–344`; `bridge.py:84–96` | Tipada com exceção SQL primária em `__cause__` e rollback em atributo; a ponte não identifica `23505` no tipo exterior e `safe_to_retry_create_collision=False`. |
| COMMIT lança exceção | `repository.py:334–341`; `errors.py:14–24` | `CommitOutcomeUnknown` permanece categoria diferente; o contexto fecha sem rollback automático nem retry. |
| COMMIT retorna normalmente, `close` falha | `repository.py:179–198`; `errors.py:27–45` | `CommitConfirmedCleanupFailed` se não existe outra exceção; não reclassifica COMMIT nem autoriza retry. |
| Rollback **retorna normalmente**, mas `close()` ou observação de `closed` falha **e já existe exceção pré-COMMIT** | `repository.py:151–200`, especialmente `173` e `198–200`; `_dispose_connection` em `409–440` | **SA-12 — NOVO, ALTA / observabilidade de limpeza:** a exceção primária pode ser propagada só com uma nota genérica, sem classe explícita para o insucesso de fechamento. Não afirmar que rollback falhou: o rollback retornou normalmente. `safe_to_retry_create_collision` continua falsa, mas outros consumidores podem não perceber a limpeza incompleta por tipo. |
| Falha de rollback em leitura independente seguida de erro de consulta | `repository.py:53–79` | Observação adicional em SA-12: a exceção primária da leitura fica apenas anotada, sem tipo de limpeza; por ser transação read-only, **não equivale** ao SA-11 de comando de escrita. |

### Parecer e limites

- **SA-11:** o mecanismo originalmente bloqueador (erro pré-COMMIT seguido de **falha efetiva de `rollback()`** em saída de UoW) está **mitigado na inspeção textual** em `__enter__`, `__exit__`, rollback explícito e falha de escrita dentro de `commit()`. Isso **não é teste PASS**, nem comprova semântica da biblioteca cliente/servidor; não encerrar A2-G4 ou executar código.
- **SA-02:** a retentativa específica de colisão `23505` ainda exige `scenario_pkey`, `_outcome=ROLLED_BACK_AFTER_WRITE_FAILURE`, conexão observada como fechada e ausência de `cleanup_failed`; as novas exceções tipadas não habilitam retry. A condição depende de SA-05 e do contrato de propriedade exclusiva da fábrica.
- **SA-12 (novo):** comunicar falha de **fechamento** após rollback que retornou normalmente, mesmo quando há exceção primária, **sem mentir sobre rollback e sem mascarar a causa**. Estender avaliação às leituras read-only e falhas de entrada, avaliando se uma exceção tipada de cleanup sem retry deve ser usada. Este achado é distinto de `RollbackNotConfirmed` e `CommitOutcomeUnknown`; não classificar falsamente rollback bem-sucedido como incerto.
- **SA-05, SA-06, SA-07, SA-08, SA-10** e **SA-03 parcial** permanecem. Diagnósticos brutos em `__cause__`/atributos internos podem conter contexto sensível e exigem política de redação antes de exposição em logs; mensagens públicas constantes, por si só, não garantem essa política.

**Decisão:** não publicar os seis arquivos técnicos como fonte aceita. A próxima atividade pode corrigir estaticamente SA-12, limitada aos seis arquivos autorizados, seguida de revisão separada. Como esta é a segunda atividade pós-CP245, o checkpoint documental seguinte deve observar o protocolo CP194 (normalmente 3–5 atividades, antecipado por risco). **STOP.**

## A3 pós-CP245 — remediação estática SA-12: fechamento não confirmado após rollback retornado

**Estado:** `SA12_STATIC_REMEDIATION_CANDIDATE_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`.
Freshness Gate: CP245, `main` HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, comparação `identical`.
A intervenção textual alterou exclusivamente `errors.py`, `repository.py` e este README; o pacote autorizado mantém seis arquivos. Não houve importação, compilação, execução do adaptador, testes, instalação, SQL, Neon, CI ou gravação no GitHub.

- **Tipo de exceção dedicado:** `ConnectionCloseNotConfirmed`, subclasse de `AdapterInfrastructureError`, representa **rollback cujo método retornou normalmente** mas conexão com fechamento não confirmado (`close_error` ou `close_observation_error`). Não declarar que o rollback falhou, que COMMIT foi tentado, nem que o servidor confirmou a reversão. `retry_allowed=False`, mensagem pública constante e diagnósticos brutos guardados exclusivamente em atributos sujeitos a redação para logging.
- **`PostgresUnitOfWork.__enter__`:** se a inicialização falhar, rollback retornar normalmente e fechamento falhar, emitir tipo específico; preservar falha original como `__cause__`. Se rollback falhar, **priorizar `RollbackNotConfirmed`**, não misturar categorias.
- **`PostgresUnitOfWork.__exit__`:** após rollback bem-sucedido no contexto, ou rollback anterior já concluído por `commit()`/`rollback()`, falha de fechamento recebe `ConnectionCloseNotConfirmed` mesmo com exceção primária. O estado `ROLLED_BACK_CLOSE_UNCONFIRMED` diferencia rollback com fechamento não confirmado de `ROLLBACK_UNCONFIRMED`. Mantém `CommitConfirmedCleanupFailed` depois de COMMIT confirmado e `CommitOutcomeUnknown` após tentativa de confirmação incerta; não converter nenhum deles.
- **Leitura independente:** `read_consistent_snapshot` preserva a exceção de consulta em `__cause__` e distingue rollback falho (`RollbackNotConfirmed`) de rollback retornado/fechamento não confirmado (`ConnectionCloseNotConfirmed`), inclusive quando o corpo de leitura retorna normalmente. A limpeza continua tentando rollback uma vez e close uma vez.
- **Retentativa:** `bridge.py` não foi modificado. Os novos tipos não têm `sqlstate=23505`; o retry específico exige SQLSTATE original mais `safe_to_retry_create_collision=True` e portanto não é autorizado quando o fechamento não foi comprovado. Uma falha SQL primária ainda pode ser recuperada em `__cause__`, com necessidade de redação antes de exposição.

**Limites:** somente inspeção e edição estática; nenhum resultado operacional PASS, nenhuma prova de exclusividade da fábrica, de fechamento no servidor ou durabilidade de rollback. SA-05, SA-06, SA-07, SA-08 e SA-10 permanecem, SA-03 parcial; SA-11 apenas mitigada textualmente. **SA-12 exige revisão adversarial independente na próxima atividade.** A2-G4 não aceita/publicada, A2-G5/execução T2-A2 NOT_AUTHORIZED. **STOP.**

## A4 pós-CP245 — revisão adversarial estática independente de SA-12

**Estado:** `SA12_STATIC_REVIEW_MITIGATION_OBSERVED_SA06_REMAINS_OPEN_NOT_VALIDATED_NOT_PERSISTED`.
**Freshness Gate:** CP245, `main` HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, comparação `identical`. Os seis arquivos locais foram inspecionados exclusivamente como texto; **nenhum módulo foi importado, compilado, executado ou testado**. Somente este README foi atualizado; módulos Python e GitHub inalterados.

### Matriz de revisão — caminhos e condições observados

| Caminho | Evidência de código no staging pós-A3 | Parecer estritamente textual |
|---|---|---|
| Falha de inicialização, `rollback()` retorna, `close()` falha ou `conn.closed` não confirma | `repository.py:129–163`, `_dispose_connection` em `450–481` | `__enter__` produz `ConnectionCloseNotConfirmed` e encadeia a falha inicial, sem classificar falsamente rollback como falho. |
| Falha de inicialização e rollback falha, independentemente de close | `repository.py:145–159`; `errors.py:48–62` | `RollbackNotConfirmed` tem precedência; erro original é `__cause__`; falhas de fechamento ficam em atributos restritos. |
| Saída normal de UoW sem `commit()` e `rollback()` retorna, mas fechamento não é confirmado | `repository.py:165–223`, em especial `169–190` e `215–223` | `ConnectionCloseNotConfirmed` impede retorno normal e não habilita retentativa. |
| Erro anterior a COMMIT + rollback do contexto retorna + close falha | `repository.py:165–223` | Exceção tipada expõe fechamento não confirmado e conserva erro anterior em `__cause__`; a condição de retry de `bridge.py:84–96` não a aceita. **SA-12 original mitigada textualmente.** |
| Erro anterior a COMMIT + rollback do contexto também falha | `repository.py:174–186`; `errors.py:48–62` | `RollbackNotConfirmed`, não `ConnectionCloseNotConfirmed`: SA-11 preservada, sem repetir. |
| Falha de SQL em `commit()` + rollback de recuperação retorna + `close()` falha | `repository.py:344–356`, `165–223` | A exceção SQL original é encadeada em `ConnectionCloseNotConfirmed`; `safe_to_retry_create_collision=False` pela ausência de fechamento observado. |
| `rollback()` explícito retorna + fechamento falha no `__exit__` | `repository.py:369–380`, `165–223` | Estado `ROLLED_BACK`; a falha de fechamento é tipada. |
| Leitura independente retorna ou falha; rollback de leitura retorna, close falha | `repository.py:54–90` | `finally` propaga `ConnectionCloseNotConfirmed`; a falha original da leitura fica como causa quando existente. |
| Leitura independente, rollback falha | `repository.py:75–90` | `RollbackNotConfirmed` tipado prevalece; não confundir com fechamento isoladamente falho. |
| COMMIT retorna normalmente; close falha | `repository.py:196–214`, `errors.py:27–45` | Mantém `CommitConfirmedCleanupFailed`, sem mudar a classificação de confirmação; no ramo de exceção pós-COMMIT preexistente há apenas nota (SA-06 residual). |
| COMMIT lança erro; close também falha | `repository.py:357–364`, `165–223`, `errors.py:14–24` | Mantém `CommitOutcomeUnknown`, sem rollback/retry, mas **diagnósticos secundários de close não são disponibilizados em atributos estruturados do erro público**; **SA-06 segue aberta**. |

### Verificações de segurança e distinções

- **SA-12:** o cenário preciso (rollback cujo método retornou normalmente, seguido de falha observável no fechamento, com exceção primária presente) está **mitigado na leitura da fonte**, nos caminhos de contexto e leitura independente. O tipo `ConnectionCloseNotConfirmed` (`errors.py:65–82`) mantém `rollback_call_returned_normally=True`, `retry_allowed=False`, dois diagnósticos de close em atributos separados, e mensagem pública constante. A propriedade não comprova reversão servidor ou exclusividade da conexão.
- **Não mascaramento de SA-11:** quando houve erro em `rollback()`, o tipo externo é `RollbackNotConfirmed`, com erro original em `__cause__` quando aplicável; SA-12 não altera esse estado.
- **Retentativa:** a ponte requer uma exceção SQL `23505` com `constraint_name=scenario_pkey` **e** `safe_to_retry_create_collision` verdadeiro, que por sua vez exige `ROLLED_BACK_AFTER_WRITE_FAILURE`, `closed_observed` e nenhuma falha de limpeza (`bridge.py:84–96`; `repository.py:115–127`). Os tipos de limpeza não oferecem o SQLSTATE externo para esse caminho. Nenhum dos cenários SA-12 examinados habilita retry.
- **SA-06 — ressalva preexistente:** em `OUTCOME_UNKNOWN` com erro secundário de fechamento, a exceção `CommitOutcomeUnknown` permanece correta para bloquear retry, mas o erro secundário só pode figurar como nota, sem `close_error`/`close_observation_error` próprios. Em `COMMITTED` com exceção preexistente, a visibilidade do close é também apenas anotada. Reavaliar em atividade futura, sem classificar COMMIT incerto como abortado e sem revelar mensagens brutas do driver.
- **Contrato de conexão SA-05:** a inspeção passiva de `conn.closed`, `autocommit`, `info.status` e `transaction_status` não comprova fábrica de conexão nova/exclusiva, papel, banco ou TLS. Os caminhos de limpeza revisados dependem de conexão conforme contrato.
- **Restrição de evidência:** classes auxiliares, encadeamento de causas, `.closed` e propriedades de status não foram exercitados contra Psycopg/PostgreSQL. Mensagens/atributos de exceções originais podem conter dados sensíveis; redação antes de logs ou serialização permanece necessária. SA-07 (JSONB), SA-08 (replay/recibos), SA-10 (SQLSTATE) e SA-03 parcial seguem abertas.

**Decisão A4:** `SA12_STATICALLY_MITIGATED_ADVERSARIAL_REVIEW_COMPLETE_WITH_RESERVATIONS`. Não declarar `SA12_PASS`, `A2-G4_COMPLETED` ou publicar pacote técnico. **Próxima atividade sugerida:** A5 pós-CP245, revisão/correção estática delimitada da observabilidade de limpeza no ramo `CommitOutcomeUnknown` (SA-06), preservando a distinção entre resultado indeterminado e fechamento falho; depois avaliar checkpoint documental CP246 conforme CP194. A2-G5 e execução T2-A2 seguem `NOT_AUTHORIZED`.

**STOP.**

## A5 pós-CP245 — refinamento estático SA-06: diagnóstico estruturado de fechamento após COMMIT incerto

**Estado:** `SA06_UNKNOWN_COMMIT_CLOSE_DIAGNOSTICS_STATIC_CANDIDATE_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`.
Freshness Gate: CP245, `main` HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, comparação `identical`.
**Escopo de edição:** somente `errors.py`, `repository.py` e este `README.md`. Os demais arquivos técnicos permanecem textualmente inalterados. Sem importação, compilação, execução, testes, dependências, SQL, Neon, CI ou publicação no GitHub.

### Contrato candidato estritamente estático

- `errors.py / CommitOutcomeUnknown`: acrescenta `retry_allowed=False` e campos de diagnóstico `close_error`, `close_observation_error` e `connection_closed_observed` (inicialmente `None`, significando relatório de saída ainda indisponível). Mensagem pública constante; os campos de exceção bruta exigem redação de dados sensíveis antes de qualquer logging/serialização.
- `repository.py / PostgresUnitOfWork.__exit__`: **apenas** quando `_outcome == "OUTCOME_UNKNOWN"` e a exceção propagada é `CommitOutcomeUnknown`, anexa ao **mesmo objeto de exceção** os campos retornados por `_dispose_connection`. Mantém `__cause__` do erro original em `conn.commit()` e mantém as notas genéricas não sensíveis. Não chama novo `rollback()` após tentativa de COMMIT.
- O campo `connection_closed_observed` relata fechamento observado da *conexão cliente*, jamais confirma aborto, efetivação, durabilidade ou reconciliação de COMMIT. `close_error` e `close_observation_error` são independentes do diagnóstico do COMMIT.
- A ponte `bridge.py` permanece inalterada: exceção `CommitOutcomeUnknown` não é uma colisão `23505` elegível; nenhuma retentativa automática é autorizada. `CommitConfirmedCleanupFailed`, `ConnectionCloseNotConfirmed` e `RollbackNotConfirmed` não foram alteradas.

### Cenários para a próxima revisão adversarial, não executados

| Cenário | Informação candidata | Classificação invariável |
|---|---|---|
| `conn.commit()` falha; `close()` retorna e `conn.closed` é observado verdadeiro | `close_error=None`, `close_observation_error=None`, `connection_closed_observed=True` | `CommitOutcomeUnknown`; não inferir rollback nem commit |
| `conn.commit()` falha; `conn.close()` também falha | `close_error` retém a exceção restrita; o estado observado é independente | `CommitOutcomeUnknown`; não retry |
| `conn.commit()` falha; consulta `conn.closed` falha ou não confirma fechamento | `close_observation_error` documenta observação falha/não confirmada | `CommitOutcomeUnknown`; não retry |
| `conn.commit()` retorna normalmente; saída falha ao fechar | Fluxo anterior `CommitConfirmedCleanupFailed`, sem transformação | COMMIT retornou normalmente, cleanup falhou |
| Falha anterior a COMMIT e rollback/fechamento falha | Fluxos anteriores `RollbackNotConfirmed`/`ConnectionCloseNotConfirmed` | Nunca reinterpretar como COMMIT incerto |

**Limitações mantidas:** o relatório de saída não resolve COMMIT indeterminado; não atesta fábrica exclusiva, role, TLS, servidor ou durabilidade (SA-05). Persistem SA-06 quanto à classificação de aborto comprovado e reconciliação, SA-07 (JSONB), SA-08 (recibos e replay), SA-10 (SQLSTATE), SA-03 parcial. A comunicação de falha em limpeza de COMMIT confirmado com uma exceção pós-COMMIT preexistente continua baseada em nota e não foi expandida nesta atividade. Esta remediação **não é PASS, não constitui aceitação estática A2-G4 e não libera A2-G5**.

**Próxima atividade sugerida:** revisão adversarial A6 pós-CP245 desta mudança, seguida de avaliação e possível checkpoint CP246 **somente documental**. **STOP.**

## A6 pós-CP245 — revisão adversarial estática dos diagnósticos SA-06 de COMMIT incerto

**Estado:** `SA06_UNKNOWN_COMMIT_DIAGNOSTICS_STATICALLY_REVIEWED_RESIDUAL_RECONCILIATION_PENDING_NOT_PERSISTED`. Freshness Gate: ponteiro CP245, `main` HEAD `b9bd139265a1f3f12006c579dbe2e956bb179995`, comparação `identical`. Seis arquivos de preparação presentes. A atividade A6 modifica **somente este README**; os cinco arquivos Python permanecem sem alterações. Nenhum import, compilação, execução, teste, instalação, SQL, Neon, CI ou publicação GitHub.

### Matriz de revisão estática

| Cenário | Evidência textual A5/A6 pós-CP245 | Parecer delimitado |
|---|---|---|
| `conn.commit()` lança exceção; `conn.close()` retorna, `conn.closed is True` | `repository.py:364–374, 165–202, 457–488`; `errors.py:14–33` | `CommitOutcomeUnknown` conserva erro de `commit()` em `__cause__`; na saída normal do contexto os diagnósticos são `close_error=None`, `close_observation_error=None`, `connection_closed_observed=True`. O fechamento do cliente **não resolve** o resultado no servidor. |
| Exceção no COMMIT e falha de `close()` | `repository.py:196–202, 472–485`; `errors.py:28–33` | Mesmo tipo `CommitOutcomeUnknown`, sem retry. Exceção secundária de close fica em atributo restrito `close_error` e não na mensagem pública. `connection_closed_observed=False` é conservador mesmo se `conn.closed` isoladamente indicar True. |
| Exceção no COMMIT, estado de fechamento inacessível ou negativo | `repository.py:476–485, 196–202` | `close_observation_error` distinto de `close_error`; `connection_closed_observed=False`; não presumir rollback nem confirmação. |
| COMMIT retorna normalmente e cleanup falha | `repository.py:203–220`; `errors.py:36–54` | `CommitConfirmedCleanupFailed` continua distinta; exceção original de `commit()` não existe nesse fluxo. Ausência de retry. |
| Erro pré-COMMIT acompanhado de rollback/close falho | `repository.py:145–163, 165–230, 351–363`; `errors.py:57–91` | `RollbackNotConfirmed` e `ConnectionCloseNotConfirmed` não são reclassificadas como `CommitOutcomeUnknown`. |
| Retentativa após resultado de COMMIT indeterminado | `bridge.py:84–96`; `repository.py:115–127` | Não identificada: exceção externa é de infraestrutura sem SQLSTATE de colisão, e estado `OUTCOME_UNKNOWN` não habilita `safe_to_retry_create_collision`. |

### Ressalvas e riscos mantidos

- **Cobertura do lifecycle:** `CommitOutcomeUnknown` inicializa os três atributos de encerramento com `None`; eles são preenchidos **somente** quando `PostgresUnitOfWork.__exit__` recebe o mesmo objeto de exceção enquanto `_outcome == "OUTCOME_UNKNOWN"` (`repository.py:196–202`). Um consumidor que intercepte a exceção *dentro* do bloco, utilize `commit()` fora de um contexto encerrado, ou a substitua antes da saída pode observar atributos não preenchidos. O fluxo canônico de `SyntheticPostgresCommandBridge` usa `with uow` e permite propagação da exceção; não é prova de que outros consumidores o façam. `None` indica relatório ausente, não prova de fechamento bem-sucedido.
- **Causa e sigilo:** o erro original do driver permanece em `__cause__` (`repository.py:365–371`). Campos `close_error` e `close_observation_error` guardam exceções brutas para diagnóstico restrito; tracebacks/serializações exigem redação específica e não devem divulgar detalhes de credenciais, consultas ou infraestrutura.
- **SA-06 ainda ABERTA:** classificação conservadora de COMMIT incerto não comprova aborto definitivo, durabilidade, reconciliação ou resultado no servidor; mesmo fechamento confirmado não resolve essa incerteza. Em estado COMMITTED com exceção posterior preexistente, a falha de close ainda pode ser sinalizada somente por nota (`repository.py:206–221`); isso não ocorreu no fluxo canônico de retorno examinado, mas requer delimitação contratual separada antes de aceitar código.
- **SA-05 segue ALTA:** propriedades passivas não comprovam propriedade exclusiva, fábrica nova, papel, banco ou TLS. **SA-03 parcial, SA-07, SA-08, SA-10 pendentes**; SA-02/SA-11/SA-12 apenas mitigadas por revisão textual, nunca por testes.
- **Decisão de publicação:** A2-G4 não está aceito/publicado tecnicamente. Não instalar/importar/compilar/executar/testar o adaptador, usar CI/SQL/Neon nem promover A2-G5. Preservar os seis arquivos apenas em staging até decisão técnica posterior.

**Próxima atividade recomendada, sob novo `Prossiga`: A7 pós-CP245 — checkpoint CP246 exclusivamente documental**, consolidando A1–A6 e os achados residuais, sem publicar pacote A2. Após CP246, priorizar SA-05, SA-07, SA-08, SA-10 e a delimitação remanescente de SA-06. Aplicar Freshness Gate novamente antes do commit.

**STOP — A6 pós-CP245 concluída por revisão estática; sem persistência canônica.**

## A1 pós-CP246 — triagem adversarial estática SA-05 (fábrica, propriedade e estado da conexão)

**Estado:** `SA05_STATIC_CONTRACT_GAP_CONFIRMED_TRIAGE_ONLY_NOT_VALIDATED_NOT_PERSISTED`.
**Freshness Gate:** CP246, `main` HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, `identical`; ponteiro único CP246. Os seis arquivos de staging existiam e coincidiam exatamente com os seis SHA-256 do Documento 221 antes da presente edição. **Esta atividade altera apenas este README**, sem modificar Python nem enviar arquivos ao GitHub. Nenhuma importação, compilação, execução, instalação de Psycopg, teste, SQL, acesso ao Neon, consulta de conexão ou CI.

### A. Garantias que o código *declara ou inspeciona*, não prova operacionalmente

| Ponto | Evidência textual | Conclusão estritamente estática |
|---|---|---|
| Instanciação e fábrica | `repository.py:37–52, 93–104` | Recebe uma função chamável e a conserva; construção de repositório/UoW não chama a fábrica. `read_consistent_snapshot` a chama em 56, e `__enter__` em 132. Não há provedor concreto nem contrato de identidade de objetos. |
| Estado inicial passivo | `repository.py:434–454` | Rejeita `conn.closed is not False`, `autocommit is not False`, `conn.info.status.name != 'OK'` e `conn.info.transaction_status.name != 'IDLE'`. A semântica dessas propriedades foi examinada apenas como referência documental de Psycopg 3, **não foi exercitada contra a distribuição/versão fixada ou banco**. |
| Disciplina transacional | `repository.py:59–90, 129–230, 320–388` | A fonte solicita isolamento antes das consultas; escrita confirma apenas por `conn.commit()` explícito e saída não faz commit implícito da conexão; rollback/fechamento próprios são registrados. Sem garantia sobre sessão previamente alterada. |
| Retentativa delimitada | `repository.py:115–127`; `bridge.py:35–98` | `safe_to_retry_create_collision` exige estado de rollback por falha de escrita, ausência de erro de cleanup e fechamento observado. Uma conexão compartilhada/emprestada quebraria a hipótese de posse sobre a qual a regra se apoia. |
| Falhas de limpeza | `repository.py:457–488` | Tenta `conn.close()` e verifica `conn.closed`; o resultado informa apenas o handle cliente, **não** propriedade exclusiva nem o estado transacional efetivo do servidor. |

### B. Fatos que *não* podem ser atestados somente por leitura do adaptador

- **Nova conexão por chamada e exclusividade:** um `Callable` pode devolver repetidamente o mesmo objeto, um lease de pool, wrapper ou conexão simultaneamente entregue a outro consumidor. `IDLE`/`OK` não detectam uso histórico, uso concorrente ou restauração completa de sessão; `conn.close()` poderia encerrar recurso de terceiro. Nem mesmo uma trava local por identidade provaria ausência de compartilhamento fora do processo.
- **Identidade real e autorização:** conexão com o banco, login e papel efetivo (`current_user` sob eventual `SET ROLE`), ACLs/GRANTs efetivos, search_path, database e endpoint necessitam de evidência do ambiente/servidor. Parâmetros de conexão do cliente não provam todas essas propriedades, nem substituem preflight separado com escopo autorizado.
- **Transporte:** negociação TLS, verificação do certificado e hostname, CA e parâmetros libpq efetivos, timeouts, origem da configuração/segredos e comportamento de redes/pools dependem de preflight operacional independente. Não inspecionar segredos nem inserir DSNs/TLS/credenciais no código de estágio.
- **Runtime:** sem importação, dependência instalada, PostgreSQL, acesso ou testes não há prova de que os atributos Psycopg 3.3.6, as exceções, os eventos de concorrência e o fechamento se comportem como esperado.

### C. Salvaguardas de fonte candidatas, **não executadas nesta atividade**

1. Formalizar interface e pré-condições da fábrica no contrato estático (conexão Psycopg síncrona, nunca pooled/emprestada, criada para exatamente uma UoW/leitura, sem transação ou estado de sessão legado); exigir instanciador de aplicação explicitamente inspecionável num gate futuro. **Simples documentação/Protocol não estabelece posse real.**
2. Avaliar política fail-closed para objetos reutilizados no mesmo processo e coerência do estado observado, sem confiar na identidade de objeto como certificação de exclusividade cross-process. Evitar criar falso selo de segurança por um contador/flag de chamada.
3. Separar parâmetros esperados de banco, usuário de login e endpoint dos controles de papel **efetivo** no servidor; uma futura etapa autorizada pode validar as propriedades com evidência independente. Não realizar `SHOW`, `SELECT`, inspeção Neon ou chamadas de conexão nesta fase.
4. Definir preflight operacional **em gate separado** para role `oes_t2a2_app`, banco/host aprovado, TLS com verificação da identidade do servidor, grants mínimos, libpq/driver e limites de conexão/timeout; não modificar infraestruturas, roles ou schema para satisfazer esta triagem.
5. Confirmar em revisão estática futura que falhas de obtenção/validação de conexão, inclusive conexão emprestada, não acionam retry; o ciclo de vida atual fecha a conexão recebida como se fosse de propriedade exclusiva. Não alterar módulos nesta A1.

### Parecer e continuidade

**SA-05 permanece `ABERTA / ALTA`:** o código rejeita determinados estados de conexão inadequados, mas **não prova posse exclusiva, sessão nova, papel efetivo, banco, TLS ou configuração operacional**. A ausência de implementação concreta da fábrica no escopo autorizado impede aceite estático integral dessa dependência. Não declarar `SA05_PASS`, `A2-G4_COMPLETED`, fonte operacionalmente validada, grants verificados agora ou novos testes PASS.

**A2 pós-CP246, sob novo `Prossiga`:** escolher uma intervenção **de código estático estritamente delimitada** para reduzir o risco de compartilhamento/estado inadequado de conexão sem alegar verificação de ambiente, ou explicitar uma decisão documental de dependência externa se nenhuma intervenção de fonte trouxer benefício proporcional. Em qualquer caso, revisar adversarialmente as alterações em atividade seguinte. SA-03 parcial, SA-06, SA-07, SA-08, SA-10 seguem pendentes. A2-G5 e T2-A2 operacional `NOT_AUTHORIZED`.

**STOP — A1 pós-CP246: somente triagem estática, README em staging, GitHub inalterado.**

## A2 pós-CP246 — reforço estático proporcional do contrato SA-05 da fábrica

**Estado:** `SA05_NOMINAL_DEDICATED_FACTORY_CONTRACT_CANDIDATE_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`.
**Freshness Gate inicial:** CP246, HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, comparação `identical`. No início da A2, os seis arquivos estavam presentes; os cinco arquivos Python coincidiam com os hashes do Documento 221 e o README correspondia ao registro A1 pós-CP246. **Alterados somente `repository.py` e `README.md` em staging local.** Sem instalação/importação/compilação/execução do adaptador, testes, SQL, Neon, CI, grants ou publicação no GitHub.

### Contrato candidato, somente inspeção textual

- Em `repository.py`, a classe nominal `DedicatedConnectionFactory` declara o contrato de uma função `open_new_connection` que **deve** abrir uma conexão Psycopg 3 **síncrona, nova, exclusivamente possuída e destinada a apenas uma** leitura independente ou Unit of Work. Pool leases, conexões emprestadas, objetos armazenados em cache e sessões compartilhadas violam expressamente a pré-condição. A criação do invólucro não invoca o provedor nem abre conexão.
- `PostgresScenarioRepository.__init__` rejeita a injeção de um mero `Callable`, exigindo uma instância explícita de `DedicatedConnectionFactory`. `PostgresUnitOfWork.__init__` aplica o mesmo requisito, inclusive para construção direta. A fábrica só é acionada em `read_consistent_snapshot` ou `PostgresUnitOfWork.__enter__` por meio de `open_new_connection()`. A disciplina transacional preexistente e a validação passiva `_require_clean_owned_connection` permanecem em vigor.
- A assinatura nominal força uma **declaração de responsabilidade do integrador**, reduzindo o risco de uso acidental de um simples callback que retorna conexão pooled/compartilhada. **Não detecta fraude, wrapper com callback inadequado, reutilização histórica, duplicação entre processos, uso concorrente, role/database/endpoint incorretos, TLS ou estado real do servidor.** Não introduzir alegação de certificação de propriedade por `isinstance` ou objeto marcado.
- O provedor concreto de conexão e a composição do integrador **não são criados no pacote** (e não há instalação de Psycopg). A identificação do opener e a conformidade com esse contrato precisam de uma revisão independente no futuro gate operacional; a mera presença do wrapper não constitui preflight aprovado.
- Os caminhos de limpeza/retry, exceções e a ponte de comandos não foram alterados. Em particular, `safe_to_retry_create_collision` permanece condicionada ao rollback e fechamento reportados; nenhum resultado de COMMIT incerto habilita nova tentativa. Uma fábrica desonesta ou conexão emprestada ainda pode violar essas premissas; logo, SA-02 continua condicionada a SA-05.

### Condições para revisão adversarial A3 pós-CP246

1. Confirmar por leitura de fonte que os dois pontos de abertura usam exclusivamente `DedicatedConnectionFactory.open_new_connection()` e que construção de repositório/UoW não abre conexão nem executa SQL.
2. Verificar que a exigência nominal também cobre instanciação direta de `PostgresUnitOfWork`, sem introduzir compatibilidade falsa com o `Callable` anterior.
3. Identificar limitações e possíveis regressões de interface, sem importar o pacote. Como A2 ainda não foi publicada, nenhuma compatibilidade operacional foi certificada.
4. Verificar caminhos de falha de obtenção e pré-checagem de conexão e seu efeito sobre a restrição de retentativa, mantendo SA-05 aberta caso o código não demonstre posse exclusiva.
5. Preservar a fronteira A2-G4: seis arquivos técnicos, Psycopg 3.3.6 apenas referência de API; nada de testes/execução/SQL/Neon/CI, nova role, grants, schema ou custos.

**Parecer A2:** `SA05_STATIC_CONTRACT_STRENGTHENED_NOT_PROVEN`. SA-05 permanece **ABERTA/ALTA**; SA-03 parcial, SA-06, SA-07, SA-08 e SA-10 abertas. A2-G4 não está aceita/publicada e A2-G5/T2-A2 operacional continuam `NOT_AUTHORIZED`. **Próxima atividade, somente sob novo `Prossiga`: A3 pós-CP246 — revisão adversarial estática independente deste reforço de fábrica.**

**STOP — A2 pós-CP246: código somente em staging, sem persistência canônica.**

## A3 pós-CP246 — revisão adversarial da fábrica nominal SA-05

**Estado:** `SA05_NOMINAL_FACTORY_STATIC_REVIEW_WITH_ACQUISITION_GAPS_NOT_PERSISTED`.
**Freshness Gate:** CP246, GitHub `main` HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, comparação `identical`. Seis arquivos no staging encontrados. Nesta atividade apenas este README foi alterado; o adaptador não foi importado, compilado, executado nem testado. Sem driver instalado, SQL, Neon, CI, mudança de grants ou publicação do pacote.

### Matriz de revisão da alteração A2

| Caminho | Evidência textual | Parecer |
|---|---|---|
| Injeção no repositório | `repository.py:31–50,60–69` | `DedicatedConnectionFactory` é classe nominal com opener chamável; `PostgresScenarioRepository` rejeita um `Callable` avulso. A construção não abre conexão. |
| Construção direta da UoW | `repository.py:116–139` | Exige o mesmo tipo nominal, sem bypass acidental por `Callable` avulso. Não garante que uma instância legítima use opener correto. |
| Pontos de obtenção | `repository.py:77–82,155–162` | São dois usos de `open_new_connection()`; não há obtenção no construtor do repositório, da UoW ou da ponte (`bridge.py:18–28`). |
| Estado inicial | `repository.py:460–480` | Verificações passivas de `closed`, `autocommit`, `info.status`, `info.transaction_status` rejeitam parte dos estados inadequados. Não atestam origem ou exclusividade, nem servidor, papel ou TLS. |
| Retentativa de criação | `repository.py:141–153`; `bridge.py:84–96` | Continua condicionada a `ROLLED_BACK_AFTER_WRITE_FAILURE`, ausência de falha de cleanup e fechamento observado. Erros da fábrica antes da entrada não satisfazem essa condição. |
| Conexão pooled/emprestada | `repository.py:31–50,460–480` | Proibida em docstring/contrato, mas nenhuma verificação nominal ou passiva comprova a posse real; `close()` de conexão emprestada ainda seria arriscado. SA-05 ABERTA/ALTA. |

### Fragilidades residuais descobertas — tratadas como subachados SA-05

- **SA05-R1 — falha do opener fora do escopo de entrada (prioridade média):** em `PostgresUnitOfWork.__enter__`, `conn = self._factory.open_new_connection()` ocorre na linha 158, **antes** do `try` da linha 160. Se a obtenção lança exceção, `__enter__` não entra no bloco de limpeza, `_finished` fica falso e `_outcome` continua `NEW`, permitindo que o **mesmo objeto UoW** seja usado novamente apesar de o contrato descrever uma operação de uso único. Em `read_consistent_snapshot`, a obtenção na linha 79 também está fora do `try`. Não foi demonstrada retentativa automática pela ponte; seu fluxo cria UoW nova e requer `safe_to_retry_create_collision`, que permanece falsa na falha de abertura. A ausência de handle devolvido impede que o repositório feche eventual conexão retida internamente pelo opener; tal falha pertence ao contrato da fábrica e necessita tratamento/observabilidade próprios.
- **SA05-R2 — objeto de conexão inválido e classificação de erro (prioridade média/alta):** `DedicatedConnectionFactory.open_new_connection()` encaminha o retorno sem validá-lo (`repository.py:43–50`). Se o opener retorna `None`, `_require_clean_owned_connection(None)` falha durante inspeção, seguida por `_dispose_connection(None, rollback=True, ...)`, que por sua vez registra erros artificiais de `rollback()` e `close()` e pode converter o diagnóstico externo em `RollbackNotConfirmed`. Nenhuma transação real precisou existir para surgir essa classificação. A fábrica deve rejeitar resultado inválido **antes** de iniciar o caminho de rollback/fechamento, sem criar falsa inferência de transação incerta e sem declarar garantida a posse de objetos aparentemente válidos. Requer revisão equivalente em `read_consistent_snapshot`.

**Sem regressão observada no foco principal:** a exigência nominal é aplicada no repositório e na construção direta da UoW; `bridge.py` não recebeu alteração; o retry de `23505` não é habilitado por falha de aquisição. Porém, a verificação acima apenas examina a estrutura da fonte, não valida Psycopg ou a conformidade do provedor. Consulta textual à documentação oficial Psycopg indica que `Connection.info.status` e `transaction_status` descrevem estado de conexão/transação, não propriedade exclusiva; operações de pool possuem ciclo de empréstimo/devolução separado. A documentação web consultada é evolutiva e não substitui verificação futura na versão de referência 3.3.6.

### Encaminhamento

**SA-05 mantém-se `ABERTA/ALTA` e o incremento nominal não está aceito.** Próxima atividade candidata **A4 pós-CP246**, sob novo `Prossiga`: correção **somente estática**, proporcional, do encerramento de lifecycle da UoW na falha do opener (R1) e da classificação de resultado `None`/inválido (R2), preservando a não execução, o contrato de conexão exclusiva como obrigação externa e as regras de rollback/retry. Não introduzir novos arquivos técnicos, credenciais, queries de preflight, acesso ao Neon, CI, testes ou autorização A2-G5. Após corrigir, programar revisão adversarial em outra atividade antes de publicar código.

**STOP — A3 pós-CP246, revisão estática somente; nenhum módulo Python modificado nem persistência canônica.**


## A4 pós-CP246 — correção estática proporcional de SA05-R1/R2 (obtenção e retorno inválido)

**Estado:** `SA05_ACQUISITION_GUARDS_STATIC_CANDIDATE_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`.
**Freshness Gate:** CP246 HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, comparação `identical`. Atividade exclusivamente de edição e inspeção textual; apenas `errors.py`, `repository.py` e este README modificados em staging. Não houve import/compilação/execução do adaptador, testes, conexão, SQL, Neon, CI, driver instalado, grants ou publicação GitHub.

### SA05-R1 — lifecycle da Unit of Work na falha de aquisição

- `PostgresUnitOfWork.__enter__` passa a gravar `_finished=True` e `_outcome="ACQUISITION_FAILED"` **antes** de chamar o opener; assim, mesmo que o opener levante exceção, uma segunda entrada no mesmo objeto é proibida por `_finished`, e `safe_to_retry_create_collision` permanece falsa.
- Somente após a preparação efetiva da transação e leitura inicial bem-sucedidas `_entered=True`, `_finished=False`, `_outcome="PENDING"`; os demais caminhos preservam os contratos prévios de confirmação explícita e limpeza.
- Se o opener lança e não devolve conexão, o adaptador não tem handle para rollback/close. A fábrica **deve** liberar eventual recurso que tenha alocado antes de lançar. Isto é obrigação de integração, não observabilidade/garantia operacional; o erro externo é `ConnectionAcquisitionError` com causa original encadeada, sem inferir resultado de transação.
- `read_consistent_snapshot` continua chamando o opener antes do bloco de leitura: se não há handle retornado, não existe handle que seu `finally` possa liberar. A classificação da falha vem da fábrica. Nenhum objeto de UoW está associado às leituras independentes.

### SA05-R2 — classificação proporcional do retorno inválido

- `DedicatedConnectionFactory.open_new_connection()` diferencia falha do opener, retorno `None` e ausência de métodos básicos **chamáveis** `execute`, `rollback`, `close`; nessas situações lança `ConnectionAcquisitionError`, e o objeto inválido **não** é passado a `_dispose_connection` para fabricar um falso `RollbackNotConfirmed`.
- Este exame de interface não importa Psycopg nem chama métodos transacionais; não certifica que um objeto com três métodos seja conexão Psycopg válida, nem que tenha posse exclusiva, role, database, endpoint, TLS ou libpq corretos. `_require_clean_owned_connection` continua impondo verificações passivas de estado após adquirir um handle minimamente plausível.
- Objetos parcialmente compatíveis e falhas em propriedades passivas continuam sujeitos a inspeção estática adicional. O adaptador não tenta descartar objetos manifestamente inválidos porque **não há posse legítima comprovada**; eventuais recursos de opener defeituoso ficam sob responsabilidade da integração.
- `ConnectionAcquisitionError(AdapterInfrastructureError)` usa mensagem pública constante, `retry_allowed=False` e preserva a exceção do opener como `__cause__` sem expor texto potencialmente sensível na mensagem. Nenhum diagnóstico de aquisição autoriza retry via a ponte: ele não carrega o SQLSTATE `23505` nem atende a `safe_to_retry_create_collision`.

**Limitações obrigatórias:** somente mitigação estática candidata. Não atribuir PASS a SA05-R1/R2 ou encerrar SA-05/SA-02. O contrato nominal não comprova exclusividade ou liberação de recursos quando o opener falha depois de abrir internamente. Uma revisão adversarial independente é a próxima atividade (A5 pós-CP246), incluindo falha de método de inspeção, erro durante validação passiva, retorno inválido e preservação dos caminhos de cleanup. SA-03 parcial e SA-06/07/08/10 permanecem abertas. A2-G4 não está aceita/publicada; A2-G5/runtime NOT_AUTHORIZED.

**STOP — A4 pós-CP246: arquivos somente em staging, sem publicação canônica.**

## A5 pós-CP246 — revisão adversarial estática SA05-R1/R2 da aquisição dedicada

**Estado:** `SA05_ACQUISITION_ADVERSARIAL_REVIEW_WITH_NEW_R3_NOT_VALIDATED_NOT_PERSISTED`.
**Freshness Gate:** `main` CP246, HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, comparação `identical`. Seis arquivos em staging presentes, leitura textual; somente este README alterado nesta A5. Nenhum import, compilação, execução de código, teste, SQL, Neon, CI, instalação de driver ou alteração canônica.

### Matriz de verificação textual

| Caminho | Referência na fonte de preparação | Parecer estático |
|---|---|---|
| Opener lança `Exception` | `repository.py:56–61`, `184–194`; `errors.py:14–24` | Exceção de aquisição tipada com causa original; UoW consumida antes da abertura; `safe_to_retry_create_collision` falsa |
| Opener retorna `None` | `repository.py:62–65` | `ConnectionAcquisitionError` sem criar falso diagnóstico de rollback, antes da entrada em `__enter__` |
| Objeto sem `execute`, `rollback` ou `close` chamáveis | `repository.py:66–79` | Rejeitado sem executar cleanup em objeto manifestamente inválido; eventual recurso já criado permanece responsabilidade da fábrica |
| Inspeção de `getattr` dessas três funções lança `Exception` | `repository.py:66–72` | Erro de interface classificado como aquisição, preservando causa; não cria UoW reaproveitável |
| Objeto estruturalmente plausível, mas com sessão incompatível | `repository.py:195–225`, `496–517` | Há tentativa de rollback/close depois do preflight passivo; falha de rollback é tipada e causa original preservada, mas identidade Psycopg, propriedade e semântica não foram atestadas |
| Colisão legítima por PK de cenário | `bridge.py:84–96`; `repository.py:170–182`, `413–425` | Retry ainda requer erro externo `23505/scenario_pkey`, tentativa inicial e rollback + fechamento registrados; aquisição falha não libera retry |
| Exceção antes de `commit()` e fechamento falho | `repository.py:227–292` | Exceções tipadas de rollback/close preservadas estaticamente; resultado operacional não demonstrado |

### SA05-R3 — NOVO: preflight estrutural omite método `commit` (ALTA, bloqueador de aceitação estática)

`DedicatedConnectionFactory.open_new_connection()` verifica somente `execute`, `rollback` e `close` (`repository.py:66–78`); não exige `commit` chamável. Um objeto que implemente as três funções e exponha propriedades passivas compatíveis pode chegar a `PostgresUnitOfWork.commit()` após operações de escrita (`repository.py:385–412`). Se não dispuser de `commit`, a tentativa `conn.commit()` (`repository.py:426–433`) levanta `AttributeError`, capturado como `CommitOutcomeUnknown`, embora **nenhum método de COMMIT tenha sido chamado**. O fluxo de saída para `OUTCOME_UNKNOWN` procede a fechamento sem rollback explícito (`repository.py:227–235`). Para um objeto não comprovadamente Psycopg isso **não atesta o destino de eventuais alterações**. Não se deve confundir falha de interface com resultado remoto incerto.

**Correção recomendada, apenas em futura atividade autorizada:** exigir `commit` chamável na validação de interface da fábrica, de modo a rejeitar esse handle como `ConnectionAcquisitionError` antes de qualquer SQL; verificar também a coerência do contrato de métodos/sessão, sem alegar prova de conexão síncrona Psycopg, propriedade exclusiva, papel, TLS, database ou correção em runtime. A correção deve ser seguida de revisão adversarial separada. Não acrescentar conexão, teste, módulo, dependência nem consulta de preflight nesta atividade.

### Limites e encaminhamento

**SA05-R1 e R2:** mitigações encontradas textualmente para os casos originais, mas não validadas e insuficientes para fechar SA-05. Objetos que imitam propriedades/métodos continuam um risco; a fábrica continua responsável por conexões que abra e não devolva. O contrato nominal não impede reutilização por outro processo/usuário da sessão.

**SA05-R3:** novo bloqueio **ALTO** de coerência de interface e classificação de erro; não declarar SA-05 encerrada nem A2-G4 aceita/publicada. SA-03 parcial, SA-06/07/08/10 abertas; A2-G5/T2-A2 operacional `NOT_AUTHORIZED`. Manter Psycopg 3.3.6 como referência exclusivamente estática. Nenhuma importação, compilação, execução, teste, CI, SQL/Neon, driver instalado, grant, schema ou serviço pago.

**Próxima atividade candidata (novo `Prossiga`): A6 pós-CP246**, correção estática estritamente delimitada de SA05-R3 em `repository.py` e README, seguida de revisão adversarial independente, antes de decidir o conteúdo e a oportunidade do CP247. Aplicar Freshness Gate no início e antes de qualquer publicação; a fonte Python continua em staging, sem persistência canônica.

**STOP — A5 pós-CP246: somente revisão estática, código Python inalterado.**

## A6 pós-CP246 — correção estática pontual de SA05-R3 (método `commit`)

**Estado:** `SA05_R3_STATIC_INTERFACE_GUARD_CANDIDATE_NOT_ADVERSARIALLY_REVIEWED_NOT_PERSISTED`.
**Freshness Gate:** CP246, `main` HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, comparação `identical`. Integridade inicial dos seis arquivos localmente presentes conferida antes da edição. Atividade restrita à leitura e à edição de texto em `repository.py` e neste README; sem importação, compilação, execução do adaptador, testes, instalação de Psycopg, CI, SQL, Neon, conexão, mudança de grants ou publicação GitHub.

### Alteração delimitada

- Em `DedicatedConnectionFactory.open_new_connection()`, o preflight estrutural de métodos chamáveis passa de `("execute", "rollback", "close")` para `("execute", "rollback", "commit", "close")`. A verificação ocorre **antes de devolver a conexão à Unit of Work**, portanto antes de qualquer SQL do adaptador; um handle sem `commit` chamável é classificado como `ConnectionAcquisitionError` e não passa a `PostgresUnitOfWork.commit()`.
- Não se alteraram `PostgresUnitOfWork.commit()`, `__enter__`, `__exit__`, `rollback()`, o SQLSTATE, a classificação de `CommitOutcomeUnknown`, a condição `safe_to_retry_create_collision` nem `bridge.py`.
- Se a avaliação de `getattr(conn, "commit", None)` falhar com `Exception`, o tratamento de erro da própria inspeção permanece em `ConnectionAcquisitionError`, com a exceção original em `__cause__`. Se o atributo existir mas não for chamável, a conexão é rejeitada como handle inválido; nenhuma tentativa de COMMIT é iniciada por esse caminho.

### Limites e próximo passo

**SA05-R3:** mitigação **candidata exclusivamente estática**, ainda não verificada adversarialmente; nenhum PASS atribuído. A presença de quatro métodos chamáveis não prova classe Psycopg, tipo síncrono, comportamento correto de `commit()`, propriedade exclusiva, configuração TLS, identidade de banco/papel ou destino de uma transação remota. O opener continua responsável por recursos que criar e não devolver. A conexão incompleta rejeitada pela verificação não é submetida a rollback/close, pois sua posse e validade não podem ser inferidas de um objeto arbitrário.

**SA-05 permanece ABERTA/ALTA**; SA-03 parcial, SA-06/07/08/10 abertas, SA-02 condicionada a SA-05, SA-11/12 apenas mitigadas/revisadas estaticamente. A2-G4 continua não aceita e não publicada; A2-G5/T2-A2 operacional `NOT_AUTHORIZED`.

**Próxima atividade sob novo `Prossiga`:** revisão adversarial **somente estática** da nova verificação de `commit`, incluindo retorno inválido, exceção de leitura de atributo, uso único da UoW e efeitos sobre `CommitOutcomeUnknown`. Após essa revisão, decidir registro documental CP247 respeitando o protocolo CP194 (atividade por autorização, Freshness Gate inicial e pré-publicação).

**STOP — A6 pós-CP246: correção apenas em staging, sem persistência canônica.**

## A7 pós-CP246 — revisão adversarial independente da guarda SA05-R3 (`commit`)

**Estado:** `SA05_R3_STATICALLY_MITIGATED_ADVERSARIALLY_REVIEWED_NO_RUNTIME_PROOF_NOT_PERSISTED`.
**Freshness Gate:** CP246, `main` HEAD `c7570d842c02949ee0ba1308438e700a01bcda81`, comparação `identical`; seis arquivos locais presentes. Atividade restrita à inspeção de texto e atualização deste README: nenhum import, compilação, execução, teste, CI, driver, SQL, Neon, grant, segredo, custo, alteração canônica ou publicação do código-fonte.

### Matriz adversarial — observação somente textual

| Cenário ou fronteira | Fonte conferida | Conclusão delimitada |
|---|---|---|
| `commit` inexistente ou não chamável no retorno do opener | `repository.py:66–78` | Rejeição por `ConnectionAcquisitionError`, antes de retornar o handle ao repositório/Unit of Work; não se alcança `conn.commit()` por esse caminho |
| Acesso ao atributo `commit` lança `Exception` durante a verificação | `repository.py:66–72`; `errors.py:14–24` | Erro é tipado como aquisição, com a exceção original encadeada em `__cause__`, sem classificar COMMIT como indeterminado |
| Opener retorna `None` ou lança `Exception` | `repository.py:56–65` | Rejeição de aquisição permanece distinta de rollback não confirmado e de COMMIT incerto |
| Quatro métodos encontrados e chamáveis | `repository.py:66–79` | A verificação de forma permite prosseguir para preflight passivo; **não prova** conexão Psycopg síncrona genuína ou funcionamento real dos métodos |
| Preflight passivo após aquisição | `repository.py:184–225`, `496–516` | Observações de `closed`, `autocommit`, `info.status` e `transaction_status` preservadas; exclusividade, identidade de servidor/papel, TLS e banco **não atestados** |
| COMMIT chamado e lança exceção | `repository.py:376–436`; `errors.py:27–46` | Continua classificado conservadoramente como `CommitOutcomeUnknown` apenas após tentativa de invocação de `conn.commit()`; tipo estático não resolve o resultado remoto |
| Possível colisão `23505` durante criação | `bridge.py:84–96`; `repository.py:170–182` | Retry somente sob restrições de método/constraint/tentativa, rollback e close observados; falha de aquisição não apresenta esse caminho |
| Instância de Unit of Work após erro da fábrica | `repository.py:184–194` | Consumo prévio do objeto impede reentrada; não prova ausência de recursos abertos internamente no opener |

### Conclusão e limites

**SA05-R3: mitigada e revisada exclusivamente no código-fonte.** A omissão específica de `commit` chamável foi corrigida. **Não atribuir PASS operacional ou encerrar SA-05.** A verificação usa `callable(getattr(...))`: não assegura identidade de classe, estabilidade posterior da interface, ausência de efeitos colaterais de descritores, semântica transacional ou exclusividade. Uma fábrica que devolva objeto enganoso/incompleto pode continuar violando o contrato sem que o código estático possa provar o contrário. O objeto rejeitado por interface inválida não é automaticamente fechado, porque sua propriedade e validade não estão comprovadas; cabe à implementação da fábrica controlar recursos previamente alocados.

**Não houve novo bloqueador distinto de SA-05/R1–R3 identificado nesta inspeção delimitada.** O risco SA-05 permanece **ABERTO/ALTA** para fábrica exclusiva, identidade de conexão, papel efetivo, banco, TLS, origem e verificação futura independente. SA-02 permanece condicionado a SA-05; SA-03 parcial; SA-06, SA-07, SA-08 e SA-10 abertas; SA-11/SA-12 mitigadas e revisadas apenas estaticamente. A2-G4 ainda não aceita/publicada; A2-G5/T2-A2 operacional `NOT_AUTHORIZED`.

**Próxima atividade, sob novo `Prossiga`:** devido às sete atividades pós-CP246 e ao protocolo CP194, preparar/publicar **CP247 exclusivamente documental**, com inventário SHA-256 atual do staging e classificação explícita de SA-05 e seus R1–R3; não incluir os seis arquivos técnicos no commit. Verificar Freshness Gate no início e imediatamente antes da escrita. Em seguida, prosseguir com triagem estática dos achados SA-07/SA-08/SA-10/SA-06 sob atividades separadas.

**STOP — A7 pós-CP246: revisão adversarial estática encerrada; GitHub inalterado.**
