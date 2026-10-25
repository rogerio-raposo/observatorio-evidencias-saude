# OES — CP286 / Continuidade após P1-A3 e prioridade P2

**Data:** 2026-10-25 (America/Recife).  
**Checkpoint anterior:** CP285 (`archive/handoffs/oes/OES_Continuidade_2026-10-25_CP285.md`).  
**HEAD imediatamente anterior ao CP286:** `ca9a66edc14349d24a7c21d4439460a99b8d688c`.  
**Caráter:** handoff operacional imutável para migração de conversa; **não é aprovação de início de P2 nem encerramento da conversa por si só**.

## 1. Diagnóstico consolidado e prioridade

O propósito institucional do OES é identificar, avaliar, sintetizar, atualizar e comunicar evidências com transparência e rastreabilidade; **metodologia antes da automação** (README). A Fase 4 permanece `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, prontidão operacional `NOT_READY`; Fase 5 `NOT_STARTED`.

**Não há pesquisadores atualmente vinculados ao OES.** Documento 290 estabeleceu que isso não impede engenharia, integração e testes sintéticos; avaliação científica independente, validade de conclusões, aceitação externa e revisões especializadas continuam pendentes, **diferidas, nunca simuladas ou dispensadas**.

Documento 288: demonstrar o objetivo central do piloto, evitar infraestrutura e workarounds temporários desproporcionais, inventariar requisitos diferidos e reavaliá-los ao definir a stack completa, antes de operação/produção. Documento 287: **duas autenticações PostgreSQL independentes não são requisito do piloto inicial**; controles necessários de privacidade, integridade, privilégio mínimo, TLS, HOLD e limpeza permanecem vigentes para operações que os exijam.

Sequência funcional:
- **P1** integração sintética offline mínima: P1-A1 inventário; P1-A2 contrato; **P1-A3 implementado, corrigido, validado e formalmente encerrado apenas offline** (Doc. 291).
- **P2 — próximo:** especificar apresentação sintética segregada no Django, sem ainda implementar; verificar primeiro o contrato e sua proporcionalidade.
- **P3 — posterior:** evidência de suficiência técnico-funcional, limites e diferimentos, sem pretender homologação científica.

## 2. Entregas e evidências verificadas

**Demonstrador Django documental**:
- `applications/oes_web`: `/`, `/signals/NCT01438697/` e `/signals/NCT07836491/`.
- Identidade documentada de NCT01438697 relaciona Ritterband 2017 e Shaffer 2020 como **dois relatórios de um estudo previamente documentado**; NCT07836491 **não identificado no inventário delimitado** não implica novidade, inelegibilidade ou exclusão. Base Docs. 247, 248 e products/154; nenhuma nova revisão científica.
- Refinamento apenas de catálogo, detalhe e CSS no commit `359a8d3cd5f8883db4fd8d4f8cba766f462ea81f`, registrado como encerrado tecnicamente **somente para apresentação documental** no Documento 289.
- Evidências de regressão: Actions [40196984551](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40196984551) **Django 50/50 PASS**, e [40197070277](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40197070277) **Chromium 9/9 PASS**, em HEAD `2c7df6d0538cf0be06a44e10b49e4d9dc3a72af5` (CP285); relatório e screenshots gerados como artefato temporário, sem afirmar inspeção humana individual.

**Integração sintética offline P1-A3**:
- Módulo `tools/d2_e5_preservation/p1_synthetic_path_offline.py` e testes `tools/d2_e5_preservation/tests/test_p1_synthetic_path_offline.py`, introduzidos em `a6a873ba38bfe400d5af73a274c005ba93df2e8e`.
- Composição: `prepare_observation` E6 (bytes, proveniência, SHA-256) → associação explicitamente **sintética**, independente entre `observation_id`, `signal_id` e NCT → `SyntheticCommandBridge` D1 (criação/ciclo/sinal, replay) → leitura de **fixture documental aprovada** via `evidence.domain.from_record` → recibo sanitizado `SYNTHETIC_TECHNICAL_ONLY` com `scientific_decision=NOT_PERFORMED`. Sem HTTP, SQL, raw em saída ou decisão científica.
- CI inicial [40198850247](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40198850247) FAILED: 3 erros pois replay D1 fornece `event_log`, não `events`; corrigido pontualmente em `3c9672e0fb4b961eedd28ab3d7399ab403d756f7`.
- Revalidação [40214460778](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40214460778), executada exatamente no commit corrigido: **107/107 PASS**, **8/8 testes P1-A3 PASS**, 0 falhas e erros. Encerramento formal `CLOSED_TECHNICAL_RESTRICTED_OFFLINE` no Documento 291, commit `ca9a66edc14349d24a7c21d4439460a99b8d688c`, com STATE e CHANGELOG.
- Essa prova demonstra composição em memória, não armazenamento físico de bytes nem readback real; não confundir com Django recebendo dinamicamente um recibo em página HTTP.

**E6 e Neon**:
- D2-I-C modelo de identidade única com conexão **simulada** 99/99 PASS em [40194548767](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40194548767), sem SQL conectado.
- Preflight Neon administrativo exclusivamente read-only na branch `br-gentle-hall-b6jaxehf` do projeto `oes-sandbox`: papéis E6 NOLOGIN; writer INSERT sem SELECT; verifier SELECT sem INSERT; proprietário administrativo possui poderes amplos e **não deve ser usado como login de aplicação**. Lacuna ACL permanece sem alteração, e ensaio conectado não autorizado.
- Captura factual adicional e workflow de coleta permanecem bloqueados.

## 3. Restrição arquitetural para P2

A aplicação Django **atual é um demonstrador exclusivamente documental por fixtures**. Seus contratos e rotas foram validados e não devem ser alterados implicitamente. O serviço Django `run_synthetic_private_roundtrip` existente ainda requer duas conexões separadas por contrato histórico; **não reutilizá-lo para P2 de forma que recoloque exigência diferida ou introduza acesso conectado**.

`P1-A3` é biblioteca offline independente e atualmente não está conectada às views Django. P2 deve distinguir prova sintética de interface, exemplo documental historicamente sustentado e alegação científica, sem fingir execução factual e sem vincular automaticamente ID de observação, ID de sinal e NCT.

## 4. Ponto exato de retomada

**P2-A1 — elaborar e revisar um contrato proporcional de projeção/apresentação integrada, opcional e explicitamente sintética no Django**, à luz de Docs. 288–291 e das interfaces atuais. Primeiro verificar:
1. O que deve ser visto pelo usuário (status sanitizado, SHA-256, IDs e limites), sem payload; onde pode residir sem afetar as rotas existentes.
2. Como garantir que uma referência documental é **apenas escolhida pelo cenário de teste**, sem afirmar associação científica derivada do payload.
3. Qual menor caminho offline (fixtures/injeção/dados pré-fabricados) respeita os contratos existentes, e se P2 é efetivamente indispensável ou já coberto pela prova técnica P1 + demonstração Django documental.
4. Critérios de aceite, testes e bloqueios, sem implementação nem publicação de código até decisão/autorizações proporcionais.

**Não executar P2 automaticamente ao abrir a próxima conversa:** primeiro apresentar Diagnóstico de Continuidade, conferir materialidade do estado, e aguardar `Prossiga` ou autorização específica.

## 5. Gates e proibições

Sem factual GET adicional, SQL conectado/Neon escrito, mudança de roles/grants/credenciais, criação/ativação de workflows factuais, pagamentos, deploy, raw payload público, inferência de relação Study–Report, ciência automatizada ou atribuição indevida de `A3` científico. Gates de execução dependem de autorização específica. Estado da fase e produto não se alteram com testes sintéticos.

## 6. Protocolo operacional da próxima conversa

Fonte canônica: `rogerio-raposo/observatorio-evidencias-saude` branch `main`; ponteiro único `archive/handoffs/oes/README.md`; template `archive/continuity/OES_Template_Abertura_Continuidade.md`; `STATE.md`, `CHANGELOG.md`, Docs. 287–291 e este CP. Freshness Gate no início do bloco e imediatamente antes de publicação; diagnosticar divergência antes de prosseguir.

**Modo alto foi explicitamente escolhido no pedido de encerramento/preparação desta conversa.** Confirmar modo na abertura; não pressupor autorização de execução pela escolha de modo. Um `Prossiga` autoriza uma atividade delimitada; checkpoint normalmente depois de 3–5 atividades ou em decisão/risco/transição; atualizações de progresso; não repetir avaliações aprovadas sem causa. O responsável trabalha pelo Android: quando a CI requer `workflow_dispatch` e o conector não oferece dispatch, fornecer link de execução manual e analisar run recebido. A conversa atual não deve ser dada como encerrada sem confirmação expressa do responsável.

## 7. Estado na publicação

`CP286_CURRENT / P1_A3_CLOSED_TECHNICAL_RESTRICTED_OFFLINE / DJANGO_DOCUMENTARY_CLOSED_RESTRICTED / P2_CONTRACT_NEXT / SCIENTIFIC_REVIEW_DEFERRED / PILOT_NOT_CLOSED / FACTUAL_BLOCKED`.

Este checkpoint é um snapshot de continuidade; os Documentos e decisões canônicos prevalecem em caso de divergência.
