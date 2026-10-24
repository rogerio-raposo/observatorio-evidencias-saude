# OES — CP275: handoff após ensaio privado sintético B2

**Data:** 2026-10-24. **Anterior:** CP274. **HEAD-base:** `e08c680e8c047ec4a1849a93038b9201c09b4043`. **Fonte operacional:** `archive/handoffs/oes/README.md`. Checkpoint imutável, não normativo; decisões em documentos canônicos prevalecem.

## Estado e autorizações
Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness operacional `NOT_READY`; D1 piloto sintético restrito; D2 `PARTIAL`; Fase 5 `NOT_STARTED`. **E6-G1 factual NÃO autorizado.** Nenhum novo GET ClinicalTrials.gov, secreta, ativação de workflow, produção, dado clínico publicado ou serviço pago.

Repo `rogerio-raposo/observatorio-evidencias-saude`, branch `main` pública. JSON bruto original **nunca** disponibilizado em commit, artifact público ou log (Documento 269). Na fase piloto, destino privado PostgreSQL `bytea`, retenção até validação/encerramento documental e deliberação posterior; não confundir workflow antigo com arquitetura aprovada.

Neon Free projeto `weathered-boat-65779510`, branch sintética `br-gentle-hall-b6jaxehf` (nome visual `oes-pg-a3-synthetic-20261024`), banco `oes_sandbox`, schema `oes_raw_private`, tabela `source_observation`. Dados PG-A4 em `evidence` devem ser preservados.

## Avanços desde CP274
- Documentos 272–276: testes ACL negativos e autenticação transitória. Login `oes_e6_capture_login` permaneceu **NOLOGIN**, sem membership, sem herança; senha antiga não foi comprovadamente invalidada, **não reutilizar**. Grants administrativos históricos `cloud_admin` para writer/verifier devem ser preservados.
- Documentos 277–279: adaptador offline `tools/d2_e5_preservation/e6_private_pg_offline.py` e 18 testes; CI `40125394727`: **57/57 PASS** (18 do adaptador, 39 anteriores). Encerramento técnico apenas offline.
- Documento 280: `e6_private_roundtrip_offline.py` e seis testes sintéticos de separação/recuperação; CI `40126123398`: **63/63 PASS**, HEAD testado `2a129c2bff8318f2b32fd8f7804e6764b40ec9a7`. Teste offline não equivale a integração via driver.
- Documentos 281–283: B1 ACL atestada no Neon SQL Editor pelo proprietário; writer NOLOGIN, USAGE/INSERT, sem SELECT; verifier NOLOGIN, USAGE/SELECT, sem INSERT; login de captura NOLOGIN sem privilégios/associações. Proprietário **escolheu opção 1**, alternância `SET ROLE` na sessão administrativa para B2, aceitando não testar autenticação independente. Autorizações B2 foram expressas e limitadas a um único registro sintético e limpeza.
- Documento **284**: ensaio real sintético B2 autorizado e concluído no Neon. Inicial 0 linhas. Grants transitórios com `SET TRUE` dados ao owner para writer e verifier, sem herança; `SET LOCAL ROLE oes_e6_writer` fez **um INSERT sintético** ID `SYNTH-B2-20261024-01`; transação distinta `SET LOCAL ROLE oes_e6_verifier` comprovou recuperação **18 bytes**, hash armazenado = SHA-256 recalculado `a8198524f58e72b56283ab71ebddada22840f108b46ef7165bb3fca9919c5558` e integridade TRUE. Sem exibir bytes brutos. DELETE do ID e REVOKE restrito `GRANTED BY oes_sandbox_owner` retornaram sucesso. Pós-ensaio tabela **0 linhas**; apenas dois grants históricos de `cloud_admin`, `SET FALSE / INHERIT FALSE / ADMIN TRUE`; três papéis continuam NOLOGIN/NOINHERIT. Testes ACL negativos já ocorreram no Documento 272, não foram repetidos em B2.
- Fixture PG-A4 após B2: `evidence.study=2`, `evidence.report=2`, `evidence.study_report_link=3` reconfirmados. **Quarto invariante pendente:** run PG-A4 `40110909348` e Documento 265 registram **uma proveniência na projeção Django de três vínculos**, mas consulta atual `evidence.result_source=0`. Isso **não prova perda**, porque a contagem de proveniência pode pertencer à projeção de outras tabelas/joins. Identificar a origem exata no código/testes e, se necessário, fazer verificação read-only específica; não inventar a correspondência.

## Segurança e limites
Workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` mantém `if: ${{ false }}` e **upload-artifact antigo incompatível** com política 269; NÃO executar, habilitar nem transferir JSON bruto. Adapter não conectado ao caminho de captura, nenhum E6-G1 aprovado. SET ROLE B2 prova papéis efetivos segregados na mesma identidade administrativa `session_user=oes_sandbox_owner`, **não** autenticação por dois logins nem integração Python/driver/CI factual. Não repetir automaticamente INSERT B2 já comprovado.

## Ponto exato de retomada
1. Ler template `archive/continuity/OES_Template_Abertura_Continuidade.md` em **Modo Continuidade**, ponteiro e CP275; Freshness Gate em `main` e `STATE.md`/`CHANGELOG.md`, Docs 269, 272, 276, 279–284.
2. Apresentar Diagnóstico de Continuidade antes de executar, explicitar HEAD e bloqueios.
3. **Próxima atividade única:** localizar no código ou evidência PG-A4 a origem do invariante de 1 proveniência da projeção Django (run `40110909348`), distinguir de `evidence.result_source`, e confirmar se o baseline de 1 foi preservado, preferencialmente por revisão documental antes de qualquer SQL. Se não confirmado, manter pendência sem reeditar resultado B2.
4. Só depois reavaliar fechamento restrito de B2 e próximo gate de integração Python PostgreSQL **sem artifacts brutos**; exigir autorização própria antes de operação conectada.
5. Uma atividade por `Prossiga`; checkpoint normalmente após 3–5 atividades ou risco; atualizações de progresso; Freshness Gate no início e antes de commit. STOP ao final. Sem trabalho assíncrono.

**STOP — CP275.**
