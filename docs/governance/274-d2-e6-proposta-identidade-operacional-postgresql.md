# Documento 274 — Proposta de identidade operacional mínima para persistência E6 no PostgreSQL

**OES | 2026-10-24 | Base: CP274; Documentos 269–273; HEAD `acc542e1579940ec72221490287ef9ef1045bebd` | PROPOSTA DOCUMENTAL**

## Decisão solicitada (ainda não concedida)
Autorizar futuramente, em gate separado, o provisionamento de **uma identidade autenticável, sem privilégios administrativos**, restrita à branch Neon experimental `br-gentle-hall-b6jaxehf` / database `oes_sandbox`, para persistir exclusivamente JSONs autorizados no piloto. A implantação do workflow e o GET factual E6-G1 são aprovações **independentes** e seguem bloqueados. Nenhuma senha, usuário ou secret criado neste documento.

## Alternativa preferencial: login mínimo associado ao writer existente
- Criar por SQL, após autorização explícita e Freshness Gate, um papel de execução `oes_e6_capture_login` com `LOGIN`, `NOSUPERUSER`, `NOCREATEDB`, `NOCREATEROLE`, `NOREPLICATION`, `NOINHERIT`; não promover a `neon_superuser` nem ao proprietário.
- Conceder unicamente capacidade **SET** para assumir `oes_e6_writer`, sem `INHERIT` e sem `ADMIN`, ou, após revisão de compatibilidade PostgreSQL 18, os privilégios de INSERT mínimos diretamente. A associação exige teste negativo de que login sozinho não lê, não altera e não administra schema e, quando assume writer, somente insere no alvo autorizado.
- A identidade `oes_e6_verifier` permanece `NOLOGIN` e somente leitora. Para conferir bytes recuperados, **não** entregar SELECT à identidade de captura. A recuperação deve usar identidade/verificação separada, aprovada posteriormente, ou outro mecanismo explicitamente revisado. Se não houver verificação pós-gravação com credenciais restritas, a execução conectada deve permanecer bloqueada.
- Não conectar o workflow com `oes_sandbox_owner` ou `oes_pg_a4_reader` por conveniência. A conta proprietária mantém exclusivamente operações administrativas.

## Secret e ciclo de vida
A credencial será obtida pelo processo Neon autorizado e guardada **somente** em GitHub Actions Secrets, com mascaramento e sem imprimir connection string, senha ou JSON bruto. O nome exato do segredo e sua inclusão na execução dependem de decisão posterior. Fixar projeto/branch/DB e `sslmode=require` no cliente. Evitar segredos em PRs, logs e artifacts; permissões do workflow `contents: read`, `persist-credentials: false`.

Para teste conectado sintético, prever criação, verificação de privilégio, uso e revogação ou rotação controlados; não presumir que exclusão do GitHub Secret revogue automaticamente a senha do Postgres. A retenção operacional da identidade para a captura factual precisa de decisão específica.

## Critérios de aceitação antes de habilitar E6
1. Role conectado comprova identidade e `NOINHERIT`, não obtém acesso às fixtures PG-A4 ou schema privado sem a troca de papel explicitamente autorizada.
2. Negar SELECT/UPDATE/DELETE ao writer, INSERT/UPDATE/DELETE ao verifier; checar que `PUBLIC` não recebe acesso.
3. Teste sintético conectado insere os bytes originais com SHA-256, recusa duplicata/limite, aplica rollback em falha, recupera por verificação **separada**; 0 registros sintéticos residuais após limpeza aprovada.
4. Workflow reformulado não produz artifact com JSON bruto, não divulga conteúdo em logs e continua `if: ${{ false }}` durante preparação e testes offline.
5. Prova documental de credenciais e grants sem divulgar valores sensíveis, e plano de rotação/revogação ensaiado.

## Compatibilidade e proporcionalidade
A documentação oficial Neon informa que papéis criados por SQL não recebem automaticamente participação em `neon_superuser`; consultar https://neon.com/docs/manage/roles . GitHub Secrets são suportados para workflows e documentados em https://neon.com/docs/manage/backups-aws-s3-backup-part-2 . Antes de implementar, confirmar as condições exatas do plano Free e os detalhes da concessão de roles do PostgreSQL 18. Não criar sistema de gestão de identidade próprio, infraestrutura paga ou outro banco.

**PostgreSQL é armazenamento exclusivamente do piloto**; manter `observation_id`, hash e proveniência portáveis para futura migração a object storage privado. JSON bruto nunca poderá ser disponibilizado para download público, inclusive como artifact GitHub.

**Estado: `E6_RUNTIME_IDENTITY_PROPOSAL_PREPARED / ROLE_CREATION_NOT_APPROVED / WORKFLOW_CHANGE_NOT_APPROVED / FACTUAL_CAPTURE_BLOCKED`.**

**STOP — aguardar autorização específica para implantação de identidade sintética mínima.**
