# Documento 210 — OES D1/T2-A2: proporcionalidade do controle financeiro e proposta P1 (CP235)

**2026-10-22 | GOVERNANCE_FINANCIAL_SIMPLIFICATION_RECORDED | P1_APPROVAL_PENDING | T2-A2 NOT_AUTHORIZED**

## 1. Decisão do proprietário e fundamento

O proprietário contestou a complexidade do bloqueio financeiro C0 para testes sintéticos Neon Free, informando como condições atuais do seu plano: **1 GB de storage por projeto, autoscaling até 2 CU, 100 CU-horas mensais por projeto, 10 branches e ausência de cartão cadastrado**. A avaliação subsequente reconheceu que exigir comprovação específica de custo zero por chamada administrativa GET era desproporcional; sob novo `Prossiga`, formaliza-se a **simplificação documental do controle financeiro**, sem alterar retrospectivamente os Documentos 208–209, sem supor que a manifestação autorize P1. Limites declarados pelo proprietário e referências públicas oficiais são contextuais; não constituem auditoria atual da conta.

A regra financeira consolidada para o escopo sintético é: **permanecer no Free; proibir contratação, upgrade, serviços pagos, cadastro de cartão ou cobrança autorizada tacitamente; acompanhar consumos e quotas em checkpoints de atividade pertinentes em vez de exigir comprovações repetitivas por consulta; interromper diante de limites gratuitos, solicitação de pagamento ou exigência de mudança de plano**. A ausência de cartão reduz significativamente risco de débito automático, mas não é garantia contratual absoluta. Não comprometer recursos nem aceitar cobranças.

## 2. Correção explícita da política C0

O protocolo histórico C0/C1/C2 foi motivado pela circularidade de exigir evidência financeira indisponível sem consultar metadados. **Para a autorização futura restrita P1, C0 deixa de ser um bloqueio genérico de prova individual de gratuidade de cada GET administrativo**. Permanece preflight administrativo simples: conferir HEAD/autorização; assegurar que a ferramenta pertence à allowlist e não modifica plano/compute; interromper se houver sinal específico de gasto, upgrade, cobrança ou escopo divergente. C1 obtém dados administrativos durante P1 somente se autorizado. C2 verifica quotas/risco de compute de modo proporcional antes da autorização separada de SQL/sessão PostgreSQL. Qualquer novo risco material exige STOP e deliberação.

A revisão **substitui prospectivamente**, apenas neste ponto de governança financeira, as formulações mais restritivas dos Docs 208–209; preserva a proveniência e a interpretação histórica dos documentos originais. Não modifica os demais riscos PA-01–PA-08, R1–R4 ou os gates.

## 3. P1 — proposta técnica de autorização, NÃO APROVADA

Escopo administrativo futuro e limitado ao projeto `oes-d1-t2-a2-synthetic` (ID `tiny-pond-20086371`), branch `synthetic-main` (ID `br-divine-grass-b63wlpcb`), banco `oes_t2a2_synthetic`:

| Ferramenta de leitura candidata | Argumentos fixos |
|---|---|
| `describe_project` | `project_id=tiny-pond-20086371` |
| `get_branch` | `project_id=tiny-pond-20086371, branch_id=br-divine-grass-b63wlpcb` |
| `get_postgres_database` | `project_id=tiny-pond-20086371, branch_id=br-divine-grass-b63wlpcb, database_name=oes_t2a2_synthetic` |

No máximo uma invocação de cada operação, sem tentativas automáticas adicionais. O plugin pode retornar registros completos: registrar apenas resultados relevantes e não reproduzir credenciais/dados sensíveis. `list_postgres_endpoints` e `get_postgres_endpoint` ficam excluídos do primeiro escopo. Também excluídos `get_connection_string`, listas amplas de projetos/pessoas, qualquer SQL, `run_sql`, inspeções de banco que iniciem sessões, DDL/DML/GRANT, CI, alterações de rede, roles, Data API, banco, branch, endpoint, plano, restauração, teste, adaptador e serviços pagos. Nenhuma alegação de segurança TLS interna do banco; N1-E3 só comprovou cliente→endpoint.

**Minuta não aprovada:**
> **PROPOSED — OES / D1-T2-A2 / A2-G2-P1 / RESTRICTED_NEON_ADMIN_METADATA_READ_ONLY** — Autorizar exclusivamente as três consultas administrativas acima, uma chamada por ferramenta, identificadores fixos, sob Freshness Gate, controle financeiro simplificado do Neon Free e proteção contra segredos. Produzir evidência mínima de PF-02/PF-03 e partes observáveis de PF-04 com PASS/FAIL/UNVERIFIED; STOP ante divergência, exigência de cobrança/upgrade, acesso excessivo ou dados sensíveis. Não autorizar SQL, P2, E, GRANT, CI, alterações de infraestrutura, custos pagos ou T2-A2. **Somente decisão expressa futura poderá aprovar a execução P1.**

## 4. Estado e continuidade

A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED` apenas desenho. P1 `NOT_AUTHORIZED`; P2 `NOT_AUTHORIZED`; E `NOT_AUTHORIZED`; T2-A2 `NOT_AUTHORIZED`. F01–F07 apenas endereçados documentalmente; L1–L4 e oráculos O-01–O-10 continuam pendentes. T1 36 PASS históricos `CLOSED_SYNTHETIC_LOCAL_ONLY`; T2-A1 75 PASS históricos `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`. D0 concluída documentalmente → D1 sintético prioritário → D2 factual posteriormente → governança completa. Nenhum Neon, SQL, CI, implementação, novo recurso, dado real ou gasto foi executado nesta consolidação.

**Próximo Prossiga:** avaliar a minuta P1 revista e, se for suficientemente clara, apresentá-la ao proprietário para **aprovação explícita independente**, sem acioná-la automaticamente. STOP.
