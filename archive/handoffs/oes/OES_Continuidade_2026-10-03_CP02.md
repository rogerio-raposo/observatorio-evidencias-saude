# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Metodológica

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP02  
**Checkpoint anterior:** CP01  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — elegibilidade, triagem e seleção de evidências  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP02

Estado formal:

> **Fase 0 — Concepção e fundamentos: EM DESENVOLVIMENTO**  
> **Documentos 00–03: CONSOLIDADOS COMO DOCUMENTOS VIVOS**  
> **Documento 10 — Busca e Recuperação: CONSOLIDADO**  
> **Documento 11 — Elegibilidade, Triagem e Seleção: CONSOLIDADO**  
> **Documento 12 — Risco de Viés e Qualidade Metodológica: NÃO INICIADO**

Base documental do checkpoint:

`main @ e96e6a5f7a47fc18d5db8fd2908ee7fdc6fa039c`

---

# 2. Novos artefatos desde CP01

- `docs/methodology/11-elegibilidade-triagem-selecao.md`
- `templates/screening-record.md`

Também foram atualizados:

- `README.md`
- `STATE.md`
- `CHANGELOG.md`
- `docs/README.md`
- `templates/README.md`
- `references/fontes-metodologicas.md`

---

# 3. Decisões consolidadas no Documento 11

1. critérios de elegibilidade devem ser pré-especificados para investigações formais;
2. alterações de critérios exigem justificativa e versionamento;
3. registro, relatório/publicação e estudo são entidades distintas;
4. múltiplos relatórios do mesmo estudo devem ser vinculados;
5. triagem por título/resumo deve privilegiar sensibilidade;
6. dúvida na triagem inicial favorece avanço para texto completo;
7. relatório não recuperado não equivale a estudo excluído;
8. motivos de exclusão em texto completo devem ser explícitos;
9. ausência de dados utilizáveis não implica inelegibilidade;
10. desfechos raramente serão critério de elegibilidade em revisões de intervenção;
11. discordâncias entre revisores devem ser preservadas e adjudicadas;
12. intensidade da triagem varia proporcionalmente entre N0–N4;
13. N4 exige dois revisores independentes para decisão final em texto completo;
14. N3 pode adotar triagem abreviada calibrada, desde que declarada;
15. automação pode priorizar e assistir, mas não possui autorização geral para exclusão silenciosa em N2–N4;
16. PRISMA é referência para rastreabilidade do fluxo;
17. elegibilidade, risco de viés e contribuição para síntese são decisões distintas.

---

# 4. Identificadores operacionais introduzidos

Candidatos provisórios:

- `OES-RC-AAAA-NNNNNN` — Record ID;
- `OES-RP-AAAA-NNNNNN` — Report ID;
- `OES-ST-AAAA-NNNN` — Study ID.

Esses identificadores permanecem provisórios até fechamento do modelo de dados.

---

# 5. Estados de seleção introduzidos

- RECORD-PENDING
- RECORD-EXCLUDE
- RECORD-POTENTIAL
- REPORT-NOT-RETRIEVED
- REPORT-FULLTEXT
- STUDY-INCLUDED
- STUDY-EXCLUDED
- STUDY-AWAITING-CLASSIFICATION
- STUDY-ONGOING
- STUDY-LINKED

Não tratar essa taxonomia operacional como modelo de dados definitivo.

---

# 6. Política de IA na triagem

Estado atual:

> IA pode priorizar, organizar, classificar preliminarmente e sugerir motivos.

Restrições:

- N2–N4: sem autorização geral para exclusão silenciosa puramente automatizada;
- N4: automação pode assistir, mas decisão final permanece sujeita ao protocolo humano;
- stopping rules automatizadas exigirão validação específica antes de uso formal.

---

# 7. Relação N0–N4

- **N0:** seleção exploratória, sem alegação de completude;
- **N1:** seleção de melhores fontes, sem processo exaustivo;
- **N2:** triagem formal e reproduzível, com verificação estruturada;
- **N3:** revisão rápida com pilotagem, calibração e simplificações declaradas;
- **N4:** padrão máximo de seleção, com controle independente reforçado e fluxo PRISMA.

---

# 8. Questões ainda não resolvidas

Permanecem abertas, entre outras:

- ferramenta definitiva para gerenciamento de screening;
- política quantitativa final para amostras de verificação em N2;
- eventual adoção futura de stopping rules validadas;
- especificação final do modelo de dados de Record/Report/Study;
- política de preservação de versões de preprints e publicações finais;
- integração técnica futura com ferramentas de deduplicação e screening.

Esses itens não devem ser tratados como decisões tomadas.

---

# 9. Ponto exato de retomada

## Documento 12 — Protocolo de Avaliação de Risco de Viés e Qualidade Metodológica

Próximos elementos a definir:

- diferença entre risco de viés, qualidade metodológica, qualidade de relato e certeza;
- matriz de instrumentos por desenho;
- RoB 2;
- ROBINS-I;
- ROBINS-E;
- QUADAS-3;
- QUIPS;
- PROBAST+AI;
- avaliação de estudos de prevalência/incidência;
- avaliação de pesquisa qualitativa;
- avaliação de revisões sistemáticas existentes;
- dupla avaliação e adjudicação;
- política de scores agregados;
- IA no apoio à avaliação;
- relação entre risco de viés, síntese e certeza.

---

# 10. Regra para retomada

Antes de continuar:

1. consultar o ponteiro operacional;
2. ler este CP02;
3. aplicar o Template Canônico em Modo Continuidade;
4. executar Freshness Gate contra `main`;
5. consultar `STATE.md` e os documentos 10 e 11;
6. apresentar Diagnóstico de Continuidade;
7. retomar no Documento 12 apenas após confirmação da base.

---

**Fim do CP02**
