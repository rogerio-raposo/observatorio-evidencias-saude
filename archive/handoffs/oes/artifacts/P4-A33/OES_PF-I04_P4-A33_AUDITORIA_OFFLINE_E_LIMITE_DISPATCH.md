# OES — PF-I04/P4-A33 | Auditoria offline e disponibilidade de GitHub Actions

**Data:** 2026-10-27. **Situação:** `LOCAL_OFFLINE_CHECK_PASS / GITHUB_ACTIONS_DISPATCH_NOT_PERFORMED / CONNECTED_JOB_HARD_HOLD`. **Checkpoint de referência:** CP325. **Freshness Gate:** `main` idêntica ao commit `3766625be6af3f413d722f6d73aad814d09eaa64` antes desta nota.

## 1. Custos e metadados verificados
- O repositório `rogerio-raposo/observatorio-evidencias-saude` retorna visibilidade `public`, default branch `main`, `archived=false` por metadados do plugin GitHub.
- GitHub Docs (consulta 2026-10-27): **standard GitHub-hosted runners** são gratuitos para repositórios públicos; o job offline usa `runs-on: ubuntu-latest`, `timeout-minutes: 5`, nenhuma ação premium, nenhum segredo e nenhum upload de artefatos. Referência: https://docs.github.com/en/actions/concepts/billing-and-usage . Não equivale a inspeção de extrato financeiro, mas não há cobrança de minutos prevista para o cenário.
- Workflow preservado no SHA Git blob `955de382252e10a287880f387111b2f35d755daf`, caminho `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml`. `workflow_dispatch` exclusivamente; `offline-contract` restrito ao repositório e `refs/heads/main`; job `connected-role-trial` fixado em `if: ${{ false }}`.

## 2. Teste offline efetivo (local, NÃO no GitHub Actions)
- Arquivo A29 trial SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`: **PASS**, bytes locais conferidos.
- Arquivo A29 postflight SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`: **PASS**, bytes locais conferidos.
- Testes do roteiro SQL: `BEGIN` primeira instrução, `ROLLBACK` última, `COMMIT` ausente, GRANT e REVOKE **somente documentados e não executados**, quatro marcadores de evidência presentes; estrutura do postflight `WITH ... SELECT` identificada: **PASS estático**.
- Contrato YAML conferido pelo plugin: apenas gatilho manual, `if: false` textual, branch guard e hashes dos dois arquivos presentes. **Não foi realizada execução do YAML em runner**; não afirmar teste end-to-end ou reconhecimento da sintaxe no GitHub.

## 3. Motivo de não acionamento
- O conjunto instalado de ações GitHub expõe consulta de arquivos, commits, jobs/logs e outros recursos, mas **não disponibiliza a operação `workflow_dispatch`**. A ação de fetch é GET e não permite POST no endpoint de dispatch. Neste ambiente não há CLI `gh` nem `GH_TOKEN`/`GITHUB_TOKEN` disponível.
- **Nenhum workflow foi disparado pelo assistente.** Não houve conexão, leitura de dados ou SQL no Neon, nenhuma credencial foi criada/consultada, nenhuma operação administrativa ou tentativa de rollback.
- Não inventar ID de run, conclusão PASS remota ou alegação de testes via GitHub Actions.

## 4. Uma única execução manual permitida no escopo offline
- Abrir https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml
- Selecionar `Run workflow` → branch `main` → `Run workflow`. Nenhuma entrada, segredo, senha ou mudança do YAML é necessária.
- Resultado esperado: job `offline-contract` em SUCCESS com `OFFLINE_PASS` e `HARD_HOLD_CONFIRMED`, job `connected-role-trial` em **SKIPPED**, e **zero conexões Neon**.
- Somente classificar `GITHUB_OFFLINE_PASS` após comprovação factual do resultado real, incluindo job conectado SKIPPED. Se erro, HOLD; não repetir automaticamente.
- Proibido ativar job conectado, remover `if: false`, cadastrar segredo, executar SQL A29 ou fazer dispatch de outra branch sem gate nominal próprio.

## 5. Ponto de retomada
**P4-A33 mantém `GITHUB_REMOTE_RUN_PENDING`** apesar do êxito offline local. Próxima ação proporcional: obter ID/link do único run manual offline e conferir jobs/logs usando o plugin GitHub; concluir A33 somente se houver evidência de `offline-contract SUCCESS` e `connected-role-trial SKIPPED`. Ou registrar formalmente teste remoto diferido e avançar para CP326 sem declarar validação remota. Gates OES inalterados.
