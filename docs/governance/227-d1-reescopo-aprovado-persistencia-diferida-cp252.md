# Documento 227 — Decisão aprovada: reescopo de D1 e diferimento de T2-A2 (CP252)

**OES | 2026-10-22 | APPROVED_D1_RESCOPE_DEFER_A2G4 | DOCUMENTARY_ONLY**

## 1. Decisão expressa e motivação

O proprietário aprovou a proposta de reescopo D1 formulada após revisão arquitetural do CP251. Fundamento: a demonstração sintética de domínio já dispõe de T1 e T2-A1 encerrados em escopos restritos; o trabalho artesanal de um adaptador PostgreSQL A2-G4 antes da decisão de stack apresenta risco de engenharia prematura, duplicação das capacidades usuais de frameworks e baixo benefício funcional marginal. O Documento 169 não homologou stack definitiva; o Documento 170 descreve PostgreSQL como etapa T2 condicionada a autorização, e o Documento 173 aprovou explicitamente somente o encerramento T1 local/sintético. Documentos 189, 190 e 197 são contratos e propostas para persistência, não prova de necessidade de PostgreSQL no primeiro incremento funcional de D1.

**Decisão:** suspender o desenvolvimento de T2-A2/A2-G4 no plano imediato de D1 e deferir a implantação de persistência durável para um marco de integração após escolha arquitetural e autorização específica. Não revogar documentos anteriores ou resultados históricos; registrar esta decisão posterior como ajuste prospectivo de escopo.

## 2. Fronteiras preservadas e novos estados de planejamento

| Objeto | Estado após aprovação |
|---|---|
| D1-T1 | `CLOSED_SYNTHETIC_LOCAL_ONLY`; 36 testes PASS históricos, S1–S6 nos limites já aprovados |
| D1-T2-A1 | `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`; 39 testes próprios + 36 T1 = 75 históricos PASS |
| D1-T2-A2 / A2-G4 | `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`; suspender atividade e não alegar encerramento |
| A2-G5 / T2-A2 runtime | `NOT_AUTHORIZED` inalterado |
| T3 nuvem / T4 equivalência OES-P1 | Diferidos; não aprovados nem executados |
| D1 global | `RESCOPED_NOT_GLOBALLY_CLOSED`; eventual encerramento do demonstrador sintético exige decisão expressa com critério delimitado |
| D2 factual | Diferido, condicionado a decisão própria |
| Fase 4 / Fase 5 | `NOT_READY` / `NOT_STARTED` |

## 3. Requisitos que continuam obrigatórios no futuro

Não dispensar regras de domínio e governança: identidades do produto e Monitor, ciclos, proveniência somente sintética nesta trilha, idempotência de request, integridade dos eventos, trilha de decisões e avaliações, preservação da conclusão científica, snapshots/replay, quatro estados independentes e disclosure real de execução. O demonstrador `oes.d1.monitor_snapshot/0.1` não é a View SQL canônica `oes.evidence_monitor_view/0.1`, nem evidência científica real.

Quando persistência durável for necessária, selecionar stack primeiro e aproveitar transações, pools, migrations, serialização e recursos consolidados. Framework ou ORM **não garantem automaticamente** idempotência de negócio, recibos semanticamente íntegros, COMMIT incerto ou recuperação correta. Revalidar então SA-05/06/07/08/10 com critérios e testes apropriados, sem reabrir análises estáticas idênticas. SA-05 global ABERTA/ALTA; SA-06 ABERTA; SA-07 ABERTA/MODERADA; SA-08 ABERTA/ALTA; SA-10 ABERTA; SA-02 condicionada, SA-03 parcial, SA-11/12 somente mitigadas estaticamente. São riscos diferidos **e não resolvidos**.

## 4. Preservação técnica e limites da aprovação

Seis arquivos experimentais A2 exclusivamente na branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, conforme Documento 223. Não editar, excluir ou integrar automaticamente a branch. `main` permanece sem `prototypes/d1_t2/a2/`. Nenhum código alterado, importado, compilado ou executado; nenhum teste/CI/SQL/Neon/grant/migration/deploy/driver, serviço pago, dado factual ou promoção científica foi autorizado por esta decisão. Histórico das 36 migrations permanece `UNREVIEWED`.

Manter os protocolos: Freshness Gate inicial e pré-commit, uma atividade por `Prossiga` e STOP, comunicação durante operações longas, checkpoints por relevância.

## 5. Próxima atividade após novo Prossiga

**D1-R1 — inventário objetivo dos entregáveis já encerrados e das lacunas do demonstrador sintético reescopado**, sem desenvolver A2-G4, implantar T3 ou afirmar D1 globalmente concluído. Identificar somente pendências demonstráveis que impeçam uma decisão futura de encerramento restrito do demonstrador; não iniciar novas análises de infraestrutura, e não executar código sem autorização própria.

**STOP — CP252 documenta exclusivamente reescopo aprovado.**
