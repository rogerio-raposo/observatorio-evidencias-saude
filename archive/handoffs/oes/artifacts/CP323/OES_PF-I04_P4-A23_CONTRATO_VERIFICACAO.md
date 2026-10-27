# OES — PF-I04/P4-A23 | Verificador independente de privilégios v1 (documental)

**Data:** 2026-10-27. **Estado:** `CANDIDATE_READ_ONLY / NOT_EXECUTED / VALIDATION_PENDING / HOLD`. **Checkpoint de referência:** CP322. O Freshness Gate confirmou que o `main` corresponde ao commit `3186476599a750d5e9eaeb184b6b59f3c8af50a8` no início da atividade. Este artefato não autoriza Neon/SQL, roles, GRANT, REVOKE, SET ROLE, Django, HTTP ou deploy.

## Artefato

`OES_PF-I04_P4-A23_VERIFICADOR_PASS_HOLD_CANDIDATO.sql`: uma única instrução `WITH ... SELECT`, com leitura de catálogos `pg_catalog`, funções de privilégio e ACLs. Sem `SELECT` em dados de usuários, sessões, perguntas ou entidades Q0. **Só poderá ser usada mediante autorização READ ONLY exclusiva**, em nova sessão administrativa no projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, executor `oes_sandbox_owner`. Esta instrução descreve o estado *pretendido após* um Bloco A futuramente autorizado e efetivado; antes dele, o resultado esperado é **HOLD**, e não erro do projeto.

## Saída e critério de decisão

O primeiro registro é `SUMMARY / GLOBAL_POSTFLIGHT`, contendo:
- `actual` no formato `<N> mismatches / <M> checks`;
- `passed` booleano e `overall_status` igual a `PASS` somente quando `failed_count=0` e `check_count>0`.

As demais linhas expressam uma expectativa (`check_group`, `subject`, `expected`, `actual`, `passed`) por objeto e operação. `NULL` em uma expectativa é tratado como falha, inclusive ausência de objetos. Se a instrução resultar em erro de sintaxe, falha de consulta, timeout, interrupção ou resultado incompleto, o processo é **HOLD**; não existe `PASS` presumido. **O `PASS` não comprova que o script mutante foi executado com atomicidade**, apenas que o estado catalogal observado coincide com o contrato limitado.

## Matriz coberta

1. Identidade administrativa da consulta, banco, CONNECT do runtime.
2. Atributos administrativos de `oes_runtime` e `oes_django_migrator`.
3. Associação original OID `155649`, grantor `cloud_admin`, ADMIN=true/INHERIT=false/SET=false; contagem 1 entre owner e migrador; zero memberships do runtime; capacidade owner->migrador SET/USAGE false, MEMBER true.
4. Schemas `oes_app`, `core`, `investigation` com proprietário esperado e USAGE/CREATE exatos; `public` USAGE=true/CREATE=false na baseline.
5. Inventário de **nove tabelas Django**, incluindo `django_migrations`, e **cinco Q0** com proprietário exato; objetos adicionais do tipo tabela em `oes_app` provocam HOLD.
6. Oito privilégios de tabela por objeto: SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER e MAINTAIN; em cada um, privilégio efetivo e GRANT OPTION separados.
7. Quatro privilégios de coluna por atributo não descartado: SELECT, INSERT, UPDATE e REFERENCES; UPDATE permitido somente na coluna `auth_user.last_login` e nas colunas de `django_session`; SELECT nas colunas das sete tabelas Django Auth e `django_session`. Direitos Q0 negativos.
8. Existência das colunas `auth_user.last_login` e `auth_user.password`.
9. Inventário e proprietário de **oito sequências Django**, sem USAGE/SELECT/UPDATE efetivo nem GRANT OPTION.
10. ACLs **diretos** ao `oes_runtime`: exatamente onze concessões de tabela pelo migrador, uma concessão de coluna `auth_user.last_login` pelo migrador e uma concessão USAGE em `oes_app` por `oes_sandbox_owner`; zero ACLs diretos em Q0, outras colunas/schemas e sequências. ACLs adicionais, direitos com GRANT OPTION ou concedentes divergentes provocam HOLD.

## Limites e reservas técnicas

- O verificador **não substitui** preflight antes de mutação, teste de rollback, autorização de uma janela transacional, verificação da sessão SQL Editor ou o postflight dentro da transação.
- Não verifica conteúdo de tabelas Django/Q0, senhas ou atributos de uma conta Django; não habilita runtime conectado. Nenhum direito foi concedido nesta atividade.
- O universo é de objetos Django e Q0 explicitamente delimitados; não é auditoria universal de triggers, funções, políticas RLS, extensões, privilégios TEMP no banco ou outros schemas/tabelas não especificados.
- A presença de um privilégio efetivo pode decorrer de `PUBLIC`. A verificação de ACLs diretas **não equivale à auditoria de todas as ACLs globais**; a matriz de privilégios efetivos cobre permissões inesperadas nos objetos alvo. Se surgir diferença de `PUBLIC`, o verificador marca HOLD nos pontos relevantes.
- `has_column_privilege` pode resultar verdadeiro em decorrência de privilégios de tabela; por isso os dois níveis são testados separadamente.
- **Não houve execução da consulta em PostgreSQL 18 ou em qualquer banco**, nem validação por parser SQL PostgreSQL. A verificação estática local não justifica aprovação operacional.
- O script transacional P4-A19 está SUPERADO; P4-A21 permanece HOLD e sem execução. A completude do verificador não remove essas travas.

## Próximo passo recomendado

P4-A24: auditoria estática adicional da consulta e elaboração de um gate próprio READ ONLY para validação controlada no Neon, somente após aprovação nominal. Preferir validação dos casos **negativos esperados antes dos GRANTs**; uma prova do resumo PASS só poderá ocorrer após uma operação Bloco A separadamente aprovada e confirmada. Preservar checkpoints proporcionais, com CP322 vigente até nova publicação.

**Gates inalterados:** Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED. Sem pesquisadores vinculados.
