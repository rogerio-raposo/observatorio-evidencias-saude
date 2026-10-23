# OES — Continuidade CP264: D2-CTGOV-E3 workflow criado, disparo pendente

**Data:** 2026-10-23. **Anterior:** CP263. **Conversa:** aberta.  
**Status:** `D2_CTGOV_E3_WORKFLOW_CREATED / DISPATCH_PENDING / SOURCE_RESPONSE_NOT_OBSERVED`.

## 1. Última autorização e progresso factual

O proprietário declarou **“Workflow aprovado.”** sobre a proposta expressa do Documento 245, para criar e efetuar **um único despacho manual** de consulta pública ClinicalTrials.gov API v2 via GitHub Actions, sem CI recursiva, queries NCT adicionais, Neon/SQL, custos ou ciência autoritativa.

Criado em `main`: `.github/workflows/d2-ctgov-single-public-get.yml`, commit **`aaebd17b4246c2623c36954d8bedc01795eb4912`**. Só dispara por `workflow_dispatch`, `contents: read`, runner Ubuntu 5 min, sem segredos/checkout/pacotes; uma única chamada GET com consulta Doc.242 (`query.cond=Insomnia`, `query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"`, `sort=@relevance`, `pageSize=20`, `countTotal=true`, `format=json`). Sem redirects ou retries. Limita resposta JSON a 2 MB, 20 estudos e NCTs únicos; logs públicos mínimos de URL codificada, UTC, status HTTP, totalCount/página/token e IDs; sem julgamento científico.

**Documento 246** `docs/governance/246-d2-ctgov-e3-workflow-criado-despacho-pendente.md` formaliza a autorização, o commit e a limitação: **a conexão GitHub desta conversa não expõe ação para disparar workflow**, portanto **nenhum despacho foi efetuado pelo assistente, nenhum run/HTTP/JSON de ClinicalTrials.gov foi observado**. Não declarar `PASS` de recuperação, mesmo com YAML aprovado. **A criação do workflow não prova sua execução**. Não repetir tentativa de DNS efêmero.

## 2. Ponto exato de retomada e autorização já concedida

O proprietário já autorizou **uma execução**, sem necessidade de voltar a aprovar a mesma ação. Para materializar o ato, abrir uma vez:
`https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/workflows/d2-ctgov-single-public-get.yml`
→ **Run workflow** → branch `main` → **Run workflow** (uma vez). Compartilhar link da execução `https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/<ID>`. Ao receber link, buscar status, jobs e logs por GitHub connector, reconciliar `PASS/PARTIAL/STOP` factual, preservar condições de saída; **não** acionar rerun nem buscar adicionalmente NCT sem nova decisão.

Se o botão não aparecer, registrar impedimento da UI e decidir se export oficial/manual ou diferimento; não inventar outro canal, não criar workflow alternativo. Não expor segredos nos logs.

## 3. Governança canônica

Repositório `rogerio-raposo/observatorio-evidencias-saude` branch `main`, ponteiro `archive/handoffs/oes/README.md`, template `archive/continuity/OES_Template_Abertura_Continuidade.md`; ler `STATE.md`, `CHANGELOG.md`. Freshness Gate no início e antes de commits; cada `Prossiga` uma atividade e STOP, checkpoints proporcionais; relatórios de progresso durante trabalho longo. Não usar ChatGPT Work. Não repetir engenharia prematura/implementações existentes.

**Fase 4:** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, gate Doc.240 `PASS_DOCUMENTARY_ONLY` com condições C1–C6, `OPERATIONAL_NOT_READY`; Fase 5 `NOT_STARTED`, M3 `BLOCKED`.
**D0** documental fechado; **D1** `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, A2-G4 diferido/não validado e A2-G5 runtime não autorizado; branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, não alterar/mesclar.
**D2** factual parcial: D2-E2 NCBI run `39977371270` sucesso técnico restrito; D2-E3 Doc.236 reconciliação Shaffer restrita; CTgov E1 e E2 pararam por canal URL e DNS, Docs.243–244; E3 workflow criado, sem execução. Ficha N2 `OES-P-2026-000401` baseline 2026-10-04, A2 interno; GRADE/currentness/ProductVersion/assurance sem mudança. ZIP original Shaffer em Biblioteca pessoal `/OES/source-supplements/supplementary_material_zsag264.zip`, checksum `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, não inserir no GitHub.
**Controles:** 36 migrations `UNREVIEWED`, BRG-03/06/07/08 `BLOCKED`, BRG-09 parcial, SA-05/06/07/08/10 diferidos/abertos, sem executor persistente homologado, sem Neon/SQL ou serviços pagos.

**STOP — CP264, aguardando somente a materialização do disparo manual já autorizado.**
