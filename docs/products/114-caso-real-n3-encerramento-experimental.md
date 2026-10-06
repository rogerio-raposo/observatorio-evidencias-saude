# 114 — Caso Real N3-01: Encerramento Experimental e Bloqueio Metodológico Controlado

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**Data:** 6 de outubro de 2026  
**Status:** caso real experimental encerrado em **A0 — bloqueado metodologicamente**  
**Publicação formal:** não autorizada

---

# 1. Objetivo

Registrar o encerramento controlado do primeiro Caso Real N3 após duas verificações metodológicas adversariais.

O objetivo deste encerramento é distinguir:

- sucesso técnico/arquitetural do produto;
- plausibilidade da síntese científica;
- suficiência metodológica para assurance;
- elegibilidade para publicação formal.

Esses estados não são equivalentes.

# 2. Estado final do caso

Produto:

- Product `OES-P-2026-000701`;
- ProductVersion atual = **2**;
- depth = N3;
- maintenance = M1;
- editorial status = `under_review`;
- assurance = **A0**;
- `publishable=false`;
- publication_date = NULL;
- expert independent review = ausente;
- qualified human controls = ausentes.

# 3. Histórico de versões

## ProductVersion 1

Conteúdo inicial completo em modo experimental:

- protocolo;
- busca;
- seleção;
- appraisal;
- síntese;
- GRADE;
- SoF;
- quality controls por IA.

Primeira verificação adversarial:

> **REVISE**

Motivo:

> cobertura insuficiente de busca/não duplicação após falha do Europe PMC.

## ProductVersion 2

Correção realizada:

- terminologia ampliada;
- terceira Search record;
- 20 hits materializados;
- 34 decisões de screening;
- 13 referências utilizadas/contextuais;
- primeira decisão REVISE preservada;
- conjunto causal, syntheses e GRADE mantidos.

Segunda verificação adversarial:

> **REVISE**

Motivo:

> arquitetura de busca ainda não satisfaz o requisito N3 de cobertura bibliográfica mínima defensável.

# 4. Causa raiz do bloqueio

O Documento 99 exige busca N3:

> **sistemática, reproduzível, documentada e proporcionalmente abrangente.**

E define como padrão inicial:

> **pelo menos duas bases bibliográficas relevantes, salvo exceção metodologicamente justificada.**

No runtime utilizado:

- PubMed/MEDLINE foi executável;
- Europe PMC não foi executável de forma reproduzível;
- tentativa via API falhou;
- tentativa via interface web falhou;
- OpenAlex direto também não foi executável;
- publisher/DOI/citation chasing permaneceu apenas fonte suplementar.

# 5. Por que a exceção não foi aceita

A exceção de uma base poderia ser metodologicamente aceitável apenas se a cobertura restante fosse defensável.

Ela foi testada empiricamente.

Após a ProductVersion 2, nova busca adversarial ainda localizou estudos elegíveis que não haviam sido recuperados.

Logo:

> **a própria execução demonstrou que a abreviação estava alterando materialmente a cobertura.**

Portanto, elevar assurance seria incompatível com o Documento 99.

# 6. Conteúdo científico preservado

Não foi identificado, nas verificações adversariais, motivo suficiente para descartar o conjunto causal principal:

- Lukac et al.;
- Afshar et al.;
- Chowdhury et al.

Também permaneceram metodologicamente plausíveis, em caráter experimental:

- documentation time: LOW;
- workload/work exhaustion: LOW;
- work outside work: LOW;
- note quality/safety: VERY LOW.

A conclusão científica permaneceu calibrada:

> ambient AI scribes podem reduzir tempo de documentação e alguns componentes de carga/exaustão, mas os efeitos variam por ferramenta/contexto e segurança equivalente não foi demonstrada.

Entretanto:

> **uma conclusão plausível não autoriza assurance quando o método de busca é insuficiente.**

# 7. Quality controls

Foram registrados seis quality controls executados por IA.

Todos permanecem:

- `actor_type = ai_system`;
- `independent=false`;
- `qualified=false`.

Continuam ausentes:

- qualified search-strategy verification;
- qualified screening pilot;
- qualified secondary screening verification;
- qualified critical-data verification;
- qualified risk-of-bias verification;
- qualified certainty verification.

# 8. Validação técnica final

GitHub Actions:

- run **37413884319**;
- attempt 1;
- conclusion **success**;
- commit validado `f2ba21eaaa2d3c43a95ceb908dd0b097b8e9a1b4`.

Artifact:

- ID **11389784878**;
- nome `oes-s5-evidence-37413884319`;
- digest `sha256:c4b53864e60be656a1e3de9039b8480746bbeff8f9fcf5b76257989a47a73b58`.

# 9. Evidências de PASS técnico

- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- F3-RS-TEMPLATE PASS;
- rebuild through migration 014 PASS;
- regressões N0–N2/F2-B/S4/S5 PASS.

# 10. Interpretação do resultado

Este caso valida um comportamento crítico do OES:

> **o sistema consegue recusar a elevação de assurance mesmo quando estrutura de dados, testes, renderização, appraisal e síntese estão tecnicamente completos.**

O adversarial layer detectou uma insuficiência que o publication gate estrutural, isoladamente, não seria capaz de resolver.

Isso demonstra a separação entre:

- completude estrutural;
- verificação metodológica;
- assurance;
- publicação.

# 11. O que foi validado no produto N3

Foi validado:

- protocolo e rapid restrictions;
- MethodDecision;
- desvio de protocolo;
- Search/Screening;
- Result;
- appraisal;
- Synthesis;
- CertaintyAssessment;
- SoF;
- quality controls;
- RapidEvidenceSynthesisView;
- template/renderização;
- gate de human-qualified controls;
- requirement de A3;
- caminho adversarial `REVISE`;
- versionamento após correção;
- rebuild com histórico;
- bloqueio de assurance quando método não satisfaz padrão N3.

# 12. O que NÃO foi validado

Não foi demonstrado:

- Caso Real N3 em A1;
- Caso Real N3 com search coverage satisfatória em duas bases;
- controles humanos qualificados;
- A3;
- publicação formal N3.

Esses estados não deverão ser inferidos.

# 13. Condição de retomada deste caso

O caso poderá ser reaberto somente se houver:

1. acesso reproduzível a uma segunda base bibliográfica relevante;
2. execução documentada da busca;
3. deduplicação e screening do novo conjunto;
4. atualização do produto se houver evidência material nova;
5. nova verificação metodológica adversarial.

Sem isso:

> **não criar ProductVersion 3.**

# 14. Decisão de projeto

> **Encerrar o Caso Real N3-01 como validação experimental controlada em A0.**

Esse encerramento é suficiente para confirmar o comportamento inicial do produto e de sua governança negativa.

Não equivale a validação de publicação formal N3.

# 15. Próxima etapa da Fase 3

Prosseguir para:

> **Revisão de Evidências — N4: especificação científica e funcional.**

A experiência N3 deverá informar especialmente:

- requisitos mínimos de busca;
- dependências de infraestrutura bibliográfica;
- controles humanos;
- regras de rerroteamento;
- distinção entre gate estrutural e verificação metodológica.

---

**Resultado final do Caso Real N3-01:** tecnicamente validado; metodologicamente bloqueado em A0; não publicável.