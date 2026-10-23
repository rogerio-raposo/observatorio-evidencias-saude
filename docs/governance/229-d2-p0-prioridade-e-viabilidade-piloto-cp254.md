# Documento 229 — Prioridade D2-P0 e viabilidade de piloto factual delimitado (CP254)

**OES | 2026-10-23 | APPROVED_D2_P0_SCIENTIFIC_PILOT_SCOPING_ONLY | DOCUMENTARY_ONLY**

## 1. Aprovação expressa e escopo

O proprietário aprovou, em conversa após CP253, a proposta `OES / D2-P0 / SCIENTIFIC_PILOT_SCOPING_ONLY` para **preparação científica e delimitação documental** de um piloto factual mínimo. Essa aprovação não autoriza executar o piloto, fazer consultas científicas, coletar dados, usar banco, CI, código, serviços externos pagos, implantar ou modificar gates. O demonstrador D1 permanece `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY` segundo Documento 228.

## 2. D2-P0/A1 — Seleção preliminar

Comparados quatro casos existentes: Ficha N2 dCBT-I (A2 interno), Resposta N1 música/ansiedade perioperatória (A2 interno), Evidence Scan N0 GenAI e saúde mental (A1 interno) e Síntese Rápida N3 ambient AI scribes (A0 experimental, metodologicamente bloqueada). **Candidato preferencial, não piloto executado:** produto `OES-P-2026-000401`, Ficha N2 sobre dCBT-I totalmente automatizada em adultos com insônia versus educação digital sobre sono/higiene, com gravidade de insônia pós-tratamento como desfecho principal. Escolha favorecida pela pergunta PICO delimitada, busca e síntese documental já existentes, baseline e status A2 internos. A ausência de revisão especializada independente deve ser divulgada; A2 não é A3.

## 3. D2-P0/A2 — Especificação científica mínima

**Pergunta:** em adultos com insônia, dCBT-I multicomponente totalmente automatizada e autoguiada, comparada com educação digital sobre sono/higiene do sono, reduz gravidade da insônia após tratamento? Principal desfecho ISI (ou escala validada compatível), janela preferencial de primeiro pós-tratamento ~6–12 semanas. Ensaios randomizados para efeito e revisões sistemáticas/meta-análises para contextualização.

**Baseline documental OES:** 2026-10-04; diferente do corte da síntese Hwang 2025 (2024-03-31). Publicação posterior ao corte não é automaticamente estudo novo. Fontes candidatas: PubMed/MEDLINE (inicial), ClinicalTrials.gov (identidade de trials e múltiplas publicações), BVS/LILACS (complementação regional) e Cochrane Library (dirigida, quando acessível). Escopo pode ser escalonado; não afirmar busca exaustiva. Estratégias conceituais já constam nos Documentos 48–49; quando autorizada, exigir conferência de sensibilidade com estudos-semente e registro literal de consultas e filtros.

Classificar registros como novo candidato elegível, referência previamente conhecida, publicação vinculada ao mesmo ensaio, evidência contextual, inelegível ou indeterminada. Deduplicar em dois níveis: **referência bibliográfica** e **estudo/ensaio**, usando DOI, PMID, identificador de registro, título e relações entre relatórios. Motivos de triagem e incertezas devem ficar rastreáveis.

**Registro mínimo:** fonte, consulta/filtros literais, hora, restrições, quantidade de hits informada quando disponível, itens recuperados e examinados (distintos), identificadores, vínculo ao produto e baseline, proveniência, decisões de deduplicação/triagem, sinal de possível materialidade, responsável e justificativa. Não inventar contagem bruta ausente.

**Sucesso futuro do piloto:** recuperação reproduzível dentro dos limites declarados; proveniência e identidade verificáveis; triagem rastreável; documentação de candidatos, ou de ausência deles, com cobertura explicitada; nenhuma alteração automática do produto ou da conclusão. Falha de cobertura, indisponibilidade de fonte, rastreabilidade insuficiente e identificação não resolvida levam a interrupção/inconclusão, **não** à alegação de inexistência de nova evidência.

## 4. D2-P0/A3 — Viabilidade integrada e pré-autorização

**Parecer documental:** `FEASIBLE_WITH_BOUNDED_OPERATIONAL_AUTHORIZATION`. Não é `OPERATIONALLY_READY`. Pergunta, baseline, elegibilidade e fontes candidatas documentados; mecanismo concreto de recuperação factual auditável ainda não verificado neste marco. A pesquisa histórica do Documento 49 não expôs contagem bruta confiável; nenhum hit count novo é alegado.

**Solução mínima recomendada:** futura consulta pontual em fonte pública, preferencialmente com ferramentas existentes; registro versionado/estruturado e descartável, sem banco; ClinicalTrials.gov para vínculo de ensaios quando pertinente. **Não selecionar stack, construir conector, reabrir A2-G4 ou exigir PostgreSQL** antes de demonstrar necessidade funcional. Mecanismo e reprodutibilidade devem ser confirmados na própria autorização de execução.

A identificação de sinal **não** altera `currentness`, `ProductVersion`, conclusão, GRADE, assurance, publicação ou gates. Avaliação científica material e alterações exigem fluxo metodológico e autorizações próprias (Documento 05).

## 5. Próxima decisão operacional — proposta ainda não aprovada

**Candidata:** `OES / D2-E1 / FIRST_FACTUAL_RETRIEVAL_READ_ONLY`.

Somente após autorização expressa específica, considerar primeira recuperação bibliográfica real de leitura, delimitada ao PICO dCBT-I e às fontes definidas, com consulta literal, registros/proveniência, deduplicação preliminar e relatório científico não conclusivo. Não autorizar por inferência: código de aplicação, SQL/Neon, CI, hospedagem, alteração de Ficha, publicação, atualização de síntese/GRADE, currentness ou gates.

**D2-E1 permanece `NOT_AUTHORIZED` neste checkpoint.** Evitar novos ciclos documentais redundantes: próximo ato é a deliberação delimitada sobre D2-E1 (e seu mecanismo), não uma nova arquitetura prévia.

## 6. Estados preservados

- D1 reescopado `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`; T1/T2-A1 inalterados, evidência histórica 36/75 PASS; nenhum reteste.
- T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`; A2-G5/runtime `NOT_AUTHORIZED`. Branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, não alterar ou mesclar.
- SA-05/06/07/08/10 permanecem riscos abertos e diferidos; não resolvidos.
- Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrations `UNREVIEWED`. D2 operacional permanece não iniciado. Nenhum gate científico/operacional promovido.

**STOP — CP254 exclusivamente documental; nenhuma consulta factual ou execução de piloto.**
