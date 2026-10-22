# Documento 207 — Decisão expressa A2-G1: aprovação documental condicionada D1/T2-A2 (CP232)

**OES | 2026-10-22 | DECISÃO EXPRESSA DO PROPRIETÁRIO | A2-G1 CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED | T2-A2 NOT_AUTHORIZED**

## 1. Decisão e autoridade

Após a avaliação A1 pós-CP231, o proprietário respondeu expressamente **"Aprovado"** à proposta delimitada de `A2-G1 / CONDITIONAL_DOCUMENTARY_DESIGN_APPROVAL`. Esta manifestação aprova **somente a referência arquitetural documental condicionada** dos Documentos 205 e 206; não autoriza T2-A2 como atividade implementável nem confere permissões operacionais. A presente formalização registra essa aprovação, sem a ampliar.

**Decisão formal interpretada no escopo integral da proposta submetida:**

> **APPROVED — OES / D1-T2-A2 / A2-G1 / CONDITIONAL_DOCUMENTARY_DESIGN_APPROVAL** — Aprovar exclusivamente como referência documental condicionada a arquitetura candidata D1/T2-A2 descrita nos Documentos 205 e 206, baseada em um namespace PostgreSQL sintético isolado e três entidades mínimas: `scenario`, `event` e `receipt`. Preservar integralmente T1, T2-A1, os cinco comandos Python, as semânticas históricas, a rastreabilidade delimitada e todos os gates existentes. Reconhecer F01–F07 como endereçados documentalmente, mas não comprovados operacionalmente, mantendo L1–L4 e O-01–O-10 como condições para futuras decisões e validações. Esta aprovação não autoriza SQL, DDL, DML, GRANT, criação de objetos, alterações de roles, novas conexões Neon, CI, implementação de adaptador, testes remotos, dados factuais, buscas científicas, serviços pagos, implantação, API pública ou promoção de fases e gates. As etapas A2-G2 e posteriores dependerão de autorizações expressas e independentes. T2-A2 permanece `NOT_AUTHORIZED` para implementação e execução.

Os identificadores A2-G1–G6 são auxiliares de fracionamento da autorização D1/T2-A2, **não criam nem promovem gates oficiais científicos ou operacionais**.

## 2. Alcance positivo estrito

Fica aprovado como **referência de planejamento** um modelo candidato PostgreSQL experimental, integralmente sintético, em namespace dedicado `oes_t2a2_proto` com somente as três entidades lógicas/físicas candidatas:
- `scenario` — identidade, revisão monotônica, estado serializado sintético;
- `event` — sequência ordenada, tipo, payload e vínculo ao cenário;
- `receipt` — identidade idempotente do comando, fingerprint canônico, resposta e revisão confirmada.

Permanecem candidatos, não homologados pela execução: tipos, checks e índices, estratégia `READ COMMITTED`/bloqueio ou alternativa, snapshot independente consistente, criação concorrente por chave única/colisão, correspondência entre estado JSONB e log, operação de rollback, confirmação incerta, segregação de ownership e GRANTs mínimos. O domínio Python T1 e a ponte T2-A1 não são modificados. A resposta da criação repetida continua snapshot **corrente**, os outros recibos devolvem respostas originais, request conflitante é rejeitado, `pending` não se reavalia, as diferenças `RepositoryConflict`/`DomainError` continuam expressas. O fingerprint permanece compatível com `encoded(payload)` e SHA-256 em Python.

## 3. Condições vinculantes e não evidências operacionais

Os sete achados adversariais **F01–F07** recebem apenas o status `DOCUMENTARILY_ADDRESSED_NOT_OPERATIONALLY_VALIDATED`. As lacunas L1–L4 continuam: (L1) isolamento ainda não testado; (L2) integridade semântica não decorre apenas de transações ou constraints; (L3) owner/ACL reais ainda exigem preflight específico; (L4) arquitetura não expande autorização de infraestrutura. Oráculos O-01–O-10 do Documento 206 continuam **NÃO EXECUTADOS**; os critérios E01–E12 do Documento 197 permanecem requisitos candidatos. A aprovação **não** significa `TESTED`, `PASS`, `IMPLEMENTATION_READY`, homologação de segurança ou homologação científica.

N1-E3 permanece `CLOSED_CLIENT_TLS_ONLY_WITH_BACKEND_OBSERVABILITY_LIMIT`: cliente Psycopg/verify-full e CA verificados no run 39737616716, mas `pg_stat_ssl.ssl=false` foi observado no backend; nenhum TLS end-to-end até o processo PostgreSQL pode ser alegado. Projeto Neon Free `oes-d1-t2-a2-synthetic` (`tiny-pond-20086371`), branch `synthetic-main`, banco `oes_t2a2_synthetic`, sem tocar em `oes-sandbox`. Papel `oes_t2a2_app` existente, sem novos GRANTs; o papel privilegiado `oes_t2a2_runtime` **não deve ser usado**; N1-D2 não concluído.

## 4. Exclusões categóricas

**Não autorizados por A2-G1:** criar schema/tabelas/índices, quaisquer SQL/DDL/DML, GRANT/REVOKE, ALTER ROLE, nova conexão ou inspeção operacional Neon, drivers, workflow/CI remota, adaptador PostgreSQL, implementação, migrações históricas, dados reais, busca PubMed/ClinicalTrials, API pública, deploy, consumo ou contratação paga, alteração de rede/Data API/papéis, descarte de objetos ou promoção de gate científico/operacional. Não assumir custo incremental zero futuro apenas pelo plano Free.

A2-G2–G6 exigem **autorização específica, expressa e independente** com escopo, preflight, pós-condições, reversão e controles financeiros. Nenhuma transição automática ocorrerá após esta decisão.

## 5. Estado preservado e próximo passo

- D0 editorial/documental concluído → D1 protótipo sintético prioritário → D2 factual posterior → governança operacional completa futura.
- T1: `CLOSED_SYNTHETIC_LOCAL_ONLY`; 36 testes locais históricos PASS, sem reexecução.
- T2-A1: `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`; 39 testes próprios + 36 T1 = 75 históricos PASS, sem reexecução.
- **A2-G1: `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`.**
- **T2-A2: `NOT_AUTHORIZED` para implementação/execução.**
- Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrações `UNREVIEWED`; gates preservados.

**Próxima atividade sob novo `Prossiga`:** avaliação e preparação **exclusivamente documental** de um eventual preflight/escopo A2-G2, com riscos, recursos, autorizações e pós-condições, sem SQL, DDL/DML/GRANT, CI, drivers, conexões Neon, alteração de infraestrutura ou testes. Qualquer ato operacional deverá aguardar autorização independente do proprietário. **STOP.**
