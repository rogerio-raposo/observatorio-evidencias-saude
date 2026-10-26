# OES — CP298 | PF-I02 Q0→Q1: pacote de decisão

**Data:** 2026-10-25. **Anterior:** CP297. **Documento canônico:** `docs/governance/311-pf-i02-i01-pacote-unico-decisao.md`.

## Resultado desde CP297
- PF-I01 fechado apenas `CLOSED_TECHNICAL_RESTRICTED_OFFLINE_GET_ONLY` (Doc. 305, CI 40243932508 success).
- PF-I02: Doc. 306 estabelece fronteira preparatória Q0/Q1/Q2; Doc. 307 identifica ausência de autenticação Django e write path; Doc. 308 define G1 identidade humana e permissões; Doc. 309 define G2 adaptação Q0-only e transações; Doc. 310 define G3 least privilege, segredos, isolamento e obrigação conectada diferida do Doc. 285.
- Doc. 311 consolida pacote único PF-I02-I01, sequenciado I01-A (auth Django offline), I01-B (modelo/migrations sob revisão), I01-C (gate PostgreSQL conectado com aprovação própria), I01-D (integração Q0→Q1 com escrita e testes). **Nenhuma implementação I01-A/B/C/D foi autorizada**, nenhum SQL, grants, usuário real, secrets, deploy ou workflow factual executado.

## Próxima decisão
Solicitar autorização expressa **`APPROVED — OES / PF-I02-I01-A / OFFLINE_DJANGO_AUTH_CODE_ONLY / no Neon or SQL writes / no real users / no deploy / E9 blocked`** antes de código; após, validar CI offline e preparar B. Sem repetir análise dos Docs. 306–311.

## Invariantes
Marco B aberto, E9 NO-GO, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, A3 não realizada e pesquisadores indisponíveis. Protocolo `Prossiga`: atividade delimitada; Freshness Gate antes de mudanças, checkpoints por materialidade.
