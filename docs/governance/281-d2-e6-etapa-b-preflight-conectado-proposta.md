# Documento 281 — Decisão de ensaio sintético conectado E6, etapa B

**OES | 2026-10-24 | CP274 | HEAD-base `93a288dc212a06b5b1d714d172da26eca2a07e0a` | PROPOSTA — AGUARDA APROVAÇÃO**

## Síntese da necessidade

Etapa A está validada em CI na run [40126123398](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40126123398): 63/63 testes PASS, sendo 6 do novo fluxo de leitura independente. **O teste conectado positivo ainda é necessário** para comprovar a interação real entre identidade de escrita, tabela privada, transação e leitura por identidade distinta; a simulação não prova isso.

Conforme Documento 276, o login descartável `oes_e6_capture_login` foi desativado (`NOLOGIN`) e sua associação ao writer foi revogada; a tabela privada foi observada vazia. A senha temporária anterior não deve ser reutilizada. A ferramenta bloqueou a tentativa anterior de INSERT positivo: não confundir ferramenta bloqueada com resultado SQL negativo.

## Proposta proporcional — uma única bateria conectada sintética

**Antes:** identificar viabilidade do acesso por ferramenta sem contornar bloqueios; confirmar branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, schema e concessões mínimas; definir forma protegida de credencial renovada sob controle do proprietário; manter `oes_e6_capture_login` indisponível até decisão de ativação distinta. Verificação independente deverá usar `oes_e6_verifier` em sessão/identidade efetivamente separada, não simplesmente conceder SELECT ao writer.

**Execução futura, sob nova autorização operacional específica:** inserir exclusivamente bytes sintéticos com identificador único na tabela privada, sob writer; verificar por leitor independente ID, comprimento e SHA-256 calculado dos bytes devolvidos; provar negações cruzadas (writer sem SELECT, verifier sem INSERT); registrar resultados sanitizados. Falhar fechado se ferramentas, autenticação, privilégio ou retorno seguro não permitirem essa separação.

**Depois:** remover somente a linha sintética inserida mediante procedimento de limpeza expressamente autorizado, verificar cardinalidade 0 e integridade da fixture PG-A4, revogar associação temporária e desativar login. Invalidate credencial para reuso, sem pressupor que apagar role apague histórico do SQL Editor.

## Fronteiras e critérios de parada

Este documento **não autoriza agora** SQL de alteração, recriação/reativação de login, concessões, gravação, leitura de JSON ou criação de secret. Não há uso de dados factuais, GET da ClinicalTrials.gov, habilitação de workflow, artifacts públicos, novas tabelas, novos serviços ou custos pagos. Se qualquer bloqueio técnico impedir a execução, documentar pendência e STOP; não buscar atalhos de privilégios.

Há duas decisões distintas: (1) pré-voo conectado **somente leitura** de catálogo/ACL sem reativar credenciais e sem acessar `raw_payload`; (2) autorização operacional específica posterior para credenciais e ensaio positivo/limpeza, somente se o pré-voo indicar viabilidade.

## Autorização solicitada neste gate

`APPROVED — OES / D2-E6 / STAGE_B_READ_ONLY_PREFLIGHT_ONLY / br-gentle-hall-b6jaxehf / no role changes / no credential changes / no writes / no raw payload reads / no factual GET / no workflow enablement / no paid services / fail closed`

**Estado:** `STAGE_A_CI_PASS / STAGE_B_PREFLIGHT_APPROVAL_PENDING / STAGE_B_WRITE_NOT_AUTHORIZED / E6_G1_BLOCKED`.

**STOP — aguardar autorização expressa do pré-voo.**
