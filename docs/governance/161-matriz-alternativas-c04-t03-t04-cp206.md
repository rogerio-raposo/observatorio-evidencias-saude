# 161 — Matriz de contratos e alternativas C04/T03/T04 (CP206)

**OES | 2026-10-20 | Fase 4 | modo médio | DRAFT_ONLY**
**Autorização:** `PREPARE_G1_DOCUMENTARY_ONLY`. Não autoriza escolher, implantar ou ensaiar mecanismos.

## 1. Proveniência e alcance
Consolida três atividades pós-CP205: A1 revisão crítica de oráculos condicionais; A2 rastreabilidade entre invariantes, hipóteses e decisões; A3 comparação em modo alto de alternativas técnicas. Fontes: Documentos 159–160; SQL `database/033c_temporal_observation_guards.sql`, `034_temporal_observation_activation_chronology.sql`, `035_temporal_observation_activation_preflight.sql`. Freshness Gate: CP205 `11d843d45aa25cd80d89ae61b73ee7abe8318261` idêntico à `main` no início da preparação.

## 2. Hierarquia de análise
1. **Implementado:** comportamento derivável da fonte SQL, sem inferência de validação efetiva.
2. **Não demonstrado:** propriedade que exige ensaio transacional ou evidência operacional.
3. **Não decidido:** política de negócio e requisitos arquiteturais que precisam de decisão expressa.
A definição do contrato semântico precede a escolha do mecanismo SQL ou operacional.

## 3. Matriz de decisões ainda pendentes
| Ref. | Invariante identificada | Lacuna de concorrência | Decisão contratual pendente | Evidência futura |
|---|---|---|---|---|
| D-C04 | Trigger 033c exige epoch `active` e target atual na leitura | transição concorrente antes de COMMIT | quando o estado deve ser válido e qual serialização exige-se | sessões, interleaving, isolamento e estados finais |
| D-T03 | 034 usa `started_at` para autoridade e desvios; 033c também verifica condições em `CURRENT_TIMESTAMP` | mudanças entre `started_at` e COMMIT, visibilidade transacional | exigências históricas versus correntes, e significado de confirmação | cronologia de decisões, alterações e transações |
| D-T04 | 035 preflight consultivo usa `p_as_of`; 034 exige `started_at` anterior à primeira oportunidade | diagnóstico obsoleto ou ignorado | obrigatoriedade do preflight, validade temporal e responsabilidade operacional | preflight, ativação e estado final auditáveis |

`CURRENT_TIMESTAMP` refere-se ao início da transação no PostgreSQL, não ao COMMIT; `started_at`, `p_as_of` e tempo efetivo são conceitos distintos. Não modificar semântica temporal silenciosamente.

## 4. Alternativas comparadas, sem seleção
### D-C04 — consistência do epoch
- C-A: manter verificações existentes; menor alteração, sem garantia geral sob concorrência.
- C-B: bloqueio explícito da linha do epoch; coordenação condicionada ao uso coerente de bloqueios, risco de contenção/deadlock.
- C-C: isolamento SERIALIZABLE; serialização de transações abrangidas, exige tratar `SQLSTATE 40001` e reexecutar a transação inteira.
- C-D: advisory locks transacionais; flexibilidade com coordenação cooperativa e adesão obrigatória dos caminhos pertinentes.

### D-T03 — política temporal
- T03-A: predominância histórica em `started_at`; preserva semântica, permite mudanças posteriores conforme contrato.
- T03-B: validar critério histórico e condições correntes adicionais; pode restringir semântica vigente.
- T03-C: modelo híbrido por condição; maior granularidade com maior complexidade de auditoria.
Nenhuma opção deve ser tomada como resposta automática à mudança posterior a `started_at`.

### D-T04 — integração do preflight
- T04-A: exigência na aplicação; baixo acoplamento inicial, pode ser contornada por outros escritores.
- T04-B: procedimento transacional controlado no PostgreSQL; centralização, exige análise de permissões e concorrência.
- T04-C: guardas obrigatórias no banco e preflight diagnóstico; protege invariantes fora do fluxo consultivo, mas pode demandar mudança do contrato.
Nenhuma garante sozinha ausência de TOCTOU.

## 5. Dependências e risco de decisão prematura
C04: contrato de validade do epoch antes de escolher sincronização. T03: decidir quais invariantes são históricas e correntes antes de revalidação. T04: decidir obrigatoriedade operacional e controle dos caminhos de ativação, considerando 12 papéis pendentes. Soluções podem ser combinadas, mas exigem análise própria de interoperabilidade, custos, rollback e revisão independente. Este documento **não recomenda vencedora**.

## 6. Condições para uma futura decisão
Contrato semântico explícito, cenários e oráculos completos, comparação por integridade/complexidade/desempenho/permissões, baseline revisada, escopo de eventual alteração, papel autorizador, sandbox apropriado e plano de evidência. AUT-01–AUT-08 seguem como checklist auxiliar sem autoridade independente. SQL, SELECT, Neon, CI, migrações, novos epochs e dados factuais requerem autorizações separadas.

## 7. Bloqueios e retomada
36 migrações UNREVIEWED; zero pós-condições aprovadas; 36 requisitos 034–036 NOT_COLLECTED; 12 controles de papéis pendentes. BRG-03/06/07/08 BLOCKED, BRG-04/05 históricos, BRG-09 parcial; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado; Fase 4 NOT_READY; Fase 5 NOT_STARTED.

**Próximo bloco, A1:** preparar quadro documental dos contratos semânticos a submeter à decisão futura, começando pela política de validade temporal de `started_at`/`p_as_of` e pelos caminhos de ativação. Sem selecionar ou implementar opções. STOP.
