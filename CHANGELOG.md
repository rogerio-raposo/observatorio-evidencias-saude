# Changelog

Este arquivo registra mudanças metodológicas consolidadas no Observatório de Evidências em Saúde — OES.

Durante a fase de concepção, os documentos são vivos e o histórico Git preserva alterações intermediárias. Entradas neste changelog correspondem a marcos ou decisões consolidadas relevantes.

## 2026-10-03 — Inicialização do repositório

### Adicionado

- Repositório definido como fonte canônica do projeto.
- README com visão geral, fluxo metodológico e arquitetura documental prevista.
- Documento 00 — Concepção.
- Documento 01 — Escopo Científico e Taxonomia das Perguntas.
- Documento 02 — Arquitetura de Níveis de Investigação e Produtos.
- Documento 03 — Entrada, Triagem e Roteamento Metodológico.
- Documento 10 — Busca e Recuperação de Evidências.

### Decisões estruturais registradas

- Metodologia antes da automação.
- Pergunta científica precede busca definitiva.
- Ausência de pirâmide universal de evidência.
- Risco de viés e certeza do corpo de evidências são processos distintos.
- Profundidade N0–N4 e manutenção M0–M3 são dimensões independentes.
- Ficha de Evidência é candidata à unidade persistente central.
- Roteamento inicial baseado em regras e justificativa, sem score numérico.
- Estudo e publicação serão entidades distintas.
- Busca científica deverá ser auditável e proporcional ao nível de investigação.
- IA será ferramenta de apoio, não fonte de evidência.


## 2026-10-03 — Mecanismo formal de continuidade

### Adicionado

- Template canônico de abertura e continuidade.
- Arquitetura `snapshot + pointer` para checkpoints.
- Ponteiro operacional único em `archive/handoffs/oes/README.md`.
- Checkpoint inaugural `CP01`.
- Freshness Gate obrigatório antes de retomadas.
- Diagnóstico de Continuidade obrigatório.
- Separação entre `STATE.md` (painel vivo) e checkpoints (snapshots imutáveis).

### Regra operacional

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

Checkpoints são artefatos operacionais e não normativos. A documentação canônica vigente prevalece em caso de conflito.


## 2026-10-03 — Documento 11: Elegibilidade, Triagem e Seleção

### Adicionado

- `docs/methodology/11-elegibilidade-triagem-selecao.md`.
- `templates/screening-record.md`.

### Decisões metodológicas

- critérios de elegibilidade pré-especificados para investigações formais;
- separação entre registro, relatório/publicação e estudo;
- triagem inicial orientada à sensibilidade;
- dúvida em título/resumo favorece avanço para texto completo;
- relatório não recuperado não equivale a estudo excluído;
- ausência de dado utilizável não implica inelegibilidade;
- motivos de exclusão de texto completo devem ser explícitos;
- múltiplos relatórios devem ser vinculados a um Study ID;
- N4 exige dois revisores independentes para decisão final por texto completo;
- N3 pode utilizar triagem abreviada calibrada e declarada;
- IA pode priorizar e assistir, mas não recebe autorização geral para exclusão silenciosa em N2–N4;
- PRISMA é referência para rastreabilidade do fluxo de seleção.

### Próxima etapa

- Documento 12 — Avaliação de Risco de Viés e Qualidade Metodológica.


## 2026-10-03 — Documento 12: Risco de Viés e Qualidade Metodológica

### Adicionado

- `docs/methodology/12-avaliacao-risco-vies.md`.
- `templates/risk-of-bias-record.md`.

### Decisões metodológicas

- risco de viés, qualidade metodológica, qualidade de relato, aplicabilidade e certeza são constructos distintos;
- não será criado score universal de qualidade;
- instrumentos manterão suas categorias e lógica originais;
- versão exata de cada ferramenta deverá ser registrada;
- RoB 2 será padrão para ensaios randomizados;
- ROBINS-I será candidato padrão para intervenções não randomizadas, com versão fixada por protocolo;
- ROBINS-E será candidato para exposições observacionais;
- QUADAS-3 será padrão para acurácia diagnóstica;
- QUIPS será candidato padrão para fatores prognósticos;
- PROBAST+AI será padrão para modelos de predição;
- JBI será referência central para prevalência, qualitativos e outros desenhos quando apropriado;
- ROBIS será padrão para risco de viés de revisões sistemáticas;
- AMSTAR 2 poderá complementar appraisal de revisões, sem score numérico;
- N3: um avaliador + verificação de todos os julgamentos por segundo avaliador;
- N4: pelo menos dois avaliadores independentes;
- IA poderá assistir, mas não produzirá julgamento final autônomo em N2–N4;
- alto risco de viés não implica exclusão automática;
- aplicabilidade ao Brasil permanece separada da validade interna.

### Próxima etapa

- Documento 13 — Extração e Estruturação de Dados.


## 2026-10-03 — Documento 13: Extração e Estruturação de Dados

### Adicionado

- `docs/methodology/13-extracao-dados.md`.
- `templates/data-extraction-record.md`.

### Decisões metodológicas

- Study, Report e Result permanecem entidades distintas;
- valor originalmente relatado e valor derivado serão preservados separadamente;
- proveniência será obrigatória para dados críticos;
- formulário estruturado será padrão em N2–N4;
- N3: um extrator com verificação por segundo revisor dos dados críticos capazes de alterar resultados ou conclusões;
- N4: extração independente em duplicata para dados de desfecho que alimentem sínteses;
- múltiplos Reports serão vinculados e reconciliados, sem duplicação artificial de estudos;
- discrepâncias entre fontes deverão ser registradas e resolvidas por regra explícita;
- estados de dados ausentes serão diferenciados;
- transformações deverão ser reproduzíveis e manter o valor de origem;
- dados obtidos de gráficos serão identificados como derivados;
- IA poderá auxiliar extração e controle de qualidade, mas não substituir silenciosamente a verificação humana de dados críticos em N3–N4;
- correções deverão preservar histórico e rastreabilidade;
- o futuro modelo de dados deverá suportar múltiplos Reports/Results, proveniência por campo, valores derivados e versionamento.

### Próxima etapa

- Documento 14 — Síntese de Evidências.


## 2026-10-03 — Documento 14: Síntese de Evidências

### Adicionado

- `docs/methodology/14-sintese-evidencias.md`.
- `templates/synthesis-record.md`.

### Decisões metodológicas

- síntese não é sinônimo de meta-análise;
- combinabilidade será julgada clínica, metodológica e estatisticamente;
- cada síntese terá unidade analítica explícita e Synthesis ID provisório;
- escolha entre common/fixed-effect e random-effects não será feita por teste Q ou corte de I²;
- random-effects deverá ser interpretado com heterogeneidade e, quando apropriado, intervalo de predição;
- subgrupos serão preferencialmente pré-especificados e comparados por interação;
- meta-regressão será utilizada com parcimônia;
- análises de sensibilidade testarão robustez e não escolherão o resultado mais conveniente;
- risco de viés deverá ser incorporado à interpretação;
- missing evidence será distinguido do risco de viés interno;
- funnel plot não será tratado como diagnóstico automático de publication bias;
- eventos raros, multi-arm e dependência exigirão métodos específicos;
- network meta-analysis exigirá transitivity e coherence;
- SWiM será referência para relato de síntese quantitativa sem meta-análise;
- vote counting por significância estatística será evitado;
- DTA, prognóstico, predição, prevalência/incidência e qualitativos usarão métodos especializados;
- JBI meta-aggregation será abordagem candidata para síntese qualitativa compatível;
- N3–N4 exigirão análise reproduzível e versionada;
- IA poderá auxiliar, mas não decidirá silenciosamente combinabilidade, modelo ou conclusão.

### Próxima etapa

- Documento 15 — Avaliação da Certeza/Confiança no Corpo de Evidências.

## 2026-10-03 — Documento 15: Certeza/Confiança no Corpo de Evidências

### Adicionado

- `docs/methodology/15-certeza-evidencia.md`.
- `templates/certainty-assessment-record.md`.

### Decisões metodológicas

- certeza será avaliada no corpo de evidências e, em regra, por desfecho/comparação/timepoint/estimando;
- GRADE será a referência central para evidência quantitativa quando aplicável;
- versão/fonte operacional do GRADE deverá ser registrada;
- não haverá score numérico universal de certeza;
- risco de viés, inconsistência, indirectness, imprecisão e missing evidence/publication bias serão julgados explicitamente;
- I² e significância estatística não serão regras automáticas de downgrade;
- ausência de evidência não será classificada automaticamente como certeza muito baixa;
- fatores de elevação serão aplicados apenas quando cabíveis e justificados;
- dupla penalização da mesma limitação entre domínios deverá ser evitada;
- aplicabilidade ao Brasil permanecerá separada da indirectness quando a pergunta-alvo não for especificamente brasileira;
- diagnóstico, prognóstico, predição, prevalência/incidência e exposição usarão orientação específica quando necessária;
- NMA poderá usar abordagem GRADE específica ou CINeMA, com avaliação de evidência direta/indireta e incoerência;
- GRADE-CERQual será o framework preferencial para confiança em achados qualitativos;
- GRADE quantitativo e CERQual não serão convertidos automaticamente um no outro;
- Summary of Findings será utilizado quando apropriado;
- N3 exigirá verificação independente dos julgamentos materiais e N4, pelo menos dois avaliadores independentes;
- IA poderá auxiliar, mas não produzirá autonomamente certeza final em N2–N4;
- certeza permanecerá separada de recomendação.

### Próxima etapa

- Consolidar o modelo conceitual de dados e aprofundar a arquitetura tecnológica do OES.

## 2026-10-03 — Documento 20: Modelo Conceitual de Dados

### Adicionado

- `docs/architecture/20-modelo-conceitual-dados.md`.

### Decisões arquiteturais

- o modelo conceitual é independente de tecnologia;
- entidades científicas, registros operacionais, produtos e artefatos derivados são camadas distintas;
- Question e Investigation são entidades distintas;
- Study, Report e Result permanecem entidades distintas;
- Search possui identidade própria e relação N:M com Reports por meio de Search Hit/Retrieval Record;
- Result preserva proveniência e pode ser documentado por múltiplos Reports;
- Synthesis é entidade explícita com relação N:M com Results por Synthesis Contribution;
- Certainty Assessment é entidade explícita e versionável;
- Ficha de Evidência permanece candidata a objeto persistente composto, sem substituir Study/Synthesis;
- proveniência e versionamento são requisitos transversais;
- o modelo físico somente será definido após validação do modelo conceitual e lógico.

### Transição de fase

- a base metodológica inicial dos Documentos 10–15 passa a sustentar a Fase 2 — Modelo de Dados da Evidência;
- próxima etapa: modelo lógico de dados.

## 2026-10-03 — Documento 21: Modelo Lógico de Dados

### Adicionado

- `docs/architecture/21-modelo-logico-dados.md`.

### Refinamento do Documento 20

- a relação Study ↔ Report foi refinada de 1:N para N:M por `StudyReportLink`, preservando o caso predominante de múltiplos Reports por Study e suportando Reports que documentem múltiplos Studies.

### Decisões lógicas

- Question terá hierarquia por autorreferência;
- Investigation poderá vincular múltiplas Questions via `InvestigationQuestion`;
- Concept foi previsto para normalização semântica, sem fixar vocabulário nesta fase;
- Outcome será entidade reutilizável;
- SearchHit preservará a ocorrência bruta de recuperação;
- deduplicação será auditável e reversível;
- identificadores externos de Study e Report serão aliases, não chaves primárias;
- Result exigirá Study e proveniência documental;
- transformações materiais gerarão `DerivationRecord`;
- RiskAssessment manterá julgamentos por domínio;
- SynthesisContribution materializará Result N:M Synthesis;
- ReviewFinding suportará síntese qualitativa e CERQual;
- CertaintyAssessment será vinculada explicitamente à unidade avaliada;
- Product agregará Investigation/Synthesis/Certainty por relações próprias;
- Ficha de Evidência será inicialmente tratada como `Product subtype`, decisão reversível;
- ProvenanceRecord será transversal;
- merges de identidade serão auditáveis e reversíveis;
- nenhuma decisão lógica fixa SGBD ou stack tecnológica.

### Próxima etapa

- validação arquitetural por casos de uso antes do modelo físico.

## 2026-10-03 — Documento 22: Validação Arquitetural por Casos de Uso

### Adicionado

- `docs/architecture/22-validacao-arquitetural-casos-uso.md`.

### Resultado da primeira bateria

- 15 cenários arquiteturais testados;
- 6 PASS;
- 7 PASS WITH REFINEMENT;
- 2 FAIL estruturais detectados antes da implementação física.

### Correções incorporadas ao Documento 21

- `ScreeningDecision` passou a suportar target tipado Report/Study;
- `StudyGroup` e `GroupComponent` foram adicionados;
- `SynthesisNode`, `SynthesisNodeMapping` e `SynthesisContrast` foram adicionados para NMA;
- `DiagnosticResultDetail` foi adicionado;
- `PredictionModel`, `PredictionModelIdentifier` e `PredictionModelStudyRole` foram adicionados;
- `FindingContribution` foi adicionado para síntese qualitativa;
- `ReportRelation` foi adicionado para correções/retrações e relações documentais;
- `InvestigationRelation` foi adicionado para updates/derivações;
- Product passou a apontar para versões específicas de Synthesis e Certainty;
- Synthesis passou a registrar origem e eventual Study externo fonte;
- Result passou a aceitar grupos estruturados e timepoint estruturado.

### Próxima etapa

- checagem de integridade entre Documentos 20–22 e fechamento do modelo lógico candidato.

## 2026-10-03 — Documento 23: Checagem de Integridade do Modelo de Dados

### Adicionado

- `docs/architecture/23-checagem-integridade-modelo-dados.md`.

### Resultado

- Documentos 20–22 verificados contra os protocolos metodológicos 13–15;
- separações Study/Report/Result, Risk of Bias/Certainty e Synthesis/Product preservadas;
- proveniência e versionamento considerados suficientes para evolução arquitetural;
- métodos especializados de NMA, diagnóstico, predição e qualitativos cobertos após refinamentos;
- `ApplicabilityAssessment — OES-AP` reservado no modelo lógico sem impor categorias ou score antes da formalização metodológica.

### Gate

- **GATE F2-A — Modelo Lógico Candidato: APROVADO**.

### Autorizado

- elaboração de primeiro desenho físico candidato;
- comparação de alternativas relacionais, documentais, grafo e híbridas.

### Ainda não autorizado

- schema definitivo;
- stack tecnológica definitiva;
- automação ampla;
- cristalização de aplicabilidade, produtos ou monitoramento ainda não formalizados.

### Próxima etapa

- alternativas arquiteturais e primeiro desenho físico candidato.

## 2026-10-03 — Documentos 24–25: Persistência e desenho físico candidato

### Adicionado

- `docs/architecture/24-alternativas-arquiteturais-persistencia.md`;
- `docs/architecture/25-primeiro-desenho-fisico-candidato.md`.

### Arquitetura candidata

- **OES-H1:** núcleo relacional canônico + extensões documentais controladas + object storage + projeções opcionais;
- bancos documentais e de grafo permanecem alternativas/projeções especializadas, não fontes paralelas de verdade nesta fase;
- PostgreSQL foi adotado apenas como referência de prova arquitetural por combinar constraints relacionais e JSONB, sem decisão definitiva de stack.

### Desenho físico candidato

- **OES-P1:** registry global de entidades e versões + entidades tipadas + tabelas associativas + JSONB controlado + artifact metadata + dependency projection;
- `core.entity` fornece identidade estável;
- `core.entity_version` fornece FK real para versões e elimina a necessidade de referências polimórficas sem integridade;
- provenance aponta para versões concretas;
- object storage mantém bytes fora das tabelas de domínio;
- `dependency_edge` é projeção derivada, não fonte primária;
- JSONB não poderá substituir relações que exigem FK.

### Próxima etapa

- PoC-S1 do schema mínimo para validar OES-P1.

## 2026-10-03 — PoC-S1: Schema mínimo e validação estática

### Adicionado

- `database/poc-s1.sql`;
- `database/poc-s1-smoke.sql`;
- `database/README.md`;
- `docs/architecture/26-poc-s1-validacao.md`.

### Validação estática do schema

- 32 tabelas;
- 5 views;
- 63 referências;
- nenhuma referência a tabela inexistente;
- nenhuma tabela CREATE duplicada;
- parênteses e bloco BEGIN/COMMIT balanceados.

### Validação estática do smoke test

- 30 statements INSERT;
- 30 alvos de INSERT válidos;
- nenhuma tabela/view ausente em FROM/JOIN;
- 101 UUIDs bem formados;
- CTE recursiva de lineage presente;
- ROLLBACK final presente.

### Limitação

- o ambiente de execução não possui PostgreSQL, psql, initdb, Docker ou Podman; portanto o DDL ainda não foi executado contra um servidor real.

### Gate

- **GATE F2-B — Execução da PoC-S1 em PostgreSQL: PENDENTE**.

### Próxima etapa permitida

- plano de testes F2-B;
- política de identidade/versionamento;
- política de proveniência;
- sem promoção do schema ou stack.

## 2026-10-03 — Trilha B: F2-B, identidade/versionamento e provenance

### Adicionado

- `docs/architecture/27-plano-testes-gate-f2b.md`;
- `docs/architecture/28-politica-identidade-versionamento.md`;
- `docs/architecture/29-politica-proveniencia-lineage.md`.

### Hardening da PoC-S1

- `core.entity_version.supersedes_version_uuid` passou a possuir FK composta que garante supersessão dentro da mesma entity;
- função `core.assert_entity_type()` adicionada com delimitador PL/pgSQL explícito;
- 9 triggers garantem compatibilidade entre registry `entity_type` e tabelas de subtipo;
- `provenance.record` passou a suportar estado, supersessão, invalidação e motivo sem UPDATE destrutivo;
- validação estática atual: 32 tabelas, 5 views, 64 REFERENCES, 9 triggers e zero referências a tabelas ausentes.

### Política

- identidade estável e versão separada;
- IDs externos permanecem aliases;
- histórico não será sobrescrito;
- provenance é dado de primeira classe;
- dependency_edge permanece projeção derivada;
- plano F2-B define 14 grupos de teste, incluindo constraints, versionamento, lineage, rollback e reconstrução do zero.

### Próxima etapa

- política de migrações;
- extensão controlada da PoC para Search/Screening/RiskAssessment;
- F2-B continua pendente de PostgreSQL real.

## 2026-10-03 — Política de migrações e PoC-S2

### Adicionado

- `docs/architecture/30-politica-migracoes.md`;
- `database/002_poc_s2_search_screening_risk.sql`;
- `docs/architecture/31-poc-s2-validacao.md`.

### Política de migrações

- `poc-s1.sql` passa a funcionar como baseline experimental;
- extensões posteriores devem preferir migrações incrementais;
- adotado padrão expand–migrate–contract;
- migrações técnicas não podem alterar significado científico silenciosamente;
- projection rebuild é separado de migration canônica;
- migration ledger permanece requisito antes de ambiente persistente.

### PoC-S2

- adicionados Search, SearchHit, DedupCluster e ScreeningDecision;
- adicionados RiskAssessment, RiskAssessmentVersion e RiskAssessmentDomain;
- Screening target limitado a Report/Study;
- Risk target limitado a Study/Result/Report;
- exclusão em screening exige motivo;
- SearchHit permanece preservado após deduplicação.

### Validação estática

- 7 novas tabelas;
- 17 REFERENCES;
- 3 triggers;
- 2 funções PL/pgSQL;
- zero referências ausentes considerando baseline + migration;
- transação, parênteses e dollar tags balanceados.

### Gate F2-B

- plano ampliado de T01–T14 para **T01–T19**;
- próxima etapa prioritária: execução real em PostgreSQL descartável;
- expansões relevantes adicionais do schema ficam suspensas até essa execução.



## 2026-10-04 — GATE F2-B: execução física integral

### Adicionado

- `database/003_poc_s3_provenance_guard.sql`;
- `database/f2b-fixtures.sql`;
- `database/f2b-tests.sql`;
- `database/f2b-rebuild-check.sql`;
- `docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md`;
- `docs/architecture/32-resultado-gate-f2b.md`.

### Execução

- GitHub Actions run **37187885839**;
- commit testado `de168908d8fe311e64c07937dc70df36af39d910`;
- PostgreSQL **18.6**;
- 39 tabelas e 5 views confirmadas;
- **T01–T19 PASS**;
- rebuild do zero aprovado;
- reaplicação acidental de migration detectada;
- artifact **11297272424**;
- artifact digest `sha256:5381605d34064f95a2d4444e34d275b8c89ceb28a19cc915db104da9362c1d7c`.

### Hardening adicional

- mutations materiais de `provenance.record` passaram a ser bloqueadas;
- correções de provenance são history-preserving por supersessão;
- harness T09 foi corrigido para evitar colisão artificial de `version_no`;
- bloqueio de CI causado por concurrency foi removido para permitir a execução final independente.

### Gate

> **GATE F2-B — PASS**

### Decisão arquitetural

- OES-P1 é mantido como **candidato físico validado no escopo do F2-B**;
- PostgreSQL permanece referência validada de PoC, não stack definitiva;
- não ocorre promoção automática para schema final;
- próxima etapa: **Revisão de Promoção Arquitetural Pós-F2-B** frente aos 15 critérios do Documento 25.


## 2026-10-04 — Revisão de promoção arquitetural pós-F2-B

### Adicionado

- `docs/architecture/33-revisao-promocao-pos-f2b.md`.

### Avaliação dos 15 critérios do Documento 25

- **7 VALIDADO**;
- **5 PARCIALMENTE VALIDADO**;
- **3 NÃO VALIDADO**;
- **0 FORA DO ESCOPO IMEDIATO**.

### Decisão

- OES-P1 **não é promovido** a schema definitivo;
- OES-P1 permanece candidato físico validado;
- OES-H1 permanece arquitetura candidata preferencial;
- PostgreSQL permanece referência de implementação validada para PoC;
- requisitos de produção são mantidos separados dos critérios de adequação arquitetural.

### Plano mínimo restante

- **PoC-S4:** multiplicidade Study/Report, síntese multiestudo e retração/impact analysis;
- **PoC-S5:** NMA, predição e qualitativa/CERQual.

### Próxima etapa

- PoC-S4, limitada aos critérios 4, 5, 7, 14 e 15.


## 2026-10-04 — PoC-S4: multiplicidade, síntese multiestudo e retração

### Adicionado

- `docs/architecture/34-plano-poc-s4.md`;
- `database/004_poc_s4_report_relation_impact.sql`;
- `database/s4-fixtures.sql`;
- `database/s4-tests.sql`;
- `database/s4-rebuild-check.sql`;
- `.github/workflows/validate-s4.yml`;
- `docs/architecture/35-resultado-poc-s4.md`.

### Execução

- GitHub Actions run **37188934837**;
- PostgreSQL **18.6**;
- **S4-T01–T15 PASS**;
- rebuild do zero aprovado;
- artifact **11298153474**;
- digest `sha256:c37a2a57bc6b039461324576b06aa4c88f401773ca83dddfa5f9d3cae583cab5`.

### Critérios promovidos

- 4 — Study com múltiplos Reports: VALIDADO;
- 5 — Report com múltiplos Studies: VALIDADO;
- 7 — síntese quantitativa: VALIDADO;
- 14 — retração e impact analysis: VALIDADO.

### Matriz atual

- 11 VALIDADO;
- 1 PARCIALMENTE VALIDADO;
- 3 NÃO VALIDADO.

### Próxima etapa

- PoC-S5 — NMA, PredictionModel e Qualitativa/CERQual.


## 2026-10-04 — PoC-S5 e fechamento da Fase 2

### Adicionado

- `docs/architecture/36-plano-poc-s5.md`;
- `database/005_poc_s5_specialized_methods.sql`;
- `database/s5-fixtures.sql`;
- `database/s5-tests.sql`;
- `database/s5-rebuild-check.sql`;
- `.github/workflows/validate-s5.yml`;
- `docs/architecture/37-resultado-poc-s5.md`;
- `docs/architecture/38-decisao-promocao-fechamento-fase2.md`.

### Execução

- GitHub Actions run **37189646452**;
- PostgreSQL **18.6**;
- regressão F2-B: PASS;
- regressão S4: PASS;
- **S5-T01–T17 PASS**;
- rebuild do zero: PASS;
- artifact **11297653844**;
- digest `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`.

### Critérios promovidos

- 8 — NMA: VALIDADO;
- 9 — predição: VALIDADO;
- 10 — qualitativa/CERQual: VALIDADO;
- 15 — lineage completo: VALIDADO.

### Matriz final

- **15 VALIDADO**;
- **0 PARCIALMENTE VALIDADO**;
- **0 NÃO VALIDADO**.

### Decisão

- OES-P1 promovido a **baseline arquitetural da Fase 2**;
- OES-H1 preservado como arquitetura de referência;
- PostgreSQL permanece implementação de referência validada, não stack definitiva de produção;
- **Fase 2 encerrada no nível de baseline arquitetural**;
- transição autorizada para **Fase 3 — Produtos do Observatório**.


## 2026-10-04 — Fase 3: taxonomia e arquitetura dos produtos

### Adicionado

- `docs/products/40-taxonomia-arquitetura-produtos.md`.

### Decisões estruturais

- taxonomia inicial com nove produtos;
- Evidence Scan, Resposta, Ficha, Síntese Rápida e Revisão vinculados a N0–N4;
- Mapa e Overview como produtos analíticos transversais;
- Monitor e Alerta como produtos de manutenção, sem criação de N5;
- Ficha de Evidência definida como unidade persistente central preferencial para perguntas focais reutilizáveis;
- separação entre estado editorial, atualidade da evidência e estado científico;
- data de corte obrigatória para produtos com conclusão científica;
- certainty não será simulada quando não formalmente avaliada;
- ausência de evidência permanece distinta de certeza muito baixa;
- evidência, interpretação, aplicabilidade e eventual recomendação permanecem separadas;
- alterações materiais geram ProductVersion sem sobrescrita histórica;
- templates individuais serão criados somente após a especificação do produto.

### Próxima etapa

- especificação individual da **Ficha de Evidência**.


## 2026-10-04 — Fase 3: especificação da Ficha de Evidência

### Adicionado

- `docs/products/41-especificacao-ficha-evidencia.md`.

### Decisões consolidadas

- Ficha de Evidência confirmada como unidade persistente central preferencial para perguntas focais reutilizáveis;
- Ficha permanece `Product subtype`, sem duplicar entidades científicas;
- uma Investigation principal é obrigatória;
- Syntheses e Certainty Assessments utilizados devem ser vinculados por versão concreta;
- certainty não será agregada artificialmente no nível global da Ficha;
- conclusão deverá ser calibrada à magnitude, incerteza e certainty;
- segurança/danos permanecem separados quando aplicáveis;
- aplicabilidade permanece descritiva até formalização metodológica própria;
- Ficha não produz recomendação normativa;
- publicação exige gate científico mínimo;
- versão publicada não é sobrescrita silenciosamente.

### Lacunas físicas identificadas

- estado de atualidade separado do estado editorial;
- múltiplas classes de mudança por ProductVersion;
- relações explícitas Product → Product;
- ApplicabilityAssessment ainda não operacionalizado;
- registro específico do gate de revisão/publicação.

### Próxima etapa

Definir o **Contrato de Dados da Ficha de Evidência** e decidir quais lacunas exigem migration antes do template operacional.


## 2026-10-04 — Fase 3: contrato de dados e gate físico da Ficha

### Adicionado

- `docs/products/42-contrato-dados-ficha-evidencia.md`;
- `database/006_product_evidence_sheet_contract.sql`;
- `database/f3-evidence-sheet-fixtures.sql`;
- `database/f3-evidence-sheet-tests.sql`;
- `database/f3-evidence-sheet-rebuild-check.sql`;
- `docs/products/43-resultado-validacao-contrato-ficha.md`.

### Validação

- run **37191456703**;
- PostgreSQL **18.6**;
- F3-FE-T01–T17 PASS;
- regressões F2-B/S4/S5 PASS;
- rebuild PASS;
- artifact **11299032774**;
- digest `sha256:2e3508b0d876e13e2f6efb367da8e8b308c943560e3d5e978fa293a8a4f851c1`.

### Decisões

- atualidade possui histórico próprio;
- classes de mudança são múltiplas;
- revisão humana é auditável;
- publication gate é avaliativo e explícito;
- ProductRelation permanece adiada;
- ApplicabilityAssessment formal permanece adiado;
- próxima etapa: EvidenceSheetView.


## 2026-10-04 — Fase 3: EvidenceSheetView

### Adicionado

- `docs/products/44-evidence-sheet-view.md`;
- `database/007_evidence_sheet_view.sql`;
- `database/f3-evidence-sheet-view-tests.sql`;
- `database/f3-evidence-sheet-view-rebuild-check.sql`;
- `docs/products/45-resultado-validacao-evidence-sheet-view.md`.

### Validação

- run **37191973078**;
- PostgreSQL **18.6**;
- F3-VIEW-T01–T16 PASS;
- regressões F2-B/S4/S5/Ficha PASS;
- rebuild PASS;
- artifact **11298729618**;
- digest `sha256:d3e53b35bccf3a89e5ee8621ff2d3fc5501d56b56e4a22b5aa8993e9897cbef9`.

### Decisões

- EvidenceSheetView é projeção JSONB derivada, não fonte canônica;
- schema de renderização inicial: `oes.evidence_sheet_view/0.1`;
- a função respeita versões concretas vinculadas ao ProductVersion;
- não recalcula ciência, certainty, Risk of Bias ou recomendação;
- referências são derivadas de ResultSource;
- projeção é determinística;
- migration 007 é idempotente por desenho;
- próxima etapa: especificação do template operacional da Ficha.


## 2026-10-04 — Fase 3: Template Operacional da Ficha de Evidência

### Adicionado

- `docs/products/46-especificacao-template-ficha-evidencia.md`;
- `templates/evidence-sheet.md`;
- `templates/evidence-sheet-presentation-map.json`;
- `scripts/render_evidence_sheet_reference.py`;
- `scripts/validate_evidence_sheet_render.py`;
- `docs/products/47-resultado-validacao-template-ficha.md`.

### Validação

- run final **37196822297**;
- PostgreSQL **18.6**;
- EvidenceSheetView exportado diretamente do banco;
- render Markdown de referência: PASS;
- F3-TEMPLATE: PASS;
- regressões F2-B/S4/S5/Ficha/View: PASS;
- rebuild até migration 007: PASS;
- artifact **11300953823**;
- digest `sha256:99a1c851678ab5ba005517f793518e13ac708bfea32f756c668135a19b47d09b`.

### Decisões

- template inicial aceito como `oes.evidence_sheet.template/0.1`;
- input científico exclusivo: `oes.evidence_sheet_view/0.1`;
- campos artificiais `display.*` foram removidos;
- traduções de enums foram desacopladas em mapa de apresentação;
- renderer Python é implementação de referência, não escolha de engine de produção;
- o template não calcula nem decide ciência;
- próxima etapa: validação científica ponta a ponta da Ficha com caso real.


## 2026-10-04 — Fase 3: início da validação científica com caso real

### Adicionado

- `docs/products/48-caso-real-01-dcbti-protocolo-n2.md`.

### Caso selecionado

Pergunta N2 focal sobre dCBT-I totalmente automatizada em adultos com insônia, comparada a educação digital sobre sono/higiene do sono, com gravidade da insônia pós-tratamento como desfecho principal.

### Decisões

- primeiro caso real deve validar a cadeia científica completa da Ficha;
- desenho principal: RCTs;
- sínteses recentes poderão ser adotadas criticamente quando aderentes;
- comparador será aplicado principalmente na elegibilidade para preservar sensibilidade da busca;
- data de corte: 4 de outubro de 2026;
- próxima etapa: execução formal da busca N2 e início da triagem.


## 2026-10-04 — Caso Real 01: appraisal, síntese e reconciliação arquitetural

### Adicionado

- Documentos 49–57 do Caso Real 01;
- `database/008_evidence_sheet_provenance_references.sql`;
- `database/009_evidence_sheet_view_evidence_counts.sql`;
- `database/f3-provenance-reference-tests.sql`;
- `database/f3-provenance-reference-rebuild-check.sql`.

### Científico

- Hwang 2025 selecionada como síntese-base comparador-específica;
- ROBIS global OES: unclear risk of bias;
- quatro RCTs decisivos avaliados por RoB 2: algumas preocupações;
- atualização N2 mantém direção favorável, com magnitude variável;
- nova meta-análise OES não executada;
- GRADE provisório do desfecho principal: moderada;
- publicação bloqueada até revisão humana.

### Arquitetural

- síntese externa adotada separada da atualização narrativa OES;
- referências da Ficha passam a ser provenance-aware;
- EvidenceSheetView expõe contagens por `study_type`;
- conflito de duas migrations 008 e dois Documentos 55 foi reconciliado;
- sequência canônica passa a 007 → 008 provenance → 009 counts.

### Validação

- run **37212250256**: PASS;
- F3-PROV-T01–T06 PASS;
- F3-VIEW-T17 PASS;
- F3-TEMPLATE PASS;
- rebuild até migration 009 PASS;
- artifact **11306779147**;
- digest `sha256:c0347d27ab8e42ca2e4eaf79db33c1bc234e831d31f53e79cd1f5d44a3ed0aca`.


## 2026-10-04 — Caso Real 01: validação ponta a ponta em pré-publicação

### Adicionado

- `database/f3-real-case-01-dcbti.sql`;
- `database/f3-real-case-01-tests.sql`;
- `database/f3-real-case-01-rebuild-check.sql`;
- `docs/products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md`.

### Resultado

- run **37213165321**: PASS;
- RC01-T01–T10 PASS;
- preview Markdown real: PASS;
- GRADE provisório moderado preservado;
- Syntheses source/primary/corroborative preservadas;
- meta-análise externa explicitamente não recalculada pelo OES;
- publication gate corretamente bloqueado;
- `MISSING_APPROVED_REVIEW` preservado;
- ausência de publication_date preservada;
- nenhum review humano aprovado foi fabricado;
- rebuild through migration 009: PASS;
- artifact **11307386757**;
- digest `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`.

### Próxima etapa

Gate de Revisão Humana do Caso Real 01.


## 2026-10-04 — Caso Real 01: materialização end-to-end e pacote de revisão humana

### Adicionado

- `database/f3-real-case-01-dcbti.sql`;
- `database/f3-real-case-01-tests.sql`;
- `database/f3-real-case-01-rebuild-check.sql`;
- `docs/products/59-caso-real-01-pacote-revisao-humana.md`.

### Validação

- GitHub Actions run **37213165321**;
- PostgreSQL **18.6**;
- RC01-T01–T10 PASS;
- preview real `under_review`: PASS;
- publication gate bloqueado por ausência de revisão humana e publication_date: PASS;
- F2-B/S4/S5/F3-FE/F3-VIEW/F3-PROV/F3-TEMPLATE: PASS;
- rebuild through migration 009: PASS;
- artifact **11307386757**;
- digest `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`.

### Decisões

- o Caso Real 01 pode ser representado sem nova migration;
- meta-análise externa adotada permanece explicitamente não recalculada pelo OES;
- atualização OES permanece narrativa e não pooled;
- GRADE permanece provisório/moderado;
- Ficha permanece `under_review`;
- publication gate deve continuar bloqueado até revisão humana real;
- pacote de revisão humana preparado no Documento 59.


## 2026-10-04 — Caso Real 01: validação técnica do Gate de Revisão Humana

### Adicionado

- `docs/products/60-caso-real-01-validacao-tecnica-gate-revisao-humana.md`;
- `database/f3-human-review-gate-tests.sql`.

### Validação

- GitHub Actions run **37213717492**: PASS;
- HRG-T01–T06: PASS;
- RC01-T01–T10: PASS;
- F3-FE/F3-VIEW/F3-PROV/F3-TEMPLATE: PASS;
- rebuild through migration 009: PASS;
- artifact **11306934256**;
- digest `sha256:81578896ae97f582bd3029c4f276303e0208067b0cdcf053b0bb46f764b3a51f`.

### Semântica validada

- `revise` não satisfaz a exigência de aprovação;
- `rejected` cria bloqueio explícito;
- aprovação concorrente não supera rejeição ativa;
- `approved` sem `publication_date` permanece não publicável;
- somente após resolução dos bloqueios e preenchimento dos demais requisitos o gate pode retornar `publishable=true`;
- todos os review records sintéticos foram executados em transação com `ROLLBACK`.

### Estado real

- nenhuma revisão humana real foi registrada;
- a Ficha continua `under_review`;
- `publishable=false`;
- próxima dependência: revisão humana real usando o Documento 59.


## 2026-10-04 — Modelo de garantia A0–A3 e avanço do Caso Real 01 para A1

### Governança

- criado `docs/governance/04-governanca-garantia-revisao.md`;
- separadas três funções:
  - AI methodological verification;
  - owner governance approval;
  - expert independent review;
- definido assurance derivado A0–A3;
- N2 padrão pode publicar em A2 com disclosure explícito de ausência de expert review;
- N3/N4 preservam requisitos de expertise qualificada.

### Arquitetura

- migration 010: `product.assurance_record` e publication gate A2/A3;
- migration 011: EvidenceSheetView consciente de assurance;
- template da Ficha evoluído para `oes.evidence_sheet.template/0.2`;
- adicionados `templates/ai-methodological-verification.md` e `templates/owner-governance-approval.md`.

### Validação do modelo

Documento 62:

- run **37225407890**: PASS;
- AG-T01–T07: PASS;
- AV-T01–T02: PASS na baseline de validação;
- rebuild through migration 011: PASS.

### Caso Real 01

- Documento 63: primeira verificação adversarial = **REVISE**;
- corrigida premissa incorreta de que Somzz havia sido incluído no pooling Hwang apenas por constar nas referências;
- ROBIS Domain 2 corrigido;
- Somzz tratado como estudo de atualização pós-cutoff;
- Documentos/dataset dependentes corrigidos;
- Documento 64: segunda verificação adversarial = **PASSED**;
- assurance record histórico REVISE preservado como superseded;
- assurance record PASSED ativo;
- Caso Real 01 avançou para **A1**.

### Evidência de execução A1

- run **37226199396**: PASS;
- RC01-T01–T10: PASS;
- AG-T01–T07: PASS;
- AV-T01–T02: PASS;
- F3-TEMPLATE: PASS;
- rebuild through migration 011: PASS;
- artifact **11311923205**;
- digest `sha256:4450a1eb9cd4e46012b8fecf55fa132a7b13e80af0472a10eaf8d859d12aeeb6`.

### Próxima etapa

Documento 65 registra o PASS do estado A1. Documento 66 foi preparado para a decisão explícita de governança do proprietário. Nenhuma owner approval foi inferida de mensagens anteriores.

## 2026-10-04 — Caso Real 01: aprovação do proprietário, A2 e publicação

### Decisão de governança

- Documento 66: decisão explícita do proprietário = **APPROVED**;
- owner approval registrado separadamente de qualquer julgamento metodológico especializado;
- ausência de expert independent review preservada;
- A2 não é apresentado como A3.

### Materialização

- `owner_governance_approval = approved`;
- assurance derivado: **A2**;
- `publication_date = 2026-10-04`;
- estado editorial: `published`;
- `publishable=true`;
- `NO_EXPERT_INDEPENDENT_REVIEW` permanece como warning explícito.

### Auditoria da validação

- run **37228886260**: FAIL por asserção antiga de renderização ainda vinculada a preview bloqueado;
- run **37228948598**: FAIL por asserção antiga de rebuild ainda vinculada a A1;
- as duas inconsistências de teste foram corrigidas sem relaxamento do publication gate;
- run final **37229070210**: **PASS**.

### Evidência final

- commit validado `9c0257172ad916a13cbb66648bb68621c8b21b1f`;
- regressões F2-B/S4/S5: PASS;
- F3 Evidence Sheet / provenance / template: PASS;
- RC01-T01–T10: PASS;
- AG-T01–T07: PASS;
- AV-T01–T02: PASS;
- idempotência e rebuild through migration 011: PASS;
- artifact **11313491459**;
- digest `sha256:81529675c16d85fe28991f7abe3b9594bdc1e99cbcbc3226cb8e3dc0f3b3c1a6`.

### Documento de fechamento

- `docs/products/67-caso-real-01-resultado-validacao-a2-publicacao.md`.

### Próxima etapa

- iniciar a especificação científica e funcional da **Resposta de Evidência — N1**, conforme ordem recomendada no Documento 40.

## 2026-10-05 — Resposta de Evidência N1: contrato e validação técnica

### Documentação

- Documento 68: especificação científica e funcional da Resposta de Evidência N1;
- Documento 69: revisão de coerência e decisão arquitetural inicial;
- Documento 70: contrato de dados N1;
- Documento 71: resultado da validação técnica = **PASS**.

### Arquitetura

- Resposta de Evidência modelada como Product subtype sobre OES-P1;
- nenhuma nova tabela ou coluna necessária;
- Synthesis e CertaintyAssessment permanecem condicionais;
- provenance direta ProductVersion → ReportVersion validada para fonte decisiva;
- publication gate N1 específico;
- EvidenceResponseView própria;
- assurance A0–A3 generalizado por função transversal, com wrapper compatível para Evidence Sheet.

### Implementação

- migration `012_evidence_response_contract.sql`;
- fixture `f3-evidence-response-fixtures.sql`;
- testes `f3-evidence-response-tests.sql`;
- rebuild check `f3-evidence-response-rebuild-check.sql`.

### Validação

- run **37356428107**: **PASS**;
- commit validado `a8f9042e41177b670c15c7f0782465e2b6c73bb4`;
- artifact **11364184531**;
- ER-T01–T14: PASS;
- F2-B/S4/S5: PASS;
- trilha F3 Evidence Sheet/N2: PASS;
- Caso Real 01: PASS;
- rebuild through migration 012: PASS.

### Próxima etapa

- formalizar o contrato de renderização **EvidenceResponseView**;
- somente depois criar template operacional N1 e validar com caso real.

## 2026-10-05 — Caso Real N1-01: A2 e publicação

### Decisão de governança

- Documento 84: decisão explícita do proprietário = **APPROVED**;
- `owner_governance_approval = approved`;
- owner approval permanece distinto de expert independent review;
- ausência de expert review preservada;
- A2 não é apresentado como A3.

### Materialização

- Product `OES-P-2026-000501`;
- ProductVersion corrente = 2;
- AI methodological verification = `passed`;
- owner governance approval = `approved`;
- `publication_date = 2026-10-05`;
- estado editorial = `published`;
- assurance = **A2**;
- `publishable=true`;
- `NO_EXPERT_INDEPENDENT_REVIEW` permanece warning explícito.

### Histórico metodológico preservado

- primeira verificação adversarial = **REVISE**;
- ProductVersion 1 preservada como `superseded`;
- ProductVersion 2 criada com correções materiais;
- segunda verificação adversarial = **PASSED**;
- certainty formal OES não foi criada;
- Synthesis permaneceu opcional em N1.

### Validação final

- run **37362554094**: **PASS**;
- commit validado `c00f4ec6dd7542074bd6c690db01bc752f0ccf6d`;
- artifact **11366543917**;
- digest `sha256:77c6c96c72e6d66a2412ffba999c6c7aa451b835396d3c175a3b850b0516dada`;
- RN1-T01–T12: PASS;
- RN1-R1-T01–T09: PASS;
- RN1-A1-T01–T09: PASS;
- RN1-A2-T01–T09: PASS;
- RN1-TEMPLATE-A2: PASS;
- regressões F2-B/S4/S5/N2: PASS;
- rebuild through migration 012: PASS.

### Documento de fechamento

- `docs/products/85-caso-real-n1-resultado-validacao-a2-publicacao.md`.

### Continuidade

- CP31 criado;
- próxima etapa: especificação científica e funcional do **Evidence Scan — N0**.

## 2026-10-05 — Evidence Scan N0: contrato técnico validado

### Especificação e arquitetura

- Documento 86 — especificação científica e funcional;
- Documento 87 — decisão arquitetural: reutilizar OES-P1;
- Documento 88 — contrato de dados;
- Documento 89 — validação técnica = **PASS**;
- Documento 90 — contrato de renderização.

### Implementação

- migration 013;
- EvidenceScanView `oes.evidence_scan_view/0.1`;
- publication gate N0;
- fixture sintética;
- testes ES-T01–T15.

### Decisões

- nenhuma nova tabela ou coluna;
- N0 permanece exploratório e não exaustivo;
- scan interno pode encerrar em A1;
- scan formal persistente exige A2;
- Synthesis/Certainty/RiskAssessment não são obrigatórios;
- exceção `insufficient` sem Report central é válida somente com Search rastreável;
- provenance permanece append-preserving.

### Validação final

- run **37366556793**, attempt 2: **success**;
- commit validado `a1aa98eec809f25add578ebf15ba6b40739d54ca`;
- artifact **11368729267**;
- digest `sha256:f734fceca49c384cf5671b81919d2991d54b2a167b03a420b2c4f19db42f4a3c`;
- ES-T01–T15 PASS;
- migration 013 idempotente;
- regressões F2-B/S4/S5/N1/N2 PASS;
- rebuild through migration 013 PASS.

### Continuidade

- CP32 criado;
- próxima etapa: template operacional do Evidence Scan N0.

## 2026-10-05 — Evidence Scan N0: caso real A1 e fechamento

### Renderização e template

- Documento 90 — contrato de renderização do EvidenceScanView;
- Documento 91 — especificação do template operacional;
- Documento 92 — validação do template = **PASS**;
- `templates/evidence-scan.md`;
- presentation map, renderer e validator específicos de N0;
- estados A2 formal, A1 interno e `search_only_insufficient` validados.

### Caso Real N0-01

Tema: chatbots GenAI/LLM para apoio à saúde mental.

- Documento 93 — protocolo;
- Documento 94 — busca exploratória e seleção;
- Documento 95 — síntese exploratória, maturity e routing;
- Documento 96 — validação A0 = **PASS**;
- Documento 97 — verificação metodológica adversarial = **PASSED**;
- Documento 98 — validação A1 e fechamento operacional = **PASS**.

Estado final:

- Product `OES-P-2026-000601`;
- assurance **A1**;
- `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- owner governance approval não realizada;
- expert independent review não realizada;
- maturity `partially_synthesized`;
- routing `N2`;
- reformulação da pergunta requerida;
- encerrado deliberadamente como artefato interno de roteamento.

### Validação final

- run **37382201584** = **success**;
- commit validado `eb503c571557b5b7078b6f148e9ca9c0651da2a4`;
- artifact **11374937122**;
- digest `sha256:be56277103192065dedf555423191d3d2f8fca149f7f568a6c8f54c0b67b8b18`;
- RN0-T01–T13 PASS;
- RN0-A1-T01–T08 PASS;
- RN0-TEMPLATE-A0/A1 PASS;
- regressões e rebuild PASS.

### Continuidade

- CP33 criado;
- próxima etapa: **Síntese Rápida de Evidências — N3**.

## 2026-10-05 — Síntese Rápida N3: contrato técnico validado

### Metodologia

- Documento 99 — especificação científica e funcional;
- Documento 100 — decisão arquitetural;
- Documento 101 — contrato de dados;
- Documento 102 — validação técnica = **PASS**.

### Arquitetura

- migration 014;
- `investigation.method_decision`;
- `investigation.quality_control_record`;
- RapidEvidenceSynthesisView `oes.rapid_evidence_synthesis_view/0.1`;
- publication gate N3.

### Governança

- N3 formal exige A3;
- A3 não substitui controles qualificados de etapa;
- IA não satisfaz human-qualified secondary verification;
- fixture A2 completa permanece não publicável;
- RS-T11 prova abertura do gate somente com qualified human controls + A3.

### Validação

- run **37384225722** = **success**;
- commit `44d50afa11d385ef26f56f860676859fb40d4f3c`;
- artifact **11375884187**;
- digest `sha256:1d880f2490142ba5fb4c0a815741a7aee01f74bb06b0b969fb352d6883443e78`;
- RS-T01–T15 PASS;
- F3-RS-T16 PASS;
- rebuild through migration 014 PASS;
- regressões N0/N1/N2/F2-B/S4/S5 PASS.

### Continuidade

- CP34 criado;
- próxima etapa: contrato de renderização N3.

## 2026-10-05 — Síntese Rápida N3: renderização/template validados

### Documentos

- Documento 103 — contrato de renderização;
- Documento 104 — especificação do template operacional;
- Documento 105 — resultado da validação do template = **PASS**.

### Artefatos

- `templates/rapid-evidence-synthesis.md`;
- `templates/rapid-evidence-synthesis-presentation-map.json`;
- `scripts/render_rapid_evidence_synthesis_reference.py`;
- `scripts/validate_rapid_evidence_synthesis_render.py`.

### Validação

- run **37384841089** = **success**;
- commit validado `da3a4a3d8d18d9ac951ab028fc4249d95e898989`;
- artifact **11378245039**;
- digest `sha256:b94c8b1d4a2428233c01ba7ea40d4b7e720fb1a7e5dc76863a406d2e9959247c`;
- F3-RS-TEMPLATE PASS;
- RS-T01–T15 PASS;
- N3 qualified-human-control gate PASS;
- rebuild through migration 014 PASS;
- regressões N0–N2/F2-B/S4/S5 PASS.

### Limite operacional

- publicação formal N3 continua proibida sem qualified human controls reais + A3;
- A3 simulado no validator é somente teste visual em memória;
- nenhum A3 falso foi persistido.

### Continuidade

- CP35 criado;
- próxima etapa: **Caso Real N3 experimental**.

## 2026-10-06 — Caso Real N3-01: encerramento experimental em A0

### Caso real

Tema: ambient AI scribes e carga de documentação clínica.

Documentos:

- 106 — protocolo;
- 107 — busca/seleção inicial;
- 108 — appraisal;
- 109 — síntese narrativa, GRADE experimental e SoF;
- 110 — validação técnica A0;
- 111 — primeira verificação adversarial = **REVISE**;
- 112 — busca suplementar corretiva;
- 113 — segunda verificação adversarial = **REVISE**;
- 114 — encerramento experimental controlado.

### ProductVersion 1

- A0 / under_review / non-publishable;
- RN3-T01–T16 PASS;
- primeira adversarial review = REVISE por coverage insuficiente.

### ProductVersion 2

- correção de search coverage;
- 3 Search records;
- 20 hits materializados;
- 34 screening decisions;
- 13 referências;
- conjunto causal, appraisals, syntheses e GRADE preservados;
- segunda adversarial review = REVISE.

### Bloqueio metodológico

- Documento 99 exige busca sistemática, reproduzível, documentada e proporcionalmente abrangente;
- padrão inicial N3 = pelo menos duas bases bibliográficas relevantes, salvo exceção defensável;
- PubMed foi executável;
- Europe PMC e OpenAlex direto não foram executáveis no runtime;
- buscas suplementares não equivaleram a segunda base;
- novos estudos elegíveis continuaram sendo localizados após a correção;
- ProductVersion 2 permanece **A0**;
- não criar ProductVersion 3 sem segunda base bibliográfica reproduzível.

### Validação final

- run **37413884319** = **success**;
- commit validado `f2ba21eaaa2d3c43a95ceb908dd0b097b8e9a1b4`;
- artifact **11389784878**;
- digest `sha256:c4b53864e60be656a1e3de9039b8480746bbeff8f9fcf5b76257989a47a73b58`;
- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- rebuild through migration 014 PASS;
- regressões N0–N2/F2-B/S4/S5 PASS.

### Continuidade

- CP36 criado;
- próxima etapa: **Revisão de Evidências — N4**.

## 2026-10-06 — Revisão de Evidências N4: contrato técnico validado

### Documentos

- Documento 115 — Especificação Científica e Funcional;
- Documento 116 — Revisão de Coerência e Decisão Arquitetural;
- Documento 117 — Contrato de Dados;
- Documento 118 — Resultado da Validação Técnica = **PASS**.

### Arquitetura

- migration 015;
- nova tabela `investigation.reviewer_assignment`;
- extensão de `appraisal.assert_risk_target_type()` para aceitar `Synthesis` em appraisal ROB-ME;
- EvidenceReviewView `oes.evidence_review_view/0.1`;
- publication gate N4;
- Infrastructure Readiness Gate.

### Governança

- N4 formal exige A3 e controles humanos qualificados específicos do protocolo;
- A3 não substitui stage controls;
- IA não pode satisfazer reviewer assignment humano;
- uma única base bibliográfica não é suficiente para N4 formal;
- protocolo prospectivo obrigatório;
- search peer review, dupla seleção, dupla extração, dupla appraisal e dupla certainty são verificáveis pelo contrato;
- meta-analysis exige code/dataset + statistical review;
- Caso Real N4 formal permanece bloqueado na configuração atual do OES.

### Validação

- fixture formal sintética A3;
- ER4-T01–T25 PASS;
- rebuild through migration 015 PASS;
- regressões F2-B/S4/S5/N0/N1/N2/N3 PASS;
- run **37417796591** = **success**;
- commit validado `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`;
- artifact **11391167525**;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

### Continuidade

- CP37 criado;
- próxima etapa: **contrato de renderização e template operacional da Revisão de Evidências N4**.

## 2026-10-06 — Revisão de Evidências N4: template/renderização validados

### Documentos

- Documento 119 — Contrato de Renderização da EvidenceReviewView;
- Documento 120 — Especificação do Template Operacional;
- Documento 121 — Resultado da Validação do Template/Renderização = **PASS**.

### Apresentação

- template `templates/evidence-review.md`;
- presentation map próprio;
- renderer neutro;
- validator positivo + cenário adversarial;
- `audit.synthetic_fixture` explícito;
- banner obrigatório de fixture sintética;
- readiness, ReviewerAssignments e stage controls visíveis;
- ROB-ME, reprodutibilidade e assurance visíveis.

### Invariante validada

- A3 não implica publication approval;
- cenário adversarial mantém A3 e `publishable=false`;
- render mostra gate N4 bloqueado e publication issue ativa;
- nenhum controle ausente é ocultado por assurance.

### Validação

- run **37418624629** = **success**;
- commit validado `4bd35271e94dfb05bf572fe76b49fa5c5af47bac`;
- artifact **11391724857**;
- digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`;
- F3-ER4-TEMPLATE PASS;
- ER4-T01–T27 PASS;
- rebuild through migration 015 PASS;
- regressões N0–N3/F2-B/S4/S5 PASS.

### Continuidade

- CP38 criado;
- próxima etapa: **Caso Real N4 experimental — executar exclusivamente o Infrastructure Readiness Gate**;
- não iniciar busca N4 real se readiness for `not_ready`.

## 2026-10-06 — N4 Infrastructure Readiness Gate = NOT_READY

### Documento

- Documento 122 — Infrastructure Readiness Gate pré-caso real.

### Resultado

- cobertura bibliográfica = `not_ready`;
- equipe metodológica = `not_ready`;
- estatística = `ready_with_documented_conditions`;
- ferramentas/artefatos = `ready`;
- governança/A3 = `not_ready`;
- resultado agregado = **NOT_READY**.

### Decisão

- nenhum Caso Real N4 formal foi aberto;
- nenhuma busca definitiva N4 foi iniciada;
- IA não será usada para preencher papéis humanos ausentes;
- requisitos N4 não serão reduzidos para contornar limitações de infraestrutura;
- N4 permanece tecnicamente validado e operacionalmente deferido.

### Continuidade

- CP39 criado;
- próxima etapa: **especificação científica e funcional do Mapa de Evidências**.



## 2026-10-06 — CP40: contrato do Mapa consolidado

### Continuidade

- Freshness Gate entre o commit de criação do CP39 (`2ea0b53455bfc7bd10ce78a223436e19b04b4437`) e o HEAD pré-CP40 (`284f08c710847891785e740b9a1edb2fa6cc1143`) confirmou **7 commits à frente e 0 atrás**;
- Documentos 123–125 reconhecidos como avanço canônico pós-CP39;
- CP40 criado para eliminar a defasagem entre o checkpoint formal e o estado real do repositório.

### Mapa de Evidências

- Documento 123 — especificação científica e funcional;
- Documento 124 — revisão de coerência e decisão arquitetural inicial;
- Documento 125 — contrato de dados v0.1;
- schema especializado `mapping` definido com 7 estruturas;
- células, contagens, gaps e concentrações permanecem derivados;
- `database/016_evidence_map_contract.sql` autorizada;
- template/renderização proibidos até PASS técnico do contrato.

### Próxima etapa

- migration 016;
- fixture formal sintética;
- testes adversariais;
- rebuild/regressões;
- integração S5;
- PASS técnico;
- somente então contrato de renderização/template do Mapa.


## 2026-10-06 — Evidence Map contract technical PASS

### Implementação

- adicionada migration `database/016_evidence_map_contract.sql`;
- criado schema `mapping` com sete estruturas especializadas;
- implementada derivação de células, contagens e gaps;
- implementados publication gate e `EvidenceMapView`;
- adicionada fixture formal sintética e testes positivos/adversariais;
- integrada migration 016 ao S5 e ao rebuild do zero.

### Validação

- EM-T01–T22 PASS;
- migration 016 duplicate detection PASS;
- rebuild through migration 016 PASS;
- regressões N0–N4 PASS;
- workflow run **37464023391** = success;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`;
- artifact **11413512318**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

### Documento

- criado Documento 126 — Resultado da Validação Técnica do Contrato do Mapa de Evidências.

### Próxima etapa

- contrato de renderização do EvidenceMapView;
- nenhum template foi criado antes do PASS técnico.


## 2026-10-06 — CP41

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP41.md`;
- PASS técnico do Mapa de Evidências consolidado;
- ponto de retomada movido para o Documento 127 — contrato de renderização do EvidenceMapView.


## 2026-10-06 — EvidenceMapView rendering contract

- criado Documento 127 — EvidenceMapView: Contrato de Renderização;
- formalizadas regras de apresentação para coverage, gap modes, counting unit, CellScope, drill-down, concentrações, classifications, assurance e publication gate;
- identificado **Projection Readiness Gate = NOT_READY para template**;
- extensões aditivas necessárias: synthetic fixture, conclusão, protocolo/codebook, reviewer/method controls, lineage/invalidation e references via Study–Report linkage;
- decisão: não reabrir migration 016; criar migration aditiva subsequente antes do template.


## 2026-10-06 — CP42

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP42.md`;
- contrato de renderização do Mapa consolidado no Documento 127;
- Projection Readiness Gate registrado como NOT_READY para template;
- retomada definida na migration aditiva da EvidenceMapView 0.1.


## 2026-10-06 — EvidenceMapView projection readiness PASS

- adicionada migration 017 — `017_evidence_map_view_rendering_readiness.sql`;
- criada `product.evidence_map_reference_reports()`;
- EvidenceMapView 0.1 ampliada com synthetic fixture, conclusão, protocolo/codebook, reviewer assignments, method controls, lineage/invalidation e references via Study–Report linkage;
- EMV-T01–T11 PASS;
- run **37466183355** = success;
- artifact **11414726018**;
- digest `sha256:44ee38666b3d502bae5936adb388cdd49660b0f763990eb23b00b2a01bd420c6`;
- rebuild through migration 017 PASS;
- Documento 128 criado;
- Projection Readiness Gate = **READY**.


## 2026-10-06 — CP43

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP43.md`;
- Projection Readiness Gate da EvidenceMapView consolidado como READY;
- retomada movida para a Especificação do Template Operacional do Mapa de Evidências.


## 2026-10-06 — Evidence Map presentation PASS

- criado Documento 129 — Especificação do Template Operacional;
- implementados template Markdown, presentation map, renderer e validator;
- primeiro run 37467276979 falhou apenas por asserção textual do validator sobre Markdown;
- validator corrigido sem alteração científica;
- run final **37467388595** = success;
- artifact **11415721992**;
- digest `sha256:889f31280259bf1f90439957d12652567d0a3542a465c379623d3810840b7afe`;
- formal fixture, A3-blocked e apparent-gap presentation PASS;
- rebuild through migration 017 PASS;
- Documento 130 criado;
- camada de apresentação do Mapa = **PASS**.


## 2026-10-06 — CP44

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP44.md`;
- camada de apresentação do Mapa consolidada como PASS;
- retomada movida para o Readiness Gate pré-Caso Real, separando rota exploratória/non-exhaustive da rota formal systematic map/EGM.


## 2026-10-06 — Evidence Map real-case readiness

- criado Documento 131 — Readiness Gate Pré-Caso Real;
- rota exploratória/structured non-exhaustive = **READY_WITH_DOCUMENTED_CONDITIONS**;
- rota formal systematic map/EGM = **NOT_READY**;
- autorizado MAP-01 interno A1 sobre ambient AI scribes, reutilizando corpus N3-01;
- definido `descriptive_mapping_review + structured_non_exhaustive + apparent_only`;
- proibida alteração da assurance/conclusão do N3-01 ou fabricação de controles humanos;
- próxima etapa: protocolo MAP-01.


## 2026-10-06 — CP45

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP45.md`;
- readiness exploratório do Mapa = READY_WITH_DOCUMENTED_CONDITIONS;
- readiness formal systematic map/EGM = NOT_READY;
- MAP-01 autorizado como caso exploratório interno;
- retomada movida para o protocolo MAP-01.


## 2026-10-06 — MAP-01 pre-persistence design

- Documento 132 — protocolo MAP-01;
- Documento 133 — inventário formal: 5 Studies + 8 contextual Reports + 4 Syntheses = 17 MapItems;
- Documento 134 — codebook v0.1;
- 20 células previstas: 18 in_scope, 1 excluded_by_framework, 1 not_applicable;
- decisão arquitetural: reutilizar InvestigationVersion N3-01 como primary Investigation do Mapa;
- Search/Screening do N3 permanecem fontes canônicas e não serão duplicados.


## 2026-10-06 — CP46

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP46.md`;
- MAP-01 pré-especificado por protocolo, inventário e codebook;
- persistência ainda não iniciada no checkpoint;
- retomada na criação controlada do MAP-01.


## 2026-10-06 — STATE taxonomy correction

- corrigida referência residual em `STATE.md` que ainda indicava a camada de apresentação do Mapa como pendente;
- taxonomia atualizada para refletir corretamente que a próxima pendência da trilha do Mapa é concluir o Caso Real MAP-01;
- nenhuma decisão metodológica ou ponto de retomada foi alterado.


## 2026-10-06 — MAP-01 source-corpus architecture correction

- criado Documento 135;
- identificada incompatibilidade semântica em reutilizar diretamente a Investigation N3-01 como primary Investigation do MAP-01;
- decisão do CP46 sobre primary Investigation foi superada;
- MAP-01 terá Question/Investigation próprias;
- N3-01 será ligada como `source_corpus`;
- Search/Screening permanecerão canônicos na N3-01, sem duplicação;
- próxima etapa: migration 018 de suporte à herança de corpus na EvidenceMapView/publication gate.


## 2026-10-06 — CP47

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP47.md`;
- decisão do CP46 sobre primary Investigation do MAP-01 formalmente superada;
- MAP-01 terá Question/Investigation próprias;
- N3-01 será ligada como `source_corpus`;
- retomada definida na migration 018.


## 2026-10-06 — Evidence Map source-corpus PASS

- migration 018 implementada;
- EvidenceMapView passou a suportar `source_corpus` sem duplicação de Search/Screening;
- mapa não sistemático pode herdar Search do corpus fonte;
- systematic/formal map não pode usar `source_corpus` para contornar Search primária;
- EMVSC-T01–T05 PASS;
- run **37479566944** = success;
- artifact **11420063123**;
- digest `sha256:c7dc99be7781200e0ad603b0d03f9e90e3022ed7eafabd32be5138f41c29024b`;
- rebuild through migration 018 PASS;
- Documento 136 criado.


## 2026-10-06 — CP48

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP48.md`;
- suporte a `source_corpus` consolidado como PASS;
- migration 018 + EMVSC-T01–T05 + rebuild validados;
- retomada movida para a persistência real do MAP-01.


## 2026-10-06 — MAP-01 controlled closure

- persistido primeiro Caso Real do Mapa: `OES-P-2026-001401`;
- 17 MapItems, 67 assignments, 20 CellScope e 13 references;
- Question/Investigation próprias + N3-01 como `source_corpus`;
- MAP01-T01–T15 PASS em A0;
- AI methodological second pass = passed;
- assurance final = **A1**;
- nenhuma owner approval, expert review ou human verification fabricada;
- MAP01-A1-T01–T07 PASS;
- template ampliado com seção de investigações-fonte do corpus;
- MAP01-RENDER-A1 PASS;
- run **37487017809** = success;
- artifact **11423951911**;
- digest `sha256:ae81f09905853a395b0bf4ba03e5209938d1cb7e6175390531d117e49f0a46e8`;
- rebuild through migration 018 + MAP-01 A1 PASS;
- Documento 137 criado;
- MAP-01 encerrado como **A1 interno / não publicável**;
- próxima etapa da Fase 3: Overview de Revisões.


## 2026-10-06 — CP49

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP49.md`;
- MAP-01 consolidado como **A1 interno / não publicável**;
- run 37487017809 e rebuild completos em PASS;
- retomada movida para a Especificação Científica e Funcional do Overview de Revisões.


## 2026-10-06 — Overview of Reviews scientific specification

- criado Documento 138 — Especificação Científica e Funcional do Overview de Revisões;
- unidade analítica principal definida como systematic review;
- formal v0.1 limitado a reviews quantitativas de intervenções;
- ROBIS definido como default de risk of bias da review;
- overlap Study-level e política explícita de double counting tornados obrigatórios;
- CCA/pairwise overlap definidos como derivados, não verdades persistidas;
- supplemental primary studies excluídos do corpus analítico formal v0.1;
- formal Overview exige A3 + qualified human controls;
- próxima etapa: revisão de coerência e decisão arquitetural.


## 2026-10-06 — Overview architectural decision

- criado Documento 139 — Revisão de Coerência e Decisão Arquitetural do Overview de Revisões;
- systematic review permanece Study/StudyVersion no OES-P1;
- aprovada camada especializada `overview` com sete estruturas;
- Review×PrimaryStudy membership será verdade persistida de overlap;
- CCA/pairwise overlap/heatmaps serão derivados;
- eligibility e overlap disposition permanecerão separados;
- OutcomeEvidence será link/context, sem copiar Results;
- formal Overview = Investigation N4 + A3 + qualified human controls;
- rejeitadas entidades/tabelas paralelas de Review, Overview, ROBIS, GRADE, Search, Screening e métricas derivadas;
- próxima etapa: contrato de dados v0.1.


## 2026-10-06 — CP50

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP50.md`;
- especificação científica e arquitetura do Overview de Revisões consolidadas;
- nenhuma migration/template do Overview criada antes do contrato;
- retomada movida para o Contrato de Dados v0.1.


## 2026-10-06 — Overview data contract v0.1

- criado Documento 140 — Contrato de Dados v0.1 do Overview de Revisões;
- definidas sete estruturas especializadas no schema `overview`;
- Review × primary Study membership definida como verdade persistida;
- CCA/pairwise overlap mantidos como derivados;
- `include_all_deduplicate_outcomes` bloqueado para publicação formal v0.1;
- publication gate e `OverviewOfReviewsView` especificados;
- OV-T01–T33 definidos;
- template permanece proibido até PASS técnico;
- próxima etapa: migration 019 + fixture/testes.


## 2026-10-06 — CP51

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP51.md`;
- Contrato de Dados v0.1 do Overview consolidado;
- template segue embargado até PASS técnico;
- retomada movida para migration 019 + fixture + OV-T01–T33.


## 2026-10-06 — Continuity editorial cleanup after CP51

- referências históricas em `STATE.md` e `docs/products/README.md` foram qualificadas como marcos já superados, evitando leitura como instrução vigente;
- histórico CP39–CP50 em `archive/handoffs/oes/README.md` teve sequências literais `\n` convertidas em quebras de linha reais;
- nenhuma decisão metodológica, estado técnico ou ponto de retomada foi alterado;
- CP51 continua vigente;
- próxima etapa permanece: migration 019 + fixture formal + OV-T01–T33.


## 2026-10-06 — Overview migration 019 structural validation

- criada `database/019_overview_of_reviews_contract.sql`;
- migration 019 integrada ao baseline/rebuild S5;
- run **37500255586** = success;
- artifact **11429895618**;
- digest `sha256:385e4457936aa3dc435ee8d6b92c21382f4e9b80025cff5404c235c39e8508f6`;
- regressões N0–N4 + Evidence Map + MAP-01 = PASS;
- rebuild through migration 019 = PASS;
- ainda não constitui PASS técnico completo do Overview;
- template continua embargado.

## 2026-10-06 — CP52

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP52.md`;
- migration 019 consolidada como estruturalmente compatível;
- retomada movida para fixture formal + OV-T01–T33.


## 2026-10-06 — Overview technical contract PASS

- Documento 141 criado;
- migration 019 = PASS;
- fixture formal sintética A3 = PASS;
- 3 Reviews, 5 primary Studies e 9 memberships;
- CCA esperado 0,4 = PASS;
- OV-T01–T33 = PASS;
- `OverviewOfReviewsView` = PASS;
- regressões N0–N4 + Evidence Map + MAP-01 = PASS;
- rebuild com migration 019 + fixture = PASS;
- run **37502184404** = success;
- artifact **11430003081**;
- digest `sha256:94759585098f90d0227a3d4435056807c18e72af1e01a558e7a5dad3267afee3`;
- dois erros iniciais da fixture (UUID e rationale omitido) foram corrigidos sem alteração do contrato;
- embargo técnico de template encerrado;
- próxima etapa: contrato de renderização da `OverviewOfReviewsView`.


## 2026-10-06 — CP53

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP53.md`;
- contrato técnico do Overview consolidado em PASS;
- OV-T01–T33 + rebuild/regressões registrados;
- template ainda não criado;
- retomada movida para contrato de renderização e Projection Readiness Gate.


## 2026-10-06 — Overview render contract / Projection NOT_READY

- criado Documento 142 — contrato de renderização da `OverviewOfReviewsView`;
- renderer definido como read-only sobre a View;
- overlap/CCA/pairwise não podem ser recalculados pelo renderer;
- eligibility e overlap disposition devem permanecer distintas;
- ROBIS e certainty permanecem dimensões distintas;
- Projection Readiness Gate = **NOT_READY**;
- lacunas aditivas: method decisions completos, reviewer conflicts, QC payloads, search export metadata, selection/exclusions, Review Report lineage, OutcomeEvidence provenance e dependency/invalidation detail;
- migration 019 permanece fechada e não será reaberta;
- próxima etapa: migration 020 + OVR-T01–T12;
- template permanece proibido até novo gate READY.


## 2026-10-06 — CP54

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP54.md`;
- contrato de renderização do Overview consolidado;
- Projection Readiness = **NOT_READY**;
- migration 019 permanece fechada;
- retomada movida para migration 020 + OVR-T01–T12;
- template permanece proibido.


## 2026-10-06 — Overview projection readiness READY

- migration `020_overview_of_reviews_view_rendering_readiness.sql` implementada de forma aditiva;
- fixture do Overview ampliada com protocol deviation, audit lineage e Result provenance;
- `f3-overview-view-rendering-readiness-tests.sql` criado;
- OVR-T01–T12 = PASS;
- migration 020 idempotent reapply = PASS;
- rebuild through migration 020 = PASS;
- regressões N0–N4 + Evidence Map + MAP-01 + Overview technical contract = PASS;
- run **37503751486** = success;
- artifact **11430083884**;
- digest `sha256:f599426adb3afd5cc28066c00eb0de73c6d18dd734f622d58e9f0f5f9be418a5`;
- Documento 143 criado;
- Projection Readiness alterado de **NOT_READY** para **READY para especificação do template operacional**;
- migration 019 permanece fechada;
- próxima etapa: especificação formal do Template Operacional do Overview.


## 2026-10-06 — CP55

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP55.md`;
- Projection Readiness do Overview consolidado em **READY**;
- migration 020 + OVR-T01–T12 + rebuild/regressões registrados;
- próxima etapa movida para especificação formal do Template Operacional;
- nenhum template/renderer/validator criado antes desse marco.


## 2026-10-06 — Overview operational template specification

- criado Documento 144 — Especificação do Template Operacional do Overview de Revisões;
- ordem canônica de apresentação definida;
- renderer permanece read-only sobre `OverviewOfReviewsView`;
- Review ≠ Report e eligibility ≠ overlap disposition preservados;
- CCA/pairwise não serão recalculados;
- ROBIS, certainty e currentness permanecem dimensões separadas;
- global Overview certainty e indirect comparison informal permanecem proibidos;
- presentation map, renderer e validator especificados;
- cenários adversariais definidos;
- próxima etapa: implementação da camada de apresentação e integração S5.


## 2026-10-06 — CP56

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP56.md`;
- especificação do Template Operacional do Overview consolidada;
- implementação ainda não iniciada no checkpoint;
- retomada movida para template + presentation map + renderer + validator + integração S5.


## 2026-10-06 — Overview presentation layer PASS

- Documento 145 criado;
- `templates/overview-of-reviews.md` implementado;
- presentation map implementado;
- renderer read-only implementado;
- validator positivo + cenários adversariais implementado;
- integração S5 concluída;
- `F3-OVERVIEW-TEMPLATE validation PASS`;
- run **37506526884** = success;
- artifact **11431539311**;
- digest `sha256:4ddfff2d14f9b8892611199cdade932f7825d2615f76610518a63499c2a58770`;
- rebuild through migration 020 + Overview fixture = PASS;
- próxima etapa: readiness pré-caso real do Overview;
- Caso Real permanece bloqueado até esse gate.


## 2026-10-06 — CP57

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP57.md`;
- camada de apresentação do Overview v0.1 consolidada em PASS;
- Caso Real permanece bloqueado;
- retomada movida para readiness pré-caso real do Overview.


## 2026-10-06 — Overview pre-real-case readiness gate

- Documento 146 criado;
- infraestrutura técnica do Overview = READY;
- rota developmental interna A0/A1 = READY_WITH_DOCUMENTED_CONDITIONS;
- rota formal publicável A3 = NOT_READY;
- nenhum OVR-01 autorizado ainda;
- N3-01 poderá ser examinado apenas como corpus candidato;
- próxima etapa: qualificação de corpus antes de Product/Investigation real.


## 2026-10-06 — CP58

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP58.md`;
- readiness pré-caso real do Overview consolidado;
- rota developmental = READY_WITH_DOCUMENTED_CONDITIONS;
- rota formal = NOT_READY;
- nenhum OVR-01 aberto;
- retomada movida para qualificação do subconjunto secundário N3-01 como corpus candidato.


## 2026-10-06 — N3-01 corpus candidate rejected for OVR-01

- Documento 147 criado;
- Report 206 confirmado como systematic review elegível em princípio;
- Report 211 confirmado como rapid review e não reclassificado artificialmente;
- Reports 210/220 permanecem scoping/narrative e não elegíveis;
- somente uma systematic review inequivocamente compatível com o contrato v0.1;
- Review Studies, membership, review-level Results/Syntheses, ROBIS e certainty não estão materializados para 206/211;
- decisão do candidato = **UNSUITABLE**;
- nenhum OVR-01 criado;
- N3-01 permanece inalterado;
- próxima etapa: selecionar novo corpus candidato.


## 2026-10-06 — CP59

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP59.md`;
- primeiro corpus candidato OVR-01 encerrado como **UNSUITABLE**;
- nenhum Product/Investigation OVR-01 criado;
- N3-01 permanece inalterado;
- retomada movida para seleção e qualificação de novo corpus candidato.


## 2026-10-06 — dCBT-I corpus suitable with conditions for OVR-01

- Documento 148 criado;
- Hwang 2025 e Gao 2026 confirmadas como duas systematic reviews já materializadas no OES;
- Review-level ResultVersions e Syntheses externas distintas já existem;
- Hwang possui ROBIS AI-assisted draft;
- membership/overlap Hwang × Gao ainda não materializados;
- last-search date de Gao ainda não persistida;
- comparadores não são idênticos e não serão tratados como estimates intercambiáveis;
- corpus classificado **SUITABLE_WITH_CONDITIONS**;
- autorização limitada à preparação do protocolo developmental;
- ReviewItems/membership ainda bloqueados até fechamento das condições pré-persistência.


## 2026-10-06 — CP60

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP60.md`;
- corpus dCBT-I consolidado como **SUITABLE_WITH_CONDITIONS** para OVR-01 developmental;
- autorização limitada à preparação do protocolo;
- ReviewItems/membership permanecem bloqueados até fechamento das condições pré-persistência.


## 2026-10-06 — OVR-01 developmental protocol

- Documento 149 criado;
- pergunta review-level e eligibility definidas;
- discovery pré-persistência estruturado como não exaustivo;
- cutoff inicial = 2026-10-06;
- currentness definida por last-search date;
- overlap strategy inicial = `include_all_separate_estimates`;
- CCA/pairwise somente após membership reconciliada;
- Hwang/Gao permanecem com estimates separados por comparador;
- Nazari deverá ser screened prospectivamente;
- global certainty, indirect comparison e nova meta-analysis permanecem proibidos;
- C1–C12 definidos como condições pré-persistência;
- próxima etapa: fechar C1–C4.


## 2026-10-06 — CP61

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP61.md`;
- protocolo developmental OVR-01 dCBT-I consolidado;
- C1–C12 permanecem condições pré-persistência;
- nenhum Product/Investigation/ReviewItem/membership OVR-01 foi criado;
- retomada movida para fechamento de C1–C4.


## 2026-10-06 — OVR-01 C1–C4 review inventory

- Documento 150 criado;
- C1 — Gao study list = PASS;
- C2 — Gao last-search date = BLOCKED / NOT_VERIFIED;
- C3 — Nazari 2025 = ELIGIBLE;
- C4 — inventário definitivo de Reviews = PASS;
- corpus analítico v1 = Hwang 2025 + Gao 2026 + Nazari 2025;
- Zhong 2026 / older-adult review / Leite 2025 / Zettor 2025 classificados fora do núcleo analítico por scope/outcome;
- nenhum OVR-01 real criado;
- próxima etapa: resolver C2 e iniciar C5–C6 preparatórios sem persistir membership.


## 2026-10-06 — CP62

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP62.md`;
- fechamento C1–C4 consolidado;
- C1 PASS / C2 BLOCKED-NOT_VERIFIED / C3 PASS / C4 PASS;
- nenhum OVR-01 real criado;
- retomada movida para resolução de C2 e preparação C5–C6 sem persistir membership.


## 2026-10-06 — OVR-01 C5–C6 preliminary identity/membership work

- Documento 151 criado — codebook de identidade Study/Report;
- Documento 152 criado — matriz preliminar Review × primary Study;
- unidade de overlap fixada como primary Study/trial;
- GoodNight reconhecido como uma Study com múltiplos Reports;
- Eigl/Hinterberger mantido como probable same Study até confirmação final;
- Lorenz 2018/2019 mantido como probable bibliographic alias;
- overlaps Hwang/Gao/Nazari demonstrados sem calcular CCA;
- C2 permanece BLOCKED / NOT_VERIFIED;
- C5 = IN_PROGRESS;
- C6 = IN_PROGRESS;
- nenhuma membership OVR-01 persistida.


## 2026-10-06 — CP63

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP63.md`;
- codebook Study/Report e matriz preliminar de membership consolidados;
- C2 = BLOCKED / NOT_VERIFIED;
- C5 = IN_PROGRESS;
- C6 = IN_PROGRESS;
- nenhum CCA ou membership persistido;
- retomada movida para resolução de aliases/multiple Reports e fechamento C5–C6.


## 2026-10-06 — OVR-01 identity aliases corrected

- Documento 153 criado.
- Eigl 2023 e Hinterberger 2024 tratados como Studies distintos.
- Lorenz, Glozier, Hagatun e Maurer tiveram aliases de ano resolvidos.
- GoodNight permanece uma Study com múltiplos Reports.
- Documentos 151–152 atualizados.
- C2 bloqueado; C5/C6 em progresso; CCA ainda não autorizado.


## 2026-10-06 — CP64

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP64.md`;
- identidade de Eigl/Hinterberger corrigida;
- aliases de ano prioritários resolvidos;
- C2 permanece bloqueado;
- C5/C6 continuam em progresso;
- CCA permanece não autorizado.


## 2026-10-06 — OVR-01 article-list reconciliation

- Documento 154 criado;
- Hwang = 29 artigos;
- GoodNight colapsa Christensen 2016 + Batterham 2017 + Batterham 2024 em uma Study;
- Hwang = 27 Study candidates provisórios;
- Nazari = 49 linhas de artigo;
- clusters confirmados em Nazari: GoodNight, REST, DIALS, SPREAD e Ritterband/Shaffer;
- Nazari = máximo provisório de 44 Study candidates após esses clusters;
- pelo menos 17 overlaps Hwang × Nazari confirmados;
- Chan 2023 (Hwang) e Chan 2024 (Nazari) confirmados como Studies distintas;
- C2 bloqueado; C5/C6 em progresso; CCA não autorizado.


## 2026-10-06 — CP65

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP65.md`;
- listas Hwang/Nazari completas em nível de artigo consolidadas;
- cinco multiple-report clusters confirmados em Nazari;
- pelo menos 17 overlaps Hwang × Nazari confirmados;
- C2 bloqueado; C5/C6 em progresso; CCA não autorizado;
- retomada movida para fechamento Study-level de Hwang/Nazari e cruzamento Gao.


## 2026-10-06 — OVR-01 C5–C6 closed

- Documento 155 criado;
- Hwang = 27 Study candidates;
- Gao = 15 Study candidates;
- Nazari = 44 Study candidates;
- união combinada = 59 Study candidates;
- occurrences = 86;
- C5 = PASS_WITH_DOCUMENTED_UNCERTAINTY;
- C6 = PASS;
- identidade permanece AI-assisted/unverified;
- CCA não calculado;
- C2 Gao last-search date permanece bloqueado;
- próxima etapa: C7 membership completeness + C8/CCA readiness.


## 2026-10-06 — CP66

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP66.md`;
- C5 = PASS_WITH_DOCUMENTED_UNCERTAINTY;
- C6 = PASS;
- matriz preparatória = 59 Study candidates / 86 occurrences;
- CCA não calculado;
- retomada movida para C7 membership completeness e C8/CCA readiness.


## 2026-10-06 — OVR-01 C7–C8 closed

- Documento 156 criado;
- C7 = PASS;
- membership completeness estrutural = complete para Hwang, Gao e Nazari;
- complete permanece separado de identity confidence/verification;
- C8 = READY_WITH_DOCUMENTED_CONDITIONS;
- CCA não calculado;
- C2 permanece bloqueado;
- próxima etapa: C9–C12 + tentativa de resolução de C2.


## 2026-10-06 — CP67

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP67.md`;
- C7 = PASS;
- C8 = READY_WITH_DOCUMENTED_CONDITIONS;
- CCA permanece não calculado;
- retomada movida para C9–C12 + tentativa legítima de resolver C2.


## 2026-10-06 — OVR-01 C9–C12 closed

- Documento 157 criado — C9, C11 e C12;
- Documento 158 criado — C10 ROBIS;
- C9 = PASS;
- C10 = PASS_WITH_DOCUMENTED_LIMITATIONS;
- C11 = PASS_WITH_PREPARED_NAZARI_MATERIALIZATION;
- C12 = PASS_WITH_DOCUMENTED_LIMITATION;
- Hwang ROBIS = unclear;
- Gao ROBIS = unclear;
- Nazari ROBIS = high;
- certainty review-level não é inventada;
- GRADE da Evidence Sheet N2 não será reutilizado;
- C2 Gao last-search date permanece BLOCKED / NOT_VERIFIED;
- próxima etapa: gate pré-persistência consolidado.


## 2026-10-06 — CP68

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP68.md`;
- C9 = PASS;
- C10 = PASS_WITH_DOCUMENTED_LIMITATIONS;
- C11 = PASS_WITH_PREPARED_NAZARI_MATERIALIZATION;
- C12 = PASS_WITH_DOCUMENTED_LIMITATION;
- C2 permanece o único blocker explícito das condições C1–C12;
- retomada movida para gate pré-persistência consolidado, sem bypass.


## 2026-10-06 — OVR-01 consolidated pre-persistence gate

- Documento 159 criado;
- gate = **READY_WITH_AMENDMENT_REQUIRED**;
- C2 Gao last-search date permanece BLOCKED / NOT_VERIFIED;
- migration 019 permite currentness unclear, mas mantém MISSING_LAST_SEARCH_DATE como publication error;
- nenhum bypass foi autorizado;
- próxima etapa obrigatória: Emenda 01 ao protocolo developmental.


## 2026-10-06 — CP69

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP69.md`;
- gate consolidado registrado;
- nenhuma entidade real OVR-01 criada;
- retomada movida para Emenda 01 + micro-gate de autorização de persistência.


## 2026-10-06 — OVR-01 Amendment 01

- Documento 160 criado;
- Emenda 01 aplicada prospectivamente ao Documento 149;
- C2 Gao last-search date permanece **BLOCKED / NOT_VERIFIED**;
- para a rota developmental A0/A1, `last_search_date=NULL` passa a ser permitido com `currentness_status='unclear'` e rationale explícita;
- nenhuma data é inferida;
- `MISSING_LAST_SEARCH_DATE` permanece **error** do publication gate;
- publicação continua proibida;
- rota formal permanece **NOT_READY**;
- nenhuma entidade real OVR-01 criada nesta etapa.


## 2026-10-06 — OVR-01 persistence micro-gate

- Documento 161 criado;
- migration 019 conferida diretamente: last_search_date nullable, currentness `unclear` suportada e rationale exigida;
- publication blocker preservado;
- C1–C12 reavaliados sem reclassificar C2;
- micro-gate = **READY_TO_PERSIST_DEVELOPMENTAL_A0**;
- autorização limitada à persistência interna A0;
- próxima etapa: persistência real controlada + testes/rebuild/render + verificação metodológica adversarial antes de eventual A1.


## 2026-10-06 — CP70

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP70.md`;
- Emenda 01 e micro-gate consolidados;
- nenhuma entidade real OVR-01 existe ainda;
- retomada movida para a persistência controlada do OVR-01 em A0 e validação pós-persistência.

## 2026-10-06 — OVR-01 real developmental A0 persisted and validated

- criado `database/f3-real-case-ovr01-dcbti.sql`;
- criado `database/f3-real-case-ovr01-tests.sql`;
- Question/Investigation/Product próprios materializados para o OVR-01;
- Nazari materializada de forma rastreável;
- ReviewItems Hwang/Gao/Nazari persistidos;
- memberships = 27 / 15 / 44;
- occurrences = 86;
- unique primary Study candidates = 59;
- pairwise overlap derivado pelo banco = 6 / 17 / 9;
- CCA permanece exclusivamente derivado pelo banco; nenhum valor foi calculado manualmente;
- Gao mantém `last_search_date=NULL` e `currentness_status='unclear'`, sem inferência;
- comparadores permanecem separados;
- nenhuma nova meta-analysis foi criada;
- certainty review-level não foi inventada nem reutilizada do N2;
- ROBIS e memberships permanecem AI-assisted/unverified;
- nenhuma verificação humana, owner approval ou expert review foi fabricada;
- assurance permanece A0;
- publication blockers permanecem abertos;
- OVR01-T01–T14 = PASS;
- render real A0 via `OverviewOfReviewsView` = PASS;
- regressões/idempotência = PASS;
- rebuild-from-zero = PASS;
- run final 37542350632 = success;
- artifact 11449631263;
- digest `sha256:138fb9fe28432124dc6e70031bd0a99c1c11a40647ba8ff73687f3fd3cecdb93`;
- próxima etapa: verificação metodológica adversarial pós-persistência antes de eventual A1.


## 2026-10-06 — CP71

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP71.md`;
- OVR-01 = **PERSISTED_DEVELOPMENTAL_A0_VALIDATED**;
- ponteiro de continuidade movido para CP71;
- retomada movida para verificação metodológica adversarial pós-persistência;
- nenhuma promoção A1/A2/A3 ou publicação foi realizada neste checkpoint.


## 2026-10-06 — OVR-01 adversarial closure and internal A1

- Documento 162 registrou primeira verificação metodológica adversarial = **REVISE**;
- achados materiais: Search execution não sustentada, regra retrospectiva `minimum_bibliographic_sources=2` e drift da Question;
- correções aplicadas sem inferir last-search date de Gao, sem CCA manual, sem nova meta-analysis e sem controles humanos fabricados;
- OVR01-T15–T16 adicionados como guards de regressão;
- Documento 163 registrou segunda passagem adversarial = **PASS**;
- `database/f3-real-case-ovr01-assurance-a1.sql` criado;
- `database/f3-real-case-ovr01-a1-tests.sql` criado;
- assurance final = **A1 interno** por `ai_methodological_verification=passed`;
- OVR01-A1-T01–T09 = PASS;
- OVR01-RENDER-A1 = PASS;
- publication blockers formais preservados;
- owner approval, expert review e human verification continuam ausentes;
- Documento 164 criado para encerramento controlado;
- run final **37549135468** (#117) = success;
- HEAD validado `ecc04933dd5ba116345dc4dcf8d352a646b6aed7`;
- artifact **11452420926**;
- digest `sha256:4dff568129b92a6a4565c33c015afbbe7bec2cc872333b4f99b2701b9c9151a6`;
- OVR-01 = **DEVELOPMENTAL_A1_INTERNAL_VALIDATED / não publicável**;
- próxima etapa: Especificação Científica e Funcional do Monitor de Evidências.


## 2026-10-06 — CP72

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP72.md`;
- OVR-01 consolidado como **DEVELOPMENTAL_A1_INTERNAL_VALIDATED**;
- Documento 164 registrado como encerramento controlado;
- run final 37549135468 = success;
- OVR01-A1-T01–T09 e OVR01-RENDER-A1 = PASS;
- publication blockers formais preservados;
- ponteiro de continuidade movido para CP72;
- retomada movida para **Especificação Científica e Funcional do Monitor de Evidências**.


## 2026-10-06 — Evidence Monitor scientific/functional specification

- Documento 165 criado;
- Monitor definido como produto/processo de manutenção M2/M3, não N5;
- alvo científico rastreável tornou-se requisito;
- Monitoring Cycle separado de ProductVersion científica;
- ausência de mudança não gera automaticamente nova versão do alvo;
- `product.currency_state` deverá ser reutilizado para currentness;
- atualização científica material continuará ocorrendo por versionamento do produto monitorado;
- Monitor e Alerta de Evidência permanecem distintos;
- assurance do alvo não é herdado como validação automática do Monitor;
- thresholds temporais/quantitativos gerais permaneceram reservados à Fase 4;
- nenhuma migration autorizada antes da revisão de coerência arquitetural;
- próxima etapa: revisão científica/arquitetural do Monitor.


## 2026-10-06 — CP73

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP73.md`;
- Documento 165 consolidado;
- Monitor de Evidências = produto/processo M2/M3, não N5;
- nenhuma migration autorizada antes da revisão arquitetural;
- ponteiro de continuidade movido para CP73;
- retomada movida para revisão de coerência científica e arquitetural do Monitor.


## 2026-10-06 — Evidence Monitor architectural coherence

- Documento 166 criado;
- revisão arquitetural = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- Monitor será Product próprio com Investigation própria de manutenção;
- depth N será herdado do alvo; maintenance = M2/M3;
- Search do Monitor permanecerá separada da Investigation científica histórica;
- camada especializada `maintenance` foi autorizada conceitualmente;
- Search/SearchHit, currency_state, version_change_class e provenance serão reutilizados;
- Monitoring Cycle não será ProductVersion;
- candidate assessment e validity events serão especializados;
- Alert completo permanece fora desta etapa;
- data-contract readiness = READY;
- migration readiness = NOT_YET;
- próxima etapa: Contrato de Dados v0.1.


## 2026-10-06 — CP74

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP74.md`;
- Documento 166 consolidado;
- revisão arquitetural do Monitor = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- data-contract readiness = READY;
- migration readiness = NOT_YET;
- ponteiro de continuidade movido para CP74;
- retomada movida para **Contrato de Dados v0.1 do Monitor de Evidências**.


## 2026-10-06 — Evidence Monitor data contract v0.1

- Documento 167 criado;
- contrato = **DATA_CONTRACT_V0_1_READY_FOR_IMPLEMENTATION**;
- schema `maintenance` definido conceitualmente;
- oito estruturas especializadas definidas;
- cutoff do Monitor definido como baseline estático da versão monitorada;
- cycles passam a carregar cutoffs posteriores;
- Search/SearchHit, currentness, version_change_class e provenance são reutilizados;
- Monitor M2 formal v0.1 exige A2;
- M3 formal permanece bloqueado até Protocolo de Atualização da Fase 4;
- migration candidata = `database/021_evidence_monitor_contract.sql`;
- próxima etapa: migration 021 + fixture + testes + rebuild/regressões.


## 2026-10-06 — CP75

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP75.md`;
- Documento 167 consolidado;
- contrato de dados do Monitor = **READY_FOR_IMPLEMENTATION**;
- migration 021 autorizada;
- ponteiro de continuidade movido para CP75;
- retomada movida para migration 021 + fixture/testes/rebuild.


## 2026-10-06 — Evidence Monitor technical validation PASS

- Documento 168 criado;
- migration 021 implementada e endurecida;
- lifecycle corrigido para impedir Search/Event/Candidate retrospectivos em cycle terminal;
- fixture M2 formal/A2 e fixture M3 bloqueada pela fronteira da Fase 4 validadas;
- MON-T01–T12 = PASS;
- MON-T13–T32 = PASS;
- MON-T33 idempotent re-apply = PASS;
- run intermediário #120 falhou apenas por uso de `min(uuid)`, corrigido sem mudança semântica;
- run #121 = success;
- resumo textual do rebuild foi alinhado de migration 020 para 021;
- run final **37553271462** (#122) = **success**;
- HEAD validado `d7ca356c8cc4d58552a9e52868fce92f27eaad9e`;
- rebuild-from-zero through migration 021 = PASS;
- artifact **11453871816**;
- digest `sha256:71dd0b68c92ce3d30832862545ac45efbfb94cba51580d77f2673f12a94fbaf8`;
- próximo gate: **Projection Readiness da EvidenceMonitorView**.


## 2026-10-06 — CP76

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP76.md`;
- contrato técnico do Monitor v0.1 consolidado em PASS;
- migration 021 + MON-T01–T33 + rebuild = PASS;
- run final 37553271462 (#122) = success;
- ponteiro de continuidade movido para CP76;
- retomada movida para **Projection Readiness Gate da EvidenceMonitorView**.


## 2026-10-06 — Evidence Monitor Projection Readiness NOT_READY

- Documento 169 criado;
- Projection Readiness da EvidenceMonitorView = **NOT_READY**;
- PR-MON-01: múltiplas categorias de impacto não estão normalizadas;
- PR-MON-02: source policy é apenas parcialmente interpretada pelo engine;
- PR-MON-03: exceções de cobertura via MethodDecision não entram no cálculo de coverage;
- PR-MON-04: temporal consistency de cycle/Search e drift dinâmico ainda são incompletos;
- PR-MON-05: Cycle → CurrencyState ainda pode ser regravado;
- migration 022 passa a ser reservada ao **Projection Readiness hardening**;
- EvidenceMonitorView passa a ser candidata para migration 023;
- nenhum template ou Caso Real do Monitor está autorizado antes do novo gate.


## 2026-10-06 — CP77

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP77.md`;
- Documento 169 consolidado;
- EvidenceMonitorView Projection Readiness = **NOT_READY**;
- migration 022 reservada ao hardening;
- EvidenceMonitorView movida para migration candidata 023;
- ponteiro de continuidade movido para CP77;
- retomada: especificação + implementação do Projection Readiness hardening.


## 2026-10-06 — Evidence Monitor projection hardening specification

- Documento 170 criado;
- hardening spec = **READY**;
- duas estruturas auxiliares normalizadas autorizadas: `candidate_impact` e `monitor_source_requirement`;
- source exceptions reutilizarão MethodDecision;
- temporal/search drift será revalidado dinamicamente;
- CycleCurrencyState será imutável;
- publication gate será endurecido sem remover blockers da migration 021;
- migration 022 autorizada somente para hardening;
- EvidenceMonitorView permanece migration candidata 023.


## 2026-10-06 — CP78

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP78.md`;
- Documento 170 consolidado;
- migration 022 autorizada para hardening de Projection Readiness;
- EvidenceMonitorView continua adiada para migration 023;
- ponteiro de continuidade movido para CP78;
- retomada: migration 022 + fixture + MONH-T01–T24 + rebuild.


## 2026-10-06 — Evidence Monitor projection hardening technical PASS

- Documento 171 criado;
- migration 022 = PASS;
- candidate impacts múltiplos normalizados;
- source requirements normalizados;
- source/temporal exceptions integradas via MethodDecision;
- Search temporal/investigation/status drift revalidado dinamicamente;
- CycleCurrencyState tornou-se imutável;
- MON-T01–T32 = PASS;
- MONH-T01–T22 = PASS;
- MON-T33 chain 021→022 = PASS;
- MONH-T23 = PASS;
- MONH-T24 rebuild-through-022 = PASS;
- run 37555588465 (#125) = success;
- artifact 11453649661;
- próximo passo: novo Projection Readiness Gate explícito.


## 2026-10-06 — CP79

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP79.md`;
- migration 022/hardening técnico consolidado em PASS;
- MON-T01–T32 + MONH-T01–T24 = PASS;
- run 37555588465 (#125) = success;
- ponteiro de continuidade movido para CP79;
- retomada: novo Projection Readiness Gate explícito.


## 2026-10-06 — Evidence Monitor Projection Readiness READY

- Documento 172 criado;
- novo gate adversarial concluiu PR-MON-01–05 = RESOLVED;
- resíduo pós-CP79 identificado: temporal exception helper não exigia stage=search;
- migration 022 corrigida para exigir stage=search;
- MONH-T12 ampliado para rejeitar accepted exception no estágio errado;
- run final pós-correção **37555981343** (#127) = success;
- artifact **11454409428**;
- Projection Readiness = **READY**;
- migration 023 autorizada para EvidenceMonitorView 0.1;
- template/Caso Real/Alert/Fase 4 permanecem não autorizados.


## 2026-10-06 — CP80

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP80.md`;
- Projection Readiness Gate 02 = **READY**;
- migration 023 autorizada para EvidenceMonitorView 0.1;
- ponteiro de continuidade movido para CP80;
- retomada: implementação da View + testes + idempotência + rebuild.


## 2026-10-06 — EvidenceMonitorView 0.1 PASS

- Documento 173 criado;
- migration 023 implementou `oes.evidence_monitor_view/0.1`;
- target projection e cycle projection especializadas foram adicionadas;
- View é read-only/STABLE;
- quatro dimensões de estado permanecem separadas;
- target ProductVersion/InvestigationVersion permanece polimórfico e explícito;
- múltiplos CandidateImpacts são projetados sem colapso;
- source requirement fulfillment e exceptions permanecem distintos;
- histórico Cycle→CurrencyState é preservado;
- M3 Phase-4 blocker permanece visível;
- MONV-T01–T17 = PASS;
- MONV-T18 = PASS;
- MONV-T19/rebuild-through-023 = PASS;
- run final **37556593132** (#128) = success;
- HEAD validado `613a9ced4ad43a3eb890a2b5db35acf51a08127e`;
- artifact **11454488440**;
- digest `sha256:6043e52ac33800ec5d944b1a4633bfe5049a9c8ecff2613eb577aadea2916630`;
- próxima etapa: contrato de renderização + Template Operacional do Monitor;
- Caso Real, Alert e Fase 4 continuam não autorizados.


## 2026-10-06 — CP81

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP81.md`;
- EvidenceMonitorView 0.1 consolidada em PASS;
- migration 023 + MONV-T01–T19 = PASS;
- run 37556593132 (#128) = success;
- ponteiro de continuidade movido para CP81;
- retomada: contrato de renderização + Especificação do Template Operacional do Monitor.


## 2026-10-06 — Evidence Monitor presentation PASS

- Documento 174 definiu o contrato de renderização;
- Documento 175 especificou o Template Operacional;
- template, presentation map, renderer e validator implementados;
- run #129 falhou por acesso a target currency não aplicável no M3; corrigido sem mudança científica;
- run **37558043092** (#130) = success;
- artifact **11455658237**;
- Monitor formalizado na Fase 3;
- Caso Real do Monitor não é obrigatório para o fechamento taxonômico desta fase;
- próxima etapa: **Alerta de Evidência**;
- Fase 4 permanece não iniciada.


## 2026-10-06 — CP82

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP82.md`;
- Monitor de Evidências formalizado na Fase 3;
- ponteiro de continuidade movido para CP82;
- retomada: **Alerta de Evidência**, último produto da taxonomia;
- Fase 4 explicitamente não autorizada.


## 2026-10-06 — Evidence Alert scientific/architectural specification

- Documento 177 definiu o contrato científico/funcional do Alerta;
- Documento 178 fechou arquitetura em PASS_WITH_ARCHITECTURAL_DECISIONS;
- Alert será Product/ProductVersion sem nova Investigation;
- source_context Investigation será reutilizada explicitamente;
- target, sources e affected dimensions serão normalizados em maintenance;
- classification/urgency serão qualitativas e persistidas, sem thresholds/SLA;
- publicação formal exigirá A2 + human verification do conteúdo/classificação;
- Alert não terá scientific conclusion nem Product currency próprios;
- Fase 4 não foi iniciada;
- próxima etapa: Contrato de Dados v0.1.


## 2026-10-06 — CP83

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP83.md`;
- arquitetura do Alerta consolidada;
- ponteiro de continuidade movido para CP83;
- retomada: Contrato de Dados v0.1 do Alerta;
- Fase 4 permanece explicitamente não autorizada.


## 2026-10-06 — Evidence Alert data contract v0.1

- Documento 179 criado;
- contrato físico do Alerta fechado;
- migration 024 autorizada;
- View adiada até Projection Readiness explícito;
- classification/urgency continuam qualitativas, sem thresholds/SLA;
- Fase 4 permanece não iniciada.


## 2026-10-06 — CP84

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP84.md`;
- Contrato de Dados v0.1 do Alerta consolidado;
- ponteiro movido para CP84;
- migration 024 + fixtures/testes autorizados;
- Fase 4 permanece não iniciada.


## 2026-10-06 — Evidence Alert contract PASS / projection NOT_READY

- Documento 180 registrou PASS técnico da migration 024;
- run 37559879675 (#132) = success;
- AL-T01–T30 + rebuild-through-024 = PASS;
- Documento 181 executou gate adversarial de projeção;
- Projection Readiness = NOT_READY;
- blockers: child inserts pós-publicação, source-context sealing, all-source drift e EntityVersion source lineage;
- migration 025 reservada ao hardening;
- Fase 4 permanece não iniciada.


## 2026-10-06 — CP85

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP85.md`;
- contrato do Alerta tecnicamente validado;
- Projection Readiness = NOT_READY;
- ponteiro movido para CP85;
- retomada: migration 025 de hardening;
- Fase 4 permanece não iniciada.


## 2026-10-06 — Evidence Alert Projection Readiness READY

- Documento 182 registrou PASS técnico do hardening 025;
- Documento 183 reexecutou o gate adversarial;
- PR-ALT-01–04 = RESOLVED;
- run 37560513048 (#135) = success;
- ALT-H01–H13 + rebuild-through-025 = PASS;
- Projection Readiness = READY;
- migration 026 autorizada para EvidenceAlertView 0.1;
- Fase 4 permanece não iniciada.


## 2026-10-06 — CP86

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP86.md`;
- Projection Readiness do Alerta = READY;
- ponteiro movido para CP86;
- retomada: migration 026 / EvidenceAlertView 0.1;
- Fase 4 permanece não iniciada.


## 2026-10-06 — EvidenceAlertView 0.1 PASS

- Documento 184 criado;
- migration 026 implementou `oes.evidence_alert_view/0.1`;
- EAV-T01–T15 = PASS;
- EAV-T16 = PASS;
- EAV-T17/rebuild-through-026 = PASS;
- run **37560891043** (#138) = success;
- artifact **11456283842**;
- próxima etapa: contrato de renderização + Template Operacional do Alerta;
- Fase 4 permanece não iniciada.


## 2026-10-06 — CP87

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP87.md`;
- EvidenceAlertView 0.1 consolidada em PASS;
- ponteiro de continuidade movido para CP87;
- retomada: apresentação do Alerta + fechamento da Fase 3;
- Fase 4 permanece explicitamente não autorizada.


## 2026-10-06 — Evidence Alert presentation PASS

- Documentos 185–186 definiram contrato de renderização e template do Alerta;
- template, presentation map, renderer e validator implementados;
- run #139 falhou por leitura indiscriminada de campos de subtype em `monitor_origin`; corrigido;
- run #140 falhou por asserção textual excessivamente rígida do validator; corrigido;
- run **37561515491** (#141) = success;
- artifact **11456897850**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`;
- Alerta de Evidência formalizado na Fase 3.

## 2026-10-06 — Fase 3 concluída

- Documento 188 executou o Gate de Encerramento da Fase 3;
- 9/9 produtos da taxonomia = formalizados no escopo técnico/taxonômico da fase;
- validation S5 #141 = success;
- rebuild-through-026 = PASS;
- regressões globais = PASS;
- blockers reais/developmentais permanecem preservados e não foram artificialmente removidos;
- `PHASE_3_PRODUCTS = COMPLETE`;
- `PHASE_4 = NOT_STARTED / NOT_AUTHORIZED`;
- Fase 4 somente poderá começar mediante consentimento explícito do usuário em nova conversa.


## 2026-10-06 — CP88

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP88.md`;
- Gate de Encerramento da Fase 3 = **PASS**;
- 9/9 produtos da taxonomia formalizados no escopo técnico/taxonômico;
- ponteiro de continuidade movido para CP88;
- estado consolidado: `PHASE_3_COMPLETE / PHASE_4_NOT_STARTED`;
- Fase 4 permanece não iniciada e exige consentimento explícito do usuário em nova conversa.

## 2026-10-06 — Fase 4 iniciada: Protocolo Transversal de Atualização

- Freshness Gate confirmou CP88 como estado canônico de encerramento da Fase 3;
- corrigida a divergência não material do cabeçalho de STATE.md, que ainda declarava Fase 3 em desenvolvimento;
- criado o Documento 05 — Protocolo Transversal de Atualização v0.1;
- arquitetura separa versão científica, currentness, manutenção M0–M3 e estado operacional/comunicacional;
- definidos signals científicos/currentness e signals operacionais como classes distintas;
- definidos gatilhos, avaliação de materialidade, state machine de currentness, cadence grammar, relógios de SLA, priorização, propagação, governança e fronteira de automação;
- currentness canônico permanece exclusivo de ProductVersion;
- InvestigationVersion não recebe CurrencyState artificial;
- cadence vencida/ciclo incompleto não altera currentness automaticamente;
- criado o Documento 06 — revisão adversarial;
- revisão = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- M3 permanece bloqueado por `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`;
- Documento 05 não remove nem contorna o blocker técnico;
- nenhuma migration, View, template, renderer ou workflow foi alterado;
- última evidência técnica permanece S5 run **37561515491** (#141) = success;
- próximo passo: Contrato de Dados v0.1 do Protocolo Transversal de Atualização, antes de qualquer migration.

## 2026-10-06 — CP89

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP89.md`;
- ponteiro de continuidade movido para CP89;
- STATE atualizado para **Fase 4 — Protocolo de Atualização**;
- `PROJECT_STATE = PHASE_4_IN_PROGRESS`;
- `PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- data contract = NOT_YET_SPECIFIED;
- migration de Fase 4 = NOT_AUTHORIZED;
- M3 formal operacional = BLOCKED;
- retomada exata: especificar maintenance policy/version, update signal, materiality assessment e update decision, seguido de gate de coerência física.

## 2026-10-07 — Phase 4 transversal update data contract PASS

- Documento 07 definiu o Contrato de Dados v0.1 do Protocolo Transversal de Atualização;
- o contrato foi endurecido adversarialmente para preservar maintenance × currentness × editorial × assurance;
- `MethodDecision` foi confirmado como conceito documental, não entidade física do baseline;
- Documento 08 executou gate de coerência física = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- migration `027_transversal_update_protocol_contract.sql` autorizada e implementada;
- sete estruturas aditivas criadas em `maintenance`;
- fixtures e bateria `F4-UP-T01–T63` implementadas;
- erro provisório no setup de T44 foi corrigido antes da validação canônica;
- workflow S5 atualizado para migration 027, F4 fixtures/tests, idempotência e rebuild;
- run **37570978847** = **success**;
- HEAD técnico validado `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- F4-UP-T01–T63 = **PASS**;
- F4-UP-IDEM = **PASS**;
- rebuild-through-027 = **PASS**;
- regressões F2-B/S4/S5/Monitor/Alert = **PASS**;
- artifact **11460960487**;
- digest `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`;
- Documento 09 registrou `PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_027 = PASS`;
- `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL` permanece ativo;
- thresholds, SLAs numéricos, score de prioridade, scheduler, notifications, auto-classification, auto-escalation, propagation e M3 readiness continuam fora do escopo.

## 2026-10-07 — CP90

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP90.md`;
- ponteiro de continuidade movido para CP90;
- primeiro contrato físico transversal da Fase 4 consolidado em PASS técnico;
- próximo passo: arquitetura de perfis de risco operacional/científico para parametrizar cadence, thresholds, SLAs e prioridade.

## 2026-10-07 — Correção de inventário: MethodDecision

- confirmado que `investigation.method_decision` existe fisicamente desde a migration 014;
- corrigida a afirmação anterior de que MethodDecision seria apenas conceito documental;
- `maintenance.update_decision` permanece como decisão especializada do protocolo de atualização;
- `investigation.method_decision` permanece como decisão metodológica ligada à InvestigationVersion;
- o PASS da migration 027 permanece válido porque sua implementação não dependia da ausência de MethodDecision;
- eventual linkage entre `reroute_method` e MethodDecision será definido explicitamente em bloco posterior, sem inferência retroativa.

## 2026-10-07 — Phase 4 risk profile and cadence baseline

- Documentos 16–17 definiram e revisaram adversarialmente os perfis de risco operacional/científico;
- `PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- score agregado aditivo rejeitado;
- taxonomia paralela R0–R3 rejeitada;
- risco científico e capacidade operacional separados;
- recomendação de manutenção reutiliza o domínio canônico M0–M3;
- recomendação M3 não ativa M3;
- currentness permanece fora do perfil;
- Documentos 18–19 definiram e revisaram cadence e thresholds temporais;
- `PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- separados relógios de vigilância, processamento, reassessment de policy/profile e atualização científica;
- schedule compliance e coverage continuity permanecem distintos;
- M1 periódico = reassessment programado, sem Monitoring Cycle por default;
- M2 periódico = surveillance ativa pelo Monitor governante;
- `monitor_cycle.planned_at` preservado como instante nominal programado de início;
- overdue é estado operacional derivado e não CurrencyState;
- cadence vencida/gap não muda currentness sem UpdateSignal → MaterialityAssessment → UpdateDecision;
- nenhuma migration 028 criada;
- M3 formal permanece bloqueado.

## 2026-10-07 — CP91

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP91.md`;
- ponteiro movido para CP91;
- correção de inventário de `investigation.method_decision` reconciliada com migration 014;
- perfis de risco e política temporal consolidados;
- próximo passo: arquitetura transversal de SLA, sem durações universais antes do gate semântico.

## 2026-10-07 — CP92

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP92.md`;
- ponteiro de continuidade movido para CP92;
- reconciliado o estado pós-CP91 em README/STATE/CHANGELOG;
- confirmado diretamente que `investigation.method_decision` existe desde a migration 014;
- preservada a distinção entre `investigation.method_decision` e `maintenance.update_decision`;
- o PASS técnico da migration 027 permanece válido;
- perfis de risco e política de cadence/thresholds temporais permanecem em **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- template canônico de continuidade atualizado para exigir pausa após cada checkpoint formal;
- nenhuma migration 028 criada;
- nenhum bloco de SLA iniciado;
- próximo passo: arquitetura transversal de SLA, somente após instrução explícita do usuário.

## 2026-10-07 — Phase 4 SLA architecture baseline

- Documento 20 definiu a arquitetura transversal de SLA;
- Documento 21 executou revisão adversarial = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- `PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- seis clocks mínimos definidos: detection→triage, triage→materiality, materiality→decision, decision→workflow start, workflow start→scientific completion, completion→review/publication;
- late normalization não reinicia SLA-1;
- evento anterior à vigência da SLA Rule preserva pre_policy_age sem breach retroativo;
- `materiality_qualified_at` e `decision_qualified_at` consideram verificação humana posterior;
- rule snapshot é congelada por SLA Instance;
- elapsed_time, business_calendar e fixed_deadline separados;
- nominal_due_at e effective_due_at separados;
- pause retroativa não apaga breach;
- backlog/capacidade baixa não são pause automáticas;
- execution_status e compliance_status permanecem eixos distintos;
- `breached_then_satisfied` preserva atraso histórico;
- Alert urgency/classification não contém duração universal;
- cycle lateness do Monitor permanece cadence, não SLA;
- triage transversal e workflow milestones permanecem gaps físicos;
- prioridade precisa preceder contrato físico conjunto de SLA;
- `MIGRATION_028 = NOT_AUTHORIZED`;
- `NUMERIC_SLA_DURATIONS = NOT_DEFINED`;
- M3 formal permanece bloqueado.

## 2026-10-07 — CP93

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP93.md`;
- ponteiro movido para CP93;
- SLA architecture consolidada;
- próximo passo: prioridade/escalation;
- regra de pausa obrigatória após checkpoints preservada.

## 2026-10-07 — Phase 4 retrospective audit and corrective hardening

- Documento 22 executou auditoria retrospectiva da Fase 4 até CP93;
- a arquitetura conceitual 05–21 permaneceu coerente;
- identificado que T01–T63 não espelhava um-a-um os 63 requisitos mínimos do Documento 07;
- identificados gaps de lifecycle e dynamic issue helpers;
- Documento 23 autorizou migration 028 somente como hardening corretivo;
- migration 027 permaneceu historicamente intacta;
- migration 028 passou a:
  - restringir `signal_type='other'` a combinações semânticas coerentes;
  - exigir UpdateSignal ativo para nova UpdateDecision;
  - exigir UpdateDecision ativa para novo CurrencyState linkage;
  - ampliar issue helpers de policy/signal/materiality/decision;
- criada suíte `f4-update-protocol-plan-tests.sql`;
- P01–P58 espelham Documento 07 §34 itens 1–58;
- P59–P63 são evidências explícitas de idempotência, rebuild e regressões no workflow;
- run **37576345925** (#143) falhou em P62 por erro de desenho de teste ao reexecutar baseline F2-B sobre banco enriquecido; não é evidência de PASS;
- P62/P63 foram corrigidos para certificar as regressões canônicas já executadas após migration 028;
- run **37576434417** (#144) = **success**;
- technical HEAD `3f36b5dd4103e15834adde107fedeeb1c81fb084`;
- artifact **11462802190**;
- digest `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- T01–T63 = PASS;
- P01–P63 = PASS;
- migration 027 idempotency = PASS;
- migration 028 idempotency = PASS;
- rebuild-through-028 = PASS;
- F2-B/S4/S5 = PASS;
- Monitor/Alert = PASS;
- M3 blocker preservado;
- Documento 24 fechou o bloco corretivo em **CLOSED_PASS**;
- metadados de dependência/validação dos Documentos 16/18/20 foram normalizados;
- STATE passou a explicitar que trechos antigos são snapshots históricos;
- database README atualizado para o estado pós-auditoria;
- próximo bloco permitido: prioridade/escalation.

## 2026-10-07 — CP94

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP94.md`;
- ponteiro de continuidade movido para CP94;
- auditoria retrospectiva da Fase 4 encerrada em **CLOSED_PASS**;
- contrato físico passa a `TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING`;
- migration 028 corretiva = PASS;
- F4-UP-T01–T63 = PASS;
- F4-UP-P01–P63 = PASS;
- rebuild-through-028 = PASS;
- regressões F2-B/S4/S5 e Monitor/Alert = PASS;
- run **37576434417** (#144) = success;
- artifact **11462802190**;
- M3 formal permanece bloqueado;
- prioridade/escalation não iniciada;
- próximo passo: arquitetura transversal de prioridade e escalation;
- regra de pausa obrigatória após checkpoint preservada.

## 2026-10-07 — Phase 4 priority and escalation architecture

- Documento 25 definiu arquitetura transversal de prioridade e escalation;
- Documento 26 executou revisão adversarial;
- primeira passagem do gate = **REVISE**;
- corrigida mistura entre priority e governance: `immediate_governance` → `immediate`;
- removidos floors universais de `material_change_confirmed` isolado e `update_recommended` isolado;
- preservados dominance/composite floors de safety/validity/suspend/high criticality;
- PriorityAssessment futura distingue `proposal | authoritative`;
- materiality AI-only não sustenta floor científico autoritativo;
- target supersession/invalidation movido de dominance para lifecycle/reassessment;
- queue aggregation definida como derivada, sem apagar causalidade por signal/case;
- escalation candidate pode ser automática, mas active exige autoridade humana na baseline;
- Alert classification/reassessment_priority permanece input local, sem mapping automático;
- breach permanece operational pressure modifier;
- capacity não compensa risco/prioridade;
- dependency reach aumenta coordination pressure, não materiality;
- gate reexecutado = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- `PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `MIGRATION_029 = NOT_AUTHORIZED`;
- priority score/pesos numéricos não definidos;
- auto-escalation não autorizada;
- M3 formal permanece bloqueado;
- próximo passo: contrato de dados integrado do plano operacional da Fase 4, ainda sem migration.

## 2026-10-07 — CP95

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP95.md`;
- ponteiro de continuidade movido para CP95;
- arquitetura transversal de prioridade/escalation consolidada em **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- primeira revisão adversarial produziu REVISE e foi efetivamente corrigida antes do PASS;
- response_class = standard | expedited | urgent | immediate;
- priority/escalation separados;
- floors isolados não dominantes removidos;
- authority_status proposal/authoritative incorporado ao desenho;
- materiality AI-only não sustenta floor científico autoritativo;
- Alert sem mapping automático;
- breach sem circularidade com SLA;
- capacity sem compensação de risco;
- queue aggregation apenas derivada;
- auto-escalation não autorizada;
- migration 029 não autorizada;
- score/pesos numéricos não definidos;
- M3 formal permanece bloqueado;
- próximo passo: contrato de dados integrado de triage + priority/escalation + SLA + workflow milestones, ainda sem migration;
- regra de pausa após checkpoint preservada.

## 2026-10-07 — Phase 4 integrated operational control contract

- Documento 27 definiu contrato lógico integrado de triage + priority/escalation + SLA + workflow;
- Documento 28 executou gate físico adversarial;
- primeira passagem = **REVISE**;
- corrigidos 22 blockers de determinismo/lifecycle/circularidade e um achado adicional de WorkflowRound status;
- UpdatePolicy preservada como âncora, sem OperationalPlan duplicado;
- triage invalid_signal usa consistency guard deferred;
- PriorityBasis recebeu source_type/locator XOR/snapshot;
- escalation authority redundante removida e transitions fechadas;
- SLA Rule recebeu rule_code + selection_precedence;
- matrizes clock→endpoint e time_basis fechadas;
- calendar/fixed-deadline payloads fechados;
- effective due/current compliance definidos como derivados;
- SLA obligation cardinality/rebase fechados;
- WorkflowRound planned ancora SLA-4;
- WorkflowMilestone recebeu adapter_type, locator XOR, authority e precisão temporal;
- adapter matrix preserva ReviewRecord/AssuranceRecord/MethodDecision/publication gates existentes;
- risk profile físico segue dívida futura, com snapshot bridge versionado;
- recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- `INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READY_FOR_MIGRATION_029`;
- migration 029 autorizada somente como infrastructure contract;
- nenhuma duração SLA, score/peso, auto-escalation ou M3 unblock autorizados;
- implementação deverá cobrir F4-OC-T01–T72 + idempotência + rebuild + regressões.

## 2026-10-07 — CP96

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP96.md`;
- ponteiro de continuidade movido para CP96;
- contrato operacional integrado consolidado em **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- migration 029 autorizada somente em escopo **OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**;
- migration 029 ainda não implementada;
- F4-OC-T01–T72 definido como plano mínimo de testes;
- nenhuma duração SLA, score/peso ou auto-escalation autorizados;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37576434417** (#144), through migration 028;
- próximo passo: implementação migration 029 + testes + validação canônica;
- modo médio seguro para implementação mecânica, com escalada para alto diante de nova decisão arquitetural;
- regra de pausa após checkpoint preservada.

## 2026-10-07 — Phase 4 operational control technical PASS

- migration 029 implementada no escopo autorizado dos Documentos 27–28;
- criadas fixtures sintéticas não normativas;
- criada suíte `database/f4-operational-control-tests.sql`;
- F4-OC-T01–T69 = PASS;
- T70 migration 029 idempotency = PASS;
- T71 rebuild-through-029 = PASS;
- T72 regressões completas = PASS;
- run canônico **37580906483** (#150) = success;
- technical HEAD `ae45918bb8cbf1ab929aec2e1af53f7239f75323`;
- artifact **11464672034**;
- digest `sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`;
- F4-UP-T01–T63 e P01–P63 permanecem verdes;
- migrations 021–029 aplicáveis permanecem idempotentes conforme workflow;
- M3 blocker preservado;
- runs #145–#149 classificadas como diagnósticas/falhas não canônicas, detalhadas no Documento 29;
- Documento 29 registra `INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED`;
- nenhum número SLA normativo, priority score, auto-escalation ou M3 unblock foi introduzido.

## 2026-10-07 — CP97

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP97.md`;
- ponteiro de continuidade movido para CP97;
- migration 029 e contrato operacional integrado = **TECHNICALLY_VALIDATED**;
- F4-OC-T01–T72 = PASS;
- run canônico **37580906483** (#150) = success;
- artifact **11464672034**;
- rebuild-through-029 = PASS;
- regressões completas = PASS;
- M3 blocker preservado;
- documentos agregados reconciliados após período de baixa visibilidade na interface;
- próximo bloco da Fase 4 ainda não selecionado;
- Fase 5 não iniciada;
- regra de pausa após checkpoint preservada.


## 2026-10-07 — Phase 4 UpdateRiskProfile physical contract

- selecionada a normalização física do UpdateRiskProfile como próxima dívida estrutural após CP97;
- Documento 30 definiu contrato físico candidato;
- Documento 31 executou gate adversarial;
- primeira passagem = **REVISE**;
- provenance dimensional foi normalizada em estrutura própria;
- authority do profile composto foi separada da authority operacional de B5;
- triggers receberam source_type/locator XOR;
- policy basis ganhou lifecycle/supersession;
- snapshots históricos foram grandfathered sem backfill fabricado;
- novos PriorityAssessment deverão usar profile físico + serializer canônico após migration 030;
- proposal incompleto não pode alimentar PriorityAssessment;
- recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- `READY_FOR_MIGRATION_030`;
- migration 030 ainda não implementada;
- F4-RP-T01–T87 definido como plano mínimo;
- M3 blocker preservado.

## 2026-10-07 — CP98

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP98.md`;
- ponteiro de continuidade movido para CP98;
- contrato físico UpdateRiskProfile = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- migration 030 = **AUTHORIZED_IN_STRICT_SCOPE**, ainda não implementada;
- F4-RP-T01–T87 definido como plano mínimo;
- provenance dimensional, authority, carry-forward e snapshot adoption fechados;
- sem backfill fabricado de profiles/policy links históricos;
- sem risk score, numeric cadence, numeric SLA ou auto policy change;
- M3 blocker preservado;
- último PASS técnico continua run **37580906483** (#150);
- próximo passo: implementação migration 030 + S5/idempotência/rebuild/regressões;
- regra de pausa após checkpoint preservada.

## 2026-10-07 — Phase 4 UpdateRiskProfile technical PASS

- migration 030 implementada no escopo dos Documentos 30–31;
- criadas fixtures sintéticas `f4-risk-profile-fixtures.sql`;
- criada suíte `f4-risk-profile-tests.sql`;
- F4-RP-T01–T84 = PASS;
- T85 migration 030 idempotency = PASS;
- T86 rebuild-through-030 = PASS;
- T87 regressões completas = PASS;
- F4-OC foi adaptado para profile físico sem relaxar seus invariantes;
- S5 run canônico **37618433929** (#161) = success;
- technical HEAD `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- artifact **11480858194**;
- digest `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`;
- M3 blocker preservado;
- runs #153–#160 registradas como diagnósticas/não canônicas no Documento 32;
- `UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_030 = PASS`;
- nenhum risk score, numeric cadence, numeric SLA, auto-policy change ou M3 unblock foi introduzido;
- próxima dívida da Fase 4 ainda não selecionada.

## 2026-10-07 — CP99

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP99.md`;
- ponteiro de continuidade movido para CP99;
- UpdateRiskProfile físico e migration 030 = **TECHNICALLY_VALIDATED**;
- F4-RP-T01–T87 = PASS;
- run canônico **37618433929** (#161) = success;
- artifact **11480858194**;
- rebuild-through-030 = PASS;
- regressões completas = PASS;
- M3 blocker preservado;
- runs #153–#160 classificadas como diagnósticas/não canônicas no Documento 32;
- próxima dívida da Fase 4 ainda não selecionada;
- Fase 5 não iniciada;
- regra de pausa após checkpoint preservada.

## 2026-10-07 — Phase 4 propagation/re-baselining architecture

- selecionada propagation/re-baselining como próxima dívida estrutural após CP99;
- criado o Documento 33 — Arquitetura Transversal de Propagação de Mudanças e Re-baselining;
- separado fan-out de impacto de re-baselining same-entity;
- preservada semântica same-target de supersedes_update_policy_uuid;
- proibido retarget in-place de MonitorTarget;
- definido que novo target M2/M3 requer novo Monitor ProductVersion/binding explícito;
- preservados históricos de UpdateSignal, PriorityAssessment, Escalation, SLA, Workflow e Alert;
- dependency_edge permanece projeção auxiliar, não registro authoritative de decisão;
- nenhuma migration autorizada;
- scheduler, notifications, auto-escalation, numeric SLA e M3 unblock permanecem fora do escopo;
- próximo passo: revisão adversarial do Documento 33.

## 2026-10-07 — Propagation/re-baselining adversarial gate

- criado o Documento 34 — Revisão Adversarial da Arquitetura de Propagação e Re-baselining;
- primeira passagem = **REVISE**;
- Documento 33 foi hardenizado em AR-F4-PR01–PR20;
- maintainable/intermediate targets, missing-policy handling e propagation source adapter foram fechados;
- cardinalidade candidate/path, cycle/depth guard e lineage validation foram fechados;
- old/new target chain, planned/activated rebaseline e concurrency foram fechados;
- cross-target UpdatePolicy lineage permanece separada de same-target supersession;
- new M2/M3 policy exige novo Monitor ProductVersion current e target coerente;
- coverage partitions, risk-profile readiness e SLA Rule/Instance handover foram fechados;
- workflow/priority/escalation históricos permanecem não-retargetáveis;
- authority domain foi explicitado;
- recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY`;
- nenhuma migration foi autorizada;
- M3 blocker preservado;
- próximo passo: Contrato Físico v0.1 + novo gate.

## 2026-10-07 — CP100

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP100.md`;
- ponteiro de continuidade movido para CP100;
- arquitetura de propagation/re-baselining = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- Documento 34 registrou primeira passagem REVISE e recheck final PASS_WITH_ARCHITECTURAL_DECISIONS;
- contrato físico de propagation/re-baselining autorizado apenas para especificação;
- nenhuma migration autorizada;
- M3 blocker preservado;
- último PASS técnico permanece run **37618433929** (#161);
- próximo passo: especificar Contrato Físico v0.1 e executar novo gate;
- Fase 5 não iniciada;
- regra de pausa após checkpoint preservada.

## 2026-10-07 — Propagation/re-baselining physical contract candidate

- criado Documento 35 — Contrato Físico v0.1 de Propagation/Re-baselining;
- normalizados PropagationAssessment/Candidate/Path/PathStep;
- especificado adapter futuro PropagationCandidate → UpdateSignalSource;
- especificado RebaselineDecision e child records explícitos para policy/Monitor/profile/coverage/SLA/signal/workflow;
- definido grandfathering prospectivo sem backfill fabricado;
- definido plano mínimo F4-PRB-T01–T128;
- migration 031 permanece não autorizada;
- M3 blocker preservado;
- próximo passo: gate adversarial/físico do contrato.

## 2026-10-07 — Propagation/re-baselining physical gate

- criado Documento 36 — Gate Adversarial/Físico do contrato;
- primeira passagem física = **REVISE**;
- Documento 35 foi hardenizado para corrigir target eligibility, max_depth, no_action/path completeness, version chain normalizada, lifecycle/concorrência, policy/profile/coverage/signal/SLA grandfathering e causal basis;
- removida invalidação de UpdateSignal apenas por target supersession;
- adicionado contract epoch técnico para grandfathering prospectivo;
- adicionados guards causais para update_decision/workflow/propagation_candidate;
- test plan expandido para **F4-PRB-T01–T145**;
- recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- `MIGRATION_031 = AUTHORIZED_IN_STRICT_SCOPE`;
- M3 blocker preservado;
- próximo passo: implementação mecânica da migration 031 + fixtures/testes/S5;
- modo médio passa a ser suficiente enquanto o escopo permanecer fechado.

## 2026-10-07 — CP101

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP101.md`;
- ponteiro de continuidade movido para CP101;
- contrato físico de propagation/re-baselining = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- F4-PRB-T01–T145 = plano mínimo aprovado;
- migration 031 autorizada em escopo estrito e ainda não implementada;
- M3 blocker preservado;
- último PASS técnico permanece run **37618433929** (#161);
- próximo passo: implementação migration 031 + fixtures/testes/S5;
- modo médio suficiente para implementação mecânica;
- Fase 5 não iniciada;
- regra de pausa após checkpoint preservada.


## 2026-10-07 — Migration 031 technical PASS

- implementada migration lógica `031_propagation_rebaseline_contract.sql` com fragments 031a–031e;
- implementados PropagationAssessment/Candidate/Path/PathStep, RebaselineDecision/chain e child handover validators;
- implementado adapter estruturado PropagationCandidate → UpdateSignalSource;
- adicionadas fixtures sintéticas e suíte **F4-PRB-T01–T145**;
- migration 031 idempotency = **PASS**;
- rebuild-through-031 = **PASS**;
- regressões F4-UP/F4-OC/F4-RP/F2-B/S4/S5/F3/Monitor/Alert = **PASS**;
- S5 run canônico **37644296649** (#167) = success;
- technical HEAD `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- job **112870931087** = success;
- artifact **11494595216**;
- digest `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`;
- runs #163–#166 classificadas como diagnósticas/intermediárias;
- M3 blocker preservado;
- sem numeric SLA/cadence, scheduler, notifications, auto-propagation/rebaseline ou currentness automático;
- próximo passo: checkpoint técnico e seleção explícita da próxima dívida da Fase 4.

## 2026-10-07 — CP102

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP102.md`;
- ponteiro de continuidade movido para CP102;
- migration 031 / propagation-rebaselining físico = **TECHNICALLY_VALIDATED**;
- F4-PRB-T01–T145 = PASS;
- idempotência 031 = PASS;
- rebuild-through-031 = PASS;
- regressões completas = PASS;
- run canônico **37644296649** (#167) = success;
- artifact **11494595216**;
- digest `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`;
- runs #163–#166 permanecem diagnósticas/intermediárias;
- M3 blocker preservado;
- próxima dívida da Fase 4 ainda não selecionada;
- Fase 5 não iniciada;
- regra de pausa após checkpoint preservada.


## 2026-10-07 — Seleção do próximo bloco da Fase 4

- criado Documento 38 — Seleção da Próxima Dívida da Fase 4;
- selecionado **TEMPORAL_CALIBRATION** como próximo bloco;
- bloco permanece **SELECTED_NOT_STARTED**;
- cadence/thresholds normativos e durações SLA devem ser calibrados antes de scheduler/notifications/M3 readiness;
- priority score/pesos não foram promovidos a dívida obrigatória: baseline qualitativo permanece deliberado;
- nenhum número normativo foi definido;
- scheduler/notifications não iniciados;
- auto-escalation continua não autorizada;
- M3 formal continua bloqueado;
- recomendado modo alto antes de iniciar metodologia/calibração.

## 2026-10-07 — CP103

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP103.md`;
- ponteiro de continuidade movido para CP103;
- próximo bloco selecionado = **TEMPORAL_CALIBRATION**;
- bloco permanece **SELECTED_NOT_STARTED**;
- priority score/pesos não são requisito do baseline;
- nenhum número normativo foi definido;
- scheduler/notifications não iniciados;
- auto-escalation continua não autorizada;
- M3 continua bloqueado;
- modo alto recomendado antes da metodologia;
- Fase 5 não iniciada;
- regra de pausa após checkpoint preservada.


## 2026-10-07 — Gate da metodologia de calibração temporal

- Documento 39 criado e hardenizado;
- Documento 40 primeira passagem = **REVISE**;
- recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- metodologia por envelopes preservada sem score aditivo;
- necessidade científica não mapeia automaticamente para intervalos;
- seleção passa a usar constraints + Pareto/dominância;
- source latency não determina cadence isoladamente;
- replay deve incluir censura/missingness/falhas;
- Priority→SLA snapshot temporal fechado;
- provisional calibration permanece fora de rules ativas;
- repeated breach não autoriza relaxamento automático;
- external deadline exige compatibilidade semântica;
- pré-requisitos físicos de cadence/SLA foram identificados;
- autorizada somente a especificação física desses pré-requisitos;
- nenhum numeric cadence/SLA, calendário real, migration 032, scheduler, notifications ou M3 foi autorizado.

## 2026-10-07 — CP104

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP104.md`;
- ponteiro de continuidade movido para CP104;
- metodologia de calibração temporal = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- pré-requisitos físicos = **AUTHORIZED_FOR_SPECIFICATION_ONLY**;
- nenhum numeric cadence/SLA, calendário real ou migration 032 autorizado;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 continua bloqueado;
- último PASS técnico permanece S5 #167;
- próximo passo: especificar contrato físico v0.1 dos pré-requisitos e submeter a novo gate;
- modo alto recomendado;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


## 2026-10-07 — Contrato físico de calibração temporal

- criado Documento 41 — contrato físico v0.1 dos pré-requisitos;
- criado Documento 42 — primeira passagem física = **REVISE**;
- Documento 41 hardenizado;
- Documento 41A incorporado como anexo de auditabilidade;
- Documento 43 = recheck final **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- uploads manuais 41A/43 reconciliados e verificados por blob SHA;
- migration 032 autorizada apenas em escopo estrito de infraestrutura;
- plano mínimo aprovado = **F4-TCAL-PH-T01–T230**;
- nenhum valor real de cadence/SLA/grace/warning/escalation ou calendário real autorizado;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 continua bloqueado;
- próximo passo: implementar migration 032 + fixtures/testes e validar tecnicamente.

## 2026-10-07 — CP105

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP105.md`;
- ponteiro de continuidade movido para CP105;
- contrato físico de calibração temporal = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- migration 032 autorizada somente em escopo estrito de infraestrutura;
- plano mínimo aprovado = **F4-TCAL-PH-T01–T230**;
- nenhum valor normativo real autorizado;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 continua bloqueado;
- próximo passo: implementar migration 032 + fixtures/testes e validar tecnicamente;
- modo médio suficiente para implementação mecânica;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


## 2026-10-07 — Migration 032 technical PASS

- implementada `database/032_temporal_calibration_prerequisites.sql` com fragments 032a–032d;
- adicionadas fixtures sintéticas de cadence e SLA/calendar v0.1;
- adicionada suíte dedicada **F4-TCAL-PH-T01–T230**;
- T01–T230 = **PASS**;
- migration 032 idempotent re-apply = **PASS**;
- rebuild-through-032 = **PASS**;
- regressões F4/F2-B/S4/S5/F3 = **PASS**;
- Documento 44 registra o resultado técnico canônico;
- HEAD técnico: `657c69024fafb6c2e6311d47091d5897730668fd`;
- S5 run `37690201061`, job `113028117278`, conclusion `success`;
- artifact `oes-s5-evidence-37690201061`, ID `11512707774`, 250711 bytes;
- digest `sha256:bb145efb29d7c30e607136defa09c828711162e27ac71a307df229449980f826`;
- nenhum valor temporal normativo real autorizado;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 continua bloqueado;
- Fase 5 não iniciada;
- próximo passo: checkpoint CP106 e retorno metodológico em modo alto antes de qualquer calibração normativa.


## 2026-10-07 — CP106

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP106.md`;
- ponteiro de continuidade movido para CP106;
- migration 032 = **implemented and technically validated**;
- **F4-TCAL-PH-T01–T230 = PASS**;
- idempotência 032 = **PASS**;
- rebuild-through-032 = **PASS**;
- S5 canônico = **PASS**;
- run `37690201061`, job `113028117278`;
- artifact ID `11512707774`, digest `sha256:bb145efb29d7c30e607136defa09c828711162e27ac71a307df229449980f826`;
- valores temporais normativos continuam não autorizados;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 continua bloqueado;
- Fase 5 não iniciada;
- próximo passo: decisão metodológica/governamental em modo alto;
- pausa obrigatória preservada.


## 2026-10-07 — Seleção do sub-bloco de Evidence Readiness

- criado `docs/governance/45-inventario-pos-cp106-selecao-evidence-readiness-calibracao-temporal.md`;
- inventário pós-CP106 confirmou que não há débito estrutural anterior com prioridade superior à trilha de calibração temporal;
- infraestrutura física v0.1 está tecnicamente validada;
- base temporal/operacional disponível no repositório permanece test-only/synthetic para fins de calibração;
- calibração normativa real não pode ser aberta genericamente como `sufficient_for_calibration`;
- próximo sub-bloco selecionado = **TEMPORAL_CALIBRATION_EVIDENCE_READINESS**;
- nenhum valor normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications permanecem dependentes e deferidos;
- auto-escalation não autorizado;
- M3 permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: protocolo de Evidence Readiness v0.1 + gate adversarial, em modo alto.


## 2026-10-07 — CP107

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP107.md`;
- ponteiro de continuidade movido para CP107;
- trilha temporal permanece prioritária;
- calibração normativa real = **BLOCKED_PENDING_REAL_EVIDENCE_READINESS**;
- próximo sub-bloco = **TEMPORAL_CALIBRATION_EVIDENCE_READINESS**;
- Calibration Dossier real ainda não autorizado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: Protocolo de Evidence Readiness v0.1 + gate adversarial;
- pausa obrigatória preservada.


## 2026-10-07 — Evidence Readiness protocol adversarial PASS

- criado Documento 46 — Protocolo de Evidence Readiness para Calibração Temporal v0.1;
- criado Documento 47 — gate adversarial do protocolo;
- primeira passagem = **REVISE**;
- hardening aplicado ao Documento 46;
- recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- READY exige prova positiva de realidade, blocker set vazio e human verification;
- cohort/window/denominator e representatividade ficam explícitos;
- fonte externa material precisa de locator auditável;
- measurement schedule permanece non-normative e não vira policy por inércia;
- drift invalida READY até reassessment;
- first real readiness assessment = autorizado para seleção/execução sob o protocolo;
- Calibration Dossier real continua condicionado a context-specific READY;
- nenhum valor normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada.


## 2026-10-07 — CP108

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP108.md`;
- ponteiro de continuidade movido para CP108;
- Documento 46 = protocolo de Evidence Readiness temporal v0.1;
- Documento 47 = gate adversarial; primeira passagem REVISE, recheck final PASS_WITH_ARCHITECTURAL_DECISIONS;
- first real readiness assessment = autorizado sob protocolo;
- Calibration Dossier real = condicionado a context-specific READY;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: seleção do primeiro exact real context para readiness assessment;
- pausa obrigatória preservada.


## 2026-10-07 — Primeiro Evidence Readiness Assessment real

- criado `docs/governance/48-primeiro-evidence-readiness-assessment-real-n1-cadence.md`;
- primeiro contexto real selecionado: ProductVersion 2 do Caso Real N1-01, cadence readiness em policy_aggregate;
- target real/publicado/A2 confirmado;
- searches e provenance reais preservados;
- fixtures F3/F4 explicitamente excluídas da evidência normativa;
- resultado = **INSUFFICIENT_EVIDENCE**;
- READY_FOR_CALIBRATION = **NO**;
- Calibration Dossier real para o contexto = **NOT_AUTHORIZED**;
- blockers: need evidence/UpdateRiskProfile real, source characterization, prospective observation, authority, feasibility e replay;
- nenhum valor temporal normativo definido;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- próximo passo: decidir entre Temporal Observation Plan não normativo para N1-01 ou segundo readiness assessment real.


## 2026-10-07 — CP109

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP109.md`;
- ponteiro de continuidade movido para CP109;
- primeiro readiness assessment real concluído no N1-01 / ProductVersion 2 / cadence / policy_aggregate;
- resultado = **INSUFFICIENT_EVIDENCE**;
- READY_FOR_CALIBRATION = **NO**;
- Calibration Dossier real para o contexto = **NOT_AUTHORIZED**;
- Temporal Observation Plan ainda não especificado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir entre observation plan não normativo para N1-01 ou segundo readiness assessment real;
- pausa obrigatória preservada.


## 2026-10-07 — Reconciliação do readiness e seleção do segundo contexto real

- criado `docs/governance/49-reconciliacao-selecao-segundo-evidence-readiness-real.md`;
- corrigida prospectivamente, sem reescrever Documento 48, a caracterização incorreta do N2/dCBT-I;
- CP28 e Documentos 66–67 confirmam N2 como A2/published com owner governance approval;
- resultado do primeiro readiness N1-01 preservado: `INSUFFICIENT_EVIDENCE`;
- justificativa comparativa de seleção do Documento 48 = parcialmente corrigida;
- Opção B selecionada antes de Observation Plan prospectivo;
- segundo contexto = N2 Caso Real 01 / ProductVersion `81000000-0000-0000-0000-000000000701` / cadence / policy_aggregate;
- segundo assessment = **SELECTED_NOT_EXECUTED**;
- Temporal Observation Plan N1-01 = deferido até o segundo assessment;
- nenhum valor temporal normativo ou Calibration Dossier real autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos; auto-escalation não autorizada; M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: checkpoint e, em modo alto, executar o segundo Evidence Readiness Assessment real.


## 2026-10-07 — CP110

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP110.md`;
- ponteiro de continuidade movido para CP110;
- divergência factual do Documento 48 reconciliada prospectivamente no Documento 49;
- N1-01 `INSUFFICIENT_EVIDENCE` preservado;
- N2/dCBT-I ProductVersion `81000000-0000-0000-0000-000000000701` selecionado como segundo contexto de cadence readiness;
- segundo assessment ainda não executado;
- Observation Plan N1-01 deferido até o segundo assessment;
- nenhum valor temporal normativo, Calibration Dossier real ou migration nova autorizado;
- scheduler/notifications deferidos; auto-escalation não autorizada; M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: segundo Evidence Readiness Assessment real em modo alto;
- pausa obrigatória preservada.


## 2026-10-07 — Segundo Evidence Readiness Assessment real

- criado `docs/governance/50-segundo-evidence-readiness-assessment-real-n2-cadence.md`;
- contexto = N2 Caso Real 01 / ProductVersion `81000000-0000-0000-0000-000000000701` / cadence / policy_aggregate;
- evidence cut-off = HEAD `98f15efddf5bb2bafa6d71a7dd35cc0a575edaf2`;
- target confirmado A2/published/current;
- 4 Search rows reais em PubMed/MEDLINE, BVS/LILACS e ClinicalTrials.gov;
- 6 SearchHits e 6 ScreeningDecisions persistidos;
- resultado = **INSUFFICIENT_EVIDENCE**;
- READY_FOR_CALIBRATION = **NO**;
- blockers = need evidence, source characterization, prospective observation, human authority, feasibility e replay;
- diversity de fontes de produção não foi tratada como substituto para surveillance longitudinal;
- comparação N1/N2 mostrou recorrência dos blockers centrais;
- terceiro readiness assessment imediato não selecionado;
- próximo problema = desenho de aquisição temporal não normativa;
- nenhum Calibration Dossier, valor temporal normativo ou migration nova autorizado;
- scheduler/notifications deferidos; auto-escalation não autorizada; M3 bloqueado;
- Fase 5 não iniciada.


## 2026-10-07 — CP111

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP111.md`;
- ponteiro movido para CP111;
- Documento 50 consolidado como segundo readiness assessment real;
- N2/dCBT-I = **INSUFFICIENT_EVIDENCE / READY_FOR_CALIBRATION=NO**;
- comparação N1/N2 confirma recorrência de blockers temporais estruturais/operacionais;
- `TWO_REAL_CONTEXTS_ASSESSED = YES`;
- `THIRD_IMMEDIATE_READINESS_ASSESSMENT = NOT_SELECTED`;
- `TEMPORAL_EVIDENCE_ACQUISITION_DESIGN = NEXT_DECISION`;
- nenhum valor temporal normativo, Calibration Dossier real ou migration nova autorizado;
- scheduler/notifications deferidos; auto-escalation não autorizada; M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir em modo alto entre plano transversal reutilizável + instância piloto versus plano inicialmente específico de um target;
- pausa obrigatória preservada.


## 2026-10-07 — Arquitetura de aquisição de evidência temporal não normativa

- criado Documento 51 com arquitetura candidata `REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE`;
- criado Documento 52; primeira passagem adversarial = **REVISE**;
- hardening aplicado ao Documento 51 para shadow-M2, storage semantics, latency endpoints, authority, outcome model, drift, stopping, data governance e anti-anchoring;
- criado Documento 53; recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- primeira Observation Plan Instance = autorizada apenas para seleção/especificação;
- observação prospectiva real continua não autorizada;
- M1 pilot não é Monitor e não usa MonitoringCycle;
- pre-calibration measurement não usa CadenceObservation;
- semantic storage mapping obrigatório;
- authority humana explícita obrigatória antes de execução;
- Result Package deve retornar a novo Evidence Readiness antes de qualquer Calibration Dossier;
- novo physical contract fica deferido até lacuna material comprovada pela instância;
- nenhum valor normativo ou migration nova autorizado;
- scheduler/notifications deferidos; auto-escalation não autorizada; M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: checkpoint e seleção/especificação do primeiro target piloto em modo alto.


## 2026-10-07 — CP112

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP112.md`;
- ponteiro movido para CP112;
- Documentos 51–53 consolidam arquitetura de aquisição temporal não normativa;
- first pass adversarial = REVISE; recheck final = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- arquitetura escolhida = protocolo transversal reutilizável + instância target/source-specific;
- primeira instância autorizada somente para seleção/especificação;
- execução prospectiva real continua não autorizada;
- semantic storage mapping, Observation Epoch e authority humana explícita obrigatórios;
- M1 pilot não é Monitor e pre-calibration measurement não usa CadenceObservation;
- physical contract/migration nova deferidos até necessidade material comprovada;
- nenhum valor temporal normativo autorizado;
- scheduler/notifications deferidos; auto-escalation não autorizada; M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: selecionar N1-01 ou N2/dCBT-I e especificar a primeira instância piloto, em modo alto;
- pausa obrigatória preservada.


## 2026-10-07 — Primeira Temporal Observation Plan Instance

- criado Documento 54: N2/dCBT-I selecionado como primeiro target da TOPI;
- escolha baseada em information gain, source complexity, cost, storage semantics, authority, data governance e overfitting;
- TOPI-N2-DCBTI-01 especificada em Phase A e Phase B;
- Phase A = characterization/authority/data-governance/risk-profile evidence preparation;
- Phase B bloqueada até Result Package + amendment v0.2 + recheck;
- measurement schedule não selecionada para evitar anchoring antes de source characterization;
- criado Documento 55: gate target-specific = **PASS_FOR_AUTHORITY_REQUEST_ONLY**;
- Phase A specification = PASS; execution ainda bloqueada;
- criado Documento 56: pacote de decisão de authority;
- `AUTHORITY_DECISION = PENDING`;
- mensagens genéricas não valem como approval do Documento 56;
- nenhuma source interaction real autorizada;
- nenhum valor temporal normativo ou migration nova autorizado;
- Phase B, scheduler, notifications, auto-escalation e M3 permanecem bloqueados;
- Fase 5 não iniciada.


## 2026-10-07 — CP113

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP113.md`;
- ponteiro movido para CP113;
- TOPI-N2-DCBTI-01 = primeira instância temporal não normativa selecionada;
- Documento 55 = PASS_FOR_AUTHORITY_REQUEST_ONLY;
- Documento 56 = authority package pendente de decisão explícita;
- Phase A execution não autorizada; Phase B bloqueada;
- measurement schedule não selecionada;
- nenhuma source interaction real autorizada antes da decisão;
- nenhum valor temporal normativo ou migration nova autorizado;
- Fase 5 não iniciada;
- próximo passo: decisão explícita APPROVED / REVISE / REJECTED sobre Phase A / Documento 56;
- modo médio suficiente após a decisão salvo nova complexidade arquitetural/metodológica;
- pausa obrigatória preservada.


## 2026-10-07 — TOPI-N2-DCBTI-01 Phase A

- owner aprovou explicitamente Phase A / Documento 56 / TOPI-N2-DCBTI-01;
- criado Documento 57 registrando operational execution authority;
- executada somente Phase A autorizada;
- criado Documento 58 — Phase A Characterization Package;
- PubMed caracterizado com E-utilities, CRDT/EDAT e controles de acesso/uso;
- BVS/LILACS caracterizado parcialmente; portal/IAHx/FI-Admin e record dates documentados, mas acesso programático público reproduzível ainda não estabelecido;
- ClinicalTrials.gov caracterizado com API v2 REST/OpenAPI/JSON e posting-date fields;
- limitações do canal de ferramenta não foram reclassificadas como source failures;
- UpdateRiskProfile permanece evidence-preparation only;
- measurement schedule permanece NOT_SELECTED;
- Phase B continua não autorizada;
- nenhum valor temporal normativo, Calibration Dossier, UpdatePolicy, Monitor ou migration nova;
- próximo passo: Plan Amendment v0.2 + novo gate + nova authority antes de qualquer Phase B.


## 2026-10-07 — CP114

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP114.md`;
- ponteiro movido para CP114;
- Documento 57 registra owner APPROVED para Phase A;
- Documento 58 conclui Phase A com source-specific limitations;
- PubMed e ClinicalTrials.gov seguem para desenho potencial de Phase B sob controles;
- BVS/LILACS permanece parcial e bloqueado para repeated programmatic measurement até resolução do access path ou desenho manual explícito;
- UpdateRiskProfile permanece evidence-preparation only;
- measurement schedule não selecionada;
- Phase B não autorizada;
- nenhum normative temporal value ou migration nova;
- M3 bloqueado; Fase 5 não iniciada;
- próximo passo: Plan Amendment v0.2 em modo alto;
- pausa obrigatória preservada.


## 2026-10-07 — TOPI Plan Amendment v0.2 / Phase B boundary

- criado Documento 59 — Plan Amendment v0.2 candidate;
- PubMed + ClinicalTrials.gov selecionados como candidate sources da Phase B;
- BVS/LILACS mantido como `DEFERRED_SOURCE_DEBT`, sem completeness claim;
- event model definido como source-specific non-normative measurement event;
- physical gap confirmado para repeated pre-calibration measurement;
- Artifact-only storage rejeitado como event store suficiente;
- Search, EvidenceEvent e CadenceObservation rejeitados como substitutos semânticos;
- measurement schedule permanece deferido;
- criado Documento 60 — recheck = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- physical contract autorizado somente para specification;
- migration, Phase B authority e Phase B execution continuam não autorizados;
- nenhum valor temporal normativo autorizado;
- M3 bloqueado; Fase 5 não iniciada.


## 2026-10-07 — CP115

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP115.md`;
- ponteiro movido para CP115;
- Documento 59 = Plan Amendment v0.2;
- Documento 60 = PASS_WITH_ARCHITECTURAL_DECISIONS;
- Phase B candidate sources = PubMed + ClinicalTrials.gov;
- BVS/LILACS = deferred source debt;
- physical gap para repeated pre-calibration measurement confirmado;
- physical contract autorizado apenas para specification;
- measurement schedule continua não selecionado;
- Phase B authority/execution e migration continuam não autorizados;
- nenhum valor temporal normativo autorizado;
- M3 bloqueado; Fase 5 não iniciada;
- próximo passo: physical contract v0.1 + test plan + gate adversarial em modo alto;
- pausa obrigatória preservada.
