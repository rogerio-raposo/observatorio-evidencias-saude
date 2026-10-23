# Documento 238 — Matriz integrada de evidências para o gate documental da Fase 4

**OES | 2026-10-23 | após CP260 | F4_DOCUMENTARY_EXIT_EVIDENCE_CROSSWALK_PREPARED / FINAL_GATE_NOT_DECIDED**

## 1. Mandato, método e limitação

O proprietário aprovou no [Documento 237](237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md) que o **encerramento metodológico e documental**, não a operacionalização, constitui o marco determinante da Fase 4. Novo `Prossiga` autorizou **uma atividade**: verificar `F4-C01–F4-C06` a partir de material canônico existente, confrontar `AT-05/09/12` e identificar somente lacunas documentais realmente impeditivas.

**Método desta atividade:** inspeção documental assistida por IA, cotejando as matrizes [136](136-inventario-suficiencia-cientifico-funcional-fase4.md) (SF-01–14), [137](137-cenarios-adversariais-aceitacao-cientifico-funcional-fase4.md) (AT-01–12), [138](138-runbook-manual-assistido-matriz-aceitacao-piloto-empirico-f4.md) (R0–R8), regras [04](04-governanca-garantia-revisao.md) e [05](05-protocolo-transversal-atualizacao.md), contrato [27](27-contrato-dados-integrado-plano-operacional-fase-4.md) e decisão [237](237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md). **Não** foi realizado teste executável de ponta a ponta, revisão humana especializada, avaliação científica nova, consulta externa, CI, SQL ou alteração de produto.

**Escalas desta matriz:** `ADEQUATE_FOR_DOCUMENTARY_GATE_REVIEW` = material rastreado e sem conflito documental impeditivo identificado nesta verificação; não significa PASS definitivo do gate. `CONDITIONAL_GUARD_REQUIRED` = coerência textual depende de regra explícita de autorização ou preservação, cuja prova operacional fica diferida. `PENDING_FINAL_DECISION` = ainda necessita decisão expressa. Os **estados históricos dos Docs. 136–138 não são reescritos**: `12/12_SPECIFIED; 0/12_END_TO_END_EXECUTED; 0_HUMAN_EXPERT_REVIEWS`.

## 2. Verificação dos seis critérios determinantes

| Critério Documento 237 | Evidência documental examinada | Resultado desta verificação e condição |
|---|---|---|
| **F4-C01 — cobertura de contratos** | Doc. 136 `SF-01–14`; Docs. 04–09, 16–37; demonstração restrita Doc. 228 | **ADEQUATE_FOR_DOCUMENTARY_GATE_REVIEW**: quatorze funções com identidade, referência, separações de risco e limites de validação. Conferência em §3; nenhuma prova operacional nova. |
| **F4-C02 — coerência integrada** | Doc. 138 `R0–R8`; Doc. 137 `AT-01–12`; contrato Doc. 27 | **CONDITIONAL_GUARD_REQUIRED**: doze cenários têm entrada, caminho, autoridade, saída proibida e oráculo identificáveis. **AT-05/09/12** têm regras explícitas e precisam ser aceitos *como condicionais*, não convertidos em execução aprovada; detalhes em §4. |
| **F4-C03 — governança/garantia** | Doc. 04 (N0–N4/A0–A3), 27 (triagem e papéis), 138 (R2/R3/R5) | **ADEQUATE_FOR_DOCUMENTARY_GATE_REVIEW**, com **condição de não simulação**: owner não substitui especialista, verificação IA não é humana; ausência de revisão especializada atual deve constar na deliberação. |
| **F4-C04 — temporal/currentness** | Docs. 05, 18–21, 39/44/46, 48/50, 136 SF-05/08/10/11, 138 AT-04/06/11 | **ADEQUATE_FOR_DOCUMENTARY_GATE_REVIEW**: regras/limites definidos; **cadence, thresholds, SLA normativos não calibrados** e M3 bloqueado. Nenhuma duração é inferida. |
| **F4-C05 — obrigações diferidas** | Docs. 135–138, 227/228, 229 e 236, CP260 | **ADEQUATE_FOR_DOCUMENTARY_GATE_REVIEW** mediante a **matriz de gatilhos e provas** em §5; nenhuma dívida de risco é considerada solucionada. |
| **F4-C06 — parecer/decisão final** | Documento 237 §3/§6; presente matriz de evidências | **PENDING_FINAL_DECISION**: este documento fornece os insumos, mas **não** autoriza `PHASE_4_CLOSED`, nem substitui aprovação expressa do proprietário. |

**Resultado agregado desta atividade:** `EVIDENCE_MATRIX_COMPLETE_FOR_FINAL_DOCUMENTARY_GATE_SUBMISSION / NO_CRITICAL_NEW_DOCUMENTARY_CONTRADICTION_DETECTED / THREE_ADVERSARIAL_GUARDS_EXPLICIT / FINAL_APPROVAL_PENDING`. Não declarar que Fase 4 está encerrada por esse resultado.

## 3. Cobertura SF-01–SF-14 — fonte, categoria e fronteira

| SF | Evidência existente | Grau comprovado e restrição |
|---|---|---|
| **01** Regimes M × editorial × assurance × currentness | Docs. 04–06 | **Baseline conceitual especificado/revisado**; M3 formal bloqueado. |
| **02** UpdateSignal e proveniência | Docs. 05/07/27; 09/29 | **Contrato e testes históricos sintéticos**, não monitor conectado contínuo. |
| **03** Triage/deduplicação/invalidade | Doc. 27 §§4–7; 137 AT-05; 138 R2 | **Regra de autoridade definida**; invalidação científica exige revisor humano qualificado. |
| **04** MaterialityAssessment | Docs. 05/07/09/24; 138 R3 | **Conceito/contratos**; avaliação de mérito científico real não inferida de cenário artificial. |
| **05** UpdateDecision versus currentness | Docs. 05–07; 138 R4; AT-01/02/04 | **Estados e STOP especificados**, sem `set_current` a partir de silêncio da fonte. |
| **06** Versionamento/lineage | Docs. 05/27, política migration 30; 138 R6 | **Regra especificada**; versão científica e editorial preservadas sem edição histórica silenciosa. |
| **07** Monitor versus Alert versus ciência | Docs. 05–06/27; produtos Monitor/Alert Fase 3 | **Separação contratual**; alerta não muda conclusão. |
| **08** Prioridade/escalation/SLA | Docs. 18–21/25–29 | **Contrato e validação sintética histórica**; sem score universal ou auto-escalation. |
| **09** Perfil de risco/propagação/rebaseline | Docs. 30–37; 138 R6 | **Contrato/sintético histórico**; sem propagação autoritativa ou retargeting silencioso. |
| **10** Método de calibração temporal | Docs. 39/44/46, avaliações reais 48/50 | **Método especificado, dados insuficientes para parâmetros normativos**. |
| **11** Medição temporal não normativa | Docs. 51/68/89/90/104/110 e histórico B1R1 | **Preparação/ensaios sintéticos**; B1R1 expirado e não executado, sem primeira medição daquele epoch. D2 NCBI pontual de 2026 não substitui esse epoch. |
| **12** Governança por nível N | Doc. 04; 137 AT-09; 138 R5 | **Regras de competência claras**; A2 owner não implica A3; revisão humana efetiva ainda ausente. |
| **13** Falha, interrupção e retomada | Docs. 07/27/89/90/138 R8 e AT-10 | **Fail-closed documental**; sem prova de ledger/fencing/restore operacional. |
| **14** Aprovações e fronteira IA | Docs. 04–06/27/135; 138 R0–R8 | **Atribuições e restrições previstas**; execução só nos gates futuros aplicáveis. |

**Leitura transversal:** os 14 itens não devem receber uma classificação indistinta de “validado”. Cada um foi rastreado à categoria correta: `especificado`, `historicamente validado de forma sintética`, `pontualmente observado em recuperação factual`, `não validado por humano` ou `não operacionalizado`.

## 4. Confrontação documental dos 12 cenários e dos três pontos adversariais

Para cada AT, a avaliação confronta **pré-condição → etapa R0–R8 → ator competente → decisão esperada → transição proibida → evidência/STOP**. O veredito abaixo significa **apenas coerência da especificação** na presente leitura.

| AT | Passo do runbook e regra essencial | Veredito documental |
|---|---|---|
| **01 — sinal sem mudança material** | R1–R4: appraisal/ator legitimado precedem decisão; sem ProductVersion criada por ausência de mudança | **COERENTE**; decisão científica real não executada |
| **02 — possível materialidade insuficiente** | R2–R5: `insufficient_to_decide` mantém avaliação, nunca promove currentness/publicação | **COERENTE**; parecer humano futuro quando exigível |
| **03 — retratação/validade** | R1–R5/R7: abrir avaliação proporcional e eventual restrição de uso; não concluir automaticamente | **COERENTE**; resposta real não testada |
| **04 — cobertura incompleta** | R1/R7/R8: zero hits com falha de fonte ≠ ausência de evidências; registrar gap | **COERENTE**; recuperação global não testada |
| **05 — duplicata/invalidação** | R2, Doc. 27 §§5–7: duplicata requer ator humano + ligação concreta; `invalid_signal`/`out_of_scope` científico autoritativo requer `human_reviewer`/`human_expert` | **CONDITIONAL_GUARD_REQUIRED**: se esse humano não existir, sinal permanece em proposta/pendência e não é invalidado autoritativamente. Não inventar identidade nem PASS de operação |
| **06 — alerta urgente/atraso** | R4/R7: escalonamento separado de materialidade e currentness; sem SLA normativo arbitrário | **COERENTE**; relógios não calibrados |
| **07 — mudança de versão e dependentes** | R5–R7: conservar versão antiga/lineage; rebaseline decidido, não automático | **COERENTE**; persistência não testada |
| **08 — alteração InvestigationVersion** | R4–R6: versionar Investigation sem forçar ProductVersion nem CurrencyState indevida | **COERENTE**; não executado |
| **09 — N/A e criticidade** | R0/R5, Doc. 04: N2 padrão A2 com disclosure; N2 crítico pode exigir qualificação superior; N3 formal A3; N4 A3 + múltiplos revisores | **CONDITIONAL_GUARD_REQUIRED**: sem especialistas competentes, bloquear publicação/claim incompatível e manter draft/experimental; owner/IA jamais substituem A3 |
| **10 — operação indeterminada** | R8: falha/commit incerto → `UNKNOWN/STOP`, não reexecutar/afirmar rollback sem prova | **COERENTE**; ledger/replay real não validado |
| **11 — insuficiência temporal** | R0/R4/R7: B1R1 expirado e série insuficiente → não fixar cadence/SLA, nem ativar M3 | **COERENTE**; calibração pendente |
| **12 — correção editorial** | R6, Docs. 05 §12/04: avaliar equivalência semântica, classificar `editorial`, preservar alterações e histórico conforme política | **CONDITIONAL_GUARD_REQUIRED**: nem `sempre nova ProductVersion científica` nem `sempre nenhuma nova versão`; exigir política de versionamento/registro e proibir alteração silenciosa de ciência/currentness |

**Três ressalvas do Documento 137:** foram confrontadas com os controles já escritos nos Docs. 27/04/05/138 e **não revelaram nova contradição documental nesta inspeção**. Isso **não demonstra** que o sistema aplique esses bloqueios nem que existam revisores humanos designados. Para o **gate final**, aceitar os cenários 05/09/12 somente com **condições vinculantes de fail-closed** e divulgação explícita. Se o gate exigir prova de execução real ou qualificação humana efetivamente presente, o resultado não pode ser PASS sem novas evidências e o escopo terá de ser revisto.

**Contagem honesta:** `9/12` cenários documentariamente coerentes sem ressalva adicional nesta revisão; `3/12` coerentes **condicionados a guardas de autoridade/versionamento**; `0/12` cenários executados end-to-end nesta matriz; `0` revisões metodológicas humanas independentes. Não representar `12/12 PASS OPERACIONAL`.

## 5. Obrigações diferidas acionadas por evento futuro — ledger mínimo

**Princípio:** nenhuma exigência de segurança é eliminada; é ativada **antes** do evento de risco que a exige. A arquitetura/stack futura pode mudar o mecanismo de prova, mas não a propriedade de segurança que precisa ser demonstrada.

| Gatilho futuro (não executado) | Exigências e riscos preservados | Prova/autoridade prévias indispensáveis |
|---|---|---|
| **Consulta factual conectada adicional** sem escrita persistente no OES | Delimitação de fonte/PICO, proveniência, cobertura, minimização, limites de API, interrupção segura | Aprovação específica do escopo, registro literal request/response/time e disposição de falhas; não equivale a medição do antigo epoch B1R1 |
| **Persistência factual e novo piloto empírico** | BRG-03 segurança/roles/TLS/auditoria; BRG-06/07 ledger, supervisão/fencing conforme arquitetura; BRG-08 restore independente; BRG-09 custo; migrations aplicáveis, SA-05/06/07/08/10 | Escolha de stack e sequência mínima verificada, testes/provas pertinentes, titular confirma custos, gate operacional e preflight antes da primeira escrita, **nunca depois** |
| **Nova migration/alteração de esquema** | Política de migrations 30, histórico de 36 `UNREVIEWED`; pós-condições, integridade, ledger e auditoria em escopo | Auditoria de dependências e aprovação de migrações **efetivamente necessárias**, inclusive testes de reconciliação; não exigir implantar todas indiscriminadamente |
| **Decisão que altera conclusão científica ou versão do produto** | Matéria científica, validação por nível N, RoB/GRADE quando pertinente, tratamento de dados insuficientes, proveniência, gates de versão | Revisor/instância competente e aprovação científica/owner aplicáveis, histórico e critérios explícitos; `UpdateSignal` não aprova sozinho |
| **Publicação formal N3/N4 ou produto N2 crítico** | Doc. 04: revisão independente A3 quando exigível, múltiplos revisores N4, transparência de assurance e conflito de interesses | Pessoas humanas qualificadas identificadas com pareceres verdadeiros, sem usar IA/owner como especialista fictício |
| **Ativação M3/monitoramento autoritativo recorrente** | Cadência/threshold/SLA com base empírica, sensibilidade/cobertura, responsabilidades, segurança da automação e falhas | Evidência de calibração real, governança e gates operacionais/científicos específicos; M3 segue `BLOCKED` |
| **Implantação multiusuário/produção** | Segregação efetiva, persistência transacional, auditoria independente, backup/restore, observabilidade, reconciliação segura, custos, incidentes | Stack definida, testes técnicos de aceitação apropriados, revisores responsáveis e autorização de implantação; CI sintética não homologa produção |

A coluna acima não constitui `APPROVED` para nenhum desses gatilhos. **BRG-03/06/07/08 bloqueados, BRG-09 parcial**, SA-05/06/07/08/10 diferidos e 36 migrations `UNREVIEWED`. A2-G4 experimental permanece na branch de preservação, não promovido a `main`.

## 6. Síntese do que realmente resta antes da deliberação final

**Não emergiu nesta revisão lacuna que exija novo framework, migração, CI, Neon ou repetição de D1/D2 para o objetivo estritamente documental.**

A pendência **de aceitação, não de construção** é produzir **uma deliberação final integrada** que:
1. confirme conscientemente os seis critérios e os resultados distintos entre especificação, verificação textual, sintético histórico e factual pontual;
2. registre como condições vinculantes os guardas AT-05/09/12, inclusive a impossibilidade de reivindicar atores/revisões humanos inexistentes;
3. assuma explicitamente que a ausência de evidência operacional não é uma prova de prontidão e mantenha o ledger de obrigações exigível antes da operação;
4. apresente o resultado `PASS_DOCUMENTARY_ONLY`, `REVISE` ou `NOT_READY` **para aprovação expressa do proprietário**, sem reabrir a infraestrutura por inferência.

**Conclusão desta atividade:** `DOCUMENTARY_EXIT_GATE_SUBMISSION_READY_WITH_DECLARED_CONDITIONS`. Não equivale ao resultado final do gate, nem a `PHASE_4_CLOSED`. Uma eventual decisão final `PASS_DOCUMENTARY_ONLY` ainda requer ato expresso posterior do proprietário. O protocolo poderá ser declarado concluído **documental e metodologicamente** após essa aprovação, sem alterar a Ficha N2, currentness, assurance, M3 ou readiness operacional.

**Próximo `Prossiga`: preparar uma única minuta de deliberação do gate F4-C01–F4-C06 baseada nesta matriz, sem novo inventário ou teste, e solicitar decisão expressa.** STOP.
