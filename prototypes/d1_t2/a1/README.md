# OES D1-T2/A1 — Ponte experimental de comandos sintéticos

Incremento experimental publicado em `prototypes/d1_t2/a1/`. `bridge.py` integra `create_scenario`, `start_cycle`, `register_signal`, `record_assessment` e `close_cycle` à `MemoryUnitOfWork` em memória. A ponte possui testes de replay, falha injetada antes do commit lógico, dois ciclos, eventos e recibos. Isso não atesta durabilidade ou falhas durante publicação interna do commit.

`repository.py` é a versão T2-A1 publicada anteriormente. `t1_monitor_reference.py` é cópia exata do núcleo T1 para validação isolada; a fonte canônica do T1 permanece em `prototypes/d1/monitor.py` e não foi modificada. Na integração futura, resolver a referência canônica sem manter implementações divergentes.

Executar em `prototypes/d1_t2/a1/`: `python -m unittest discover -s . -p 'test_*.py' -q` (39 testes). Executar em `prototypes/d1/`: o mesmo comando (36 testes). Última validação local conjunta: **75/75 PASS** (39+36), com os módulos posicionados na estrutura de diretórios do repositório. `test_reference_contract.py` exige o T1 original acessível em `prototypes/d1/monitor.py`; falha explicitamente se não estiver presente.

Preserva a resposta histórica da criação repetida (snapshot atual); os outros recibos preservam a resposta original. Conflitos da UoW podem lançar `RepositoryConflict`, enquanto o T1 usa `DomainError` para alguns conflitos equivalentes; essa diferença de classe de exceção é intencionalmente registrada nos testes de compatibilidade, sem modificação silenciosa. `pending` mantém a impossibilidade histórica de reavaliação do mesmo sinal. Sem PostgreSQL, SQL, Neon, CI, nuvem, rede, dados factuais ou serviços pagos. O lock é somente intraprocesso, não transação durável.
