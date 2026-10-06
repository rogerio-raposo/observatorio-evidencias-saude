# 122 — Revisão de Evidências N4: Infrastructure Readiness Gate Pré-Caso Real

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status do gate:** **NOT_READY**  
**Escopo:** prontidão transversal antes da abertura de qualquer Caso Real N4

---

# 1. Objetivo

Executar o N4 Infrastructure Readiness Gate exigido pelo Documento 115 antes de abrir Investigation, protocolo ou busca definitiva de um Caso Real N4.

Esta avaliação é deliberadamente pré-caso. Não foi criada Investigation N4 real e nenhuma busca científica N4 foi iniciada.

# 2. Regra canônica

O Documento 115 estabelece:

> **a profundidade desejada não autoriza iniciar N4 quando a infraestrutura necessária é inexistente.**

Estados permitidos:

- ready;
- ready_with_documented_conditions;
- not_ready.

Se `not_ready`:

> **não iniciar Caso Real N4 formal.**

# 3. Resultado global

> **NOT_READY**

O resultado é determinado por blockers transversais que independem do tema específico da revisão.

# 4. Domínio A — cobertura bibliográfica

**Estado:** `not_ready`

Evidências do projeto:

- o Caso Real N3 demonstrou indisponibilidade reprodutível do Europe PMC;
- OpenAlex direto também não ficou operacionalmente disponível naquele runtime;
- citation chasing/publisher discovery não substituiu segunda base bibliográfica;
- novos estudos elegíveis continuaram sendo encontrados após correções de busca;
- para N4, a cobertura exigida é mais forte que em N3;
- não existe hoje garantia operacional de acesso ao conjunto de bases necessário a qualquer classe de pergunta N4.

Conclusão:

> cobertura bibliográfica suficiente não pode ser garantida antecipadamente.

# 5. Domínio B — equipe metodológica

**Estado:** `not_ready`

Configuração atual:

- existe apenas o proprietário como humano envolvido no projeto;
- não há dois revisores humanos qualificados e independentes disponíveis;
- não há terceiro/adjudicador qualificado configurado;
- não há search peer reviewer/information specialist qualificado configurado;
- não há pares independentes qualificados para appraisal e certainty.

Conclusão:

> stage controls humanos obrigatórios não podem ser satisfeitos.

# 6. Domínio C — estatística

**Estado:** `ready_with_documented_conditions`

OES possui:

- arquitetura para Synthesis;
- suporte técnico a código/dataset;
- fixture/meta-analysis reproduzível;
- checks de statistical review.

Mas:

- não há garantia de expertise bioestatística humana qualificada para qualquer método complexo;
- NMA, meta-regressão, IPD ou outros métodos avançados podem exigir expertise não disponível.

Conclusão:

> capacidade técnica existe, mas a prontidão depende do subtipo e não pode ser considerada plenamente ready.

# 7. Domínio D — ferramentas e artefatos

**Estado:** `ready`

Já validados:

- versionamento GitHub;
- migrations/rebuild;
- Search/SearchHit/Screening;
- Artifacts e hashes;
- Provenance;
- Result/Synthesis/Certainty;
- ReviewerAssignment;
- publication gate;
- EvidenceReviewView;
- templates/renderers/validators;
- armazenamento de código/dataset em artifacts;
- auditoria e continuidade.

Conclusão:

> infraestrutura técnica/documental do OES está pronta para desenvolvimento e simulação N4.

# 8. Domínio E — governança

**Estado:** `not_ready`

Disponível:

- modelo A0–A3;
- owner governance approval;
- gates estruturais;
- registro de conflitos e papéis;
- suporte a expert independent review no modelo.

Ausente no mundo real:

- expert independent reviewer qualificado e independente;
- caminho operacional real para A3.

Conclusão:

> governança está modelada, mas o requisito humano A3 não pode ser satisfeito.

# 9. Resumo do gate

| Domínio | Estado | Natureza |
|---|---|---|
| Cobertura bibliográfica | not_ready | blocker |
| Equipe metodológica | not_ready | blocker |
| Estatística | ready_with_documented_conditions | condicional |
| Ferramentas/artefatos | ready | disponível |
| Governança/A3 | not_ready | blocker |

Resultado agregado:

> **NOT_READY**

# 10. Decisão

Não abrir Caso Real N4 formal neste momento.

Especificamente:

- não criar Investigation N4 real;
- não iniciar protocolo de revisão real;
- não executar busca definitiva N4;
- não fabricar ReviewerAssignments humanos;
- não utilizar IA como segundo reviewer humano;
- não reduzir os requisitos para fazer o caso caber na infraestrutura atual;
- não usar rótulo formal de systematic review.

# 11. O que permanece permitido

É permitido:

- manter contrato/template N4;
- executar fixtures sintéticas;
- testar arquitetura;
- melhorar infraestrutura;
- desenvolver acesso a bases;
- futuramente incorporar revisores humanos qualificados;
- reexecutar o readiness gate quando as condições mudarem.

# 12. Condições mínimas de reabertura

Reavaliar N4 real somente quando houver, no mínimo:

1. dois revisores humanos qualificados e independentes disponíveis;
2. search peer reviewer/information specialist qualificado;
3. expert independent reviewer para A3;
4. acesso reproduzível às bases bibliográficas necessárias ao subtipo;
5. expertise estatística compatível quando o método exigir;
6. papéis/conflitos formalmente registráveis antes da execução.

# 13. Consequência para a Fase 3

O resultado `not_ready` é um resultado metodologicamente correto do produto.

Ele demonstra que o OES consegue:

- avaliar capacidade antes de investir em execução científica;
- bloquear N4 quando seus requisitos constitutivos não existem;
- distinguir prontidão técnica de prontidão metodológica/humana;
- evitar produzir uma revisão sistemática incompleta apenas para avançar o roadmap.

# 14. Próxima etapa recomendada

> **Deferir Caso Real N4 e prosseguir para o próximo produto da taxonomia: Mapa de Evidências.**

O N4 permanece tecnicamente disponível e deverá ser reaberto apenas após mudança real das condições de readiness.

---

**Resultado final:** `NOT_READY`; nenhum Caso Real N4 formal iniciado.