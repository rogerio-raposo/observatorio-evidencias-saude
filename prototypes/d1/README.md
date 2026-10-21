# OES D1-T1 — núcleo Python M2 exclusivamente sintético

Protótipo de aplicação em Python puro e biblioteca padrão, sem dependências de terceiros, banco, rede, CI, serviço pago ou integração científica factual.

## Testes

`python -m unittest discover -s . -p 'test_*.py' -v`

## Escopo implementado

Criação idempotente de cenário, identidade do produto/Monitor, ciclos M2 e janelas temporais, sinais fictícios de `search_hit`/`evidence_event`, avaliação explícita com múltiplos impactos, decisão de manutenção, `target_currency` independente da conclusão científica, snapshot `oes.d1.monitor_snapshot/0.1`, visualização textual demonstrativa, event log sequencial e reconstrução determinística com detecção de divergências.

Testes locais da revisão: **21 testes passando**. Os arquivos do pacote foram executados localmente; nenhuma execução remota foi acionada.

## Limites

- Não é implementação de `product.evidence_monitor_view/0.1`; não demonstra equivalência ao SQL 021–023 nem aprovação de gates.
- Não realiza revisão por IA/humano, busca PubMed/ClinicalTrials, asseguramento A2 ou publicação.
- Persistência somente em memória, sem armazenamento durável, transação entre processos, recuperação após encerramento ou controle de concorrência; acesso direto a `repo.scenarios` é interface interna não protegida.
- `scenario_actor` identifica somente personagem da fixture. Os rótulos `python_service` identificam execução do serviço Python local, não execução científica.
- Renderizador simples, distinto do template canônico. Mapeamento editorial abrangente, testes diferenciais e controle de acesso em ambiente web permanecem pendentes.
- Critérios S1–S6 parcialmente cobertos. Não declarar T1 plenamente concluído.

## Composição

`monitor.py` — núcleo e apresentação sintética. `test_monitor.py` — unittest local.

O repositório principal permanece fonte de verdade dos contratos OES; este diretório não altera as migrations, a taxonomia, os gates ou os documentos históricos.

## Endurecimento local posterior ao primeiro upload

Correção do fechamento de ciclo: verificar a integridade da conclusão científica **antes** de qualquer mutação. Novo teste adversarial de rejeição atômica em caso de adulteração interna. Nenhuma nova integração ou dependência.

## Controles de proveniência do cenário

A origem obrigatória de um cenário deve usar o prefixo `synthetic:` e o identificador da versão do produto-alvo não pode ser idêntico ao identificador da versão do Monitor. Entradas incompatíveis são rejeitadas antes de criar estado ou recibos; dois novos testes adversariais verificam ambos os casos.

## Falhas injetadas e rollback T1 em memória

Os comandos agora restauram o estado do cenário se uma exceção ocorrer após uma mutação e antes da conclusão do registro de evento. Cinco testes de falha injetada validam criação, início, sinal, avaliação e fechamento, incluindo ausência de recibo e replay sem divergência. Essa garantia limita-se ao fluxo sequencial em memória: **não há atomicidade transacional entre processos, isolamento de concorrência nem persistência durável**.

## Projeção demonstrativa fiel ao escopo

O renderer exibe separadamente estado editorial e operacional do Monitor, currency do Monitor e do alvo, proveniência fictícia, janelas/cutoffs sintéticos, impactos múltiplos, decisões e histórico. O baseline científico do Monitor **não é registrado** no contrato atual: a apresentação declara essa ausência sem fabricar dado. Divulgação de busca factual, revisão científica ou View SQL executadas é rejeitada pelo renderer. Três novos testes de apresentação; não há equivalência à View SQL canônica.

## Baseline sintético explícito (incremento T1)

A criação do cenário exige `baseline_evidence_cutoff_date` ISO válido e imutável, declarado como conteúdo sintético e armazenado no evento de criação; as janelas dos ciclos devem começar depois do cutoff inicial. O snapshot e o renderer apresentam separadamente o baseline e os cutoffs dos ciclos. Não houve consulta real a fontes científicas.
