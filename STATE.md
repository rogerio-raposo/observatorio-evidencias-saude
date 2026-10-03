# STATE — Estado Atual do Projeto OES

**Última atualização:** 3 de outubro de 2026  
**Fase:** Fase 0 — Concepção e fundamentos metodológicos  
**Status geral:** em desenvolvimento

## 1. Fonte canônica

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

As conversas podem ser usadas para desenvolver, discutir e revisar conteúdo, mas decisões persistentes devem ser consolidadas nos documentos do repositório.

## 2. Documentos consolidados até o momento

### Governança / fundamentos

- 00 — Documento de Concepção
- 01 — Escopo Científico e Taxonomia das Perguntas
- 02 — Arquitetura de Níveis de Investigação e Produtos
- 03 — Protocolo de Entrada, Triagem e Roteamento Metodológico

### Metodologia

- 10 — Protocolo de Busca e Recuperação de Evidências

### Estrutura operacional

- Question Record
- Routing Record
- Search Record
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
- busca científica deverá ser auditável;
- IA apoia, mas não é fonte de evidência científica;
- o repositório, e não a memória da conversa, é o registro persistente do projeto.

## 4. Próxima etapa

**11 — Protocolo de Elegibilidade, Triagem e Seleção de Evidências**

Deverá definir:

- critérios de inclusão e exclusão;
- triagem por título/resumo;
- avaliação de texto completo;
- dupla triagem e verificações proporcionais por N0–N4;
- resolução de discordâncias;
- uso de IA na triagem;
- motivos de exclusão;
- fluxo PRISMA;
- vinculação de múltiplos relatórios ao mesmo Study ID.

## 5. Etapas metodológicas seguintes

Depois do documento 11:

- 12 — Avaliação de Risco de Viés
- 13 — Extração de Dados
- 14 — Síntese de Evidências
- 15 — Certeza/Confiança na Evidência

Somente depois deverá ser consolidado o modelo de dados e aprofundada a arquitetura tecnológica.

## 6. Questões ainda provisórias

- nomenclatura final dos produtos;
- critérios operacionais precisos para descritores baixa/moderada/alta no roteamento;
- instrumentos específicos para prevalência/incidência e pesquisa qualitativa;
- regras finais para avaliação de revisões sistemáticas existentes;
- gatilhos quantitativos/operacionais de atualização;
- especificação definitiva da Ficha de Evidência;
- política formal de versionamento dos produtos.

## 7. Regra de retomada

Ao retomar o projeto em nova conversa ou sessão:

1. consultar README.md;
2. consultar este STATE.md;
3. consultar o documento metodológico diretamente relacionado à próxima tarefa;
4. verificar CHANGELOG.md quando houver dúvida sobre decisões anteriores;
5. atualizar este arquivo ao encerrar um novo marco metodológico.

## 8. Checkpoint atual

**Checkpoint OES-CP-001**

Cobertura:

- concepção;
- taxonomia;
- níveis e produtos;
- roteamento;
- busca e recuperação;
- estrutura inicial do repositório.

Próximo ponto de trabalho:

**Elegibilidade, Triagem e Seleção de Evidências.**
