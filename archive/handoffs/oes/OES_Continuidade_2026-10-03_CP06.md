# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Metodológica

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP06  
**Checkpoint anterior:** CP05  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — certeza/confiança no corpo de evidências  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP06

Estado formal:

> **Fase 0 — Concepção e fundamentos: EM DESENVOLVIMENTO**  
> **Documentos 00–03: CONSOLIDADOS COMO DOCUMENTOS VIVOS**  
> **Documento 10 — Busca e Recuperação: CONSOLIDADO**  
> **Documento 11 — Elegibilidade, Triagem e Seleção: CONSOLIDADO**  
> **Documento 12 — Risco de Viés e Qualidade Metodológica: CONSOLIDADO**  
> **Documento 13 — Extração e Estruturação de Dados: CONSOLIDADO**  
> **Documento 14 — Síntese de Evidências: CONSOLIDADO**  
> **Documento 15 — Certeza/Confiança no Corpo de Evidências: CONSOLIDADO**

Base documental do checkpoint:

`main @ 0d0ec3fef986e795f633a724b920d8683b2930fc`

---

# 2. Novos artefatos desde CP05

- `docs/methodology/15-certeza-evidencia.md`
- `templates/certainty-assessment-record.md`

Também foram atualizados:

- `README.md`
- `docs/README.md`
- `templates/README.md`
- `references/fontes-metodologicas.md`
- `CHANGELOG.md`

---

# 3. Decisões consolidadas no Documento 15

1. certeza é atributo do corpo de evidências, não do estudo individual;
2. a avaliação quantitativa será feita por desfecho/comparação/timepoint/estimando;
3. GRADE será a referência central quando aplicável;
4. a versão/fonte operacional do GRADE deverá ser registrada;
5. não haverá score numérico universal de certeza;
6. risco de viés, inconsistência, indirectness, imprecisão e missing evidence/publication bias serão avaliados explicitamente;
7. I² não será regra automática para downgrade;
8. significância estatística não será regra automática de imprecisão;
9. limiares decisórios deverão ser explícitos quando utilizados;
10. ausência de evidência não será classificada automaticamente como certeza muito baixa;
11. fatores de elevação serão usados somente quando metodologicamente cabíveis;
12. dupla penalização da mesma limitação deverá ser evitada;
13. aplicabilidade ao Brasil permanecerá separada da indirectness quando a pergunta científica não for especificamente brasileira;
14. diagnóstico, prognóstico, predição, prevalência/incidência e exposições exigirão orientação específica quando necessária;
15. NMA poderá utilizar abordagem GRADE específica ou CINeMA;
16. GRADE-CERQual será a referência preferencial para confiança em achados qualitativos;
17. GRADE quantitativo e CERQual não serão convertidos automaticamente entre si;
18. Summary of Findings será utilizado quando apropriado;
19. N3 exige verificação independente dos julgamentos materiais;
20. N4 exige pelo menos dois avaliadores independentes;
21. IA poderá assistir, mas não atribuir autonomamente certeza final em N2–N4;
22. certeza permanecerá separada de recomendação.

---

# 4. Arquitetura de certeza ativa

Estrutura conceitual:

`Study/Result → Synthesis ID → Risk of Bias profile → Certainty Assessment ID → interpretação/aplicabilidade`

Identificador provisório:

`OES-CE-AAAA-NNNNNN`

O Certainty Assessment Record deverá manter, conforme aplicável:

- Investigation ID;
- Synthesis ID;
- Outcome/Review Finding;
- Study IDs;
- Result IDs;
- Risk of Bias Records;
- framework e versão;
- julgamentos por domínio;
- justificativas;
- decisão final;
- revisores/adjudicação;
- versão/data.

---

# 5. Separações conceituais preservadas

Não colapsar:

- risco de viés × certeza;
- certeza × significância estatística;
- indirectness × aplicabilidade local;
- ausência de evidência × certeza muito baixa;
- GRADE × CERQual;
- certeza × recomendação.

A cadeia conceitual permanece:

`evidência → síntese → certeza → interpretação → aplicabilidade → decisão/recomendação`

---

# 6. Frameworks ativos

Referências centrais:

- GRADE Working Group;
- Cochrane Handbook Chapter 14;
- GRADE-CERQual;
- CINeMA / GRADE para NMA;
- Cochrane DTA Handbook;
- Cochrane Prognosis Handbook.

Como o GRADE Book encontra-se em processo de atualização do material histórico, a fonte operacional vigente deverá ser confirmada em cada investigação formal.

---

# 7. Política de IA

IA pode auxiliar em:

- organização dos dados por domínio;
- vinculação com Risk of Bias Records;
- detecção de inconsistências;
- cálculos e tabelas;
- rascunho de justificativas.

IA não pode, sem revisão humana:

- atribuir certeza final;
- inventar limiares;
- executar downgrade/upgrade sem base verificável;
- transformar ausência de evidência em “muito baixa”;
- converter certeza em recomendação.

---

# 8. Questões ainda abertas

Permanecem para fases posteriores:

- especificação definitiva da Ficha de Evidência;
- modelo conceitual de dados consolidado;
- relações formais entre Investigation, Study, Report, Result, Synthesis e Certainty Assessment;
- política definitiva de versionamento dos produtos;
- regras operacionais finais de aplicabilidade;
- gatilhos quantitativos de atualização;
- implementação computacional dos registros;
- seleção de software/pacotes oficiais;
- política de revisão estatística externa em análises complexas.

---

# 9. Ponto exato de retomada

## Consolidação do modelo conceitual de dados e aprofundamento da arquitetura tecnológica

Próxima tarefa:

1. mapear as entidades e relações já definidas nos Documentos 00–15;
2. distinguir entidades persistentes, registros operacionais e artefatos derivados;
3. definir cardinalidades e identificadores;
4. modelar proveniência e versionamento;
5. verificar compatibilidade com a candidata **Ficha de Evidência**;
6. somente depois aprofundar implementação tecnológica.

Não iniciar automação ampla antes de consolidar esse modelo.

---

# 10. Regra de retomada

Antes de continuar:

1. consultar o ponteiro operacional;
2. ler este CP06;
3. aplicar o Template Canônico em Modo Continuidade;
4. executar Freshness Gate contra `main`;
5. consultar `STATE.md`, os Documentos 13–15 e artefatos de arquitetura existentes;
6. apresentar Diagnóstico de Continuidade;
7. retomar na consolidação do modelo conceitual de dados, se não houver alteração material.

---

**Fim do CP06**
