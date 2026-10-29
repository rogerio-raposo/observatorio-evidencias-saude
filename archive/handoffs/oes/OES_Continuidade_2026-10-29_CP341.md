# OES — Continuidade CP341 — 2026-10-29

**Anterior:** [CP340](OES_Continuidade_2026-10-29_CP340.md). **Branch GitHub:** main. **HEAD antes do checkpoint:** `79d95e3c64147eef97e5d16699701e35408dc150`.
**Gates:** Marco B OPEN; Fase 5 NOT_STARTED; E9 NO-GO; execução Q0 Django HARD HOLD; provisionamento conectado Django HARD HOLD; ausência de validação científica e pesquisadores.

## Avanços desde CP340

- Três aliases Django configurados somente sob `OES_Q0_MULTI_ALIAS_ENABLED=1`: `default` autenticação `oes_auth_trial_login`, `oes_q0_writer` `oes_qprep_login`, `oes_synthetic_reader` `oes_pg_a4_reader`; endpoints diretos e três credenciais distintas. CI [40878636150](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40878636150) 261 PASS offline.
- Preflight auth/writer inicial [40879868895](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40879868895) HOLD por secrets com valores coincidentes, corrigido pelo responsável; [40882380556](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40882380556) PASS nas duas conexões e ACLs Q0. Sem DML.
- Diagnóstico preparador [40884729765](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40884729765) HOLD. Diagnóstico agregado [40885079565](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40885079565): `user_exists=NO`, `active_nonadmin_exists=NO`, `active_nonadmin_identity_exists=NO`, `permission_definition_exists=NO`. Confirmação administrativa: `django_auth.auth_user` zero registros, RLS desativada; `oes_app.auth_user` também zero. Branch principal `production` (br-wild-field-b6qg7k3p) não possui essas tabelas no banco oes_sandbox. Branch sintética `br-gentle-hall-b6jaxehf` permanece única de trabalho.
- Catálogo: `django_auth` contém 12 migrações auth, 2 contenttypes, 1 sessions e 1 preparer_identity; FK identidade para auth_user confirmada. `oes_app` contém Django auth legado paralelo, mas sem preparer_identity. Schema canônico escolhido: `django_auth`, manter `oes_app` intocado.
- `preparer_identity` registrado em INSTALLED_APPS, `default` fixado com `search_path=django_auth,public`, metadado `evidence.prepare_question` declarado em OesQuestion (managed=False). Correção de testes legados; [40887850440](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40887850440) 262/262 PASS offline. Não significa permissão persistida no banco.
- [40889381479](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40889381479): `oes_auth_trial_login` SELECT mas nenhum INSERT/UPDATE/DELETE nas cinco tabelas de provisionamento. Preservar role read-only; não conceder INSERT.
- `oes_auth_migrator` identificado como dono das cinco tabelas de autenticação e sequências relevantes no `django_auth`, login não-superuser; [40893828407](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40893828407) PASS conectado via workflow manual SELECT only, sessão readonly, cinco tabelas e cinco sequências. O responsável confirmou exclusão de `OES_AUTH_MIGRATOR_PASSWORD` após uso; **isso não revoga senha PostgreSQL**. Não reusar secret sem novo gate.
- Plano [docs/governance/OES_MARCO_B_DJANGO_SYNTHETIC_PREPARER_PROVISIONING_PLAN.md](../../../docs/governance/OES_MARCO_B_DJANGO_SYNTHETIC_PREPARER_PROVISIONING_PLAN.md) define um único usuário sintético com senha inutilizável, um actor UUID, permissão mínima, atomicidade e reconciliação fail-closed. Contrato offline `provisioning_plan_offline.py` com entrypoint HOLD e classificações de resultado; [40892109873](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40892109873) 265 PASS; [40899707532](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40899707532) 266/266 PASS.
- Após 266 PASS, adicionados `preparer_identity/connected_provisioning_dormant.py` em `81f2f14d` e teste de ambos gates incondicionais em `79d95e3c`. **Essas alterações ainda NÃO têm CI verificado**. O arquivo é referência inerte, não implementação conectada de DML nem executor funcional.

## Limites e próximos passos

1. Executar workflow manual `oes-django-vertical-slice-validation.yml` no HEAD atualizado e confirmar suíte (esperados 267 testes, ainda não comprovados).
2. Revisar proporcionalmente detalhes operacionais do provisionamento único; antes de qualquer DML, exigir gate nominal distinto e credencial administrativa temporária sob gestão do usuário. Nenhum GRANT, DDL, migração, usuário novo ou Q0 write aprovado.
3. Não repetir preflights já aprovados sem fato novo; verificar diferenciação entre sintético e dados reais. Desfecho incerto exige verificador independente, sem repetição automática.
4. Manter credencial de leitor `OES_PG_A4_READER_PASSWORD` por decisão do usuário; auth/writer secrets presentes, migrator secret excluído segundo usuário. Jamais registrar valores sensíveis.
5. Documento 362 (governança proporcional), Django First Doc347, Marco B OPEN; Fase 5 NOT_STARTED; E9 NO-GO.

**Atenção:** CP340 foi produzido antes dos passos descritos. CP341 é a referência atual após atualização do ponteiro.
