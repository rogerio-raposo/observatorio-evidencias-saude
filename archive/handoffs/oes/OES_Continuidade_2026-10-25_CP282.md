# OES — CP282: D2-I-A e D2-I-B validados offline

**Data:** 2026-10-25. **Anterior:** CP281. **HEAD antes do CP:** `60e088af4a1bc1fb05ba889f2893598fc0608f47`.

## Evidências
- D2-I-A: contrato Doc. 286, serviço de projeção sintética opt-in em `applications/oes_web/evidence/services.py`, sem tocar fixtures, views e rotas. Commit `6352fcc1fb19cd03cafcbd93230189b56058115e`. GitHub Actions [40190923646](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40190923646), job `121161570317`, Django check PASS, **39/39 testes PASS**, seis testes D2-I-A PASS.
- D2-I-B: função interna `run_synthetic_private_roundtrip`, exigência opt-in, objetos writer/verifier distintos, orquestrador injetado, contrato de saída sanitizada e HOLD inclusive após possível commit. Commit `60e088af4a1bc1fb05ba889f2893598fc0608f47`. GitHub Actions [40191544839](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40191544839), job `121163407550`, Django check PASS, **46/46 testes PASS**, sete novos testes D2-I-B PASS.

## Limitações e classificação
**D2-I-A:** `CLOSED_TECHNICAL_RESTRICTED_OFFLINE`. **D2-I-B:** `OFFLINE_SERVICE_CONTRACT_PASS / ADAPTER_COMPOSITION_PENDING`. Os testes de Django não demonstraram composição conjunta com os adaptadores reais, conexão PostgreSQL ou autenticação independente. Não elevar status por simples existência de código. O serviço D2-I-B depende de orquestrador injetado e não invoca por padrão os adaptadores E6. Nenhuma promoção científica, operacional ou de produção.

## Gates preservados
CP281/Documento 285: G2-I2 isolado diferido para gate conectado obrigatório do piloto integrado; G2-I1 autenticação inconclusiva, cleanup PASS; workflows G2-I1 e factual desabilitados; sem GET factual, raw JSON público, serviço pago, mudanças em logins/SQL. Fase 4 encerrada somente metodológica/documentalmente; D2 parcial; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.

## Ponto exato de retomada
Definir a composição offline **mínima e verificável** do orquestrador E6 existente com o serviço D2-I-B Django. Identificar interface de importação sem copiar adaptadores nem reimplementar transações, fixtures sintéticas e testes positivos/negativos. Submeter alterações de código à autorização restrita, mantendo conexões somente simuladas. Depois executar regressão offline; gate conectado separado e posterior.

## Protocolo
Um `Prossiga` autoriza uma atividade. Checkpoint normalmente após 3–5 atividades, ou antecipado por mudança material; Freshness Gate; mensagens de progresso. Fonte: `main`, `archive/handoffs/oes/README.md`, `STATE.md`.
