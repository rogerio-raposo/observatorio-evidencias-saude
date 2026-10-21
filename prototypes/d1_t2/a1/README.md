# OES D1-T2/A1 — Ponte experimental de comandos sintéticos

Incremento experimental publicado em `prototypes/d1_t2/a1/`. `bridge.py` integra `create_scenario`, `start_cycle`, `register_signal`, `record_assessment` e `close_cycle` à `MemoryUnitOfWork` em memória. A ponte ainda precisa de provas de replay e de falhas no commit lógico.

`repository.py` é a versão T2-A1 publicada anteriormente. `t1_monitor_reference.py` é cópia exata do núcleo T1 para validação isolada; a fonte canônica do T1 permanece em `prototypes/d1/monitor.py` e não foi modificada. Na integração futura, resolver a referência canônica sem manter implementações divergentes.

Teste local: `python -m unittest discover -s . -p 'test_*.py' -q` (19 testes da ponte e 8 do repositório). Executar separadamente a suíte T1 (36 testes). Evidência histórica até CP220: 63/63 PASS, sem reteste no checkpoint documental.

Preserva a resposta histórica da criação repetida (snapshot atual); os outros recibos preservam a resposta original. Sem PostgreSQL, SQL, Neon, CI, nuvem, rede, dados factuais ou serviços pagos. O lock é somente intraprocesso, não transação durável.
