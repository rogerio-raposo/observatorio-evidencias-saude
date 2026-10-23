# OES — Continuidade CP263: D2-CTGOV-E2 HTTP direto interrompido por DNS

**Data:** 2026-10-23. **Anterior:** CP262. **Conversa:** aberta.  
**Estado:** `PHASE_4_CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY / D2_CTGOV_E2_STOP_DNS_IN_EXECUTOR / PHASE_5_NOT_STARTED`.

## 1. Marco factual desta conversa

O proprietário autorizou **“Execução http autorizada”** após CP262 recomendar uma **única requisição HTTP direta** CTgov. Freshness Gate em `main` `427d94da3921e8ed4e7e39c0494142c9187f8f92` `identical` antes da operação. Foi efetuado **somente um comando `curl GET`** diretamente para a URL candidata `https://clinicaltrials.gov/api/v2/studies?query.cond=Insomnia&query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&sort=%40relevance&pageSize=20&countTotal=true&format=json`. Execução UTC `2026-10-23T20:33:01Z`, `curl` exit=6 `Could not resolve host: clinicaltrials.gov`; `http_code=000` indicador local **não** HTTP de origem; zero bytes transferidos. **Nenhum** JSON, NCT, `totalCount`, `returned_count`, status HTTP verdadeiro ou UTC da fonte observados; **nenhum retry** ou lookup NCT.

O **Documento 244** `docs/governance/244-d2-ctgov-e2-http-direto-dns-stop.md` registra autoridade, comando, parâmetros, erro e limites. O **Documento 243** (E1) descreve falha anterior de ferramenta de abertura de URL, não a mesma falha DNS comprovada em E2. **Não afirmar indisponibilidade ClinicalTrials.gov nem ausência de estudos**. Estado `D2_CTGOV_E2_STOP_DNS_IN_EXECUTOR` e **STOP**.

## 2. Estados canônicos preservados

- GitHub `rogerio-raposo/observatorio-evidencias-saude` branch `main`; ponteiro único `archive/handoffs/oes/README.md`; template `archive/continuity/OES_Template_Abertura_Continuidade.md`; `STATE.md` e `CHANGELOG.md`. Freshness Gate em toda retomada e antes de alterações.
- **Fase 4:** Documento 240, `PASS_DOCUMENTARY_ONLY` com C1–C6, `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; prontidão operacional `NOT_READY`; M3 `BLOCKED`; Fase 5 `NOT_STARTED`. Nenhuma revisão humana científica independente alegada.
- **D0** fechado documentalmente. **D1** demonstrador sintético memória restrito encerrado; T2-A2/A2-G4 diferido/não aceito, A2-G5 runtime não autorizado; branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1` não alterar/mesclar.
- **D2 factual global:** parcial. D2-E2 NCBI acesso real pontual (run GitHub Actions `39977371270`: 11 testes PASS, 4 PMIDs semente e 1 Shaffer na consulta literal). D2-E3 documental restrito encerrado Doc.236; docs 233–235 estudos/triagem e Doc.49 seção 14 rastreabilidade Zhou/Nazem. Ficha N2 `OES-P-2026-000401` A2 interno, baseline 2026-10-04, Docs.52/53, GRADE, `ProductVersion`, currentness, assurance inalterados.
- 36 migrations `UNREVIEWED`, BRG-03/06/07/08 bloqueados, BRG-09 parcial, SA-05/06/07/08/10 diferidos/abertos; sem operação factual persistente, Neon/SQL/CI, compra ou implantação. Suplemento binário Shaffer original na Biblioteca pessoal `/OES/source-supplements/supplementary_material_zsag264.zip` SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, não publicar, verificar acesso em novas conversas.

## 3. Acordos e próximo ato

Uma atividade delimitada por `Prossiga` seguida de STOP. Checkpoint normalmente a cada 3–5 atividades, antecipado quando materialidade/risco/handoff. Progresso durante trabalhos longos. Evitar repetir tentativas que falharam sem novo mecanismo; não reinventar framework/conector. Preferência por componentes maduros, nuvem e software gratuito, sem serviço pago ou implantação por inferência. Não usar ChatGPT Work.

**Próximo `Prossiga`: deliberar proporcionalmente** entre (A) um ambiente externo/GitHub Actions com saída HTTP/DNS auditável — *exige aprovação específica*, mesmo que já exista CI NCBI; (B) export oficial fornecido pelo titular; (C) diferir CTgov e avançar à seleção do primeiro incremento de stack/aplicação. Explicitar custo/benefício e não executar sem nova autorização. **Não repetir** a consulta no mesmo ambiente nem rodar CI espontaneamente. Fonte de origem CTgov **não verificada** nesta trilha.

**STOP — CP263; nenhum resultado científico novo.**
