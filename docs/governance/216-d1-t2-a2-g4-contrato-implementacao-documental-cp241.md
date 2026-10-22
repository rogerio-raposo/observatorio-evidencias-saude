# Documento 216 — D1/T2-A2: contrato documental candidato do adaptador PostgreSQL A2-G4 (CP241)

**OES | 2026-10-22 | REVISED_DOCUMENTARY_CONTRACT_CANDIDATE | A2-G4/G5 E IMPLEMENTAÇÃO T2-A2 NOT_AUTHORIZED**

## 1. Autoridade, proveniência e alcance

Este documento consolida as quatro atividades **exclusivamente documentais A1–A4 pós-CP240**: proposta inicial de contrato, revisão adversarial (RA-01–RA-10), consolidação revisada e avaliação de suficiência (RF-01–RF-05). O CP240, Documentos 197, 205–207 e 211–215, o código de `prototypes/d1/` e `prototypes/d1_t2/a1/` são a base documental. A aprovação A2-G1 é **condicional e documental**; A2-G2/P1, P2, E e A2-G3 foram encerrados somente nos respectivos escopos expressamente aprovados.

**Classificação final:** `SUFFICIENT_WITH_FINAL_REFINEMENTS_FOR_DOCUMENTARY_PERSISTENCE`. Trata-se de **contrato candidato**, e não de aprovação, implementação, teste, validação operacional ou promoção de gate. `A2-G4`, `A2-G5` e implementação `T2-A2` permanecem `NOT_AUTHORIZED`. As etiquetas A2-G1–G6 são auxiliares e não gates oficiais.

Nenhuma operação SQL, Neon, CI, instalação, nova conexão, fixture, mudança de role/ACL, implantação ou acesso a dados reais foi executada pelas atividades A1–A4. Resultados de testes T1 (36) e T2-A1 (75, incluindo T1) são **históricos**, não reexecutados neste bloco.

## 2. Fronteira e arquitetura candidata

Objetivo futuro, somente se autorizado em ato próprio: um adaptador PostgreSQL estritamente sintético para `create_scenario`, `start_cycle`, `register_signal`, `record_assessment` e `close_cycle`, com persistência transacional, concorrência, idempotência entre reinícios, confirmação incerta, replay e descarte delimitado.

Ambiente reservado: Neon Free, projeto `oes-d1-t2-a2-synthetic` (`tiny-pond-20086371`), branch `synthetic-main` (`br-divine-grass-b63wlpcb`), banco `oes_t2a2_synthetic`, PostgreSQL 18, schema `oes_t2a2_proto`. **Não tocar em `oes-sandbox`.** Papel da aplicação `oes_t2a2_app` somente; `oes_t2a2_runtime` proibido e `oes_t2a2_owner` não pode ser runtime.

Objetos já documentados em CP239: `scenario` (PK `scenario_id`, `revision`, `state` JSONB, `synthetic`); `event` (PK composta `scenario_id,sequence`, FK, `kind`, `payload` JSONB); `receipt` (PK composta `scenario_id,request_id`, FK, `fingerprint`, `response` JSONB, `revision`). Restrições vigentes não demonstram coerência completa entre tabelas. Não propor automaticamente novas tabelas, colunas, índices, triggers, funções, migrações históricas, RLS ou API.

**Camadas:** (i) regras de domínio existentes em T1, (ii) orquestração adaptada da ponte T2-A1 sem transportar leituras fora da Unit of Work, (iii) persistência PostgreSQL em pacote experimental separado sob `prototypes/d1_t2/`. Não alterar `prototypes/d1/` ou `prototypes/d1_t2/a1/` por conveniência. A cópia `t1_monitor_reference.py` está sob controle de equivalência com `prototypes/d1/monitor.py`; evitar novas bifurcações silenciosas.

## 3. Interface de repositório e Unit of Work

Contrato lógico proposto, não implementação:
- `begin_command(scenario_id, request_id, fingerprint)`: abrir transação/UoW e fixar identidade, sem commit implícito;
- `lock_or_resolve_scenario`: bloquear cenário existente antes das leituras dependentes ou executar rota específica de criação;
- `find_receipt`: consultar recibo e conferir fingerprint no contexto protegido;
- `read_scenario` e `list_events`: ler estado/revisão e log **na mesma transação/conexão**, sem chamada externa ao contexto de UoW;
- `stage_scenario`, `append_event` e `stage_receipt`: preparar as três alterações;
- `commit`: confirmar exclusivamente o conjunto íntegro;
- `rollback`: reverter tentativa não confirmada;
- `read_consistent_snapshot`: leitura independente consistente para snapshot/replay, sem mutações.

Impedir uso após fechamento, reentrada incompatível, commit duplo, commit parcial e liberação de conexão com transação aberta. Erros e cancelamentos devem fechar/reverter a transação quando o resultado for conhecido; desconexão em COMMIT exige classificação específica. Preservar APIs e parâmetros dos cinco comandos.

A `bridge.py` T2-A1 chama `repo.list_events(scenario_id)` fora da UoW: proteção por `RLock` de memória **não** fornece garantia entre conexões/processos. O adaptador deverá refatorar **somente a orquestração experimental** para realizar a leitura dentro da fronteira protegida.

## 4. Escrita de cenário existente: isolamento e revisão

**Hipótese candidata:** transação `READ COMMITTED`, bloqueio transacional da linha `scenario` **antes** de ler recibo, estado e eventos dependentes, seguido de verificação da revisão esperada. Para cada novo comando: validar input sintético, iniciar UoW, bloquear cenário, ler visão protegida, conferir recibo/fingerprint, validar coerência, executar domínio em cópia, preparar estado+um evento+um recibo, confirmar conjuntamente ou reverter.

`READ COMMITTED` não oferece snapshot MVCC fixo entre todas as instruções; a coerência lógica pressupõe que **todas as escritas pertinentes ao cenário obedeçam ao mesmo bloqueio**, sem escrita externa arbitrária e sem leituras dependentes anteriores ao bloqueio. A eventual utilização de `UPDATE ... WHERE revision = expected_revision` deve comprovar exatamente uma linha afetada; resultado incompatível é conflito, não atualização silenciosa. Os privilégios CP240 permitem SELECT/INSERT nas três tabelas e UPDATE **somente** `scenario.revision` e `scenario.state`; a adequação do bloqueio e do driver requer prova posterior.

Para leituras independentes de snapshot/replay, `REPEATABLE READ READ ONLY` é candidato para garantir visão estável; não misturar essas leituras com commits de outras transações sem identificar revisões.

## 5. Criação concorrente e colisões

`SELECT FOR UPDATE` não bloqueia cenário inexistente. A criação deverá competir por `scenario.scenario_id` único e confirmar, na mesma transação, `scenario`, primeiro `event` e primeiro `receipt`.

Em colisão esperada de chave única: reconhecer a **constraint específica** e o contexto; reverter a tentativa inteira; iniciar transação nova; bloquear o cenário existente e reavaliar recibo, fingerprint e identidade. Se request e fingerprint coincidirem, retornar snapshot **corrente** protegido. Se o request for igual e fingerprint divergente, preservar `RepositoryConflict` conforme a ponte T2-A1; se for novo request para cenário existente, preservar `DomainError`. Outras violações `23505` não devem ser convertidas genericamente em criação duplicada.

Não introduzir locks globais, tabelas auxiliares ou `SERIALIZABLE` como pressuposto nesta versão. Ausência de contiguidade ou incoerência de estado deve interromper sem reparo automático.

## 6. Atomicidade, revisão, eventos e recibos

Para cenário íntegro iniciado pela criação: revisão = 1 na criação e incrementa exatamente 1 por **comando novo confirmado**; exatamente um evento novo por comando; `event.sequence` percorre 1..revision sem lacunas; `receipt.revision` do comando novo coincide com a revisão confirmada; existe exatamente um recibo lógico por comando novo. Assim, neste modelo restrito de cinco comandos, `revision` = quantidade de eventos confirmados = quantidade de recibos íntegros.

A chave de `receipt` preserva `(scenario_id,request_id)`, mas **não** garante unicidade de revisão ou correspondência com cada evento. Essas invariantes exigem validação na lógica transacional e no replay. O campo Python `state.events[*].data` corresponde semanticamente a `event.payload`, mediante conversão controlada; igualdade deve ser comparada após normalização compatível e ordenação por sequência.

As três escritas confirmam **numa única transação**. Falha conhecida antes do commit exige rollback integral, sem estado, evento ou recibo parcial. Repetições idempotentes nunca incrementam revisão.

## 7. Idempotência e semântica histórica

Fingerprint **inalterado**: SHA-256 sobre `encoded(payload).encode("utf-8")` do Python legado. Não recalcular a partir do texto JSONB produzido pelo PostgreSQL.

- `create_scenario` repetido com mesmo request/payload devolve **snapshot corrente** obtido sob visão protegida.
- Os demais comandos repetidos com mesmo request/payload devolvem a resposta originalmente persistida.
- Request repetido com payload diferente falha sem efeitos, preservando a diferença intencional `RepositoryConflict` (ponte T2-A1) / `DomainError` (T1 direto).
- Criação de cenário existente com **novo** request deve ser `DomainError`.
- Não alterar `pending` (vedada segunda avaliação do sinal), baseline sintético, conclusão científica sintética imutável ou os quatro estados de projeção distintos.

**Limite RF-02:** `Receipt.response: Any` no repositório genérico T2-A1 não equivale a suporte a objetos Python arbitrários pelo `receipt.response JSONB`. Garantir compatibilidade observável dos cinco comandos sintéticos, com testes diferenciais; não alegar equivalência para todo `Any`. O JSONB aceita valores escalares JSON válidos, não apenas objetos. Especificar e testar precisão numérica, Unicode, tipos serializáveis, estruturas aninhadas e valores incompatíveis. Rejeitar ou classificar explicitamente o não representável; nunca modificar silenciosamente a interface T1/T2-A1.

## 8. Commit incerto, recuperação e exceções

Classificações internas candidatas: `COMMITTED_CONFIRMED`, `ROLLED_BACK_CONFIRMED` e `OUTCOME_UNKNOWN`. Desconexão durante COMMIT pode deixar confirmação indeterminada. **Não pressupor rollback e não efetuar retry cego.**

Após recuperar conectividade, consultar recibo por cenário/request em conexão apropriada e comparar fingerprint, resposta e revisão com as invariantes. Recibo compatível e íntegro poderá fundamentar confirmação; ausência imediata ou indisponibilidade contínua não comprova rollback. Nesse caso, manter `OUTCOME_UNKNOWN` até evidência suficiente ou intervenção delimitada. Não inventar sucesso nem falha definitiva.

**RF-03 pendente antes da implementação:** especificar representação Python de `OUTCOME_UNKNOWN`, tratamento de conectividade, cancelamentos e limites de reconciliação sem substituir indevidamente `DomainError` ou `RepositoryConflict`.

Mapear erros PostgreSQL por SQLSTATE **e contexto/constraint**: `23505` somente quando colisão reconhecida; `40001` e `40P01` permitem retry delimitado da transação completa após aborto conhecido; `55P03` exige política controlada de lock; `57014` demanda classificação por estágio; classe `08` pode indicar incerteza; `25P02` exige rollback antes de reutilização; `42501` interrompe sem elevar grants. Retry nunca incluir efeitos externos não idempotentes e deve ter limite, backoff e timeouts expressos antes da execução. Não converter todo erro de banco em `RepositoryConflict`.

## 9. Replay determinístico e divergência

Obter `scenario`, `event` ordenados e `receipt` na mesma visão transacional read-only. Validar contiguidade, revisão, unicidade lógica e quantidade de recibos, correspondência de `state.events` à tabela `event`, fingerprint armazenado, e consistência das revisões. Reconstruir o estado pelo núcleo T1 **em memória**, comparar snapshot completo com o estado persistido e sinalizar divergências sem autocorreção ou efeitos persistentes.

Replay não prova resistência criptográfica a adulteração coordenada. Não confundir detecção de divergência local com auditoria independente.

## 10. Segurança, dependências e descarte

`oes_t2a2_app` deve permanecer o único papel de execução de aplicação. A criação estrutural CP239 e grants CP240 estão documentados, não homologados para segurança de produção. `oes_t2a2_owner` mantém capacidades administrativas elevadas; `oes_t2a2_runtime` é proibido. `PUBLIC` não tem USAGE/CREATE no schema na última verificação; `PUBLIC CONNECT/TEMP` no banco persiste como ressalva distinta. ACL não protege integralmente semântica contra SQL arbitrário no papel app.

Não ampliar permissões para corrigir defeitos; não executar `DELETE`/`TRUNCATE`, `UPDATE` de `event`/`receipt`, DDL, ALTER ROLE, GRANT/REVOKE, nem reutilizar infraestrutura canônica. Usar SQL parametrizada, nomes de objetos explicitamente qualificados, não registrar segredos/URLs sensíveis, e utilizar somente dados fictícios. `synthetic:true` e prefixo `synthetic:` não provam por si a ausência de informação real. Os limites de TLS observados anteriormente são do cliente Psycopg→endpoint (verify-full), **não** TLS ponta a ponta até o backend nem configuração TLS do plugin Neon.

Descarte, inclusive qualquer uso de owner ou DROP, exige autorização administrativa independente. Nenhum rollback ou descarte foi executado neste bloco. A política financeira transversal Doc 211 permite consumo proporcional em Free **dentro de atividades tecnicamente autorizadas**, sem permitir contratação, upgrade, cartão ou cobrança sem aprovação explícita.

## 11. Achados adversariais A2 e refinamentos A4

| ID | Severidade | Controle incorporado / situação |
|---|---|---|
| RA-01 | CRITICAL | Bloquear antes de leituras dependentes e impor protocolo comum de escrita; **não testado** |
| RA-02 | HIGH | Colisão de criação com rollback, transação nova e rechecagem de recibo; **não testado** |
| RA-03 | HIGH | Snapshot corrente em criação idempotente, dentro da UoW; **não testado** |
| RA-04 | HIGH | Revisão, sequência, recibos e estado cruzados; **não testado** |
| RA-05 | CRITICAL | Confirmação incerta e reconciliação, sem rollback presumido; **interface pendente** |
| RA-06 | HIGH | SQLSTATE contextual preservando exceções históricas; **não testado** |
| RA-07 | MODERATE | Fingerprint Python e compatibilidade JSONB delimitada; **não testado** |
| RA-08 | HIGH | Cobertura lógica de recibos/revisões e replay; **não testado** |
| RA-09 | HIGH | Ciclo de vida e retries delimitados; **parâmetros pendentes** |
| RA-10 | MODERATE | Ameaça limitada, descarte segregado e sem grants extras; **não homologado** |

RF-01 esclarece limites de `READ COMMITTED`; RF-02 delimita `Any` vs. JSONB; RF-03 reserva contrato de erro incerto; RF-04 exige retries transacionais e colisão específica; RF-05 separa implementação, testes e descarte. Todos são **refinamentos documentais**, não PASS operacional.

Os achados F01–F07 dos Docs 205–206 continuam `DOCUMENTARILY_ADDRESSED_NOT_OPERATIONALLY_VALIDATED`; L1–L4 e os oráculos O-01–O-10 continuam condicionantes. O preflight e as concessões em CP237–CP240 não validaram transações da aplicação, replay ou durabilidade.

## 12. Matriz de provas futuras — NÃO EXECUTADAS

| Oráculo existente | Evidência futura necessária | Relação com revisão |
|---|---|---|
| O-01 | Snapshot/concorrência sem revisão mista | RA-01, RA-03 |
| O-02 | Criação concorrente única | RA-02 |
| O-03 | Repetição, fingerprint conflitante e semânticas | RA-02, RA-03, RA-06 |
| O-04 | Atomicidade sob falhas entre operações | RA-04 |
| O-05 | Divergência JSONB/log e replay | RA-04, RA-07, RA-08 |
| O-06 | Commit incerto, reconciliação e não duplicação | RA-05, RA-09 |
| O-07 | Negativa de DDL/privilégios da aplicação | RA-10 |
| O-08 | Persistência após reinício de processo Python | RA-04, RA-08 |
| O-09 | Regressão T1 36 + T2-A1 39 e diferencial T2-A2 | RA-03, RA-06, RA-07 |
| O-10 | Descarte só de recursos isolados autorizados | RA-10 |

Reexecuções e testes não podem ser declarados PASS antes de resultados observáveis e evidência registrável. Distinguir reinício Python, interrupção de banco/rede, falha de armazenamento e failover. Os critérios E01–E12 do Documento 197 permanecem candidatos e não pós-condições aprovadas.

## 13. Condições para futura deliberação A2-G4

Antes de implementar, submeter **ato expresso, específico e independente** com:
1. Diretório e lista fechada de arquivos a criar, sem alterar legados;
2. Driver/versão, dependências, instalação e uso de credenciais sem exposição;
3. Interface UoW, protocolos de locking/isolamento e criação concorrente;
4. Contrato de `OUTCOME_UNKNOWN`, classificação de erros e reconciliação;
5. Política concreta de conexão, timeout, retry e limites;
6. Compatibilidade observável e decisões RF-02 para JSONB;
7. Fronteira técnica de código **separada** de SQL/Neon e testes A2-G5;
8. Critérios de STOP, rollback e descarte futuro;
9. Freshness Gate anterior a qualquer commit, sem HEAD divergente;
10. Proibição de novos grants, alterações no banco/infra, dados reais, CI remota, custos ou promoção de gates sem outra autorização.

Este documento **não** concede essa autorização e não serve como licença implícita para editar código, conectar ao banco ou executar testes. A revisão final de suficiência documental não equivale a `IMPLEMENTATION_READY`.

## 14. Estado, publicação e ponto de retomada

T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 PASS históricos); T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 PASS históricos incluindo T1); A2-G1 aprovação somente documental condicional; A2-G2/P1/P2/E e A2-G3 concluídos exclusivamente em seus escopos; **A2-G4/G5 e T2-A2 NOT_AUTHORIZED**. Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`. D0 editorial/documental encerrado → D1 sintético prioritário → D2 factual condicionado → governança operacional completa posterior.

**Próxima atividade, somente após novo `Prossiga`:** avaliar documentalmente a suficiência de um pacote de decisão **estrita** para eventual autorização A2-G4; não aprovar nem implementar automaticamente. O proprietário decidirá o escopo em ato separado. **STOP.**
