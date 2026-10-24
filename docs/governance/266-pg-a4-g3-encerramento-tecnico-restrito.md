# Documento 266 — Encerramento técnico restrito de PG-A4-G3

**OES | 2026-10-24 | CP272 | HEAD de validação `36033f646a55100a9e38d6c48e4f9febda123020` | PG_A4_CLOSED_SYNTHETIC_TECHNICAL_RESTRICTED**

## Decisão de encerramento
PG-A4-G3 é considerado **tecnicamente encerrado no âmbito estritamente sintético e experimental**. Este fechamento não corresponde a prontidão operacional, publicação científica, liberação factual, promoção de fase ou implantação de serviço.

## Evidência de aceite
1. PG-A4-G0: papel `oes_pg_a4_reader` autenticado efetivamente no Neon e com privilégios SELECT limitados, sem permissão de escrita nas estruturas avaliadas.
2. PG-A4-G1: Django possui conexão PostgreSQL opcional, serviço interno de projeção Study–Report–proveniência e preservação das rotas JSON. Workflow offline inicial [40102803355](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40102803355): 32/32 PASS.
3. PG-A4-G2-A: [40104902381](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40104902381): Django conectado em sessão read-only, identidade restrita, retorno vazio correto antes da carga.
4. PG-A4-G2-B: fixture artificial `database/fixtures/pg_a4_g2b_synthetic.sql` executada transacionalmente apenas na branch de ensaio; leitura posterior confirmou 2 Studies, 2 Reports, 3 vínculos N:M e 1 proveniência. [40110909348](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40110909348): CI conectada `success`, com `PASS PG_A4_G2_B_DJANGO_CONNECTED_THREE_LINKS_ONE_PROVENANCE`.
5. PG-A4-G3: [40111540817](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40111540817) sobre `36033f646a55100a9e38d6c48e4f9febda123020`: `manage.py check` PASS, **33/33 testes Django PASS** incluindo teste `test_unavailable_connection_raises_instead_of_returning_empty_result`. Falha de conexão **simulada** (mock); nenhuma interrupção real do serviço foi provocada. Serviço propaga erro, em vez de reinterpretá-lo como conjunto vazio.

## Ambiente e limites
Projeto Neon `oes-sandbox` (`weathered-boat-65779510`), branch **não principal** `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, endpoint `ep-wispy-dream-b6021bw0`, role `oes_pg_a4_reader`. A branch `production` não foi alterada. Nenhum endpoint Django público novo, migration nova, ingestão factual, associação inferida de NCT ou mudança das páginas JSON. Os dados permanecem marcados `SYNTHETIC_TECHNICAL_ONLY`. O teste negativo prova tratamento explícito em simulação, não disponibilidade, recuperação ou resiliência operacional.

**Credenciais:** o usuário confirmou após o último ensaio conectado a alteração da senha temporária e exclusão do secret GitHub Actions `OES_PG_A4_PASSWORD`; não houve auditoria independente de remoção. Nenhuma senha/URI credenciada é registrada aqui.

**Fixtures:** os quatro registros de entidade, suas versões, três vínculos e um registro de proveniência **permanecem na branch sintética**. Retenção provisória deliberada; remoção, descarte ou nova execução da fixture exigem decisão específica.

## Continuidade e restrições
PG-A4 `CLOSED_SYNTHETIC_TECHNICAL_RESTRICTED`; evolução posterior só mediante novo escopo aprovado. CP272 permanece ponteiro até próximo checkpoint. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, `NOT_READY` para operação, D2 `PARTIAL`, E6-G1 `NOT_APPROVED`, M3 `BLOCKED`, BRG/SA pendentes, 36 migrations `UNREVIEWED`, Fase 5 `NOT_STARTED`. A próxima decisão é sobre retenção versus limpeza das fixtures e priorização de integrações, sem antecipar autorização.
**STOP.**
