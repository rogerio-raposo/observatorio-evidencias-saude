# OES — Handoff CP257: preservação de continuidade D2-E3/A1

**Data:** 2026-10-23  
**Anterior:** CP256  
**Estado:** `D2_E3_A1_SHAFFER_STUDY_SET_RECONCILED / PICO_ELIGIBILITY_PARTIAL / SCIENTIFIC_MATERIALITY_NOT_ASSESSED`  
**Natureza:** checkpoint de segurança de continuidade; **não** encerramento da conversa nem promoção científica, técnica ou operacional.

## 1. Regra de fonte canônica e avanço

Repositório GitHub: `rogerio-raposo/observatorio-evidencias-saude`; branch de trabalho `main`; ponteiro único `archive/handoffs/oes/README.md`; estado `STATE.md`; changelog `CHANGELOG.md`. Ao retomar, consultar este handoff e executar **Freshness Gate** antes de agir. Não confiar exclusivamente em memória ou no texto de outra conversa.

Trabalhar com **uma atividade delimitada por `Prossiga`**, evitando documentação repetitiva e reinvenção desnecessária de infraestrutura. Checkpoint normalmente após 3–5 atividades internas, antecipado por risco, mudança de gate ou ameaça à continuidade. Antes de persistir, verificar HEAD. Informar progresso nas tarefas longas. **STOP** ao final de cada atividade. Pedir aprovação expressa para mudanças de risco ou escopo (código operacional, CI conectada, alteração científica/produção). Proprietário optou por **não utilizar ChatGPT Work**.

## 2. Marcos e evidência factual

- D0 documental encerrado; D1 demonstrador reescopado `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, T1/T2-A1 restritos; T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`, A2-G5/runtime `NOT_AUTHORIZED`.
- D2-P0 aprovado documentalmente; candidato prioritário Ficha N2 `OES-P-2026-000401`: adultos com insônia, dCBT-I autoguiada totalmente automatizada vs educação digital de sono, gravidade ISI no pós-tratamento de ~6–12 semanas; baseline **2026-10-04**, distinto do corte Hwang **2024-03-31**.
- D2-E1 leitura factual PubMed resultou `PARTIAL_RETRIEVAL / SEARCH_REPRODUCIBILITY_NOT_VERIFIED` no mecanismo inicial (CP255), não conclusão científica.
- D2-E2/A1 cliente Python `prototypes/d2_e2/`, API oficial NCBI ESearch/ESummary; A2 aprovação expressa `SINGLE_CONNECTED_NCBI_PROBE`; workflow manual `.github/workflows/d2-e2-single-ncbi-probe.yml`. GitHub Actions [run 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270) `success`, **11/11 testes PASS**, **4/4 PMIDs-semente** recuperados, consulta PubMed com filtro 2026-10-05 até 2026-10-23 `count=1`, ESummary 1 registro: Shaffer 2026 PMID **42841437**, DOI `10.1093/sleep/zsag264`. **PASS exclusivamente de mecanismo técnico, não sensibilidade ou exaustividade científica.** Não repetir workflow sem nova autorização.
- D2-E3/A1 `TARGETED_SHAFFER_ELIGIBILITY_AND_OVERLAP_SCREENING` expressamente aprovado. Primeiro parecer `docs/governance/232-d2-e3-a1-shaffer-triagem-dirigida-preliminar.md` havia identificado estudo mas não acessado suplemento. Proprietário enviou ZIP; reconciliação oficial detalhada e atual `docs/governance/233-d2-e3-a1-reconciliacao-suplemento-shaffer.md`, com nota histórica no 232. **Doc 233 prevalece sobre o 232 quanto à limitação do suplemento e à identidade dos estudos**.

## 3. Resultado mais recente — suplemento Shaffer original

Meta-análise de Shaffer publicada eletronicamente em **2026-10-07**, busca própria até **2025-10-07**, 25 estudos/29 publicações no corpo amplo. Figuras suplementares S1a/S9a identificam **10 RCTs distintos e 12 contrastes** na comparação SHUTi/educação online (múltiplos braços compartilhando controles):
**Hagatun 2019; Christensen 2016; Ritterband 2017; Vedaa 2020; Glozier 2019; Zhou 2022; Verlinden 2023; Nazem 2023; Malarkey 2024; Ritterband 2025 (SHUTi OASIS).**

- **Christensen 2016/HealthWatch não é educação sobre sono**, logo não aderente ao comparador principal.
- **Zhou 2022**: dois braços SHUTi com um mesmo controle; **Ritterband 2025/OASIS**: braço autoguiado e braço com suporte escalonado; não duplicar RCT ou controle.
- Hagatun, Christensen, Ritterband 2017, Vedaa 2020, Glozier já constam na síntese-base Hwang; SHUTi OASIS já consta dos documentos narrativos N2. Zhou, Verlinden, Nazem e Malarkey exigem exame focal de elegibilidade e da presença no inventário OES; alguns apresentam populações especiais/indiretas, e **não** representam ensaios primários posteriores ao baseline OES.
- Um ensaio pode ter múltiplas publicações: deduplicar por **estudo/NCT**, não apenas título/PMID.
- Fig. S1a SMD mudança ISI `-1.03` (IC95% -1.23,-0.83; I² 63,3%); Fig. S9a SMD pós-tratamento `+0.93` (IC95% 0.75,1.12; I² 76,9%). **Estimandos/convenções de sinal distintos; nenhuma substituição automática da estimativa Hwang.**
- Planilha JBI intermediária `Comparison - RCT` apresenta **37 células literais `#REF!`**; não importar como appraisal científico validado. Não extrapolar erro a todas as abas.
- Resultado `STUDY_SET_RECONCILED / PICO_ELIGIBILITY_PARTIAL / SCIENTIFIC_MATERIALITY_NOT_ASSESSED`. Não há nova meta-análise, reestimativa GRADE, alteração de currentness, conclusão nem promoção de gate.

## 4. Preservação permanente do insumo original — separada do GitHub público

O ZIP suplementar original foi enviado pelo proprietário durante a conversa e **copiado com confirmação de leitura de listagem para a Biblioteca pessoal do ChatGPT**, em:

`/OES/source-supplements/supplementary_material_zsag264.zip`

**SHA-256:** `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`  
**Tamanho:** 757.171 bytes.  

Contém quatro arquivos: `Final_SHUTi-MA_SupplementalMaterials_Accepted_Submit.docx`, `Final_Supplemental Appendix 1 - Full Text Screen Excluded.xlsx`, `Final_Supplemental Appendix 2 - JBI RoB Assessment Results.xlsx`, `SHUTi-MA_PRISMA_submit.pdf`.

**Importante:** a Biblioteca pessoal é separada do GitHub. Em eventual nova conversa, verificar acesso real à Biblioteca/Project antes de depender dos bytes; se indisponível, solicitar apenas a reapresentação desse mesmo ZIP ou recuperá-lo legitimamente no editor. **Nunca inferir que o ZIP está no repositório ou republicar material da editora no GitHub público**. A análise derivada (Documentos 232/233) está persistida no GitHub, e o hash permite verificar identidade do original.

## 5. Controles e bloqueios não alterados

Ficha N2 continua A2 interno, sem revisão independente e sem atualização de ProductVersion/GRADE/assurance/currentness. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`; SA-05/06/07/08/10 abertos/diferidos; 36 migrations `UNREVIEWED`. Sem nova consulta PubMed, workflow/CI, Neon, SQL, implantação, serviço pago ou uso de ChatGPT Work neste checkpoint. Branch de preservação experimental `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` fixada no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`; não mesclar ou modificar.

## 6. Próxima atividade exata — não executar automaticamente

**Próximo `Prossiga`: preparar decisão metodológica proporcional para triagem focal de PICO/aplicabilidade dos estudos Zhou 2022, Verlinden 2023, Nazem 2023, Malarkey 2024 e braço apropriado de OASIS, usando Doc 233 e suplemento já preservado.** Especificar separadamente elegibilidade direta/indireta, sobreposição estudo-relatório, identidade do controle e controles compartilhados. **Antes de executar appraisal de risco de viés, reanálise de efeito, nova consulta factual ou revisão do produto, exigir nova aprovação expressa.** Não repetir pesquisas ou reconstruir frameworks já resolvidos.

A conversa atual **permanece aberta**; CP257 é checkpoint preventivo para reduzir risco de perda de continuidade, não mudança imediata de conversa.

**STOP — CP257.**
