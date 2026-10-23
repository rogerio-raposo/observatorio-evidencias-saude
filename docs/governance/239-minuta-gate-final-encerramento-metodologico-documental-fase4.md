# Documento 239 — Minuta única do gate final de encerramento metodológico-documental da Fase 4

**OES | 2026-10-23 | PROPOSAL_ONLY / RECOMMEND_PASS_DOCUMENTARY_ONLY_WITH_BINDING_CONDITIONS / OWNER_FINAL_APPROVAL_PENDING**

> **ESTE DOCUMENTO É UMA MINUTA PARA DELIBERAÇÃO.** Não constitui decisão do proprietário, não executa o gate, não altera o estado da Fase 4 e não autoriza a Fase 5.

## 1. Fundamentação e competência

- **Decisão de escopo aprovada:** [Documento 237](237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md): o marco determinante de encerramento da Fase 4 — Protocolo de Atualização é a **aceitação metodológica e documental**, não o funcionamento operacional.
- **Exame dos critérios:** [Documento 238](238-f4-c01-c06-matriz-evidencias-gate-documental.md) confrontou `F4-C01–F4-C06` com os registros `SF-01–SF-14`, runbook `R0–R8` e cenários `AT-01–AT-12`, priorizando AT-05, AT-09 e AT-12. Nenhuma contradição documental crítica nova foi identificada no escopo da inspeção.
- **Protocolo de autoridade científica:** [Documento 04](04-governanca-garantia-revisao.md). O proprietário pode ratificar a conclusão **metodológica/documental do projeto**, mas não se atribuir competência de parecerista científico independente que não possui. Análise de IA tampouco é peer review.
- **Decisão ainda requerida:** `F4-C06`. A recomendação deste documento somente pode tornar-se estado efetivo após aprovação inequívoca e específica do proprietário.

## 2. Parecer integrado para deliberação

| Critério de saída | Juízo na presente minuta | Elemento incontornável da eventual aprovação |
|---|---|---|
| **F4-C01** — cobertura | **Suficiente para o escopo documental** | SF-01–14 com rastreabilidade e classes distintas de prova; não homologar infraestrutura |
| **F4-C02** — coerência lógica | **Suficiente com condições** | 9 cenários coerentes sem ressalvas adicionais e 3 condicionados por guardas; **12 especificados, 0 executados end-to-end** |
| **F4-C03** — governança e garantia | **Suficiente com divulgação** | IA/owner não substituem revisor científico; níveis N0–N4/A0–A3 mantidos |
| **F4-C04** — atualidade e temporalidade | **Suficiente como método, não como calibração** | Cadence/threshold/SLA sem valores normativos aprovados, M3 bloqueado, alteração de conclusão/currentness somente sob seus próprios gates |
| **F4-C05** — dívidas e riscos | **Suficiente com condicionantes futuras** | Ledger de obrigações por gatilho futuro do Doc. 238 §5; controles operacionais exigíveis antes de operações relacionadas |
| **F4-C06** — deliberação final | **PENDENTE** | Nenhuma alteração de estado até ato expresso do proprietário; registrar decisão de saída com escopo e limites |

**Resultado recomendado, NÃO aprovado:** `PASS_DOCUMENTARY_ONLY_WITH_BINDING_CONDITIONS` para **encerramento metodológico e documental** da Fase 4. A categoria canônica do gate definida no Doc. 237 é `PASS_DOCUMENTARY_ONLY`; as condições abaixo acompanham e limitam essa aprovação, sem inventar um novo nível de assurance ou readiness.

O parecer é **análise de consistência documental assistida por IA**, não revisão externa do protocolo, não avaliação RoB/GRADE independente e não prova de funcionamento do software ou da coleta.

## 3. Condições vinculantes propostas

**C1 — AT-05 / autoridade para invalidação científica:** deduplicação exige vínculo e ator humano conforme contrato; classificação científica autoritativa `invalid_signal`/`out_of_scope` exige `human_reviewer`/`human_expert`. Na ausência desses profissionais, o sinal permanece proposto/em avaliação, **não é descartado por IA ou proprietário**. Preservar histórico e coerência de status. [Docs. 27](27-contrato-dados-integrado-plano-operacional-fase-4.md) e [138](138-runbook-manual-assistido-matriz-aceitacao-piloto-empirico-f4.md).

**C2 — AT-09 / garantia humana:** N2 padrão pode atingir A2 com declaração de ausência de revisor independente; N2 crítico pode exigir garantia adicional; N3 formal exige A3 e N4 A3 mais requisitos próprios de múltiplos revisores. **Nenhuma operação/publicação/assurance que exija pessoas qualificadas será executada na ausência delas.** Owner e IA não assumem A3 fictício. [Documento 04](04-governanca-garantia-revisao.md).

**C3 — AT-12 / mudança editorial:** correções editoriais e mudanças de conteúdo científico permanecem distinguíveis, com histórico preservado e classe de mudança compatível. Edição não altera `CurrencyState` automaticamente e não dispensa indiscriminadamente versão/registro editorial; aplicação depende da política de versão vigente. [Docs. 05](05-protocolo-transversal-atualizacao.md) e [138](138-runbook-manual-assistido-matriz-aceitacao-piloto-empirico-f4.md).

**C4 — integridade científica/temporal:** `UpdateSignal`, Alert, Monitor, ausência de novos hits e atraso temporal não justificam alteração automática de conclusão científica, ProductVersion, certainty, assurance ou currentness. Threshold, cadence e SLA normativos permanecem não calibrados; `M3 BLOCKED`.

**C5 — dívida operacional condicionante:** BRG-03/06/07/08 continuam bloqueados, BRG-09 parcial; 36 migrations `UNREVIEWED`; SA-05/06/07/08/10 abertos/diferidos; ledger/supervisor/fencing, segregação/auditoria independente e backup/restore não aceitos operacionalmente. Essas provas são exigíveis **antes** de persistência/execução/implantação em seus respectivos gatilhos, não para o fechamento puramente documental. Segurança não foi dispensada nem considerada comprovada. D1-T2-A2/A2-G4 permanece diferido/não aceito; A2-G5/runtime não autorizado.

**C6 — integridade do encerramento e divulgação:** classificar explicitamente `12/12 cenários especificados; 9 coerentes sem ressalvas documentais adicionais; 3 coerentes com condições; 0 execuções end-to-end; 0 revisões científicas independentes`. D1 encerrou **somente demonstrador local sintético em memória**, D2 realizou **apenas consulta NCBI conectada pontual** e reconciliação documental de Shaffer; nem D2 global nem o piloto empírico persistente foram encerrados. A Ficha N2 A2 interna e seus desfechos, estimativas, GRADE, ProductVersion/currentness e gates de produto permanecem inalterados. Fase 5 `NOT_STARTED`, nenhum M3/CI/SQL/Neon/serviço pago autorizado por este ato.

## 4. Alternativas formais à disposição do proprietário

- **`PASS_DOCUMENTARY_ONLY` (recomendado, condicionado a C1–C6):** aprovar a suficiência do Protocolo de Atualização da Fase 4 **exclusivamente em nível metodológico e documental**, preservando os bloqueios e limitações na decisão de encerramento a ser persistida.
- **`REVISE`:** identificar **qual critério F4-C01–C06** não foi satisfeito e qual correção documental mínima é necessária; não iniciar testes/infraestrutura automaticamente.
- **`NOT_READY`:** não encerrar, com identificação precisa de lacuna impeditiva do **escopo metodológico-documental**, sem converter indiscriminadamente requisitos de produção em novos requisitos documentais.

## 5. Texto proposto para autorização expressa futura — NÃO concedida

```text
APPROVED — OES / F4-FINAL-GATE / PASS_DOCUMENTARY_ONLY /
Aprovar o encerramento da Fase 4 — Protocolo de Atualização
exclusivamente em seu escopo metodológico e documental, conforme
Documentos 237–239 e condições vinculantes C1–C6 do Documento 239.
Reconhecer a suficiência documental F4-C01–F4-C06 com os limites de
validação declarados; manter revisão científica independente ausente,
12 cenários especificados e zero execuções end-to-end.
Preservar D1 sintético restrito, D2 factual parcial, Ficha N2,
GRADE, ProductVersion, currentness, assurance, M3, BRGs/SA,
36 migrations não revisadas, prontidão operacional NOT_READY e
Fase 5 NOT_STARTED.
Esta aprovação autoriza somente registrar a decisão de encerramento
documental no estado canônico e no checkpoint; não autoriza
implantação, Neon/SQL, novas buscas, CI, persistência, operação
autoritativa, publicação científica, serviços pagos ou Fase 5.
```

**Este texto é uma proposta:** `Prossiga` usado para preparar a minuta não equivale a `APPROVED — OES / F4-FINAL-GATE`. Se o proprietário adotar a aprovação, será necessário **um ato subsequente e delimitado de persistência** (documento de decisão final, `STATE.md`, `CHANGELOG.md`, handoff/pointer), com Freshness Gate, sem manipulação técnica/científica.

## 6. Disposição atual e próximo passo único

**Estado antes da decisão:** `F4_FINAL_GATE_DECISION_DRAFT_PREPARED / OWNER_APPROVAL_PENDING / PHASE_4_NOT_CLOSED / OPERATIONAL_NOT_READY`.

**Próximo passo:** submeter ao proprietário a recomendação e alternativas `PASS_DOCUMENTARY_ONLY`, `REVISE`, `NOT_READY`. Registrar sua decisão somente após manifestação expressa. Sem novas rodadas de documentos ou testes para “confirmar” fatos já verificados, salvo divergência material.

**STOP — minuta única disponibilizada; decisão final não registrada.**
