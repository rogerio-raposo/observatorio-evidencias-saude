# Documento 191 — D1-T2/A1: solicitação de autorização para refatoração Python local

**OES | 2026-10-21 | PROPOSTA PARA DELIBERAÇÃO — NÃO APROVADA / NÃO EXECUTAR**

**Referências:** Documentos 169–170, 173, 189–190; CP218. HEAD examinado: `aca409bd620e67daafaf9c94527054f4aedef87b`.

## 1. Decisão solicitada e justificativa

O encerramento técnico do T1 foi aprovado expressamente pelo proprietário sob `SYNTHETIC_LOCAL_TECHNICAL_CLOSURE`, com 36 testes locais PASS e rastreabilidade S1–S6. T1 permanece encerrado em seu escopo sintético. **Nenhuma execução de T2 está atualmente autorizada.**

O código T1 utiliza diretamente `InMemoryRepository.scenarios` e `receipts`, além de rollback por cópia local. A introdução direta de PostgreSQL não asseguraria conformidade, concorrência ou transações. O Documento 190 propõe, como pré-requisito, separar a lógica de domínio da unidade de persistência usando uma interface e um adaptador **ainda em memória**.

Propõe-se autorizar somente T2-A1: implementação e teste local dessa fronteira Python, sem infraestrutura de banco ou serviços externos. O objetivo é preparar um adaptador substituível posteriormente, mas não implementar PostgreSQL agora.

## 2. Escopo estritamente autorizável de T2-A1

1. Criar um diretório de trabalho experimental próprio, preferencialmente `prototypes/d1_t2/a1/`, mantendo a baseline versionada de `prototypes/d1/` e os 36 testes originais sem modificações retroativas.
2. Definir contrato Python de `ScenarioRepository` e `UnitOfWork` (ou nomes equivalentes) para leitura do cenário, controle de versão, acesso a recibos idempotentes, preparação de estado/eventos/recibos e commit/rollback atômico **em memória**.
3. Adaptar os serviços sintéticos do protótipo para depender dessa interface, evitando acesso direto aos dicionários internos e preservando as regras de domínio, identidade, proveniência, baseline, transições e conclusão científica.
4. Implementar adaptador em memória isolado, determinístico e reprodutível; injetar falhas controladas e validar que um erro não confirme estado/evento/recibo parcialmente.
5. Executar localmente testes de conformidade, regressão e testes adversariais; executar também os **36 testes originais de T1**, sem alterar seu significado ou apresentá-los como testes PostgreSQL.
6. Publicar arquivos Python, testes e documentação no GitHub mediante Freshness Gate, verificação de hashes e checkpoint equilibrado; registrar divergências, falhas, limites e custos iguais a zero, sem alegar durabilidade ou concorrência entre processos.

**Entregável de saída:** contrato de repositório e UoW funcional **sobre memória**, demonstrador reprodutível e relatório de testes vinculados ao HEAD; avaliação de prontidão para discutir T2-A2, **não** autorização implícita para avançar.

## 3. Exclusões vinculantes

- **Proibidos:** PostgreSQL e SQL (inclusive SELECT/DDL), Neon, bancos locais ou remotos, drivers/conexões de banco, migrações do OES-P1, CI remota, nuvem, implantação, endpoints/API pública, chamadas factuais PubMed/ClinicalTrials, dados pessoais/reais, serviços pagos, cartão/upgrade de plano, credenciais novas e mudança de gates.
- Não alterar o encerramento T1, os contratos e migrations canônicos, o estado da Fase 4/5 ou declarar revisão científica independente, equivalência SQL, robustez concorrente ou prontidão para produção.
- Não abrir T2-A2, T3 nem D2 sem deliberação expressa separada. Um novo `Prossiga`, por si só, não altera essas fronteiras.
- Não modificar silenciosamente a semântica de `create_scenario` ou `record_assessment(pending)`; registrar propostas de correção e testes como questões explícitas para deliberação posterior.

## 4. Critérios objetivos de aceitação futura

| Controle | Evidência requerida |
|---|---|
| A1-Isolamento | diretório T2 próprio; T1 intacto; comparação de blobs/hashes antes e após |
| A1-Regressão | 36/36 testes T1 aprovados, sem esconder divergências |
| A1-Contrato | interface/UoW especificadas, injeção de adaptador e testes por operação |
| A1-Atomicidade | rollback sem mutação parcial de cenário/eventos/recibos em falhas injetadas |
| A1-Idempotência | recibos e conflitos exercitados; diferenças de semântica do T1 declaradas |
| A1-Replay | reconstrução consistente e detecção de divergências sintéticas |
| A1-Proveniência | `synthetic=true`, `synthetic:`, ator fictício e disclosure fiel |
| A1-Reprodutibilidade | comando, resultados, hashes, HEAD e dependências registradas |
| A1-Custos e limites | biblioteca padrão sempre que viável; nenhum acesso externo, cobrança ou promessa de banco/concorrência |

Se houver necessidade de infraestrutura, dependência paga, alteração dos contratos científicos, perda de regressão sem justificativa aprovada ou escopo não sintético, **interromper** e submeter decisão. Falha de teste deve ser reportada, não mascarada.

## 5. Pontos de arquitetura reservados

**R1 — Resposta da criação idempotente:** T1 devolve snapshot corrente ao repetir a criação, enquanto outras operações devolvem o resultado original. O contrato candidato do Documento 190 recomenda resposta original imutável em T2, mas **a mudança de semântica não é aprovada por esta minuta**.

**R2 — Avaliação `pending`:** T1 permite registrar pendência sem permitir substituição posterior do mesmo sinal. Uma transição auditada ou a restrição de `pending` requer deliberação própria. T2-A1 deve documentar e reproduzir o comportamento atual nos testes baselines, sem corrigi-lo tacitamente.

## 6. Texto exato para decisão do proprietário — PROPOSTO, NÃO APROVADO

`APPROVED — OES / D1-T2-A1 / PYTHON_IN_MEMORY_REPOSITORY_BOUNDARY_ONLY / Autorizar exclusivamente a refatoração e os testes locais, em Python, da interface de repositório e Unit of Work com adaptador em memória, em diretório experimental separado, preservando o T1 e seus 36 testes, a semântica atual e as limitações científicas; permitir versionamento no GitHub com Freshness Gate; sem SQL, PostgreSQL, Neon, drivers de banco, CI remota, nuvem, implantação, API pública, consultas factuais, dados reais, serviços pagos, alteração de gates ou autorização de T2-A2.`

**Só o envio expresso dessa aprovação pelo proprietário libera T2-A1**; a existência do documento não concede permissão. Alterações sobre R1/R2, PostgreSQL local, Neon Free e execução de T2-A2 exigem autorização separada.

## 7. Estado e continuidade

T1 = `CLOSED_SYNTHETIC_LOCAL_ONLY`. T2-A0 = `DOCUMENTED`. T2-A1 = `AWAITING_EXPLICIT_OWNER_APPROVAL`. CP218 = vigente; demais gates históricos inalterados. Após a decisão expressa do proprietário, formalizar escopo e executar **uma atividade delimitada por Prossiga**, mantendo checkpoints após 3–5 atividades ou decisão material.

**STOP — aguardar aprovação ou outra orientação.**
