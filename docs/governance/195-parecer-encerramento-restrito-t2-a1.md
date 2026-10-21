# Documento 195 — D1-T2/A1: parecer consolidado e proposta de encerramento técnico restrito

**OES | 2026-10-21 | PARECER PARA DECISÃO — NÃO É APROVAÇÃO**

## 1. Autoridade e evidências

Autorização vigente: `APPROVED — OES / D1-T2-A1 / PYTHON_IN_MEMORY_REPOSITORY_BOUNDARY_ONLY`, formalizada no Documento 192. A documentação científica e técnica aplicável inclui Documentos 173, 189–190, 193–194 e CP220. HEAD de referência verificado antes desta avaliação: `1a9111a0b253991e6da2af9585861634d0ca85dd`.

T1 foi encerrado previamente, somente como protótipo sintético local. Os seus 36 testes e o arquivo `prototypes/d1/monitor.py` foram preservados. T2-A1 permanece autorizado apenas para a fronteira Python de repositório/Unit of Work com adaptador em memória, diretório experimental e versionamento GitHub sujeito ao Freshness Gate.

**Resultado histórico da última execução local reportada:** 39 testes T2-A1 + 36 T1 = **75/75 PASS**. Esta avaliação é documental e **não reexecutou as suítes no presente HEAD**; não confundir a evidência histórica com verificação independente de nova execução.

## 2. Entregas existentes

- `prototypes/d1_t2/a1/repository.py`: interface `ScenarioRepository`, repositório em memória, `MemoryUnitOfWork`, cópias defensivas, revisões e armazenamento lógico conjunto de estado, evento e recibo.
- `bridge.py`: cinco comandos `create_scenario`, `start_cycle`, `register_signal`, `record_assessment` e `close_cycle`; snapshots sintéticos e replay de eventos em memória.
- `t1_monitor_reference.py`: cópia da baseline T1, cujo alinhamento é verificado por teste automatizado de comparação de bytes.
- `test_repository.py`, `test_bridge.py`, `test_replay_atomicity.py`, `test_adversarial_cycles.py` e `test_reference_contract.py`: paridade, integrações, idempotência, exclusões, isolamento, falhas injetadas, ciclos sucessivos, replay e integridade.
- `README.md`: comandos para reprodução local e limitações explícitas.

## 3. Rastreabilidade S1–S6 — conclusão delimitada

| Critério | Conclusão sobre T2-A1 |
|---|---|
| S1 Identidades | Evidência de cenário/Monitor/target e vínculos/ciclos sintéticos, sem chaves/FKs reais |
| S2 Proveniência | Fixtures obrigatoriamente rotuladas `synthetic:`; sem validação factual |
| S3 Idempotência e eventos | Recibos e sequência em memória, conflitos verificados, sem recuperação durável |
| S4 Avaliação e decisão | Impactos múltiplos, `pending` original e conclusão científica sintética preservados |
| S5 Snapshot | Quatro status distintos, baseline/cutoffs e disclosure; não é View SQL canônica |
| S6 Replay e isolamento | Reconstrução e detecção de algumas adulterações, isolamento intraprocesso; sem garantia de descarte seguro ou imutabilidade criptográfica |

**Parecer técnico:** `T2_A1_READY_FOR_RESTRICTED_OWNER_CLOSURE_DECISION`. Objetivo experimental autorizado demonstrado nos cenários testados; não há fundamentação para exigir funcionalidade PostgreSQL, implantação ou produção como pré-requisito para encerrar **esta** subetapa. Não declarar `CLOSED` antes de decisão expressa.

## 4. Limitações e riscos aceitos somente se a decisão os mencionar

1. `RLock` e estado são do processo Python: não há persistência durável, concorrência interprocessos ou transação SQL.
2. A falha injetada antes da publicação do commit não comprova recuperação após erro no interior da efetivação nem resultado de commit incerto.
3. O replay lê registros apenas em memória; não demonstra recuperação após reinício, segurança de eventos contra adulteração coordenada ou trilha de auditoria de produção.
4. `t1_monitor_reference.py` é duplicação controlada pela verificação de integridade, não substituição definitiva da origem T1.
5. `RepositoryConflict` e `DomainError` diferem em certos conflitos; a distinção foi documentada e testada, sem normalização de interface pública.
6. Criação repetida devolve snapshot corrente e `pending` não permite segunda avaliação do mesmo sinal, exatamente como no T1. Corrigir essas semânticas depende de aprovação independente.
7. S1–S6 são observações sintéticas locais, não validação científica, operacional, de segurança, dados reais, gates, migrações ou `oes.evidence_monitor_view/0.1`.

## 5. Texto sugerido para deliberação — NÃO APROVADO

`APPROVED — OES / D1-T2-A1 / SYNTHETIC_IN_MEMORY_TECHNICAL_CLOSURE / Aprovar exclusivamente o encerramento técnico restrito de T2-A1, como fronteira experimental de repositório e Unit of Work em Python local e memória, com cinco comandos integrados, 75 testes locais historicamente PASS incluindo os 36 testes T1 e rastreabilidade S1–S6 delimitada; preservar T1, limitações, diferenças de exceções, semântica atual e gates; não autorizar T2-A2, SQL, PostgreSQL, Neon, drivers de banco, CI remota, nuvem, implantação, API pública, buscas factuais, dados reais, serviços pagos ou promoção científica/operacional.`

Esta minuta é **proposta**, não aprovação. O usuário poderá aprovar, rejeitar ou solicitar refinamento. Se aprovada, registrar decisão em documento próprio e atualizar checkpoint sem inferir autorização de T2-A2.

## 6. Situação e próximo passo

`T1=CLOSED_SYNTHETIC_LOCAL_ONLY`; `T2-A1=READY_FOR_RESTRICTED_OWNER_CLOSURE_DECISION / NOT_CLOSED`; `T2-A2=NOT_AUTHORIZED`. CP220 permanece vigente. D0 documental encerrado; D1 prioritário; D2 factual e governança operacional completa posteriores. Todas as migrations, gates e pendências institucionais permanecem sem promoção.

**STOP — aguardar deliberação expressa sobre encerramento restrito T2-A1.**
