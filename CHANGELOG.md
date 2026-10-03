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

