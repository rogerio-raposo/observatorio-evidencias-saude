# OES — Continuidade CP258: triagem focal e pré-appraisal Zhou/Nazem

**Data:** 2026-10-23  
**Anterior:** CP257  
**Natureza:** checkpoint proporcional de continuidade, **sem encerrar a conversa** e **sem promover gates**.  
**Estado corrente:** `D2_E3_A3_PRELIMINARY_METHOD_APPRAISAL_COMPLETED / NO_PROVEN_MATERIAL_CHANGE / FORMAL_ROB2_NOT_VALIDATED / PRODUCT_UNCHANGED`.

## 1. Fonte de verdade, acordos de trabalho e retomada

Repositório `rogerio-raposo/observatorio-evidencias-saude`, branch `main`. Ponteiro canônico único `archive/handoffs/oes/README.md`; template `archive/continuity/OES_Template_Abertura_Continuidade.md`; `STATE.md` e `CHANGELOG.md`. Ao retomar, ler ponteiro, handoff e documentos relevantes; executar **Freshness Gate** antes da ação e do commit. Conversa atual **continua aberta**.

Cada **`Prossiga`** autoriza uma atividade delimitada; STOP ao final; checkpoint persistente normalmente após 3–5 atividades ou materialidade/risco. Mostrar progresso em tarefas mais longas. Exigir autorização expressa para elevar risco/escopo, alteração científica ou operações conectadas. Não usar ChatGPT Work. Evitar repetição de arquiteturas/testes e soluções próprias para problemas atendidos por ferramentas existentes. Modos: médio para trabalho documental; alto para análise científica e gates.

## 2. Linha evolutiva após CP257

- **CP257 (protetivo)**: documentada cadeia D2-E2 (prova NCBI bem-sucedida no [run 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270), 11/11 testes, quatro sementes, um registro PMID 42841437 na consulta executada), triagem Shaffer e ZIP original em Biblioteca.
- D2-E3/A1 e seu suplemento: `docs/governance/232-d2-e3-a1-shaffer-triagem-dirigida-preliminar.md` (histórico) e `233-d2-e3-a1-reconciliacao-suplemento-shaffer.md` (atual): **dez RCTs únicos, 12 contrastes** na análise SHUTi/educação on-line; Christensen/HealthWatch não compara educação sobre sono; variantes Zhou/OASIS compartilham controles; publicação da revisão Shaffer em 2026-10-07, busca da própria revisão até 2025-10-07. Nenhum novo RCT pós-baseline OES foi demonstrado nesse subconjunto.
- **D2-E3/A2 expressamente aprovado e executado**: `docs/governance/234-d2-e3-a2-triagem-focal-pico-estudos-shaffer.md`. Candidatos diretos **Zhou 2022**, **Nazem 2023** e **OASIS 2025 apenas autoguiado** (já documentado pelo OES); contextual/indireto por população **Verlinden 2023** (consumo elevado de álcool) e **Malarkey 2024** (traumatismo cranioencefálico). Zhou um RCT NCT03613519, SHUTi/SHUTi-BWHS vs educação, dois contrastes com controle compartilhado. Nazem NCT03366870. OASIS NCT03213132; braço stepped support é **apoio de engajamento, não automaticamente terapia humana regular**.
- Adendo de sobreposição no Doc 234: Hwang 2025 **29 RCTs, 32 contrastes**, subgrupo educação online **k=10**. Nomenclatura de braços da Figura 3 de Hwang sustenta vínculo forte com Zhou, mas entrada exata no subgrupo k=10 sem confirmação tabular; Nazem em Hwang **NOT_VERIFIED**. Ambos constam da revisão Nazari, **o que não prova entrada no pooling Hwang**. Não confundir os dez contrastes Hwang com os dez RCTs Shaffer.
- **D2-E3/A3**: usuário autorizou “Autorizo as avaliações. Prossiga.”; documento `docs/governance/235-d2-e3-a3-avaliacao-metodologica-focal-zhou-nazem.md`. Avaliação **preliminar, não RoB 2 formal validado por avaliadores independentes**, restrita ao ISI pós ~9 semanas. Cinco domínios: Zhou D1 algumas preocupações, D3 preocupação importante/alto risco possível devido perdas relacionadas a completar sessões (5,4 vs 2,2), D4/D5 algumas preocupações ou informação insuficiente; Nazem D1 baixo preliminar, D3 algumas preocupações (**91/116** vs **98/115** com ISI pós; ~78,4% vs 85,2%), D4/D5 preocupações ou NI. Estimativas favorecem dCBT-I em direção; **sem nova meta-análise, RoB2 formal, mudança comprovada de materialidade, certeza ou conclusão**.
- Anomalia de extração Nazem: o resumo PubMed registra limite superior **+1,88** para IC da terceira diferença de mudança do ISI, enquanto texto integral/Tabela 3 indicam **−1,88** (seguimento de 1 ano); no **pós** o contraste ajustado reportado é **−3,47 (IC95% −4,78 a −2,16)**. Não confundir timepoints nem estimandos, e não reestimar o produto a partir desses dados.

## 3. Fonte binária externa e preservação

O usuário enviou arquivo original `supplementary_material_zsag264.zip` de Shaffer e ele foi **preservado na Biblioteca pessoal** `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, tamanho **757.171 bytes**. Quatro componentes: DOCX suplemento, duas XLSX (triagem excluídos e avaliação JBI), PDF checklist PRISMA. Não distribuir ou publicar binários de terceiros na `main`. Em nova conversa testar acesso real à Biblioteca antes de confiar em bytes; usar Docs. 233–235 como fontes textuais canônicas, não supor acesso persistente automático. Erro `#REF!` em 37 células da aba intermediária JBI observado em CP257; não adotar planilha como validação RoB.

## 4. Estado e bloqueios preservados

D0 documental encerrado. D1 `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`; T1/T2-A1 sintéticos históricos; T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE/NOT_TECHNICALLY_ACCEPTED`; A2-G5/runtime não autorizado. Branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1` não alterar/mesclar.

Produto `OES-P-2026-000401` Ficha N2 dCBT-I vs educação digital sono (ISI pós), baseline **2026-10-04**, permanece **A2 interno**, sem revisão especialista independente. Nenhuma atualização de `docs/products/`, ProductVersion, ROBIS/GRADE, certeza, currentness, assurance ou gate. Riscos SA-05/06/07/08/10 abertos/diferidos; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrations `UNREVIEWED`. Não houve nova execução CI/NCBI, Neon, SQL, implantação ou custos.

## 5. Próxima decisão — exata e proporcional

**Próximo `Prossiga`: deliberar se o ganho documental de acrescentar referências rastreáveis de Zhou e Nazem ao inventário de evidências do produto N2 compensa uma atualização documental restrita, sem modificar resultados e conclusões.** Uma atualização de arquivo de produto exige **autorização expressa** e deve distinguir referência conhecida, inclusão Hwang ainda incerta, viés preliminar e ausência de evidência pós-baseline. Se não houver benefício, encerrar D2-E3 neste nível. **Não** repetir buscas de sobreposição Hwang, RoB2 completo, cálculo de SMD, revisão GRADE ou criar novos conectores sem justificativa científica explícita.

**STOP — CP258.**
