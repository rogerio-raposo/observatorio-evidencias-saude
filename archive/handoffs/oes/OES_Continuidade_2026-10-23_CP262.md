# OES — Continuidade CP262: D2 ClinicalTrials.gov primeira tentativa sem resposta da fonte

**Data:** 2026-10-23. **Anterior:** CP261. **Conversa atual:** aberta.  
**Estado:** `PHASE_4_CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY / D2_CTGOV_E1_STOP_TOOL_URL_INACCESSIBLE / PHASE_5_NOT_STARTED`.

## 1. Decisões recentes após CP261

- **Documento 241** `docs/governance/241-prioridades-pos-fase4-d2-multifonte-delimitado.md`: avaliação proporcional das prioridades pós-F4; sugerido D2 factual multifonte público limitado antes da seleção de stack. Proprietário **“Prioridade aprovada.”**, aprovação somente de planejamento; sem autorização automática de nova operação.
- **Documento 242** `docs/governance/242-d2-clinicaltrials-preflight-api-v2-prioridade-aprovada.md`: preflight documental da ClinicalTrials.gov API v2 (`query.cond=Insomnia`, `query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"`, `sort=@relevance`, `pageSize=20`, `countTotal=true`, `format=json`); uma página, até três NCT opcionais como controles em limite total de quatro GET. Nenhuma chamada de estudos nesse ato.
- Proprietário **“Aprovada a primeira consulta conectada.”** Documento **243** `docs/governance/243-d2-ctgov-e1-consulta-conectada-indeterminada-stop.md`: ferramenta de abertura pública retornou `URL ... is not accessible via this tool`, inclusive ao tentar a URL com `&` corretamente separados; **nenhum HTTP originário da API, body, totalCount, NCT ou horário da fonte observado**. Um primeiro endereço com `%26` mal codificados também falhou pela ferramenta; transparência de tentativas no Doc. 243. **STOP**, sem repetir com outros meios e sem três lookups NCT. Resultado `D2_CTGOV_E1_STOP_TOOL_URL_INACCESSIBLE / NO_SOURCE_RESPONSE_OBSERVED`, **não** declarar API indisponível nem `0` resultados.
- Nenhuma alteração de Ficha, GRADE, currentness, assurance, ProductVersion, gates, CI/Neon/SQL, serviços pagos ou Fase 5. Apenas documentação de autorização/tentativa e estado.

## 2. Fonte canônica e acordos

GitHub `rogerio-raposo/observatorio-evidencias-saude`, `main`, ponteiro `archive/handoffs/oes/README.md`, template `archive/continuity/OES_Template_Abertura_Continuidade.md`, `STATE.md`, `CHANGELOG.md`. Sempre Freshness Gate no início e antes de commits. Um `Prossiga` = uma atividade e STOP; checkpoints geralmente a cada 3–5 atividades ou marco material. Informar progresso em tarefas extensas. **Não usar ChatGPT Work**. Evitar soluções artesanais repetitivas onde frameworks existentes atendem; não reabrir busca Shaffer/Hwang sem fato novo. Preferência do titular por cloud e software gratuito, mas sem contratação/infra por inferência.

## 3. Estados preservados

- **Fase 4** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Documento 240 gate `PASS_DOCUMENTARY_ONLY` com C1–C6; readiness operacional `NOT_READY`, `M3 BLOCKED`, Fase 5 `NOT_STARTED`. Zero cenários AT executados end-to-end no gate; nenhuma revisão independente.
- **D0** fechado documentalmente, **D1** `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`. D1 T2-A2/A2-G4 diferido/não validado, A2-G5/runtime não autorizado; branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1` não alterar/mesclar.
- **D2** factual global parcial. D2-E2 cliente NCBI via CI autorizada pontualmente, run `39977371270` com 11 testes, 4 PMIDs-semente, 1 Shaffer na query literal; não busca sistemática. D2-E3 triagem/reconciliação documental restrita encerrada Doc.236; N2 `OES-P-2026-000401` A2 interno, baseline 2026-10-04, adendo Doc.49 Zhou/Nazem; Docs.52/53 e ciência inalterados.
- 36 migrations `UNREVIEWED`, SA-05/06/07/08/10 abertos/diferidos, BRG-03/06/07/08 bloqueados, BRG-09 parcial; ausência de executor factual persistente aprovado, auditoria/backup/restore/ledger não homologados. O resultado D2-CTGOV `STOP` **não** concede nem reduz BRG.
- ZIP binário Shaffer original na Biblioteca pessoal `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`; verificar acesso real em nova conversa, não subir para GitHub.

## 4. Ponto exato de retomada

**Próximo `Prossiga`: não repetir URL no mesmo mecanismo.** Primeiro promover uma **deliberação proporcional** entre: (A) nova autorização específica para um **único caminho alternativo de GET público JSON** com status/UTC/resposta verificáveis, sem construir stack e sem CI por padrão; (B) usar export oficial fornecido pelo titular; (C) diferir ClinicalTrials e avaliar primeiro incremento de stack/aplicação. Avaliar custo, garantia de proveniência, disponibilidade do mecanismo e benefício; **não executar outra consulta** até decisão expressa. Tratar tentativas já feitas como `source_response_not_observed`, não como falha HTTP da API. Conversa aberta.

**STOP — CP262 checkpoint de falha de acesso, sem promoção científica/operacional.**
