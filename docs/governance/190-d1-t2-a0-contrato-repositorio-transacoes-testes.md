# Documento 190 — D1-T2/A0: contrato de repositório e testes transacionais

**OES | 2026-10-21 | desenho documental exclusivamente | T2 NÃO AUTORIZADO**

Fontes: Documentos 169, 170, 173 e 189; `prototypes/d1/monitor.py` e `TRACEABILITY.md`, HEAD `fa1ba4eeb51571b83e579514caf1e7e3c0bfcc21`. CP218 vigente. Nenhuma implementação, banco, SQL, Neon, CI remota ou implantação foi executada nesta atividade.

## 1. Delimitação e achados do T1

A autorização expressa encerrou **somente T1**, Python sintético local, com 36 testes PASS. T2 continua dependente de aprovação separada. O serviço atual usa acesso direto aos dicionários `repo.scenarios` e `repo.receipts` e faz rollback por cópia de estado: isso não oferece durabilidade nem transações ou concorrência entre processos. A lógica de domínio deve permanecer no Python; o banco futuro deverá assegurar unicidade, persistência, isolamento e atomicidade.

Duas decisões não podem ser escondidas numa mudança de adaptador:
- `create_scenario` registra apenas `scenario_id` no recibo; sua repetição devolve o **snapshot corrente**, que pode diferir do retorno original. Os outros comandos guardam a resposta original. Recomenda-se padronizar o recibo imutável e documentar a mudança comportamental.
- `record_assessment` admite decisão `pending`, mas rejeita nova avaliação do mesmo sinal; `close_cycle` exige avaliações terminais. Logo, uma avaliação pendente não pode ser concluída pelo fluxo T1. Recomenda-se escolher entre impedir `pending` nessa versão ou criar transição explícita, auditada e testada. Não alterar silenciosamente os resultados de T1.

Também, `replay_snapshot` reconstitui eventos com IDs de requisição fictícios; **não recupera** recibos originais. Snapshot `oes.d1.monitor_snapshot/0.1` não equivale à View SQL canônica, nem contém declaração de execução efetiva de PostgreSQL.

## 2. Contrato lógico proposto — não implementado

**Identificador candidato:** `oes.d1.scenario_store/0.1`. Métodos conceituais abaixo não são uma API publicada:

| Método | Responsabilidade |
|---|---|
| `begin_command(scenario_id, request_id, fingerprint)` | Abrir unidade transacional/lock por cenário; contemplar criação de cenário inexistente |
| `uow.find_receipt()` | Buscar recibo imutável do pedido dentro da unidade |
| `uow.read_scenario(for_update=True)` | Ler estado e revisão protegidos contra corrida |
| `uow.stage_scenario(state, expected_revision)` | Preparar estado após validação em Python |
| `uow.append_event(kind, data, sequence)` | Preparar evento único e sequencial |
| `uow.stage_receipt(fingerprint, original_response)` | Preparar resposta original para idempotência |
| `uow.commit()/rollback()` | Confirmar estado, evento e recibo juntos ou desfazer tudo |
| `read_snapshot/list_events/read_receipt` | Consultas sintéticas consistentes, sem efeitos de escrita |
| `purge_test_scenario` | Limpeza administrativa exclusivamente no namespace experimental aprovado |

**Chave idempotente:** `(scenario_id, request_id)`; fingerprint canônico inclui tipo de ação e payload completo. Mesma chave/payload retorna o resultado **original** sem novo evento. Mesma chave/payload divergente retorna erro sem alteração. Recibos sobrevivem a reinício e só entram em vigor junto ao evento e ao estado.

**Sequência obrigatória:** (1) validar dados fictícios e construir envelope; (2) iniciar transação/serialização por cenário; (3) ler recibo; (4) ler revisão/estado e aplicar regras Python numa cópia; (5) preparar estado, evento ordenado e recibo; (6) commit único, rollback em erro; (7) devolver resultado confirmado. Falha na conexão durante commit pode ter resultado **incerto**: consultar recibo antes de repetir. Para criação simultânea, proteger identidade por constraint e estratégia adequada, pois lock de linha inexistente não basta. Concorrência deverá ser testada com conexões/processos independentes, não presumida pelo nível de isolamento padrão.

## 3. Modelo lógico mínimo, sem DDL

| Registro experimental | Chave | Regra |
|---|---|---|
| Cenário sintético | `scenario_id` único | revisão monotônica, estado serializado; baseline e conclusão científica protegidos |
| Evento | `(scenario_id, sequence)` único | sequência sem lacuna confirmada, evento append-only e ordem verificável |
| Recibo | `(scenario_id, request_id)` único | fingerprint + resposta original + revisão do commit, imutáveis |

Candidato para primeira prova: **um estado serializado por cenário + eventos + recibos**, todos confirmados na mesma transação. O log constitui trilha auditável; o estado materializado deve coincidir com o replay, e o recibo é a evidência da resposta idempotente. Normalização adicional de ciclos/sinais/avaliações só se necessária por testes ou constraints. Não usar o schema OES-P1 nem executar as 36 migrations históricas.

## 4. Invariantes e versionamento

- Identidades target/Monitor distintas; `scenario_id` delimita todos os vínculos; `request_id` único por cenário; ordinal de ciclo/sinal e de evento não duplicável.
- `fixture_source` e `source` devem declarar `synthetic:`; isso é apenas rótulo de fixture, não autenticação real. Atores são personagens fictícios.
- Baseline sintético ISO imutável; início de ciclo posterior ao baseline; conclusão científica original e hash não se alteram por decisão de Monitor.
- Estados editorial, operacional, currency do Monitor e currency do alvo permanecem distintos; impactos 1:N sem perda; decisão exige ator/rationale fictícios.
- Replay determinístico; divergência de eventos/estado bloqueia aceitação. Receipts reprodutíveis por consulta durável, não recriados pelo replay do T1.
- Disclosure de execução real de adaptador PostgreSQL exige definição explícita de nova versão/projeção (possível `oes.d1.monitor_snapshot/0.2`), mantendo falsos os campos de View SQL canônica, busca factual, revisão científica e gate de publicação.

## 5. Matriz futura de testes — NÃO EXECUTADA

| Grupo | Cenários mínimos |
|---|---|
| S1 Identidade | criar duas vezes com mesmo ID; trocar alvo; conflitos de versões, ciclos ou sinais |
| S2 Proveniência | origem não sintética; ator fictício; ausência de acesso factual ou origem externa |
| S3 Eventos/idempotência | repetir após reinício; mesmo pedido concorrente; mesmo ID com payload divergente; unicidade de sequências |
| S4 Decisões | impactos múltiplos; conclusão/hash invariáveis; fechamento concorrente; política explícita de `pending` |
| S5 Projeção | comparar snapshots T1/T2 por fixture, baseline e quatro status; disclosure verdadeiro, sem equivalência SQL |
| S6 Replay/isolamento | reconstrução após reinício, corrupções detectadas, cenários distintos, descarte com contagens pré/pós |
| Atomicidade | falhas injetadas entre alterações de estado, evento, recibo e commit; ausência de efeitos parciais |
| Conexão/concorrência | duas conexões/processos; commit de resultado incerto; conflitos serializados ou rejeitados |
| Custos/segurança | sem credenciais em código/logs; ambiente isolado, privilégios mínimos, sem cobrança/upgrade |

Regressão obrigatória dos **36 testes locais de T1**. Testes T2 deverão indicar HEAD, versão de PostgreSQL/driver, comandos, resultado, idempotência entre reinícios, artefatos sintéticos, hashes, escopo de limpeza e riscos residuais. Não registrar senhas, tokens, URLs privadas de conexão ou identificadores pessoais.

## 6. Gates de decisão e recomendações

**Sequência de menor risco:** (A) após autorização expressa, refatorar o núcleo Python para interface de repositório e UoW **ainda em memória**, mantendo regressão T1; (B) após confirmação específica e preflight, implementar adaptador PostgreSQL **local** sintético e executar testes transacionais; (C) avaliar Neon Free apenas em decisão própria. Provas na nuvem, API e T3 permanecem fora do escopo.

**Bloquear avanço** se não houver isolamento da base canônica, runtime local gratuito, tratamento correto de idempotência/commit incerto, rollback, replay, integridade da conclusão ou ausência de custos adicionais. Conflitos semânticos identificados (`pending` e resposta de criação) requerem deliberação antes de codificação; não pressupor aceitação de mudança de contrato.

**Situação:** `T1=CLOSED_SYNTHETIC_LOCAL_ONLY`; `T2=DOCUMENTARY_DESIGN_ONLY/NOT_AUTHORIZED`; `D2` factual posterior; gates, migrations `UNREVIEWED`, pendências científicas e fases históricas preservados. CP218 permanece ponteiro vigente.

**Próximo `Prossiga`:** elaborar texto de autorização estritamente para T2-A1 (extração da interface Python local com testes), submetendo-o ao proprietário **antes** de qualquer execução. STOP.
