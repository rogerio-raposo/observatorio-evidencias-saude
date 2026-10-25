# OES — CP281: G2-I2 diferido para piloto integrado por decisão aprovada

**Data:** 2026-10-25. **Anterior:** CP280. **HEAD anterior:** `f922213c0842fafd7d001eac5350f0628572f597`. **Decisão canônica:** Documento 285 (agora aprovado).

## Deliberação
Aprovado pelo proprietário: `APPROVED — OES / D2-E6 / G2_I2_DEFER_TO_INTEGRATED_PILOT / Documento 285 / preserve connected authentication and integrity validation as mandatory pilot gate / no factual GET / no role or data changes / no workflow enablement / no paid services / fail closed`.

G2-I2 **não será executado como ensaio isolado agora**. A validação conectada Python/PostgreSQL é **obrigatória no piloto integrado** antes de qualquer captura factual: autenticação independente, papéis de menor privilégio e TLS; escrita sintética, leitura privada, SHA-256 e transações; HOLD e cleanup após falhas, sem exposição de secrets/raw JSON; aceite verificável e aprovação operacional própria.

## Base de evidência e limites
CP280 encerrou G2-I1 com duas contas descartáveis removidas, grants seletivos revogados, tabela privada 0 linhas, proveniência total 1 e autenticação real **inconclusiva**. B2 comprova SET ROLE em sessão administrativa, não login independente. Python offline e CI de mocks não demonstram conexão real. Nenhuma nova operação no Neon executada por esta deliberação. G2-I1 e workflow factual desabilitados. `G2_I2_NOT_AUTHORIZED / E6_G1_FACTUAL_BLOCKED / NOT_READY / PHASE5_NOT_STARTED`.

## Macroatividades seguintes
1. Mapear com precisão os entregáveis pendentes do D2 e identificar funções que os frameworks/stack existente já resolvem.
2. Definir integração mínima de aplicação e persistência sem novas camadas experimentais desnecessárias; preservar convenções de privacidade e provenance.
3. Preparar gate de validação sintética conectada **integrada**, com aprovação própria antes de executar.
4. Só após PASS e revisão de prontidão, submeter eventual captura factual a gate separado. Sem promoção automática de Fase 4/Fase 5.

## Ponto exato de retomada
Realizar **mapeamento das macroatividades remanescentes D2**, classificando concluído/comprovado, parcial e pendente, distinguindo requisitos essenciais dos experimentos diferidos. Apresentar proposta de sequência mínima; não realizar operações conectadas, alterações de papéis, secrets, workflows ou captura factual sem autorização específica.

## Continuidade
Protocolo vigente: um `Prossiga` autoriza uma atividade; 3–5 atividades por checkpoint, com antecipação por decisão material; Freshness Gate pré-commit; progresso durante atividades longas; `main` + `archive/handoffs/oes/README.md` prevalecem como referência operacional. Nenhum serviço pago.
