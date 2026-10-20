# 156 — Plano transversal de evidências 031–036 / BRG-06

**OES | Fase 4 | CP201 | 2026-10-20 | modo médio**
**Classificação:** `G1_BRG06_PLAN_DRAFT_ONLY`. Exclusivamente documental; nenhuma pós-condição aprovada.

## 1. Escopo
Consolida A1–A3 pós-CP200, com base nos Documentos 152–155 e catálogo `database/f4-reconciliation-postconditions-draft.json`. As 36 migrações constituem baseline candidata; `PREPARE_G1_DOCUMENTARY_ONLY` é a única autorização aplicável. Nenhuma execução Neon, PostgreSQL, CI, consulta PubMed/ClinicalTrials ou serviço pago.

## 2. Inventário e lacunas
| Migration | Inventário textual | Lacunas principais |
|---|---|---|
| 031 | 15 tabelas, 22 funções, 26 triggers esperados (nove dinâmicos) | Identidade DDL, guardas, CHECK legadas, rollback |
| 032 | 10 tabelas, 56 funções, 23 triggers (quatro constraint diferíveis), sete colunas | Deferrability, FKs, compatibilidade estrutural e erro no COMMIT |
| 033 | 12 tabelas, 27 funções, 23 triggers, duas views | Lifecycle, append, imutabilidade e tentativas concorrentes |
| 034 | Guard de cronologia de ativação | Janela temporal, autoridade válida em `started_at`, desvios |
| 035 | Duas funções STABLE de preflight | 10 checks impeditivos, um informativo, precedência FAIL/WAIT/PASS; diagnóstico não ativa epoch nem mitiga TOCTOU |
| 036 | Guard de primeira conclusão por `epoch_source_uuid` | Primeira/subsequente medição, contagem e concorrência |

Contagens são declarações estáticas, não comprovação de instalações.

## 3. Matriz transversal candidata
| Grupo | Evidência mínima futura | Critério proposto |
|---|---|---|
| G1-E01 identidade | SHA-256 das fontes, manifesto, dependências, recibos | Fonte inspecionada e fonte aplicada inequivocamente correspondentes |
| G1-E02 estrutura | Catálogos de objetos, constraints, FKs, funções, triggers habilitados e permissões | DDL e vínculos exatos, não apenas existência |
| G1-E03 transações | Limites transacionais, recibos, falhas e rollback | Nenhuma aplicação parcial indevida |
| G1-E04 comportamento | Casos positivos/negativos para guards, lifecycle, autoridade e preflight | Rejeições/aceitações conforme regras |
| G1-E05 concorrência | Ensaios de tentativas simultâneas e primeira conclusão | Nenhuma violação das invariantes nos cenários testados |
| G1-E06 auditoria | Ambiente, executor, instante, resultados observados e revisão independente | Rastreabilidade verificável sem lacunas impeditivas |

Rótulos provisórios D0 = descrito, D1 = observado/reproduzível, D2 = reconciliado/revisado são ferramenta de análise e não estados oficiais ou aprovação.

## 4. Plano e autorização
1. Fixar e aprovar separadamente o manifesto e baseline antes de qualquer execução.
2. Preparar E01/E02 e consultas de catálogo, **sem executá-las**.
3. Preparar E03/E04/E05 com cenários de falha, rollback, guarda e concorrência para ambiente descartável futuro, sujeito a autorização específica.
4. Preparar E06, atribuições funcionais e protocolo de revisão independente.
5. Somente após autorização expressa, considerar verificações no banco; uma consulta somente leitura também exige autorização operacional.

Dependências de evidência: 031/032 integram contratos precedentes; 033 provê epoch/eventos; 034 reforça cronologia, 035 informa preflight consultivo e 036 reforça primeira conclusão. Isto não substitui validação do grafo de dependências SQL.

## 5. Riscos e responsabilidades
R1: aplicação parcial; R2: corrida em `attempt_no` e primeira conclusão; R3: TOCTOU e preflight não obrigatório; R4: autoridade histórica, permissões e proveniência não comprovadas.
Funções apenas propostas: proprietário decide; responsável técnico projeta; executor autorizado opera; revisor independente julga; governança registra. Não satisfaz os 12 controles de papéis pendentes.

## 6. Bloqueios preservados e retomada
36/36 migrações UNREVIEWED; zero pós-condições aprovadas; 36 requisitos de 034–036 NOT_COLLECTED; 12 controles de papéis pendentes. BRG-03/06/07/08 BLOCKED; BRG-04/05 evidência histórica/sintética; BRG-09 parcial. B1R1 EXPIRED_NOT_EXECUTED; novo epoch e primeiras consultas factuais não autorizados; M3 bloqueado; Fase 4 NOT_READY e Fase 5 NOT_STARTED.

**Próximo bloco, A1 sob novo Prossiga:** reconciliar rastreabilidade documental dos requisitos candidatos 031–036 ao catálogo, sem modificar catálogo nem executar SQL. **STOP.**
