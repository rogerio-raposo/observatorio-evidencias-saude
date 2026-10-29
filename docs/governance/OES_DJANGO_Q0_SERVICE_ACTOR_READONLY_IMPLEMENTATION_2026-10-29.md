# OES — Identidade sintética de serviço: verificação READ ONLY offline

2026-10-29. Implementação: `applications/oes_web/preparer_identity/synthetic_service_readonly.py`; testes: `applications/oes_web/evidence/test_synthetic_service_readonly_offline.py`.

O classificador puro exige username reservado, exatamente um usuário e uma associação de UUIDv4, vínculo por user_id, ativo e não administrativo, senha inutilizável, exatamente a permissão direta `evidence.prepare_question` e nenhuma associação a grupo. Retorna `oes:actor:<uuid>` derivado exclusivamente da associação persistida, sem aceitar actor fornecido externamente.

A função de atestação é estritamente READ ONLY e exige na sessão PostgreSQL role `oes_auth_trial_login`, database `oes_sandbox`, schema `django_auth`, transaction_read_only=on, sem transação externa e autocommit; não estabelece login Django, não fornece autorização operacional e não é chamada pelo executor Q0. Em configuração corrente, o alias `default` não garante `transaction_read_only=on` e portanto **a atestação permanecerá HOLD até configuração revisada de sessão somente leitura**. Não relaxar essa checagem para viabilizar ensaio.

## Tentativa única

Avaliados recursos atuais: concurrency do GitHub Actions apenas serializa e environment approval não é ledger de consumo; artefato/log de workflow não é fonte atômica confiável. Não implantar tabela, credencial, automação escritora ou serviço novo neste incremento. **Não há garantia técnica de single-use ainda; connected-trial mantém `if: false`**.

## Próxima ação

Confirmar CI offline do novo classificador (expectativa 291 testes a partir dos 287 já comprovados); depois revisar o alias auth read-only e o mecanismo de consumo de autorização numa única decisão proporcional. A autorização nominal anterior para um ensaio rollback-only não foi consumida. Marco B OPEN; Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED.
