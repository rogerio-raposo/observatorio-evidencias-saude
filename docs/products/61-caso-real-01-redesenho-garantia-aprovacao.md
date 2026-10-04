# 61 — Caso Real 01: Redesenho do Modelo de Garantia e Aprovação

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Status:** decisão arquitetural/metodológica aplicada  
**Data:** 4 de outubro de 2026  
**Dependência normativa:** Documento 04 — Governança de Garantia Metodológica, Aprovação e Revisão

---

# 1. Motivo

O fluxo anterior exigia uma “revisão humana aprovada” antes da publicação da Ficha.

Essa regra tornou-se inadequada ao contexto real do projeto porque:

- o único humano diretamente envolvido é o proprietário do OES;
- o proprietário não possui formação especializada em revisão sistemática, ROBIS, RoB 2, GRADE ou bioestatística;
- registrar sua aprovação como revisão metodológica criaria uma falsa garantia.

Decisão:

> **o Caso Real 01 deixa de exigir uma revisão humana genérica e passa a utilizar o modelo A0–A3 do Documento 04.**

---

# 2. Funções separadas

## AI methodological verification

- segunda passagem metodológica;
- explicitamente não independente;
- registra `passed`, `revise` ou `failed`.

## Owner governance approval

- escopo, transparência e comunicação;
- não valida ROBIS/RoB/GRADE;
- registra `approved`, `revise` ou `rejected`.

## Expert independent review

- somente quando existir especialista qualificado;
- opcional para N2 padrão;
- exigida quando criticidade/finalidade tornar A2 insuficiente.

---

# 3. Níveis de garantia aplicados ao Caso Real 01

## A0

Estado atual imediatamente após o redesenho:

- nenhuma AI methodological verification persistida;
- nenhuma owner governance approval persistida;
- nenhum expert review persistido.

## A1

Será atingido quando:

- AI methodological verification = `passed`.

## A2

Será atingido quando:

- A1;
- owner governance approval = `approved`.

Esse será o nível mínimo para eventual publicação N2 padrão do Caso Real 01.

## A3

Somente se houver:

- A2;
- expert independent review = `approved`.

---

# 4. Modelo de dados

Migration:

`database/010_product_assurance_governance.sql`

Cria:

`product.assurance_record`

com:

- assurance_uuid;
- product_version_uuid;
- assurance_type;
- actor;
- actor_type;
- independent_flag;
- decision;
- performed_at;
- notes;
- evidence_payload;
- status.

Constraints impedem:

- owner ser registrado como human_expert;
- IA ser marcada como independente;
- expert review com `independent_flag=false`;
- decisões incompatíveis com o tipo de assurance.

---

# 5. Publication gate

O gate N2 padrão passa a exigir:

1. AI methodological verification ativa em `passed`;
2. owner governance approval ativa em `approved`;
3. nenhuma AI verification ativa em `revise`/`failed`;
4. nenhuma owner approval ativa em `revise`/`rejected`;
5. se expert review existir, nenhuma `revise`/`rejected` ativa;
6. demais invariantes científicas;
7. publication_date.

Ausência de expert review em A2:

> **warning, não error.**

Issue:

`NO_EXPERT_INDEPENDENT_REVIEW`

---

# 6. EvidenceSheetView

Migration:

`database/011_evidence_sheet_assurance_view.sql`

Passa a expor:

- `audit.assurance_level`;
- `audit.expert_independent_reviewed`;
- `audit.assurance_records[]`;
- `audit.assurance_disclosure`.

---

# 7. Template

Template:

`oes.evidence_sheet.template/0.2`

A Ficha passa a mostrar na camada principal:

- nível de garantia;
- disclosure metodológico.

Na auditoria:

- registros de assurance;
- expert review status;
- review records históricos/especializados, se existirem.

Regra:

> **A2 sem expert review deve declarar isso explicitamente.**

---

# 8. Documento 59

O Documento 59 deixa de ser o gate obrigatório do proprietário.

Passa a ser:

> **pacote de revisão especializada independente**

a ser utilizado quando houver especialista ou quando A3 for exigido.

---

# 9. Documento 60

O Documento 60 permanece como evidência histórica válida da mecânica do antigo gate `review_record`.

A semântica normativa vigente, entretanto, passa a ser definida por:

- Documento 04;
- migration 010;
- Documento 61.

---

# 10. Estado do Caso Real 01

Product:

`OES-P-2026-000401`

Estado após o redesenho e antes da segunda passagem metodológica:

- editorial: `under_review`;
- assurance: **A0**;
- expert review: não realizado;
- publication_date: NULL;
- publishable: false.

---

# 11. Próxima etapa

Executar:

> **AI methodological verification adversarial do Caso Real 01**

utilizando:

`templates/ai-methodological-verification.md`

Somente se a decisão for `passed`:

- registrar assurance A1;
- gerar novo preview;
- apresentar ao proprietário o formulário simples de owner governance approval.

---

**Decisão:** o OES não exigirá do proprietário uma competência metodológica que ele não possui.
