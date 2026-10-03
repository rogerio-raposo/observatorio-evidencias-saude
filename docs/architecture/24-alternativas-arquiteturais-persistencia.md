# 24 — Alternativas Arquiteturais de Persistência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — análise arquitetural  
**Data:** 3 de outubro de 2026  
**Gate de entrada:** GATE F2-A aprovado  
**Dependências:** Documentos 20–23

## 1. Finalidade

Comparar alternativas de persistência para o OES antes da elaboração do primeiro desenho físico candidato.

A escolha deve ser guiada pelos requisitos metodológicos, não por preferência tecnológica.

Critérios principais:

- integridade referencial;
- relações N:M;
- transações;
- versionamento;
- proveniência;
- auditabilidade;
- flexibilidade para instrumentos diferentes;
- consultas de dependência;
- capacidade de evolução;
- armazenamento de artefatos;
- complexidade operacional;
- reversibilidade.

---

# PARTE I — REQUISITOS DERIVADOS DO MÉTODO

## 2. Requisitos de integridade forte

O OES contém relações em que inconsistência estrutural não é aceitável:

- Result → Study;
- Study ↔ Report;
- Result → Outcome;
- Result ↔ Synthesis;
- Certainty → Synthesis/ReviewFinding;
- Product → versões específicas de Synthesis/Certainty;
- versionamento e supersessão;
- deduplicação e merges auditáveis.

Essas relações favorecem mecanismos explícitos de chave, unicidade e integridade referencial.

## 3. Requisitos de flexibilidade

Algumas estruturas variam conforme o método:

- domínios de RoB 2, ROBINS-I, QUADAS-3, PROBAST+AI etc.;
- parâmetros de síntese;
- detalhes de métodos especializados;
- metadados de busca;
- proveniência adicional;
- futuros campos de aplicabilidade.

O modelo precisa evoluir sem converter toda variação metodológica em migração estrutural imediata.

## 4. Requisitos de artefatos

O sistema deverá referenciar arquivos que não devem ser armazenados como linhas relacionais comuns:

- PDFs;
- exports bibliográficos;
- datasets;
- scripts;
- gráficos;
- tabelas;
- anexos;
- snapshots;
- relatórios gerados.

## 5. Requisitos de travessia de dependências

Perguntas futuras incluem:

- quais Products dependem de um Report retratado?
- quais Syntheses usam determinado Result?
- quais Certainty Assessments dependem de determinada Synthesis?
- quais Reports pertencem ao mesmo Study?
- quais versões foram superseded?
- qual caminho liga uma nova evidência a uma conclusão publicada?

Esse comportamento possui natureza de grafo, mesmo que a fonte canônica não seja um banco de grafo.

---

# PARTE II — OPÇÃO A: RELACIONAL

## 6. Descrição

Entidades e relações centrais são representadas em tabelas com:

- chaves primárias;
- chaves estrangeiras;
- constraints;
- tabelas associativas;
- transações;
- índices.

## 7. Vantagens para o OES

- forte integridade referencial;
- representação natural das cardinalidades já definidas;
- transações para atualizações coerentes;
- excelente suporte a auditabilidade;
- esquema explícito;
- consultas analíticas maduras;
- versionamento modelável de forma transparente.

## 8. Limitações

- instrumentos metodológicos altamente variáveis podem gerar muitas tabelas ou colunas;
- evolução de estruturas especializadas exige migrações;
- travessias profundas de dependência podem ser menos naturais que em grafo;
- não é adequado como armazenamento primário de arquivos grandes.

## 9. Avaliação

**Adequação: ALTA para o núcleo canônico.**

---

# PARTE III — OPÇÃO B: DOCUMENTAL

## 10. Descrição

Entidades são armazenadas como documentos flexíveis, com subdocumentos e arrays.

## 11. Vantagens

- flexibilidade de schema;
- boa representação de objetos compostos;
- facilidade para payloads heterogêneos;
- evolução rápida de campos opcionais;
- estruturas metodológicas podem ser mantidas próximas ao formato de origem.

## 12. Limitações para o OES

- muitas relações do OES são N:M e atravessam objetos independentes;
- duplicar subdocumentos aumenta risco de divergência;
- referências entre entidades exigem disciplina adicional;
- versionamento transversal e impacto de retração atravessam muitos documentos;
- integridade de domínio pode migrar para lógica de aplicação.

Bancos documentais modernos oferecem validação de schema e transações multi-documento, mas o modelo flexível continua deslocando parte relevante da disciplina estrutural para o desenho da aplicação.

## 13. Avaliação

**Adequação: MÉDIA como fonte canônica; ALTA para payloads flexíveis específicos.**

---

# PARTE IV — OPÇÃO C: GRAFO

## 14. Descrição

Entidades são nós; relações metodológicas e de dependência são arestas explícitas.

## 15. Vantagens

- excelente para navegar dependências;
- relações de Study/Report/Result/Synthesis/Certainty/Product são intuitivas;
- análise de impacto de correção/retração é natural;
- consultas de caminhos são expressivas;
- adequado a futuros mapas de conhecimento.

## 16. Limitações

- maior complexidade operacional se usado como fonte única;
- estruturas tabulares/estatísticas e versionamento detalhado podem ser menos naturais;
- constraints existem, mas o contrato relacional do OES já está fortemente estruturado;
- risco de manter duas verdades se grafo for adicionado prematuramente a outro banco.

## 17. Avaliação

**Adequação: ALTA como projeção de dependências; MÉDIA como única fonte canônica.**

---

# PARTE V — OPÇÃO D: HÍBRIDA

## 18. Descrição

Arquitetura em camadas:

1. **núcleo relacional canônico** para entidades, relações, versões e proveniência;
2. **campos documentais controlados** para payloads metodológicos variáveis;
3. **object storage** para arquivos e artefatos;
4. **projeções especializadas opcionais** para busca, grafo ou analytics.

## 19. Princípio de fonte de verdade

Somente um componente será canônico para os dados estruturados.

Projeções:

- são reconstruíveis;
- não recebem edição primária;
- possuem origem/versionamento;
- podem ser descartadas e regeneradas.

## 20. Vantagens

- preserva integridade relacional;
- acomoda flexibilidade sem fragmentar o sistema;
- separa arquivos volumosos de metadados;
- permite adicionar grafo ou índice de busca apenas quando houver caso de uso;
- reduz lock-in conceitual;
- facilita evolução incremental.

## 21. Desvantagens

- exige disciplina de fronteira entre dado canônico e payload flexível;
- pode se tornar complexo se múltiplas projeções forem introduzidas cedo;
- sincronização precisa ser controlada quando houver componentes derivados.

## 22. Avaliação

**Adequação: MUITO ALTA como arquitetura candidata.**

---

# PARTE VI — REFERÊNCIA RELACIONAL CANDIDATA

## 23. PostgreSQL como referência de prova arquitetural

Sem constituir ainda decisão de stack, PostgreSQL é uma referência útil para testar o desenho físico candidato porque oferece simultaneamente:

- primary/foreign keys, unique e check constraints;
- transações;
- tipos JSON/JSONB;
- indexação de JSONB;
- SQL/JSON;
- tipos UUID;
- recursos de busca textual;
- extensibilidade.

Isso permite testar um padrão:

**relacional para invariantes + JSONB para extensões controladas**

sem introduzir um banco documental separado na primeira implementação.

## 24. Uso proposto de JSONB

JSONB poderá ser considerado para:

- payload do instrumento metodológico;
- parâmetros de software;
- detalhes específicos de métodos;
- metadados externos não normalizados;
- extensões futuras.

JSONB **não deverá substituir** entidades e relações centrais apenas para evitar modelagem.

Não colocar em JSONB, como regra:

- Study ID;
- Report ID;
- Result ID;
- Synthesis ID;
- Certainty ID;
- relações N:M críticas;
- estados de versionamento;
- provenance links críticos.

## 25. Documentos de referência

PostgreSQL — JSON/JSONB:
https://www.postgresql.org/docs/current/datatype-json.html

PostgreSQL — constraints:
https://www.postgresql.org/docs/current/ddl-constraints.html

PostgreSQL — SQL/JSON:
https://www.postgresql.org/docs/current/functions-json.html

MongoDB — schema validation:
https://www.mongodb.com/docs/manual/core/schema-validation/

Neo4j — graph database:
https://neo4j.com/docs/getting-started/graph-database/

Neo4j — constraints:
https://neo4j.com/docs/cypher-manual/current/schema/constraints/

---

# PARTE VII — ARQUITETURA CANDIDATA

## 26. Decisão arquitetural candidata

> **OES-H1 — Núcleo Relacional + Extensões Documentais Controladas + Object Storage + Projeções Opcionais**

Estado:

**CANDIDATA PARA PROVA DE ARQUITETURA — NÃO DEFINITIVA**

## 27. Camada canônica

Deverá conter:

- IDs;
- entidades;
- relacionamentos;
- versionamento;
- proveniência;
- decisões metodológicas estruturadas;
- links para artefatos.

## 28. Camada documental controlada

Usada somente quando a estrutura:

- é dependente de ferramenta/metodologia;
- possui variabilidade legítima;
- não constitui relação canônica;
- precisa evoluir sem remodelagem frequente.

Todo payload deverá possuir:

- tipo;
- schema/version;
- origem;
- validação.

## 29. Object storage

Armazenará bytes/arquivos.

O banco canônico armazenará:

- Artifact ID;
- URI/chave;
- hash;
- MIME type;
- tamanho;
- origem;
- versão;
- data;
- relação com entidade/processo.

## 30. Projeção de grafo

Não será componente obrigatório inicial.

Poderá ser criada se surgirem necessidades de:

- análise de impacto;
- exploração de redes de evidência;
- visualização de dependências;
- knowledge graph;
- consultas de caminhos complexos.

A projeção deverá ser reconstruível a partir do núcleo canônico.

---

# PARTE VIII — MATRIZ DE DECISÃO

## 31. Avaliação qualitativa

| Critério | Relacional | Documental | Grafo | Híbrida OES-H1 |
|---|---|---|---|---|
| Integridade referencial | Alta | Média | Média/Alta | Alta |
| N:M estruturado | Alta | Média | Alta | Alta |
| Flexibilidade de payload | Média | Alta | Alta | Alta |
| Versionamento auditável | Alta | Média/Alta | Média/Alta | Alta |
| Proveniência por campo | Alta | Alta | Alta | Alta |
| Travessia de dependências | Média/Alta | Média | Muito alta | Alta, expansível |
| Estatística/analytics | Alta | Média | Média | Alta |
| Artefatos binários | Baixa | Baixa/Média | Baixa | Alta via object storage |
| Complexidade inicial | Baixa/Média | Média | Média/Alta | Média |
| Evolução incremental | Alta | Alta | Alta | Muito alta |
| Risco de múltiplas fontes de verdade | Baixo | Baixo | Baixo | Controlável se projeções forem read-only |

A matriz é arquitetural, não um score quantitativo.

---

# PARTE IX — REGRAS DE ADOÇÃO

## 32. O que fica decidido

1. a fonte canônica estruturada deve priorizar integridade relacional;
2. flexibilidade documental será complementar, não substituta do modelo;
3. artefatos binários ficarão fora das tabelas de domínio;
4. projeções especializadas devem ser derivadas;
5. grafo não será introduzido sem caso de uso;
6. a arquitetura candidata OES-H1 será utilizada para o primeiro desenho físico;
7. PostgreSQL poderá ser usado como **referência de prova**, sem decisão definitiva de stack.

## 33. O que não fica decidido

- provedor cloud;
- SGBD definitivo;
- serviço de object storage;
- motor de busca;
- banco de grafo;
- linguagem de backend;
- framework de API;
- ferramenta de workflow.

---

# PARTE X — PRÓXIMA ETAPA

Elaborar o **Documento 25 — Primeiro Desenho Físico Candidato**, usando OES-H1 como referência.

O desenho deverá incluir:

- schemas/lógicas de namespace;
- tabelas centrais;
- tabelas associativas;
- estratégia de IDs;
- versionamento;
- provenance;
- artifacts;
- JSONB/extensões controladas;
- constraints;
- índices candidatos;
- views de estado vigente;
- mecanismo de projeções derivadas;
- regras de migração.

---

**Documento vivo. OES-H1 é arquitetura candidata, não stack definitiva.**
