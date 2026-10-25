# Documento 285 — D2-E6 / G2-I2: avaliação proporcional e deferimento proposto

**Data:** 2026-10-25. **Referência canônica:** CP280. **Natureza:** recomendação técnica; **decisão formal PENDENTE**.

## Questão
Após G2-I1 encerrado com limpeza comprovada e autenticação independente inconclusiva, verificar se o ensaio conectado isolado G2-I2 precisa ocorrer agora ou se deve integrar o gate do piloto.

## Evidências existentes
- B2 comprovou em sessão administrativa com SET ROLE um INSERT sintético, leitura privada controlada, integridade SHA-256 e limpeza; não comprova autenticação independente de aplicação.
- G1 e G2-P3 trouxeram implementação e testes offline com conexões simuladas; não comprovam conexão Python real.
- G2-I1 criou identidades temporárias com ACL mínimas, realizou uma execução CI conectada com resultado HOLD de causa indeterminada, não conseguiu executar a segunda tentativa e removeu integralmente os logins e memberships de teste (CP280).
- Nenhuma captura factual, disponibilização de payload bruto ou liberação de workflow factual foi autorizada.

## Parecer
**Recomendação:** diferir G2-I2 isolado e exigir uma validação conectada **na integração do piloto**, sem declarar autenticação ou roundtrip Python/PostgreSQL comprovados. Evitar recriação desnecessária de logins, workflows transitórios e ciclos de depuração sem ganho suficiente para o piloto.

## Gate mínimo obrigatório do piloto integrado — ainda não autorizado
1. Credenciais independentes e papéis de menor privilégio; autenticação, TLS, isolamento e proibição de acesso cruzado confirmados.
2. Escrita, commit, leitura restrita e prova de integridade de bytes de fixture sintética; transações parametrizadas e tratamento de falha pós-commit sem retry inseguro.
3. Cleanup identificado e auditável, inclusive HOLD; dados e concessões pré-existentes preservados.
4. Sem publicação de raw JSON, segredos ou payload em CI/logs/APIs; nenhuma consulta factual até gate específico.
5. Evidências verificáveis em ambiente pertinente, critérios explícitos de aceite e autorização separada de operação conectada/factual.

## Limites e deliberação
Esta análise **não aprova G2-I2**, não promove E6-G1, não inicia Fase 5, não altera papéis, dados, credenciais ou workflows. Encerramento metodológico/documental da Fase 4 não é readiness operacional. **Estado: `G2_I2_DEFERRAL_RECOMMENDED / DECISION_PENDING / G2_I2_NOT_AUTHORIZED / FACTUAL_BLOCKED`.**

**Próxima deliberação proposta:** aprovar explicitamente o deferimento para o gate integrado ou solicitar revisão crítica do parecer. Somente após essa deliberação atualizar STATE/README/checkpoint como decisão vigente.
