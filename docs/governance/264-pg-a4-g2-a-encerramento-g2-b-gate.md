# Documento 264 — PG-A4-G2-A encerrado; autorização proposta PG-A4-G2-B

**OES | 2026-10-24 | CP271 | HEAD da execução `1fb158826d315eafa30ccf74fa35cc5786e7b5c3` | G2_A_CONNECTED_PASS / G2_B_NOT_AUTHORIZED**

## Evidência do encerramento PG-A4-G2-A
Execução manual [GitHub Actions 40104902381](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40104902381), `main`, resultado `success`. Logs registraram `PASS PG_A4_DJANGO_CONFIG_PREFLIGHT_NO_CONNECTION` e `PASS PG_A4_G2_A_DJANGO_CONNECTED_READ_ONLY_EMPTY`. Houve inicialização Django, autenticação real com `oes_pg_a4_reader`, checagem de identidade, banco `oes_sandbox`, sessão `transaction_read_only=on` e execução da função `list_synthetic_study_report_links()` com retorno vazio. A branch Neon permaneceu sem fixtures; nenhuma migration ou escrita foi realizada na demonstração.

Os ensaios anteriores 40104184405 e 40104439246 falharam antes da conexão, respectivamente por importação `config` e ausência de alias `default`; correções persistidas nos commits `e42870f875b13253e9d7b8c9179f1447d8e7292c` e `af75a279a18d0a96af5d523b2948e7fa0e36e2c6`. O pré-teste sem segredo foi acrescentado no commit `1fb158826d315eafa30ccf74fa35cc5786e7b5c3`.

**Segurança e limite da evidência:** após a execução bem-sucedida, o usuário **confirmou** a rotação da senha temporária no Neon e exclusão do segredo `OES_PG_A4_PASSWORD` no GitHub Actions. Essa confirmação humana não equivale a auditoria independente de exclusão. Nenhum valor de senha consta deste registro. Workflow conectado permanece manual; não acioná-lo sem nova credencial temporária e autorização.

## Proposta delimitada PG-A4-G2-B — ainda não autorizada

Objetivo: comprovar projeção tipada Study–Report N:M e referência de proveniência **somente com registros artificiais** na branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`.

1. **Preparação documental/código:** elaborar fixture SQL idempotente ou com transação controlada, validada contra `database/poc-s1.sql`, contendo exatamente 2 entidades Study, 2 Report, versões correntes, 3 vínculos N:M e pelo menos uma referência artificial de proveniência; identificadores reservados sem NCT real, marcação explícita `SYNTHETIC_TECHNICAL_ONLY`. Revisar constraints e política de limpeza; nenhuma escrita ainda.
2. **Gate de escrita específico:** após revisão e autorização separada, executar inserção apenas na branch sintética com papel administrador de teste; confirmar previamente HEAD, branch, plano Free, tabelas e ausência de conflitos. Nunca usar `oes_pg_a4_reader` para escrita.
3. **Leitura Django:** executar consulta com `oes_pg_a4_reader`, projetar 3 vínculos e proveniência, validar cardinalidade e identidades; segredo temporário exclusivamente em CI manual controlada e rotação/exclusão imediatamente após.
4. **Saída:** registrar evidências, distinguir falha de software versus dados, e submeter eventual exclusão/rollback posterior a decisão expressa. Sem produção, dados factuais, reconciliação de NCT, novos endpoints ou migrations.

**Exclusões e STOP:** não criar fixtures, credenciais, secrets ou serviços nesta atividade documental. Estado operacional `NOT_READY`; D2-E6-G1 não autorizado, 36 migrations ainda `UNREVIEWED`, Fase 5 `NOT_STARTED`. CP271 vigente até próximo checkpoint de continuidade proporcional.

**Próxima decisão:** autorização específica apenas da preparação de fixture PG-A4-G2-B, sem inserção no Neon.
