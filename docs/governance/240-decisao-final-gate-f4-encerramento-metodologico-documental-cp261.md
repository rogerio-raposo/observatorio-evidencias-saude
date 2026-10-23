# Documento 240 — Decisão final: encerramento metodológico e documental da Fase 4

**OES | 2026-10-23 | F4-FINAL-GATE / PASS_DOCUMENTARY_ONLY / PHASE_4_CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY**

## 1. Ato de aprovação e alcance jurídico-metodológico interno

Após a publicação da [minuta do gate final — Documento 239](239-minuta-gate-final-encerramento-metodologico-documental-fase4.md), o proprietário declarou expressamente na conversa OES: **“Minuta aprovada.”** A referência inequívoca é a proposta `APPROVED — OES / F4-FINAL-GATE / PASS_DOCUMENTARY_ONLY` apresentada integralmente no Documento 239, inclusive **condições vinculantes C1–C6**.

**DECISÃO FINAL:** aprovar o **encerramento da Fase 4 — Protocolo de Atualização exclusivamente no plano metodológico e documental**. A autorização do proprietário está materializada neste registro; não é necessário um segundo consentimento para esta **formalização de decisão já aprovada**. Esta decisão **não certifica** implementação, produção, qualidade científica independentemente revisada, cobertura de fontes, continuidade de serviço ou eficácia dos controles de segurança.

**Estado canônico novo:** `PHASE_4_CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`  
**Readiness operacional preservado:** `NOT_READY`  
**Fase 5:** `NOT_STARTED`  
**Gate aprovado:** `F4-FINAL-GATE = PASS_DOCUMENTARY_ONLY` **com condições C1–C6**.

## 2. Fundamentação do gate

1. O [Documento 237](237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md) tornou a **suficiência metodológica e documental** o critério determinante de fechamento, sem exigir implantar a solução.
2. O [Documento 238](238-f4-c01-c06-matriz-evidencias-gate-documental.md) demonstrou a rastreabilidade de **SF-01–SF-14**, confrontou logicamente o runbook **R0–R8** com **AT-01–AT-12** e identificou **nove cenários documentalmente coerentes sem ressalvas adicionais** e **três coerentes sob salvaguardas vinculantes** (AT-05, AT-09, AT-12). Não identificou contradição documental crítica nova no escopo da revisão.
3. A [minuta aprovada — Documento 239](239-minuta-gate-final-encerramento-metodologico-documental-fase4.md) consolidou os julgamentos **F4-C01–F4-C06**, explicitou as seis condições vinculantes e ofereceu ao proprietário `PASS_DOCUMENTARY_ONLY`, `REVISE` ou `NOT_READY`.
4. A manifestação **“Minuta aprovada”** aceitou a recomendação `PASS_DOCUMENTARY_ONLY` e as respectivas condições. O ato não adiciona nem simula novas provas.

**Classificação obrigatória:** `12/12` cenários especificados; `9/12` documentalmente coerentes sem ressalvas adicionais; `3/12` com condições explícitas; `0/12` ensaios integrados operacionais executados no corpus da matriz; `0` revisões científicas independentes executadas no gate. Um `PASS_DOCUMENTARY_ONLY` **não** pode ser apresentado como `PASS_OPERATIONAL`, `EXPERT_VALIDATED` ou `PRODUCTION_READY`.

## 3. Condições C1–C6 aceitas como vinculantes

| Condição | Compromisso preservado após encerramento documental |
|---|---|
| **C1 / AT-05** | `duplicate_or_already_covered` requer ator humano e vínculo rastreável; `invalid_signal`/`out_of_scope` científico **autoritativo** depende de `human_reviewer`/`human_expert`. Na ausência de profissional competente, **não invalidar** por ato de IA/owner; sinal permanece em proposta/pendência e histórico é preservado. |
| **C2 / AT-09** | Separar A2 do proprietário e A3 independente. N2 padrão A2 pode ser divulgado com limitação explícita; N2 crítico, N3 formal e N4 exigem revisões/instâncias correspondentes quando cabíveis. Não publicar ou afirmar revisão inexistente. |
| **C3 / AT-12** | Distinguir correção editorial de alteração científica. Respeitar a política aplicável de versionamento, classe `editorial`, histórico e provenance; não alterar `CurrencyState` por mera edição, nem dispensar sempre uma versão ou exigir sempre nova versão científica. |
| **C4** | Signal, ausência de hits, Alert, Monitor e atraso temporal **não** promovem ciência, currentness, assurance ou ProductVersion automaticamente. Cadence/threshold/SLA normativos não calibrados; `M3 BLOCKED`. |
| **C5** | BRG-03/06/07/08 bloqueados; BRG-09 parcial; 36 migrations `UNREVIEWED`; SA-05/06/07/08/10 abertos; controles de segredos, auditoria, ledger/fencing, backup/restore e custos não aprovados para a operação. **Antes do ato futuro de risco correspondente**, realizar as provas e obter os gates próprios. |
| **C6** | Divulgação fiel dos limites: 12 cenários documentados, nenhum teste end-to-end da matriz ou revisão independente; D1 apenas sintético/local/memória; D2 factual apenas recuperação NCBI pontual e reconciliação documental Shaffer. Ficha N2, GRADE, versão científica, assurance, currentness e gates de produto não promovidos; M3 bloqueado, prontidão operacional `NOT_READY`, Fase 5 `NOT_STARTED`. |

As condições **não são exceções temporárias facultativas**: são restrições permanentes da presente decisão até revisão explícita dos protocolos/gates competentes. Nenhuma medida operacional anteriormente exigida foi dispensada para os atos em que se aplica.

## 4. Rastreabilidade dos estados de D0, D1, D2, governança e implementação

- **D0:** escopo documental histórico encerrado.
- **D1:** `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`; T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`; A2-G5/runtime `NOT_AUTHORIZED`. A branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` não será alterada/mesclada.
- **D2:** iniciativa factual global **parcial e não encerrada**; D2-E2 provou acesso conectado NCBI pontual em GitHub Actions [run 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270), não busca exaustiva; D2-E3 `CLOSED_RESTRICTED_DOCUMENTARY_RECONCILIATION_ONLY` via [Documento 236](236-d2-e3-encerramento-restrito-rastreabilidade-shaffer-cp259.md).
- **Produto N2** `OES-P-2026-000401`: A2 interno, baseline 2026-10-04, sem validação especializada independente nem atualização científica/quantitativa da Ficha; nenhuma revisão automática de ROBIS/RoB2/GRADE.
- **Governança operacional:** BRGs e riscos SA permanecem nas situações históricas vigentes; 36 migrations `UNREVIEWED`, zero pós-condições de reconciliação homologadas, nenhuma prova operacional nova de restore/ledger/fencing. Fase 5 `NOT_STARTED`. Ausência de parecer humano independente expressa, não substituída por aprovação do proprietário.
- **Proveniência:** artefatos documentais e runbook preservados no repositório; suplemento binário original Shaffer permanece na Biblioteca pessoal do ChatGPT conforme CP257–CP260, não publicado na `main`.

## 5. Consequências e proibições

**Única consequência autorizada e executada por este ato:** registrar a Fase 4 como **`CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`** nos artefatos canônicos de governança/continuidade; conservar o protocolo de atualização como referência para etapas posteriores.

**Não autorizados por esta aprovação:** iniciar a Fase 5, implementar stack/framework, tocar Neon/SQL, executar migrations/CI conectada, coletar novo dado factual, persistir informação científica, ativar M3, operar scheduler, reanalisar Shaffer/Hwang, modificar Ficha N2, certainty/GRADE, `ProductVersion`, `currentness`, `assurance`, publicar produto ou aceitar serviço pago. Todas essas ações exigem avaliação e autorização próprias.

O fechamento é **da etapa de concepção e formalização metodológica do protocolo**, não de todas as atividades futuras relativas à atualização de evidências. Pendências operacionais não precisam ser resolvidas antes desse marco, mas **não podem ser ignoradas ao iniciar execução**.

## 6. Ponto seguinte de governança

Com a Fase 4 metodológica/documental concluída e Fase 5 ainda não iniciada, o **próximo `Prossiga`** deverá preparar **uma decisão de prioridades pós-Fase 4**, confrontando o D2 factual ainda incompleto, os requisitos mínimos de uma futura implementação da solução e a governança operacional, **sem dar início a nenhum desses trabalhos por inferência**. Respeitar um trabalho delimitado por `Prossiga`, Freshness Gate e checkpoints proporcionais.

**DECISÃO EFETIVA:** `APPROVED — OES / F4-FINAL-GATE / PASS_DOCUMENTARY_ONLY` — **FASE 4 ENCERRADA METODOLÓGICA E DOCUMENTALMENTE**, limitada pelas condições C1–C6. **STOP.**
