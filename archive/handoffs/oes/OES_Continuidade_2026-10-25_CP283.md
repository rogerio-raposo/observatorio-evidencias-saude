# OES — CP283 / D2-I-B encerramento técnico restrito offline

**Data:** 2026-10-25. **Anterior:** CP282. **HEAD de evidência:** `5511eff6598b11b18b6cb47966a1c2b52fb70830`.

## Evidências
- D2-I-A: serviço de projeção sintética opt-in no Django, sem NCT/UUID crosswalk; run [40190923646](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40190923646): **39/39 PASS**.
- D2-I-B: serviço de roundtrip Django com orquestrador injetado; run [40191544839](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40191544839): **46/46 PASS**.
- Composição Django + orquestrador **E6 real** demonstrada offline usando conexões simuladas, commit `5511eff6598b11b18b6cb47966a1c2b52fb70830`; run [40192039182](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40192039182), job 121164886672, HEAD exato, Django check PASS, **50/50 PASS**, 0 erros e 0 falhas, incluindo quatro novos testes: roundtrip íntegro, ACL incorreta bloqueada antes da escrita, adulteração pós-commit gera HOLD sem retry, conexão compartilhada rejeitada.

## Classificação e limitações
**D2-I-A** e **D2-I-B**: `CLOSED_TECHNICAL_RESTRICTED_OFFLINE`. A demonstração não utiliza sessões PostgreSQL reais, TLS, credenciais, leitura/escrita conectada ou recuperação operacional pós-commit. Não há autorização factual ou promoção científica/operacional. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.

## Gates preservados
Decisão Documento 285 / CP281: G2-I2 isolado diferido; autenticação independente real, ACL, integridade, limpeza e isolamento privado são requisitos obrigatórios do gate integrado. Workflows G2-I1 e factual seguem hard-disabled. Sem mudanças em roles/grants, Neon ou serviços pagos. Nenhum GET factual.

## Ponto exato de retomada
**D2-I-C — especificação proporcional documental do gate conectado do piloto integrado**, sem executá-lo. Definir escopo, autenticação writer/verifier independente, TLS, menor privilégio, commit/readback, evidência de integridade, cleanup seguro e HOLD pós-commit. Somente depois pedir autorização específica para execução. Evitar novos frameworks e repetições de ensaios offline.

## Continuidade
Uma atividade por `Prossiga`; Freshness Gate ao início e antes do commit; checkpoints proporcionais; `main`, README e STATE canônicos.
