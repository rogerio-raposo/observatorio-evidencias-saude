# Documento 201 — N1 e N1-B Neon, CP226

2026-10-21. Projeto Neon exclusivamente sintético `oes-d1-t2-a2-synthetic` (ID `tiny-pond-20086371`), branch `synthetic-main` (ID `br-divine-grass-b63wlpcb`), PostgreSQL 18, plano Free.

O proprietário aprovou N1 (consulta de metadados e preparação sem mutações) e N1-B (somente criação de papel PostgreSQL). O preflight confirmou a inexistência do nome; a operação administrativa `create_postgres_role` criou `oes_t2a2_runtime`; inspeção posterior confirmou `oes_t2a2_owner` e `oes_t2a2_runtime` e autenticação password. Nenhuma senha foi recuperada; nenhum SQL, GRANT, DDL, tabela ou dado foi executado ou criado pela atividade.

Riscos não encerrados: privilégios mínimos efetivos não verificados, `block_public_connections=false`, branch sem proteção, TLS e segredos não testados, quotas futuras não garantidas; o projeto original `oes-sandbox` permanece separado.

T1 36 PASS históricos; T2-A1 75 PASS históricos; T2-A2 e N2 NÃO AUTORIZADOS. Fase 4 NOT_READY; Fase 5 NOT_STARTED; migrations e gates preservados.

Próximo `Prossiga`: uma atividade documental de matriz de privilégios mínimos e conexão segura, sem SQL nem modificações Neon. STOP.
