# 148 — Dependências estáticas temporal 031–036 versus base 001–030

**OES | CP192 | 2026-10-20 | modo médio**  
**Resultado:** `G1_PREBASE_DEPENDENCY_EDGES_PARTIALLY_MAPPED` — sem autorização de instalação e sem teste operacional.

## 1. Fontes e limites

Freshness Gate CP191/main `9904f4af48dafbc53441c005b4c7531f3ce5e449`: identical, ahead/behind 0. Conferidos ponteiro CP191, handoff, Documento 147, manifesto e artefatos GitHub. Autorização permanece `PREPARE_G1_DOCUMENTARY_ONLY`, sem SQL, Neon, CI/PG18, consulta PubMed/ClinicalTrials.gov, epoch ou custos.

O manifesto inclui 36 entrypoints. A tentativa de leitura em lote dos 30 arquivos antecedentes excedeu o limite da integração. Para não fabricar uma closure completa, examinamos diretamente as migrations de base `poc-s1.sql`, `002`, `027`, `029`, `030`, além dos wrappers e fragmentos já inspecionados no CP191. **Os demais arquivos 003–026 e 028 não foram individualmente varridos neste checkpoint; nenhum resultado exaustivo é alegado.**

## 2. Arestas concretas identificadas pela leitura direta

| Consumidor (031–036) | Objeto requerido | Produtor observado (001–030) | Grau de evidência |
|---|---|---|---|
| 031a/031c | `core.entity_version` | `poc-s1.sql` | Objeto CREATE TABLE identificado |
| 031c/032a/033a | `product.product_version` | `poc-s1.sql` | Objeto CREATE TABLE identificado |
| 031c/032a/033a | `investigation.investigation_version` | `poc-s1.sql` | Objeto CREATE TABLE identificado |
| 031c/032a/033a/033b | `artifact.artifact` | `poc-s1.sql` | Objeto CREATE TABLE identificado |
| 033b | `investigation.search` | `002_poc_s2_search_screening_risk.sql` | Objeto CREATE TABLE identificado |
| 033b | `investigation.search_hit` | `002_poc_s2_search_screening_risk.sql` | Objeto CREATE TABLE identificado |
| 031b/031c/032a | `maintenance.update_signal` | `027_transversal_update_protocol_contract.sql` | Objeto CREATE TABLE identificado |
| 031c/032a | `maintenance.update_policy`, `maintenance.update_decision` | `027_transversal_update_protocol_contract.sql` | Objetos CREATE TABLE identificados |
| 031c/032a/032d | `maintenance.monitor_cycle` | 021–026 **a confirmar no produtor exato** | Hipótese baseada no escopo de monitoramento; não verificado |
| 031c/032a/032d | `maintenance.sla_rule`, `sla_instance` | `029_integrated_operational_control_contract.sql` | Objetos CREATE TABLE identificados |
| 031c/032a | `maintenance.workflow_round`, `priority_assessment` | `029_integrated_operational_control_contract.sql` | Objetos CREATE TABLE identificados |
| 031c/032a | `maintenance.update_risk_profile` | `030_update_risk_profile_contract.sql` | Objeto CREATE TABLE identificado |

**Interpretação:** pelo menos as migrations 001, 002, 027, 029 e 030 fornecem objetos usados na camada 031–036. Arestas adicionais, efeitos de `ALTER`, views, sequences, types, triggers, ordem de funções e relações indiretas não foram exaustivamente verificadas; não afirmar que esses cinco arquivos formam uma instalação suficiente.

## 3. Condição de viabilidade de uma instalação reduzida

**Resultado:** `REDUCED_INSTALLATION_PLAUSIBILITY=UNDETERMINED`. A cadeia completa do manifesto permanece baseline sintética candidata e **não é autorizada para factual Neon**. A existência de referências cruzadas demonstra que instalar apenas 033–036 seria insuficiente no schema vazio observado anteriormente, mas não demonstra que todas as 36 entradas sejam indispensáveis. Qualquer redução exige:

1. Inventário textual sistemático de 003–026 e 028 e construção de grafo de CREATE/ALTER/REFERENCES/funções/triggers, distinguindo nomes de objetos de dependências realmente executáveis.
2. Checagem explícita de dependências dinâmicas em PL/pgSQL e contratuais, não alcançadas por regex de DDL.
3. Preservação dos 14 SQL subordinados de 031–033 em ordem `\\ir` e paths psql adequados.
4. Critérios estáticos de suficiência por objeto, sem ignorar ledger, roles, auditoria, provenance, artifacts e recuperação.
5. Somente futuramente, após decisão específica, ensaios descartáveis que comprovem ou refutem a hipótese — **não realizados aqui**.

## 4. Bloqueios e próximo checkpoint

36 migrations continuam `UNREVIEWED`, 0 pós-condições aprovadas, 36 requisitos 034–036 `NOT_COLLECTED` e 12 controles roles insatisfeitos. BRG-03/06/07/08 bloqueados; 04/05 históricos; 09 parcial, não aprovado. B1R1 expirado sem execução, P-B e novo epoch não autorizados; M3 bloqueado, Fase 4 documental não encerrada, Fase 5 não iniciada.

**CP193 candidato, somente sob novo `Prossiga`:** fechar **uma lacuna por vez** da matriz de produtores não inspecionados, começando pelas dependências `monitor_cycle` e outras referências 021–028, sem compilar nem executar SQL ou prometer subset. Avaliar custo-benefício do detalhamento antes de novo ciclo.

**STOP após reconciliação.**
