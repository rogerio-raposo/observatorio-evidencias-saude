# 160 — Pacote documental reproduzível: fixtures, evidências e oráculos V033-06/V035-03

**OES | 2026-10-20 | CP205 | Fase 4 | modo médio**
**Status:** `EVIDENCE_PACKAGE_DRAFT_ONLY`; `PREPARE_G1_DOCUMENTARY_ONLY`. Nenhuma autorização nova.

## 1. Proveniência e escopo
Consolida o bloco A1–A3 pós-CP204: estrutura mínima do pacote; manifesto conceitual das fixtures e registros; oito variantes, oráculos e classificações. Documentos antecedentes 158 e 159, migrations 033b/033c/034/035. Freshness Gate confirmou CP204 `f66e2895cb88108efbd27dbf7e15a0cf3e5eaac6` idêntico a `main` no início. Nenhum SQL (inclusive SELECT), Neon, CI, experimento, medição científica factual, novo epoch ou gasto.

## 2. Estrutura mínima exigida para solicitação futura de autorização
Identidade (fonte e hashes); ambiente isolado e descartável; dados sintéticos e fixtures reproduzíveis; transações e participantes; observações e estado final; decisão e revisão independente. Vincular AUT-01–AUT-08 apenas como checklist de preparo subordinado à governança canônica. Aptidão documental não concede permissão.

Campos de manifesto **candidatos**: `fixture_id`, `scenario_id`, `fixture_version`, `source_commit`, `source_sha256`, `environment_id`, `data_classification=SYNTHETIC_ONLY`, `execution_authorized=false`, `evidence_status=NOT_COLLECTED`. Campos vazios não devem ser preenchidos por inferência. Não há fixture criada nem identificador factual de ambiente.

Estruturar cada evidência em três camadas: (1) plano/autorização, estado inicial e oráculos; (2) operações observadas por sessão/transação, sequência, erros, instantes e confirmação; (3) estado final, limpeza, cobertura, julgamento e revisão independente. Não confundir sequência planejada com ordem efetivamente observada.

## 3. V033-06 — variantes e oráculos
Pré-condições conceituais: epoch `active`, target atual, oportunidade não resolvida, tentativas anteriores consistentes, `effort_payload` válido, duas sessões sintéticas independentes.

| Variante | Concorrência | Oráculo | Limitação |
|---|---|---|---|
| C01 | inserção × inserção | unicidade de `(measurement_opportunity_uuid,attempt_no)` e sequência de tentativas confirmadas | constraint UNIQUE não demonstra demais regras de negócio |
| C02 | inserção × resolução | nenhuma tentativa confirmada que viole resolução terminal aplicável | depende da efetiva ordem e visibilidade das transações |
| C03 | inserção × conclusão | nenhuma reabertura/continuação indevida após conclusão terminal | inspecionar estado final e ambas as transações |
| C04 | inserção × mudança do epoch | resultado compatível com lifecycle no ponto de validação contratual | oráculo condicionado ao contrato temporal e isolamento |

Ensaios C02–C04 exigem distinguir início de operação, visibilidade e COMMIT, não somente timestamps de aplicação.

## 4. V035-03 — variantes e oráculos
Pré-condições conceituais: epoch `authorized_non_normative`, oportunidades materializadas e válidas, sem eventos/resoluções prévios, autoridade inicialmente aprovada e janela aberta. Registrar `p_as_of`, `started_at` e instantes de confirmação separadamente. Preflight 035 é consultivo; guardas 034 avaliam autoridade e desvios em `started_at`.

| Variante | Mudança | Oráculo | Limitação |
|---|---|---|---|
| T01 | autoridade muda entre diagnóstico e início | resultado consistente com autoridade histórica exigida | diferenciar temporalidade e transação |
| T02 | desvio impeditivo até `started_at` | ativação confirmada deve ser rejeitada se houver desvio aplicável | evidência de registro e visibilidade |
| T03 | condição muda após `started_at`, antes de COMMIT | conformidade com regra temporal/transacional explicitada | mudança posterior não implica falha automática |
| T04 | expiração da janela de ativação | nenhuma ativação contratualmente proibida apoiada em diagnóstico obsoleto | depende do procedimento operacional, ainda não comprovado |

## 5. Classificação auxiliar de resultados
- `SATISFACTORY_IN_SCOPE`: todos os oráculos aplicáveis à variante examinada demonstrados com evidências suficientes, limites de cobertura declarados e revisão.
- `UNSATISFACTORY`: violação comprovada de pelo menos uma invariante obrigatória.
- `INCONCLUSIVE`: evidência insuficiente, fixture inválida, visibilidade incerta ou cobertura indeterminada.

Esses rótulos **não** são estados oficiais da migração, nem aprovação de BRG, nem autorização. `observed_result=NOT_COLLECTED` para todas as oito variantes. Oráculos C04, T03 e T04 precisam de definição técnica adicional para execução inequívoca. Separar eventual falha do ambiente de falha do contrato verificado.

## 6. Lacunas de preparação
Sem definição aprovada de formato executável de fixtures, sincronização determinística, isolamento de sessões, comprovação de descarte, ordem observada sem inferência de timestamps, nem exigência operacional de preflight. Escolher estratégia de concorrência/isolamento ou mecanismos corretivos demanda recomendação prévia do modo alto e autorização pertinente. Não iniciar testes.

## 7. Estado e retomada
36 migrations `UNREVIEWED`, 0 pós-condições aprovadas, 36 requisitos 034–036 `NOT_COLLECTED`, 12 roles pendentes; BRG-03/06/07/08 `BLOCKED`; BRG-04/05 históricos; BRG-09 parcial; B1R1 `EXPIRED_NOT_EXECUTED`, M3 bloqueado; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`.

Próximo `Prossiga`: nova A1 documental, revisar criticamente se os oráculos condicionais C04/T03/T04 podem ser especificados sem antecipar decisões técnicas de isolamento e autorização. **STOP.**
