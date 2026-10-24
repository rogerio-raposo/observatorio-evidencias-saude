# Documento 275 — Pedido de autorização: identidade operacional sintética de menor privilégio (D2-E6)

**OES | 2026-10-24 | CP274 | Referência: Documento 274 | HEAD de preparação:** `ee8e1d45f42ade8b6a9109ca9a9dd1aace877f9e`

**Estado:** `OWNER_APPROVAL_PENDING / NO_CREDENTIAL_OR_ROLE_CREATED_BY_THIS_DOCUMENT / E6_G1_FACTUAL_BLOCKED`.

## 1. Decisão solicitada
Autorizar **somente** a implantação e verificação sintética de uma identidade PostgreSQL autenticável de menor privilégio no **projeto Neon Free existente** `weathered-boat-65779510`, branch experimental `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`.

Escopo máximo:
1. Criar um único papel técnico `oes_e6_capture_login` com LOGIN, sem privilégios administrativos, sem herança de poderes nem acesso genérico à fixture PG-A4; permitir somente associação controlada, sem ADMIN e sem INHERIT, ao papel `oes_e6_writer` existente, com capacidade de SET quando explicitamente invocada.
2. Gerar credencial forte sem expô-la em GitHub, logs, documentos ou respostas. Evitar devolver senha pelo conector; se o processo não permitir provisionamento seguro, **STOP** e reapresentar alternativa.
3. Com exclusivamente JSON sintético, validar login e limites de SELECT/INSERT/UPDATE/DELETE e schema, além de inserção controlada e integridade; excluir registros sintéticos do teste e confirmar fixture PG-A4 (2 estudos, 2 relatórios, 3 vínculos, 1 proveniência).
4. Definir destino seguro da credencial para futuro workflow, preferencialmente GitHub Actions Secrets, **sem acoplar ou disparar captura factual**. Não autorizar automaticamente criação de qualquer Secret ou implantação em workflow factual; essa ligação terá decisão própria.
5. Rotação/revogação ou desativação documentada e comprovável. Eventual credencial deixada ativa exige decisão específica posterior, distinta da aprovação do ensaio sintético.

## 2. Segurança e condições técnicas
- Freshness Gate GitHub, preflight Neon read-only de papéis e grants; abortar se existir identidade com mesmo nome ou se grants divergirem.
- Conferir antes da aplicação compatibilidade do PostgreSQL 18 com GRANT de associação `WITH SET TRUE, INHERIT FALSE, ADMIN FALSE` e com `SET LOCAL ROLE`; configurar transações breves e rollback; nenhuma concessão a `PUBLIC`.
- Não utilizar `oes_sandbox_owner` ou `oes_pg_a4_reader` para executar a captura. Administrador pode ser utilizado somente para criação controlada do papel e diagnóstico.
- Não criar conta de verificação com LOGIN por inferência; leitura pós-gravação por identidade separada necessita proposta própria, ou continuar bloqueado.
- Não reutilizar secrets antigos, criar serviços pagos, mexer no branch primário, replicar dados factuais ou publicar o JSON em artifacts.
- Preservar explícita e integralmente os papéis `oes_e6_writer` e `oes_e6_verifier` preexistentes e suas associações administrativas originais, inclusive `SET FALSE`.

## 3. Evidência exigida
Preflight e pós-teste: identidade de conexão, inventário de concessões, privilégios efetivos, total de linhas `oes_raw_private.source_observation` igual a zero após limpeza, fixture PG-A4 intacta, ausência de payload e segredo em logs/artifacts. Negativos sob identidade autenticada: escrita sem `SET ROLE` deve falhar; SELECT/UPDATE/DELETE mesmo como writer devem falhar; somente INSERT sintético autorizado como writer. Se algum teste falhar, não promover a identidade ao workflow.

## 4. Portabilidade e fronteira futura
PostgreSQL `bytea` restringe-se ao piloto; futura migração para object storage privado continua possível. A retenção é por finalidade. `.github/workflows/d2-e6-a2-gated-capture.yml` segue `if: ${{ false }}`, ainda com caminho antigo de artifact público que não pode ser executado. **E6-G1 GET factual não está aprovado.** Aprovação deste documento não autoriza execução de consulta, secrets do GitHub ou edição de workflow.

## 5. Texto sugerido de decisão
`APPROVED — OES / D2-E6 / SYNTHETIC_MIN_PRIVILEGE_CAPTURE_LOGIN_ONLY / br-gentle-hall-b6jaxehf / controlled-credential / verify-and-disable / no factual GET / no public JSON / no workflow enablement / no paid services / fail closed`

**Este documento é pedido de autorização, não autorização. STOP.**

## 6. Verificação de provisionamento seguro — 2026-10-24

Documentação oficial Neon `https://neon.com/docs/manage/roles`: papéis criados por SQL **não** recebem automaticamente `neon_superuser`; papéis criados pela Console, CLI ou API normalmente recebem essa associação. O SQL Editor aceita `CREATE ROLE ... WITH LOGIN PASSWORD ...` e `ALTER USER ... WITH PASSWORD ...`; recomenda senha com pelo menos 60 bits de entropia. A redefinição pela API/Console pode retornar senha gerada na resposta — essa rota exporia a credencial no canal de ferramenta usado aqui, sendo inadequada sem mecanismo de encaminhamento secreto comprovado.

**Diretriz proporcional:** preferir provisionamento SQL pelo usuário no Neon SQL Editor, com senha aleatória forte gerada fora da conversa e armazenada em gerenciador de segredos; não enviar valor da senha ao chat, a commits ou a logs. Após aprovação de operação conectada sintética e política de ciclo de vida, credencial poderá ser inserida diretamente em GitHub Actions Secrets pelo usuário, para teste autenticado específico, sem habilitar E6-G1 factual. Essa alternativa requer verificação dos grants mínimos, autorização para eventual secret e revogação/desativação conforme Documento 275. Não fornecer aqui SQL com senha literal ou alegar execução conectada já comprovada.

**Conclusão:** `SECURE_SQL_ROLE_PROVISIONING_FEASIBLE / SECRET_HANDOFF_NEEDS_USER_CONTROLLED_CHANNEL / NO_ROLE_CREATED / E6_G1_BLOCKED`.
