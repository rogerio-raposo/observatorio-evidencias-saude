# OES — Continuidade CP333 — 2026-10-28

**Predecessor:** CP332 (`archive/handoffs/oes/OES_Continuidade_2026-10-28_CP332.md`). **Escopo:** A6–A10, avanço offline Django First, sem promoção operacional. **Branch:** main.

## Atividades concluídas desde CP332

- **A6:** revisão do contrato ORM e riscos: baseline conectada de 44 permissões distinta do SQLite, escopo de transação, concorrência e alias. Somente análise, sem escrita.
- **A7:** commits `d58cc85fd544a553e4b9be90fdd16dcba60276c0` e `28f2c8aac98e0c316f00f725e377e94970d82bd2`: preflight movido para `transaction.atomic(using=...)`, checagem de `django_session` e validação de alias da instância antes de `user.user_permissions.add(permission)`; dois testes novos de sessões e atomicidade. CI [40746209036](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40746209036) SUCCESS.
- **A8:** especificação da orquestração mínima: autorização nominal; papel `oes_auth_migrator`, banco `oes_sandbox`, schema `django_auth`; baseline exata; quatro efeitos; postflight independente; tratamento de erro e limpeza em gate separado. Somente análise.
- **A9:** commits `0a4d571f293106c19c24c69259f5fbf45d884998` e `175bcb94753f9ee1dce41613d369daee4c17111f`: contratos puros `CONNECTED_BASELINE` e `CONNECTED_POSTFLIGHT`, `validate_connected_contract` com resultado explicitamente não autorizativo, e dois testes novos. CI [40748916868](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40748916868) SUCCESS, SHA `175bcb94753f9ee1dce41613d369daee4c17111f`.
- **A10:** confirmação do resultado CI e consolidação deste checkpoint. Nenhum DML Neon, GRANT, role, segredo, novo workflow conectado, HTTP write, deploy ou serviço pago durante A6–A10.

## Invariantes e limites

- Decisão normativa **Django First**: Documento 347; governança técnica proporcional: Documento 362.
- O núcleo `applications/oes_web/config/auth_pg_g2_p2b_offline.py` tem **única entrada pública offline** com guard SQLite descartável. `_provision_transaction` é função interna, não executor conectado autorizado; o contrato conectado é somente validador de dados informados e **não verifica identidade no servidor**.
- Baseline conectada histórica de G2-P2-A: 44 permissões, 0 usuários, 0 vínculos, 0 identidades, 0 sessões; `evidence.prepare_question` ausente. Confirmar novamente in situ antes de qualquer escrita. Postflight esperado: 45, 1, 1, 1, 0 respectivamente. Verificar o ContentType e preservar as permissões preexistentes.
- Projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, schema `django_auth`; papel administrativo `oes_auth_migrator`; validação anterior de ACLs registrada no documento canônico de arquitetura. Credenciais informadas com validade 2026-10-31 23:59:59 UTC.
- **Riscos não resolvidos:** concorrência com outros escritores; verificação real de `current_user`, `current_database()` e `search_path`; segregação de aliases; pós-commit incerto; preparação segura e limpeza autorizada de identidade sintética. `transaction.atomic()` não resolve sozinho concorrência externa.
- **Gates:** Marco B OPEN, G2-P2-B conectado HOLD / operacional NO-GO, E9 NO-GO, Fase 5 NOT_STARTED, fase 4 encerrada metodológica e documentalmente. Ausência de pesquisadores reais.

## Próxima atividade sugerida

Realizar **revisão proporcional de suficiência** do contrato offline e dos riscos restantes. Evitar novas abstrações puramente documentais: se necessário, preparar um único pacote técnico operacional mínimo, sem ativá-lo, para futura solicitação de autorização nominal explícita. Não usar `Prossiga` como aprovação de DML conectado. Não duplicar a stack Django nem reabrir auditorias catalogais concluídas. Falhas de verificação => HOLD.

**Fonte de verdade:** CP333 para continuidade, CP332/CP331 como histórico, `STATE.md`, documento canônico `docs/governance/oes-auth-single-database-architecture-2026-10-28.md`, Documentos 347 e 362.
