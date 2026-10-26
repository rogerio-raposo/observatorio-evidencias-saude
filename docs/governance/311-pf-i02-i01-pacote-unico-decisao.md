# Documento 311 — PF-I02-I01: pacote único de decisão para fluxo Q0→Q1

**Data:** 2026-10-25. **Natureza:** pacote para aprovação futura, não autorização de implementação ou operação conectada. **Base:** Docs. 300, 306–310; CP297.

## Resultado pretendido
Um único preparador humano autorizado registra Q0 literalmente, consulta a preparação e propõe Q1 em versão posterior, com justificativa, autoria e trilha recuperáveis após reinício; nenhum Q2, routing, Investigation/E9, coleta factual, avaliação A3 ou publicação científica. PF-I01 e rotas anteriores preservadas.

## Fases executáveis sob autorizações independentes
**I01-A — aplicação e identidade (código offline):** configurar módulos de autenticação Django, sessões/CSRF/permissionamento; escolher configuração de testes sem banco operacional e política para desenvolvimento versus execução; não criar contas reais ou liberar acesso público. Aceite: login/permission checks isolados, anônimo negado, E9 ausente, CI offline.

**I01-B — persistência/modelo (design/migrations revisadas, sem aplicar):** especificar alteração controlada permitindo Q0 sem Q1, estados técnicos de preparação, auditoria/idempotência, integridade e migração compatível com histórico. Determinar como dados Django auth e OES coabitarão no banco sem duplicar stack. Produzir plano de rollback e concorrência. Aceite: revisão estática de DDL, ausência de alterações de Investigation, migrações não aplicadas sem aprovação.

**I01-C — fronteira PostgreSQL conectada:** mediante aprovação separada para ambiente, DDL, identidade técnica/GRANTs e credenciais, verificar IAM/ACLs negativas, TLS, secrets, quotas Free, cleanup e backups. Identidade separada de PG-A4, E6 e proprietário. Sem credencial administrativa na aplicação. Teste conectado sintético, sem publicação de payload.

**I01-D — integração transacional e UI mínima:** somente após A–C aprovadas, criar/ler Q0, preparar/ler Q1, compare-and-swap da versão, idempotência e rollback em uma transação por comando; audit trail vinculado à sessão humana; status sanitizados, CSRF; bloqueio E9 por rotas e privilégios. CI regressiva e testes conectados com limpeza/reconciliação; não presumir commit desfeito após falha de confirmação.

## Gates e evidências de aceitação
1. **Autoridade:** definir responsável por criar/revogar preparador e limites de visualização dos registros; não confundir governança do OES com A3 científica.
2. **Autenticação:** nenhuma escrita anônima, cookie/token seguro e identidade de sessão validada em servidor.
3. **Integridade:** Q0 byte/text exact, Q1 realmente distinta ou explicitamente igual sob justificativa, versões append-only/supersessão correta e autor/hora estáveis.
4. **Concorrência:** duas alterações conflitantes não produzem dois atuais, nem perda silenciosa; retries idempotentes.
5. **Bancos e papéis:** grants estritamente necessários com negativas de E9/owner, transações e verificador separado; backup/rollback.
6. **Segurança operacional:** `DEBUG=False` em eventual hospedagem, segredo real, HTTPS/CSRF, logs sanitizados, retenção e privacidade; sem publicação externa inadvertida.
7. **Regressão:** PF-I01 preservado, fluxo experimental E6 e workflows científicos não habilitados.
8. **Escopo científico:** somente preparação; A3 não realizada e E9 NO-GO.

## Critério de autorização
Um `Prossiga` comum pode avançar inspeções e documentação, **não** delega automaticamente criação de logins reais, DDL/DML, grants, secrets ou deploy. Para iniciar I01-A, exigir autorização expressa com escopo `OFFLINE_DJANGO_AUTH_CODE_ONLY`. Para I01-B/C/D haverá decisões separadas adequadas ao risco. Não iniciar implementação total em uma única execução.

## Recomendação
Solicitar aprovação para **I01-A — implementação isolada, offline, de autenticação/permissões Django**, com testes e nenhuma dependência de Neon. A seguir revisar modelo Q0-only; evitar mais protocolos fragmentados.

**Invariantes:** Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; E9 NO-GO, A3 ausente e pesquisadores não vinculados.
