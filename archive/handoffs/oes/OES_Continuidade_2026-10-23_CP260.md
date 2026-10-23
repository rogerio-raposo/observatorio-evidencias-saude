# OES — Continuidade CP260: novo critério de encerramento da Fase 4

**Data:** 2026-10-23  
**Anterior:** CP259  
**Ato de governança:** proprietário declarou **“Gostaria de formalizar o encerramento metodológico e documental como marco determinante do encerramento da fase 4.”**
**Estado:** `PHASE_4_DOCUMENTARY_METHODOLOGICAL_EXIT_CRITERION_APPROVED / PHASE_4_CLOSURE_PENDING / OPERATIONAL_NOT_READY`.

## 1. Decisão vinculante e documento canônico

**Documento 237** `docs/governance/237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md` define o **marco determinante de conclusão da Fase 4** como aceitação **metodológica e documental** do Protocolo de Atualização, após revisão integrada dos critérios de saída e **autorização expressa posterior do gate final pelo proprietário**. **Esta decisão muda o critério de saída; NÃO encerra a fase agora**. Operação autoritativa, M3, Neon, migrações e produção não são condição da saída metodológica, mas as provas de seus riscos continuam obrigatórias **antes dos atos técnicos aos quais se aplicam**. Não reduzir/alterar BRGs por inferência.

## 2. Evidência, critério e trabalho seguinte

Base dos Docs. 04–09, 135–138. Matriz de avaliação aprovada como definição de pronto:
- `F4-C01`: rastreabilidade e suficiência SF-01–SF-14;
- `F4-C02`: coerência documental end-to-end `R0–R8` e AT-01–AT-12, com ressalvas AT-05/09/12;
- `F4-C03`: governança humana, N/A, A2 versus A3 e disclosure;
- `F4-C04`: temporal, cadence/currentness, falhas e M3 bloqueado, sem parâmetros não justificados;
- `F4-C05`: ledger explícito de obrigações operacionais diferidas, evidência/autoridade/gatilho;
- `F4-C06`: parecer de fronteira e autorização final de encerramento **apenas documental**.

Os 12 cenários estão documentados, **0/12 executados end-to-end** na matriz histórica; o demonstrador D1 em memória foi encerrado sinteticamente; prova factual D2 NCBI foi pontual; isso não corresponde a execução integrada de Fase 4. Não exigir execução operacional para saída documental; jamais reivindicar PASS de produção ou peer review inexistente.

**Ponto exato do próximo `Prossiga`: elaborar matriz objetiva F4-C01–F4-C06 com evidências existentes e lacunas impeditivas exclusivamente documentais, priorizando AT-05, AT-09, AT-12; propor deliberação final futura e STOP.** Não criar infraestrutura, buscar novamente Shaffer/Hwang ou alterar produto por inferência.

## 3. Estados herdados de CP259

GitHub `rogerio-raposo/observatorio-evidencias-saude`, branch `main`; ponteiro `archive/handoffs/oes/README.md`; template `archive/continuity/OES_Template_Abertura_Continuidade.md`; `STATE.md`/`CHANGELOG.md`. Freshness Gate na retomada e antes de commit. Cada `Prossiga` uma atividade e STOP; checkpoint normalmente após 3–5 atividades ou risco/decisão; progresso visível. Não usar ChatGPT Work. Não repetir testagens/artefatos sem ganho material.

**D0** documental histórico encerrado; **D1** `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`; T2-A2/A2-G4 diferido, A2-G5/runtime não autorizado. **D2** factual parcial: NCBI E-utilities ensaio conectado no [run 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270) SUCCESS 11/11 testes/4 sementes/1 artigo Shaffer count literal, não busca exaustiva; Docs. 232–236 reconciliam suplemento 10 estudos/12 estimativas e pré-appraisal; D2-E3 documental restrito fechado, D2 global ainda aberto. Ficha N2 `OES-P-2026-000401` A2 interno e documentos 52/53 sem alteração científica, revisão independente ausente. O Documento 49 recebeu adendo bibliográfico sem atualizar cutoff 2026-10-04.

Suplemento proprietário `supplementary_material_zsag264.zip` preservado em Biblioteca pessoal `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, não publicado em GitHub; verificar acesso real em nova conversa. Branch experimental `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, não alterar/mesclar.

Riscos SA-05/06/07/08/10 abertos/diferidos; BRG-03/06/07/08 bloqueados, BRG-09 parcial; 36 migrations `UNREVIEWED`, M3 `BLOCKED`, Fase 4 `NOT_CLOSED`, readiness operacional `NOT_READY`, Fase 5 `NOT_STARTED`. Sem CI adicional, Neon, SQL, custos, reestimativa GRADE ou promoção científica.

**STOP — CP260, conversa permanece aberta.**
