# Documento 356 — PF-I02/P2 — G2-P2A identidade READ ONLY — resultado factual
Data: 2026-10-26. Autorização nominal do usuário: "Autorizado G2-P2A". Base CP312 e Doc355. G2-P2B permanece NÃO AUTORIZADO.

## Destino e consulta permitida
Projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf` (ready, `oes-pg-a3-synthetic-20261024`), banco `oes_sandbox`. Inspeção exclusiva do catálogo via consulta SELECT, sem leitura de linhas operacionais. Nenhum `SET ROLE`, DML, DDL, grants, credenciais ou transação Django.

## Evidência
- `session_user=current_user=oes_sandbox_owner`.
- Papel alvo `oes_qprep_writer`: `rolcanlogin=false`, `rolinherit=false`.
- `pg_has_role(session_user,'oes_qprep_writer','MEMBER')=true`.
- `pg_has_role(session_user,'oes_qprep_writer','SET')=false`; idem `current_user`.
- Papel-alvo: `USAGE` em schemas `core` e `investigation`; `SELECT` e `INSERT` nas cinco tabelas canônicas; `DELETE` e `UPDATE` de tabela não concedidos. G2-P0 já verificou UPDATE limitado a duas colunas de `core.entity_version`.
- A evidência confirma associação de papel, **não** confirma assumir identidade runtime nem que os privilégios efetivos da sessão administrativa são mínimos. Nenhuma simulação ou suposto efeito de `SET ROLE` realizado.

## Decisão
`G2_P2A_READ_ONLY_COMPLETE_WITH_IDENTITY_HOLD`. **G2-P2B NO-GO**: não executar ensaio conectado como owner ou usar indiscriminadamente grants herdados. Resolver em decisão separada a identidade runtime com permissões mínimas; quaisquer mudanças de role/grant/login/credencial exigem aprovação própria, sem autorização implícita neste documento.

## Invariantes
CP312 vigente; Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED; E9 NO-GO; sem usuários reais, HTTP write, deploy ou serviços pagos.
