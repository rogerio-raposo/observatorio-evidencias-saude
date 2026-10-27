# OES — CP322 | PF-I04/P4-A17–A20 — alternativa administrativa e correção de contrato transacional

**Data:** 2026-10-27. **Anterior:** CP321. **HEAD-base verificado (Freshness Gate PASS):** `7286728077b71d9bd4ddcaa52d6137986a789aad`. **Natureza:** checkpoint documental; nenhuma autorização de SQL mutante, role, GRANT, SET ROLE, conexão Django, HTTP ou deploy.

## 1. Contexto preservado
- Neon sintético: projeto `weathered-boat-65779510` (`oes-sandbox`), branch `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), banco `oes_sandbox`, executor administrativo `oes_sandbox_owner`. Não utilizar a branch de produção.
- CP321/P4-A13: o responsável criou manualmente `oes_runtime` com senha privada; postflight confirmou LOGIN=true, INHERIT=false, sem poderes administrativos e **zero memberships**. P4-A14: role efetivamente sem direitos nas nove tabelas Django, cinco tabelas Q0 e oito sequências Django; CONNECT ao banco já existente; `oes_app` sem USAGE/CREATE.
- P4-A16: `oes_sandbox_owner` possui GRANT OPTION sobre três schemas e cinco tabelas Q0, **não** sobre nove tabelas Django, que pertencem a `oes_django_migrator`. Papel migrador preservado NOLOGIN/sem CREATE, sem reexecução de migrations. P4-A9: permissão `evidence.prepare_question` cadastrada (ID 41), **não atribuída**. CI offline P4-A11 130/130 PASS, sem prova conectada.

## 2. Atividades novas
### P4-A17 — opções administrativas (somente documental)
- Preferida, **sob condições**, janela administrativa temporária de `SET ROLE` preservando ownership e o migrador NOLOGIN. Rejeitadas como atalhos automáticos: ativar LOGIN do migrador, transferir propriedade, manter poderes administrativos permanentes no owner ou runtime.
- Necessário auditar GRANTOR/ADMIN/INHERIT/SET da associação e demonstrar retirada da concessão temporária por concedente, sem alterar associação original.

### P4-A18 — exatamente um SELECT de pg_auth_members após aprovação nominal
- Associação **única** existente: `membership_oid=155649`, `role=oes_django_migrator`, `member=oes_sandbox_owner`, `grantor=cloud_admin`, `admin_option=true`, `inherit_option=false`, `set_option=false`.
- Conclusão: alternativa de associação adicional por concedente diferente **conceitualmente plausível**, NÃO validada por execução ou autorização de mudança. Associações, roles e privilégios permaneceram inalterados.

### P4-A19 — desenho de uma transação única (somente documental)
- Sequência candidata: BEGIN, preflight fail closed (banco/executor/associação original/ownership/baseline), concessão temporária `SET TRUE` por `oes_sandbox_owner`, `SET LOCAL ROLE oes_django_migrator`, GRANTs mínimos **Bloco A** sobre tabelas Django, restauração a owner, GRANT USAGE no schema `oes_app`, REVOKE da **associação temporária identificada pelo concedente** com RESTRICT, verificações e COMMIT; após commit postflight independente.
- **ATENÇÃO: o SQL integral publicado na resposta de P4-A19 é CANDIDATO SUPERADO E NÃO EXECUTÁVEL.** Não reutilizar/copy-paste. Não foi ensaiado, nem avaliado o executor multicomando e a recuperação sob falhas.

### P4-A20 — revisão crítica que invalida P4-A19 como candidato de execução
- Falha material encontrada: `has_table_privilege(..., 'SELECT, INSERT, UPDATE, DELETE')` com múltiplas operações retorna true se **qualquer uma** for permitida; portanto não comprova todas. Exigir chamadas individuais com AND e resultados positivos **e negativos**, sem aceitar acesso parcial.
- Outros defeitos: preflight de contagem/owner sem inventário exato dos nomes; postflight testa somente parte da matriz; não examina `relacl`, `attacl`, concedentes, grant options, privilégios adicionais, sequências, cinco Q0, todas as colunas; ausência de teste de execução indivisível de sessão; não demonstrada recuperação após erro/commit incerto.
- P4-A20 produziu **propostas READ ONLY, NÃO executadas**: validação individual das 9 tabelas Django (SELECT somente 7 auth, sessions CRUD, migrations sem acesso; `auth_user` sem UPDATE de tabela inteira mas UPDATE apenas da coluna `last_login`) e ACL audit com `aclexplode`; ambas ainda requerem revisão e complementos. Não equiparar privilégio de tabela ao privilégio de coluna.
- Baseline e direitos pretendidos diferem. Mesmo que `oes_runtime` obtenha direitos via Bloco A, não habilitar login conectado, dados reais, usuários ou Q0.

## 3. Matriz candidata Bloco A e limites
- `oes_app`: USAGE ao runtime, nunca CREATE.
- SELECT nas sete tabelas: `auth_user`, `auth_permission`, `django_content_type`, `auth_user_user_permissions`, `auth_group`, `auth_user_groups`, `auth_group_permissions`.
- `django_session`: SELECT/INSERT/UPDATE/DELETE, sem GRANT OPTION.
- `auth_user.last_login`: UPDATE **somente coluna**, sem UPDATE sobre tabela inteira; atualização de `auth_user.password` permanece **não autorizada**, ainda dependente de decisão sobre evolução automática de hash.
- `django_migrations`: nenhum direito; nenhuma sequência Django deve receber USAGE/SELECT/UPDATE. Demais privilégios proibidos (TRUNCATE, REFERENCES, TRIGGER, MAINTAIN, GRANT OPTION) sob inspeção. Cinco tabelas Q0 permanecem sem novos privilégios, assim como schema `core`/`investigation` para runtime; Bloco B adiado.
- Pós-commit deverá confirmar grantors dos ACLs de objeto e coluna, USAGE do schema, todos os positivos/negativos, ownership, papéis `NOLOGIN` e zero memberships de `oes_runtime`.

## 4. Correções e gates pendentes
1. **P4-A19 SQL SUPERSEDED — HOLD.** Não encaminhar para execução nem aprovar como está; primeiro preparar script integral v2 completo, sintaticamente revisado e separado das consultas apenas documentais.
2. Validar especificidades PostgreSQL 18 e canal de execução (uma única sessão/transação, `SET LOCAL ROLE`, `GRANTED BY`, REVOKE RESTRICT sem afetar `cloud_admin` OID 155649). Havendo incerteza, impedir execução e solicitar ensaio controlado separado; não improvisar alteração de membership.
3. Preflight deve confirmar inventário exato, baseline anterior, atribuibilidade administrativa, ausência de permissões novas; postflight na transação e **independente após commit**, rollback integral em erro, análise antes de qualquer repetição em commit incerto.
4. Todas as mutações de GRANT, REVOKE, role, membership e SET ROLE requerem autorização nominal separada; até lá **nenhum SQL mutante**.
5. Preservar status globais: Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`; Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; PF-I04/P4 `NOT_AUTHORIZED`; sem pesquisadores vinculados, nenhum dado real nem promoção científica.

## 5. Ponto exato de retomada
**PF-I04/P4-A21:** preparar **documentalmente** script transacional v2 completo e matriz de preflight/postflight independentes, inclusive todas as permissões positivas e negativas, concedentes/colunas/seqs/Q0, propriedade e limpeza da associação temporária. Não executar no Neon, não modificar GitHub fora do escopo autorizado, não ativar runtime/HTTP. Avaliar mecanismo de GRANT/REVOKE por concedente com revisão técnica antes de solicitar gate operacional. O CP322 só documenta o trabalho realizado; cada `Prossiga` autoriza uma atividade interna e STOP. Checkpoints proporcionais após 3–5 atividades, com Freshness Gate antes de commits.
