# Documento 228 — Encerramento restrito do demonstrador sintético D1 reescopado (CP253)

**OES | 2026-10-23 | APPROVED_D1_R3_RESCOPED_SYNTHETIC_DEMONSTRATOR_CLOSURE | DOCUMENTARY_ONLY**

## 1. Decisão expressa do proprietário

> APPROVED — OES / D1-R3 / CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY / Aprovar exclusivamente o encerramento do demonstrador sintético D1 reescopado, nos termos da minuta D1-R3, preservando os estados de T1 e T2-A1, os riscos diferidos, os limites de autorização e todos os gates científicos e operacionais.

**Decisão:** declarar **encerrado somente o demonstrador sintético D1 reescopado** no estado `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`. A decisão não equivale a encerrar todos os componentes do desenho originalmente previsto para D1 nem constitui homologação de produção ou validação científica.

A decisão aprovada complementa, sem revogar, o Documento 227/CP252, que diferiu persistência durável e desenvolvimento de A2-G4.

## 2. Fundamentação consolidada (D1-R1, D1-R2, D1-R3)

- **D1-R1 — inventário:** T1 e T2-A1 são entregas já encerradas em escopos restritos. Não foi demonstrada necessidade de PostgreSQL, Neon ou persistência durável para o primeiro demonstrador em memória. Lacunas de produção foram segregadas do escopo sintético.
- **D1-R2 — suficiência estática:** o núcleo `prototypes/d1/` e a ponte `prototypes/d1_t2/a1/` oferecem, no código publicado, `create_scenario`, `start_cycle`, `register_signal`, `record_assessment` e `close_cycle`, além de snapshot, replay, eventos, recibos, fronteira de repositório e Unit of Work em memória. Verificação **estática**; não foram executados testes novos.
- **D1-R3 — deliberação:** os critérios de escopo, comandos, rastreabilidade, evidência histórica e divulgação de limitações foram considerados suficientes para **decisão restrita**, com aprovação expressa do proprietário nesta conversa.

Referências técnicas e decisórias: Documento 173 (`CLOSED_SYNTHETIC_LOCAL_ONLY`, **36/36 PASS históricos**); Documento 196 (`CLOSED_SYNTHETIC_IN_MEMORY_ONLY`, **39 testes T2-A1 + 36 T1 = 75/75 PASS históricos**); `prototypes/d1/TRACEABILITY.md` (S1–S6 nos limites sintéticos); Documento 227 (reescopo e diferimento). Os testes PASS não foram reexecutados em D1-R1/R2/R3 nem neste registro.

## 3. Escopo efetivamente encerrado e limitações vinculantes

A aceitação cobre somente dados fictícios declarados como sintéticos, identidades de produto e Monitor, ciclos M2, sinais, avaliações, decisões, preservação da conclusão científica declarada, baseline/cutoffs sintéticos, quatro estados independentes, controles de idempotência, eventos, recibos, snapshot `oes.d1.monitor_snapshot/0.1`, replay e divulgação de atividades efetivamente executadas, nas condições aprovadas de execução **local, Python e memória**.

Continuam expressamente **não demonstrados**: persistência durável e recuperação após reinício; concorrência e isolamento entre processos; integridade transacional de banco, commit incerto e falhas de infraestrutura; autenticação e segurança de produção; equivalência à View SQL canônica `oes.evidence_monitor_view/0.1`; buscas científicas factuais, revisão de evidências, garantia científica/assurance, aprovação de publicação e prontidão operacional.

Permanecem aceitas **somente no escopo restrito** as diferenças documentadas entre `RepositoryConflict` e `DomainError`, a criação idempotente repetida que devolve snapshot corrente, a semântica `pending` sem reavaliação do mesmo sinal e a cópia T1 de referência em T2-A1. A última demanda racionalização **apenas em futura integração**, não uma alteração automática deste protótipo.

A inexistência de interface gráfica ou roteiro público próprio não bloqueia o encerramento técnico restrito; eventual comunicação a pesquisadores constitui objetivo separado.

## 4. Estados preservados e exclusões

| Objeto | Estado após decisão |
|---|---|
| **Demonstrador sintético D1 reescopado** | `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY` **(aprovado)** |
| D1-T1 | `CLOSED_SYNTHETIC_LOCAL_ONLY` (inalterado) |
| D1-T2-A1 | `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (inalterado) |
| D1 originalmente abrangente / futura integração | **Não homologados globalmente**; exigem decisões próprias |
| T2-A2/A2-G4 | `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED` |
| A2-G5 / runtime T2-A2 | `NOT_AUTHORIZED` |
| T3 nuvem / T4 equivalência OES-P1 | Diferidos, não autorizados |
| D2 factual | Diferido, condicionado a aprovação própria |
| Fase 4 / Fase 5 | `NOT_READY` / `NOT_STARTED` |
| 36 migrations | `UNREVIEWED` |

Riscos SA-05/06/07/08/10 continuam **abertos e diferidos**, não resolvidos; SA-02 condicionada, SA-03 parcial e SA-11/12 apenas mitigadas estaticamente. A futura escolha de stack deverá reavaliar os riscos aplicáveis sem reproduzir ciclos documentais redundantes.

Os seis arquivos A2 experimentais seguem **exclusivamente preservados e não validados** na branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, sem merge ou inclusão em `main`. A branch não deve ser alterada.

A decisão **não autoriza** testes/execução novos, código A2, SQL, PostgreSQL, Neon, drivers, CI remota, schema, migrações, grants, deploy, API pública, consultas factuais, dados reais, serviços pagos nem alteração de gates científicos ou operacionais.

## 5. Continuidade proporcional

D1-R1, R2 e R3 foram consolidadas neste único checkpoint **CP253**. Não há pendência obrigatória de desenvolvimento adicional dentro do demonstrador aprovado. A próxima atividade deverá ser uma **decisão separada de prioridade e escopo** para o marco seguinte (por exemplo, comunicação científica, preparação deliberativa de D2 ou arquitetura de integração), sem ativar automaticamente D2, persistência ou Fase 4.

**STOP — CP253 documental, decisão de encerramento restrito registrada; nenhuma execução técnica adicional.**
