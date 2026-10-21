# Documento 171 — D1-T1: cobertura S1–S6 e critérios de encerramento (CP216)

**OES · 2026-10-21 · Avaliação documental do primeiro núcleo Python sintético · estado: T1 EM DESENVOLVIMENTO**

## 1. Autoridade e escopo

O proprietário concedeu autorização expressa: `APPROVED — OES / D1-T1 / PYTHON_SYNTHETIC_DOMAIN_ONLY / Implementar e testar localmente os serviços Python e a apresentação demonstrativa sintética, com persistência em memória e versionamento no GitHub; sem SQL, Neon, CI remota, implantação cloud, API pública, consultas factuais, serviços pagos, migrações ou alteração de gates.`

Documento 170 (CP215) permanece a especificação técnica preparatória; sua frase histórica «implementação não autorizada» retrata a data de elaboração e **não** revoga a aprovação posterior do proprietário. Este Documento 171 registra aquela autorização e o estado implementado, **não** concede novas permissões.

Fonte auditada: `prototypes/d1/monitor.py`, `test_monitor.py`, `README.md`, HEAD `c4c1e4aaaa2b00d3394e98f0e66148e891a93d1d`. Não houve execução local ou remota de testes durante a elaboração do CP216; **13/13 PASS** é resultado histórico reportado nas atividades T1 anteriores, não nova execução desta análise.

## 2. Entregas verificadas

- Implementação Python padrão, em memória: `SyntheticMonitorService` e `InMemoryRepository`.
- `create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`, `snapshot` e `replay_snapshot`.
- Contrato próprio `oes.d1.monitor_snapshot/0.1` e `render_demo` textual; declaração explícita `synthetic=true` e de operações não executadas.
- Idempotência por `request_id`, sequência de eventos, validação básica de janelas temporais, enumerações de impacto, decisão explícita, hash de conclusão científica, proteção de fechamento ante adulteração detectável.
- Proteção adicional contra origem de fixture sem `synthetic:` e coincidência de identificadores de versão do Monitor/alvo.
- Commits T1 observados no histórico da conversa, culminando no HEAD acima; publicação e hashes dos arquivos já conferidos no GitHub.

## 3. Matriz de avaliação documental S1–S6

| Critério | Evidência existente no código/testes | Lacuna para aceitação T1 | Classificação |
|---|---|---|---|
| S1 Identidade | versões de Monitor e alvo obrigatórias/distintas; `cycle_no` sequencial | tipagem/forma de IDs e vínculos de alvo em eventos; testes de conflitos entre cenários | **PARCIAL** |
| S2 Proveniência | `fixture_source` e `source` exigem `synthetic:`; sinalização `synthetic`, `scenario_actor` e `execution_disclosure` | `synthetic:` é declaração textual, não autenticação; caracterização dos atores e contenção de payloads arbitrários; teste de falsificação | **PARCIAL** |
| S3 Eventos | `search_hit`/`evidence_event`, idempotência, event log e impedimento de mutação normal após fechar | integridade de `request_id` contra casos patológicos, referência/duplicidade entre ciclos e atomicidade sob exceções | **PARCIAL** |
| S4 Avaliação | `retained_for_impact` com impactos canônicos múltiplos, rationale/ator, decisão e currency separadas; hash da conclusão preservado e teste de adulteração | testes negativos para todos os estados e transições; regra de ciclo completo e separação entre ato fictício e verificação real | **PARCIAL** |
| S5 Projeção | snapshot sintético próprio, renderer textual, quatro estados presentes no JSON, testes de campos importantes | cobertura explícita das quatro dimensões no renderer, cutoffs/baseline, fidelidade de todos os campos, não equivalência à View SQL | **PARCIAL** |
| S6 Auditoria | sequência e `replay_snapshot` verificam divergência em casos positivos e negativos; dados em memória | replay adversarial extensivo; isolamento, descarte e ausência de efeitos externos verificados por testes; ausência de garantia para concorrência | **PARCIAL** |

A frase «teste passou» vale apenas para o respectivo caso de teste; não estende a garantia a todos os invariantes SQL 021–023 nem aos gates científicos.

## 4. Riscos específicos identificados para próximas atividades

1. **Mutabilidade interna:** `repo.scenarios` é um `dict` público, sem barreira para adulteração por código interno; o hash identifica apenas uma classe dessas alterações. Tratar como risco demonstrativo, não segurança de produção.
2. **Atomicidade parcial:** a correção de `close_cycle` passou a verificar conclusão antes da mutação; outras rotas requerem revisão *fail-before-mutate* e testes de rollback lógico.
3. **Fidelidade semântica:** o snapshot não é `product.evidence_monitor_view/0.1`; estados de currency e publicação não equivalem a gatilhos SQL, revisão real ou A2.
4. **Cobertura histórica do Monitor:** renderizador exibe alguns estados, mas precisa explicitar baseline e cutoffs, a distinção de quatro status, avaliações e fontes para apresentação fiel.
5. **Execução isolada:** os testes locais são indício positivo, mas não demonstram concorrência ou integridade multiusuário. T1 não deve prometer isso.
6. **Artefato histórico S5:** evidência do run `37558043092`, artifact `11455658237`, expiração prevista `2026-11-06T01:38:17Z`. ZIP não foi preservado/inspecionado no presente ciclo documental; tratar como tarefa independente e não reinterpretar metadados como execução.

## 5. Critérios objetivos de encerramento de T1, ainda NÃO satisfeitos

A. Todos os testes do protótipo executados localmente, com resultado/HEAD e comando documentados; sem CI remota.

B. S1–S6 com casos positivos e adversariais identificáveis, evidência de teste específica por critério, e cobertura explícita de idempotência, imutabilidade, datas, fechamento e replay.

C. Garantir rejeição de operações inválidas **sem mutações parciais** no estado/recibos em todas as rotas testadas.

D. Snapshot/renderização sintéticos completos para o caso M2 delimitado: identidades; origem/ator da fixture; quatro status distintos; baseline versus cutoff de ciclo; impactos multivalorados; decisão; trilha cronológica; disclosure de não execução SQL, busca e revisão científica.

E. Isolamento/limpeza determinísticos de `InMemoryRepository` demonstrados por testes; ausência de dependências de rede/serviços na execução do pacote.

F. Fonte versionada no GitHub, integridade dos arquivos e instruções reprodutíveis; avaliação final sem reivindicar equivalência SQL ou aprovação científica, sem passar automaticamente a T2.

**Resultado de CP216: T1_PARTIAL / NOT_CLOSED.**

## 6. Estado de governança preservado

D0 encerrado no âmbito documental; D1 prioritário; D2 factual e governança operacional completa posteriores. 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles pendentes; BRG-03/06/07/08 BLOCKED, BRG-04/05 históricos, BRG-09 parcial, B1R1 EXPIRED_NOT_EXECUTED, M3 bloqueado; Fase 4 NOT_READY e Fase 5 NOT_STARTED.

Nenhum PostgreSQL, Neon, SQL, CI remota, API pública, implantação cloud, consulta factual, cobrança ou alteração de gates decorrente deste checkpoint.

## 7. Próxima atividade estritamente delimitada

**Sob novo `Prossiga`:** T1 — testes e correção local de atomicidade/imutabilidade dos comandos, exclusivamente Python e memória. Conferir Freshness Gate e preservar escopo autorizado, uma atividade por `Prossiga`. Não iniciar T2 nem ações de cloud/CI. STOP.
