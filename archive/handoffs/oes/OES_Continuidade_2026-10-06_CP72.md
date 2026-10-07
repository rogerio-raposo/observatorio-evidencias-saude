# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP72  
**Checkpoint anterior:** CP71  
**Status:** artefato de continuidade; não normativo  
**Escopo:** encerramento controlado do OVR-01 dCBT-I em A1 interno após correções adversariais e validação integrada

## 1. Marco

> **OVR-01 = DEVELOPMENTAL_A1_INTERNAL_VALIDATED.**

O primeiro Caso Real developmental do Overview de Revisões foi encerrado em A1 interno, não publicável, após duas passagens metodológicas adversariais, correções, testes pós-A1, renderização e rebuild-from-zero.

A rota formal permanece:

> **NOT_READY**

Nenhuma owner approval, expert review, human verification, A2/A3 ou publicação foi criada.

## 2. Freshness Gate que precedeu o CP72

Fonte canônica:

- repositório `rogerio-raposo/observatorio-evidencias-saude`;
- branch `main`.

HEAD encontrado antes da consolidação:

`ecc04933dd5ba116345dc4dcf8d352a646b6aed7`

Checkpoint vigente encontrado:

> **CP71**

Foram reconciliados os commits posteriores ao CP71 correspondentes à primeira passagem adversarial, correções, segunda passagem adversarial, promoção A1 e integração S5.

Não foi identificado trabalho externo divergente.

Após a reconciliação foram persistidos:

- Documento 164: commit `d9cf4029a3d77b83b8a4a79e77ce5d830e545a2f`;
- atualização substantiva de `STATE.md`: commit `507fb8201cf4fcc5f4dbaa8904585b5c7d304a43`;
- atualização de `CHANGELOG.md`: commit `666c6099ab9b8ac96407c90451c29b5c9d65e2c7`.

## 3. Primeira passagem adversarial

Documento:

`docs/products/162-verificacao-metodologica-adversarial-01-ovr01-dcbti.md`

Decisão:

> **REVISE**

Achados materiais:

1. Search execution persistida sem sustentação operacional canônica suficiente;
2. regra retrospectiva `minimum_bibliographic_sources=2`, não prevista no protocolo;
3. drift da Question em relação ao Documento 149.

Assurance permaneceu A0.

## 4. Correções pós-REVISE

Correções principais:

- Search/search hits/screening decisions não sustentados removidos;
- discovery restaurada como documentação `structured_non_exhaustive`;
- regra `minimum_bibliographic_sources=2` removida;
- Question restaurada conforme protocolo;
- OVR01-T15 e OVR01-T16 adicionados como guards de regressão.

Commits principais:

- `6736a6c05c23fe69651a7a0f447f456fcc8fc3ce`;
- `20d113d646641c78865a0a8ef4741cc35bfdafa0`;
- `49b567720dd24dd718e3c140eba659c26554efb1`.

Run pós-correção A0:

- **37543166213** = success.

## 5. Segunda passagem adversarial

Documento:

`docs/products/163-verificacao-metodologica-adversarial-02-ovr01-dcbti.md`

Decisão:

> **PASS**

Commit:

`7a63bab3546df7a7cdd95299fb508febbbb67fd5`

A passagem confirmou que os achados materiais foram corrigidos e que as limitações developmental permaneciam explícitas.

## 6. Promoção A1

Arquivos:

- `database/f3-real-case-ovr01-assurance-a1.sql`;
- `database/f3-real-case-ovr01-a1-tests.sql`.

Assurance:

> **A1 — ai_methodological_verification=passed**

Não houve nova ProductVersion apenas para alterar assurance.

Não foram criados:

- owner approval;
- expert independent review;
- reviewer humano;
- human consensus;
- A2/A3;
- publicação.

## 7. Estado científico/metodológico preservado

Caso:

- Product `OES-P-2026-001601`;
- status `under_review`;
- `publication_date=NULL`;
- `publishable=false`.

Corpus:

- Hwang = 27 memberships;
- Gao = 15;
- Nazari = 44;
- occurrences = 86;
- unique primary Studies = 59.

Pairwise overlap derivado pelo banco:

- Hwang × Gao = 6;
- Hwang × Nazari = 17;
- Gao × Nazari = 9.

Limites obrigatórios preservados:

- Gao continua com `last_search_date=NULL`;
- nenhuma data foi inferida;
- CCA continua derivado exclusivamente por `overview.overlap_metrics`;
- nenhuma nova meta-analysis OES;
- comparadores não foram colapsados;
- certainty review-level não foi inventada;
- ROBIS e memberships permanecem AI-assisted/unverified.

## 8. Validação integrada final

Workflow:

`OES PoC-S5 PostgreSQL Validation`

Run:

- **37549135468**;
- run number **117**;
- HEAD validado `ecc04933dd5ba116345dc4dcf8d352a646b6aed7`;
- conclusão **success**.

Confirmado:

- OVR01-T01–T16 PASS;
- OVR01-A1-T01–T09 PASS;
- OVR01-RENDER-A1 PASS;
- regressões integradas PASS;
- rebuild-from-zero PASS.

Artifact:

- ID **11452420926**;
- nome `oes-s5-evidence-37549135468`;
- digest `sha256:4dff568129b92a6a4565c33c015afbbe7bec2cc872333b4f99b2701b9c9151a6`.

## 9. Encerramento documental

Documento 164:

`docs/products/164-caso-real-ovr01-resultado-encerramento.md`

Decisão:

> **OVR-01 concluído como Overview developmental A1 interno / não publicável.**

A rota formal segue separada e continua exigindo A3 + controles humanos qualificados.

## 10. Ponto exato de retomada

> **Iniciar a Especificação Científica e Funcional do Monitor de Evidências.**

Base arquitetural inicial:

- Documento 40;
- Monitor = produto/processo de manutenção;
- dimensão M2/M3;
- não constitui N5;
- deve vincular-se a Investigation e/ou produto científico persistente;
- deve monitorar novas evidências capazes de modificar Results, Synthesis, Certainty, aplicabilidade, conclusão ou estado de atualidade.

O **Alerta de Evidência** permanece posterior ao Monitor.

## 11. Protocolo anti-interrupção

Na retomada:

1. executar novo Freshness Gate;
2. não repetir operações por aparência de travamento;
3. reconciliar commits posteriores ao CP72;
4. fazer alterações pequenas e atômicas;
5. persistir checkpoints em marcos metodológicos;
6. atualizar `STATE.md`, `CHANGELOG.md` e o ponteiro de continuidade.

**Fim do CP72**
