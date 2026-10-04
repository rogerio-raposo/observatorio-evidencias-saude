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
