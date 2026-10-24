# OES — Continuidade CP266: Django A1/B1, UX-02 e fronteira de decisão funcional

**Data:** 2026-10-23 (America/Recife). **Anterior:** CP265. **Conversa:** aberta.  
**Estado:** `DJANGO_VERTICAL_SLICES_AND_UX02_AUTOMATED_PASS_20_OF_20 / BROWSER_VALIDATION_PENDING / PHASE_5_NOT_STARTED`.

## 1. Evidências e entregas posteriores ao CP265

- **D2:** Documento 248 consolidou cruzamento **documental restrito** dos 20 NCTs da primeira página ClinicalTrials.gov (Documento 247); 4 identificadores já documentados, 16 não identificados no inventário delimitado, sem alegação de novidade, elegibilidade, cobertura bibliográfica ou revisão científica nova. D2 global **PARTIAL**; não fazer novas consultas, paginação ou repetição de workflow por inferência.
- **Arquitetura:** Documento 249 aprovou preliminarmente **Django 5.2 LTS / Python 3.12**, monólito modular simplificado, domínio independente, JSON local e GET-only, sem SQL/Neon. Primeiro vertical slice em `applications/oes_web/`; testes 8/8 PASS no [run 40044041757](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40044041757).
- **B1:** Documento 250 aprovou escopo; autorização explícita posterior permitiu implementar trajetória documental retrospectiva nas duas fixtures `NCT01438697` (um Study, Ritterband 2017/Shaffer 2020 como relatórios relacionados) e `NCT07836491` (identidade não conciliada, sem inferências). Código commit `dcf21ddc0135e846085bb68f5ff37cced3db0cb6`; testes B1 16/16 PASS no [run 40046496477](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40046496477).
- **UX-02:** proprietário aprovou quatro melhorias de apresentação: estados em linguagem humana, três seções, links controlados aos Docs. 247/248/products/154, trajetória visual. Código commit `38a454333b15d553b35a281a4fe81c1494a8caec`; validação Django **20/20 testes PASS**, Python 3.12, Django 5.2.18, `manage.py check` PASS, banco não utilizado, [run 40047175669](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40047175669), testado no commit `4e9c1ac149954414ececf426183b09ebee3c2af6`. `STATE.md` traz evidência e limites.
- **UX real:** houve reprodução estática exploratória em Chromium, **não** renderização do Django executado; tentativa de ambiente local bloqueada por falta de Django/acesso para instalar. `REAL_BROWSER_VALIDATION_PENDING_NON_BLOCKING_FOR_PROTOTYPE`; pendência não bloqueante somente para continuar o demonstrador, bloqueia alegações de homologação visual/acessibilidade ou prontidão pública. Não criar infraestrutura nova apenas para tal validação.

## 2. Fonte canônica, estados e limitações

Repositório: `rogerio-raposo/observatorio-evidencias-saude`, branch `main`. Ponteiro operacional: `archive/handoffs/oes/README.md`; template: `archive/continuity/OES_Template_Abertura_Continuidade.md`; `STATE.md` e `CHANGELOG.md` prevalecem em informação corrente. **HEAD imediatamente anterior a este checkpoint:** `892d294fb3b5415dccc2c528ab0a54e2e2686f28`; conferir HEAD atual ao retomar, pois o commit de CP266 será posterior.

**Fase 4:** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` (Documento 240, C1–C6 restritos), prontidão `NOT_READY`, M3 `BLOCKED`. **Fase 5:** `NOT_STARTED`. D0 concluído documentalmente; D1 `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` intacta/não mesclar; D2 parcial. 36 migrations `UNREVIEWED`; BRG-03/06/07/08 bloqueados, BRG-09 parcial; SA abertos/diferidos. Produto N2 `OES-P-2026-000401` permanece A2 interno, baseline 2026-10-04 sem nova revisão científica. Nenhuma promoção de produto, revisão humana, SQL, Neon, deployment, API pública, serviço pago ou capacidade operacional por este checkpoint.

## 3. Ponto exato de retomada e formas de trabalho

**Próximo `Prossiga`:** comparar objetivamente **alternativas para o próximo incremento funcional substantivo do demonstrador Django**, considerando utilidade científico-documental, simplicidade de implementação, dependências, escopo das evidências disponíveis e gates. **Somente análise/proposta**, sem construir código ou expandir integração por implicação. Evitar novo ciclo UX cosmético e retrabalho de framework.

Processo: um `Prossiga` = uma atividade interna delimitada + STOP; checkpoints normalmente após 3–5 atividades, antecipados por fronteira decisória/risco. Atualizações de progresso em tarefas longas, Freshness Gate no início e antes de commits, documentação canônica apenas por relevância. Recomendar modo médio para análises e alto para decisões de risco/integração. Autorizações de B1, UX-02 e seus runs já consumidas, não reutilizáveis para novas intervenções; sem triggers automáticos ou consultas externas não autorizadas. Ao abrir conversa nova, seguir estritamente template e ponteiro; a memória conversacional não substitui GitHub.

**STOP — checkpoint consolidado; não autoriza novo incremento.**
