# STATE — Estado Atual do Projeto OES

**Última atualização:** 3 de outubro de 2026  
**Fase:** Fase 2 — Modelo de Dados da Evidência  
**Status geral:** em desenvolvimento

## 1. Fonte canônica

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

As conversas podem ser usadas para desenvolver, discutir e revisar conteúdo, mas decisões persistentes devem ser consolidadas nos documentos do repositório.

### Continuidade formal

O STATE.md é um **painel vivo** e pode ser atualizado.

A continuidade formal utiliza checkpoints imutáveis em:

`archive/handoffs/oes/`

Ponteiro vigente:

`archive/handoffs/oes/README.md`

Template canônico:

`archive/continuity/OES_Template_Abertura_Continuidade.md`

## 2. Documentos consolidados até o momento

### Governança / fundamentos

- 00 — Documento de Concepção
- 01 — Escopo Científico e Taxonomia das Perguntas
- 02 — Arquitetura de Níveis de Investigação e Produtos
- 03 — Protocolo de Entrada, Triagem e Roteamento Metodológico

### Metodologia

- 10 — Protocolo de Busca e Recuperação de Evidências
- 11 — Protocolo de Elegibilidade, Triagem e Seleção de Evidências
- 12 — Protocolo de Avaliação de Risco de Viés e Qualidade Metodológica
- 13 — Protocolo de Extração e Estruturação de Dados
- 14 — Protocolo de Síntese de Evidências
- 15 — Protocolo de Avaliação da Certeza/Confiança no Corpo de Evidências

### Arquitetura e dados

- 20 — Modelo Conceitual de Dados do OES
- 21 — Modelo Lógico de Dados do OES
- 22 — Validação Arquitetural por Casos de Uso
- 23 — Checagem de Integridade do Modelo de Dados
- 24 — Alternativas Arquiteturais de Persistência
- 25 — Primeiro Desenho Físico Candidato
- 26 — PoC-S1: Validação do Schema Mínimo

### Estrutura operacional

- Question Record
- Routing Record
- Search Record
- Screening Record
- Risk of Bias / Critical Appraisal Record
- Data Extraction Record
- Synthesis Record
- Certainty Assessment Record
- Índice de fontes metodológicas

## 3. Decisões arquiteturais já firmadas

- metodologia antes da automação;
- pergunta formalizada antes da busca definitiva;
- nenhuma pirâmide universal de evidência;
- risco de viés e certeza do corpo de evidências são processos distintos;
- profundidade N0–N4 e manutenção M0–M3 são dimensões independentes;
- Ficha de Evidência é candidata à unidade persistente central;
- roteamento sem score numérico nesta fase;
- toda decisão de roteamento exige justificativa textual;
- estudo e publicação são entidades distintas;
- Study, Report e Result são entidades distintas na extração;
- valor originalmente relatado e valor derivado devem permanecer separados;
- dados críticos devem manter proveniência rastreável;
- busca científica deverá ser auditável;
- certeza do corpo de evidências será avaliada de forma explícita e rastreável;
- GRADE será a referência central quando aplicável, com CERQual separado para achados qualitativos;
- aplicabilidade ao Brasil não será confundida automaticamente com indirectness;
- certeza permanecerá separada de recomendação;
- IA apoia, mas não é fonte de evidência científica;
- o repositório, e não a memória da conversa, é o registro persistente do projeto.

## 4. Próxima etapa

**Trilha B enquanto o GATE F2-B aguarda execução PostgreSQL.**

Próximo trabalho:

- plano formal de testes do F2-B;
- política de identidade e IDs;
- política de versionamento;
- política de proveniência;
- desenho de migrações;
- extensão controlada para Search/Screening/RiskAssessment.

## 5. Gate arquitetural

**GATE F2-A — Modelo Lógico Candidato: APROVADO**, com reservas metodológicas explícitas.

Arquiteturas candidatas:

- **OES-H1** — persistência híbrida com núcleo relacional canônico;
- **OES-P1** — primeiro desenho físico candidato.

## 6. Estado das fases

- Fase 0 — Concepção e fundamentos: base inicial consolidada como documentação viva;
- Fase 1 — Manual Metodológico: base inicial dos Documentos 10–15 consolidada;
- Fase 2 — Modelo de Dados da Evidência: em desenvolvimento;
- Fases 3–7: ainda não iniciadas formalmente.

## 7. Questões ainda provisórias

- nomenclatura final dos produtos;
- critérios operacionais precisos para descritores baixa/moderada/alta no roteamento;
- instrumentos específicos para prevalência/incidência e pesquisa qualitativa;
- regras finais para avaliação de revisões sistemáticas existentes;
- gatilhos quantitativos/operacionais de atualização;
- especificação definitiva da Ficha de Evidência;
- política formal de versionamento dos produtos.

## 8. Regra de retomada

Ao retomar o projeto em nova conversa ou sessão:

1. consultar README.md;
2. consultar este STATE.md;
3. consultar o documento metodológico diretamente relacionado à próxima tarefa;
4. verificar CHANGELOG.md quando houver dúvida sobre decisões anteriores;
5. atualizar este arquivo ao encerrar um novo marco metodológico.

## 9. Checkpoint atual

**CP11 — 2026-10-03**

Arquivo canônico do checkpoint:

`archive/handoffs/oes/OES_Continuidade_2026-10-03_CP11.md`

O checkpoint é imutável e operacional; este STATE.md permanece atualizável.

Cobertura:

- concepção;
- taxonomia;
- níveis e produtos;
- roteamento;
- busca e recuperação;
- elegibilidade, triagem e seleção;
- avaliação de risco de viés e qualidade metodológica;
- extração e estruturação de dados;
- síntese de evidências;
- avaliação da certeza/confiança no corpo de evidências;
- modelo conceitual de dados;
- modelo lógico de dados;
- validação arquitetural e gate F2-A;
- alternativas de persistência OES-H1;
- desenho físico candidato OES-P1;
- PoC-S1 criada e estaticamente validada;
- GATE F2-B pendente;
- estrutura inicial do repositório.

Próximo ponto de trabalho:

**Trilha B documental enquanto F2-B permanece pendente.**
