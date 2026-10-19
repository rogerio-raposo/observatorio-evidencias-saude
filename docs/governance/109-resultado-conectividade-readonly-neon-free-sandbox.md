# 109 — Resultado factual de conectividade read-only do sandbox Neon Free

**Data:** 2026-10-19  
**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4  
**Modo:** médio  
**Status:** **SANDBOX_CONNECTION_READ_ONLY_PASS — ODB_NOT_READY**  
**Autoridade:** aprovação explícita do proprietário, Documento 108/CP152, escopo synthetic-only / aws-sa-east-1 / no paid services.  
**HEAD de entrada:** `bf808c78704e60c876de6a2a4de9a48a351406db`.

## 1. Ambiente observado no provedor

A integração Neon foi acessada com sucesso usando as operações de leitura de metadados e SQL, sem expor credenciais. O estado anterior de plugin não instalado não impediu a conexão por integração Neon disponível nesta sessão; portanto, a hipótese CP152 `NEON_PLUGIN_CONNECTION=NOT_INSTALLED` não deve ser reproduzida como impossibilidade de acesso atual.

Retorno do projeto Neon:
- name = `oes-sandbox`;
- project ID = `weathered-boat-65779510`;
- region = `aws-sa-east-1`;
- engine PostgreSQL major = 18;
- tamanho lógico máximo publicado ao recurso = 1 GiB;
- branch padrão = `production` (`br-wild-field-b6qg7k3p`), state = `ready`;
- `production` é nome de branch do provedor, **não** publicação científica ou produção OES;
- project created_at = `2026-10-19T11:45:22Z`, conforme leitura de metadados.

## 2. Smoke test factual, sem mutation

Primeira tentativa de executar múltiplos comandos no executor Neon foi **rejeitada pelo cliente de prepared statement**: `cannot insert multiple commands into a prepared statement`. Não houve transação ou alteração por essa tentativa.

Reformulado como uma **única instrução SELECT**, que não escreve dados:

```sql
SELECT CURRENT_TIMESTAMP AS observed_database_time,
       current_database() AS connected_database,
       current_user AS connected_role,
       current_setting('server_version') AS server_version,
       current_setting('transaction_read_only') AS transaction_read_only;
```

Retorno factual:
- `observed_database_time=2026-10-19T11:59:14.637Z` (= `2026-10-19T08:59:14.637-03:00`);
- `connected_database=oes_sandbox`;
- `connected_role=oes_sandbox_owner`;
- `server_version=18.6 (653b019)`;
- `transaction_read_only=off` é propriedade da sessão/role de conexão: **não** indica que o SELECT realizou escrita; indica que a conexão dispõe de permissão potencial para escrever, sujeita ao role. Não usar esta role owner para preflight futuro; definir role read-only depois de revisão de privilégios.

**Resultado:** conexão e execução de SQL read-only de fato passaram. O executor não aceita `BEGIN; SELECT; ROLLBACK;` em um único prepared statement; o arquivo preparado em CP152 pode ser usado por `psql` compatível, mas não enviado inteiro ao endpoint `run_sql` da Neon.

Nenhum migration, DDL, `INSERT`, `UPDATE`, `DELETE`, alteração de frozen artifacts, consulta PubMed/ClinicalTrials.gov ou prova de ativação ocorreu.

## 3. Interpretação por controle ODB

- ODB-01: escopo/restrições de owner aprovado; região AWS São Paulo confirmada, Free tier precisa ser conferido em billing do projeto antes de avançar;
- ODB-02: instância PostgreSQL persistente **existe e é acessível**; persistência entre suspensões e restauração ainda não foram ensaiadas;
- ODB-03: acesso como `oes_sandbox_owner` verificado, mas privilégios mínimos e validação TLS de cliente **não comprovados**;
- ODB-04: somente leitura técnica e sandbox sintético, sem dados pessoais clínicos;
- ODB-05–06: migrations, ledger e bootstrap **não executados**;
- ODB-07–08: object storage externo, cópias independentes e restore **não configurados**;
- ODB-09: clock PostgreSQL observado; logs, alertas e consumo não auditados integralmente;
- ODB-10: executor factual não configurado;
- ODB-11: CI não foi conectada ao Neon; segregação de credenciais ainda exige hardening;
- ODB-12: primeira consulta de conectividade em ambiente real = PASS, mas smoke tests completos ainda pendentes.

Nenhum gate geral `OPERATIONAL_DATABASE_READY` aprovado. O B1R1 permanece não ativado; a existência do sandbox não autoriza backdating ou recuperação de oportunidade já decorrida. A janela B1R1 termina às 09h00 exclusive, e a consulta ocorreu às 08h59min14s; não registrar `EXPIRED_NOT_EXECUTED` antes de verificar tempo após 09h00 e ausência de ativação.

## 4. Próximo passo

Após checkpoint/STOP, o próximo bloco em modo médio é o **inventário read-only de schemas, roles, configurações de conexão, branch e capacidade**, sem mutation, e a preparação de migration ledger/estratégia de branch isolada para testes sintéticos. Backup independente e restauração devem ser tratados antes de qualquer registro factual científico. Alterações DDL e administração de permissões requerem escopo e cautela adicionais; não executar automaticamente apenas porque existe conexão como owner.

**Fim do Documento 109**

