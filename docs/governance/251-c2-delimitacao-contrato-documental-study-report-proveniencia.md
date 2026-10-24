# Documento 251 — C2: delimitação técnica de identidade Study/Report e proveniência documental

**OES | 2026-10-23 (America/Recife) | C2_SCOPE_DELINEATED / IMPLEMENTATION_NOT_AUTHORIZED**

## 1. Autorização e fonte canônica

Após avaliação de maturidade do demonstrador A1/B1/UX-02/C1, o proprietário aprovou **a delimitação de C2**, não sua implementação. Freshness Gate: main `ae888773c2e562660cdf92f16454ba46821fedc5`, CP266 vigente. Fontes: `docs/architecture/20-modelo-conceitual-dados.md`, `28-politica-identidade-versionamento.md`, `29-politica-proveniencia-lineage.md`, `docs/products/154-reconciliacao-listas-artigos-clusters-reports-ovr01-dcbti.md`, `docs/governance/248-d2-ctgov-e4-conciliacao-documental-20-ncts.md` e aplicação `applications/oes_web/evidence/`.

## 2. Problema e contrato mínimo

A fixture Django atual contém `study_label`, `reports` e `provenance` como texto; isso demonstra leitura, mas não representa explicitamente a identidade Study/Report e fonte da associação.

Proposta de objetos **de leitura local**, não entidades canônicas novas:
- `Signal`: NCT externo, estado documental, limites; NCT é alias, **não** PK científica ou Study criado.
- `StudyReference`: referência local a Study documentalmente identificado, sem emitir UUID/ID OES.
- `ReportReference`: referência documental a Report, rótulo e fonte conhecida; sem DOI/PMID inventado.
- `StudyReportReference`: associação explicitamente sustentada, com fonte e limite; desenho preparado conceitualmente para N:M, **sem dedução por similaridade**.
- `SourceReference`: documento OES com caminho/localizador explícito e categoria `documentary_reference`; não alegar cadeia integral P1–P6 de provenance.

Nenhum status de julgamento humano, resultado clínico, data, versão ou ID científico novo será emitido. Observar os Docs. 20/28/29: identidade estável, Study distinto de Report, aliases externos distintos de PK, provenance vinculada às afirmações e versionamento sem sobrescrita; **este recorte não implementa esses contratos completos**.

## 3. Duas fixtures e invariantes

**NCT01438697:** um Study *já documentado* com Ritterband 2017 e Shaffer 2020 como dois Reports relacionados (Doc. products/154 e conciliação Doc. 248). Um Study, dois Reports; sem duplicar contagem de ensaios, criar OES-ST/OES-RP fictícios ou alegar elegibilidade nova.

**NCT07836491:** `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`; sem StudyReference, ReportReference ou StudyReportReference; não presumir novidade, exclusão, desenho ou resultado. Ausência documental no corpus examinado não significa ausência geral.

**Regras:** vinculação positiva requer fonte delimitada explícita; não produzir datas, DOI/PMID, IDs OES ou decisões por inferência; fontes sem prova permanecerão não estruturadas/limitadas, não ganharão falsa precisão.

## 4. Implementação mínima candidata, ainda não aprovada

Manter Django 5.2 LTS/Python 3.12, GET-only e fixtures JSON locais. Introduzir dataclasses tipadas pequenas ou estruturas equivalentes **apenas quando materialmente necessárias**; preservar compatibilidade de `Signal`, rotas e templates existentes durante transição. Preferir adaptação no domínio e serviço de leitura, sem criar ORM, camada de eventos, repository framework, novos endpoints ou infraestrutura.

Critérios propostos: (1) 25 testes atuais continuam PASS; (2) um único Study conhecido com dois Reports relacionados; (3) NCT não conciliado sem Study/Report; (4) vínculos e fontes verificáveis; (5) nenhuma identidade científica, versão ou julgamento inventado; (6) interface C1 e B1 permanece funcional; (7) testes adicionais de integridade e compatibilidade; (8) sem SQL, Neon, HTTP externo, migrações, deploy ou serviços pagos. CI conectada exige autorização separada.

## 5. Limites e continuidade

C2 é **contrato delimitado, não código implementado**, não altera o modelo conceitual OES. CP266 vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, D2 parcial; BRG/SA, 36 migrations `UNREVIEWED` e Ficha N2 inalterados. Próximo passo: avaliar e autorizar explicitamente a implementação mínima de C2; não reutilizar autorizações anteriores de CI ou integração.

**STOP — C2 delimitado documentalmente, implementação não iniciada.**
