# OES — Handoffs de Continuidade

**Status:** artefato operacional  
**Finalidade:** servir como **único ponteiro operacional** para a retomada do desenvolvimento do Observatório de Evidências em Saúde — OES.

## Arquitetura de continuidade

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

## Checkpoint vigente

**CP21 — 2026-10-04**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-04_CP21.md`

Checkpoint anterior:

`CP20`

Status:

> vigente para continuidade operacional, sujeito ao Freshness Gate.

## Template canônico

Utilizar:

`archive/continuity/OES_Template_Abertura_Continuidade.md`

em **Modo Continuidade**.

## Procedimento de retomada

1. consultar este `README.md` para identificar o checkpoint vigente;
2. consultar o template canônico;
3. ler integralmente o checkpoint indicado;
4. aplicar o Freshness Gate contra a branch `main`;
5. consultar `STATE.md` e documentos canônicos materialmente relacionados;
6. apresentar o Diagnóstico de Continuidade;
7. se não houver alteração material, retomar exatamente do **Ponto exato de retomada**;
8. se houver alteração material, registrar a divergência e ajustar o ponto de retomada conforme a documentação canônica.

## Prompt operacional de retomada

> Consulte no repositório `rogerio-raposo/observatorio-evidencias-saude` o arquivo `archive/continuity/OES_Template_Abertura_Continuidade.md` e utilize-o em **Modo Continuidade**. Consulte `archive/handoffs/oes/README.md` para identificar o checkpoint vigente e leia integralmente o handoff indicado. Aplique o Freshness Gate contra a branch `main`, apresente primeiro o Diagnóstico de Continuidade e, se não houver alteração material, retome do **Ponto exato de retomada** registrado no checkpoint vigente.

## Política de checkpoint

- checkpoints são snapshots autônomos e imutáveis;
- todo novo CP referencia o anterior;
- checkpoints antigos permanecem preservados;
- este README é o único ponteiro para o checkpoint vigente;
- somente este README contém o prompt operacional de retomada;
- correções materiais geram novo CP;
- handoffs são operacionais e não normativos;
- Freshness Gate e Diagnóstico de Continuidade são obrigatórios;
- documentação canônica vigente prevalece sobre o checkpoint em caso de conflito.

## Histórico

- **CP01 — 2026-10-03:** checkpoint inaugural. Consolida a criação do repositório, os documentos 00–03 e 10, os templates operacionais iniciais e registra como ponto de retomada o documento 11 — Elegibilidade, Triagem e Seleção.
- **CP02 — 2026-10-03:** consolida o Documento 11, o Screening Record e registra como ponto de retomada o Documento 12 — Avaliação de Risco de Viés e Qualidade Metodológica.
- **CP03 — 2026-10-03:** consolida o Documento 12, o Risk of Bias / Critical Appraisal Record e registra como ponto de retomada o Documento 13 — Extração e Estruturação de Dados.

- **CP04 — 2026-10-03:** consolida o Documento 13, o Data Extraction Record e registra como ponto de retomada o Documento 14 — Síntese de Evidências.
- **CP05 — 2026-10-03:** consolida o Documento 14, o Synthesis Record e registra como ponto de retomada o Documento 15 — Avaliação da Certeza/Confiança no Corpo de Evidências.
- **CP06 — 2026-10-03:** consolida o Documento 15, o Certainty Assessment Record e registra como ponto de retomada a consolidação do modelo conceitual de dados e o aprofundamento da arquitetura tecnológica.
- **CP07 — 2026-10-03:** consolida o Documento 20 — Modelo Conceitual de Dados, formaliza a transição para a Fase 2 e registra como ponto de retomada o desenvolvimento do modelo lógico de dados.
- **CP08 — 2026-10-03:** consolida o Documento 21 — Modelo Lógico de Dados e registra como ponto de retomada a validação arquitetural por casos de uso.
- **CP09 — 2026-10-03:** consolida a validação arquitetural, a checagem de integridade e o GATE F2-A; registra como ponto de retomada as alternativas arquiteturais e o primeiro desenho físico candidato.
- **CP10 — 2026-10-03:** consolida OES-H1 e OES-P1; registra como ponto de retomada a PoC-S1 do schema mínimo.
- **CP11 — 2026-10-03:** consolida a PoC-S1 e sua validação estática; mantém F2-B pendente e registra como ponto de retomada a Trilha B documental.
- **CP12 — 2026-10-03:** consolida o plano F2-B, identidade/versionamento, provenance/lineage e o hardening da PoC-S1; retoma em migrações e PoC-S2.
- **CP13 — 2026-10-04:** consolida PoC-S2/PoC-S3 e o **GATE F2-B = PASS** em PostgreSQL 18.6; mantém OES-P1 como candidato físico validado e registra como ponto de retomada a Revisão de Promoção Arquitetural Pós-F2-B.
- **CP14 — 2026-10-04:** consolida a revisão dos 15 critérios de promoção, mantém OES-P1 não promovido e registra como ponto de retomada a PoC-S4 — Multiplicidade Study/Report, Síntese Multiestudo e Retração/Impact Analysis.
- **CP15 — 2026-10-04:** consolida a **PoC-S4 = PASS**, atualiza a matriz para 11/1/3 e registra como ponto de retomada a PoC-S5 — Métodos Especializados Mínimos.
- **CP16 — 2026-10-04:** consolida a **PoC-S5 = PASS**, a matriz 15/15, promove OES-P1 a baseline arquitetural, encerra a Fase 2 e registra como ponto de retomada a Fase 3 — Produtos do Observatório.
- **CP17 — 2026-10-04:** consolida o Documento 40 — Taxonomia e Arquitetura dos Produtos, formaliza a Ficha de Evidência como unidade persistente central preferencial e registra como ponto de retomada sua especificação individual.

- **CP18 — 2026-10-04:** consolida a especificação científica/funcional da Ficha de Evidência e registra como ponto de retomada o Contrato de Dados da Ficha.
- **CP19 — 2026-10-04:** consolida o contrato de dados, migration 006 e publication gate da Ficha com PASS; registra como ponto de retomada o EvidenceSheetView.
- **CP20 — 2026-10-04:** consolida o EvidenceSheetView e sua validação com PASS; registra como ponto de retomada a especificação do Template Operacional da Ficha de Evidência.
- **CP21 — 2026-10-04:** consolida o Template Operacional inicial da Ficha de Evidência com PASS estrutural/operacional e registra como ponto de retomada a validação científica ponta a ponta com um caso real N2.
