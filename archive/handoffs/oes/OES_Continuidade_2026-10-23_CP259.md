# OES — Handoff CP259: encerramento documental restrito D2-E3

**Data:** 2026-10-23  
**Anterior:** CP258  
**Natureza:** checkpoint de fechamento proporcional; não encerra a conversa nem promove o estado científico/operacional de D2.  
**Estado corrente:** `D2_E3_CLOSED_RESTRICTED_DOCUMENTARY_RECONCILIATION_ONLY`.

## 1. Fonte canônica e protocolo de trabalho

Repositório `rogerio-raposo/observatorio-evidencias-saude`, branch `main`, ponteiro único `archive/handoffs/oes/README.md`, template `archive/continuity/OES_Template_Abertura_Continuidade.md`, estado `STATE.md` e `CHANGELOG.md`. Na retomada, consultar ponteiro, CP259 e docs específicos e verificar HEAD com **Freshness Gate** antes de agir/commitar. Histórico de CP258 pode não mostrar D2-E3/A4: CP259 registra o adendo subsequente.

**Forma de trabalho:** uma atividade por `Prossiga`, **STOP** depois; checkpoints normalmente após 3–5 atividades ou materialidade/risco; progresso visível nas etapas longas; autorização específica para mudanças de risco, ciência, execução conectada ou produto. Evitar ciclos de repetição e infraestrutura reinventada; usar ferramentas existentes. Modos médio/alto conforme risco. **Não utilizar ChatGPT Work**. Conversa permanece aberta.

## 2. Encadeamento factual e artefatos

- **D2-E2:** mecanismo Python NCBI ESearch/ESummary `prototypes/d2_e2/`, workflow manual `.github/workflows/d2-e2-single-ncbi-probe.yml`. [Run 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270) `success`, 11 testes PASS, 4 PMIDs-semente, ESearch count=1 em consulta literal 2026-10-05 a 2026-10-23, um PMID Shaffer 42841437. **PASS técnico pontual**, não busca exaustiva; não repetir CI por inferência.
- **D2-E3/A1:** meta-análise de Shaffer (2026-10-07), DOI `10.1093/sleep/zsag264`, artigo cuja busca terminou 2025-10-07. Docs. `232` (histórico pré-suplemento) e `233` (suplemento reconciliado): **dez RCTs distintos, 12 estimativas/contrastes**; Christensen/HealthWatch não é educação sobre sono; Zhou e OASIS com braços compartilhando controles; não importar estimativa meta-analítica de Shaffer como se fosse o PICO e estimando Hwang.
- **D2-E3/A2:** Doc. `234`, Zhou 2022 e Nazem 2023 candidatos diretos PICO, OASIS autoguiado direto/já considerado OES; Verlinden/Malarkey contextuais por população. Hwang 2025: `k=10` educação on-line, valor SMD -0,93 e I²=68%; pertencimento exato de Zhou ao pooling não auditado, Nazem em Hwang `NOT_VERIFIED`. Ambos em Nazari; não confundir presença em uma revisão com inclusão no subgrupo de outra.
- **D2-E3/A3:** Doc. `235`, apreciação inicial de cinco domínios RoB 2 para ISI pós de Zhou/Nazem, `AT_LEAST_SOME_CONCERNS` (dados ausentes e mensuração autorreferida), **não** RoB2 formal independente. Nazem 91/116 vs 98/115 avaliados no pós; ambiguidade de sinal de IC entre resumo e texto para **seguimento de um ano** registrada, não extrapolar ao efeito primário.
- **D2-E3/A4:** autorização expressa `Autorizado. Prossiga.`; Doc. `docs/products/49-caso-real-01-busca-triagem-inicial.md` **seção 14** acrescentada, somente proveniência/identificadores e limitações Zhou/Nazem; texto histórico e cutoff **2026-10-04** preservados. **Não** atualizar síntese/estimativa/certeza ou Ficha N2.
- **Encerramento técnico-documental:** `docs/governance/236-d2-e3-encerramento-restrito-rastreabilidade-shaffer-cp259.md` contém alcance, tabela de evidências, pendências não resolvidas e decisão explícita `D2_E3_CLOSED_RESTRICTED_DOCUMENTARY_RECONCILIATION_ONLY`.

## 3. Fonte original e restrições

O proprietário anexou `supplementary_material_zsag264.zip`, preservado na **Biblioteca pessoal do ChatGPT**, `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, tamanho **757.171 bytes**. DOCX, duas XLSX e PDF PRISMA no ZIP. Binários não estão no GitHub público. Em outra conversa verificar o acesso à Biblioteca antes de presumir disponibilidade. A planilha JBI intermediária apresentava 37 `#REF!` literais; não tratar como appraisal validado.

**Resultados não autorizados/não demonstrados:** atualização científica pós-baseline, busca sistemática global, julgamento final RoB 2 independente, verificação exaustiva de sobreposição Hwang por estimativa, nova meta-análise, ROBIS formal de Shaffer, nova certeza GRADE, atualização de `currentness`, `ProductVersion`, conclusão clínica ou gate. A nova síntese Shaffer publicada em 2026 **não** demonstrou RCT publicado após baseline OES 2026-10-04 naquele subconjunto.

## 4. Estados preservados

Produto N2 `OES-P-2026-000401` dCBT-I versus educação digital sobre sono, ISI pós, permanece **A2 interno**, sem revisão científica especializada independente, documentos 52/53 e Ficha inalterados, sem assurance/currentness/gate promovidos.

D0 documental encerrado. D1 `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, T1/T2-A1 histórico sintético, T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`; A2-G5/runtime `NOT_AUTHORIZED`. Branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` mantida no SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1` e não mesclada. Riscos SA-05/06/07/08/10 abertos e diferidos; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrations `UNREVIEWED`. Sem Neon, SQL, produção, CI adicional ou serviços pagos.

## 5. Próximo `Prossiga` — ponto exato de retomada

**Preparar apenas uma decisão de prioridade sobre o próximo avanço factual proporcional de D2**, partindo do cliente NCBI já verificado e dos controles científicos construídos. Comparar opções de contribuição tangível (por exemplo, ampliar a cobertura de fontes ou tornar a recuperação repetível com proveniência, sem presumir lacunas já resolvidas), escopo/custo/risco e necessidade de autorização específica. **Não executar** nova coleta real, workflow, código, banco, reanálise de Hwang/Shaffer, appraisal, nova publicação ou gate automaticamente. Evitar recriar frameworks ou reabrir D2-E3 sem fato novo relevante.

**STOP — CP259, conclusão documental delimitada, conversa aberta.**
