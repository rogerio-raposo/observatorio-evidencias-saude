# 145 — Decisão limitada CP189 e mandato para preparação documental G1

**OES | Fase 4 | 2026-10-20 (America/Recife) | modo médio**  
**Estado:** `PREPARE_G1_DOCUMENTARY_ONLY_APPROVED — G1_OPERATIONAL_NOT_AUTHORIZED`.

## 1. Base canônica e Freshness Gate

Ponteiro CP188, handoff CP188, template canônico, Documento 144, matriz ODB do Documento 139, STATE e CHANGELOG consultados. HEAD de CP188 e main = `ee1f7c4c98bbdead73452f093e6d0a924aa64f4b`, identical, ahead/behind 0.

**Aprovação textual expressa do proprietário:** `APPROVED — CP189 / PREPARE_G1_DOCUMENTARY_ONLY / OES / zero paid services / no Neon SQL, branches, roles or migrations / no new epoch / no source queries. Prossiga com a formalização desta decisão e somente um checkpoint.`

Essa instrução é autoridade para **um checkpoint de formalização e planejamento G1 exclusivamente documental**. Não é aprovação global do G0-D1–D6, implantação de banco ou operação científica.

## 2. Escopo autorizado e oráculos

**Permitido neste mandato:**
1. ler documentos/arquivos existentes no GitHub e estruturar o plano de evidência da cadeia canônica de migrations sem executá-las;
2. definir sequência e dependências necessárias de migrations, ledger, hashes e pós-condições como hipóteses sujeitas à revisão;
3. especificar papéis de banco com privilégio mínimo, propriedade, membership e auditoria externa, sem criar/alterar roles;
4. especificar critérios para Artifacts, armazenamento independente, backup e restauração, sem escolher/contratar serviço;
5. analisar risco/custo proporcionalmente usando evidência Free CP186–CP187, sem assumir garantia de cobrança zero;
6. publicar documentação, apontamento de continuidade e avaliação documental de impedimentos, em GitHub.

**Não autorizado:** Neon SQL/branch/role/migration ou alterações em configuração, grants/segredos, recursos pagos, execução PG18/CI nova sem checkpoint próprio, requests target-specific PubMed/ClinicalTrials.gov, criação de Opportunity/MeasurementEvent, novo epoch, ativação M3, revisão científica humana fictícia ou Fase 5.

**Critério de falha fechada:** qualquer ato que ultrapasse análise documental ou tenha possibilidade de produzir escrita persistente, gasto, efeito externo ou medição factual exige STOP e nova autorização específica. A mudança para modo alto será recomendada antes de decisão de risco/custo/operação efetiva.

## 3. Entregáveis documentais concretos de G1 — próximo trabalho, não executados aqui

| Pacote | Conteúdo mínimo verificável | Estado |
|---|---|---|
| G1-MIG | Lista ordenada das migrations relevantes, dependências, hash, bootstrap estritamente estrutural, distinção de fixtures e pós-condições a aprovar | NOT_PREPARED |
| G1-ROLE | Mapa de papéis/ownership/SET-INHERIT-ADMIN e evidência requerida para impedir uso de proprietário/role elevada pelo executor factual | NOT_PREPARED |
| G1-AUDIT | Origem independente de evidências de DDL, alteração privilegiada, tentativas e receipts não confiáveis do mesmo executor | NOT_PREPARED |
| G1-DUR | Requisitos mínimos para Artifacts, hashes, backup independente, destino e ensaio de restore, sem contratar fornecedor | NOT_PREPARED |
| G1-COST | Envelope de recursos Free e condições de parada por cota/cobrança, sem novos pagamentos | PARTIAL_EVIDENCE_CP186_CP187 |
| G1-GATE | Matriz prova/ator/decisão para solicitar posteriormente, de forma separada, teste descartável ou implementação operacional | NOT_PREPARED |

**Próxima atividade efetiva recomendada:** começar por `G1-MIG`, realizando **inventário estático das migrations e do manifesto de reconciliação** para separar o que é necessário no piloto factual do que pertence a produção completa. Isso reduz a lacuna técnica sem tocar no Neon nem repetir testes desnecessários. O catálogo de 36 migrations permanece `UNREVIEWED`; análise estática não é promoção para `REVIEWED`.

## 4. Estados preservados

- `G0-D1..D5=PENDING_OWNER_DECISION`; `G0-D6` recebe exclusivamente autorização **PREPARE_G1_DOCUMENTARY_ONLY**, não permissão de implantação.
- `BRG-03/06/07/08=BLOCKED`; `BRG-04/05=HISTORICAL_SYNTHETIC_ONLY`; `BRG-09=PARTIAL_OWNER_EVIDENCE_NOT_OPERATIONALLY_APPROVED`.
- 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles insatisfeitos operacionalmente.
- Neon Free `OPERATIONAL_DATABASE_READY=NO`, `FACTUAL_WRITES=NOT_AUTHORIZED`, B1R1 `EXPIRED_NOT_EXECUTED`, `NEW_EPOCH=NOT_AUTHORIZED`, `SOURCE_QUERY=NOT_AUTHORIZED`.
- 12 cenários AT científico-funcionais documentalmente especificados, zero execuções end-to-end; `PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY`, M3 BLOCKED, Fase 5 NOT_STARTED.

## 5. Deliberação e ponto de retomada

**CP189:** autorização limitada formalizada e governada, não implantação G1. Nenhum ato no Neon, CI/PG18, PubMed ou ClinicalTrials, nenhum gasto.

**CP190 candidato:** somente após novo `Prossiga` e Freshness Gate, preparar **G1-MIG inventário documental estático** da sequência de migrations e dependências relevantes ao piloto, com bloqueios intactos; não executar migrations/SQL.

**STOP — após publicar e reconciliar, aguardar novo Prossiga.**
