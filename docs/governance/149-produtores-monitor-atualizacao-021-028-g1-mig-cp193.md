# 149 — Produtores 021–028 para dependências do piloto factual P-B

**OES | Fase 4 | 2026-10-20 | CP193 | modo médio**  
**Resultado:** `G1_MONITOR_UPDATE_PRODUCERS_STATICALLY_IDENTIFIED_NOT_OPERATIONALLY_VALIDATED`. Apenas leitura dos arquivos SQL versionados; nenhum SQL executado.

## 1. Freshness Gate e escopo

HEAD de entrada CP192/main `a7ef8c1a2ae1cde8a3280b302850b34ae0471c17`: identical, zero ahead/behind. Ponteiro, handoff CP192, Documento 148 e registros de continuidade conferidos. Autorização `PREPARE_G1_DOCUMENTARY_ONLY` segue vigente. Foram examinados **os oito arquivos 021–028** via GitHub, sem CI, acesso ao Neon, criação de recurso, serviço pago, source query ou epoch.

## 2. Inventário dos produtores observados

| Entrada | Objetos identificados em CREATE TABLE | Papel funcional |
|---|---|---|
| 021_evidence_monitor_contract | `maintenance.monitor_definition`, `monitor_target`, `monitor_state`, **`monitor_cycle`**, `cycle_search`, `evidence_event`, `candidate_assessment`, `cycle_currency_state` | Contrato físico de monitoramento |
| 022_evidence_monitor_projection_hardening | `maintenance.candidate_impact`, `monitor_source_requirement` | Requisitos de fonte e integridade de monitoramento |
| 023_evidence_monitor_view_rendering_readiness | Nenhuma tabela CREATE observada; funções de projeção de `monitor_cycle` e views de produto | Renderização e readiness |
| 024_evidence_alert_contract | `maintenance.evidence_alert`, `alert_source`, `alert_affected_dimension` | Contrato de alertas |
| 025_evidence_alert_projection_hardening | Nenhuma tabela CREATE observada; funções de consistência e publication gate | Hardening de alertas |
| 026_evidence_alert_view_rendering_readiness | Nenhuma tabela CREATE observada; função `product.evidence_alert_view` | Renderização de alertas |
| 027_transversal_update_protocol_contract | `maintenance.update_policy`, `update_signal`, `update_signal_source`, `materiality_assessment`, `materiality_dimension`, `update_decision`, `update_decision_currency_state` | Núcleo do protocolo transversal |
| 028_transversal_update_protocol_audit_hardening | Nenhuma tabela CREATE observada; funções `assert_update_decision_signal_active`, `update_policy_issues`, `update_signal_issues` e correlatas | Auditoria/validação do protocolo |

**Aresta resolvida:** referências `maintenance.monitor_cycle` nas migrations temporais 031–032 têm como produtor observável a entrada **021**, não uma migration 022–026 não identificada.

**Outras arestas corroboradas:** `maintenance.update_policy`, `update_signal` e `update_decision` usados no domínio 031–032 são produzidos em 027. Os objetos de 029 e 030 identificados no Documento 148 seguem como produtores já observados.

## 3. O que esse achado demonstra — e o que não demonstra

A leitura reduz a incerteza sobre os **produtores de tabelas** essenciais, mas não estabelece que toda função, trigger ou view em 031–036 possa ser instalada sem 022–026/028, nem que cada uma dessas entradas seja essencial ao piloto limitado. Contratos de projeção, atualização, segurança e integridade podem criar dependências não capturadas pelo simples inventário de CREATE TABLE.

Consequentemente:

- `MONITOR_CYCLE_PRODUCER=021_CONFIRMED_BY_SOURCE`.
- `UPDATE_SIGNAL_POLICY_DECISION_PRODUCER=027_CONFIRMED_BY_SOURCE`.
- `FULL_CROSS_MIGRATION_CLOSURE=NOT_PROVEN`.
- `REDUCED_INSTALLATION_PLAUSIBILITY=UNDETERMINED`.
- `MIGRATION_ORDER_APPROVED_FOR_FACTUAL=NO`.

Não presumir que a ausência de `CREATE TABLE` em 023, 025, 026 ou 028 as torne descartáveis; podem alterar comportamento por funções, triggers ou dependências indiretas. Também não se concluiu que o piloto de duas fontes deve implantar todos os produtos de Monitor/Alert: é questão de closure, não de preferência arquitetural.

## 4. Pendências e critério de utilidade do próximo passo

O restante não inspecionado individualmente no CP192/193 inclui **003–020**; closures indiretas, referências dinâmicas PL/pgSQL e pós-condições são pendências reais. Para evitar documentação circular, a próxima análise deve focar em **uma questão com efeito decisório**: determinar, a partir de arestas explícitas das funções e objetos usados por 033–036, se um subconjunto do manifesto é *plausível*, sem alterar a política canônica ou simular PASS de execução.

**CP194 candidato, somente com novo `Prossiga`:** estabelecer teste documental de necessidade dos grupos 021–028 para primeiro evento temporal e distinguir dependência SQL estrita de dependência de produto, sem executar SQL. Se a análise não permitir decisão, documentar STOP e não repetir testes estáticos sem utilidade.

## 5. Limites que permanecem

36 migrations `UNREVIEWED`, 0 pós-condições aprovadas, 36 requisitos 034–036 `NOT_COLLECTED`, 12 controles de roles não satisfeitos. BRG-03/06/07/08 `BLOCKED`, BRG-04/05 históricos, BRG-09 evidência parcial sem aprovação operacional. B1R1 `EXPIRED_NOT_EXECUTED`, P-B e novo epoch não autorizados, M3 `BLOCKED`, Fase 4 documental `NOT_READY`, Fase 5 `NOT_STARTED`. Nenhuma operação Neon, SQL, CI/PG18, PubMed/ClinicalTrials ou pagamento neste CP.

**STOP.**
