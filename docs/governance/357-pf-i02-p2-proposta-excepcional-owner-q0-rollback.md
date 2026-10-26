# Documento 357 — PF-I02/P2 — Proposta excepcional de ensaio Q0 com owner e rollback

**Data:** 2026-10-26. **Natureza:** proposta para decisão, NÃO autorização de execução. **Base:** CP312; Docs 352, 353, 354, 355 e 356; CI 40285338405, 167/167 PASS.

## Justificativa de proporcionalidade
G2-P2A confirmou que `oes_sandbox_owner` é a identidade efetiva da sessão de catálogo e que `oes_qprep_writer` é NOLOGIN, com associação MEMBER existente mas `SET` não autorizado. O impedimento de usar diretamente o papel mínimo é factual. Para encerrar incertezas de integração Django/PostgreSQL sem alterar roles, grants ou credenciais, propõe-se avaliar **um único ensaio Q0 excepcional** com `oes_sandbox_owner`, limitado à sandbox, sem uso permanente no aplicativo.

**Risco residual:** owner pode alterar objetos fora do escopo autorizado. Rollback reduz persistência acidental, mas não neutraliza erros fora da transação, comandos não transacionais ou abuso de privilégios. O ensaio provaria apenas integração funcional Q0 com owner; **não provaria operação sob privilégios mínimos, autorização multiusuário ou readiness**.

## Condições anteriores ao ensaio
1. Nova autorização nominal específica, separada desta proposta, contendo projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, identidade `oes_sandbox_owner`, uma pergunta totalmente sintética, exatamente quatro registros Q0 e um receipt, e rollback intencional sem commit.
2. Revisão estática e CI da fronteira Django real: `DjangoQ0Repository` está hoje ininstanciável; proibir bypass via `object.__new__` ou alteração informal de segurança. Criar harness independente, condicionado ao gate, com `transaction.atomic(using=alias)` e todos os QuerySets/advisory locks na mesma conexão, **sem configurar writer permanente ou ativar HTTP**. Alterações no código exigem revisão e evidências antes da execução.
3. Validar destino, identidade, autocommit/estado da transação, padrão fail-closed, grants observados e ausência de dependência de Q1 antes de qualquer INSERT; consulta de catálogo adicional somente após autorização correspondente.
4. Reservar `oes_id` e `request_id` artificiais exclusivos, sem recuperar ou exibir conteúdo de terceiros; verificar unicidade por restrição do banco, não por leitura global de dados.
5. Restringir chamadas a SQL dos advisory locks, SELECTs de escopo e exatamente cinco INSERTs ORM. Proibir `SET ROLE`, DDL, DCL, UPDATE, DELETE, Q1, criação de usuário, chamadas de rede externas e serviços pagos.

## Protocolo proposto e critérios de parada
- Dentro de **uma** transação Django: locks de requisição e pergunta; cinco INSERTs Q0; verificação restrita, por UUIDs e IDs sintéticos, das cinco linhas e invariantes; forçar `transaction.set_rollback(True, using=alias)` antes de sair do bloco.
- Confirmar em nova transação read-only ausência dos identificadores sintéticos, com leitura pontual autorizada. Não chamar rollback simulado de evidência PostgreSQL.
- Exceção, timeout, perda de conexão, SQL inesperado, identidade divergente, linha extra ou incerteza de rollback: interromper, preservar evidência sanitizada e manter HOLD. Nunca repetir automaticamente, não executar limpeza especulativa fora da transação.
- **Sem aprovação de commit durável**. A hipótese comprovável é consistência de uma transação Q0 abortada; não se pode concluir sobre commit, replay conectado sob privilégios mínimos, isolamento ou funcionamento de Q1.

## Decisão recomendada
Propor primeiro um gate separado de **preparação do harness e revisão estática/CI somente**, mantendo o construtor e a aplicação desativados; depois solicitar consentimento específico para o ensaio conectado com owner e rollback. Não usar o simples “Prossiga” para inferir autorização de DML.

**Estado:** `OWNER_Q0_ROLLBACK_EXCEPTION_PROPOSED / CONNECTED_TRIAL_NOT_AUTHORIZED / G2_P2B_NO_GO / CP312_ACTIVE / E9_NO_GO`. Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED.
