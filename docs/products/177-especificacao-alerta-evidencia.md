# 177 — Especificação Científica e Funcional do Alerta de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **SCIENTIFIC_FUNCTIONAL_SPEC_READY**  
**Dependências:** Documento 40; Documentos 165–176; OES-P1

---

## 1. Natureza

O Alerta de Evidência é:

> **um produto comunicacional persistente de manutenção que registra e comunica um sinal potencialmente modificador, sem constituir nova investigação científica e sem alterar por si só a conclusão do alvo.**

É simultaneamente:

- produto OES identificável/versionável;
- evento comunicacional;
- registro auditável de escalonamento.

Não é:

- nova revisão;
- nova síntese;
- nova Investigation;
- novo Result;
- nova CertaintyAssessment;
- atualização científica do alvo;
- recomendação clínica;
- substituto do Monitor.

---

## 2. Pergunta operacional

O Alerta responde:

> **Que informação nova, rastreável e potencialmente material exige atenção sobre este produto/investigação, qual dimensão pode ser afetada e qual é o estado da sua avaliação?**

Não responde automaticamente:

> “A conclusão científica mudou?”

Essa pergunta exige processo de atualização do alvo.

---

## 3. Relação com o Monitor

Monitor e Alerta permanecem objetos distintos.

Monitor:

- vigia;
- detecta;
- tria;
- avalia impacto potencial;
- recomenda escalonamento.

Alerta:

- comunica um sinal selecionado;
- registra sua classificação preliminar;
- explicita a possível dimensão afetada;
- comunica necessidade/urgência qualitativa de reavaliação.

Regras:

- nem todo cycle gera Alerta;
- nem todo CandidateAssessment gera Alerta;
- nem todo EvidenceEvent gera Alerta;
- um Alerta deve possuir origem rastreável;
- um Alerta pode ser originado por Monitor ou por fonte/evento rastreável fora de um Monitor;
- o Alerta nunca modifica silenciosamente o target.

---

## 4. Identidade

Cada Alerta formal persistente deverá possuir:

- Product entity;
- ProductVersion;
- `product_type='evidence_alert'`;
- título;
- público-alvo;
- data de corte da informação considerada;
- estado editorial;
- provenance/lineage;
- vínculo a pelo menos uma Investigation de contexto.

Não criar Investigation exclusiva do Alerta.

---

## 5. Investigation de contexto

Quando originado em Monitor:

> vincular à Investigation do Monitor que produziu o signal/cycle.

Quando originado fora de Monitor:

> vincular à Investigation do target científico ou outra Investigation explicitamente justificável.

Esse vínculo:

- contextualiza a evidência;
- não transforma a Investigation em “Investigation do Alerta”;
- não adiciona Search retroativamente;
- não altera cutoff histórico da Investigation.

---

## 6. Target

Cada AlertVersion deverá possuir exatamente um target primário:

- ProductVersion; ou
- InvestigationVersion.

O target é:

> **a versão concreta potencialmente afetada pelo sinal.**

O Alerta não aponta apenas para Product identity sem versão.

Motivo:

- preserva estado científico/editorial no momento da emissão;
- permite lineage;
- evita reinterpretar retrospectivamente o alvo.

---

## 7. Origem rastreável

Cada AlertVersion deverá possuir pelo menos uma origem rastreável.

Origens v0.1 admitidas:

1. `maintenance.candidate_assessment`;
2. `maintenance.evidence_event`;
3. `core.entity_version` científico/documental;
4. `artifact.artifact`;
5. source URI persistida com descrição suficiente.

Quando CandidateAssessment ou EvidenceEvent for usado:

> preservar também a cadeia Monitor → Cycle → source/event/candidate.

A origem não pode ser apenas texto narrativo sem referência quando houver entidade estruturada disponível.

---

## 8. Data do sinal

Registrar separadamente:

- `signal_date`, quando conhecida;
- `detected_at`;
- `issued_at`, quando o Alerta é emitido;
- ProductVersion publication_date, quando formalmente publicado.

Essas datas não são intercambiáveis.

---

## 9. Classificação preliminar

Categorias canônicas v0.1:

- `informational`;
- `relevant`;
- `critical`.

Correspondem a:

- Informativo;
- Relevante;
- Crítico.

São:

> **classificações comunicacionais preliminares persistidas, não thresholds quantitativos automáticos.**

A Fase 3 não define:

- tamanho de efeito mínimo;
- intervalo temporal;
- probabilidade;
- número de estudos;
- SLA;
- gatilho automático;
- score.

---

## 10. Dimensões potencialmente afetadas

Um mesmo Alerta pode afetar múltiplas dimensões.

Classes v0.1:

- `benefit`;
- `harm`;
- `magnitude`;
- `precision`;
- `certainty`;
- `applicability`;
- `conclusion`;
- `regulatory_status`;
- `validity`;
- `scope`;
- `other`.

A cardinalidade é:

> **1:N por AlertVersion.**

Não reduzir a uma única dimensão.

---

## 11. Justificativa

Cada AlertVersion deve explicar:

- qual sinal foi detectado;
- por que ele é potencialmente material;
- que dimensão pode ser afetada;
- por que a classificação preliminar foi atribuída;
- que incerteza permanece.

A justificativa não pode afirmar mudança científica já confirmada se ela ainda não ocorreu.

---

## 12. Urgência de reavaliação

Categorias qualitativas v0.1:

- `routine`;
- `priority`;
- `urgent`.

Essas categorias indicam:

> **prioridade comunicacional relativa, sem prazo temporal/SLA embutido.**

A Fase 4 poderá operacionalizar prazos/thresholds.

Não interpretar:

- routine = X dias;
- priority = Y horas;
- urgent = Z horas

na Fase 3.

---

## 13. Estado do Alerta

Lifecycle científico-comunicacional v0.1:

- `triage`;
- `evaluation`;
- `incorporated`;
- `discarded`.

### triage

Signal foi registrado e ainda está sendo qualificado.

### evaluation

Signal foi aceito para reavaliação do target, mas não há atualização concluída.

### incorporated

O signal foi incorporado a um processo/resultado de atualização rastreável.

Não significa necessariamente:

- mudança de conclusão.

### discarded

Após avaliação, o signal não sustenta ação adicional no escopo do Alerta.

Exige rationale.

---

## 14. Estado editorial

Separado do lifecycle do Alerta.

ProductVersion continua usando:

- draft;
- under_review;
- published;
- superseded;
- archived.

Exemplos permitidos:

- under_review + triage;
- published + evaluation;
- published + incorporated;
- superseded + discarded.

Não colapsar lifecycle em editorial status.

---

## 15. Currentness

O Alerta não cria currentness científico próprio equivalente ao de um produto-síntese.

A View deve projetar:

- currentness do target ProductVersion, quando aplicável;
- lifecycle do Alerta;
- estado editorial do Alerta.

Não criar `product.currency_state` do Alerta apenas para simular lifecycle.

---

## 16. Conclusão científica

`product.product_version.conclusion_text` do Alerta deve permanecer:

> **NULL**

no v0.1.

O conteúdo comunicacional pertence ao contrato especializado do Alerta:

- headline;
- summary;
- justification;
- possible implications;
- reassessment priority.

Isso evita confundir:

> comunicação de signal

com:

> conclusão científica nova.

---

## 17. Headline e summary

Cada AlertVersion deve possuir:

- `headline`;
- `summary`.

Regras:

- headline descritiva, não sensacionalista;
- summary deve descrever potencial impacto, não conclusão confirmada;
- não usar linguagem de recomendação clínica automática;
- não declarar causalidade não suportada.

---

## 18. Verificação

Registrar explicitamente:

- assessment actor;
- actor type;
- verification status;
- verifier;
- verifier actor type;
- verification date.

Estados:

- unverified;
- ai_verified;
- human_verified;
- human_consensus.

Regra:

> **AI verification nunca é human verification.**

---

## 19. Publicação formal

Para v0.1, Alerta publicado exige:

- ProductVersion atual;
- target concreto;
- origem rastreável;
- pelo menos uma dimensão afetada;
- classification persistida;
- urgency qualitativa persistida;
- justification;
- lifecycle diferente de `triage`;
- verification humana do AlertVersion;
- ausência de dependency invalidation;
- assurance mínimo A2 do ProductVersion do Alerta;
- publication_date.

A2 não é expert review.

A ausência de A3 deverá permanecer explicitamente auditável.

---

## 20. Crítico

A classificação `critical` não ganha, na Fase 3:

- SLA numérico;
- auto-publicação;
- trigger automático;
- regra quantitativa própria.

Entretanto, para evitar comunicação não verificada:

> **critical publicado também continua submetido ao mesmo gate humano mínimo do v0.1.**

A Fase 4 poderá endurecer a governança de critical.

---

## 21. Informativo

`informational` não significa irrelevante.

Pode registrar:

- alteração de fonte;
- update que merece awareness;
- evento regulatório;
- nova evidência sem indicação atual de mudança científica material.

Não deve ser usado como categoria de descarte.

---

## 22. Relação com target currentness

O Alerta:

- pode ser emitido com target `current`;
- pode coexistir com `under_evaluation`;
- pode acompanhar `update_recommended` ou `outdated`.

Mas:

> **classification do Alerta não determina automaticamente target currency.**

A mudança de currency deve vir do processo autorizado que a produz.

---

## 23. Relação com atualização

Quando lifecycle muda para `incorporated`, deve haver referência rastreável ao resultado de incorporação, por exemplo:

- nova ProductVersion;
- nova InvestigationVersion;
- CurrencyState;
- MethodDecision/processo de atualização;
- outro versioned target autorizado.

Não usar `incorporated` sem lineage.

---

## 24. Discarded

`discarded` exige:

- rationale;
- actor;
- timestamp;
- preservação da origem;
- histórico/versionamento.

Não deletar Alerta.

---

## 25. Versionamento

Alert Product identity permanece estável.

Nova ProductVersion quando houver mudança material na comunicação, por exemplo:

- classification muda;
- nova dimensão afetada relevante;
- justification muda materialmente;
- urgency muda;
- target muda;
- signal é corrigido;
- lifecycle muda de modo que altere comunicação pública.

Mudanças meramente editoriais podem seguir política geral de correção/versionamento.

Não sobrescrever silenciosamente versão publicada.

---

## 26. Relação com retratação/correção

Alertas podem ser originados por:

- retraction;
- correction;
- expression of concern;
- report update;
- dataset invalidation;
- regulatory update;
- guidance update;
- source withdrawal.

O Alerta comunica o evento.

A propagação científica permanece função de:

- provenance;
- dependency;
- Monitor/update workflow.

---

## 27. Provenance

O caminho mínimo auditável deve permitir:

> source signal → AlertVersion → target version → eventual process/update incorporation.

Quando originado do Monitor:

> Monitor → Cycle → EvidenceEvent/SearchHit/CandidateAssessment → AlertVersion → target.

---

## 28. Dependency

Registrar dependency versionada do source/target pertinente ao AlertVersion.

Não substituir o vínculo especializado por dependency genérica apenas.

---

## 29. Assurance

Assurance do Alert ProductVersion avalia:

> qualidade/verificação da comunicação e sua rastreabilidade.

Não é:

- assurance do target;
- certainty científica;
- validação de nova síntese.

Assurance do target deve ser projetada separadamente como contexto.

---

## 30. Human controls

V0.1 formal publicado exige:

> **human verification explícita do conteúdo/classificação do Alerta.**

Isso não exige automaticamente:

- human expert;
- A3.

Se houver expert review, deve ser registrada sem ser presumida.

---

## 31. Fase 3 × Fase 4

### Fase 3 define

- identidade;
- persistência;
- target;
- source traceability;
- classificação preliminar;
- dimensões afetadas;
- urgency qualitativa;
- lifecycle;
- verification;
- assurance/publication gate;
- View;
- template;
- provenance.

### Fase 4 definirá

- thresholds quantitativos;
- regras automáticas de classificação;
- SLAs;
- tempos máximos;
- gatilhos automáticos;
- políticas transversais de escalonamento;
- canais/notificações;
- priorização global;
- comportamento M3 living.

---

## 32. Saída mínima

O Alerta deve apresentar:

- Alert ID/version;
- headline;
- target;
- signal;
- source;
- signal date/detection date;
- classification;
- affected dimensions;
- justification;
- reassessment priority;
- lifecycle;
- editorial status;
- target currentness;
- verification;
- assurance;
- publication gate;
- lineage;
- limitations/disclosures.

---

## 33. Não criar

A Fase 3 do Alerta não deve criar:

- nova Investigation;
- nova Search;
- nova Synthesis;
- nova CertaintyAssessment;
- currentness científico próprio do Alert;
- threshold quantitativo;
- SLA;
- auto-escalation;
- recomendação clínica;
- auto-update;
- auto-publicação.

---

## 34. Caso Real

Caso Real não é requisito para fechar a formalização taxonômica v0.1.

Fixtures sintéticas devem cobrir:

- Alert formal publicado;
- Alert bloqueado;
- source Monitor;
- source direta;
- target ProductVersion;
- target InvestigationVersion;
- múltiplas dimensões;
- AI-only bloqueado;
- critical sem regra automática;
- incorporated com lineage;
- discarded com rationale.

---

## 35. Próxima etapa

> **Revisão de Coerência Científica e Decisão Arquitetural do Alerta de Evidência.**

Nenhuma migration deve ser criada antes dessa revisão.

---

**Resultado:** especificação científica/funcional do Alerta de Evidência pronta, preservando integralmente a fronteira Fase 3 × Fase 4.
