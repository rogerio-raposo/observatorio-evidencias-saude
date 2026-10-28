# OES — PF-I04/P4-A32 | Workflow GitHub Actions manual com HARD HOLD

**Data:** 2026-10-27. **Status:** `OFFLINE_WORKFLOW_PREPARED / CONNECTED_JOB_DISABLED / OPERATIONAL_HOLD`. **Checkpoint vigente:** CP325. **Natureza:** preparação e implantação de artefato de CI **somente para preflight offline**; nenhuma conexão, SQL mutante ou READ ONLY ao Neon foi efetuado nesta atividade.

## 1. Decisão e artefato

Novo workflow `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml` com `workflow_dispatch` exclusivamente. O job `offline-contract` executa somente checagens locais de integridade, sem segredos ou conexões. O job `connected-role-trial` tem **`if: ${{ false }}` incondicional**, constituindo HARD HOLD: nenhuma entrada do acionamento manual, segredo, condição ambiental ou alteração na branch pode ativá-lo sem modificar e revisar o código do workflow em um novo commit.

**Nenhum acionamento do workflow foi autorizado ou feito em P4-A32.** Publicar o arquivo não significa executar o ensaio. O job conectado contém uma sequência *futura e inativa* para referência, não habilitada.

## 2. Escopo de destino verificado via metadados Neon READ ONLY

- Projeto `weathered-boat-65779510`.
- Branch sintética `br-gentle-hall-b6jaxehf`, nome `oes-pg-a3-synthetic-20261024`, `default=false`, `primary=false`, `protected=false` na consulta de metadados desta atividade.
- Endpoint write da branch **direto, sem `-pooler`**: `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`; ID de endpoint `ep-wispy-dream-b6021bw0`. Existe outro endpoint `ep-royal-wave-b6c1oahh...` da branch default e **não deverá ser utilizado**.
- Database `oes_sandbox`, papel `oes_sandbox_owner` (conexão futura não testada).
- Metadados podem mudar: **reconfirmar endpoint→branch e custos antes de qualquer autorização de execução**. Host pinado não é prova criptográfica permanente do ID de branch nem valida credencial ou política TLS; exigir controle adicional de aprovação.

## 3. Fontes fixadas e verificação

- Ensaio A29 `archive/handoffs/oes/artifacts/CP325/OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql` — SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`. Contém **GRANT/REVOKE temporários de associação**, `SET LOCAL ROLE`, `BEGIN`, `ROLLBACK`; **não executar sem gate nominal operacional**.
- Postflight A29 `archive/handoffs/oes/artifacts/CP325/OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql` — SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`. Consulta independente, somente catalogal, **não habilitada no workflow** e sujeita a autorização própria.
- Job offline verifica ambos SHA-256 e controles sintáticos básicos, BEGIN e ROLLBACK finais, ausência de `COMMIT;` standalone, e verifica que a expressão `if: ${{ false }}` continua literalmente presente no job conectado.
- Validação local de estrutura YAML e execução dos dois passos offline contra cópias byte-idênticas dos SQLs: **PASS**. Nenhum servidor PostgreSQL foi utilizado nem parser GitHub Actions remoto; não declarar aprovação operacional antes de executar a CI offline sob gate proporcional.

## 4. Barreiras concretas

1. `workflow_dispatch` apenas, sem `push`, `schedule`, PR, HTTP ou deploy; permissões GH `contents: read`; checkout sem credenciais persistentes e escopo de `github.repository`/`main`.
2. `concurrency.cancel-in-progress=false` e timeout. A existência do workflow não é autorização para acioná-lo.
3. Job conectado com `if: ${{ false }}` e sem dependência de entrada configurável; nenhum segredo do banco existe ou foi consultado/cadastrado nesta atividade.
4. Template futuro exige segredo descartável **`OES_P4_A32_OWNER_PASSWORD_ONETIME`**, que **não deve ser criado agora**. Proíbe mostrar password, URL com password ou logs crus. Futuros custos de Actions precisam ser verificados contra a política de não usar serviços pagos.
5. Template futuro usa `psql -X -v ON_ERROR_STOP=on -v ON_ERROR_ROLLBACK=off`, **sem `-1`**, e arquivo imutável terminado por ROLLBACK, sem repetição. Log da transação fica no diretório efêmero do runner, **não é publicado**; são examinados somente quatro marcadores de identidade/PID/membership e `ROLLBACK` final. Uma falha é HOLD sem retry.
6. **Postflight independente não roda neste job.** Novo gate nominal, novo processo/sessão, sem alterar dados e confirmando retorno integral `SUMMARY/PASS` são condições futuras. PASS isolado no postflight não prova o ensaio.
7. Nenhum GRANT de tabelas/colunas/sequências, Django login, Q0/HTTP, papéis novos, senha alterada, aplicação ou E9 autorizados.

## 5. Riscos e pendências

- A camada GitHub Actions não comprova como o executor se comportará diante de erro de rede/timeout durante a transação. Fechamento de conexão normalmente aborta transação aberta; **resultado incerto exige postflight diagnóstico**, nunca retry automático.
- O `psql` e o login via credencial descartável ainda não foram testados contra o Neon; tampouco há confirmação de política de custos do GitHub Actions. Fluxo conectado segue **NO-GO**.
- Para ativar o job, exigir **aprovação nominal específica de um novo diff do workflow e hashes imutáveis**, confirmação atual do endpoint e política de gastos, capacidade do papel de login, armazenamento transitório do segredo e pré-autorização separada do postflight. Não remover `if: false` a partir de mera mensagem `Prossiga`.
- A SQL administrativa A21 de GRANTs Django permanece **HOLD incondicional**. O teste A29 é limitado a associação temporária e rollback; não confundir com operacionalização da aplicação.

## 6. Resultado e continuação

**P4-A32:** somente preparação e persistência de workflow manual com bloqueio incondicional. Nenhuma execução do workflow, Neon, GRANT/REVOKE/SET ROLE, nenhum segredo, alteração de banco, deployment ou serviço pago.

**Próximo P4-A33 recomendado:** executar somente revisão offline de arquivo/controle de custos e, se houver autorização apropriada, considerar acionamento do job offline sem DB para comprovar validação real do GitHub Actions. **Não ativar o job conectado.** Checkpoint CP325 permanece vigente; consolidar P4-A31–A33 em CP326 por risco/proporcionalidade.
