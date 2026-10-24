# Documento 260 — PG-A3-G0: execução verificada e decisão pendente de G1

**OES | 2026-10-24 | Base main `21696ae25c3021d68b1dc3a0860bc91ded1a9b2c` | G0_EXECUTED_VERIFIED / G1_NOT_APPROVED**

## Resultado factual de G0

O proprietário autorizou expressamente `PG-A3-G0`. Foi criada **uma** branch isolada no projeto Neon existente `oes-sandbox` (`weathered-boat-65779510`, `aws-sa-east-1`), plano informado `free_v3` e limite observado de dez branches. Antes da criação havia apenas a branch principal.

- Origem, preservada: `production`, ID `br-wild-field-b6qg7k3p`, primary/default `true`.
- Nova branch: `oes-pg-a3-synthetic-20261024`, ID `br-gentle-hall-b6jaxehf`, parent_id `br-wild-field-b6qg7k3p`, primary/default `false`.
- Criação registrada pelo Neon: `2026-10-24T12:34:44Z`.
- Reconsulta do Neon nesta atividade: `current_state=ready`, sem computação provisionada para a nova branch (`no_compute: true` no pedido de criação; `compute_time_seconds=0` registrado).
- Não houve SQL, testes, migrations, inserts, carregamento de fixtures, integração Django ou alteração deliberada na branch principal. Não se criou outro projeto Neon nem se alterou `oes-d1-t2-a2-synthetic`.
- O status `ready` descreve a branch, **não** significa banco preparado para SQL ou prontidão operacional. A presença de branch pode consumir cotas mesmo sem endpoint de computação.

**Evidências verificadas:** retorno da criação `create_branch`, `get_branch` e `list_branches` após a criação; nova confirmação `get_branch` nesta atividade. Sem alegar inspeção de dados SQL ou ausência de qualquer efeito invisível além do escopo dessas consultas.

## Próxima decisão: PG-A3-G1 (minuta; NÃO AUTORIZADA)

Objeto: primeiro ensaio **somente sintético e isolado** na branch `br-gentle-hall-b6jaxehf`; habilitar computação exclusivamente nela, se necessário e mediante verificação de quotas/custos; executar `database/poc-s1.sql` e, **apenas se expressamente incluído na autorização**, `database/003_poc_s3_provenance_guard.sql`, com os hashes de conteúdo recalculados e HEAD confirmado imediatamente antes da execução.

Controles mínimos: confirmar identidades de projeto/branch e origem; conexão direta para schema; privilégios limitados ao necessário; compatibilidade do baseline integral; nenhum segredo em logs; registrar revisão e evidências de instalação; criar fixtures inteiramente inventadas; testar integridade de Study/Report, FKs, versionamento, relações e provenance; diferenciar falha de conexão, de migration e de semântica. **Não executar automaticamente migrations 002, 004–036**, nem editar Django, fazer GET científico, usar dados reais, tocar na principal ou promover schema de produção.

A ativação da computação e as escritas são atos materiais; uma autorização de G0 ou um simples `Prossiga` **não** as autoriza. Qualquer quota/custo novo, desvio de alvo ou evidência incompleta exige STOP. A exclusão da branch isolada exige autorização própria.

**Minuta curta proposta para autorização futura:**

`APPROVED — OES / PG-A3-G1 / SYNTHETIC_ISOLATED_NEON_TRIAL / project=weathered-boat-65779510 / branch=br-gentle-hall-b6jaxehf / baseline=poc-s1.sql / guard=003 OPTIONAL_SUBJECT_TO_EXPLICIT_CHOICE / NO_PRODUCTION_NO_FACTUAL_NO_PAID_SERVICES`

Essa frase é **proposta**, não autorização recebida. Para evitar ambiguidade, definir sim/não sobre 003 na aprovação final e separar as operações em atividades delimitadas, começando por preflight de computação e conexão.

## Estado e continuidade

`PG_A3_G0_EXECUTED_VERIFIED / PG_A3_G1_AUTHORIZATION_PENDING / NEON_BRANCH_ISOLATED_NO_COMPUTE`.

PG-A1, PG-A2 e especificação PG-A3 persistidos nos Documentos 256–259. CP270 permanece vigente até checkpoint proporcional posterior. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, prontidão `NOT_READY`, Fase 5 `NOT_STARTED`, D2-E6-G1 bloqueado, 36 migrations `UNREVIEWED`. Este registro é documental: **nenhuma operação Neon mutável nesta atividade**.

**STOP — aguardar autorização PG-A3-G1 específica antes de computação, SQL ou fixtures.**
