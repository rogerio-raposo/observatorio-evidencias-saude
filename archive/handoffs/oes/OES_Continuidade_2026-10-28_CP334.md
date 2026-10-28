# OES — Continuidade CP334 — 2026-10-28

**Anterior:** CP333. **Escopo:** A11–A15, preparação offline proporcional e Django First. **Branch:** main.

## Avanços confirmados
- A11: avaliação de suficiência; encerrar extensões genéricas e reutilizar a stack Django.
- A12: configuração `config/settings_auth_pg_g2_p2b_dormant.py` permanentemente bloqueada, sem credenciais nem conexão, mais teste do HOLD. Commits `6bf8d626`, `7f9066f8`; CI [40754760803](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40754760803) SUCCESS.
- A13: confirmação da CI e revisão de reutilização de `config/auth_pg_g2_p1_preflight.py`, cujo contrato de runtime read-only **não** pode ser usado diretamente como contrato administrativo.
- A14: criado `config/auth_pg_g2_p2b_admin_preflight.py`, verificador **puro** de identidade informada, baseline, quatro privilégios INSERT/DELETE e quatro sequências USAGE, ContentType e permissão ausente; testes offline e filtro CI. Commits `36fe928e`, `ede4f44d`, `343554e2`.
- A15: [CI 40755134420](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40755134420) SUCCESS para HEAD `343554e2ed0d0c3800a9f85cf9c4fc315efe22c6`, seguido deste checkpoint.

## Estado de segurança
- Nenhuma conexão DML no Neon, migração, GRANT, role, segredo, workflow conectado habilitado, deploy ou HTTP write em A11–A15.
- O validador administrativo não lê o banco: **evidências ainda precisarão ser obtidas na sessão PostgreSQL autorizada**. Não tratar um retorno PASS do contrato puro como verificação conectada.
- A configuração G2-P2-B permanece com `raise RuntimeError(HOLD)` incondicional; nenhum executor conectado foi disponibilizado.
- Baseline histórica G2-P2-A: 44 permissões, 0 usuários, 0 vínculos, 0 identidades, 0 sessões, `evidence.prepare_question` ausente; pós-condições projetadas: 45/1/1/1/0. Revalidar no banco antes de qualquer DML.
- Neon: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, schema `django_auth`; papel administrativo `oes_auth_migrator`. Direitos catalogais previamente confirmados no documento de arquitetura. Senhas com prazo informado até 2026-10-31 23:59:59 UTC.
- Marco B OPEN; G2-P2-B conectado HOLD/operacional NO-GO; E9 NO-GO; Fase 5 NOT_STARTED; nenhum pesquisador real.
- Documentos normativos: Doc347 Django First; Doc362 simplificação proporcional; `docs/governance/oes-auth-single-database-architecture-2026-10-28.md` canônico.

## Retomada
1. Conferir HEAD, ponteiro e CP334.
2. Evitar prolongar indefinidamente testes de contratos puros. O próximo incremento útil é **obter evidências reais via preflight conectado READ ONLY sob autorização própria** ou preparar um único pacote inativo que faça essa coleta, sem DML e sem ativação.
3. Antes de propor qualquer escrita, resolver acesso autorizado, identificação real da sessão, baseline, concorrência, pós-commit incerto, segredo efêmero e limpeza em gate separado. Nenhum `Prossiga` genérico autoriza DML.
4. Sem novas roles/grants, SQL personalizado ou serviços, salvo necessidade técnica demonstrada. Falhas ou drift => HOLD.

**CP333 e anteriores preservados.** Este checkpoint não promove gates.
