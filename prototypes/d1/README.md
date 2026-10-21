# OES D1-T1 — núcleo Python M2 exclusivamente sintético

Protótipo de aplicação em Python puro e biblioteca padrão, sem dependências de terceiros, banco, rede, CI, serviço pago ou integração científica factual.

## Testes

`python -m unittest discover -s . -p 'test_*.py' -v`

## Escopo implementado

Criação idempotente de cenário, identidade do produto/Monitor, ciclos M2 e janelas temporais, sinais fictícios de `search_hit`/`evidence_event`, avaliação explícita com múltiplos impactos, decisão de manutenção, `target_currency` independente da conclusão científica, snapshot `oes.d1.monitor_snapshot/0.1`, visualização textual demonstrativa, event log sequencial e reconstrução determinística com detecção de divergências.

Testes locais da revisão: **13 testes passando**. Os arquivos do pacote foram executados localmente; nenhuma execução remota foi acionada.

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
