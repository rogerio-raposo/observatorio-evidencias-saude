# OES — CP274: handoff após implantação sintética privada

Data: 2026-10-24. Anterior: CP273. HEAD-base: `01b230e0fb4f560a47ff6e59fd75d02e0f1d0d7f`.

## Estado canônico
Consultar primeiro os Documentos 269, 270 e 271, além do Documento 255 (revisão humana por exceção) e Documento 268 (histórico superado sobre artifact público). O proprietário determinou que **nenhum JSON bruto original será disponibilizado para download público**. Para o piloto E6-G1, o armazenamento será privado no PostgreSQL experimental, **somente durante o piloto**, com possibilidade posterior de migrar para armazenamento privado de objetos. Retenção por finalidade, sem prazo universal: preservar até validação e encerramento documental do ensaio e deliberar sobre manutenção/descarte. Repositório GitHub principal permanece público, sem JSON bruto em commit, artifact ou logs.

## Autorização delimitada e resultado
Aprovado pelo proprietário: `APPROVED — OES / D2-E6 / PG_RAW_SYNTHETIC_ONLY_SCHEMA_ROLES_AND_TESTS / branch br-gentle-hall-b6jaxehf / no factual GET / no public JSON / no paid services / fail closed`.

Neon Free projeto `weathered-boat-65779510`, database `oes_sandbox`, branch experimental **não principal** `br-gentle-hall-b6jaxehf`. Criados o schema `oes_raw_private`, a tabela `source_observation` com bytes `bytea` e proveniência, os papéis `oes_e6_writer` e `oes_e6_verifier`, ambos `NOLOGIN`. Matriz testada em catálogo: writer USAGE/INSERT, sem SELECT/UPDATE/DELETE; verifier USAGE/SELECT, sem INSERT/UPDATE/DELETE. `oes_pg_a4_reader` não tem acesso: consulta efetiva sob esse papel falhou com `permission denied for schema oes_raw_private` (PASS). Inserção/leitura de JSON sintético de 18 bytes teve paridade de bytes e hash fornecido, com remoção completa. Teste de rollback por erro induzido PASS. Tabela privada ficou **vazia**. Fixture PG-A4 preservada: 2 estudos, 2 relatórios, 3 vínculos e 1 proveniência; não reinserir nem remover.

## Limites e tarefas pendentes
Testes dos papéis E6 com conector falharam antes de chegar ao banco, por ausência de credenciais: papéis `NOLOGIN`. Ainda faltam teste controlado `SET ROLE` (se seguro), duplicidade e limite >2 MB, verificação independente do digest, e adaptar/testar workflow sem upload do JSON em artifact público. Não declarar suite integral PASS. CI offline histórica E6 39/39 PASS corresponde ao caminho **antigo**, não à gravação PostgreSQL.

E6-G1 captura factual **não autorizada**; workflow `.github/workflows/d2-e6-a2-gated-capture.yml` permanece `if: ${{ false }}` e tem caminho antigo de artifact que não pode ser usado para JSON factual. Não executar GET, desbloquear job, criar senhas, adicionar serviços, alterar branch primária nem promover resultados por inferência. Termos integrais de redistribuição ClinicalTrials.gov não verificados; política atual dispensa redistribuição do JSON bruto.

## Ponto exato de retomada
1. Ler template `archive/continuity/OES_Template_Abertura_Continuidade.md` em Modo Continuidade e `archive/handoffs/oes/README.md`.
2. Aplicar Freshness Gate na branch `main`, confrontar `STATE.md`, `CHANGELOG.md` e documentos vigentes 269–271.
3. Apresentar Diagnóstico de Continuidade.
4. Próxima atividade delimitada: avaliar teste sintético de writer/verifier por `SET ROLE` e executar apenas se seguro e incluído na autorização sintética vigente; sem contas/senhas novas.
5. STOP após atividade. `Prossiga` = uma atividade interna; checkpoints normalmente após 3–5 atividades ou decisão/risco, progresso transparente.

Fase 4 encerrada metodológica/documental, operação NOT_READY; D2 PARTIAL; Fase 5 NOT_STARTED. Este CP é operacional, não substitui políticas canônicas.

**STOP — CP274.**
