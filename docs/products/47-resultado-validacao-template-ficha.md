# 47 — Resultado da Validação do Template Operacional da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** PASS estrutural/operacional  
**Data:** 4 de outubro de 2026  
**Especificação:** Documento 46  
**Input contract:** `oes.evidence_sheet_view/0.1`  
**Template:** `oes.evidence_sheet.template/0.1`  
**GitHub Actions run final:** 37196822297  
**Commit testado:** `de824e4c11319e5a08e034895502770afcef18f5`

---

# 1. Resultado

O primeiro template operacional Markdown da Ficha de Evidência foi validado contra um `EvidenceSheetView` produzido pelo próprio PostgreSQL a partir da fixture versionada.

> **Template Operacional da Ficha — PASS estrutural/operacional**

A validação incluiu:

- template canônico Markdown;
- mapa de apresentação de enums;
- renderer de referência;
- validador estrutural;
- exportação real do `EvidenceSheetView`;
- renderização Markdown;
- ausência de placeholders não resolvidos;
- presença das seções e valores científicos obrigatórios;
- publication gate;
- regressões anteriores;
- rebuild até migration 007.

---

# 2. Artefatos versionados

## Template

`templates/evidence-sheet.md`

SHA-256 observado no run:

`08381947428c5857ce502674a14fbd0cab2d06a6a5703c594a80f29363ae85b9`

## Mapa de apresentação

`templates/evidence-sheet-presentation-map.json`

SHA-256:

`a65779276b2dc4e4652256224d41bcb059a013eb4fb725f013d2dced2707f975`

## Renderer de referência

`scripts/render_evidence_sheet_reference.py`

SHA-256:

`e7615c316e7ad41e11620b4cdbf7c3c97dcef8589961168f81ae7c35ddb83326`

## Validador

`scripts/validate_evidence_sheet_render.py`

SHA-256:

`873902c9073c6926240fa3c130748d06d9e36b4c39159ce11e49fe303ec3d9a8`

---

# 3. Princípio confirmado

O template consome exclusivamente:

> **EvidenceSheetView + regras de apresentação**

Ele não introduz nova fonte científica.

Foram removidas referências artificiais a `display.*` que não pertenciam ao contrato `EvidenceSheetView 0.1`.

Traduções de enums, como:

- `current → Atual`;
- `moderate → moderada`;
- `new_evidence → nova evidência`;

foram deslocadas para um mapa de apresentação separado.

Consequência:

> dados canônicos e apresentação permanecem desacoplados.

---

# 4. Neutralidade de motor

A sintaxe do template utiliza apenas o subconjunto contratual:

- `{{path}}`;
- `{{this}}`;
- `{{#if path}}`;
- `{{else}}`;
- `{{/if}}`;
- `{{#each path}}`;
- `{{/each}}`.

O renderer Python existente é:

> **implementação de referência para teste e reprodutibilidade**

e não escolha definitiva do motor de template de produção.

O helper `unless` foi removido para evitar dependência desnecessária de engine.

---

# 5. Render de referência

O workflow executou:

1. `product.evidence_sheet_view(...)` no PostgreSQL;
2. exportação do JSON real;
3. aplicação do template;
4. aplicação do mapa de apresentação;
5. geração de Markdown;
6. validação estrutural.

Arquivos produzidos no artifact:

- `evidence-sheet-view.json`;
- `evidence-sheet-fixture.md`;
- `F3-TEMPLATE-validation.log`.

O render de fixture é deliberadamente um artefato reprodutível, não fonte canônica.

---

# 6. Testes validados

A etapa F3-TEMPLATE confirmou:

1. template sem `display.*`;
2. template sem helper `unless`;
3. nenhum placeholder permaneceu no Markdown renderizado;
4. versão do template presente;
5. versão do EvidenceSheetView correta;
6. título presente;
7. Product ID presente;
8. pergunta normalizada presente;
9. conclusão presente;
10. limitações presentes;
11. aplicabilidade presente;
12. referências vinculadas presentes;
13. Synthesis vinculada presente;
14. framework de certainty presente quando formal;
15. gate de publicação corretamente representado;
16. produto publishable não foi rotulado como preview;
17. seção de auditoria presente;
18. seção de atualidade/histórico presente.

Resultado:

> **F3-TEMPLATE PASS**

---

# 7. Falha intermediária e correção

O run anterior **37196775597** falhou apenas na asserção textual do validador.

Causa:

o validador procurava:

`Gate de publicação: aprovado`

enquanto o Markdown corretamente renderizava:

`**Gate de publicação:** aprovado`

Não houve falha:

- do template;
- do EvidenceSheetView;
- do contrato científico;
- do PostgreSQL.

A asserção foi corrigida e o run final passou integralmente.

Essa ocorrência é classificada como:

> **defeito do harness de validação, corrigido.**

---

# 8. Regressões

No run final:

- F2-B regression: **PASS**;
- PoC-S4 regression: **PASS**;
- PoC-S5 S5-T02–T15: **PASS**;
- S5-T17: **PASS**;
- Evidence Sheet contract F3-FE: **PASS**;
- EvidenceSheetView F3-VIEW: **PASS**;
- migration 007 idempotent re-apply: **PASS**;
- rebuild até migration 007: **PASS**.

Conclusão:

> o template e seu renderer de referência não alteraram nem romperam o baseline científico/arquitetural.

---

# 9. Artifact do run final

- Artifact ID: **11300953823**
- Nome: `oes-s5-evidence-37196822297`
- Digest: `sha256:99a1c851678ab5ba005517f793518e13ac708bfea32f756c668135a19b47d09b`
- Tamanho: 13184 bytes
- Expiração: 3 de novembro de 2026

O artifact é temporário, mas sua reprodução é garantida pelos arquivos versionados no repositório e pelo workflow.

---

# 10. Limites desta validação

O PASS atual é:

> **estrutural e operacional**

Ainda não demonstra que o template possui a melhor apresentação editorial para todos os tipos de pergunta.

Pontos que deverão ser testados com casos reais:

- legibilidade de `result_summary` quantitativo;
- apresentação de múltiplos outcomes;
- no-evidence;
- certainty não avaliada;
- safety/harms;
- qualitativa/CERQual;
- diagnóstico;
- PredictionModel;
- Ficha com atualização e predecessor;
- Ficha não publishable em preview;
- listas longas de Studies/Reports.

Esses testes poderão levar a melhorias de apresentação sem alterar o contrato científico.

---

# 11. Decisão

Com o run final aprovado:

> **`templates/evidence-sheet.md` é aceito como Template Operacional inicial da Ficha de Evidência, versão `oes.evidence_sheet.template/0.1`.**

Sua condição permanece:

- inicial;
- evolutiva;
- subordinada ao Documento 41;
- subordinada ao EvidenceSheetView;
- sujeita à validação científica/editorial com caso real.

---

# 12. Próxima etapa

A infraestrutura mínima do primeiro produto está pronta:

`OES-P1 → Product contract → EvidenceSheetView → Template Markdown`

Próxima etapa recomendada:

> **Validação científica ponta a ponta da Ficha de Evidência com um caso real.**

O caso deverá permitir testar:

1. formulação da pergunta;
2. Investigation N2;
3. busca;
4. triagem;
5. avaliação crítica;
6. extração;
7. síntese;
8. certainty;
9. conclusão;
10. aplicabilidade;
11. ProductVersion;
12. publication gate;
13. EvidenceSheetView;
14. render Markdown;
15. revisão editorial final.

Somente após essa validação deverá ser decidido se a Ficha está suficientemente madura para servir de padrão aos demais produtos.

---

**Resultado final:** PASS estrutural/operacional.
