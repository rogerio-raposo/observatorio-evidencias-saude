# OES — Handoffs de Continuidade

**Status:** artefato operacional  
**Finalidade:** servir como **único ponteiro operacional** para a retomada do desenvolvimento do Observatório de Evidências em Saúde — OES.

## Arquitetura de continuidade

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

## Checkpoint vigente

**CP59 — 2026-10-06**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-06_CP59.md`

Checkpoint anterior:

`CP58`

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

- **CP01 — 2026-10-03:** checkpoint inaugural; documentos 00–03 e 10; retomada no Documento 11.
- **CP02 — 2026-10-03:** consolida Documento 11; retomada no Documento 12.
- **CP03 — 2026-10-03:** consolida Documento 12; retomada no Documento 13.
- **CP04 — 2026-10-03:** consolida Documento 13; retomada no Documento 14.
- **CP05 — 2026-10-03:** consolida Documento 14; retomada no Documento 15.
- **CP06 — 2026-10-03:** consolida Documento 15; retomada no modelo conceitual de dados.
- **CP07 — 2026-10-03:** consolida Documento 20; transição para Fase 2.
- **CP08 — 2026-10-03:** consolida Documento 21; retomada na validação arquitetural.
- **CP09 — 2026-10-03:** consolida validação arquitetural, integridade e GATE F2-A.
- **CP10 — 2026-10-03:** consolida OES-H1/OES-P1; retomada na PoC-S1.
- **CP11 — 2026-10-03:** consolida PoC-S1; F2-B pendente.
- **CP12 — 2026-10-03:** consolida plano F2-B, versionamento, provenance e hardening.
- **CP13 — 2026-10-04:** GATE F2-B PASS; retomada na revisão de promoção.
- **CP14 — 2026-10-04:** revisão dos 15 critérios; retomada na PoC-S4.
- **CP15 — 2026-10-04:** PoC-S4 PASS; retomada na PoC-S5.
- **CP16 — 2026-10-04:** PoC-S5 PASS, matriz 15/15, OES-P1 promovido; Fase 2 encerrada.
- **CP17 — 2026-10-04:** Documento 40; retomada na Ficha de Evidência.
- **CP18 — 2026-10-04:** especificação da Ficha; retomada no contrato de dados.
- **CP19 — 2026-10-04:** contrato de dados/migration 006 PASS; retomada no EvidenceSheetView.
- **CP20 — 2026-10-04:** EvidenceSheetView PASS; retomada no template operacional.
- **CP21 — 2026-10-04:** template inicial PASS; retomada no caso real N2.
- **CP22 — 2026-10-04:** reconciliação 008/009/Documento 55 e hardening; retomada na materialização do Caso Real 01.
- **CP23 — 2026-10-04:** PASS ponta a ponta em pré-publicação; retomada no gate de revisão.
- **CP24 — 2026-10-04:** pacote de revisão preparado; revisão humana real pendente.
- **CP25 — 2026-10-04:** HRG-T01–T06 PASS; revisão humana real ainda pendente.
- **CP26 — 2026-10-04:** modelo A0–A3 e verificação metodológica adversarial; Caso Real 01 em A1.
- **CP27 — 2026-10-04:** reconcilia Documentos 65–66; owner approval pendente.
- **CP28 — 2026-10-04:** consolida owner approval explícita, Caso Real 01 em **A2/published**, PASS do run 37229070210 e retoma na especificação científica e funcional da **Resposta de Evidência — N1**.
- **CP29 — 2026-10-05:** consolida Documentos 68–71, migration 012, EvidenceResponseView candidata e ER-T01–T14 em PASS; retomada na formalização do contrato de renderização **EvidenceResponseView**.
- **CP30 — 2026-10-05:** consolida Documentos 72–74, EvidenceResponseView formalizada, template N1 v0.1 em PASS no run 37357423887; retomada no **Caso Real N1**.
- **CP31 — 2026-10-05:** fecha a trilha inicial da **Resposta de Evidência N1** com Caso Real N1-01 em **A2/published**, run final 37362554094 PASS; retomada na especificação científica e funcional do **Evidence Scan N0**.
- **CP32 — 2026-10-05:** consolida Documentos 86–89, migration 013, EvidenceScanView e ES-T01–T15 em PASS; retomada no **contrato de renderização do Evidence Scan N0**.
- **CP33 — 2026-10-05:** fecha a trilha inicial do **Evidence Scan N0** com Caso Real N0-01 em **A1 interno**, run final 37382201584 PASS; retomada na especificação científica e funcional da **Síntese Rápida de Evidências — N3**.
- **CP34 — 2026-10-05:** consolida Documentos 99–102, migration 014, RapidEvidenceSynthesisView e RS-T01–T15 em PASS; retomada no **contrato de renderização da Síntese Rápida N3**.
- **CP35 — 2026-10-05:** consolida Documentos 103–105, template/renderização N3 e F3-RS-TEMPLATE em PASS; retomada no **Caso Real N3 experimental**.
- **CP36 — 2026-10-06:** fecha o **Caso Real N3-01** em A0 experimental após dois adversariais `REVISE`, com bloqueio metodológico por cobertura bibliográfica insuficiente; retomada na **Revisão de Evidências — N4**.
- **CP37 — 2026-10-06:** consolida Documentos 115–118, migration 015, EvidenceReviewView e ER4-T01–T25 em PASS; retomada no **contrato de renderização/template da Revisão de Evidências N4**.
- **CP38 — 2026-10-06:** fecha a trilha técnica inicial da **Revisão de Evidências N4** com template/renderização em PASS; retomada no **Infrastructure Readiness Gate de um Caso Real N4 experimental**.
- **CP39 — 2026-10-06:** registra **N4 Infrastructure Readiness Gate = NOT_READY**, sem abertura de Caso Real N4; retomada na **especificação científica e funcional do Mapa de Evidências**.
- **CP40 — 2026-10-06:** consolida os Documentos 123–125 do **Mapa de Evidências**, registra a camada `mapping` e o contrato de dados v0.1; retomada na **migration 016 + fixture + testes + rebuild + S5**, antes de qualquer template.
- **CP41 — 2026-10-06:** registra **PASS técnico do contrato do Mapa de Evidências**, Documento 126, run 37464023391 e rebuild through migration 016; retomada no **Documento 127 — contrato de renderização do EvidenceMapView**.
- **CP42 — 2026-10-06:** registra o Documento 127 e **Projection Readiness Gate = NOT_READY para template**; retomada na migration aditiva da EvidenceMapView 0.1.
- **CP43 — 2026-10-06:** registra **Projection Readiness Gate = READY**, migration 017, EMV-T01–T11 e rebuild through migration 017; retomada na **Especificação do Template Operacional do Mapa de Evidências**.
- **CP44 — 2026-10-06:** registra **PASS da camada de apresentação do Mapa**, Documento 130 e run 37467388595; retomada no **Readiness Gate pré-Caso Real**, separando rota exploratória da rota formal.
- **CP45 — 2026-10-06:** registra **rota exploratória READY_WITH_DOCUMENTED_CONDITIONS / rota formal NOT_READY** e autoriza o **MAP-01**; retomada no protocolo do caso.
- **CP46 — 2026-10-06:** fecha protocolo, inventário e codebook do **MAP-01** antes da persistência; retomada na criação controlada do caso no banco.
- **CP47 — 2026-10-06:** corrige a identidade arquitetural do MAP-01: Question/Investigation próprias + N3-01 como `source_corpus`; retomada na migration 018.
- **CP48 — 2026-10-06:** registra **PASS do suporte a source_corpus**, migration 018, EMVSC-T01–T05 e rebuild through migration 018; retomada na persistência real do MAP-01.
- **CP49 — 2026-10-06:** encerra o **MAP-01 em A1 interno / não publicável**, com render e rebuild em PASS; retomada na **Especificação Científica e Funcional do Overview de Revisões**.
- **CP50 — 2026-10-06:** fecha especificação científica e arquitetura do **Overview de Revisões**; retomada no **Contrato de Dados v0.1**.


- **CP51 — 2026-10-06:** fecha o Contrato de Dados v0.1 do Overview de Revisões; retomada na migration 019, fixture e testes OV-T01–T33.


- **CP52 — 2026-10-06:** registra migration 019 estruturalmente validada, regressões/rebuild em PASS; retomada na fixture formal do Overview + OV-T01–T33.


- **CP53 — 2026-10-06:** registra PASS técnico do contrato do Overview de Revisões, OV-T01–T33 e rebuild/regressões; retomada no contrato de renderização da `OverviewOfReviewsView`.


- **CP54 — 2026-10-06:** define contrato de renderização do Overview e Projection Readiness **NOT_READY**; retomada na migration 020 + OVR-T01–T12.


- **CP55 — 2026-10-06:** Projection Readiness do Overview = READY após migration 020 + OVR-T01–T12; retomada na especificação formal do Template Operacional.


- **CP56 — 2026-10-06:** especificação do Template Operacional do Overview concluída; retomada na implementação dos quatro arquivos da camada de apresentação e integração S5.


- **CP57 — 2026-10-06:** camada de apresentação do Overview v0.1 validada em PASS; retomada no readiness pré-caso real, sem abertura de Caso Real antes do gate.


- **CP58 — 2026-10-06:** readiness pré-caso real do Overview fechado; developmental = READY_WITH_DOCUMENTED_CONDITIONS, formal = NOT_READY; retomada na qualificação do subconjunto secundário N3-01 como corpus candidato.


- **CP59 — 2026-10-06:** subconjunto secundário N3-01 rejeitado como UNSUITABLE para OVR-01; retomada na seleção/qualificação de novo corpus candidato.
