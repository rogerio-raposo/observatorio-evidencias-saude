# Governança 170 — D1: especificação mínima e revisão de compatibilidade (CP215)

**OES | 2026-10-21 | D1-A3–A5 | documento técnico preparatório — IMPLEMENTAÇÃO NÃO AUTORIZADA**

**Autoridade:** prioridades e limites no Documento 169 (CP214), com fundamento nos Documentos 164, 165 (decisão histórica preservada), 38, 174–176 e código versionado. D1-A3 auditou estaticamente a trilha do Monitor; D1-A4 formulou a proposta funcional; D1-A5 verificou compatibilidade e delimita um pedido de execução. Nenhum `Prossiga` genérico equivale a aprovação de execução técnica. Não modifica regras científicas, gates, estado das migrations ou stack definitiva.

## 1. Objetivo e critério de arquitetura

Produzir, **quando houver autorização específica**, a menor *fatia vertical reutilizável* do futuro OES: produto-alvo M2 sintético, Monitor sintético, ciclo, registro de sinais/candidatos, avaliação e decisão explícitas, histórico e apresentação auditável. A implementação deverá priorizar **Python, software livre e custo zero**, preservando a possibilidade futura de execução na **nuvem**. PostgreSQL permanece candidato preferencial de persistência, sem obrigatoriedade de deploy nesta primeira etapa.

**Invariante central:** decisão de Monitor não altera automaticamente `ProductVersion.conclusion_text`; `evaluate_update` pode corresponder a `under_evaluation` na *currency* do alvo, com ato, motivo e proveniência explícitos. Monitor editorial, Monitor operacional, currency do Monitor e currency científico do alvo são dimensões distintas.

Não adotar simulação que apenas imprime resultados predefinidos, nem derivar um novo sistema canônico paralelo. Serviços de domínio deverão executar transições reais sobre *dados fictícios*, com execução/replay determinístico verificável. A primeira persistência eventualmente isolada será demonstrativa e temporária, sem pretensão de equivalência ao OES-P1.

## 2. Base verificada documentalmente

- `database/021_evidence_monitor_contract.sql`: declara dependência de baseline + migrations 002–020; define `maintenance.monitor_target`, `monitor_cycle`, `evidence_event`, `candidate_assessment`, `cycle_currency_state`, controles de ciclo e proveniência.
- `database/022_evidence_monitor_projection_hardening.sql`: depende de 002–021, acrescenta `candidate_impact` normalizado e controles de consistência, temporalidade e cobertura.
- `database/023_evidence_monitor_view_rendering_readiness.sql`: depende de 002–022; `product.evidence_monitor_view` retorna JSON `oes.evidence_monitor_view/0.1`. **Reexecutar a View original em PostgreSQL não equivale a aplicar apenas 021–023 isoladamente**.
- `database/f3-evidence-monitor-fixtures.sql`: dois ciclos M2, um sem atualização e outro com novo estudo e sinal regulatório fictícios, múltiplas dimensões de impacto e decisão `evaluate_update`; inclui simulações rotuladas `fixture-ai` e `fixture-owner`, não pessoas/revisões reais.
- `scripts/render_evidence_monitor_reference.py`, `scripts/render_evidence_sheet_reference.py`, `templates/evidence-monitor.md` e `templates/evidence-monitor-presentation-map.json`: renderização sem decisões científicas. `scripts/validate_evidence_monitor_render.py` valida cenário histórico de View SQL; **não deve ser empregado sem adaptação como se testasse um contrato novo**.
- Histórico `docs/products/176-resultado-validacao-template-monitor-evidencias.md`: run S5 `37558043092` em 2026-10-07, `success`, HEAD `40762d00f874599716fcbb86271bea4084ca19ef`, artifact `11455658237`, digest `sha256:6d80f9f80622713717d373d99ea200481f8926c295587e223a15a2f179bde0e3`. Em D1-A3 os **metadados** do artefato estavam disponíveis (expiração 2026-11-06 01:38:17 UTC), mas o ZIP e os JSONs **não foram inspecionados nem preservados** nesta trilha.
- Nenhuma execução SQL, Python, CI, busca externa, Neon ou teste de conformidade ocorreu em D1-A3–A5.

## 3. Divergências concretas e tratamento obrigatório

| Referência canônica SQL | Camada editorial existente | Disposição D1 |
|---|---|---|
| `candidate_kind` inclui `regulatory_signal`, `validity_event`, `scope_change_signal`, `review_update` | mapa utiliza `regulatory_or_contextual`, `correction_or_update`, `other` | preservar código canônico no registro; tradução é somente de apresentação e requer tabela de mapeamento explícita, testada |
| `candidate_impact.impact_class` admite `quantitative`, `certainty`, `applicability`, `conclusion`, `validity`, `scope` | mapa inclui `safety` e `other`, sem `validity`/`scope` | não converter categorias silenciosamente; confirmar compatibilidade por enum antes de exibir |
| `monitor_cycle.maintenance_decision` admite `no_update_needed`, `evaluate_update`, `update_recommended`, `outdated` | mapa inclui `urgent_reassessment` mas não `outdated` | separar `maintenance_decision` de `escalation_recommendation`; jamais substituir um pelo outro |
| `cycle_currency_state` associa decisão terminal a currency: `evaluate_update` → `under_evaluation` | resultado poderia ser confundido com revisão da conclusão | exibir transição como *estado de avaliação*, mantendo texto/versão científica imutáveis |
| Fixture contém `ai_verified` e `owner_governance_approval` ficcionais | validator histórico verifica assurance A2 do fixture | registrar `scenario_assertion` e `executed_by=automated_test` separadamente; **não declarar IA/verificador ou owner real** |
| `product.evidence_monitor_view/0.1` é gerada por SQL | renderer validado consome somente essa View | evitar alimentar o template canônico com JSON substituto cuja equivalência não esteja demonstrada |

As diferenças são **incompatibilidades de vocabulário/escopo a corrigir no protótipo**, não defeitos comprovados das validações históricas.

## 4. Comportamentos D1.0 e contratos propostos

**Componentes de aplicação sem dependência direta do framework HTTP:**
- `domain`: tipos e invariantes do cenário, `MonitorCycle`, `EvidenceEvent`, `CandidateAssessment`, `CandidateImpact`, `MaintenanceDecision`, `TargetCurrencyState`.
- `application`: `create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`, `get_snapshot`.
- `persistence`: `ScenarioRepository` como interface com unidade atômica de escrita, persistência de eventos e controle de duplicatas; implementação **em memória para testes autorizados** e candidato PostgreSQL sintético isolado para etapa seguinte, após sua própria autorização.
- `presentation`: serialização e visualização de histórico sintético, sem cálculo de impacto/assurance/publicabilidade.

**Entrada obrigatória:** identificadores estáveis de cenário, produto-alvo/versão, Monitor/versão e ciclo; payload com `synthetic=true`, `fixture_source`, tipo de ato, timestamp controlado, `request_id` para idempotência, `scenario_actor` (personagem do teste), `executed_by` (mecanismo realmente operante), decisão explícita e motivação quando cabível. Não forjar humanos ou verificadores especializados; não aceitar payload factual.

**Estados permitidos:** ciclo usa valores canônicos `planned/running/completed/incomplete/cancelled`; candidato `pending/excluded/retained_for_impact`; impactos respeitam os códigos SQL de 022. Fechamento exige decisão, rationale, ator declarado, janela consistente, ausência de inconformidades essenciais e atualização rastreável da currency do alvo quando aplicável. Repetição com mesmo `request_id` não duplica evento; reutilização com payload divergente falha. Eventos e avaliações encerrados são imutáveis; correção futura por novo evento/supersessão, não apagamento.

**Saída:** `oes.d1.monitor_snapshot/0.1` (proposta, **não** `oes.evidence_monitor_view/0.1`). Campos mínimos: `schema_version`, `synthetic`, `scenario_id`, identidades/versionamento, separação dos quatro estados, baseline/cycle cutoff, lista de ciclos, sinais, avaliações/impactos, decisão, moeda de avaliação (*currency*) do alvo, trilha/replay e `execution_disclosure`. Carregar literalmente a conclusão científica sintética inicial; comparar seu hash calculado de maneira estável antes/depois. O snapshot contém sinalização explícita de quais serviços foram executados, quais dados provêm de fixtures históricas, o que foi simulado, e de que **nenhuma View SQL/fonte científica/parecer científico foi executado** quando isso for verdade.

**Apresentação:** desenvolver template demonstrativo próprio ou adaptador de *campos projetados declarados*, reutilizando somente o motor neutro Python; manter o contrato do Documento 174 inviolado para a View canônica. Não afirmar A2 ou publishable apenas porque a fixture histórica os contém. Não propor API pública para operações de escrita no primeiro incremento.

## 5. Sequência de implementação sugerida (não autorizada)

**T1 — Núcleo Python sintético isolado:** arquivos de domínio, casos de uso, interface de repositório, implementação determinística em memória, serializer `oes.d1.monitor_snapshot/0.1`, template demonstrativo, testes locais isolados e documentação de execução/proveniência. Somente software gratuito, nenhum banco, Neon, CI remoto, deploy, API pública, dados factuais ou cartão. A autorização documental deste plano **não autoriza T1**.

**T2 — Persistência sintética:** somente após T1 passar e após autorização específica, adaptador PostgreSQL em projeto/branch isolado, **sem acesso ao schema canônico** e sem se apresentar como migração oficial. Validar idempotência/concorrência, isolamento, limpeza e possibilidade de migração futura. Não instalar 36 migrations por padrão; SQL original continua não validado nesse adaptador.

**T3 — Demonstração na nuvem:** somente após autorização separada, comparar limites gratuitos atuais de Render/Neon e alternativas e escolher hospedagem; verificar ausência de custos automáticos/cartão, TLS, controle de acesso e bloqueio de escrita pública anônima. Hospedagem não é produção nem D2.

**T4 — Compatibilidade com OES-P1:** trabalho futuro de cruzamento de contratos e testes diferenciais usando payloads SQL históricos confiáveis e/ou PostgreSQL original em ambiente separado, com autorização específica. Sem reivindicar paridade enquanto os testes não forem realizados.

## 6. Critérios S1–S6 convertidos em testes executáveis futuros

| Critério | Evidência mínima prevista | Falhas deliberadas a rejeitar |
|---|---|---|
| **S1 identidade** | par produto/Monitor/versões consistente, ciclo único, vínculo com target imutável | target desconhecido, troca de Monitor, `cycle_no` repetido |
| **S2 proveniência** | `synthetic=true`, `fixture_source`, `scenario_actor`, `executed_by`, zero consultas externas | entrada factual, atribuição humana/IA real fictícia |
| **S3 sinais** | registrar evento/candidato vinculado, idempotência de `request_id` com replay estável | duplicação, origem inexistente, mutação após fechamento |
| **S4 avaliação** | impacto 1:N sem perda, decisão e rationale registradas, hash de conclusão científica idêntico | impacto primário ausente ou múltiplo, decisão implícita, alteração de conclusão |
| **S5 projeção** | snapshot determinístico, estados/cutoffs separados e render demonstrativo legível | preencher `audit.publishable`/A2 como real, forjar `evidence_monitor_view/0.1` ou esconder incerteza |
| **S6 auditoria** | ordenação de eventos, repetição produz snapshot equivalente, isolamento, descarte verificável | replay divergente, credencial no código, consulta factual, persistência além do escopo |

Esses testes são **critérios do demonstrador**, não homologação de produção, revisão científica ou novas regras de governança.

## 7. Prontidão, riscos e autorização proposta

**Estado da análise:** `SPECIFICATION_CANDIDATE_READY_FOR_OWNER_DECISION`. Não é `READY_TO_EXECUTE`.

**Riscos remanescentes:** contrato JSON demonstrativo ainda não implementado; tipo de ator/proveniência necessita discriminação entre ficção e execução; equivalência à SQL original não demonstrada; definição transacional do adaptador PostgreSQL pendente; limites atuais dos planos cloud devem ser reconferidos na implantação; artefato S5 pode expirar em 2026-11-06.

**Solicitação proposta, NÃO CONCEDIDA:**

`APPROVED — OES / D1-T1 / PYTHON_SYNTHETIC_DOMAIN_ONLY / Implementar e testar localmente serviços Python e representação demonstrativa sintética, em isolamento e sem serviços pagos; sem SQL, Neon, CI remota, implantação cloud, API pública, consultas factuais, migrações ou mudança de gates.`

Sem declaração expressa do proprietário, este texto **não é autorização**. Qualquer futura aprovação deverá indicar escopo e limites com precisão; não se presume autorização de T2–T4.

## 8. Situação inalterada e ponto de retomada

Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`, 0 pós-condições aprovadas, 36 requisitos 034–036 `NOT_COLLECTED`, 12 controles de roles pendentes; BRG-03/06/07/08 `BLOCKED`, BRG-04/05 históricos, BRG-09 parcial; B1R1 `EXPIRED_NOT_EXECUTED`, M3 bloqueado. D0 concluído no escopo documental; D1 prioritário; D2 factual e governança operacional completa posteriores. Nenhuma operação técnica foi realizada em D1-A3–A5.

**Próximo passo (sob novo `Prossiga`):** D1-A6 — apresentar a decisão técnica de T1 e o pedido de autorização, sem iniciar implementação nem testes até aprovação operacional explícita; avaliar, separadamente, obtenção read-only do artefato S5 para evitar perda por expiração. STOP.
