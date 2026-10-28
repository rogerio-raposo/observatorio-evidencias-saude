# OES — CP327 | PF-I04/P4-A35–A38 — identidade temporária isolada e quatro SQLs sintéticos preservados sob HOLD

**Data:** 2026-10-28. **Checkpoint anterior:** CP326. **Natureza:** continuidade canônica, somente documentação/GitHub; nenhum SQL executado por assistente no Neon neste ciclo. **Freshness Gate:** main idêntica ao HEAD `97c4a1ebd65650dca712077c2a806c68efe58b30` antes de A38; idêntica a `0232bf0a21715af19b742ff90b6777413de10a31` antes deste checkpoint.

## 1. Estado factual do experimento
- Neon sintético: project `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, PostgreSQL 18, owner administrativo `oes_sandbox_owner`; não branch default. Endpoint DIRECT historicamente confirmado `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`; reconfirmar por metadados antes de gate. Nenhuma credencial no Git.
- Django: `oes_django_migrator` NOLOGIN, proprietário de 9 tabelas e 8 sequências no `oes_app`; associação com `oes_sandbox_owner`, OID **155649**, concedida por `cloud_admin`, ADMIN=true, INHERIT=false, SET=false. Deve permanecer intacta. `oes_runtime` sem membership e sem grants Django no escopo pré-GRANT; E9 NO-GO.
- P4-A27: auditoria v3 catalogal já executada, 946 checks + summary, 64 divergências esperadas e `SUMMARY/HOLD`, `PUBLIC=0` somente no escopo auditado. SQL A21 Django ainda HOLD incondicional. SQL original A29 para owner **NÃO EXECUTADO**.
- O responsável criou no Neon SQL Editor o login **`oes_p4_trial_login`** com LOGIN, NOINHERIT, sem flags administrativas, CONNECTION LIMIT 1, CONNECT `oes_sandbox`, senha com validade até `2026-10-31 03:30:53 UTC`. Consulta posterior fornecida pelo responsável confirmou **0 memberships** do login, acesso SET=false a migrator e owner, 1 associação original owner↔migrator e OID 155649 intacto. **Não pedir nem expor a senha.** Registro do login informado pelo responsável, não consulta conectada repetida pelo assistente.

## 2. P4-A35–A38
### P4-A35 — candidato separado HARD HOLD
- Novo workflow `.github/workflows/oes-pf-i04-p4-a35-connected-role-trial-candidate-hold.yml`, blob `41e1be3bad3aa0dee479306d8b55f6af321220ea`. Apenas `workflow_dispatch`. Job conectado `if: false`; `APPROVED_HEAD=NOT_AUTHORIZED` e `CREDENTIAL_LIFECYCLE_GATE=NOT_APPROVED`. Candidato ainda destinado a `oes_sandbox_owner` e SQL A29, **não adaptado ao novo login**. Nada executar. A32 testemunho offline permanece imutável (`if:false`); run 40622890545 OFFLINE SUCCESS / CONNECTED SKIPPED.
- Parecer `archive/handoffs/oes/artifacts/P4-A35/OES_PF-I04_P4-A35_WORKFLOW_CANDIDATO_E_GATE_CREDENCIAL.md`.

### P4-A36 — criação do login e baseline informados
- SQL de criação pelo responsável e consulta subsequente comprovaram estado restrito do login `oes_p4_trial_login`: zero memberships e ausência de SET para migrator/owner. Não houve concessão administrativa. No momento da continuidade, **o alvo sintético não foi criado** e o GitHub Secret NÃO cadastrado.

### P4-A37 — mudança para circuito inteiramente sintético
- **Decisão:** não associar migrator nem `oes_sandbox_owner` ao trial login, porque ADMIN TRUE permitiria concessão de membership sensível. Projetado `oes_p4_trial_target` NOLOGIN sem ownership, separado de Django/Q0. Setup futura criaria alvo e delegaria `ADMIN TRUE, INHERIT FALSE, SET FALSE` apenas neste alvo. Trial autenticada por trial login faria GRANT temporário próprio com SET TRUE → SET LOCAL ROLE → NONE → REVOKE grantor-aware → ROLLBACK. Postflight catalogal independente e cleanup são separadamente autorizáveis. Não prova equivalência com OID 155649 original.
- Parecer `archive/handoffs/oes/artifacts/P4-A37/OES_PF-I04_P4-A37_DECISAO_SINTETICA_E_HASHES_HOLD.md`; pacote local original `OES_PF-I04_P4-A37_SINTETICO_CANDIDATOS_HOLD.zip` SHA256 `bd9f71a95d504c4ec7217410a752369d4d8e04909bca63054889a807eea3dde8`.

### P4-A38 — QUATRO arquivos SQL integrais agora PERSISTIDOS em GitHub, auditados
- Diretório canônico `archive/handoffs/oes/artifacts/P4-A38/`. As quatro fontes A37 originais foram publicadas byte a byte **com Git blob SHA verificado contra git hash-object local**:
  1. `OES_P4_A37_SETUP_SYNTHETIC_TARGET_CANDIDATO_HOLD.sql`: SHA-256 `b2b2063eff27d6a0d5996aa2befcfc1922bae68fff249422cc25e1ab99dbb09b`, Git blob `fdf1b92880adb83c2343f31840b50a93b9385e83`; 9 statements, BEGIN→COMMIT. **MUTANTE, HOLD**.
  2. `OES_P4_A37_TRIAL_SYNTHETIC_ROLLBACK_ONLY_CANDIDATO_HOLD.sql`: SHA-256 `0ade6935a8d4a368c660f2c94de6a34b4a7d27f768aa87b8d5c8edf964c71b35`, Git blob `782ba277613bc31deffcea844168ee38bc0f84ef`; 19 statements, BEGIN→ROLLBACK, nenhum COMMIT; **MUTANTE TRANSITÓRIO, HOLD**.
  3. `OES_P4_A37_POSTFLIGHT_CATALOG_READ_ONLY_HOLD.sql`: SHA-256 `7648e3e320ba3fcdfbb535b47bfa1687c85ca969f301b9ab0b3ddfcb310d6c87`, Git blob `20d1618492a53d094b3120a60305720a0eac9c1d`; uma consulta catalogal, 12 checks esperados; **HOLD**, não foi autorizada.
  4. `OES_P4_A37_CLEANUP_SYNTHETIC_HOLD.sql`: SHA-256 `4cf8ff2bc8ac7ca520e6f90815da5b8d5ba7e016c4c43276f4c9f910157dc1df`, Git blob `c17c7b1368f1897c308866656e9a65e573ee6674`; 8 statements, BEGIN→COMMIT; **MUTANTE, HOLD**.
- Parecer independente `archive/handoffs/oes/artifacts/P4-A38/OES_PF-I04_P4-A38_AUDITORIA_E_GATE_HOLD.md` (Git blob `0ce269a285465ab013ff1fd0304624dd737fc607`). Scanner local de instruções e verificação de integridade **PASS estático**; **não testado contra parser/mecanismo PostgreSQL 18**.
- ACHADOS para próxima revisão:
  - **A38-R01 (BLOQUEANTE):** postflight não verifica todas as associações de terceiros do `roleid=target` ou `member=target`, nem dependências/ownership. Um terceiro pode escapar da validação; cleanup pode afetar associations sem inventário.
  - **A38-R02:** postflight verifica DB mas não `session_user/current_user` e não identifica branch, requer endpoint verificado e v2.
  - **A38-R03:** cleanup valida `NOLOGIN`, não comprova independentemente `PASSWORD NULL`; evitar ler `pg_authid` sensível sem gate específico.
  - **A38-R04:** ADMIN TRUE sobre alvo sintético ainda precisa janela restrita e certificação de ausência de privilégios/objetos, mesmo com NOLOGIN.
  - **A38-R05 (BLOQUEANTE):** workflow A35 atual está preso ao owner e A29. Precisa de workflow separado versionado para trial A37, com SHA nominal e `if:false` até autorização específica.
- **Resultado P4-A38:** `DOCUMENTARY_PERSISTENCE_PASS / STATIC_AUDIT_WITH_BLOCKERS / OPERATIONAL_HOLD`. Preservar originais imutáveis; corrigir em v2 separado, nunca modificar hashes canônicos A37 sem novo gate.

## 3. Protocolo e gates
- Cada `Prossiga` aprova uma atividade interna delimitada. Freshness Gate no início e antes de gravações. Checkpoints 3–5 atividades/risco. Mensagens de progresso; STOP ao final.
- O setup é **persistente** (CREATE ROLE/GRANT/COMMIT); o trial é **transitório** (GRANT/REVOKE/SET LOCAL ROLE e ROLLBACK); postflight é um SELECT catalogal independente; cleanup é **persistente** (ALTER ROLE/REVOKE/DROP/COMMIT). Cada um requer **gate nominal distinto**, especialmente operações conectadas READ ONLY.
- GRANTs de papéis são compartilhados pelo cluster PostgreSQL; isolamento relevante é branch Neon e identity do endpoint, não apenas `current_database()`. Nunca usar default/produção. Nenhum segredo foi criado pelo assistente.
- **Permanecem:** Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY, Fase 5 NOT_STARTED.

## 4. Retomada segura
**PF-I04/P4-A39 — OFFLINE V2 CORRECTION ONLY.** Criar um **novo postflight v2** com inventário de memberships do alvo nos dois sentidos, estado do target/login, nenhuma associação inesperada de terceiros, identidade de sessão/versão, e dependências/ownership em escopo viável; revisar setup/cleanup conforme achados, com nova identidade SHA. Não executar os SQLs A37 preservados, não criar role-alvo, não cadastrar segredo e não remover as travas A32/A35 apenas por `Prossiga`. Depois de revisão estática, preparar gates nominais independentes de setup, trial, postflight e cleanup. Nada de GRANT Django/Q0, E9, HTTP, deploy ou serviços pagos.
