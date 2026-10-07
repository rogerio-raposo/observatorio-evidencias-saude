# 169 — Monitor de Evidências: Projection Readiness Gate

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **Projection Readiness = NOT_READY**  
**Dependências:** Documentos 165–168; migrations 002–021; MON-T01–T33

---

## 1. Finalidade

Avaliar se o estado persistido após a migration 021 contém semântica suficiente, determinística e auditável para implementar:

> `oes.evidence_monitor_view/0.1`

como fonte única de um futuro renderer read-only.

O gate não avalia template nem Caso Real.

---

## 2. Resultado

> **NOT_READY**

A migration 021 está tecnicamente validada e preserva o contrato estrutural principal, porém a revisão de projeção encontrou lacunas semânticas que poderiam fazer uma View apresentar estado incompleto ou excessivamente otimista.

Nenhuma EvidenceMonitorView deve ser criada antes do hardening descrito neste documento.

---

## 3. O que já está READY para projeção

O schema atual consegue projetar deterministicamente:

- identity do Monitor ProductVersion;
- Question/Investigation do Monitor;
- baseline cutoff;
- maintenance level;
- MonitorDefinition e seus payloads;
- operational MonitorState;
- Monitor Product currency;
- target ProductVersion ou InvestigationVersion;
- target depth;
- target cutoff;
- target assurance quando ProductVersion;
- target currency quando ProductVersion;
- target conclusion quando ProductVersion;
- cycle history;
- latest cycle / latest completed cycle;
- Search executions vinculadas;
- SearchHits;
- EvidenceEvents;
- CandidateAssessments;
- cycle decision;
- cycle verification;
- escalation recommendation;
- resulting target CurrencyState;
- assurance records;
- quality controls;
- publication issues;
- dependency edge target → Monitor.

Esses elementos não justificam, isoladamente, Projection Readiness.

---

## 4. Lacuna PR-MON-01 — cardinalidade de impacto

Documento 165 estabelece:

> **uma mesma evidência poderá ocupar mais de uma categoria de impacto.**

As categorias incluem, entre outras:

- quantitativo;
- certainty;
- aplicabilidade;
- conclusão;
- validade;
- mudança de escopo.

Entretanto `maintenance.candidate_assessment` possui somente:

> `impact_class text`

singular.

`impact_payload` é JSON livre e não possui contrato que garanta representação completa das dimensões adicionais.

Consequência:

> uma View não consegue distinguir deterministicamente “único impacto” de “impactos adicionais omitidos no payload”.

### Decisão

**BLOCKER de Projection Readiness.**

O hardening deverá preservar múltiplas categorias de impacto de forma estruturada.

---

## 5. Lacuna PR-MON-02 — source policy parcialmente interpretada

Documento 167 permite declarar, por instância:

- required source names;
- required source classes;
- minimum bibliographic sources;
- registry;
- regulatory sources;
- retraction/correction sources;
- citation chaining;
- grey literature;
- event-only sources.

E determina:

> **o gate deve validar as regras declaradas na própria source policy.**

A função atual `maintenance.monitor_cycle_source_coverage()` interpreta apenas:

- `required_source_names`;
- `required_source_classes`;
- `minimum_bibliographic_sources`.

Logo, políticas adicionais podem ser persistidas sem entrar no booleano de cobertura.

Consequência:

> `required_source_coverage_satisfied=true` poderia ser projetado mesmo quando parte da política declarada não foi avaliada.

### Decisão

**BLOCKER de Projection Readiness.**

O hardening deve:

- definir gramática v0.1 machine-readable de source requirements; ou
- falhar fechado quando a policy declarar requisito que o engine não sabe avaliar.

---

## 6. Lacuna PR-MON-03 — exceções de cobertura não integradas

Documento 167 estabelece que cycle completo exige:

> todas as sources obrigatórias executadas **ou exceção MethodDecision ativa e justificada**.

A implementação atual de source coverage:

> não consulta `investigation.method_decision`.

Portanto uma indisponibilidade legitimamente documentada não pode ser distinguida de cobertura incompleta não justificada.

Consequência:

- falso blocker; ou
- necessidade de enfraquecer manualmente source policy;
- perda de provenance metodológica.

### Decisão

**BLOCKER de Projection Readiness.**

A cobertura deve projetar separadamente:

- requirements declarados;
- requirements satisfeitos;
- exceptions aceitas;
- requirements não satisfeitos.

Um único booleano sem decomposição não é suficiente.

---

## 7. Lacuna PR-MON-04 — semântica temporal incompleta

Documento 167 exige capacidade de detectar:

- gap de janela não explicado;
- janela anterior ao baseline;
- janela futura inválida;
- cycle fora de ordem;
- Search temporalmente incompatível com cycle, salvo import histórico documentado.

A migration 021 valida:

- `window_end_date >= window_start_date`;
- ordem de `cycle_no` em `previous_cycle_uuid`;
- ordem básica de timestamps do lifecycle.

Mas ainda não implementa de forma completa:

- Search.executed_at compatível com o cycle;
- gap entre cycles e sua justificativa;
- cycle window anterior ao baseline;
- terminal cycle com janela futura;
- decomposição de temporal issues para a View.

Consequência:

> uma View poderia apresentar “cycle complete” sem mostrar uma inconsistência temporal relevante.

### Decisão

**BLOCKER de Projection Readiness.**

---

## 8. Lacuna PR-MON-05 — vínculo Cycle → CurrencyState ainda regravável

`maintenance.cycle_currency_state` representa o resultado histórico de currentness produzido por um cycle.

No estado atual:

- PK impede duas linhas simultâneas por cycle;
- trigger valida target e mapping decision↔currency no INSERT/UPDATE;
- porém o vínculo pode ser atualizado para outra CurrencyState compatível.

Isso permite reescrever a consequência histórica do cycle sem cadeia de supersession.

Consequência:

> audit trail do cycle pode mudar silenciosamente.

### Decisão

**BLOCKER de Projection Readiness.**

No v0.1 o vínculo deverá ser:

> **imutável após criação.**

Correção de uma decisão científica deve ocorrer por novo cycle/correção explícita, não overwrite do vínculo histórico.

---

## 9. Drift dinâmico de Search

O guard `cycle_search` valida a Search no momento do vínculo.

Entretanto `investigation.search` é estrutura transversal e não é imutável globalmente.

Se a Search vinculada for posteriormente alterada:

- InvestigationVersion;
- status;
- executed_at;
- source metadata;

a consistência original pode deixar de existir.

A View/gate deve:

> **revalidar dinamicamente a coerência das Searches vinculadas, sem exigir mudança destrutiva no contrato global de Search.**

Esse ponto será tratado junto ao PR-MON-04/source coverage.

---

## 10. Elementos que não são blockers

Não constituem blocker neste gate:

- target polimórfico ProductVersion/InvestigationVersion;
- absence de target assurance/currency para target InvestigationVersion;
- absence de Alert Product;
- M3 formal bloqueado;
- absence de thresholds transversais da Fase 4;
- absence de template;
- absence de Caso Real.

Esses estados podem ser projetados explicitamente como `not_applicable`, `blocked` ou ausentes conforme contrato.

---

## 11. Hardening necessário

Antes da EvidenceMonitorView, executar uma migration aditiva de hardening que resolva:

1. representação estruturada de múltiplas impact categories;
2. gramática machine-readable/fail-closed de source requirements;
3. integração de MethodDecision para source exceptions;
4. temporal consistency de cycle/Search;
5. cycle-window issues;
6. imutabilidade de CycleCurrencyState;
7. revalidação dinâmica de Search linkage no gate.

A migration não deve:

- implementar Alert;
- criar thresholds globais;
- iniciar Fase 4;
- alterar entidades científicas canônicas;
- criar template.

---

## 12. Numeração de migrations

Como a migration 022 havia sido apenas uma candidata futura para View e ainda não existe:

> **migration 022 será usada para hardening de Projection Readiness.**

A EvidenceMonitorView passa a ser candidata para:

> **migration 023**, somente após novo gate.

---

## 13. Testes mínimos de hardening

A migration 022 deverá demonstrar, no mínimo:

- candidato com dois impactos preservado e projetável;
- duplicata de impact category rejeitada;
- source requirement desconhecido fecha o gate;
- source requirement conhecido é avaliado;
- MethodDecision de exceção aceita é distinguida de requirement satisfeito;
- exceção aberta/rejeitada não satisfaz cobertura;
- Search executada fora da janela é detectada;
- Search movida para outra Investigation após linkage é detectada;
- janela anterior ao baseline é detectada;
- gap temporal sem rationale é detectado;
- gap com rationale documentada é distinguível;
- CycleCurrencyState não pode ser regravado;
- regressões MON-T01–T33 permanecem verdes;
- rebuild permanece verde.

---

## 14. Decisão

> **Projection Readiness Gate = NOT_READY.**

Motivo:

> **o núcleo técnico do Monitor está validado, mas a semântica necessária para uma projeção read-only integral ainda possui cinco lacunas materiais.**

Não criar View nem template neste estado.

---

## 15. Próxima etapa

> **Formalizar e implementar o hardening de Projection Readiness na migration 022, com testes próprios.**

Depois de PASS:

> **reexecutar o Projection Readiness Gate.**

Somente se READY:

> implementar `EvidenceMonitorView 0.1` em migration 023.

---

**Resultado final:** **NOT_READY para EvidenceMonitorView/template; migration 022 de hardening autorizável como próxima etapa.**
