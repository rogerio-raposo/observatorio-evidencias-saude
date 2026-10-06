# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP36  
**Checkpoint anterior:** CP35  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Caso Real N3-01, duas verificações adversariais e encerramento experimental controlado em A0  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP36

> **Caso Real N3-01: validação técnica ponta a ponta = PASS**

> **Verificação metodológica adversarial 1 = REVISE**

> **ProductVersion 2 corrigida = PASS técnico**

> **Verificação metodológica adversarial 2 = REVISE**

> **Estado final = A0 experimental / não publicável / bloqueado por cobertura bibliográfica insuficiente**

> **Próximo estágio: Revisão de Evidências — N4: especificação científica e funcional**

Run técnico final:

- GitHub Actions **37413884319**;
- conclusion **success**;
- commit validado `f2ba21eaaa2d3c43a95ceb908dd0b097b8e9a1b4`;
- artifact **11389784878**;
- digest `sha256:c4b53864e60be656a1e3de9039b8480746bbeff8f9fcf5b76257989a47a73b58`.

## 2. Documentação N3 consolidada desde CP35

- 106 — protocolo do Caso Real N3-01;
- 107 — busca rápida, desvio e seleção;
- 108 — appraisal experimental;
- 109 — síntese narrativa, GRADE experimental e SoF;
- 110 — validação técnica A0;
- 111 — primeira verificação adversarial = REVISE;
- 112 — busca suplementar corretiva;
- 113 — segunda verificação adversarial = REVISE;
- 114 — encerramento experimental e bloqueio metodológico controlado.

## 3. Produto/caso

Product:

`OES-P-2026-000701`

Estado atual:

- ProductVersion 1 = superseded;
- ProductVersion 2 = current;
- status = under_review;
- depth = N3;
- maintenance = M1;
- assurance = A0;
- publishable = false;
- publication_date = NULL.

## 4. Corpo científico experimental

Conjunto causal principal:

- Lukac et al. 2025;
- Afshar et al. 2025;
- Chowdhury et al. 2026.

Síntese:

- quatro SynthesisVersion narrativas;
- sem meta-análise nova;
- 11 Results estruturados;
- 10 appraisals;
- GRADE experimental:
  - documentation time = LOW;
  - workload/work exhaustion = LOW;
  - work outside work = LOW;
  - note quality/safety = VERY LOW.

Conclusão experimental:

> ambient AI scribes podem reduzir documentação/carga em alguns contextos; magnitude varia; segurança equivalente não foi demonstrada.

## 5. Primeiro adversarial

Resultado:

> **REVISE**

Motivo:

- Kanaparthy 2025 não incluída na checagem de não duplicação;
- estudos prospectivos relevantes não capturados;
- busca substituta após falha do Europe PMC insuficientemente sensível.

Correção:

- expansão terminológica;
- terceira Search;
- 20 hits materializados;
- 34 screening decisions;
- 13 referências;
- conjunto causal/Results/Synthesis/GRADE preservados.

## 6. Segundo adversarial

Resultado:

> **REVISE**

Motivo raiz:

> **search architecture insuficiente para N3.**

Documento 99 exige busca sistemática, reproduzível, documentada e proporcionalmente abrangente e define como padrão inicial pelo menos duas bases bibliográficas relevantes, salvo exceção defensável.

No runtime:

- PubMed foi executável;
- Europe PMC não foi executável;
- OpenAlex direto não foi executável;
- publisher/DOI/citation chasing não equivale a segunda base bibliográfica.

A exceção não foi aceita porque nova busca adversarial ainda encontrou estudos elegíveis não capturados.

## 7. Governança validada

O caso demonstrou que:

- completude estrutural não equivale a assurance;
- technical PASS não equivale a methodological PASS;
- conclusão plausível não compensa busca insuficiente;
- AI quality controls não substituem controles humanos qualificados;
- `revise` não eleva assurance;
- dois `revise` permanecem historicamente rastreáveis;
- A3 não é fabricado;
- publication gate permanece fechado.

## 8. Testes finais

- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- F3-RS-TEMPLATE PASS;
- Rebuild through migration 014 PASS;
- regressões N0–N2/F2-B/S4/S5 PASS.

## 9. Condição de reabertura do Caso N3-01

Reabrir somente se houver:

1. segunda base bibliográfica relevante acessível e reproduzível;
2. nova busca executada;
3. deduplicação/screening;
4. atualização científica quando material;
5. nova verificação adversarial.

Sem isso:

> **não criar ProductVersion 3.**

## 10. Estado da Fase 3

Produtos já exercitados:

- N0 — Evidence Scan: trilha técnica + caso real A1 interno;
- N1 — Resposta de Evidência: caso real A2 publicado;
- N2 — Ficha de Evidência: caso real A2 publicado;
- N3 — Síntese Rápida: contrato/template validados + caso real experimental bloqueado corretamente em A0.

## 11. Ponto exato de retomada

> **Fase 3 — iniciar especificação científica e funcional da Revisão de Evidências — N4.**

Antes de implementação N4, incorporar as lições N3 sobre:

- cobertura mínima de bases;
- dependências bibliográficas;
- protocolo e emendas;
- qualified human controls;
- assurance A3;
- critérios de rerroteamento;
- separação entre validação estrutural e metodológica.

**Fim do CP36**