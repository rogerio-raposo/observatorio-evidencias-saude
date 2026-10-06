# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP71  
**Checkpoint anterior:** CP70  
**Status:** artefato de continuidade; não normativo  
**Escopo:** persistência real controlada e validação pós-persistência do OVR-01 dCBT-I em A0

## 1. Marco

> **OVR-01 = PERSISTED_DEVELOPMENTAL_A0_VALIDATED.**

O OVR-01 dCBT-I foi materializado no banco em A0 developmental, validado por testes específicos, regressões, rebuild-from-zero e renderização por `OverviewOfReviewsView`.

Ainda **não** houve verificação metodológica adversarial pós-persistência e, portanto, nenhuma promoção a A1 foi realizada neste checkpoint.

## 2. Freshness Gate da retomada

A retomada partiu do CP70, mas o estado canônico foi verificado diretamente em `main`.

HEAD encontrado no início:

`e664c4266baf50bd62842603423c4e2b29dd1b60`

Checkpoint vigente encontrado:

`CP70`

Commits posteriores ao commit que criou o arquivo CP70 eram somente atualizações operacionais de continuidade/STATE/CHANGELOG e não alteravam materialmente o marco metodológico.

Foi identificada uma divergência operacional no topo de `STATE.md`: ainda apontava para CP36. Ela foi reconciliada antes das escritas metodológicas no commit:

`0d59a096952ae0dc6ebbda6aa6acf9aa085e771c`

Nenhum trabalho CP62–CP70 foi refeito.

## 3. Persistência real A0

Arquivo:

`database/f3-real-case-ovr01-dcbti.sql`

Commits principais:

- criação da persistência: `e33366911c8d0bf30421f34484b391495911b843`;
- ROBIS OVR mantido ativo porém não verificado: `f6751d524569dc4840768aa554b6fbfc98b85172`.

A persistência inclui:

- Question própria;
- Investigation própria, developmental, N3/M0;
- Product/ProductVersion próprio `overview_of_reviews`;
- protocolo, Emenda 01, matriz e micro-gate rastreáveis;
- materialização de Nazari;
- ReviewItems Hwang, Gao e Nazari;
- memberships Study-level;
- cluster/resolução de overlap;
- ROBIS OVR-scoped AI-assisted/unverified;
- OutcomeEvidence review-level sem nova meta-analysis;
- Product em `under_review`;
- currency `under_evaluation`;
- nenhuma assurance adicional.

## 4. Limites epistemológicos preservados

Foram preservados explicitamente:

- Gao com `last_search_date=NULL`, `currentness_status='unclear'` e rationale sem inferência;
- Nazari sem dia exato inventado para a busca; a fonte disponível informa apenas cobertura até janeiro de 2025;
- nenhum CCA calculado ou persistido manualmente;
- nenhuma nova meta-analysis OES;
- Hwang, Gao e Nazari com estimativas review-level separadas;
- comparadores não colapsados;
- certainty review-level não inventada e GRADE N2 não reutilizado;
- memberships AI-assisted/unverified;
- ROBIS AI-assisted/unverified;
- nenhum reviewer humano fictício;
- nenhum owner approval;
- nenhuma expert review;
- nenhuma promoção A2/A3;
- nenhuma publicação;
- rota formal permanece separada e NOT_READY.

## 5. Membership e overlap

Matriz canônica persistida:

- Hwang = 27 Study memberships;
- Gao = 15;
- Nazari = 44;
- total de occurrences = 86;
- união = 59 primary Study candidates.

Controles pairwise derivados pelo banco:

- Hwang × Gao = 6 shared Studies;
- Hwang × Nazari = 17;
- Gao × Nazari = 9.

`overview.overlap_metrics` confirmou structural membership completa, 86 occurrences, 59 Studies únicas e CCA calculável pelo banco.

> O valor numérico de CCA não foi calculado nem transcrito manualmente neste checkpoint.

## 6. Publication blockers

O publication gate permanece fechado.

Foi confirmado no banco:

- `MISSING_LAST_SEARCH_DATE`;
- `MISSING_APPRAISAL_CONTROL`;
- `UNVERIFIED_REVIEW_APPRAISAL`;
- `UNVERIFIED_MEMBERSHIP`;
- `MISSING_OVERLAP_CONTROL`;
- `UNVERIFIED_OUTCOME_EVIDENCE`.

Para Gao, especificamente:

- `last_search_date IS NULL`;
- `currentness_status='unclear'`;
- rationale explicita que nenhuma data foi inferida.

A Emenda 01 continua sendo somente developmental; não converte C2 em PASS e não altera a rota formal.

## 7. Testes específicos

Arquivo:

`database/f3-real-case-ovr01-tests.sql`

Commits:

- criação: `5b65a5f6d8e2acfe8f9d9c10453ea6e4bd0f9ca0`;
- correção atômica do teste de identidade Sweetman: `a083e383a8971dafe9a9886ffa03990fe302ca8a`.

Resultado:

> **OVR01-T01–T14 PASS**

Os testes cobrem:

- identidade/A0/non-publishable;
- 3 ReviewItems;
- 27/15/44 = 86/59;
- overlap global derivado;
- pairwise 6/17/9;
- blocker de Gao;
- comparadores/certainty;
- ausência de controles humanos fabricados;
- ROBIS OVR;
- blockers formais;
- ausência de nova meta-analysis;
- reutilização da Study Sweetman existente;
- projeção pela View;
- materialização/proveniência de Nazari.

## 8. Renderização

A primeira execução integrada, run **37542066270**, falhou somente no renderer porque o template presumiu `export_artifact.storage_key` para toda Search.

Importante:

- a persistência SQL havia concluído;
- OVR01-T01–T14 haviam passado;
- a falha não era científica nem de banco.

Não foi fabricado search export para contornar a falha.

O template foi corrigido no commit:

`7da4b8b9e90ae86858728b35a97c49cb7979cbab`

Agora Search sem export artifact é renderizada com ausência explícita, enquanto Search com export mantém o comportamento anterior.

## 9. Validação integrada final

Workflow:

`.github/workflows/validate-s5.yml`

Integração inicial:

`525ecaaee4467a45212452d485250f63480ec266`

Run final:

- run **37542350632**;
- run number **112**;
- HEAD: `7da4b8b9e90ae86858728b35a97c49cb7979cbab`;
- conclusão: **success**.

Validado no run:

- contrato sintético do Overview = PASS;
- OVR01 load = PASS;
- OVR01-T01–T14 = PASS;
- render real A0 via `OverviewOfReviewsView` = PASS;
- idempotência/regressões = PASS;
- rebuild-from-zero = PASS;
- final S5 status = PASS.

Artifact:

- id **11449631263**;
- name `oes-s5-evidence-37542350632`;
- digest `sha256:138fb9fe28432124dc6e70031bd0a99c1c11a40647ba8ff73687f3fd3cecdb93`.

## 10. Assurance

Estado atual:

> **A0**

Não existe `product.assurance_record` ativo para o OVR-01.

A persistência de dados e o PASS técnico **não equivalem** a verificação metodológica adversarial e não promovem o produto automaticamente.

## 11. Ponto exato de retomada

> **Executar verificação metodológica adversarial pós-persistência do OVR-01 contra o protocolo developmental, Emenda 01, matriz canônica, blockers e OverviewOfReviewsView; reconciliar qualquer achado material. Somente se o adversarial concluir PASS metodológico sem fabricação de controles humanos, considerar promoção interna para A1. Não promover A2/A3 e não publicar.**

Limites que continuam obrigatórios:

- não inferir last-search date de Gao;
- não calcular CCA manualmente;
- não criar nova meta-analysis;
- não colapsar comparadores;
- não fabricar verificação humana;
- não criar owner approval ou expert review fictícios;
- não promover automaticamente para A2/A3;
- não publicar;
- preservar a rota formal separada da developmental.

**Fim do CP71**
