# Quadro 1 — Casos documentados: produto, resultado e limite (protótipo editorial)

**Estado:** PROTÓTIPO EDITORIAL PARA REVISÃO SEMÂNTICA — ainda não incorporado ao manuscrito nem aprovado cientificamente.
**Data de referência dos estados:** **20 de outubro de 2026**; retrato documental, sem inferência de atualização automática posterior.
**Manuscrito-base:** [OES — Fundamentos científicos, arquitetura metodológica e modelo de desenvolvimento](../oes-fundamentos-arquitetura-modelo-desenvolvimento.md), versão editorial **0.53**, §14.2.
**Inserção prevista:** logo após o parágrafo introdutório da §14.2, **antes dos relatos individuais**.
**Tipo:** tabela Markdown acessível, com cabeçalhos textuais e linhas não hierarquizadas; não converter em ranking, gráfico de desempenho ou imagem sem necessidade.
**Especificação:** [plano editorial visual](../oes-plano-editorial-visual-manuscrito.md). Estado: [STATE.md](../../../STATE.md), [CP213](../../../archive/handoffs/oes/OES_Continuidade_2026-10-20_CP213.md); política transversal [Documento 04](../../governance/04-governanca-garantia-revisao.md).

## Quadro proposto

| Objeto e tema | Uso ou resultado demonstrado | Estado/garantia documentado(a) | Limite científico e operacional |
|---|---|---|---|
| **N0 — Evidence Scan**: IA generativa e saúde mental | Exploração estruturada de fontes, controvérsias, lacunas aparentes e encaminhamento de perguntas para investigação posterior | **A1 interno**, `under_review`, não publicável; sem aprovação de governança do proprietário | Busca não exaustiva; seis sínteses usadas/contextualizadas não constituem seis evidências independentes de eficácia ou segurança; sem conclusão clínica formal |
| **N1 — Resposta de Evidência**: música gravada e ansiedade perioperatória | Síntese e resposta documentadas, com verificação adversarial e **publicação interna** | **A2**, publicado internamente; sem revisão especializada independente | Divergência de estimativas entre resumo e resultados de Stoop et al. (2026) identificada, mas origem estatística não esclarecida; não houve reanálise independente |
| **N2 — Ficha de Evidência**: dCBT-I para insônia | Ficha estruturada com pergunta, fontes e julgamentos; **publicação interna** após verificação assistida por IA e aprovação de governança | **A2**, publicado internamente; GRADE moderada **provisória** na interpretação OES; sem A3 | Meta-análise de Hwang et al. (2025) é **fonte externa**, não síntese quantitativa produzida pelo OES; certeza assistida por IA não equivale a revisão especializada |
| **N3 — Síntese Rápida**: IA para documentação clínica | Contratos e percurso experimental exercitados; verificações adversariais detectaram insuficiência de cobertura de busca | **A0 experimental**, encerrado com **bloqueio metodológico**; não publicável | Falha de cobertura bibliográfica impede síntese formal; testes técnicos `PASS` não superam o bloqueio nem conferem A3 |
| **N4 — Revisão de Evidências** | Especificação, contratos, template e cenários **sintéticos** tecnicamente exercitados; investigação real formal **não iniciada** | *Sem nível A atribuído a caso real não iniciado*; gate real `NOT_READY` | Fixture sintética A3 e simulações de revisores **não são** revisão científica humana independente nem execução de uma investigação N4 real |
| **MAP-01 — Mapa de Evidências**: corpus de IA para documentação clínica | Mapeamento exploratório com identidade própria e proveniência do corpus experimental N3 | **A1 interno**, sob revisão, **não publicável** | Itens do mapa misturam unidades; corpus herdado e classificações assistidas por IA não verificadas; lacunas apenas **aparentes**, não ausência comprovada de estudos |
| **OVR-01 — Overview de Revisões**: dCBT-I | Organização de três revisões externas e análise documental preparatória de sobreposição | **A1 interno**, sob revisão, **não publicável**; rota formal `NOT_READY` | 59 identidades candidatas de estudos não significam 59 estudos independentes confirmados; ROBIS/mapeamentos sem revisão humana independente; não houve nova metanálise OES |
| **Monitor de Evidências / Alerta de Evidência** | Contratos de monitoramento e alerta e cenários técnicos/sintéticos historicamente exercitados, inclusive em **M2** | **Testes técnicos/sintéticos**, sem classificação A de produto científico; **M3 bloqueado** | Não comprova vigilância factual persistente, coleta sustentada de fontes reais ou disponibilidade operacional; B1R1 = `EXPIRED_NOT_EXECUTED` |

## Legenda científica proposta

**Quadro 1 — Casos e percursos documentados no Observatório de Evidências em Saúde (OES) até 20 de outubro de 2026.** A tabela distingue produto ou percurso, uso demonstrado, estado/garantia quando aplicável e limite científico. As designações **A0–A3** qualificam processos de garantia de versões específicas; **M2–M3** designam regimes de manutenção e monitoramento, não graus de confiança científica. Publicação **interna** A2 não significa revisão especializada independente nem divulgação externa. Os casos apresentados não são comparáveis como medidas de eficácia, maturidade ou desempenho da plataforma. Fontes: `STATE.md`, CP213, Documento 04 e registros específicos dos produtos.

## Notas de interpretação obrigatórias

1. **Não há contagem agregada de produtos cientificamente validados.** Os oito registros são exemplos de *tipos diferentes de resultado*: produtos internos, investigação bloqueada, preparação técnica, derivação exploratória e testes sintéticos. Não representam oito avaliações independentes do mesmo desfecho.
2. **A2 não equivale a A3.** Os casos N1 e N2 possuem aprovação de governança e publicação interna, sem revisão metodológica especializada independente; as conclusões e julgamentos científicos não são certificados por essa aprovação.
3. **N2 e GRADE:** o julgamento OES de certeza moderada é assistido por IA e provisório. Hwang et al. (2025) é uma revisão/metanálise externa. Os estudos clínicos listados como contexto não demonstram busca, extração ou metanálise independente feita pelo OES.
4. **N1:** a discrepância de estimativas em Stoop et al. permanece de causa desconhecida. O ajuste documental de proveniência não reanalisa seus cálculos nem eleva o nível de garantia.
5. **N0, MAP-01 e OVR-01:** o mesmo estudo, relatório, síntese ou revisão pode aparecer em múltiplos conjuntos. Não somar seis sínteses do N0, dezessete itens do MAP-01 ou cinquenta e nove identidades candidatas do OVR-01 como ensaios primários independentes.
6. **N3:** a insuficiência de busca e o encerramento `A0` bloqueado têm precedência sobre testes técnicos satisfatórios. N3 formal exige as garantias especializadas aplicáveis.
7. **N4:** contrato, fixture e `PASS` técnico não constituem investigação real formal nem A3 efetivamente recebido por um produto real. Não atribuir A0, A1, A2 ou A3 a um caso factual inexistente.
8. **Monitor/Alerta:** M2 sintético é somente evidência de comportamento técnico histórico. M3 bloqueado; B1R1 `EXPIRED_NOT_EXECUTED` não demonstra que uma medição factual ocorreu. Não atribuir assurance A ao regime M.
9. **Risco e temporalidade:** nenhuma linha autoriza recomendações clínicas individuais, prontidão operacional, liberação de *gates* ou alegação de revisão independente. Manter estado de 20/10/2026, salvo atualização canônica explicitamente conferida antes da publicação.

## Rastreabilidade seletiva

- **N0:** [Documento 98 — encerramento A1](../../products/98-caso-real-n0-resultado-validacao-a1.md).
- **N1:** [Documento 78 — síntese e adendo de proveniência](../../products/78-caso-real-n1-musica-ansiedade-sintese.md); estado A2 no [STATE.md](../../../STATE.md).
- **N2:** ficha e assurance A2 registrados no [STATE.md](../../../STATE.md); ressalvas de certeza e fonte externa em [CP213](../../../archive/handoffs/oes/OES_Continuidade_2026-10-20_CP213.md).
- **N3:** [Documento 114 — encerramento experimental bloqueado](../../products/114-caso-real-n3-encerramento-experimental.md).
- **N4:** estado do gate formal e fixture sintética no [STATE.md](../../../STATE.md), seção N4.
- **MAP-01:** [Documento 137 — encerramento A1 interno](../../products/137-caso-real-map01-resultado-encerramento.md).
- **OVR-01:** [Documento 164 — encerramento developmental](../../products/164-caso-real-ovr01-resultado-encerramento.md).
- **Monitor/Alerta:** [STATE.md](../../../STATE.md) e [CP213](../../../archive/handoffs/oes/OES_Continuidade_2026-10-20_CP213.md).

## Checklist da próxima revisão semântica

- [ ] Confirmar, linha a linha, objeto, uso, garantia aplicável, status editorial e restrição científica nas fontes canônicas.
- [ ] Diferenciar publicação interna A2 de publicação externa, de A3 e de validade científica independente.
- [ ] Preservar N3 bloqueado e N4 factual não iniciado, sem fabricar assurance para N4.
- [ ] Confirmar MAP-01 como derivação de corpus não exaustivo e OVR-01 como overview developmental, sem metanálise original.
- [ ] Confirmar M2 sintético, M3 bloqueado e B1R1 `EXPIRED_NOT_EXECUTED`, sem representar vigilância factual contínua.
- [ ] Avaliar legibilidade editorial da tabela no manuscrito; preferir tabela Markdown acessível a SVG/imagem por ser conteúdo tabular.
- [ ] Integrar apenas após revisão, sem alterar indevidamente as sete figuras incorporadas e as 56 referências.

**Limite desta entrega:** quadro editorial em Markdown, sem integração ao manuscrito, PDF, SVG, alteração de `STATE.md`, handoffs, gates, banco, CI, consultas factuais ou serviços pagos.
