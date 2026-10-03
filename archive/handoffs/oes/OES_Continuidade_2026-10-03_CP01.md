# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Metodológica

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP01  
**Checkpoint anterior:** nenhum  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — concepção e fundamentos metodológicos  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP01

O projeto possui repositório GitHub próprio e passou a utilizar documentação persistente como fonte canônica.

Estado metodológico:

> **Fase 0 — Concepção e fundamentos: EM DESENVOLVIMENTO**  
> **Documentos 00–03: CONSOLIDADOS COMO DOCUMENTOS VIVOS**  
> **Documento 10 — Busca e Recuperação: CONSOLIDADO COMO DOCUMENTO VIVO**  
> **Documento 11 — Elegibilidade, Triagem e Seleção: NÃO INICIADO**  
> **Automação/implementação tecnológica: ADIADA ATÉ ESTABILIZAÇÃO METODOLÓGICA**

Base documental observada antes da criação do mecanismo formal de continuidade:

`main @ 191ddbb530a6f749c0887c8099f1599347e92147`

---

# 2. Documentação canônica existente

## Governança e fundamentos

- `docs/governance/00-documento-de-concepcao.md`
- `docs/governance/01-taxonomia-perguntas.md`
- `docs/governance/02-niveis-investigacao-produtos.md`
- `docs/governance/03-roteamento-metodologico.md`

## Metodologia

- `docs/methodology/10-busca-recuperacao-evidencias.md`

## Estado e histórico

- `README.md`
- `STATE.md`
- `CHANGELOG.md`

## Templates operacionais

- `templates/question-record.md`
- `templates/routing-record.md`
- `templates/search-record.md`

## Referências

- `references/fontes-metodologicas.md`

---

# 3. Decisões estruturais vigentes

1. o repositório é a fonte canônica do projeto;
2. metodologia precede automação;
3. a pergunta científica é formalizada antes da busca definitiva;
4. não existe pirâmide universal de evidência;
5. risco de viés e certeza/confiança no corpo de evidências são processos distintos;
6. profundidade N0–N4 e manutenção M0–M3 são dimensões independentes;
7. a Ficha de Evidência é candidata à unidade persistente central do conhecimento;
8. o roteamento inicial é rule-based e exige justificativa textual; não há score numérico;
9. estudo e publicação são entidades distintas;
10. busca científica deve ser auditável e proporcional ao nível da investigação;
11. IA é ferramenta de apoio e não fonte de evidência científica;
12. decisões persistentes devem ser consolidadas no GitHub, não deixadas apenas na conversa.

---

# 4. Taxonomia e arquitetura já definidas

Classes principais:

- INT — intervenção;
- SAF — segurança;
- DIA — diagnóstico;
- PRO — prognóstico;
- PRE — predição;
- ETI — etiologia/exposição;
- FREQ — prevalência/incidência;
- QUAL — qualitativa;
- SYS — sistemas/políticas;
- MAP — mapeamento.

Profundidade:

- N0 — Evidence Scan;
- N1 — Resposta de Evidência;
- N2 — Ficha de Evidência;
- N3 — Síntese Rápida;
- N4 — Revisão Sistemática/Síntese Aprofundada.

Manutenção:

- M0 — estático;
- M1 — elegível para atualização;
- M2 — monitoramento ativo;
- M3 — Living Evidence.

---

# 5. Estado da busca e recuperação

O documento 10 já definiu, em caráter de documento vivo:

- classes de fontes F1–F7;
- papel de PubMed/MEDLINE;
- uso estratégico de Epistemonikos;
- integração de LILACS/BVS;
- registros de ensaios;
- ReBEC e Camada Brasil;
- literatura cinzenta;
- busca por citações;
- diferenciação estudo/publicação;
- Search ID e Study ID;
- cobertura proporcional N0–N4;
- PRESS e PRISMA-S como referências de controle/transparência;
- atualização e busca viva;
- papel auxiliar da IA.

---

# 6. Questões ainda provisórias

Ainda não formalizadas:

- nomenclatura final dos produtos;
- critérios operacionais finais dos descritores de roteamento;
- instrumentos específicos para prevalência/incidência e qualitativos;
- instrumento final para avaliação de revisões sistemáticas existentes;
- gatilhos operacionais de atualização;
- especificação final da Ficha de Evidência;
- política formal de versionamento de produtos;
- modelo de dados completo.

Esses itens não devem ser tratados como resolvidos por inferência.

---

# 7. Mecanismo de continuidade adotado

A partir deste checkpoint:

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

O `STATE.md` permanece como **painel vivo de estado**, mas não substitui checkpoints imutáveis.

Este CP é um snapshot operacional. Não deve ser editado silenciosamente após publicação.

---

# 8. Ponto exato de retomada

## Documento 11 — Protocolo de Elegibilidade, Triagem e Seleção de Evidências

Próximos elementos a definir:

- critérios de inclusão e exclusão;
- triagem por título/resumo;
- avaliação de texto completo;
- dupla triagem e verificações proporcionais a N0–N4;
- resolução de discordâncias;
- uso de IA na triagem;
- motivos de exclusão;
- fluxo PRISMA;
- vinculação de múltiplos relatórios ao mesmo Study ID.

A etapa deve ser desenvolvida sem reabrir automaticamente decisões já consolidadas nos documentos 00–03 e 10, salvo se surgir conflito metodológico documentado.

---

# 9. Regra para a próxima retomada

Antes de continuar:

1. ler o ponteiro operacional;
2. aplicar o template em Modo Continuidade;
3. executar o Freshness Gate;
4. consultar STATE.md;
5. verificar mudanças posteriores nos documentos canônicos;
6. apresentar Diagnóstico de Continuidade;
7. somente depois retomar o Documento 11.

---

**Fim do CP01**
