# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP18  
**Checkpoint anterior:** CP17  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 3 — especificação científica da Ficha de Evidência  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP18

Estado formal:

> **Fase 2 — concluída no nível de baseline arquitetural**  
> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Documento 40 — Taxonomia e Arquitetura dos Produtos: CONSOLIDADO**  
> **Documento 41 — Especificação Científica e Funcional da Ficha de Evidência: CONSOLIDADO COMO BASE INICIAL**  
> **Próxima etapa: CONTRATO DE DADOS DA FICHA DE EVIDÊNCIA**

---

# 2. Documento consolidado

`docs/products/41-especificacao-ficha-evidencia.md`

O Documento 41 define o contrato científico e funcional da Ficha antes do template operacional.

---

# 3. Decisões estruturais

1. A Ficha é a unidade persistente central preferencial para perguntas focais reutilizáveis.
2. A Ficha permanece `Product subtype`.
3. Ela não duplica Study, Report, Result, Synthesis, Certainty ou provenance.
4. Um `Product ID` permanece estável enquanto a unidade científica central permanecer a mesma.
5. Mudanças materiais geram nova ProductVersion.
6. Mudança material da pergunta pode exigir nova Ficha.
7. Uma Investigation principal é obrigatória.
8. Investigações-fonte adicionais podem ser vinculadas quando houver reuso.
9. Toda Synthesis usada na conclusão deve estar vinculada estruturalmente.
10. Certainty formal comunicada exige CertaintyAssessmentVersion concreta.
11. Não existe certainty global artificial da Ficha.
12. Ausência de evidência permanece distinta de very low certainty.
13. Study e Report continuam separados para impedir dupla contagem de publicações.
14. Segurança/danos devem ser tratados separadamente quando aplicáveis.
15. Limitações são obrigatórias.
16. Aplicabilidade permanece descritiva até método próprio.
17. Camada Brasil será usada quando o contexto-alvo for brasileiro.
18. Conclusão deve ser calibrada à magnitude, incerteza e certainty.
19. A Ficha não produz recomendação normativa por si só.
20. Estado editorial e estado de atualidade permanecem separados.
21. Ficha é compatível com M0–M3.
22. Monitor e Alerta não alteram conclusão automaticamente.
23. Publicação exige gate científico mínimo.
24. Template só será criado após fechamento do contrato de dados.

---

# 4. Estrutura científica da Ficha

Blocos definidos:

A. Identificação e estado;  
B. Pergunta e escopo científico;  
C. Método resumido;  
D. Corpo de evidências;  
E. Resultados/achados prioritários;  
F. Risco de viés/qualidade metodológica;  
G. Certeza/confiança;  
H. Segurança e danos;  
I. Limitações;  
J. Aplicabilidade;  
K. Conclusão da evidência;  
L. Atualização, versionamento e rastreabilidade.

---

# 5. Gate mínimo de publicação

A Ficha somente poderá ser publicada quando houver, entre outros:

- Product/ProductVersion válidos;
- Investigation principal;
- pergunta estruturada;
- nível metodológico definido;
- data de corte;
- fontes/busca identificáveis;
- elegibilidade registrada;
- corpo de evidências reconstruível;
- Results/Syntheses vinculados;
- RiskAssessment quando exigido;
- certainty vinculada quando formal;
- limitações;
- aplicabilidade ou estado equivalente;
- conclusão sustentada;
- revisão humana;
- tratamento de correções/retrações;
- provenance/lineage suficiente;
- coerência entre conclusão e certainty.

---

# 6. Versionamento

Classes preservadas:

- editorial;
- evidência nova;
- correção científica;
- mudança quantitativa;
- mudança de certeza;
- mudança de aplicabilidade;
- mudança de conclusão.

Uma versão pode ter múltiplas classes.

Versão publicada não é sobrescrita silenciosamente.

---

# 7. Manutenção

A Ficha é compatível com M0–M3.

Fluxo preferencial para conhecimento vivo:

`Investigation → Ficha → Monitor → Alerta → reavaliação → nova ProductVersion`

Monitor e Alerta não criam mudança científica sem atualização formal.

---

# 8. Lacunas de implementação identificadas

## 8.1 Estado de atualidade

Documento 40 exige separação entre:

- estado editorial;
- estado de atualidade.

O baseline físico atual possui `ProductVersion.status`, mas não estrutura explícita para atualidade.

## 8.2 Classes de mudança

Uma ProductVersion pode possuir múltiplas classes de mudança, mas o baseline ainda não possui estrutura própria para registrá-las.

## 8.3 Product → Product

Derivações entre produtos poderão exigir relação explícita.

## 8.4 ApplicabilityAssessment

Interface lógica reservada, ainda sem método/implementação final.

## 8.5 Revisão/publicação

O gate científico exige registro auditável da revisão humana antes de `published`.

---

# 9. Ponto exato de retomada

## Contrato de Dados da Ficha de Evidência

Próximas tarefas:

1. mapear cada campo/bloco ao OES-P1;
2. classificar como:
   - armazenado;
   - derivado;
   - renderizado;
   - futuro;
3. identificar extensões mínimas obrigatórias;
4. definir invariantes de ProductVersion;
5. decidir se ProductRelation é necessária já nesta fase;
6. decidir como registrar classes de mudança;
7. decidir como registrar estado de atualidade;
8. definir gate físico de publicação;
9. preparar migration somente após fechar o contrato;
10. não criar template ainda.

---

# 10. Regra para retomada

1. consultar ponteiro;
2. ler CP18;
3. aplicar Freshness Gate;
4. consultar Documentos 38, 40 e 41;
5. consultar OES-P1 e migrations vigentes;
6. desenvolver o Contrato de Dados da Ficha;
7. somente depois decidir migration/template.

---

**Fim do CP18**
