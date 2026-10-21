# Documento 197 — D1-T2-A2: especificação documental consolidada e critérios de autorização (CP222)

**OES | 2026-10-21 | CANDIDATE DOCUMENTARY SPECIFICATION | T2-A2 NOT_AUTHORIZED**

## 1. Autoridade e escopo
Este documento consolida três atividades exclusivamente documentais A1 (desenho), A2 (revisão adversarial REVISE, achados F01–F05) e A3 (especificação integrada), a partir de CP221 e dos Documentos 169, 173, 189, 190, 194, 195 e 196. Nenhuma implementação, teste, driver, SQL, PostgreSQL, Neon, CI, cloud ou consulta factual foi executada nestas atividades.

**Estados preservados:** T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 testes históricos PASS), T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (39 testes próprios + 36 de T1 = 75 históricos PASS); **T2-A2 = NOT_AUTHORIZED**. Nenhuma homologação científica, equivalência à View SQL canônica, alteração de gate ou autorização D2.

## 2. Objetivo mínimo e arquitetura candidata
Demonstrar futuramente, **somente se especificamente aprovado**, durabilidade, atomicidade, idempotência entre reinícios, concorrência interprocessos, confirmação incerta e replay com PostgreSQL **local isolado gratuito** e dados integralmente fictícios.

Três camadas: (i) regras de domínio e cinco comandos Python existentes; (ii) interface de repositório/Unit of Work transacional; (iii) adaptador PostgreSQL para integridade, persistência e isolamento. Manter `prototypes/d1/` e `prototypes/d1_t2/a1/` inalterados; novo diretório experimental separado apenas após autorização.

**Modelo mínimo lógico (sem DDL):**
- `Scenario`: `scenario_id` único, revisão controlada, estado sintético serializado.
- `Event`: `(scenario_id, sequence)` único, ordem contígua por cenário, tipo e payload.
- `Receipt`: `(scenario_id, request_id)` único, fingerprint, resposta original e revisão confirmada.

Estado, evento e recibo devem confirmar **na mesma transação**. Revisão, último evento confirmado, recibo e estado reconstruído por replay devem ser consistentes. Normalização de ciclos/sinais/avaliações só se exigida por evidência/invariantes; não migrar SQL canônico nem instalar as 36 migrations.

## 3. Fluxo transacional e concorrência
Por comando: validar envelope sintético; iniciar transação/UoW; proteger identidade do cenário; consultar recibo; ler estado **e eventos na mesma visão consistente**; aplicar domínio Python a cópia; preparar estado, evento e recibo; confirmar conjuntamente, ou reverter integralmente; devolver resposta confirmada ou classificar confirmação incerta.

Para cenário existente, a **estratégia candidata** é bloqueio transacional por cenário com revisão monotônica complementar. Para criação concorrente, impor unicidade de ID e tratamento explícito de colisão: não presumir bloqueio de linha inexistente. Escolher estratégia e nível de isolamento antes de executar, verificando deadlocks, retries e não duplicação de efeitos. Leituras para projeção/replay não podem combinar revisões diferentes.

Perda de conexão durante commit não autoriza inferir rollback: reconectar e reconciliar por recibo persistente. Se o banco continuar indisponível, registrar resultado **indeterminado**, sem alegar sucesso ou falha. Distinguir rollback confirmado, commit confirmado e resultado incerto.

## 4. Compatibilidade vinculante e limites científicos
Preservar literalmente os contratos T1/T2-A1 aprovados: cinco comandos `create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`; criação repetida retorna **snapshot corrente**, enquanto os outros recibos preservam resposta original; `pending` não admite nova avaliação do mesmo sinal; diferenças `RepositoryConflict`/`DomainError` explicitamente mapeadas; request ID repetido com payload divergente rejeitado sem efeito; conclusão científica sintética original e baseline imutáveis; quatro estados da projeção distintos. Mudar essas semânticas exige decisão autônoma, nunca correção silenciosa. Prefixo `synthetic:` é rótulo de fixture, não prova de proveniência factual.

Não declarar equivalência à View SQL canônica, validação científica/operacional, trilha criptograficamente inviolável, segurança multiusuário, recuperação de desastre ou prontidão para publicação.

## 5. Requisitos essenciais de aceitação
| ID | Exigência |
|---|---|
| E01 | Base/namespace exclusiva, artificial, identificável e descartável |
| E02 | Custo incremental zero comprovado; nenhum serviço cobrável |
| E03 | Identidade, revisão e sequência protegidas contra duplicação/lacunas confirmadas |
| E04 | Atomicidade completa de estado, evento e recibo |
| E05 | Idempotência persistente em reinício e repetição conflitante |
| E06 | Consistência sob concorrência entre conexões e processos |
| E07 | Durabilidade verificada após reinício de aplicação; servidor se autorizado |
| E08 | Replay determinístico e divergência detectável |
| E09 | Contrato e semânticas T1/T2-A1 preservados |
| E10 | Regressão dos 36 testes T1 e 39 T2-A1 |
| E11 | Segredos protegidos, privilégio mínimo, dados exclusivamente sintéticos |
| E12 | Descarte verificado e limites documentados |

**Desejáveis não bloqueantes:** métricas simples, maior volume de fixtures, comparação de políticas de locking, empacotamento portável e preparação meramente documental de cloud Free.

## 6. Matriz futura de testes — NÃO EXECUTADA
| Grupo/IDs | Ensaios e oráculos |
|---|---|
| A01–A04 | Falhas nos estágios de escrita/antes do commit: nenhum estado, evento ou recibo parcial |
| I01–I03 | Repetição pós-reinício; request conflitante; criação repetida retorna snapshot corrente |
| C01–C04 | Criações simultâneas (uma efetiva), pedidos iguais (efeito único), escritas conflitantes e cenários independentes |
| R01–R04 | Recuperação pós-reinício, dois ciclos, divergência de log detectada, recibos duráveis |
| F01 | Perda de conexão junto ao commit: reconciliação por recibo ou incerteza explícita |
| P01 | Regressão integral 75/75 histórica reexecutada na futura validação |
| S01–S02 | Origem não sintética rejeitada; limpeza verificável |
| A2-T01 | Estado e log divergentes detectados por replay |
| A2-T02 | Criação concorrente de cenário ausente resulta em uma só criação |
| A2-T03 | Leituras concorrentes não misturam revisões |
| A2-T04 | Confirmação incerta/reconexão não duplicam evento/recibo |
| A2-T05 | Reinício do processo após commit preserva estado/recibo |
| A2-T06 | Testes diferenciais integrais T2-A1/T2-A2 sem divergência não aprovada |

Não confundir reinício de processo, reinício do servidor, indisponibilidade de rede e falha física de armazenamento. Teste de mutação controlada não demonstra resistência a adulteração coordenada. Registrar resultados negativos, HEAD, versões, configurações não sensíveis, evidências de recuperação e de descarte.

## 7. Preflight, fronteira financeira e segurança
**Preflight inicial somente leitura**, após autorização para a atividade cabível: conferir HEAD, PostgreSQL local e versão realmente disponíveis, driver necessário, isolamento de banco/schema, credenciais com menor privilégio, inexistência de dados factuais, recursos compartilhados, possibilidade de rollback e limpeza, custo incremental zero. Não inferir que licença PostgreSQL sem tarifa elimina custo operacional.

**Instalação, início de serviço, configuração privilegiada, drivers, criação de banco/role/objeto e qualquer execução SQL dependem de autorização operacional específica, concretamente delimitada.** Uma aprovação de análise não libera essas ações. Não reutilizar instância científica canônica, migrations, dados reais ou Neon. Proibir senha/URL sensível em documentação, logs ou conversa.

## 8. STOP conditions
Parar diante de autorização ausente/ambígua, possível cobrança, isolamento não demonstrado, dependência de schema/migration canônico, mudança semântica não aprovada, escrita parcial, duplicidade/integridade comprometida, confirmação incerta não reconciliável (sem declarar resultado), segredo exposto, dados factuais, descarte impossível ou alteração de infraestrutura compartilhada fora do escopo. Falha corrigível deve permanecer registrada, jamais promovida a PASS.

## 9. Portões de decisão e minuta NÃO APROVADA
Antes de implementação, o proprietário deverá deliberar **separadamente**: D1 experimento PostgreSQL local; D2 runtime/driver/instalação e configuração concreta; D3 operações e matriz de testes permitidas; D4 manter explicitamente Neon, cloud, CI remota, API, deploy, fontes factuais e custo fora do escopo.

**Minuta exclusivamente propositiva — não executar:**

`APPROVED — OES / D1-T2-A2 / POSTGRESQL_SYNTHETIC_LOCAL_EXPERIMENT_ONLY / Autorizar somente após preflight satisfatório e aprovação específica das dependências e operações locais o desenvolvimento e teste de um adaptador PostgreSQL experimental isolado para os cinco comandos sintéticos de T2-A1, com atomicidade, durabilidade, idempotência, concorrência, confirmação incerta, replay, regressão e descarte verificável, preservando T1, T2-A1, semânticas históricas, S1–S6 e todos os gates; sem Neon, cloud, CI remota, implantação, API pública, dados factuais, buscas científicas, migrations canônicas ou serviços pagos; sem instalações privilegiadas ou alteração de infraestrutura compartilhada não aprovadas; qualquer ampliação exige autorização distinta.`

A minuta **não é aprovação**. Mesmo execução futura PASS apenas poderá fundamentar parecer técnico restrito para nova decisão de encerramento, sem promover gates ou fases.

## 10. Continuidade
D0 documental/editorial encerrado → D1 prioritário → D2 factual condicionado → governança operacional completa posterior. Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`, zero pós-condições aprovadas, requisitos `NOT_COLLECTED`, controles de papéis e BRGs bloqueados inalterados.

**Próxima atividade após CP222 e novo `Prossiga`:** revisão editorial/verificação cruzada do Documento 197 e preparação de pacote deliberativo para o proprietário, ainda somente documental e sem presumir autorização de T2-A2. STOP.
