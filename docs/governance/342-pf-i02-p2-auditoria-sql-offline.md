# Documento 342 — PF-I02-P2: auditoria técnica offline da porta Q0→Q1
**Data:** 2026-10-26. **Natureza:** auditoria de fonte versionada, sem consulta conectada, DML, DDL, grants ou deploy. **Base:** CP309, Doc.341, schema `database/poc-s1.sql`, Doc.335, CI https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40276688658 (140/140 PASS no commit 66e41bff4932a347c14a5939882dc2bf21bb967a).

## Correção proporcional aplicada
A consulta `current_question()` filtrava somente `ev.valid_to IS NULL`, portanto podia considerar como vigente versão cujo `version_status` não fosse `current`. Exigido também `ev.version_status='current'`, com assertiva offline no teste do SQL. **Código corrigido depois da CI 140/140; nova CI pendente.**

## Achados remanescentes
1. A Unit of Work faz uma leitura de `current_question(lock=True)` e `propose_q1()` realiza outra SELECT FOR UPDATE. Validar transações e locks para impedir TOCTOU e confirmar semântica de concorrência adversarial. A porta e testes em memória não comprovam isso.
2. Factory injetada não prova por si mesma commit único, rollback, nível de isolamento, timeout ou lock persistente; são obrigações para futuro adaptador conectado, que permanece não autorizado.
3. `core.entity_version.change_type='normalization_proposed'` é apenas candidato técnico; não foi reconciliado com convenções existentes de Q1. A coluna exige NOT NULL mas não enum canônico.
4. ACL W2a: role `oes_qprep_writer NOLOGIN`, SELECT/INSERT nas cinco tabelas e UPDATE só em `core.entity_version.version_status/valid_to`; sem RLS e sem segregação de registro. Necessária validação conectada separadamente autorizada, nunca usar owner como runtime.
5. O lookup scoped de Q0 retorna `None` para entidade de outro responsável; não demonstra ausência global. UNIQUE em `core.entity.oes_id` e rollback são proteção necessária; sem vazamento de dados em conflitos.
6. A assinatura `Receipt` não carrega UUID, portanto replay comprova versão/número e escopo mas não confere UUID do resultado com ledger; exigir avaliação antes da homologação multiusuária.
7. Comandos com `FOR UPDATE OF q, ev` e respectivas permissões devem ser verificados contra PostgreSQL/ACL em gate específico. Nenhuma execução conectada neste documento.

## Conclusão
`P2_OFFLINE_SQL_AUDIT_FINDINGS_OPEN / CONNECTED_HOLD`. Não declarar encerramento irrestrito de Q0→Q1 nem CP310 até corrigir itens impeditivos proporcionais, validar nova CI e formalizar limitações. Marco B aberto, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO.
