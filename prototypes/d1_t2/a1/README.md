# OES D1-T2/A1 — Fronteira experimental Python em memória

Primeiro incremento autorizado de T2-A1, **sem banco, driver, SQL, Neon, CI, cloud, rede ou serviços pagos**. Código independente em `prototypes/d1_t2/a1/`; o T1 em `prototypes/d1/` permanece inalterado. Esta fronteira ainda não foi integrada ao serviço de domínio T1.

O contrato experimental define `ScenarioRepository` e `MemoryUnitOfWork`, com estado, um evento e recibo confirmados juntos por atribuição de registro em memória sob `RLock`. Retornos são cópias defensivas. Não há persistência durável, concorrência multiprocesso, isolamento SQL nem interface pública.

Testes locais: `python -m unittest discover -s . -p 'test_*.py' -v`. Rodar separadamente a regressão T1 em `prototypes/d1/`. O comportamento T1 de repetição da criação (snapshot corrente) e `pending` não foi modificado; o adaptador ainda não possui comandos de domínio. Qualquer mudança dessas semânticas exige decisão específica.

**Próximo incremento somente sob `Prossiga`:** adaptar, de modo incremental, os comandos sintéticos à fronteira em memória e verificar paridade contra T1, sem modificar arquivos T1 e sem ativar T2-A2.
