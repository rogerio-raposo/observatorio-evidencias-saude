# PF-I04-A2 — Alternativas de armazenamento Django Auth e sessões

**Data:** 2026-10-27. **Natureza:** decisão arquitetural candidata, não autorização de execução. **Base:** Docs. 287, 288, 315 e 316 (PF-I04-A1); inventário não mutante no Neon sintético.

## 1. Contexto confirmado
- Projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`.
- `investigation.question_version` já suporta Q0 com `normalized_text` nullable e `preparation_stage` validado; recibos de Q0/Q1 têm PK composta em `investigation.question_command_receipt`. Não repetir DDL.
- Inventário da branch não identificou `auth_user` ou `django_session`. O Django atual mantém `DATABASES={}`, `DEBUG=True` e segredo exclusivamente de desenvolvimento.

## 2. Alternativas avaliadas
| Alternativa | Vantagem | Risco e custo | Parecer |
|---|---|---|---|
| A — tabelas Django no schema `public` do mesmo `oes_sandbox` | Simplifica conexão inicial e transações | Mistura domínio administrativo com dados científicos; migrações requerem DDL e `search_path`/privilégios controlados | Não preferida |
| B — schema de aplicação dedicado no mesmo `oes_sandbox` | Isolamento lógico, custo reduzido, uma conexão possível para Q0 e identidade | Django migrations, `search_path`, FKs, ACL e permissões de DDL precisam projeto explícito; risco de permissões excessivas | **Recomendação candidata para piloto restrito** |
| C — banco separado para Django Auth/sessões | Fronteira de dados mais clara e administração separável | Duas conexões, coerência transacional entre contas e perguntas, setup e operação extras; Django não oferece transação distribuída automática | Alternativa se isolamento exigir |

## 3. Desenho candidato B — sujeito a validação
1. Reservar namespace específico (nome candidato `oes_app`) somente para tabelas Django `auth`, `contenttypes` e `sessions`; não criar nesta etapa.
2. Manter tabelas canônicas de Question nos schemas `core` e `investigation`, sem migrações Django sobre esses modelos `managed=False`.
3. Usar autenticação Django padrão e permissão explícita `evidence.prepare_question`; mapear `user.pk` a `responsible_actor_id` com regra estável, auditável e restrita à aplicação, a detalhar.
4. Segregar privilégio de execução da aplicação de privilégio temporário de migração. A identidade de aplicação pode ser única para o piloto (Doc. 287), mas nunca proprietária do banco ou com `CREATE` genérico. Decidir `search_path` seguro, host, TLS, default DB alias, migrações e reversão antes de conectar.
5. Estabelecer política de criação, bloqueio e exclusão de contas sintéticas; `DEBUG=False`, `SECRET_KEY` externa, `ALLOWED_HOSTS` e `CSRF_TRUSTED_ORIGINS` precisos, cookies de sessão e CSRF protegidos, logs sem dados sensíveis e controle de custo.
6. Verificar catálogo `pg_namespace`, privilégios mínimos e compatibilidade de migrations em preflight explicitamente não mutante; não inferir segurança só da separação por schema.

## 4. Sequência de gates proposta
- **B1 — aceite arquitetural documental:** usuário aprova a alternativa e o contrato de identidade/sessão, sem SQL.
- **B2 — preflight somente leitura:** catálogo, configurações e privilégio de roles existentes; nenhuma leitura de payload/credencial e nenhum DDL.
- **B3 — autorização separada de preparação de schema e migrations:** SQL exato, branch, banco, role transitória, backup/rollback e verificação pós-execução.
- **B4 — autorização separada de conexão privada Django e primeiro Q0 commit:** credenciais descartáveis/protegidas, identidade e autorização com testes negativos, transação/recibo e sem E9; não habilitar automaticamente rotas públicas.

## 5. Pendências decisórias
- Definir se contas Django ficam em `oes_app` no `oes_sandbox` ou banco separado, com base na avaliação real de privilégios e migrações.
- Definir mapping imutável de principal Django para ator OES, regime de revogação, ownership de contas e acesso ao histórico.
- Confirmar escopo da primeira fatia: Q0 somente e leitura privada após commit, sem Q1/Q2 persistentes.
- Plano de incidentes/rollback, ambiente privado e responsável operacional.

**Conclusão:** recomenda-se **alternativa B como candidata**, sem antecipar operações ou considerar seu aceite automático. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED; CP314 permanece canônico.
