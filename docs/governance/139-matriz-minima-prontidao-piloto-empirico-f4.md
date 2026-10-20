# 139 — Prontidão mínima e autoridade para novo piloto PubMed/ClinicalTrials.gov

**OES | Fase 4 | 2026-10-20 | CP183 | modo médio**  
**Resultado:** `PILOT_MINIMUM_READINESS_MAPPED_NOT_APPROVED`. Documento **D0** sem operação, mudança de infra, custos ou experimentos.

## 1. Fonte, continuidade e hipótese

Freshness Gate: `main` no commit CP182 `9e762b1edfd96262b9782d9fe87c1a508da46051`, 0 ahead/behind; ponteiro CP182, handoff, STATE, CHANGELOG, template, Docs 105–106, 110, 130, 132, 138 verificados. Aprovação de `Prossiga` no modo médio vale **somente para este checkpoint documental**; risco, custos, credenciais, alterações Neon e novo epoch exigirão aviso e recomendação de modo alto.

**Hipótese a resolver:** como realizar primeiras medições reais de PubMed/ClinicalTrials.gov com custo baixo, evidência factual e armazenamento recuperável, preservando as exigências que efetivamente protegem a execução, sem replicar desnecessariamente todos os controles de produção.

## 2. Experimentos não equivalentes

**P-A — interface pública não persistente (alternativa não selecionada):** avaliação prospectiva de request, latência e paginação, sem escrever `MeasurementEvent`/resolução e sem formar o histórico factual pretendido. Necessita autorização própria e **não** satisfaz a primeira medição OES.

**P-B — piloto factual persistente (objetivo preservado, NÃO autorizado):** novo Epoch/Opportunities e congelamento futuro, preflight real em ambiente com schema OES, execução PubMed/ClinicalTrials.gov nos horários aprovados, registro durável de status, identificadores e Artifacts, recuperação e posterior triage científica quando cabível. B1R1 histórico NÃO é reutilizável.

A conta Neon Free criada é **candidata P-B**, mas sua existência e SELECT histórico não constituem `OPERATIONAL_DATABASE_READY`.

## 3. Doze gates ODB — observação histórica versus evidência faltante

A tabela consolida o Documento 110 e requisitos já impostos nos Documentos 105–107, 130 e 132. Os resultados **não** provêm de leitura Neon ao vivo em CP183.

| Gate | Domínio | Fato disponível | Evidência/decisão ainda necessária | Restrição ligada | Prontidão |
|---|---|---|---|---|---|
| ODB-01 | Titular/plano/região/custo | Neon Free synthetic-only autorizado | Owner confirma quotas/custos e nova finalidade factual | BRG-09 | NOT_READY_FOR_FACTUAL |
| ODB-02 | Persistência | PostgreSQL 18 acessível via SELECT anterior | Comprovar persistência, isolamento e recuperação | ODB-02/BRG-08 | NOT_READY_FOR_FACTUAL |
| ODB-03 | Acesso seguro | Owner conectado tinha privilégios elevados | TLS, segredo, isolamento e elevação segura comprovados | BRG-03 | NOT_READY_FOR_FACTUAL |
| ODB-04 | Dados mínimos | Somente uso sintético autorizado | Nova autorização para metadados públicos, sem PHI | ODB-04 | NOT_READY_FOR_FACTUAL |
| ODB-05 | Schema/migration | Banco vazio na inspeção anterior; 36 migrations UNREVIEWED | Ledger, hash, sequência aprovada, guards e pós-condições | BRG-06 | NOT_READY_FOR_FACTUAL |
| ODB-06 | Bootstrap | Nenhum estado factual B1R1 foi criado | Bootstrap novo sem retrofatos e sem fixtures CI | ODB-06 | NOT_READY_FOR_FACTUAL |
| ODB-07 | Artifacts | Durabilidade de bytes ainda não demonstrada | Armazenamento, hash, recuperação e provenance | ODB-07 | NOT_READY_FOR_FACTUAL |
| ODB-08 | Backup/restore | Independência e restauração não comprovadas | Backup externo e restore ensaiado no escopo factual | BRG-08 | NOT_READY_FOR_FACTUAL |
| ODB-09 | Tempo/auditoria | SQL clock histórico; auditoria externa incompleta | Relógio e logs confiáveis fora do mesmo runner, quotas | BRG-03/09 | NOT_READY_FOR_FACTUAL |
| ODB-10 | Executor | Nenhum executor factual autorizado | Least privilege, FAIL CLOSED, titular e operador definidos | BRG-07 | NOT_READY_FOR_FACTUAL |
| ODB-11 | CI segregada | CI sintética sem vínculo autorizado ao Neon factual | Credenciais e fixtures isoladas, evidência verificável | BRG-03/07 | NOT_READY_FOR_FACTUAL |
| ODB-12 | Smoke tests | Apenas inspeção SELECT histórica | Checks end-to-end controlados sob autorização; não CI PASS | ODB-12 | NOT_READY_FOR_FACTUAL |

**Condição de parada:** qualquer `NOT_READY_FOR_FACTUAL` relevante impede ativação P-B. Esta matriz não aprova exceção ou transição e não altera a precedência de gates normativos.

## 4. Trilha mínima de decisão e prova — sem implantação

| Gate | Passo de saída | Autoridade / modo futuro |
|---|---|---|
| **G0** | Owner define objetivo P-B, classe de dados públicos, limites e confirma Free/quotas/custo; sem pagamento presumido | Proposta documental em médio; decisão que envolva custo/risco em **alto** |
| **G1** | Aprovar e demonstrar sequência de migrations/ledger e roles/TLS/segregação/auditoria | Projeto técnico preliminar em médio; SQL e mutação Neon em **alto** e nova autorização |
| **G2** | Validar armazenamento dos Artifacts e backup externo com restore efetivo | Aprovação do owner e, se necessário, revisão especializada; **alto** na mudança irreversível |
| **G3** | Executor factual de mínimo privilégio, clock, logs e comportamento FAIL CLOSED demonstrados | Gate separado; sem backend admin implícito |
| **G4** | Novo Epoch/Opportunity, frozen queries e calendário prospectivo; preflight factual read-only PASS e autorização de activation | **Alto** + autoridade temporal específica; B1R1 e 14 horários antigos intocados |
| **G5** | Primeiras medições novas PubMed e ClinicalTrials.gov, request/response factuais e trilha de triage científica | Operação separadamente aprovada, resultados não equivalem a materialidade científica |

Não inventar datas futuras até infraestrutura, escopo, operador e autorização estarem prontos. Modo alto **não é necessário agora** para ler documentos, estruturar quadros ou fazer diagnóstico estático; recomendar quando houver decisão substancial sobre permissão, gasto, execução temporal e persistência.

## 5. Relação com bloqueios atuais

- `BRG-03` TLS, privilegio de owner, auditabilidade independente: BLOQUEADO.
- `BRG-04/05` resultados históricos/sintéticos; não equivalem a evidência factual Neon.
- `BRG-06` ledger não operacional; `BRG-07` supervisor/fencing não operacional; `BRG-08` restore externo não configurado; `BRG-09` custo/quotas do titular pendentes.
- **36 migrations UNREVIEWED**, **0 pós-condições aprovadas**, **36 requisitos 034–036 NOT_COLLECTED**, **12 controles de roles não satisfeitos**.
- `B1R1=EXPIRED_NOT_EXECUTED`; `NEW_EPOCH=NOT_AUTHORIZED`; `M3=BLOCKED`; `PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY`; `PHASE_5=NOT_STARTED`.
- Documentos 94/95 das primeiras medições permanecem **artefatos históricos preparados, não executados**. Não executar consultas nas antigas Opportunities.
- No CP183: **nenhum SQL/branch/migration/role Neon, nenhuma consulta PubMed/ClinicalTrials, nenhum PG18/CI, nenhum serviço pago**, nenhuma autoridade factual.

## 6. Decisão e próximo checkpoint candidato

**Resultado CP183:** `P_B_STRATEGIC_PRIORITY_RETAINED` + `OPERATIONAL_READINESS_BLOCKED`. A retomada não foi descartada; apenas foi estruturada em dependências reais e decisões separadas. O encerramento da Fase 4 não foi autorizado.

**CP184 candidato — somente após novo `Prossiga`:** pacote documental para decisão G0 do owner sobre escopo P-B, metadados públicos, limites/custo da conta Free, operador, backup/Artifacts e riscos. Isso não cria epoch nem habilita escrita Neon. Se for necessária aprovação de risco/custo/infra, **recomendar modo alto antes do ato**.

**STOP após publicação e reconciliação.**
