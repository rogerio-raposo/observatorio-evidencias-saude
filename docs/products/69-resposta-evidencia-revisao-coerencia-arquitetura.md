# 69 — Resposta de Evidência N1: Revisão de Coerência e Decisão Arquitetural Inicial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Decisão arquitetural inicial consolidada  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 04, 20–21, 28–30, 38, 40–47, 61–62 e 68  
**Baseline arquitetural:** OES-P1  
**Produto:** OES — Resposta de Evidência  
**Nível:** N1

---

# 1. Finalidade

Este documento registra a revisão de coerência do Documento 68 e decide o que a Resposta de Evidência N1 deve reutilizar da arquitetura existente antes de qualquer implementação física.

Objetivos:

1. evitar duplicação do modelo criado para a Ficha de Evidência;
2. impedir que requisitos específicos de N2 sejam herdados indevidamente por N1;
3. preservar o baseline OES-P1;
4. identificar somente as lacunas reais que deverão ser resolvidas no contrato de dados N1.

---

# 2. Resultado da revisão de coerência

O Documento 68 é coerente com:

- Documento 40 — Resposta de Evidência = N1;
- Documento 03 — pergunta focal + boas sínteses + ausência de necessidade de completude;
- Documento 10 — busca documentada, não exaustiva, priorizando sínteses;
- Documento 11 — seleção orientada às melhores fontes;
- Documento 12 — appraisal proporcional das fontes decisivas;
- Documento 13 — extração focal com conferência das afirmações materiais;
- Documento 14 — adoção crítica de síntese existente; nova meta-análise não rotineira;
- Documento 15 — certainty existente reutilizável somente sob compatibilidade;
- Documento 04 — A2 para publicação formal/persistente N1;
- baseline OES-P1 — Product como agregador de Investigation/Synthesis/Certainty sem duplicar objetos científicos.

Nenhuma incompatibilidade metodológica material foi identificada.

---

# 3. Princípio arquitetural

A Resposta de Evidência será tratada como:

> **novo Product subtype sobre o baseline OES-P1, reutilizando infraestrutura transversal e adicionando somente regras/projeções específicas de N1.**

Não será criado um “mini-banco da Resposta”.

A arquitetura deverá distinguir:

- infraestrutura comum de Product;
- regras específicas do subtipo;
- projeção de leitura/apresentação.

---

# 4. Componentes reutilizados sem alteração conceitual

## 4.1 Identidade e versionamento

Reutilizar:

- `core.entity`;
- `core.entity_version`;
- `product.product`;
- `product.product_version`.

`product_type` deverá identificar a Resposta de Evidência por valor controlado a definir no contrato físico, candidato: `evidence_response`.

Nenhuma nova entidade principal é necessária.

## 4.2 Investigação

Reutilizar `product.investigation_link` e `investigation.investigation_version`.

Regra N1:

- uma Investigation primary;
- profundidade derivada = N1;
- demais investigações poderão ser vinculadas como suporte quando necessário.

## 4.3 Estado editorial e atualização

Reutilizar status editorial comum, `product.currency_state`, `product.current_currency_state` e `product.version_change_class`.

A Resposta não requer vocabulário próprio de estado.

## 4.4 Assurance

Reutilizar `product.assurance_record` e os tipos já existentes de verificação metodológica por IA, owner governance approval e expert independent review.

O modelo A0–A3 é transversal e não deverá ser duplicado por produto.

## 4.5 Provenance e dependency graph

Reutilizar `provenance.record`, `provenance.dependency_edge`, guardas de imutabilidade e lineage já validado.

Isso permite registrar afirmações de uma ProductVersion diretamente contra uma ReportVersion quando não houver Synthesis formal intermediária.

## 4.6 Artefatos

Reutilizar a infraestrutura `artifact` e o vínculo de rendered artifact já previsto em ProductVersion.

---

# 5. Componentes reutilizáveis de forma condicional

## 5.1 Synthesis link

A Resposta poderá vincular SynthesisVersion quando reutilizar uma síntese OES estruturada, adotar representação estruturada de síntese externa ou derivar de Ficha/investigação N2–N4.

> **Synthesis vinculada não será requisito universal para N1.**

Impor essa exigência faria N1 herdar profundidade estrutural de N2 sem necessidade científica.

## 5.2 Certainty link

Será utilizado somente quando a Resposta comunicar uma CertaintyAssessment estruturada e compatível.

Não será obrigatório quando não houver certainty formal adequada e a incerteza for comunicada descritivamente conforme Documento 68.

## 5.3 RiskAssessment

RiskAssessment existente poderá ser reutilizado.

A Resposta N1 não exigirá RiskAssessment formal para todas as fontes. Quando appraisal formal de uma fonte decisiva for executado, deverá permanecer na entidade metodológica apropriada e ser referenciado/projetado, não copiado para o produto.

---

# 6. Componentes que não devem ser reutilizados diretamente

## 6.1 `product.evidence_sheet_publication_issues()`

Não reutilizar diretamente. A função contém invariantes específicos de Ficha, inclusive `product_type=evidence_sheet`, Investigation primary N2 e requisitos estruturais próprios.

## 6.2 `product.evidence_sheet_is_publishable()`

Não reutilizar diretamente. A publicação N1 deve ser calculada contra invariantes N1.

## 6.3 `product.evidence_sheet_view()`

Não reutilizar como contrato da Resposta. O EvidenceSheetView contém estrutura de apresentação e conteúdo própria da Ficha N2.

## 6.4 Template da Ficha

Não reutilizar como template final N1. Blocos conceituais poderão inspirar composição, mas não deverão forçar a Resposta a assumir o volume e estrutura da Ficha.

---

# 7. Assurance: oportunidade de generalização controlada

A tabela `product.assurance_record` já é genérica.

A função atualmente denominada `product.evidence_sheet_assurance_level()` implementa lógica A0–A3 conceitualmente transversal.

Decisão inicial:

> **considerar, em migration futura, extração de função genérica de assurance derivado por ProductVersion, preservando wrapper compatível para Evidence Sheet.**

Candidato conceitual: `product.assurance_level(product_version_uuid)`.

Essa alteração não será implementada agora.

Condições antes de generalizar:

1. contrato N1 fechado;
2. regressão da Ficha preservada;
3. nenhuma alteração semântica de A0–A3;
4. wrapper histórico mantido;
5. rebuild e idempotência validados.

Publication gates continuarão podendo ser específicos por subtipo.

---

# 8. Representação das fontes decisivas

Este é o principal ponto de atenção do contrato N1.

A Resposta deve identificar fontes como decisiva, suporte, contextual, atualização posterior e, quando aplicável, regulatória/institucional.

O baseline atual permite provenance direta: `ProductVersion → provenance.record → ReportVersion`.

> **não criar uma nova tabela de source/reference link antes de demonstrar necessidade.**

O próximo contrato deverá testar se provenance + estruturas já existentes são suficientes para representar identidade da fonte, papel na resposta, localização do dado/afirmação, atualidade e relação com a conclusão.

Se o papel semântico da fonte não puder ser representado sem abuso de `field_path`, `process_type` ou texto livre, então será justificada uma estrutura mínima específica ou genérica.

Não usar campos de provenance para finalidade semântica incompatível apenas para evitar migration.

---

# 9. Necessidade de Synthesis em N1

A Resposta poderá assumir três padrões:

## Padrão A — síntese estruturada existente

`Product(Response) → SynthesisVersion → Results/Reports`

## Padrão B — fonte decisiva direta

`Product(Response) → provenance → ReportVersion`

## Padrão C — composição híbrida

`Product(Response) → SynthesisVersion + provenance direta para Reports adicionais`

Todos são válidos em N1.

> **o publication gate N1 não deverá exigir Synthesis link universalmente.**

---

# 10. Reuso de Certainty

Quando certainty formal existente for reutilizada, preferir `Product → CertaintyAssessmentVersion` com provenance até a fonte original.

Quando a avaliação estiver apenas descrita no documento externo e ainda não tiver sido estruturada no OES, o contrato N1 deverá decidir entre estruturar CertaintyAssessment reutilizado ou comunicar descritivamente a certeza relatada pela fonte, sem transformá-la em avaliação OES.

> **não criar CertaintyAssessment apenas para preencher campo visual.**

---

# 11. Publication gate N1 — requisitos conceituais

## Identidade e roteamento

- ProductVersion existente;
- `product_type` correto;
- exatamente uma Investigation primary;
- primary Investigation = N1;
- versão corrente.

## Conteúdo científico mínimo

- título;
- pergunta focal;
- conclusão;
- data de corte;
- limitações;
- referências/fontes decisivas rastreáveis;
- método de busca documentado;
- declaração de não exaustividade quando aplicável.

## Coerência

- conclusão com provenance;
- certainty comunicada apenas quando suportada;
- nenhuma exigência universal de Synthesis;
- nenhuma exigência universal de nova CertaintyAssessment.

## Assurance

Para publicação formal:

- AI methodological verification ativa = `passed`;
- owner approval ativa = `approved`;
- nenhuma decisão ativa bloqueante;
- expert review `approved`, se existente, eleva A3;
- ausência de expert review permanece explícita.

## Editorial

- `publication_date` somente no conteúdo fechado;
- status `published` somente quando gate sem erro.

---

# 12. Projeção de leitura

A Resposta provavelmente se beneficiará de uma projeção própria, candidata `EvidenceResponseView`.

Entretanto sua criação dependerá do contrato de dados.

Estrutura conceitual candidata:

~~~text
EvidenceResponseView
├── schema_version
├── identity
├── question
├── routing
├── answer
├── method
├── key_sources[]
├── key_results[]
├── certainty
├── limitations
├── applicability
├── references[]
└── audit
~~~

Esta estrutura é candidata, não contrato aprovado.

Diferença central para EvidenceSheetView: menor granularidade, Synthesis opcional, CertaintyAssessment opcional e foco em fontes decisivas sem representar o corpo de evidência como se fosse N2.

---

# 13. Migração física

Neste estágio:

> **nenhuma migration nova está autorizada ainda.**

Primeiro deverá existir o contrato de dados da Resposta de Evidência.

O contrato deverá classificar cada campo como já existente, derivado, reutilizável, ausente ou candidato a nova estrutura.

Somente lacunas comprovadas poderão gerar migration.

---

# 14. Decisões consolidadas

1. Resposta de Evidência será Product subtype do OES-P1.
2. Não será criado modelo paralelo.
3. Product/ProductVersion serão reutilizados.
4. Investigation link será reutilizado com primary N1.
5. currency/version change serão reutilizados.
6. `assurance_record` será reutilizado.
7. provenance/dependency graph serão reutilizados.
8. Synthesis link será opcional.
9. Certainty link será opcional.
10. RiskAssessment formal será opcional e proporcional.
11. Evidence Sheet publication gate não será reutilizado diretamente.
12. EvidenceSheetView não será contrato da Resposta.
13. Template da Ficha não será copiado para N1.
14. Publication gate N1 não exigirá Synthesis universalmente.
15. Fontes decisivas poderão ser vinculadas diretamente por provenance.
16. Nova tabela de source/reference link não será criada sem necessidade demonstrada.
17. Generalização da função de assurance poderá ser considerada posteriormente, com compatibilidade retroativa.
18. Nenhuma migration será criada antes do contrato de dados N1.

---

# 15. Próxima etapa

Produzir:

> **Contrato de Dados da Resposta de Evidência — N1**

O contrato deverá:

1. mapear os blocos do Documento 68 para OES-P1;
2. identificar campos comuns com a Ficha;
3. identificar campos específicos N1;
4. resolver representação das fontes decisivas;
5. definir obrigatoriedade/condicionalidade;
6. estabelecer invariantes do gate;
7. determinar se alguma migration é realmente necessária;
8. propor somente depois a eventual `EvidenceResponseView`.

---

**Decisão final:** reutilização arquitetural ampla, especialização mínima e nenhuma migration prematura.