# OES — CP315 | PF-I03 encerrado, PF-I04-A2/P1 isolamento Django comprovado localmente
**Data:** 2026-10-27. **Anterior:** CP314. **HEAD de referência anterior ao checkpoint:** `a5cf31ab4652c5c6a93d09338732517d6b62caec`. **Natureza:** handoff canônico sem promoção de gates.

## Decisões e evidências
- PF-I03 Q0→Q1→Q2/roteamento preparatório sintético: encerrado como `CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY`; CI [40535916973](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40535916973), 201/201 PASS com um teste sequencial integrado. Não equivale a fluxo persistente, ciência A3 ou operação.
- Contrato piloto PF-I04: docs `315-pf-i04-contrato-minimo-piloto-funcional-candidato.md`, `316-pf-i04-a1-diagnostico-identidade-persistencia-ambiente.md`. Preparador Django Auth; primeiro passo Q0 autenticado durável, sem Q1/Q2 persistentes prematuros.
- Responsável aprovou a **alternativa B**: banco sintético `oes_sandbox`, schema Django administrativo separado `oes_app`, sem migração ainda no Neon. Ver Doc. 317/318 PF-I04-A2.
- Neon preflight somente leitura: branch `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`. `oes_app` não existia; Q0/recibo já tinham tabelas e constraints. `oes_qprep_login` sem CREATE no banco/public; `oes_pg_a4_reader` permanece leitor.
- CI inventário migrations [40540077376](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40540077376): 15 migrations (2 contenttypes, 12 auth, 1 sessions), Django 5.2.18. Prévia SQL [40540685917](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40540685917): 15 previews, artefato 12750596954; `sqlmigrate` incompleto para RunPython/post_migrate.
- **CI de isolamento** [40541606299](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40541606299) sobre `a5cf31ab4652c5c6a93d09338732517d6b62caec`: PASS; 15/15 migrations em PostgreSQL 16 descartável, 9 tabelas e 8 sequências `oes_app`, 40 permissões, nenhuma tabela Django em `public`. Nenhuma conexão Neon.
- Parecer/P3 candidato: `docs/governance/330-pf-i04-a2-p1-parecer-isolamento-e-gates-p3.md` (criado junto ao checkpoint). Plano de privilégio mínimo ainda depende de SQL exato, owners, search_path e preflight.

## Gatilhos e limitações
- CP314 mantém o histórico do ensaio Q0 conectado com rollback e confirmação declaratória de exclusão do segredo descartável. Não repetir ensaio nem reconstituir credenciais.
- Config Django ainda de desenvolvimento: `DATABASES={}` por padrão, `DEBUG=True`, segredo fixo. O writer ORM e `execute_connected_q0` permanecem intencionalmente bloqueados.
- Sem pesquisadores vinculados e sem A3. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`; Marco B `OPEN`; readiness `NOT_READY`; G2-P2B operacional e E9 `NO-GO`.
- Sem DDL, DML, roles/grants, credenciais, HTTP write, deploy, dados reais ou custos pagos por autorização implícita.

## Ponto exato de retomada
**PF-I04-A2/P1→P3 ainda em preparação.** Concluir matriz exata do migrador/runtime e SQL proposto, com preflight read-only e plano de restauração. Solicitar aprovação nominal para P3 antes de qualquer alteração conectada. Não promover avanço apenas por testes locais.

## Acordo de trabalho
Cada `Prossiga` autoriza uma atividade delimitada; Freshness Gate no início e antes de mutações; checkpoints em marcos materiais ou a cada 3–5 atividades; comunicação de progresso periódica; alterações caras ou sensíveis sob autorização expressa; falhas produzem HOLD.
