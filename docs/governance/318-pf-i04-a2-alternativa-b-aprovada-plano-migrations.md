# Documento 318 — PF-I04-A2: alternativa B aprovada e plano de execução controlada

**Data:** 2026-10-27. **Decisão:** responsável aprovou **a alternativa B** do Documento 317: Django Auth/permissões/sessões em schema próprio `oes_app` no banco sintético `oes_sandbox`. **Aprovação arquitetural, não aprovação de DDL, migrations, grants, secrets, conexão ou escrita HTTP.**

## Destino e isolamento
- Neon project `weathered-boat-65779510`; branch `br-gentle-hall-b6jaxehf`; database `oes_sandbox`; nenhuma operação em `production`.
- `oes_app` reservado às tabelas administrativas Django; tabelas de domínio permanecem em `core` e `investigation`, mapeadas com `managed=False`.
- Catálogo anterior: `oes_app` ausente; `oes_qprep_login` sem privilégio CREATE em public/banco; proprietário não deve ser conexão runtime. Q0 e recibos já existem; sem recriação.

## Gate P1: contrato de migrations e privilégios — somente preparação
1. Fixar versão exata Django e conjunto de apps/migrations (`auth`, `contenttypes`, `sessions`); inspecionar dependências e SQL gerado em ambiente local isolado antes de aplicar. A aplicação `evidence` não deve gerar DDL para modelos OES unmanaged.
2. Definir alias de conexão para autenticação, `search_path` explícito, proteção contra resolução inesperada de objetos `public`, e estratégia compatível com referências entre schemas. Verificar permissões `USAGE`/`CREATE` por schema e propriedade dos objetos.
3. Decidir identidades distintas por **privilégio**: papel transitório para DDL/migrate; identidade runtime com apenas SELECT/INSERT/UPDATE/DELETE/USAGE de sequências estritamente necessárias. Duas conexões de login independentes para funções do piloto não são requisito (Doc. 287); isso não elimina separação da autoridade de DDL.
4. Mapear `auth.User.pk` a identificador estável de preparador OES sem acoplamento irreversível a PK volátil; definir provisionamento, desativação, escopo e revogação, com fail closed.
5. Revisar `django_migrations`, `auth_permission`, `django_content_type` e `django_session` como objetos de aplicação, não modelos científicos. Declarar como o histórico de migrations será auditado.
6. Prever segredo Django externo, `DEBUG=False`, hosts/origins específicos, CSRF, cookies seguros sob HTTPS, logs sem payloads e procedimentos de backup/rollback. Não ativar estas configurações por padrão no scaffold atual.

## Gate P2: preflight conectado não mutante — exigir aprovação delimitada
Verificar branch/banco/role/catalogo por consultas somente leitura; ausência de `oes_app`, conflitos de objetos, extensão/collation, migrations existentes, esquema padrão/search_path e grants efetivos, sem ler usuários, senhas ou payload. Interromper diante de divergência.

## Gate P3: mudança estrutural — aprovação separada
Preparar artefato de SQL exato para criar `oes_app`, ownership e grants mínimos; preparar plano de Django `migrate` restrito aos apps administrativos, com timeout, auditoria de objetos e recuperação. Requer aprovação nominal de DDL/migrations, destino e role. **Não executar neste documento.**

## Gate P4: conexão privada e Q0 — aprovação separada
Após validação de P3, configurar Django privado e provisionar usuário sintético; comprovar autenticação/autorização negativas, primeira transação Q0 e read-after-write com rollback/recibos, mantendo bloqueios E9 e sem public HTTP write. Credenciais por canal protegido, nunca em docs.

## Critérios de parada
Nunca utilizar o role owner como identidade runtime nem reaproveitar `oes_pg_a4_reader` como writer. Não usar `oes_qprep_login` como migrator. Não executar `migrate` com `DATABASES={}`, sem `search_path` e ownership aprovados, nem transformar a receita ORM dormant em writer sem gate. Diferenças de catálogo, privilégios ou resultados de commit incertos -> HOLD e análise sem retry automático.

## Próxima ação concreta
Gerar o inventário do SQL das migrations administrativas e desenho de roles/search_path **offline**, sem comprometer-se antecipadamente com SQL exato que ainda não foi derivado e revisado. Preparar decisão técnica P1 e só depois propor P2/P3.

**Estado:** CP314 canônico; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.
