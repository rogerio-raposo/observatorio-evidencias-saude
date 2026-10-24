# Documento 250 — B1: aprovação de escopo do segundo vertical slice Django

**OES | 2026-10-23 | B1_SCOPE_APPROVED / IMPLEMENTATION_NOT_STARTED / DOCUMENTARY_ONLY**

## 1. Decisão e origem

O proprietário aprovou expressamente o escopo B1, elaborado após o primeiro vertical slice Django (Documento 249) e sua validação automatizada restrita no [run 40044041757](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40044041757): 8 testes PASS, mas aceitação funcional ainda parcial. Esta aprovação delimita a **proposta funcional**, sem autorizar implementação, dependências novas, CI adicional, consultas externas, SQL, Neon, migrations, implantação, serviços pagos ou mudanças científicas.

## 2. Objetivo

Estender a página de sinal de evidência para **visualizar sua trajetória documental retrospectiva**: identificação/recuperação conhecida, conciliação com inventário documental, vínculo Study/Report quando documentado e informação explícita de que não ocorreu julgamento científico novo. Não é workflow operacional, event sourcing, parecer científico ou histórico de atualização efetivamente executada pelo novo aplicativo.

## 3. Material e fronteiras

- Reutilizar Django 5.2 LTS e as duas fixtures já presentes em `applications/oes_web/evidence/fixtures/signals.json`.
- `NCT01438697`: exibir associação documental Ritterband 2017 / Shaffer 2020 ao **mesmo Study**, sem duplicação de ensaio; proveniência nos Docs. 247/248 e referências prévias verificáveis.
- `NCT07836491`: manter `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`; não inferir novo ensaio, elegibilidade, exclusão, desenho ou resultados.
- Marcos candidatos exclusivamente como **metadados de apresentação**, contendo `event_type`, `source_ref`, `description`, `event_date` opcional, `certainty_boundary`. Datas só podem constar quando explicitamente sustentadas por documento canônico. Ordenação é documental, não cronologia fabricada.
- Nenhum campo/estado novo poderá fingir adjudicação humana, evidência clínica revisada ou aprovação científica.
- Não integrar automaticamente os comandos e eventos do protótipo sintético D1: processo operacional e narrativa documental retrospectiva são categorias distintas.

## 4. Critérios VS2 de aceitação propostos

1. **VS2-01:** A página e rotas do primeiro incremento permanecem funcionais.
2. **VS2-02:** Marcos seguem ordem documental definida e justificada, sem datas artificiais.
3. **VS2-03:** Cada marco apresenta sua fonte `source_ref`.
4. **VS2-04:** Datas não documentadas são omitidas, não inventadas.
5. **VS2-05:** A fixture não reconciliada não recebe Study, Report ou classificação científica presumidos.
6. **VS2-06:** Nenhuma ação de aprovação, exclusão ou atualização científica é oferecida/executada.
7. **VS2-07:** Não há acesso SQL/Neon ou consultas HTTP externas.
8. **VS2-08:** Os oito testes existentes continuam passando.
9. **VS2-09:** Testes adicionais verificam ordem, origem e fronteira das inferências.

Os itens são critérios funcionais do incremento candidato, não novo gate normativo; resultados permanecem pendentes até implementação e execução de testes expressamente autorizadas.

## 5. Conservação de limites

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` (C1–C6, Doc. 240), readiness `NOT_READY`, Fase 5 `NOT_STARTED`, M3 `BLOCKED`, D1 demonstrador restrito fechado, D2 global parcial, 36 migrations `UNREVIEWED`, BRG/SA não liberados, Ficha N2 `OES-P-2026-000401` e respectivos juízos/cortes científicos não alterados. Nenhuma operação metodológica ou credencial de infraestrutura está incluída.

## 6. Continuidade

**Próximo passo recomendado:** proposta objetiva de implementação mínima no aplicativo existente e solicitação de autorização técnica específica. **Não codificar por inferência da aprovação de escopo**. CP265 permanece checkpoint operacional vigente até novo checkpoint proporcional, sujeito ao Freshness Gate.

**STOP — escopo formalizado, implementação não iniciada.**
