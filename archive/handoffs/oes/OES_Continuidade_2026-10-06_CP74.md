# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP74  
**Checkpoint anterior:** CP73  
**Status:** artefato de continuidade; não normativo  
**Escopo:** revisão de coerência científica e arquitetural do Monitor de Evidências

## 1. Marco

> **MONITOR DE EVIDÊNCIAS — ARCHITECTURAL COHERENCE PASS_WITH_ARCHITECTURAL_DECISIONS.**

Documento:

`docs/products/166-monitor-revisao-coerencia-arquitetura.md`

## 2. Decisão consolidada

> **Monitor = Product próprio + Investigation própria de manutenção que herda N do alvo + camada especializada `maintenance` para target/cycle/candidate/event.**

Reutilizar:

- `investigation.search`;
- `investigation.search_hit`;
- deduplicação existente;
- `product.currency_state`;
- `product.version_change_class`;
- provenance/dependency.

## 3. Decisões-chave

- Search do Monitor não contamina Investigation científica histórica;
- Monitor possui alvo primário explícito;
- Monitoring Cycle não é ProductVersion;
- cycle-search linkage será especializado;
- candidate assessment cobre SearchHits ainda não resolvidos e eventos;
- validity events representam retratação/correção e sinais não bibliográficos;
- currentness permanece em `product.currency_state`;
- mudança científica material permanece em nova ProductVersion do alvo;
- Alert não será implementado nesta etapa;
- assurance do Monitor é próprio do processo, não herdado automaticamente.

## 4. Readiness

- scientific/functional readiness = PASS;
- architectural coherence = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data-contract readiness = READY;
- migration readiness = NOT_YET.

## 5. Próxima etapa

> **Definir o Contrato de Dados v0.1 do Monitor de Evidências.**

O contrato deverá resolver constraints, cardinalidades, lifecycle de cycle, candidate polymorphism, event provenance, currentness linkage, assurance/gates e projeções.

## 6. Observação operacional

O próximo passo possui complexidade arquitetural significativamente maior que a etapa de especificação/revisão e deve ser retomado com maior esforço de raciocínio quando disponível.

**Fim do CP74**
