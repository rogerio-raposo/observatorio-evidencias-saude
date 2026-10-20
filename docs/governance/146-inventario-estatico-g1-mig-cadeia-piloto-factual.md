# 146 — Inventário estático G1-MIG da cadeia de migrations para piloto factual prospectivo

**OES | 2026-10-20 (America/Recife) | CP190 | modo médio**  
**Estado:** `G1_MIG_STATIC_INVENTORY_COMPLETE_ORDER_NOT_APPROVED`; estritamente análise de artefatos GitHub, sem SQL executado, CI, acesso Neon ou alteração de ambiente.

## 1. Continuidade e fundamento

Freshness Gate CP189/main `8a799c86caf900bcf9d149620ee19d91de97c37e`: identical, ahead/behind 0. Ponteiro CP189, handoff CP189, Documento 145, política `docs/architecture/30-politica-migracoes.md`, `database/README.md`, manifesto `database/f4-neon-sandbox-schema-migration-manifest.txt`, catálogo `database/f4-reconciliation-postconditions-draft.json`, arquivos 033–036 e STATE/CHANGELOG consultados. A autorização `PREPARE_G1_DOCUMENTARY_ONLY` não autoriza execução ou promoção de estados do catálogo.

## 2. Contagem, entradas e proveniência

O manifesto possui **36 entradas de execução ordenadas**, começando por `database/poc-s1.sql` e terminando em `database/036_temporal_first_measurement_semantics.sql`. O catálogo draft contém **36 registros**, todos `UNREVIEWED`, `migration_execution_allowed=false`, `automatic_replay_allowed=false`, sem pós-condições aprovadas.

As entradas 031, 032 e 033 são **wrappers psql**, que incluem respectivamente **cinco**, **quatro** e **cinco** arquivos subordinados por `\\ir` (14 arquivos ao todo). Os arquivos subordinados **não** constituem entradas independentes no manifesto. A execução por drivers SQL que não interpretam `\\ir` falharia ou seria incompleta. A política de migrations exige verificar hashes, identidade exata, dependências, transaction boundary, ledger, evidência independente e pós-condições antes de habilitar execução.

**Sequência de referência, sem autoridade de replay:** `poc-s1 → 002…030 → 031 [031a–e] → 032 [032a–d] → 033 [033a–e] → 034 → 035 → 036`.

## 3. Classes funcionais e necessidade de revisão

| Grupo | Entradas | Finalidade documental | Situação para P-B |
|---|---|---|---|
| BASE_001_011 | 001–011 | PoC basal, proveniência, ficha e assurance | DEPENDENCY_REVIEW_REQUIRED |
| PRODUCT_012_020 | 012–020 | Produtos científicos, avaliação e projeções | DEPENDENCY_REVIEW_REQUIRED |
| MONITOR_ALERT_021_026 | 021–026 | Monitor e Alert; dependências transversais, não prova de M3 | DEPENDENCY_REVIEW_REQUIRED |
| UPDATE_027_030 | 027–030 | UpdateProtocol, auditoria e controles operacionais/riscos | DEPENDENCY_REVIEW_REQUIRED |
| PROPAGATION_031 | 031 (wrapper) | Propagation/rebaseline; cinco arquivos 031a–031e | DEPENDENCY_REVIEW_REQUIRED |
| CALIBRATION_032 | 032 (wrapper) | Pré-requisitos de calibração; quatro arquivos 032a–032d | DEPENDENCY_REVIEW_REQUIRED |
| OBSERVATION_033 | 033 (wrapper) | Observação temporal não normativa; cinco arquivos 033a–033e | DEPENDENCY_REVIEW_REQUIRED |
| ACTIVATION_034_036 | 034–036 | Cronologia de ativação, preflight e primeira medição | DEPENDENCY_REVIEW_REQUIRED |

**Decisão:** não declarar quais entradas são dispensáveis sem provar dependências de schema, FKs, funções, triggers, provenance e autoridade nos arquivos. A hipótese de um subconjunto pequeno para P-B é **UNVERIFIED**. A ordem completa do manifesto é baseline **candidata sintética**, não plano aprovado de instalação factual.

## 4. Camada temporal particularmente relevante

| Arquivo | Evidência observada na leitura estática | Implicação |
|---|---|---|
| 033 | Cria componentes de observação não normativa; wrapper depende de 001–032 e invoca 033a–033e | Base para plans/epochs/opportunities/events, sem fatos históricos automáticos |
| 034 | Trigger de cronologia verifica `started_at`, primeira opportunity e authority no instante de ativação | Impede backdate/ativação fora da janela, condicionado a schema e trigger corretos |
| 035 | Função `maintenance.temporal_activation_preflight` apresenta checks sem ativar epoch | Inspeção read-only do preflight não substitui gate operacional completo |
| 036 | Trigger da primeira medição exige `novelty_state=not_applicable` e `new_identifier_count=NULL` na primeira completada de cada epoch-source | Primeira medição não é conclusão de novidade/materialidade e não deve copiar semântica de medições subsequentes |

Os scripts de autoridade B1R1, fixtures, readouts e testes **não** integram o manifesto de instalação e não podem ser executados como bootstrap factual. B1R1 permanece expirado.

## 5. Critérios mínimos para revisar G1-MIG em futuro checkpoint

1. Verificar SHA-256 de **bytes exatos** e closure dos 14 subarquivos em cada ponto de entrada 031–033; os valores de blob SHA do GitHub **não substituem automaticamente** SHA-256 de arquivo.
2. Revisar dependência real e ordem entre 001–036, catalogar objetos criados/tocados, referência cruzada e efeitos colaterais relevantes a P-B.
3. Separar schema puro de materialização de dados, authority, fixture histórica e SQL de observação; proibir carga indistinta dos arquivos `s5-fixtures.sql` e `f4-topi-...`.
4. Identificar idempotência de cada migration, boundary transacional, DDL/ownership/ACL, migrations com guards alteráveis pelo owner e evidência externa.
5. Especificar ledger/recibos e pós-condições de integridade verificáveis sem falsos PASS; não permitir replay automático em caso de status incerto.
6. Reconhecer que a matriz 034–036 mantém **36 requisitos NOT_COLLECTED**; não reclassificá-los por análise estática de cabeçalhos.
7. Somente após revisão integral e autorização apropriada, desenhar prova descartável com oráculo decisório novo; não repetir CI PG18 pelo simples acúmulo de testes.

## 6. Lacunas mantidas e limites

- **36 migrations UNREVIEWED**, **0 pós-condições aprovadas**, 36 requisitos 034–036 `NOT_COLLECTED`, 12 controles de roles insatisfeitos.
- BRG-03/06/07/08 bloqueados; BRG-04/05 históricos/sintéticos; BRG-09 evidência financeira parcial, gate operacional não aprovado.
- Neon Free não pronto para fatos, sem SQL/branch/role/migration, sem source query PubMed/ClinicalTrials, custos ou novo epoch autorizados.
- B1R1 `EXPIRED_NOT_EXECUTED`, M3 `BLOCKED`, Fase 4 documental `NOT_READY`, Fase 5 `NOT_STARTED`.

## 7. Resultado e retomada

**CP190:** inventário de ordem e agrupamento **ESTÁTICO**, com dependências/impactos ainda não reconciliados. Não certifica execução, compatibilidade com Neon, suficiência de subset ou propriedades transacionais.

**CP191 candidato**, somente após novo `Prossiga` e Freshness Gate: analisar estaticamente a **closure de dependências dos wrappers 031/032/033 e da cadeia 033–036**, com inventário de `\\ir`, ordens, objetos/contratos relevantes e riscos de execução, sem rodar SQL ou migrações. Modo médio adequado. STOP.
