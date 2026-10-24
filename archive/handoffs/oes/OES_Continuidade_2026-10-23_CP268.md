# OES — Continuidade CP268: estabilização Django validada em navegador real

**Data:** 2026-10-23, America/Recife (CI 2026-10-24 UTC). **Anterior:** CP267. **Conversa:** aberta.
**Estado:** `REAL_DJANGO_BROWSER_VALIDATION_PASS_9_OF_9 / FUNCTIONAL_SCOPE_PARTIAL / OPERATIONAL_NOT_READY`.

## 1. Mudanças e decisões depois do CP267

1. Análise Integrada de Prontidão e Dependências sem pesquisadores aprovada para análise e publicada no [Documento 252](../../../docs/governance/252-analise-integrada-prontidao-dependencias-sem-pesquisadores.md), commit `59f934a211865a765e84ae6dfef77bc50b0bf288`. Identifica tarefas de engenharia sem pesquisadores, atos reservados à competência científica e gates técnicos condicionados ao ato de risco; não reabre a Fase 4.
2. O proprietário **aprovou a prioridade de estabilização** em lugar de ampliar C3 ou antecipar Neon: `STABILIZATION_PRIORITY_APPROVED / DJANGO_FUNCTIONAL_EXPANSION_DEFERRED`, registrada no `STATE.md` pelo commit `9c5a78b7ccf2854fcfc81691d568d57858517ba1`.
3. A tentativa de validação local anterior **não executou Django real**, pois Django não estava instalável naquele ambiente; reproduções estáticas são evidência preliminar apenas, sem PASS integrado.
4. Com autorização expressa, foram implementados `django.contrib.staticfiles` e `STATIC_URL="/static/"`, script `applications/oes_web/scripts/validate_browser.py`, workflow manual `.github/workflows/oes-django-real-browser-validation.yml` e documentação. Commit **`1c7400c909d1af74ed17c1d42ba16b24de7026d9`**, sem alterar o workflow Django anterior de 30 testes.
5. Com autorização separada, o proprietário acionou [GitHub Actions run 40054002708](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40054002708), `workflow_dispatch`, tentativa 1, `completed/success`, commit testado **`1c7400c909d1af74ed17c1d42ba16b24de7026d9`**. Job `django-real-browser` e todas as etapas `success`. Logs mostram `System check identified no issues (0 silenced)`; **nove PASS** (catálogo, NCT01438697, NCT07836491 × desktop 1440, tablet 810, mobile 390), `BROWSER_VALIDATION_STATUS=PASS`; navegação verificada pelo script. Django real em loopback, Chromium headless, CSS aplicado, limites e identidade documental sem atribuições científicas novas; nenhuma consulta factual externa feita pelo teste.
6. Artefato da execução `oes-django-real-browser-evidence`, ID **12544582293**, 1.330.537 bytes, upload de **11 arquivos** segundo log: nove screenshots, `results.json` e `django-server.log`; disponível em [GitHub Actions](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40054002708/artifacts/12544582293), retenção declarada de sete dias (expiração registrada 2026-10-31 02:24:48 UTC). A classificação é restrita: sucesso dos nove checks do script e da navegação, não revisão visual humana independente das screenshots nem auditoria plena de acessibilidade.

## 2. Limites explícitos e situação de gates

- **Validação Django/browser:** `REAL_DJANGO_BROWSER_VALIDATION_PASS_9_OF_9 / FUNCTIONAL_SCOPE_PARTIAL`. Os **30/30 testes Django históricos** da run 40049293022 referem-se ao commit anterior `8e9aae...`; não afirmar que foram reexecutados no commit atual.
- **Sem avaliação científica independente:** ausência atual de pesquisadores não impede engenharia, porém não pode gerar elegibilidade, ROBIS/RoB2/GRADE, juízo científico material ou A3 fictício. Preservar regras do Documento 04 e condições C1–C6 do Documento 240.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; **readiness operacional `NOT_READY`**, Fase 5 `NOT_STARTED`, M3 `BLOCKED`; D0 fechado documentalmente, D1 encerrado somente no demonstrador sintético/memória, D2 factual global `PARTIAL`. Produto `OES-P-2026-000401` A2 interno e baseline 2026-10-04 inalterados.
- **36 migrations `UNREVIEWED`**, BRG-03/06/07/08 `BLOCKED`, BRG-09 parcial, SA-05/06/07/08/10 abertos/diferidos. Sem PostgreSQL/Neon, SQL, execução factual, publicação científica, custo pago, implantação, Fase 5 ou atualização autoritativa. Branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` permanece intocada.
- Alertas de depreciação Node.js 20 nas actions v4/v5 observados nos logs como avisos não bloqueantes; não reabrir infraestrutura sem necessidade decisória.

## 3. Retomada precisa

**Próximo `Prossiga`:** realizar **uma avaliação crítica do próximo uso concreto** do demonstrador estabilizado (apresentação documental a futuros pesquisadores, ampliação pontual da observação factual não adjudicativa, ou uma pausa técnica disciplinada). Elaborar recomendação proporcional com entrega verificável, dependências e autoridade requerida; **não implementar C3, banco, workflow adicional ou CI por inferência**. Um resultado PASS em navegador encerra a lacuna experimental **nesse escopo**, não promove operações, segurança, ciência ou Fase 5.

Protocolo: cada `Prossiga` autoriza apenas uma atividade seguida de STOP; checkpoints em geral após 3–5 atividades ou decisão relevante; Freshness Gate inicial e imediatamente antes de commit; atualizar STATE/CHANGELOG proporcionalmente. Mensagens de progresso em tarefas longas. Modo médio para análise, alto para alterações com risco. Repositório `rogerio-raposo/observatorio-evidencias-saude`; ponteiro `archive/handoffs/oes/README.md`, estado `STATE.md`, template `archive/continuity/OES_Template_Abertura_Continuidade.md`.

**HEAD antes de CP268:** `1c7400c909d1af74ed17c1d42ba16b24de7026d9`. CP267 preservado; conferir novo HEAD após publicação.

**STOP — CP268 formaliza a validação real em navegador; não autoriza novos incrementos.**
