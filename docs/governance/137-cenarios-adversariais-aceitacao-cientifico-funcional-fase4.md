# 137 — Confrontação adversarial de 12 cenários de aceitação científico-funcional

**OES | Fase 4 | 2026-10-20 (America/Recife) | CP181 | modo alto**  
**Estado:** SCENARIOS_SPECIFIED_DESK_REVIEWED_WITH_RESERVATIONS — NOT_EXECUTED_END_TO_END.  
**Escopo:** D0 documental. **Não** constitui ensaio PostgreSQL, execução científica real, validação independente, aprovação de produção ou encerramento da Fase 4.

## 1. Freshness Gate e fundamento

Ponteiro e handoff CP180, Documento 136, template canônico, STATE.md e CHANGELOG.md conferidos. HEAD de CP180 e HEAD factual da branch main = `98886a7cb2d710c88fba9f58bd2decb054a0aedd`, identical, ahead/behind 0. Escopo autorizado pelo novo `Prossiga`: somente CP181 e seus documentos de continuidade, sem iniciar CP182 ou Fase 5.

Referências transversais confrontadas: Documentos 04–07, 18, 20–21, 25–27, 33–37, 39, 46, 48, 50, 89–90, 110, 124, 135–136 e políticas de identidade e migrations (arquitetura 28/30). Evidência técnica prévia é histórica/sintética, não medição operacional nem revisão científica independente.

## 2. Método e oráculo transversal

Para cada AT: precondição e target versionado, entrada sintética, triage, materialidade, autoridade, saída permitida, ação proibida e oráculo. A revisão compara o **resultado esperado** com as regras canônicas; sem injetar dados nem executar workflow.

**Condições transversais:** (i) não confundir estado M0–M3, status editorial, CurrencyState, assurance e prioridade; (ii) signal/Alert/Monitor não criam conclusão; (iii) triage autoritativa depende de disposition e competência; (iv) MaterialityAssessment é distinta de UpdateDecision; (v) humanos artificiais nunca satisfazem review; (vi) CurrencyState pertence a ProductVersion; (vii) versão, provenance e lineage preservados; (viii) propagation não é decisão; (ix) falta de evidência não vira PASS; (x) falha ou commit incerto bloqueiam replay.

**Classificação documental:** COERENTE_COM_RESTRICOES = expectativa sustentada pelos contratos com autoridade real ainda pendente; RESSALVA_ADVERSARIAL = nuance obrigatória explicitada para evitar erro de interpretação. **Nenhuma** categoria é PASS de execução. Os identificadores PV/IV/S são fixtures narrativas, não registros reais.

## 3. Casos integrados de aceitação — especificação D0

### AT-01 — Signal científico sem mudança material

**Pré-condição/entrada:** PV-1 current; study S1 sintético completo, sem alteração material após appraisal hipotético

**Triagem:** new_study científico; accepted_for_materiality somente sob roteamento permitido

**Materialidade e decisão:** no_material_change documentado; no_scientific_update somente se houver autoridade científica suficiente

**Autoridade requerida:** Human_reviewer/human_expert conforme matéria; AI proposal não substitui julgamento; owner não é materiality assessor

**Saída admitida:** Decisão de não atualizar registrada; currentness só retorna a current por assessment, decisão e linkage específicos; PV anterior preservada

**Ação adversarial proibida:** Zero hits ou ausência de prova não justificam no_scientific_update; nenhuma nova PV automática

**Oráculo de aceitação documental posterior:** Source→triage→assessment→decision e currentness coerentes; nenhuma PV científica fictícia

**Fonte documental:** Docs 05 §§9–12; 07 §§17–21; 27; SF-02/04/05

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-02 — Novo estudo potencialmente material, appraisal insuficiente

**Pré-condição/entrada:** PV-2 current; S2 sintético sem avaliação suficiente de viés/certainty

**Triagem:** new_study; aceitação conservadora para avaliação, sem conclusão

**Materialidade e decisão:** Distinguir potentially_material de insufficient_to_decide segundo suficiência documentada

**Autoridade requerida:** Materiality científica não é decisão do owner; reviewer/expert conforme contrato

**Saída admitida:** Permanecer sob avaliação ou observe, sem afirmar conclusão; set_under_evaluation somente com decisão autoritativa e linkage correto

**Ação adversarial proibida:** insufficient_to_decide→set_current, encerramento como no_scientific_update ou publicação automática

**Oráculo de aceitação documental posterior:** Lacuna explícita, rastreio de fonte, nenhuma resolução científica fictícia

**Fonte documental:** Docs 05, 07; SF-02/04/05/12

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-03 — Retratação ou correção ameaçando validade

**Pré-condição/entrada:** PV-3 v1 hipotética dependente de estudo posteriormente retratado

**Triagem:** retraction ou correction com fonte identificável, accepted_for_materiality

**Materialidade e decisão:** validity_or_use_threat somente com evidência/ dimensão threat; caso contrário pendência

**Autoridade requerida:** Reviewer/expert para julgamento de validade; owner pode apenas encaminhar riscos operacionais permitidos

**Saída admitida:** Registrar reavaliação, restrições potenciais de uso e decisão explícita sobre suspensão/atualização se justificada

**Ação adversarial proibida:** retraction→outdated automático; urgent=critical; nova conclusão sem avaliação

**Oráculo de aceitação documental posterior:** Source, materiality, prioridade e decisão separados; estado não alterado automaticamente

**Fonte documental:** Docs 05, 07, 25–27; SF-04/05/08/12

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-04 — Monitor com cobertura incompleta

**Pré-condição/entrada:** Monitor M2 com fonte obrigatória não consultada e zero hits em fontes restantes

**Triagem:** source_coverage_gap ou cycle_incomplete operacional; registrar coverage/erro

**Materialidade e decisão:** Lacuna operacional não é prova de mudança científica nem de ausência de evidência

**Autoridade requerida:** Owner pode encaminhar reparo operacional; reassessment científico só por autoridade adequada

**Saída admitida:** Ciclo incompleto preservado; recuperação da fonte pendente; avaliar relevância para currentness sem automatismo

**Ação adversarial proibida:** no_update_needed com cycle incompleto; current por zero hits; outdated apenas por prazo

**Oráculo de aceitação documental posterior:** Fonte ausente identificada; cobertura incompleta e ausência de negativo científico

**Fonte documental:** Docs 05–06, 18; SF-02/05/07/10

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-05 — Signal duplicado e outro inválido

**Pré-condição/entrada:** S5a/S5b sintéticos duplicados; S5c hipoteticamente incompatível com target

**Triagem:** Para b: duplicate_or_already_covered com vínculo concreto. Para c: proposta invalid_signal

**Materialidade e decisão:** Apenas a válido aceito avança a assessment; não apagar sinais históricos

**Autoridade requerida:** Duplicata exige ator humano e linkage; invalid_signal/out_of_scope científico autoritativo requer human_reviewer/human_expert, não owner/IA

**Saída admitida:** b preservado como duplicado; c invalidado apenas após triage autoritativa legítima e status consistente no commit

**Ação adversarial proibida:** owner/IA invalidar signal científico autoritativamente; invalid_signal autoritativo com status active; duplicate causar assessment paralelo

**Oráculo de aceitação documental posterior:** Zero duplicação autoritativa, linkage preservado e status invalidated consistente apenas com autoridade

**Fonte documental:** Doc 27 §§4–7; 07 §16; SF-02/03/12

**Resultado da confrontação textual:** RESSALVA_ADVERSARIAL_AUTORIDADE. **Execução end-to-end:** NÃO.

### AT-06 — Alert urgente mais atraso operacional

**Pré-condição/entrada:** PV-6 sem novo appraisal; Alert urgent e ciclo M2 vencido

**Triagem:** Alert e cadence_due tratados como entradas distintas; linkage do target preservado

**Materialidade e decisão:** Urgência e atraso não confirmam mudança científica material

**Autoridade requerida:** Owner decide operação no escopo permitido; prioridade científica/mista e currentness requerem humanos competentes

**Saída admitida:** Escalation proposta/decidida no escopo; ciência e currentness só por assessment/decision específicos

**Ação adversarial proibida:** Alert critical→outdated; breach→conclusion; criar SLA numérico ou auto-escalation

**Oráculo de aceitação documental posterior:** Classificação, prioridade, risco, SLA e CurrencyState permanecem separados

**Fonte documental:** Docs 05, 18, 20–21, 25–27; SF-05/07/08

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-07 — Nova ProductVersion com dependentes e Monitor

**Pré-condição/entrada:** Hipótese de PV-7 v1→v2 cientificamente aprovada apenas no cenário; policy e Monitor para v1

**Triagem:** PropagationCandidate para dependentes; signals novos na policy de cada dependente que exigir avaliação

**Materialidade e decisão:** Impacto downstream não é conclusão; sem copiar MaterialityAssessment upstream

**Autoridade requerida:** Versão e rebaseline científico/misto exigem humano qualificado conforme política; owner não valida ciência sozinho

**Saída admitida:** Preservar v1, lineage e policy antiga; nova policy ligada a v2 por rebaseline próprio; Monitor/coverage/cadence/SLA exigem dispositions

**Ação adversarial proibida:** Retargeting in-place, copiar decisions, herdar assurance ou publicar dependentes automaticamente

**Oráculo de aceitação documental posterior:** Old/new version da mesma entidade, lineage e disposições verificáveis sem reescrever histórico

**Fonte documental:** Docs 05 §12/18, 33–37; SF-06/09/14

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-08 — InvestigationVersion sem ProductVersion correspondente

**Pré-condição/entrada:** IV-8 v1 é target; mudança sintética de escopo exige eventual v2

**Triagem:** scope_change com provenance e referência à IV correta

**Materialidade e decisão:** Materialidade de scope/method sob avaliação humana competente

**Autoridade requerida:** Human_reviewer/expert para decisão científica; owner não substitui appraisal

**Saída admitida:** Versionar IV se aprovado; avaliar mudança de QuestionVersion se a pergunta mudou; nenhuma PV artificial

**Ação adversarial proibida:** Criar CurrencyState para IV, criar PV fictícia, apagar IV antiga

**Oráculo de aceitação documental posterior:** Lineage e escopo preservados; domínio de CurrencyState restrito a ProductVersion

**Fonte documental:** Docs 05 §§10/12, 06, 07; SF-01/05/06

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-09 — N3/N4 ou N2 de criticidade elevada sem expert review

**Pré-condição/entrada:** Produto sintético N3/N4 ou N2 crítico com IA e owner, mas sem revisor independente

**Triagem:** Triagem pode encaminhar caso sem suprir publicação ou assurance

**Materialidade e decisão:** Sem julgamento de método especializado apenas pelo uso de AI verification

**Autoridade requerida:** N3 formal requer A3, N4 A3 e condições de múltiplos revisores; N2 padrão admite A2 com disclosure, mas alta criticidade pode exigir A3/elevação

**Saída admitida:** Manter draft/experimental ou bloquear publicação de alta criticidade até revisão, conflitos e competência documentados

**Ação adversarial proibida:** AI/owner apresentados como peer review; A2 transformado automaticamente em A3; publicação crítica indevida

**Oráculo de aceitação documental posterior:** Gate de publicação bloqueado quando necessária revisão humana efetiva; níveis N/A e disclosure corretos

**Fonte documental:** Doc 04 §§2–6, 9/12; SF-12/14

**Resultado da confrontação textual:** RESSALVA_ADVERSARIAL_N2_VS_N3_N4. **Execução end-to-end:** NÃO.

### AT-10 — Interrupção com execução e autorização incertas

**Pré-condição/entrada:** Workflow sintético registra attempt; estado de commit e autorização não são conhecidos

**Triagem:** Classificar unknown/unresolved, preservando tentativa e causa da falha

**Materialidade e decisão:** Interrupção operacional não prova mudança científica nem rollback

**Autoridade requerida:** Sem supervisor/fencing/replay operacional; qualquer ação persistente futura requer gates e autorização específica

**Saída admitida:** Fail-closed, rechecagem factual futura antes de decidir recuperação; manter incerteza explícita

**Ação adversarial proibida:** Reexecutar SQL, reconciliation/replay automático, declarar committed ou rollback sem prova

**Oráculo de aceitação documental posterior:** Tentativa, resultado desconhecido e blockers separados; nenhuma nova operação executada

**Fonte documental:** Docs 07, 27, arquitetura 30, 124/135/136; SF-03/13/14

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-11 — Evidência temporal insuficiente e B1R1 expirado

**Pré-condição/entrada:** Docs 48/50 = INSUFFICIENT_EVIDENCE em N1/N2; B1R1 expirou sem execução

**Triagem:** Proposal de cadence/threshold baseada em ensaio artificial; não é obrigação normativa

**Materialidade e decisão:** Faltam séries reais, cobertura, autoridade e viabilidade para calibrar

**Autoridade requerida:** Não reutilizar A2 editorial como autoridade temporal; dependências científicas e titular permanecem

**Saída admitida:** Recusar valor normativo; manter B1R1 EXPIRED_NOT_EXECUTED, readiness insuficiente e M3 bloqueado

**Ação adversarial proibida:** Inventar intervalos/dias, reativar epoch, calibrar SLA ou habilitar serviços sem aprovação

**Oráculo de aceitação documental posterior:** Nenhuma rule normativa criada nem autoridade caducada reaproveitada

**Fonte documental:** Docs 39, 46, 48, 50, 89–90, 110; SF-10/11

**Resultado da confrontação textual:** COERENTE_COM_RESTRICOES. **Execução end-to-end:** NÃO.

### AT-12 — Apenas correção editorial de ProductVersion

**Pré-condição/entrada:** PV-12 com ciência intacta; corrigir ortografia/forma, sem mudança de estimativa, certeza ou conclusão

**Triagem:** Demanda editorial tratada sem forçar new_study científico

**Materialidade e decisão:** Documentar por que não há mudança científica; reavaliar se significado tiver mudado

**Autoridade requerida:** Owner atua na revisão editorial cabível; expert quando conteúdo científico ou uso crítico o exigir

**Saída admitida:** Versionamento editorial/append-preserving quando política exigir; classificar change_class editorial em eventual nova versão; não mudar CurrencyState automaticamente

**Ação adversarial proibida:** Afirmar sempre 'sem nova PV' ou sempre 'nova PV científica'; editar histórico silenciosamente

**Oráculo de aceitação documental posterior:** Proveniência, equivalência semântica, política de versionamento e distinção de currentness explícitas

**Fonte documental:** Doc 05 §12.1, 04, 07 e arquitetura 28; SF-01/06/12

**Resultado da confrontação textual:** RESSALVA_ADVERSARIAL_EDITORIAL. **Execução end-to-end:** NÃO.


## 4. Resultado verificável da revisão documental

| Caso | Resultado da leitura adversarial | Execução factual |
|---|---|---|
| AT-01 | COERENTE_COM_RESTRICOES | Não executada |
| AT-02 | COERENTE_COM_RESTRICOES | Não executada |
| AT-03 | COERENTE_COM_RESTRICOES | Não executada |
| AT-04 | COERENTE_COM_RESTRICOES | Não executada |
| AT-05 | RESSALVA_ADVERSARIAL_AUTORIDADE | Não executada |
| AT-06 | COERENTE_COM_RESTRICOES | Não executada |
| AT-07 | COERENTE_COM_RESTRICOES | Não executada |
| AT-08 | COERENTE_COM_RESTRICOES | Não executada |
| AT-09 | RESSALVA_ADVERSARIAL_N2_VS_N3_N4 | Não executada |
| AT-10 | COERENTE_COM_RESTRICOES | Não executada |
| AT-11 | COERENTE_COM_RESTRICOES | Não executada |
| AT-12 | RESSALVA_ADVERSARIAL_EDITORIAL | Não executada |

**Contagem:** 12 cenários integralmente especificados; 9 leituras coerentes com restrições e **3 ressalvas adversariais** (AT-05/09/12). **Zero testes integrados executados**, zero validações científicas humanas, zero aprovações operacionais. Não reportar “12/12 PASS” nem afirmar avaliação empírica da consistência científica.

### Três riscos de interpretação corrigidos

1. **AT-05:** Disposição autoritativa duplicate exige ator humano com linkage; invalid_signal/out_of_scope científico exige human_reviewer/human_expert — aprovação do owner ou da IA é insuficiente.
2. **AT-09:** N2 padrão/A2 com disclosure não é igual a N2 de alta criticidade. N3 formal exige A3 e N4 requer A3 + controles especializados de múltiplos revisores.
3. **AT-12:** Correção editorial não produz necessariamente mudança científica, mas pode requerer **versionamento editorial** apropriado; não editar materialmente in-place ou inferir dispensa universal de nova ProductVersion.

## 5. Contribuição para lacunas G1–G6 do CP180

| Lacuna | Avanço demonstrável em CP181 | Estado remanescente |
|---|---|---|
| G1 — fluxo integrado | AT-01–AT-12 têm entrada, caminho, autoridade, oráculo e contraprova definidos | PARTIALLY_SPECIFIED_ONLY; execução e avaliação empírica pendentes |
| G2 — autoridade humana | Confrontadas permissões de owner, IA e human reviewer/expert | HUMAN_SPECIALIST_REVIEW_NOT_PERFORMED |
| G3 — calibração normativa temporal | AT-04/06/11 preservam lacunas e impedem valores arbitrários | REAL_TEMPORAL_EVIDENCE_INSUFFICIENT |
| G4 — operação persistente | AT-10 preserva fail-closed e bloqueios | OPERATIONAL_BLOCKERS_UNCHANGED |
| G5 — runbook manual/assistido | Roteiros de aceitação podem ser transformados em runbook verificável | INTEGRATED_RUNBOOK_NOT_YET_PUBLISHED |
| G6 — fechamento documental | Distinguidas especificação, ensaio, aprovação humana e operação | DOCUMENTAL_CLOSURE_NOT_READY |

## 6. Limitações e bloqueios preservados

- BRG-03/06/07/08/09 continuam bloqueados; BRG-04/05 permanecem evidências históricas limitadas a commits.
- 36 migrations UNREVIEWED; zero pós-condições aprovadas; 36 requisitos 034–036 NOT_COLLECTED; 12 controles de roles não satisfeitos.
- Nenhuma CI, teste PostgreSQL, SQL, role, branch ou migration Neon, serviço pago ou dado clínico/científico real processado neste CP.
- B1R1 EXPIRED_NOT_EXECUTED; M3 formal BLOCKED; Fase 5 NOT_STARTED; nenhuma automação autoritativa/replay/reconciliação liberada.
- Owner approval não equivale a julgamento de risco de viés, certeza ou revisão especializada. É necessário envolver especialistas reais onde os contratos exigirem.
- Os roteiros são especificações de **futura** aceitação e **não prova científica de conteúdo**. O escopo de cada revisão científica deve ser decidido e aprovado separadamente.

## 7. Decisão CP181, ponto de parada e próxima hipótese

**CP181:** SPECIFICATION_COMPLETE_WITH_THREE_ADVERSARIAL_RESERVATIONS; NOT_EXECUTED_END_TO_END; PHASE_4_DOCUMENTAL_CLOSURE = NOT_READY.

**CP182 candidato, não iniciado:** preparar um runbook manual/assistido e matriz de evidência científico-funcional, a partir dos 12 ATs, com condições de início/parada, rastreabilidade, limites de delegação e requisitos para um eventual gate documental; considerar ensaios adicionais somente mediante decisão dependente, proporcionalidade CP179 e nova autorização. Não iniciar Fase 5 ou serviços persistentes por inferência.

**STOP — após publicar e reconciliar, aguardar novo Prossiga.**
