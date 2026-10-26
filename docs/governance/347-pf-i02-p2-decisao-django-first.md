# Documento 347 — PF-I02 / P2 — Decisão arquitetural proporcional: Django ORM versus adaptador SQL
**Data:** 2026-10-26. **Base:** CP310, Docs.344–346, CI 40278790506 (142/142 PASS offline). **Natureza:** decisão de desenho documental, sem acesso ao Neon e sem habilitar escrita.

## Avaliação por capacidade
| Requisito OES | Preferência para aplicação definitiva | Limite que exige evidência |
|---|---|---|
| Autorização do preparador | Auth/permissions Django + política de objeto explícita | Permissão global não comprova responsabilidade individual; RLS ausente |
| Q0 com ID único e dados originais imutáveis | Models Django mapeados sobre schema canônico, constraints de banco, `objects.create()` | Confirmar `managed=False` ou estratégia de migrações; não recriar schema de legado |
| Q1 com histórico e versão corrente | Models/QuerySets e `transaction.atomic()`; atualização condicional por versão | Controle de versão e constraints no PostgreSQL, concorrência conectada |
| Recibo e idempotência | Model com unique constraint (actor, request); escrita na mesma `atomic()` | Rechecagem de escopo e commit incerto |
| Rollback atômico | `transaction.atomic()`, preferir fronteira única | Verificar factory/transaction nesting e comportamento connected |
| Lock de versão | `select_for_update(of=...)` quando necessário | Privilégio UPDATE, isolamento e locking reais |
| Lock por identidade global sem linha Q0 | SQL PostgreSQL mínimo (`pg_advisory_xact_lock`) **se ainda necessário** | Todos os caminhos de alteração de responsabilidade devem cooperar; não substitui ACL |
| Consultas e validação | ORM, constraints e checks em serviço | Não converter simulação offline em prova conectada |
| Captura/publicação factual, HTTP | Fora deste incremento | E9 NO-GO; usuários reais e A3 ausentes |

## Decisão
**Django-first, conservar o domínio:** preservar `QuestionCommand`, fingerprint, regras de preparação, recibos e cenários de 142 testes como especificações do comportamento. Tratar `question_sql_port_offline.py` como **artefato de laboratório**, não contrato permanente. Para backend futuro, avaliar um repositório fino usando Django models mapeados para as tabelas canônicas, transações `atomic()`, constraints e, somente se demonstrado necessário, SQL mínimo de advisory lock. Não migrar nem duplicar tabelas automaticamente.

**G2 NÃO deve ser desenhado como homologação obrigatória do adaptador SQL experimental.** Reavaliar o gate para demonstrar primeiro as invariantes Q0→Q1 pela stack Django/PostgreSQL mais simples, com caso sintético estritamente delimitado, dentro de autorização nominal nova. Reutilizar testes como critérios de aceite, não exigir implementação idêntica.

## Riscos e checkpoints
- Ausência de model Django operacional para essas tabelas ainda impede presumir ORM pronto; mapear schema antes de criar Models.
- Sem autenticação de pesquisadores reais, identidade conectada ou isolamento por registro, não há readiness operacional.
- Revogação/transferência continua bloqueada até existir via única que compartilhe serialização ou solução de controle mais robusta.
- O protótipo SQL offline permanece preservado e CI 142/142 continua evidência histórica, sem necessidade de novos refinamentos artificiais.
- `SELECT FOR UPDATE` via ORM não contorna privilégios PostgreSQL; o papel W2a conserva ACL e G2 permanece NO-GO.

**Conclusão:** `DJANGO_FIRST_ARCHITECTURE_PREFERRED / EXPERIMENTAL_SQL_ADAPTER_NONCANONICAL_FOR_PRODUCTION / G2_NO_GO`. CP310 vigente; Marco B aberto; Fase 5 NOT_STARTED, readiness NOT_READY, E9 NO-GO.
