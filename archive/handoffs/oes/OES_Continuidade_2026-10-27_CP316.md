# OES — CP316 | Fechamento P3a/P3b Django administrativo no Neon sintético
**Data:** 2026-10-27. **Anterior:** CP315. **HEAD anterior à persistência:** `3c1789c78d4386d46ffd540263c09af715d2fc82`. **Natureza:** checkpoint canônico de continuidade e fechamento técnico delimitado; não é promoção operacional.

## Ponto factual de partida
- Repositório `rogerio-raposo/observatorio-evidencias-saude`, `main`. Fonte de verdade: `archive/handoffs/oes/README.md` → este checkpoint → `STATE.md`, com Freshness Gate na retomada.
- Neon: projeto `weathered-boat-65779510`, branch **sintética não principal** `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), banco `oes_sandbox`; **produção não alterada**.
- PF-I03 sintético Q0→Q1→Q2/roteamento offline `CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY`, CI [40535916973](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40535916973) 201/201 PASS. Não há persistência de Q1/Q2 ou roteamento.
- PF-I04 arquitetura B aprovada: Django Auth/contenttypes/sessions em schema independente `oes_app`; preliminares Docs 315–319 PF-I04, parecer Doc 330, pacote Doc 360 e identidade migradora Doc 361. Numeração de documentos 315–319 e 330 colide entre trilhas; sempre usar caminhos completos.

## P3a — concluído, autorização específica e postflight
- `oes_app` criado vazio por `oes_sandbox_owner` após aprovação nominal P3a do proprietário; sem GRANT, migration ou aplicação nesta etapa. Postflight confirmou schema vazio e owner previsto. Posteriormente P3b o povoou.

## P3b — concluído tecnicamente, sem habilitação operacional
- Proprietário autorizou explicitamente migrations administrativas P3b. Identidade dedicada `oes_django_migrator` foi criada pelo proprietário no Neon SQL Editor com senha definida por ele; retorno informado pelo usuário confirmou LOGIN=true, SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS=false, USAGE/CREATE `oes_app`=true.
- Executor Django 5.2.18 + psycopg 3.3.6, PostgreSQL **18** no Neon; workflow manual `.github/workflows/oes-pf-i04-p3b-django-migrate.yml`, execução [40555198917](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40555198917), commit `a8bd8e7ce825e56dc2794b5b6f0c4e663cd88f25` **PASS**: 15/15 migrations, 40 permissões, `P3B POSTFLIGHT PASS`.
- Postflight **independente** SELECT confirmou: `oes_app` owner `oes_sandbox_owner`; 15 registros `django_migrations`; 40 `auth_permission`; 9 tabelas + 8 sequências em `oes_app`; zero objetos administrativos Django em `public`; 44 objetos de propriedade `oes_django_migrator`.
- Após **autorização específica posterior**, transação no Neon executou exclusivamente `ALTER ROLE oes_django_migrator NOLOGIN` e `REVOKE CREATE ON SCHEMA oes_app FROM oes_django_migrator`; postflight SELECT confirmou `rolcanlogin=false`, CREATE efetivo=false, 15 migrations e 44 objetos do migrador preservados. **Nunca DROP ROLE automaticamente**.
- Proprietário **declarou** exclusão do segredo GitHub Actions `OES_P3B_MIGRATOR_PASSWORD_ONETIME` nesta conversa. É declaração do usuário, não inspeção independente de secrets; não solicitar nem repetir senha.
- **Não reexecutar workflow P3b.** É histórico e falhará ou pode introduzir alterações inadvertidas se reabilitado; proteger por novo gate se for reutilizado algum dia.

## O que permanece bloqueado
- PF-I04/P4 (uso Django autenticado, contas reais, sessões e primeiro Q0 persistente) **NÃO AUTORIZADO**. `DATABASES={}` como padrão na aplicação; runtime PG-A4 só leitura opcional; `DjangoQ0Repository` e `execute_connected_q0()` continuam dormentes/fail-closed. Nenhum write HTTP, deploy ou usuário real.
- Não confundir conclusão técnica das migrations administrativas com operacionalização do piloto, acesso científico, validação por pesquisadores ou E9.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`; Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`. Sem pesquisadores associados.
- Uma identidade Django runtime ainda não foi provisionada e sua matriz de mínimos não equivale à do migrador. Evitar usar owner ou reativar migrador como runtime.

## Ponto exato de retomada
**PF-I04/P4 — somente desenho/preparação não mutante**, incluindo decisão proporcional sobre autenticação/identidade runtime, concessões mínimas em `oes_app`, configuração Django segura, mapeamento preparador↔ator OES e caminho autenticado persistente Q0. Fazer inspeção factual apenas quando necessário; não repetir P3a/P3b nem experimentar novas migrations. Pedir autorização explícita e delimitada antes de DDL/DML/grants/secrets/conexão runtime/HTTP write/deploy/contas. Preferir progressão funcional Django-first e reuso da stack ao invés de novas provas sintéticas isoladas.

## Acordos de trabalho e retomada
- Cada `Prossiga` = uma atividade delimitada; decisões sensíveis exigem `APPROVED` escopado; fail closed e STOP na incerteza.
- Freshness Gate no início e imediatamente antes de commit; atualizar `STATE.md` e `CHANGELOG` somente quando relevantes, checkpoints geralmente após 3–5 atividades ou marco material, sem burocracia redundante.
- Enviar progresso durante tarefas longas; não alegar testes ou commits sem confirmação; preservar custo zero/free quando possível e evitar arquitetura provisória desnecessária. Não recuperar credenciais.
- Na nova conversa, iniciar com Diagnóstico de Continuidade baseado no template canônico `archive/continuity/OES_Template_Abertura_Continuidade.md`, confirmar estado atual e recomendar **uma** próxima atividade. Esta conversa poderá ser declarada encerrada e, nesse caso, não retomar nela sem dupla confirmação do usuário.
