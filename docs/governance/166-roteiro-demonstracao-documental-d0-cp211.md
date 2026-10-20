# 166 — Roteiro utilizável da demonstração documental D0 (CP211)

**OES | 2026-10-20 | prioridade D0 aprovada no Documento 165 | status ROTEIRO DOCUMENTAL, NÃO EXECUÇÃO**
**Escopo:** apresentação baseada em materiais já registrados, sem acesso novo a bases científicas, sem execução de código/CI/SQL/Neon e sem validação especializada independente.

## Objetivo e público
Apresentar a pesquisadores em cinco quadros o problema atendido, um produto científico documentado, as garantias de rastreabilidade, o Monitor M2 com dados sintéticos e o estado real de maturidade do OES. Não apresentar interfaces ou operação factual como existentes sem evidência. A Fase 4 permanece NOT_READY.

## Quadro 1 — O problema e a proposta (1 minuto sugerido, não obrigatório)
**Mensagem:** pesquisas relevantes evoluem, e conclusões devem manter vínculo com fontes, versões e avaliações. O OES busca identificar, organizar, avaliar, sintetizar e acompanhar evidências de modo transparente.
**Mostrar:** pergunta científica → recuperação/seleção → avaliação → síntese → produto → possibilidade de manutenção.
**Ressalva:** a existência da arquitetura não implica automação factual contínua.

## Quadro 2 — Exemplo real: Ficha de Evidência N2 (3 minutos)
**Produto:** `OES-P-2026-000401`; tema: dCBT-I totalmente automatizada versus educação digital sobre sono/higiene do sono em adultos com insônia.
**Pergunta:** reduz gravidade da insônia ao final do tratamento?
**Resultado registrado no Documento 67:** evidência provavelmente favorável à redução da gravidade; direção consistente, magnitude variável.
**Resultado de referência de publicação externa, NÃO recalculado pelo OES:** Hwang et al. 2025, subgrupo específico `k=10`, SMD −0,93 (IC95% −1,07 a −0,79), I² 68%, registrado no Documento 52.
**Atualização narrativa registrada:** Sweetman 2024, SleepioRx 2025, SHUTi OASIS 2025, Somzz 2024; triangulação Gao 2026. Não misturar métricas distintas, não atribuir pooling novo ao OES.
**GRADE OES:** certeza moderada para o desfecho principal, julgamento provisório metodológico assistido por IA, sem revisão científica independente (Documento 53). Não generalizar a segurança ou efeitos em outros desfechos.
**Corte:** 2026-10-04. **Assurance:** A2, aprovação de governança do proprietário; published no contrato OES. **Expert review:** ausente. A2 NÃO significa peer review/A3. Sem recomendação clínica individual.
**Tela/slide sugerido:** pergunta, conclusão cautelosa, certeza provisória, estimativa-base atribuída, cutoff e disclosure visível.

## Quadro 3 — Rastreabilidade e níveis de leitura (2 minutos)
**Visão executiva:** pergunta, desfecho, conclusão, incerteza e cutoff.
**Fundamentação:** síntese publicada adotada criticamente, RCTs de atualização narrativa, ROBIS/RoB 2, GRADE e limitações.
**Auditoria:** ID do produto, Documentos 52–54 e 67, workflow histórico `OES PoC-S5 PostgreSQL Validation`, run `37229070210` PASS no commit `9c0257172ad916a13cbb66648bb68621c8b21b1f`, artifact `11313491459` e digest registrados no Documento 67.
**Distinguir estados:** Documento 54 é draft A1/under_review histórico; Documento 67 registra a posterior publicação A2. Resultado de CI histórico não é reexecução presente nem auditoria científica independente.

## Quadro 4 — Monitor M2, EXCLUSIVAMENTE exemplo sintético (3 minutos)
**Não se trata de monitoramento real da Ficha dCBT-I acima.** As fixtures do Monitor usam produto-alvo sintético distinto.
Mostrar sequência conceitual fiel às estruturas de `database/021_evidence_monitor_contract.sql`:
1. Produto-alvo sintético e definição do Monitor (versão, escopo e fontes declaradas).
2. Ciclo `maintenance.monitor_cycle` e suas buscas `maintenance.cycle_search`.
3. Eventos em `maintenance.evidence_event` e candidatos/avaliações `maintenance.candidate_assessment`.
4. Avaliação do estado do alvo e histórico em `maintenance.cycle_currency_state`, sem modificar silenciosamente conclusão científica.
5. Projeção `product.evidence_monitor_view` da migration 023 para apresentar resultados.
**Exemplos de testes presentes no código:** MON-T02/03/04/05/06 (separação de assurance, cutoff, currency e buscas); MONV-T08/09/10 (impactos, evento versus avaliação, histórico); MONV-T14 (verificação por IA não equivale a verificação humana); MONV-T15/17 (determinismo e projeção read-only). Os testes históricos estão documentados no STATE; não foram reexecutados nesta atividade.
**Quadros para apresentação:** (i) alvo e plano, (ii) ocorrência sintética, (iii) avaliação, (iv) estado/histórico. Não inventar valores/prints nem afirmar ligação com dCBT-I.

## Quadro 5 — O que existe, o que falta e colaboração desejada (2 minutos)
**Registrado:** Fase 2 baseline arquitetural validada; Fase 3 nove produtos formalizados; casos N1/N2 A2 com ausência de revisão especializada; Monitor M2 com contrato, fixtures, testes e projeção documentados.
**Ainda não demonstrado/autorizado:** monitoramento factual contínuo de PubMed/ClinicalTrials.gov; piloto D2; D1 sintético executável autorizado; implantação integrada pública; revisão independente de julgamentos científicos; M3 e Fase 4 pronta.
**Colaboração científica futura:** revisar definições da pergunta, métodos de busca, appraisal, GRADE, aplicabilidade e critérios de impacto/atualização antes de reivindicações científicas mais fortes. Não insinuar que revisores já foram selecionados.

## Roteiro de fala curta (adaptável)
“O projeto produziu uma Ficha de Evidência rastreável sobre dCBT-I, com síntese crítica e declaração explícita de incertezas. Seu resultado foi publicado internamente sob aprovação de governança A2, sem revisão científica independente. Em paralelo, implementamos e testamos historicamente um Monitor em cenários sintéticos, capaz de representar ciclos, eventos e avaliações. O próximo desafio é validar esses resultados com especialistas e demonstrar com segurança o fluxo integrado antes de passar a acompanhamento factual contínuo.”

## Evidências canônicas mínimas
- `docs/products/52-caso-real-01-sintese-atualizada.md`: base quantitativa atribuída e atualização narrativa.
- `docs/products/53-caso-real-01-grade-gravidade-insomnia.md`: certainty provisória, riscos e ressalvas.
- `docs/products/54-caso-real-01-draft-ficha.md`: draft histórico; não apresentar como estado final.
- `docs/products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md`: validação de preview histórico.
- `docs/products/67-caso-real-01-resultado-validacao-a2-publicacao.md`: estado A2 final e registro da CI.
- `database/f3-evidence-monitor-fixtures.sql`, `database/f3-evidence-monitor-tests-a.sql`, `database/f3-evidence-monitor-tests-b.sql`, `database/f3-evidence-monitor-view-tests.sql`, `database/021_evidence_monitor_contract.sql`, `database/023_evidence_monitor_view_rendering_readiness.sql`: cenário e capacidade sintética.
- `docs/governance/165-decisao-prioridade-d0-d1-cp210.md`: autoridade documental vigente.

## Checklist não normativo da apresentação
D0-01 pergunta/finalidade; D0-02 produto documentado; D0-03 proveniência; D0-04 Monitor sintético versus fato; D0-05 A2 e revisão independente ausente; D0-06 limites e próximos passos. Este checklist não cria gate nem dispensa controle existente.

## Próxima atividade e limites
**Após CP211, nova A1:** avaliar suficiência e clareza do roteiro D0 para um pesquisador não envolvido, corrigindo apenas apresentação documental, sem criar dados, simular parecer ou produzir artefato operacional. D1 permanece apenas preparação documental; D2 diferido. `PREPARE_G1_DOCUMENTARY_ONLY`; BRG-03/06/07/08 BLOCKED, 04/05 históricos, 09 parcial; 36 UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 roles pendentes; B1R1 EXPIRED_NOT_EXECUTED, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED. STOP.
