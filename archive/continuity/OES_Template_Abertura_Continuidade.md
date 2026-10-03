# OES — Template Canônico de Abertura e Continuidade

**Status:** artefato operacional  
**Finalidade:** inicialização controlada de novas conversas e retomada controlada do desenvolvimento do Observatório de Evidências em Saúde — OES.

O repositório `rogerio-raposo/observatorio-evidencias-saude`, branch `main`, é a fonte documental persistente do projeto.

Este template possui dois modos:

- **Modo Partida:** quando não existe checkpoint/handoff válido para o escopo em questão;
- **Modo Continuidade:** quando existe checkpoint vigente indicado pelo ponteiro operacional.

---

## 1. Regras gerais

Antes de iniciar desenvolvimento, revisão ou alteração:

1. consulte o `README.md`;
2. consulte o `STATE.md` como painel de estado vivo;
3. identifique os documentos canônicos relacionados à tarefa;
4. diferencie rigorosamente:
   - decisões consolidadas;
   - hipóteses/propostas;
   - questões provisórias;
   - pendências;
   - trabalho futuro;
5. não trate memória do ChatGPT como fonte normativa;
6. não preencha lacunas documentais por inferência silenciosa;
7. não atribua versão formal, aprovação ou status normativo sem base documental;
8. se houver conflito, a documentação canônica vigente prevalece sobre checkpoints operacionais.

---

## 2. Modo Partida

Use quando não houver checkpoint válido para o escopo.

Antes de produzir novo conteúdo metodológico, apresente um **Diagnóstico de Partida**, contendo:

- documentos canônicos existentes;
- decisões já consolidadas;
- estado atual do projeto;
- pendências relevantes;
- questões provisórias;
- dependências;
- ponto seguro para início do trabalho.

Somente após o diagnóstico o desenvolvimento deve prosseguir.

---

## 3. Modo Continuidade

Use quando houver checkpoint vigente.

Arquitetura:

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

Procedimento:

1. consulte o ponteiro operacional em `archive/handoffs/oes/README.md`;
2. leia integralmente o checkpoint vigente indicado;
3. identifique o estado documental e o ponto exato de retomada registrados;
4. aplique o **Freshness Gate**;
5. apresente o **Diagnóstico de Continuidade**;
6. somente então retome o desenvolvimento.

---

## 4. Freshness Gate

Antes de aceitar um checkpoint como base atual:

1. compare a base temporal/documental do checkpoint com a branch `main`;
2. verifique alterações posteriores nos documentos canônicos relacionados ao escopo;
3. verifique alterações em `README.md`, `STATE.md` e `CHANGELOG.md` que possam mudar o estado do projeto;
4. diferencie alterações:
   - editoriais;
   - operacionais;
   - metodologicamente materiais;
5. identifique decisões posteriores que substituam ou modifiquem o checkpoint;
6. não invalide o checkpoint por alterações posteriores irrelevantes;
7. se houver alteração material, registre explicitamente o impacto antes de retomar.

---

## 5. Diagnóstico de Continuidade

Apresente, antes de prosseguir:

### A. Base do checkpoint confirmada

Decisões, definições, pendências e fronteiras que continuam compatíveis com a documentação atual.

### B. Alterações posteriores

Arquivos, decisões ou mudanças de estado posteriores ao checkpoint que afetem o escopo.

### C. Divergências e impactos

Conflitos entre checkpoint e documentação atual, itens que exigem reabertura e questões ainda indeterminadas.

### D. Ponto exato de retomada

A etapa a partir da qual o trabalho pode continuar sem repetir etapas já validadas.

Se não houver alteração material, registrar explicitamente:

> **Checkpoint vigente confirmado; nenhuma alteração material identificada pelo Freshness Gate.**

---

## 6. Política de checkpoint

Checkpoints do OES são:

- **snapshots autônomos e imutáveis** do estado de trabalho;
- artefatos **operacionais, não normativos**;
- preservados para auditoria;
- encadeados por referência ao checkpoint anterior;
- substituídos operacionalmente apenas pela atualização do ponteiro `archive/handoffs/oes/README.md`.

Regras:

- não sobrescrever silenciosamente checkpoint publicado;
- correção material exige novo checkpoint;
- um novo checkpoint não precisa repetir todo o histórico;
- o checkpoint deve registrar apenas o necessário para retomada segura;
- o ponteiro é o único local que indica qual checkpoint é vigente;
- o prompt operacional de retomada permanece apenas no ponteiro;
- documentação canônica posterior e de maior autoridade prevalece em caso de conflito.

---

## 7. Conteúdo mínimo de um checkpoint

Cada checkpoint deve conter:

- data;
- identificador CP;
- checkpoint anterior;
- status;
- escopo;
- base documental considerada;
- decisões consolidadas desde o checkpoint anterior;
- hipóteses/propostas ainda não normativas;
- pendências;
- arquivos canônicos relevantes;
- alterações que não devem ser reabertas sem motivo;
- ponto exato de retomada;
- referência estável ao ponteiro operacional.

---

## 8. Quando criar um checkpoint

Criar checkpoint quando houver pelo menos uma destas situações:

- conclusão de uma etapa metodológica relevante;
- conjunto significativo de decisões já estável;
- mudança de fase;
- interrupção provável após trabalho substancial;
- aumento de complexidade que torne arriscada a retomada apenas por memória;
- antes de iniciar etapa com dependências importantes;
- antes de migrar a continuidade para outra conversa.

Não é necessário criar checkpoint para pequenas correções editoriais.

---

## 9. Prompt mínimo

### Modo Partida

> Consulte no repositório do Observatório de Evidências em Saúde o arquivo `archive/continuity/OES_Template_Abertura_Continuidade.md` e utilize-o em **Modo Partida** para recuperar o estado documental antes de iniciar o trabalho.

### Modo Continuidade

> Consulte no repositório do Observatório de Evidências em Saúde o arquivo `archive/continuity/OES_Template_Abertura_Continuidade.md` e utilize-o em **Modo Continuidade**. Consulte `archive/handoffs/oes/README.md` para identificar o checkpoint vigente, aplique o Freshness Gate, apresente o Diagnóstico de Continuidade e retome somente do ponto exato confirmado.

---

## 10. Hierarquia operacional

`Documentação canônica → Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico → retomada`

O checkpoint preserva continuidade operacional; não substitui a documentação metodológica oficial.
