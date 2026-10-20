# 133 — Ensaio sintético PG18 de LOGIN, SET/INHERIT e recibos fora da transação

**OES — Fase 4 | 2026-10-20 (America/Recife) | modo alto**  
**Estado:** PG18_SYNTHETIC_LOGIN_MEMBERSHIP_AND_LOCAL_RECEIPTS_VERIFIED_PINNED_COMMIT_ONLY — NOT_AN_EXTERNAL_AUDIT — NO_NEON_WRITE.  
**Entrada:** CP176, HEAD `1bed3de41ebc9dd5a670e867d38bc3c2e6825669`.

## 1. Continuidade e limite de autorização

Freshness Gate no início do checkpoint: `main` comparado ao HEAD CP176 = `identical`, ahead=0, behind=0. README apontava CP176. Foram lidos checkpoint CP176, Documento 132 e a proposta de papéis. O `Prossiga` autoriza somente um experimento sintético e a reconciliação documental. Não autorizou branches, roles, migrations, gravações ou consumo de serviços pagos no Neon.

## 2. Artefatos de teste

- `scripts/oes_f4_pg18_login_roles_external_receipt_sim.py`: harness exclusivamente para serviço PG18 descartável de GitHub Actions, host local `127.0.0.1`, DB fixa `oes_f4_cp177_synthetic`, repositório exato e `GITHUB_ACTIONS=true`. Rejeita `DATABASE_URL`, `PGSERVICE` e `PGSERVICEFILE`. Instala as 36 migrations somente no contêiner sintético e configura três credenciais `LOGIN` distintas, além de uma role proprietária `NOLOGIN`. Não é executor operacional nem coletor externo.
- `.github/workflows/f4-pg18-login-and-audit-receipts-synthetic.yml`: workflow em serviço efêmero `postgres:18`, `contents:read`, checkout sem persistência de credenciais, gatilho automático limitado a seus arquivos e manifesto, preservação do artifact inclusive sob falha. Sem endpoint/secret Neon.

As credenciais e os nomes de roles são artificiais, fixos somente na CI descartável; não constituem padrão de armazenamento ou rotação de segredos reais.

## 3. Execuções e correção rastreável

**Primeiro run:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39404590522 — commit `158459f7ce5b47c160196e4c1fa314e88a9164ae`, job `118567331868`, `completed/failure`. A instalação 001–036 e os testes de separação de identidades e bloqueio do migrator/runtime haviam passado. A operação `SET ROLE oes_ci_guard_owner; ALTER TABLE maintenance.temporal_observation_epoch DISABLE TRIGGER...` foi recusada por `permission denied for schema maintenance`: a role proprietária artificial havia recebido a propriedade da tabela, porém não `USAGE` no schema. **Falha de configuração do ensaio**, não evidência de que ownership elevado seja incapaz de alterar a tabela. A falha e artifact `12255679352` foram preservados.

**Correção prospectiva:** conceder `USAGE` em `maintenance` à role `oes_ci_guard_owner` **exclusivamente no banco PG18 descartável**. Não foi alterado nenhum SQL histórico.

**Segundo run:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39404695131 — commit fixado `39ad812f55fd7b79c70f80766f0a85c3e9ea713c`, job `118567684999`, `completed/success`. `checks.tsv`: **41/41 PASS**; `result.txt`: `PG18_LOGIN_AUDIT_RECEIPTS_SYNTHETIC_LIMITED_PASS`.

Artifact `f4-pg18-login-audit-receipts-cp177`, ID **12256624023**, ZIP recuperado e íntegro (`testzip()=None`), SHA-256 `e40f13a2254d9e8d41e14b87b3c758f6e2f1a0200e1f35a3d96d6aee240c014f`, coincidente com digest fornecido pelo GitHub. Nove arquivos incluem `checks.tsv`, `result.json`, `simulated-outside-db.jsonl`, `audit-anchor.json`, `commit.txt`, logs e versões. O SHA em `commit.txt` coincide com o commit do run.

## 4. Observações sobre privilégios PostgreSQL 18

O ensaio criou três roles distintas com `LOGIN` e senhas artificiais, além de `oes_ci_guard_owner NOLOGIN`. Foram verificadas identidade própria de conexão, ausência de acesso de runtime ao owner e duas formas diferentes de membership para migrator e ator elevado.

- **Runtime:** sem membership de owner; `SET ROLE` recusado; alteração do trigger 034 recusada.
- **Migrator restrito:** membro de owner com `INHERIT FALSE, SET FALSE, ADMIN FALSE`; nem herda os poderes do proprietário nem pode executar `SET ROLE`. Desabilitar o trigger 034 foi recusado.
- **Ator temporariamente elevado no ensaio:** membro de owner com `INHERIT FALSE, SET TRUE, ADMIN FALSE`; sem `SET ROLE`, não consegue alterar a tabela. Após `SET ROLE oes_ci_guard_owner`, conseguiu **desabilitar** e **reabilitar** o trigger 034 da tabela protegida no banco descartável.
- A role proprietária `NOLOGIN` não podia autenticar-se diretamente. Isso não impede `SET ROLE` quando outra credencial tem membership com `SET TRUE`.

**Implicação:** a capacidade de executar migrations com poderes de proprietário cria uma janela administrativa em que o guard também pode ser desabilitado. Não existe garantia dessa separação por `REVOKE` enquanto o executor puder tornar-se owner. O desenho operacional precisa restringir janela, escopo e arquivo de migration por hash, com autorização do titular, observação externa independente, pós-validação e revogação verificável. **Nenhum desses controles foi implementado no Neon.**

## 5. Recibos de auditoria fora da transação — simulação limitada

Um arquivo JSONL armazenado **no filesystem do mesmo runner de CI**, e portanto fora da transação do PostgreSQL, recebeu tentativas e resultados de quatro ações artificiais: desabilitação, reabilitação, DDL transacional seguida de `ROLLBACK` e `SET ROLE` recusado. Foram **oito recibos** (um `attempt` e um `result` por ação), sequenciados e ligados por SHA-256, com hash final em `audit-anchor.json`.

O teste observou que o recibo de tentativa e resultado de DDL revertido permanece no filesystem do runner mesmo quando o PostgreSQL desfaz o DDL. A verificação detectou adulteração do conteúdo, remoção de recibo intermediário, truncamento, reordenação e hash-âncora falsificado **quando a âncora íntegra foi mantida**.

**Limitação crucial:** filesystem e âncora estão sob o mesmo domínio de confiança da execução CI. Um agente que altere cadeia e âncora em conjunto pode reconstruir uma cadeia formalmente coerente. O modelo não garante assinatura externa, retenção imutável, cobertura de SQL administrativo direto no Neon, disponibilidade após a perda do runner, medição de timestamps confiável ou resistência contra adulteração privilegiada. **Não é uma auditoria externa independente nem um coletor operacional**. Nenhum serviço externo foi configurado.

## 6. Estado e gates

- `BRG-03`: PG18 descartável comprovou limites do `SET ROLE`, mas **Neon/TLS/ACL reais, segredos e DDL audit independente seguem pendentes**.
- `BRG-06/07`: ledger, fencing e runner operacionais não implantados/aprovados.
- `BRG-08`: backup/restore independente pendente.
- `BRG-09`: billing/consumo Neon no console do titular pendente.
- `POSTCONDITION_CATALOG=36_UNREVIEWED_0_APPROVED`; `MATRIX_034_036=36_NOT_COLLECTED`.
- `EXTERNAL_DDL_AUDIT=NOT_CONFIGURED`; `PAID_SERVICES=NOT_APPROVED`.
- `NEON_TEST_BRANCH=NOT_CREATED`; `NEON_SCHEMA_MIGRATION=NOT_STARTED`; `B1R1=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

## 7. Próximo passo

Em modo alto, delinear **plano de verificação para registros externos com âncora fora do domínio de confiança do runner**, incluindo falha de envio, lacunas não detectáveis sem recibo externo, cobertura de alterações diretas fora do pipeline e custo/eligibilidade Free. Qualquer recurso persistente ou com cobrança requer aprovação explícita do titular. A alternativa segura permanece bloquear o gate operacional enquanto não existir prova verificável e revisão especializada humana.

**Fim do Documento 133.**