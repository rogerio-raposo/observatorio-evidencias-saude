# OES — Continuidade CP335 — 2026-10-28

**Anterior:** CP334. **Branch:** main. **Escopo:** encerramento técnico delimitado G2-P2-B, sem promoção operacional.

## Evidência verificada
- Ensaio conectado de provisionamento sintético G2-P2-B: GitHub Actions [40773613528](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40773613528), `workflow_dispatch`, tentativa 1, SUCCESS, `PASS_POST_COMMIT`, commit `4215a7eb66e9213953dc691c681b75dade7002cc`.
- Preflight de limpeza autorizado READ ONLY, pelo papel `oes_auth_migrator` no Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`: 45 permissões, 1 usuário, 1 vínculo, 1 identidade, 0 sessões; dependências de chaves estrangeiras examinadas, vínculos externos impeditivos não identificados.
- Ensaio de limpeza transacional Django: GitHub Actions [40775904096](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40775904096), tentativa 1, SUCCESS, `PASS_CLEANUP_POST_COMMIT`, commit `417ee2eb266d8f28c0d87ccc07ace6e1bfa8732b`.
- Reconciliação pós-commit por nova conexão READ ONLY do próprio runner confirmou baseline restituída: permissions=44, users=0, links=0, identities=0, sessions=0. Não houve segunda confirmação direta independente pelo conector Neon após a limpeza.
- Usuário confirmou exclusão dos segredos efêmeros de provisionamento e limpeza, inclusive `OES_AUTH_G2_P2B_CLEANUP_PASSWORD`; registro declaratório, não verificação independente de secrets no GitHub.
- Código e evidências documentados em `applications/oes_web/config/auth_pg_g2_p2b_*.py` e `docs/governance/oes-auth-single-database-architecture-2026-10-28.md`. CI de integração offline de limpeza [40775302497](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40775302497) SUCCESS.

## Decisão e limites
**G2-P2-B encerrado tecnicamente apenas no perímetro sintético.** Não repetir nenhum dos dois workflows; nenhum DELETE adicional, conta real, HTTP write, deploy, migração, role/grant ou serviço pago autorizado. Workflows manuais continuam versionados, mas não são autorização para novas execuções. Documento 347 (Django First) e Documento 362 (governança proporcional) continuam aplicáveis. Marco B OPEN, E9 NO-GO e Fase 5 NOT_STARTED; sem pesquisadores reais.

## Próxima prioridade
Não estender artificialmente G2-P2-B. Retomar o próximo incremento substantivo Django First por diagnóstico delimitado da lacuna funcional e de critérios de aceitação, sem ativação operacional inferida. Registros sintéticos já limpos. Consultar README, STATE, CHANGELOG, ponteiro e documento canônico antes de qualquer mudança. A autorização para o ensaio encerrado não se transfere à próxima etapa.

**HEAD de referência antes deste checkpoint:** `e7c3d18aa778ebb0a0df483ad9e271272441861b`. Atualizar com o commit efetivo do novo CP durante a retomada. CP334 e anteriores preservados.
