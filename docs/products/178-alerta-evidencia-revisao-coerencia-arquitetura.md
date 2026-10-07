# 178 — Alerta de Evidência: Revisão de Coerência Científica e Decisão Arquitetural

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — pronto para Contrato de Dados v0.1**  
**Dependências:** Documentos 40, 165–177; OES-P1; migrations 002–023

---

## 1. Finalidade

Confrontar o Documento 177 com a arquitetura física vigente e decidir:

- identidade do Alerta;
- necessidade ou não de Investigation própria;
- target linkage;
- source linkage;
- lifecycle;
- affected dimensions;
- versionamento;
- currentness;
- assurance/publication gate;
- integração com Monitor;
- fronteira Fase 3 × Fase 4.

Nenhuma migration é criada neste documento.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

A arquitetura vigente suporta o Alerta com:

- Product/ProductVersion genéricos já existentes;
- provenance/dependency existentes;
- uma extensão pequena do namespace `maintenance`.

Não é necessário criar entidade científica nova.

---

## 3. Decisão A — Alerta é Product persistente

Cada Alerta formal será representado por:

- `core.entity(entity_type='Product')`;
- `product.product`;
- `core.entity_version`;
- `product.product_version`;
- `product_type='evidence_alert'`.

Motivos:

- identidade estável;
- versão auditável;
- correções preservadas;
- estado editorial;
- publication date;
- assurance existente;
- rendered artifact futuro.

O fato de ser “evento comunicacional” não elimina a necessidade de identidade/versionamento quando a comunicação é persistida formalmente.

---

## 4. Decisão B — Alerta não cria Investigation

Não criar:

- nova `investigation.investigation`;
- nova `investigation.investigation_version`;
- Search própria;
- Question própria apenas para o Alerta.

O ProductVersion do Alerta deve possuir:

> **um Investigation link de contexto**, não uma Investigation “do Alerta”.

Role candidata:

> `source_context`

Quando originado em Monitor:

- source_context = Monitor InvestigationVersion.

Quando não originado em Monitor:

- source_context = InvestigationVersion científica diretamente relacionada ao target/signal.

Essa decisão satisfaz a arquitetura comum de Product ↔ Investigation sem falsificar uma nova investigação.

---

## 5. Decisão C — target linkage especializado

Criar target explícito no registro especializado do Alerta.

Exatamente um:

- `target_product_version_uuid`; ou
- `target_investigation_version_uuid`.

Não utilizar apenas `product.investigation_link` para representar target.

Motivo:

> contexto de origem e alvo potencialmente afetado são relações diferentes.

---

## 6. Decisão D — estrutura especializada central

Criar:

> `maintenance.evidence_alert`

Cardinalidade:

> **1:1 com Alert ProductVersion.**

Campos conceituais mínimos:

- Alert ProductVersion;
- target ProductVersion xor InvestigationVersion;
- headline;
- summary;
- signal date;
- detected_at;
- preliminary classification;
- reassessment priority;
- lifecycle status;
- justification;
- assessed_by;
- actor_type;
- verification status;
- verifier metadata;
- issued_at;
- resolution rationale;
- incorporation target version, quando aplicável;
- incorporation CurrencyState, quando aplicável.

---

## 7. Decisão E — fontes normalizadas 1:N

Criar:

> `maintenance.alert_source`

Um AlertVersion pode possuir múltiplas fontes.

Cada source row deverá apontar para exatamente um:

1. CandidateAssessment;
2. EvidenceEvent;
3. EntityVersion;
4. Artifact;
5. URI.

Campos adicionais:

- source role = primary/supporting;
- source date;
- description/rationale;
- sequence.

Regra:

> **cada AlertVersion deve possuir exatamente uma fonte primary antes de publicação.**

---

## 8. Decisão F — não colapsar event em Alert

`maintenance.evidence_event` continua sendo:

> evento detectado pelo Monitor.

`maintenance.evidence_alert` é:

> comunicação persistente selecionada.

Um EvidenceEvent pode:

- não gerar Alert;
- gerar um Alert;
- futuramente sustentar mais de um AlertVersion da mesma identidade.

Não copiar EvidenceEvent como se fosse Alert automaticamente.

---

## 9. Decisão G — dimensões afetadas normalizadas 1:N

Criar:

> `maintenance.alert_affected_dimension`

Classes:

- benefit;
- harm;
- magnitude;
- precision;
- certainty;
- applicability;
- conclusion;
- regulatory_status;
- validity;
- scope;
- other.

Cada AlertVersion formal precisa:

> pelo menos uma dimensão.

Um dimension row poderá conter:

- rationale;
- sequence.

Não criar score agregado.

---

## 10. Decisão H — classification é persistida, não calculada

Campo:

> `classification`

Valores:

- informational;
- relevant;
- critical.

A database:

- valida domínio;
- persiste;
- audita.

A database **não**:

- calcula automaticamente classification;
- define threshold quantitativo;
- promove classificação por contagem de sources;
- usa tempo desde publicação como trigger.

---

## 11. Decisão I — reassessment priority é qualitativa

Campo:

> `reassessment_priority`

Valores:

- routine;
- priority;
- urgent.

Sem duração associada.

Nenhuma função da migration poderá traduzir esses estados em horas/dias.

---

## 12. Decisão J — lifecycle pertence ao AlertVersion

Campo:

> `lifecycle_status`

Valores:

- triage;
- evaluation;
- incorporated;
- discarded.

Mudança material de lifecycle:

> **gera nova ProductVersion do mesmo Alert Product.**

Não atualizar silenciosamente versão publicada.

---

## 13. Decisão K — incorporação rastreável

Para `lifecycle_status='incorporated'`, exigir pelo menos um:

- `incorporated_version_uuid`; ou
- `incorporated_currency_state_uuid`.

O primeiro referencia:

> `core.entity_version`

O segundo:

> `product.currency_state`.

Objetivo:

> provar que o signal entrou em processo/estado versionado do target.

Não inferir “conclusão mudou”.

---

## 14. Decisão L — discarded exige rationale

Para:

> `lifecycle_status='discarded'`

exigir:

- resolution rationale;
- assessment actor;
- timestamp/versionamento preservado.

Não deletar Alert.

---

## 15. Decisão M — Product currentness do Alerta não será criado

Não criar automaticamente:

> `product.currency_state` para o Alert ProductVersion.

Motivo:

- lifecycle já representa estado do evento comunicacional;
- target currency é o estado científico relevante;
- criar Alert currency paralelo confundiria comunicação com atualidade científica.

A View deverá projetar:

- Alert editorial status;
- Alert lifecycle;
- target currency, quando target ProductVersion.

---

## 16. Decisão N — conclusion_text deve permanecer NULL

No ProductVersion de Alert:

> `conclusion_text IS NULL`

v0.1.

O conteúdo especializado é:

- headline;
- summary;
- justification.

Isso impede que uma comunicação de signal pareça nova conclusão científica.

---

## 17. Decisão O — evidence cutoff do ProductVersion

`product.product_version.evidence_cutoff_date` do Alerta significa:

> **data até a qual as informações usadas para esta versão do Alerta foram consideradas.**

Não significa:

- cutoff científico do target;
- data da Search do Monitor;
- publication date.

A View deve mostrar separadamente:

- alert information cutoff;
- target cutoff;
- source dates.

---

## 18. Decisão P — source_context Investigation

Regra v0.1:

> exatamente um `product.investigation_link` com `role='source_context'`.

Não exigir `role='primary'`.

Consequências:

- generic Product schema permanece utilizável;
- Alert não ganha Investigation artificial;
- context lineage fica explícita.

---

## 19. Decisão Q — dependency edges

Criar/validar, conforme aplicabilidade:

### target

> target version → AlertVersion  
> `dependency_type='maintenance_alert_target'`

### versioned source

> source EntityVersion → AlertVersion  
> `dependency_type='maintenance_alert_source'`

### incorporation

> AlertVersion → incorporated version  
> `dependency_type='maintenance_alert_incorporation'`

Essas edges complementam os links especializados.

---

## 20. Decisão R — provenance

`provenance.record` poderá apontar para AlertVersion com:

- field_path;
- source ReportVersion quando aplicável;
- process_type;
- process_record_uuid;
- transformation;
- actor.

AlertSource continua necessário porque provenance genérica não representa adequadamente:

- EvidenceEvent;
- CandidateAssessment;
- URI;
- source role.

---

## 21. Decisão S — verificação

`maintenance.evidence_alert` deve persistir:

- assessed_by;
- actor_type;
- verification_status;
- verified_by;
- verifier_actor_type;
- verified_at.

Regras iguais às já usadas no Monitor:

- unverified sem verifier;
- ai_verified exige ai_system;
- human_verified/human_consensus exige human actor.

---

## 22. Decisão T — assurance

Reutilizar:

> `product.assurance_record`

e:

> `product.assurance_level(...)`.

Não criar alert assurance paralelo.

Interpretação:

- A1 = AI methodological verification;
- A2 = A1 + owner governance approval;
- A3 = A2 + expert independent review.

Assurance do target:

> projetada separadamente; nunca herdada.

---

## 23. Decisão U — gate de publicação v0.1

`product.evidence_alert_publication_issues(...)` deverá bloquear publicação formal quando houver, no mínimo:

- ProductVersion ausente;
- wrong product_type;
- Alert specialized record ausente;
- source_context Investigation ausente/múltipla;
- target ausente/inválido;
- primary AlertSource ausente/múltipla;
- affected dimension ausente;
- headline/summary/justification ausentes;
- classification inválida;
- reassessment priority inválida;
- lifecycle=triage;
- human verification ausente;
- assurance < A2;
- publication_date ausente;
- Alert core EntityVersion não current;
- target invalidated/archived;
- dependency target ausente;
- invalidated dependency;
- incorporated sem incorporation linkage;
- discarded sem resolution rationale;
- `conclusion_text` indevidamente preenchido.

Warnings candidatos:

- target currency under_evaluation/update_recommended/outdated;
- A3 ausente;
- classification=critical sem expert review;
- source origin fora de Monitor;
- target assurance abaixo de A2, quando informativo para interpretação.

Warnings não são auto-blockers salvo regra explícita futura.

---

## 24. Decisão V — critical não cria política Fase 4

O gate não fará:

- critical → prazo;
- critical → A3 obrigatório;
- critical → auto-update;
- critical → auto-notification.

Pode emitir warning:

> `CRITICAL_WITHOUT_EXPERT_REVIEW`

sem impedir o contrato v0.1 de funcionar.

Qualquer endurecimento dessa regra pertence à revisão futura/Fase 4.

---

## 25. Decisão W — comunicação formal exige human verification

Mesmo com A2:

> Alert publicado precisa `human_verified` ou `human_consensus`.

Motivo:

- A2 inclui owner approval, mas owner approval não é verificação humana técnica do conteúdo;
- o signal e sua classificação comunicacional precisam de verificação explícita;
- evita publicar AI-only Alert como comunicação formal.

Isso não transforma human reviewer em expert.

---

## 26. Decisão X — View

Após o contrato físico estar validado, criar:

> `product.evidence_alert_view/0.1`

em migration separada se necessário.

A View deverá projetar:

- identity;
- source context;
- target;
- alert content;
- source(s);
- affected dimensions;
- verification;
- target currency;
- target assurance;
- lifecycle/incorporation;
- lineage;
- audit/publication issues;
- assurance records.

---

## 27. Decisão Y — template

Template deverá consumir exclusivamente a View.

Não poderá:

- classificar;
- definir urgency;
- derivar target currentness;
- criar Alert;
- sugerir prazo Fase 4;
- reescrever conclusão científica.

---

## 28. Estruturas físicas mínimas

Migration candidata 024:

1. `maintenance.evidence_alert`;
2. `maintenance.alert_source`;
3. `maintenance.alert_affected_dimension`;
4. integrity triggers;
5. publication issues/is_publishable helpers;
6. fixture/test support.

EvidenceAlertView poderá entrar:

- na mesma migration se o contrato físico já suportar projeção integral; ou
- em migration 025 após Projection Readiness Gate.

Preferência:

> **separar contrato físico e View**, seguindo a disciplina usada em Mapa, Overview e Monitor.

---

## 29. Critérios arquiteturais de PASS

Antes da migration:

1. Alert = Product;
2. zero nova Investigation;
3. target versionado único;
4. source context explícito;
5. source 1:N normalizada;
6. exatamente uma primary source;
7. dimensions 1:N;
8. classification não calculada;
9. urgency não temporal;
10. lifecycle versionado;
11. incorporated rastreável;
12. discarded auditável;
13. Alert sem scientific conclusion própria;
14. Alert sem Product currency artificial;
15. assurance reutilizada;
16. human verification explícita;
17. target assurance/currentness separados;
18. Fase 4 não antecipada.

Todos os critérios estão satisfeitos por esta decisão.

---

## 30. Próxima etapa

> **Contrato de Dados v0.1 do Alerta de Evidência.**

Somente após esse documento:

> migration 024 + fixture + testes.

---

**Resultado:** arquitetura do Alerta = PASS_WITH_ARCHITECTURAL_DECISIONS; pronta para contrato de dados sem iniciar Fase 4.
