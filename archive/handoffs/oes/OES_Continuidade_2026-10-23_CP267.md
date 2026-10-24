# OES — Continuidade CP267: C1 e C2 implementados e validados

**Data:** 2026-10-23 (America/Recife; execuções CI em 2026-10-24 UTC). **Anterior:** CP266. **Conversa:** aberta.  
**Estado:** `C2_AUTOMATED_TESTS_PASS_30_OF_30 / FUNCTIONAL_SCOPE_PARTIAL / PHASE_5_NOT_STARTED`.

## 1. Marcos posteriores ao CP266

- **C1 — catálogo documental demonstrativo:** implementação aprovada pelo proprietário e publicada no commit `fd30370039e44ec730c9b9903069096ad8171bfc`. Aplicação Django em `applications/oes_web/`, rota `/` GET-only mostra as duas fixtures delimitadas e conduz às páginas de detalhe, sem afirmar inventário completo. CI manual autorizada: [run 40048357640](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40048357640), commit testado `cf7c2fcc07ad75366bd639312aca211f37e6f851`, `completed/success`, **25/25 testes PASS**, sem banco.
- **C2 — contrato mínimo de identidade/proveniência:** Documento 251 `docs/governance/251-c2-delimitacao-contrato-documental-study-report-proveniencia.md`, amparado nos Docs. arquitetura 20/28/29 e products/154. Implementação autorizada, commit `91b8629051ce1d5c021311f792c6a2a6ac694008`: `StudyReference`, `ReportReference`, `StudyReportReference` e `SourceReference` locais tipadas. NCT01438697 permanece **um Study documentado, com dois Reports** Ritterband 2017/Shaffer 2020, origem products/154 §5.5; NCT07836491 permanece não identificado no inventário delimitado, **sem Study/Report**. Não se criaram IDs OES, nova adjudicação ou versão científica. CI manual autorizada: [run 40049293022](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40049293022), commit testado `8e9aae482eb8581eaac2d474aa62dd012cc61790`, `completed/success`, **30/30 testes PASS**, Python 3.12, Django 5.2.18; `manage.py check` sem problemas; banco não utilizado.
- **Estado canônico:** última atualização documental antes deste CP: commit `2b0c596d7942a18e300aa3c6fe886f88bd4be2b3`. A validação em navegador **com Django real** segue pendente, não bloqueante **somente para continuar o protótipo**; não foi demonstrada prontidão operacional, acessibilidade auditada, segurança de produção ou conformidade completa provenance P1–P6. Os resultados CI não equivalem à homologação científica.

## 2. Invariantes e fonte de verdade

Branch `main` do repositório `rogerio-raposo/observatorio-evidencias-saude`; ponteiro `archive/handoffs/oes/README.md`, template `archive/continuity/OES_Template_Abertura_Continuidade.md`, estado `STATE.md`, histórico `CHANGELOG.md`. CP266 preservado imutável. **HEAD de base antes de CP267:** `2b0c596d7942a18e300aa3c6fe886f88bd4be2b3`; aplicar Freshness Gate ao retomar e não confundir este SHA com o commit do próprio checkpoint.

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` (Documento 240 C1–C6), readiness `NOT_READY`; Fase 5 `NOT_STARTED`, M3 `BLOCKED`; D0 documental encerrado, D1 `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY` com branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` intocada, D2 factual global parcial. Produto N2 `OES-P-2026-000401` A2 interno e baseline inalterados; **36 migrations UNREVIEWED**, BRG-03/06/07/08 bloqueados, BRG-09 parcial, SA abertos/diferidos. Sem PostgreSQL/Neon, SQL, migrations, serviços pagos, API pública, deploy, atualização automática, busca factual adicional ou revisão científica independente. Autorizações consumidas de C1/C2 e respectivas CI não se estendem automaticamente a incrementos futuros.

## 3. Ponto exato de retomada e protocolo

**Próximo `Prossiga`:** realizar uma avaliação crítica proporcional de qual **próxima capacidade substantiva** — ou pausa deliberada de incrementos do demonstrador — efetivamente reduz lacunas para o OES, com preferência por requisitos científicos e governança já existentes. **Somente análise e recomendação**, sem implementar C3, acessar fontes externas, executar CI ou iniciar Fase 5 sem aprovação específica. Evitar repetir pequenos ciclos de CRUD/UX, criar frameworks próprios ou confundir 30 testes verdes com readiness.

Cada `Prossiga` = uma atividade delimitada seguida de STOP; checkpoints normalmente após 3–5 atividades ou risco/decisão relevante; Freshness Gate no início e antes de mudanças; mensagens de progresso para tarefas longas; atualizações de STATE/CHANGELOG proporcionais. Modo médio recomendado para análise, alto para decisões de risco ou integração.

**STOP — CP267 consolidado; nenhuma autorização de implementação adicional.**
