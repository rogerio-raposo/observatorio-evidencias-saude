# OES D1-T2/A1 — Ponte experimental de comandos sintéticos

Incremento experimental publicado em `prototypes/d1_t2/a1/`. `bridge.py` integra apenas `create_scenario` e `start_cycle` à `MemoryUnitOfWork` do primeiro incremento T2-A1. As demais operações permanecem fora desta ponte e não são declaradas integradas.

`repository.py` é a versão T2-A1 publicada anteriormente. `t1_monitor_reference.py` é cópia exata do núcleo T1 para validação isolada; a fonte canônica do T1 permanece em `prototypes/d1/monitor.py` e não foi modificada. Na integração futura, resolver a referência canônica sem manter implementações divergentes.

Teste local: `python -m unittest discover -s . -p 'test_bridge.py' -q` (8 testes). Executar também `test_repository.py` (8 testes) e a suíte T1 (36 testes) nos respectivos diretórios. Resultado histórico do incremento: 52/52 PASS no total das três suítes locais.

Preserva a resposta histórica da criação repetida (snapshot atual); os outros recibos preservam a resposta original. Sem PostgreSQL, SQL, Neon, CI, nuvem, rede, dados factuais ou serviços pagos. O lock é somente intraprocesso, não transação durável.
