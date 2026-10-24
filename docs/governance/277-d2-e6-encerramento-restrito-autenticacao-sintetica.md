# Documento 277 — Encerramento restrito da bateria de autenticação sintética E6

**OES — 2026-10-24 | CP274 | Base documental: Documentos 269–276 | HEAD de preparação:** `898042e2d3ae9aa330a23fe06e22751f4563917c`  
**Classificação:** encerramento técnico **parcial**, apenas dos testes de identidade e isolamento realizados; **não** encerra D2-E6 nem habilita E6-G1.

## 1. Escopo executado
Na branch Neon experimental `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, criou-se `oes_e6_capture_login` por SQL sem poderes administrativos, com associação restrita e temporária a `oes_e6_writer`. Credencial descartável foi configurada pelo proprietário no Neon SQL Editor, sob exceção de risco de histórico expressamente aceita apenas para estes testes.

A autenticação conectada pelo papel `oes_e6_capture_login` foi comprovada por `current_user=session_user`. Sem assumir o writer, `SELECT` e `INSERT` na tabela privada foram negados; `SELECT` na fixture `evidence.study` também foi negado. Inventário de roles confirmou ausência de `neon_superuser`, `SUPERUSER`, `CREATEDB`, `CREATEROLE`, `REPLICATION` e herança automática.

## 2. Limite da evidência
A tentativa de `INSERT` positivo sintético com `SET LOCAL ROLE oes_e6_writer` foi **bloqueada pela ferramenta antes de resultado SQL**. Por isso, NÃO considerar a escrita positiva, verificação de digest pós-leitura ou limpeza de registro inserido como executadas. Os testes sintéticos anteriores de constraints e de `SET ROLE` negativo no Documento 271/272 são evidências distintas; não substituem autenticação positiva do writer.

## 3. Encerramento dos acessos
Após ação manual do proprietário, nova consulta conectada confirmou `rolcanlogin=false`, `rolinherit=false` e **nenhuma associação de papel** remanescente para `oes_e6_capture_login`. Tabela `oes_raw_private.source_observation` com **0 linhas**. Nenhum dado factual foi capturado.

**Riscos residuais:** `NOLOGIN` barra novas conexões mas não comprova encerramento de sessões prévias; a senha temporária pode permanecer no histórico restrito do SQL Editor e na configuração do papel. Não reutilizar a senha; antes de reativação exigir troca/invalidação e autorização explícita. Não declarar a bateria como integralmente PASS.

## 4. Fronteiras e próximo gate
Workflow `.github/workflows/d2-e6-a2-gated-capture.yml` permanece com `if: ${{ false }}` e caminho antigo de artifact público incompatível com política posterior. Não executá-lo. Não há autorização de novo secret, coleta factual E6-G1, serviços pagos ou promoção a produção.

A próxima atividade proporcional é revisar os testes pendentes e decidir o mínimo necessário para avançar na **implementação offline** do destino PostgreSQL privado, antes de reabrir credenciais ou conectividade; essa implementação exige gate distinto.

**Estado:** `SYNTHETIC_AUTH_BATTERY_CLOSED_PARTIAL / NEGATIVE_ACCESS_PASS / POSITIVE_WRITE_NOT_TESTED / LOGIN_DISABLED_VERIFIED / E6_G1_FACTUAL_BLOCKED`.

**STOP — conclusão documental, não liberação operacional.**
