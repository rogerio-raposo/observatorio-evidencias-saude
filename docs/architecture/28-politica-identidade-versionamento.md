# 28 — Política de Identidade e Versionamento

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — política arquitetural  
**Data:** 3 de outubro de 2026

## 1. Princípio

O OES distinguirá rigorosamente identidade, versão, identificador externo e representação.

> Alterar um objeto não deve apagar sua história nem criar identidade nova sem necessidade.

## 2. Dois identificadores

### 2.1 Chave física

`entity_uuid`:

- opaca;
- imutável;
- não significativa;
- não reutilizada;
- não é o principal identificador editorial.

O mecanismo de geração do UUID não é normativo nesta fase.

### 2.2 ID público OES

Formato candidato:

`OES-<PREFIXO>-AAAA-NNNNNN`

Regras:

- imutável após atribuição;
- único;
- nunca reutilizado;
- ano = primeiro registro da identidade;
- número não carrega significado científico;
- mudança de título/rótulo não altera ID.

## 3. Prefixos

- Q — Question;
- I — Investigation;
- C — Concept;
- ST — Study;
- RP — Report;
- SG — StudyGroup;
- O — Outcome;
- RS — Result;
- RB — RiskAssessment;
- SY — Synthesis;
- SN — SynthesisNode;
- RF — ReviewFinding;
- PM — PredictionModel;
- CE — CertaintyAssessment;
- AP — ApplicabilityAssessment;
- P — Product.

Novos prefixos exigem registro central.

## 4. Identificadores externos

São aliases, não PK.

Exemplos:

- DOI/PMID/PMCID → tipicamente Report;
- NCT/ReBEC/ICTRP → tipicamente Study;
- códigos terminológicos → Concept.

Podem estar ausentes, ser corrigidos ou existir em multiplicidade.

## 5. Nova identidade versus nova versão

Criar nova identidade para novo objeto científico ou de conhecimento.

Não criar novo ID apenas por:

- correção textual;
- nova extração do mesmo resultado;
- atualização de status;
- nova avaliação da mesma unidade;
- nova versão do mesmo Product.

Esses casos geram versão.

## 6. Study e Report

- novo artigo não implica novo Study;
- novo Study não depende de novo artigo;
- Report pode vincular múltiplos Studies;
- Study pode vincular múltiplos Reports;
- incerteza de vínculo deve ser registrada, não resolvida por duplicação arbitrária.

## 7. Merge

Quando duas identidades forem reconhecidas como o mesmo objeto:

- escolher identidade canônica;
- preservar IDs anteriores;
- marcar identidades antigas como superseded/merged;
- registrar MergeDecision;
- preservar provenance;
- permitir reversão lógica.

## 8. Split

Quando uma identidade agregou incorretamente objetos distintos:

- preservar identidade histórica;
- criar identidades corretas;
- registrar decisão;
- redistribuir relações por nova versão;
- manter trilha de correção.

## 9. Estrutura de versão

Cada versão possui:

- version_uuid;
- version_no;
- status;
- valid_from;
- valid_to;
- supersedes_version_uuid;
- change_type;
- change_note;
- created_at;
- created_by.

`version_no` cresce monotonicamente por entidade.

## 10. Estados

Estados-base:

- draft;
- current;
- superseded;
- archived;
- invalidated.

Regra:

> no máximo uma versão current por entidade.

## 11. Transição normal

`draft → current → superseded`

Exceções possíveis:

- draft → archived;
- current → invalidated;
- superseded → archived.

Reativar conteúdo anterior deverá gerar nova decisão/versão, não reescrever a história.

## 12. Tipos de mudança

Vocabulário inicial:

- initial;
- editorial_correction;
- data_correction;
- new_evidence;
- reanalysis;
- methodological_change;
- certainty_change;
- applicability_change;
- conclusion_change;
- merge;
- split;
- invalidation.

## 13. Atualização de evidência

Nova evidência não sobrescreve:

- Result anterior;
- Synthesis anterior;
- Certainty anterior;
- Product anterior.

Cria novas versões conforme necessário.

## 14. Investigation: versão ou nova identidade?

### Mesma Investigation, nova versão

Quando protocolo e escopo fundamental permanecem e ocorre correção ou atualização planejada da mesma investigação viva.

### Nova Investigation relacionada

Quando houver novo corte tratado como execução formal, mudança substantiva de escopo, novo nível, reanálise independente ou nova finalidade.

Relacionar via InvestigationRelation.

## 15. Result: versão ou novo Result?

### Nova versão

Mesmo estimando e unidade analítica, com correção, nova fonte mais confiável ou transformação corrigida.

### Novo Result

Quando mudam materialmente outcome, timepoint, grupo/comparação, estimando ou análise científica.

## 16. Synthesis

Nova versão para mesmo objetivo/unidade quando houver novos estudos, correção ou reexecução.

Nova Synthesis identity quando a unidade analítica muda materialmente.

## 17. Certainty

Nova versão quando a mesma unidade é reavaliada.

Nova identity quando a unidade avaliada é diferente.

## 18. Product

Product ID permanece estável para produto persistente.

Nova versão quando houver:

- novo corte;
- nova evidência;
- nova síntese;
- nova certeza;
- nova aplicabilidade;
- nova conclusão material.

## 19. Imutabilidade

Versão publicada/current não deve sofrer alteração in-place em campos científicos materiais.

Correção:

1. criar nova versão;
2. registrar change_type;
3. relacionar supersession;
4. mudar estado anterior;
5. preservar provenance.

## 20. Concorrência

A geração de `oes_id`, `version_no` e a transição para `current` deve ser atômica.

A implementação deverá impedir:

- IDs duplicados;
- versões duplicadas;
- dois estados current simultâneos.

## 21. Auditoria

Toda criação de versão registra autor/processo, timestamp, motivo, versão anterior e impacto esperado.

## 22. Decisão

> Identidade é estável; conhecimento evolui por versões; histórico não é descartável.

Essa regra é invariante da arquitetura OES.
