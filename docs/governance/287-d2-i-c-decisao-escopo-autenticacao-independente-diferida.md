# Documento 287 — Decisão de escopo do piloto D2-I-C: autenticação independente deferida

**Data:** 2026-10-25. **Ato:** decisão expressa do responsável pelo OES em conversa de continuidade após CP283.

## Deliberação
**Retirar do escopo do piloto inicial a exigência de duas conexões com logins independentes**, anteriormente obrigatória para o gate integrado pelo Documento 285. A decisão é direta e não depende de nova análise de proporcionalidade. O requisito de duas autenticações distintas fica **diferido, não eliminado como possível controle de evolução futura**.

## Requisitos mantidos
- Preservação privada de bytes originais sintéticos, proveniência e verificação SHA-256.
- Controle de transações, tratamento fail closed e HOLD após possível commit, sem retry inseguro.
- Privilégio mínimo proporcional à operação, TLS adequado, proteção de credenciais, confidencialidade de raw payload, cleanup estrito e auditoria.
- Gate conectado do piloto ainda requer aprovação específica; captura factual, escrita não autorizada, alterações de roles/grants, workflow enablement e serviços pagos seguem bloqueados.

## Impacto arquitetural
É admissível projetar o piloto com **uma identidade de aplicação**, desde que tenha apenas os privilégios efetivamente necessários e sejam documentados os riscos residuais. Isso **não autoriza automaticamente** ampliar ACL ou usar uma credencial administrativa. Os adaptadores E6 existentes exigem writer/verifier distintos e validam roles separadas; portanto, **não podem ser considerados compatíveis com o novo escopo sem adaptação aprovada e testes correspondentes**. Não modificar ainda os adaptadores, nem reclassificar os testes offline 50/50 PASS: continuam válidos para o modelo anterior que foi testado.

## Relação com Documento 285
Esta decisão **substitui exclusivamente** o requisito de autenticações independentes do gate mínimo do Documento 285, no contexto do piloto inicial. Os demais controles do Documento 285 continuam vigentes. Não altera diretamente o código, os logins presentes no Neon ou a política de Fase 4.

## Próxima atividade
Redesenhar proporcionalmente o contrato de D2-I-C para uma identidade de aplicação e garantir preservação e verificação de integridade, distinguindo o que é demonstrado por testes offline e pelo ensaio conectado. Somente depois solicitar autorizações técnicas estritamente delimitadas.
