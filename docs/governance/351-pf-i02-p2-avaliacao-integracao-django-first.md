# Documento 351 — PF-I02/P2 — Avaliação de integração Django-first
Data: 2026-10-26. Referência: CP311, Doc.350, CI 40283529418 (SUCCESS, 158/158, SHA 837d40465501d5500a94491e572bb3bbc4308eab).
Escopo: auditoria estática; nenhuma conexão, SQL executado ou autorização G2.

## Resultado
Os componentes **não constituem backend ORM transacional integrado**. O serviço `question_preparation.py` valida comando, permissões e resultado; `OfflineQuestionUnitOfWork` contém orquestração Q0/Q1, replay e recibos; `models.py` define tabelas; `question_orm_transaction_offline.py` contém QuerySets não avaliados; `question_orm_atomic_boundary_offline.py` aceita exclusivamente factories simuladas e não executa `django.db.transaction.atomic`. O compilador ORM DML só gera SQL sem executar. Assim, 158/158 PASS é evidência sintética **parcial**, não integração operacional.

## Lacunas específicas
1. Implementar **um** port concreto para os métodos `lock_request`, `find_receipt`, `current_question`, `can_access_question`, `register_q0`, `propose_q1`, `save_receipt`, sem espelhar permanentemente o adaptador SQL experimental.
2. Iniciar `transaction.atomic(using=alias_autorizado)` na mesma conexão que quaisquer comandos necessários de advisory lock e todos os QuerySets; não utilizar alias reader. Nenhum alias writer autorizado ou disponibilizado atualmente.
3. Revalidação de replay exige escopo contemporâneo e comparação de fingerprint, sem uso do recibo como permissão; Q0 deve tratar colisão de `oes_id` global, sem revelar pergunta alheia.
4. Q1 exige `original_text` idêntico, `expected_version` corrente, relação `(entity_uuid,version_uuid)`, atualização condicional e uma linha afetada; gravação da próxima `entity_version` + `question_version` + ledger no mesmo commit.
5. O esquema garante constraints e FKs compostas que o ORM não reproduz; conferir em ensaio autorizado os defaults, grants mínimos, `change_type`, índices e mensagens de falha. Em particular, não utilizar `SELECT ... FOR UPDATE` em `investigation.question`, sem privilégio UPDATE. As mutações de responsabilidade exigiriam lock cooperante equivalente; não implementadas.
6. Timeout/commit incerto: HOLD sem repetição automática; integridade e ausência de vazamento de informação prevalecem sobre conveniência.
7. Verificação de `rowcount`, equivalência dos dados gravados e concorrência real não decorre de testes de compilação ou mocks.

## Decisão de simplificação
- Não criar outras factories, adaptadores paralelos, novos esquemas ou camadas de simulação apenas para elevar o número de testes.
- Preservar os módulos experimentais como evidência, evitando promovê-los a dependências de produção.
- Próximo incremento quando aprovado: **uma implementação mínima e coesa do port ORM**, com uma única transação e controles de fail-closed. Primeiro avaliar que parte pode ser verificada offline; não tratar simulações como validação PostgreSQL.
- G2 continua **NO-GO** e requer autorização nominal para qualquer transação conectada. Não executar Neon, DML/DDL, grants, HTTP write, deploy, E9 ou serviços pagos.

## Estado
`DJANGO_FIRST_INTEGRATION_GAP_IDENTIFIED / 158_TESTS_SYNTHETIC_PASS / CP311_ACTIVE / G2_NO_GO`.
Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO.
