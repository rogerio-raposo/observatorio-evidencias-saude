# OES — Continuidade CP265: ClinicalTrials.gov primeira recuperação estruturada bem-sucedida, parcial

**Data:** 2026-10-23. **Anterior:** CP264. **Conversa:** aberta.  
**Status:** `D2_CTGOV_E3_CONNECTED_RETRIEVAL_PASS_FIRST_PAGE_PARTIAL / PHASE_4_DOCUMENTARY_CLOSED / PHASE_5_NOT_STARTED`.

## 1. Ato factual concluído

O proprietário forneceu `https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40021883998` após autorização formal do único disparo manual D2-CTGOV-E3 (Documento 245, workflow criado e preparado conforme Documento 246/CP264). Conector GitHub leu execução, job e logs. `workflow_dispatch`, `run_attempt=1`, `head_sha=546c14219ae20a60c110372d96868dcb5602fccf`, `completed/success`, `clinicaltrials-one-get` job `120648218066` success. Consultou uma vez API `GET https://clinicaltrials.gov/api/v2/studies` com parâmetros literais do Doc. 242/245; em `2026-10-23T20:47:12.448752+00:00` a `2026-10-23T20:47:12.942393+00:00`, recebeu **HTTP 200, JSON, 630386 bytes, `totalCount=87`, `returned_count=20`, `nextPageToken=true`**. Rotina classificou `PARTIAL_FIRST_PAGE_ONLY` e job concluiu success. **Não paginar, não rerun, não lookup NCT adicional**, pois a autorização foi consumida.

**Documento 247** `docs/governance/247-d2-ctgov-e3-primeira-recuperacao-estruturada-parcial-cp265.md` registra os **20 NCT IDs na ordem**, URL codificada, UTC, prova/restrições. Aparecem NCT03613519 (Zhou), NCT03213132 (OASIS) e NCT04564807 (Verlinden, contextual já catalogado no OES). Nazem NCT03366870 não consta da **primeira página**, não inferir ausência geral. O log não preserva JSON integral dos registros; NCTs distintos **não** são RCTs elegíveis novos. Não inferir cobertura dos 87 hits nem relação exaustiva PMID/DOI. É PASS de **acesso técnico estruturado, parcial por paginação** e nada mais.

## 2. Fonte canônica e limites conservados

GitHub `rogerio-raposo/observatorio-evidencias-saude` branch `main`; `archive/handoffs/oes/README.md` ponteiro para CP265, template `archive/continuity/OES_Template_Abertura_Continuidade.md`, `STATE.md`, `CHANGELOG.md`. Freshness Gate inicial nesta atividade: CP264 HEAD `546c14219ae20a60c110372d96868dcb5602fccf` `identical`. Revalidar antes de qualquer mudança ou retomada.

**Fase 4:** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Doc.240 `PASS_DOCUMENTARY_ONLY` com C1–C6, readiness operacional `NOT_READY`, `M3 BLOCKED`, **Fase 5 `NOT_STARTED`**. Sem parecer científico independente, 12 AT não executados end-to-end.
**D0:** encerrado documentalmente. **D1:** `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, A2-G4 deferido/não aceito, A2-G5 runtime não autorizado; branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1` não alterar/mesclar.
**D2:** factual global parcial; NCBI D2-E2 run `39977371270` success restrito; Shaffer D2-E3 Doc.236 restrito; CTgov E1 Doc.243 falha URL ferramenta, E2 Doc.244 falha DNS local, **E3 run 40021883998 success técnico parcial**. Ficha N2 `OES-P-2026-000401` baseline 2026-10-04 A2 interno, GRADE/currentness/assurance/ProductVersion inalterados, NCTs não promovidos como nova evidência elegível.
**Segurança:** 36 migrations `UNREVIEWED`; BRG-03/06/07/08 bloqueados, BRG-09 parcial; SA-05/06/07/08/10 abertos/diferidos, sem Neon/SQL e sem novo serviço pago. ZIP Shaffer em Biblioteca pessoal `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, não publicar; verificar acesso real em retomadas.

## 3. Próximo `Prossiga` e forma de trabalho

Cada `Prossiga` autoriza uma atividade interna e **STOP**; checkpoints normalmente após 3–5 atividades ou risco/decisão, comunicação de progresso em operações extensas; não construir framework próprio sem necessidade; não utilizar ChatGPT Work. Priorizar utilidade científica real e limites de autoridade humana.

**Próximo `Prossiga`: elaborar apenas uma conciliação documental sem consultas novas da lista de 20 NCTs no Doc. 247 com os inventários OES existentes (Doc.49, 234 e correlatos), separando identidades já conhecidas de não identificadas na documentação examinada; registrar impossibilidade de julgar eligibilidade, duplicação entre relatórios, data de publicação e materialidade com apenas o NCT.** Antes de qualquer acesso CTgov adicional, paginação, consulta individual NCT, appraisal científico, alteração de produto ou Fase 5, exigir decisão própria. Não repetir workflow nem utilizar a autorização já consumida.

**STOP — CP265, recuperação técnica primeira página concluída, D2 ainda parcial.**
