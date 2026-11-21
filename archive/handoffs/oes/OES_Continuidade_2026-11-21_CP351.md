# OES — CP351 | Django First Q0 → Q1 e preparação do ensaio supervisionado

**Data:** 2026-11-21 (America/Recife). **Antecessor:** [CP350](OES_Continuidade_2026-11-21_CP350.md).  
**Base da elaboração / último SHA confirmado na main:** `72c68b7cbb882e98b0fff086a46ccb4eaa494a89` (squash merge do PR #55). **Na retomada, aplicar Freshness Gate; não presumir que esta base permaneça HEAD.**  
**Natureza:** consolidação documental de decisões e fatos desta conversa; não libera conexão, dados, workflows, HTTP nem gates.

## 1. Resultado técnico e histórico de integração desde CP350

| Incremento | Evidência canônica | Resultado e alcance |
| --- | --- | --- |
| PF-I04-A3 | [PR #51](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/51), `6690723383b5ef5bd4237f77d8b784865d0e65c4` | Navegação documental preparatória; sem liberação conectada. |
| PF-I04-A4.1 | [PR #52](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/52), `47d4fe3fe3a225b5a22113b022e81b0f7ebcd10f` | Adaptador transacional Q1 candidato e testes offline; **o adaptador SQL injetado não é o executor operacional**. Codex relatou 125 testes PASS na entrega. |
| PF-I04-A4.2 | [PR #53](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/53), `9ac5871faedfb008f0d72f900e769a95bb66c755` | Verificador e contrato P2 do writer compartilhado ajustados para exigir UPDATE exclusivamente nas colunas `version_status` e `valid_to` de `core.entity_version`. Codex relatou 398 testes offline PASS. |
| PF-I04-A4.3 | [PR #54](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/54), `c4d1f0fb674e39b946ce80850b8c2ab9d9e8a0fe` | Integração Q1 candidata com Django ORM, transação, locks, recibo e reader; recuperação histórica Q0 adaptada após Q1. Codex relatou 346 testes offline PASS. |
| PF-I04-A4.4 | [PR #55](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/55), `72c68b7cbb882e98b0fff086a46ccb4eaa494a89` | Executor CLI privado supervisionado, bloqueado por fonte, reforço de leitura independente Q1, liberação de conexão Auth antes de espera no lock e [roteiro de ensaio](../../../docs/governance/OES_PF_I04_A44_ENSAIO_Q0_Q1.md). Codex relatou 349 testes offline PASS. |

Todos esses PRs foram examinados e integrados via squash merge mediante autorizações específicas. **Os números PASS acima são relatórios de testes locais do Codex; não representam execução/repetição desses testes pelo ChatGPT nem ensaio PostgreSQL conectado.** CI não registrada nos commits pertinentes não deve ser denominada PASS.

## 2. Decisões arquiteturais ratificadas

1. **Django First, uma aplicação Django:** utilizar Django Auth/sessões, Forms, ORM, `transaction.atomic()`, `select_for_update()` e constraints PostgreSQL antes de desenvolver camadas transacionais paralelas. A aplicação privada sintética tem aliases separados: `default` (Auth), `oes_q0_writer` (writer), `oes_synthetic_reader` (reader). O compartilhamento de writer Q0/Q1 foi aprovado como solução proporcional ao piloto; não criar outro login de escrita para Q1.
2. **Q1 pelo ORM, não pelo adaptador SQL da A4.1:** o SQL injetado existente permanece referência de contrato/testes, não um segundo caminho ativo que duplique mapeamentos. Reutilizar a Unit of Work, o repositório ORM e os recibos existentes, sem criar outro subsistema.
3. **Preservar invariantes Q0, não congelar o código Q0:** após uma transição Q1 válida, a versão Q0 permanece como registro histórico íntegro mesmo quando `superseded`. A confirmação *de uma nova escrita Q0* continua exigindo versão 1 corrente; a recuperação *histórica/replay* aceita Q0 encerrada somente no snapshot independente e com versão 2 `q1_proposed` diretamente vinculada e compatível. Divergências resultam em HOLD/INDETERMINATE; não aceitar recibo histórico como confirmação de outra tentativa com candidato próprio.
4. **Concorrência e commit incerto:** advisory lock da solicitação antes da busca de recibo (a linha pode ainda não existir); bloqueio da versão corrente via `select_for_update()`. Atomicidade Q0 → Q1 e recibo na mesma transação. Após resposta de COMMIT perdida, não repetir escrita automaticamente; recuperar pelo reader independente. A conexão Auth deve ser devolvida antes da espera pelo advisory lock no CLI privado, sem presumir que isso já esteja comprovado por sessão real.
5. **Simplificação proporcional e contraditório técnico:** preservar contratos e evidências; evitar arquitetura paralela, refatoração geral, novos microgates e testes repetidos sem hipótese material. Documento 362 e estratégia ChatGPT–Codex–GitHub seguem normativos; o Codex pode contestar tecnicamente despachos.

## 3. Neon — GRANT mínimo autorizado, efetivamente executado e verificado

**Destino:** projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf` (não a branch production), banco `oes_sandbox`. Executor administrativo `oes_sandbox_owner`, beneficiário `oes_qprep_login`. Autorização específica: `APPROVED — OES / PF-I04-A4.2 / SINGLE_SHARED_WRITER_MINIMAL_COLUMN_GRANT`.

Única mutação administrativa executada nessa operação:

```sql
GRANT UPDATE (version_status, valid_to)
ON TABLE core.entity_version
TO oes_qprep_login;
```

**Preflight**: writer SELECT/INSERT nas cinco tabelas, nenhum UPDATE; reader SELECT sem escrita; identidades sem memberships inesperadas e sem atributos privilegiados, USAGE em `core` e `investigation`. **Postflight**: 10/10 combinações identidade×tabela conformes; no writer, apenas `valid_to` e `version_status` de `core.entity_version` com UPDATE efetivo por coluna; nenhum UPDATE de tabela, DELETE/TRUNCATE nem escrita reader. O GRANT **foi mantido** por autorização expressa após resultado positivo. Nenhum DML científico, alteração de credenciais, papéis, schema, M3-C ou rota HTTP ocorreu nesse procedimento. A verificação foi por consulta administrativa aos privilégios efetivos; não foi uma prova de transação Q1.

Não repetir GRANT/REVOKE ou alterar outros privilégios sem hipótese nova e autorização própria. O GRANT persistente não equivale à liberação da aplicação.

## 4. Executor A4.4 e próximo ensaio

**Arquivos executores:** `applications/oes_web/scripts/pf_i04_a44_trial.py`, `applications/oes_web/evidence/question_orm_q1_dormant.py`, `applications/oes_web/evidence/question_orm_q0_repository_dormant.py`.  
**Roteiro obrigatório:** [OES_PF_I04_A44_ENSAIO_Q0_Q1.md](../../../docs/governance/OES_PF_I04_A44_ENSAIO_Q0_Q1.md).

O CLI propõe nova questão sintética a partir de UUID v4 e oferece fases `register`, `propose`, `review`, `conflict`, com contexto de ator/comando/fase. **A função de liberação de fonte `_require_q1_trial_release()` permanece HOLD incondicionalmente na main**, e o modo Q0 geral permanece bloqueado. A existência do CLI e do roteiro **não autoriza executá-lo** no Neon.

**Próxima unidade de trabalho recomendada:** revisar e preparar artefato estritamente temporário/privado de ativação para um único ensaio conectado, confirmar capacidade e limites para duas sessões writer concorrentes e reader, e submeter **um único despacho operacional integrado** com SHA, operador, usuário e ator sintéticos, UUID v4 novo, destino, janela, pré-condições, STOP, encerramento, verificação independente e preservação de registros. A preparação documental/estática pode continuar proporcionalmente; **nenhuma mutação científica conectada está autorizada por este checkpoint**.

Sequência experimental planejada: Q0 novo e readback; duas propostas Q1 concorrentes com mesma chave antes de recibo, demonstrando espera real e um único commit; replay e fingerprint divergente; reader valida Q0 superseded + Q1 current + recibos; encerramento de processos e retorno a HOLD. A injeção de falha real de COMMIT não faz parte do ensaio descrito; apenas mocks offline a cobriram. Uma ausência de resposta/timeout não comprova rollback, e não autoriza retry. Não reutilizar IDs nem alterar registros M3-C.

**Limitações pendentes:** concorrência, limites de conexão, comportamento transacional/rollback, commit real e readback Q1 ainda não demonstrados em PostgreSQL conectado. O fluxo de autenticação e o perfil privado precisam de verificação antes da janela; não tratar testes em mocks como evidência dessa execução.

## 5. Custódia e gates

M3-C do CP350 permanece encerrada, com registros `OES-M3C-20261118-R01` e `OES-M3C-20261118-Q01` intocados. Preservar branch Neon de segurança `br-silent-dream-b6mvn50u`; restauração/RPO/RTO não demonstrados. Nenhum dado real, pesquisador real, avaliação científica, Q2 persistente, deploy ou serviço pago é abrangido.

**Gates imutáveis:** Marco B `OPEN`; Q0 geral `HARD HOLD`; Q1 conectado `HOLD`; E9 `NO-GO`; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`. HTTP mutante permanece em `423`; `_require_release()` segue HOLD. Sem promoção científica/operacional.

## 6. Forma de trabalho e retomada

**Documentos canônicos a ler primeiro**, nessa ordem:
1. [Ponteiro de continuidade](README.md) e **este CP351**.
2. [STATE.md](../../../STATE.md) e `main` (Freshness Gate).
3. [Documento 362 — simplificação proporcional](../../../docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md).
4. [Estratégia ChatGPT–Codex–GitHub](../../../docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md) e [AGENTS.md](../../../AGENTS.md).
5. [Contrato P2](../../../docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md), [roteiro A4.4](../../../docs/governance/OES_PF_I04_A44_ENSAIO_Q0_Q1.md) e [CP350](OES_Continuidade_2026-11-21_CP350.md) para o marco M3-C.

**Responsabilidades:** ChatGPT coordena, inspeciona patches/revisa, formaliza e persiste; Codex desenvolve e testa sob despacho, publica quando autorizado; GitHub `main` é fonte canônica. Publicação/PR, merge e escrita conectada requerem escopo autorizado; não presumir permissão de `Prossiga`. Freshness Gate antes de editar/publicar; revisão independente de código antes de merge. Não criar tarefas administrativas artificiais nem pedir ao Codex documentação que ChatGPT pode persistir.

**Na abertura de outra conversa:** informar que CP351 é o checkpoint mais recente *após integração à main*, referir os PRs #51–#55, SHA de base `72c68b7cbb882e98b0fff086a46ccb4eaa494a89`, GRANT já executado, A4.4 bloqueado por fonte e ensaio conectado pendente. Ler estes arquivos do repositório e identificar HEAD real antes de qualquer despacho. **Se CP351 estiver apenas em branch/PR não integrado, CP350 continua o ponteiro oficial da main; concluir revisão/merge documental somente com autorização apropriada.**
