# 128 — Ensaio comportamental PostgreSQL 18 das migrations temporais 034–036

**OES — Fase 4 | 2026-10-19 (America/Recife) | modo alto**  
**Status:** TEMPORAL_034_036_SYNTHETIC_BEHAVIOR_30_CHECKS_PASS_PINNED_COMMIT_ONLY — NO_NEON_WRITE — POSTCONDITIONS_UNREVIEWED.  
**Entrada:** CP171, HEAD `e8219a04ab322eb51d401ce37177e5f5e33b1cba`.

## 1. Continuidade e alcance

O Freshness Gate na entrada mostrou `main` **identical**, zero drift, e o ponteiro canônico apontava CP171. Foram examinados os SQL reais 034, 035 e 036 e as definições de tabelas, guards e funções de apoio da migration 033. Nenhuma operação ocorreu no Neon e não houve criação de branch, role, schema ou ledger Neon.

Criados apenas artefatos de teste:
- `tests/fixtures/f4-temporal-034-036/seed.sql`: produto, plan, source, epoch, duas oportunidades, artefato de controle e **registro artificial de autoridade** somente para permitir exercitar a lógica; nenhuma pessoa autorizou execução, cronologia ou coleta.
- `scripts/oes_f4_pg18_034_036_behavior_test.py`: harness de teste em PostgreSQL 18 descartável, com destino CI-only fixo, recusa `DATABASE_URL`/`PGSERVICE`, instalação 001–036 no banco temporário e asserções positivas/negativas. **Não é um runner operacional.**
- `.github/workflows/f4-pg18-034-036-temporal-behavior.yml`: GitHub-hosted `postgres:18`, `contents:read`, acionamento automático apenas quando caminhos próprios mudam, upload de evidência `if:always()`, sem Neon.

## 2. Runs e correção rastreável

**Execução inicial #39355352898**, commit `85bb17b81fac44f3a59f4cd7b61ba7cd9eb694a4`, job `118408743099`, **completed/failure**. Instalou as 36 migrations mas o fixture inicial reutilizava `tests/fixtures/f4-grandfathering-032/seed.sql`. Esse fixture pré-032 incluía um payload de calendário SLA rejeitado quando usado **após** as migrations até 036 (`SLA calendar payload invalid`). A falha estava na **composição do fixture**, não foi falha da instalação das 36 migrations nem dos testes 034–036. Artifact inicial `12234058781` preservado pela CI.

**Correção prospectiva:** removeu-se a reutilização do fixture pré-032; o fixture temporal mantém somente o produto sintético vinculado ao registro central e os objetos artificiais indispensáveis à prova 034–036, evitando povoar calendário/SLA desnecessários. Nenhum SQL histórico de migration foi modificado.

**Execução corrigida #39355448709:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39355448709. Commit fixado `d0c378a99b36f331bc1f5df627cd024448a421e1`, job `118409046787` = `completed/success`. PostgreSQL servidor **18.6**, cliente conforme `psql-version.txt` no artifact. Logs exibem `SYNTHETIC_TEMPORAL_034_036_BEHAVIOR_PASS_LIMITED`.

Artifact `f4-pg18-034-036-temporal-behavior`, ID **12235255740**; ZIP local integralmente lido, 9 entradas, `testzip()` íntegro, SHA-256 dos bytes **`a9326e8d6d5aa3a2f282460ed3465be295767f6d2d513c4f2d1986523b8e2442`**, idêntico ao digest GitHub. O arquivo `checks.tsv` contém **30/30 PASS**; `commit.txt` corresponde ao commit testado; `preflight.json`, `negative-controls.log` e `report.json` sustentam a classificação.

## 3. Comportamentos verificados

| Migration | Prova positiva limitada | Controles negativos reproduzidos |
|---|---|---|
| **034 — `assert_temporal_epoch_activation_chronology`** | Trigger `BEFORE UPDATE` habilitado, associado à função certa; epoch sintética com autoridade artificial aprovada no passado, oportunidade congelada e `started_at` anterior à primeira oportunidade pôde passar de `authorized_non_normative` a `active` | Recusou `started_at` ausente; recusou `started_at` igual ao primeiro `planned_for`; recusou desvio material/invalidating registrado antes da ativação. Transação com desvio falhou e não deixou a linha de teste persistida |
| **035 — `temporal_activation_preflight` e `..._state`** | Duas funções instaladas; epoch autorizada e consistente retornou `WAIT` antes da janela e `PASS` dentro dela; relatório detalhado conferido; nenhuma MeasurementEvent criada pelo preflight | UUID de epoch ausente: `FAIL`; epoch ainda `draft`: `FAIL`; instante de preflight igual à primeira oportunidade: `FAIL` com `ACTIVATION_WINDOW=FAIL` |
| **036 — `assert_temporal_first_measurement_semantics`** | Trigger `BEFORE INSERT` habilitado e associado à função; primeiro evento concluído aceito com `novelty_state='not_applicable'`, `new_identifier_count IS NULL`, `failure_attribution='not_applicable'`; segundo evento concluído aceito com `novelty_state='zero_new'`, contagem nova zero, mesma atribuição não aplicável | Primeira conclusão com `zero_new` rejeitada; primeira com `new_identifier_count` não nulo rejeitada; segunda com `not_applicable` rejeitada; conclusão com `failure_attribution='unknown'` rejeitada |

Os erros SQL esperados — `active epoch requires started_at`, ordem temporal inválida, desvio material e violações de novelty/attribution — são **contraprovas esperadas**, não falhas administrativas do run aprovado.

## 4. Limitações explícitas

1. O registro `actor_type='human_reviewer'` no fixture é artificial e identificado como `SYNTHETIC-FAKE-AUTHORITY-NOT-A-HUMAN`: **nenhuma aprovação humana real ocorreu**.
2. As datas 2030 foram usadas artificialmente para cenários de janela, **não** representam reativação de B1R1 ou cronograma operacional.
3. A simulação não cobre integração de fontes externas, evidência científica, SearchHit, cadeia de proveniência, dados clínicos, timezone heterogêneo, replay, falhas simultâneas, escalabilidade nem concorrência.
4. Prova que regras selecionadas **atuaram**, não que toda semântica temporal ou todos os ramos das funções estejam corretamente cobertos.
5. Não comprova segurança transacional completa de `DROP TRIGGER / CREATE TRIGGER` nas migrations 034/036: a contraprova de parcialidade está no Documento 126.
6. Nenhum teste é autorização de execução no Neon nem aprovação metodológica. **BRG-06 e BRG-07 continuam sem ledger/runner operacional; BRG-03/08/09 permanecem pendentes.**
7. **Catálogo principal das 36 migrations permanece `UNREVIEWED`, zero pós-condições de reconciliação formalmente aprovadas, todas as flags de replay/execução/reconciliação automáticas em `false`.**

## 5. Continuidade proposta

Após novo `Prossiga`, recomenda-se avaliar lacunas na cobertura comportamental (fonte ausente, autoridade ausente/conflitante, conexão bloqueada, oportunidades não materializadas, desvios após `started_at`, dados intercalados e gatilhos desabilitados) antes de qualquer formulação de pós-condições aprováveis. Planejar revisão independente humana de PostgreSQL e metodologia antes de integrar catálogo/ledger a migrations. Continuar no PostgreSQL 18 descartável, sem operações Neon por comando genérico.

`NEON_TEST_BRANCH=NOT_CREATED`; `NEON_SCHEMA_MIGRATION=NOT_STARTED`; `B1R1_ACTIVATION_WINDOW=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

**Fim do Documento 128.**