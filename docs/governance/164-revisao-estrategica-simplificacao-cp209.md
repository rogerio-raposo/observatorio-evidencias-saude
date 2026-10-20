# 164 — Revisão estratégica de simplificação e demonstração mínima OES (CP209)

**OES | 2026-10-20 | Fase 4 | modo médio de consolidação | PROPOSTA NÃO APROVADA**
**Autorização vigente:** `PREPARE_G1_DOCUMENTARY_ONLY`. Não altera gates, semânticas, permissões ou execução.

## 1. Motivação e proveniência
O proprietário manifestou preocupação com o custo de complexidade documental, autorizando revisão estratégica **documental**, sem aprovação de D0/D1 como novo escopo canônico. Consolida A1 diagnóstico de ativos, A2 caminho mínimo, A3 escopo e critérios. Fonte: `STATE.md`, Fases 2–4, Documento 04, Documento 67, migrations 021–023 e 027, fixtures/testes F3-Monitor, `.github/workflows/validate-s5.yml`, catálogo e manifesto de 36 migrações. Freshness Gate inicial: CP208 `be0ada96f3304561089d617c3eb468de065e5337` idêntico a `main`. Evidência histórica de testes não equivale a reexecução atual.

## 2. Diagnóstico da proporcionalidade
As Fases 2 (baseline arquitetural) e 3 (nove produtos formalizados) possuem documentação de implementação e validações históricas. Ficha N2 dCBT-I e Resposta N1 publicadas com garantia A2, **sem revisão científica independente**; N0 interno A1 não publicável. Monitor M2 dispõe de contrato 021, hardening 022, projeções 023, fixtures e testes de CI históricos; M3 e operação factual contínua não demonstradas/autorizadas. Exigir homologação integral da infraestrutura institucional para *mostrar* resultados anteriores é desproporcional; não se permite inferir ambiente integrado em funcionamento, nem prontidão operacional.

## 3. Três escopos distintos (não selecionados)
| Escopo proposto | Objetivo | Limite |
|---|---|---|
| **D0 — demonstração documental** | expor um produto científico existente, proveniência, limites de garantia, resultados históricos e lógica do Monitor | nenhuma operação, consulta nova, afirmação de revisão científica ou integração factual |
| **D1 — protótipo sintético executável** | exibir alvo sintético, Monitor M2, mudança simulada, avaliação, visualização e histórico | autorização de execução separada; sandbox descartável; sem alteração de conclusões científicas nem consultas factuais |
| **D2 — piloto factual** | consultar fontes públicas e observar atualizações reais | fora do escopo atual, condicionado a governança/autorizações próprias |

**Prioridade candidata:** D0 → D1 → D2, ainda sujeita à aprovação explícita do proprietário. D0 preparável documentalmente dentro da autorização vigente; D1 e D2 NÃO AUTORIZADOS.

## 4. Reutilização e dependências
- N2 dCBT-I: Documento 67 (`A2`, aprovação de governança do proprietário, expert review ausente); validação histórica não atesta acerto científico por terceiro.
- Monitor M2: `database/021_evidence_monitor_contract.sql`, `022_evidence_monitor_projection_hardening.sql`, `023_evidence_monitor_view_rendering_readiness.sql`; `database/f3-evidence-monitor-fixtures.sql`, `f3-evidence-monitor-tests-a.sql`, `-b.sql`, `f3-evidence-monitor-view-tests.sql` e workflow `validate-s5.yml`.
- 021 pressupõe baseline e migrações anteriores; 023 depende até 022. Recorte candidato **até 023**, NÃO é ordem de implantação aprovada; requer auditoria estática de dependências transitivas, hashes, política de migrations, controles aplicáveis e autorização antes de qualquer execução. 024–036 não demonstradas como requisito da projeção 023, mas ausência de dependência declarada não prova ausência de dependência funcional.
- O fixture M2 sintético do Monitor não é o mesmo produto real dCBT-I. Uma apresentação integrada entre ambos é **objetivo não verificado**, não capacidade atual.

## 5. Fluxo de demonstração D1 proposto
Produto-alvo **sintético** identificável → ciclo M2 → evento/novo candidato sintético → registro de avaliação e impacto → visualização `product.evidence_monitor_view` → histórico auditável, sem atualização automática da conclusão científica. Não simular busca factual de PubMed/ClinicalTrials, aprovação científica, publicação ou M3.

## 6. Critérios propostos para D1
| Critério | Verificação futura |
|---|---|
| S1 | identidades de produto/Monitor preservadas |
| S2 | dados explicitamente sintéticos, origem rastreável |
| S3 | evento/candidato simulado detectado e registrado |
| S4 | avaliação registrada sem alterar silenciosamente conclusão científica |
| S5 | projeção do Monitor fiel ao histórico |
| S6 | logs, isolamento, descarte e reprodução verificados |
Critérios de demonstração, NÃO gates de promoção e NÃO autorização de SQL.

## 7. Controles por proporcionalidade (recomendação, não dispensa)
**Essenciais para D0/D1 no escopo pertinente:** proveniência, identidade, integridade dos objetos efetivamente usados, distinção sintético/factual, conclusão científica intocada, rastreabilidade, testes/limpeza no D1, limitações de garantia. **Candidatos a diferimento no escopo da demonstração:** ativação epochs 033–036, M3, SLA/cadência normativa, multiusuário/HA, monitoramento contínuo, novas consultas e reconciliação de migrações fora da cadeia efetivamente proposta. 36 entradas permanecem `UNREVIEWED`, 0 pós-condições aprovadas, 36 requisitos 034–036 `NOT_COLLECTED` e 12 controles de roles pendentes; a classificação **não muda** seus estados nem BRG.

## 8. Riscos, decisão e restrições
Riscos: fixture insuficiente para S1–S6; dependências transitivas; inadequação de saída para pesquisador; interpretação indevida de A2 como peer review; confusão de demonstração com operação factual; permissões e custos. Exige-se: (a) aprovação explícita da mudança de prioridade para D0/D1, (b) análise documental das dependências do recorte, (c) autorização operacional específica antes de CI/SQL/Neon/execução, (d) parecer científico independente para reivindicações de validação especializada. Nenhuma etapa automaticamente concedida.

## 9. Estado e próximo ato
`PREPARE_G1_DOCUMENTARY_ONLY`, BRG-03/06/07/08 BLOCKED, BRG-04/05 históricos, BRG-09 parcial; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado; Fase 4 NOT_READY e Fase 5 NOT_STARTED. Sem execuções nem serviços pagos.

**Próximo Prossiga — novo bloco A1:** formular decisão de prioridade em linguagem objetiva para aprovação do proprietário, distinguindo aprovação de preparar D0/D1 de qualquer autorização de executar D1; sem executar nem presumir consentimento. Modo médio; alto antes de alteração arquitetural material. STOP.
