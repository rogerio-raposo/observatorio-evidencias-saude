# Documento 206 — D1/T2-A2: fechamento documental condicionado e proposta A2-G1 (CP231)

**OES | 2026-10-22 | DESIGN_DELIBERATION_PACKAGE_READY | A2-G1 NOT_APPROVED | T2-A2 NOT_AUTHORIZED**

## 1. Natureza e precedência
Consolidação das atividades documentais pós-CP230 A1 (contratos verificáveis e oráculos), A2 (suficiência e minuta condicionada) e A3 (integração editorial). Base canônica: Documento 197 (especificação histórica inicialmente local), Documento 205 (modelo pós-conexão, achados F01–F07), Documentos 200–204 (Neon e limites de N1-E3), `prototypes/d1/monitor.py`, `prototypes/d1_t2/a1/repository.py`, `bridge.py` e testes. Esta proposta não modifica o Documento 205, não homologa invariantes e não concede autorização a T2-A2. O Documento 205 continua válido como registro dos achados; a resolução neste documento é **somente de desenho proposto**, não prova operacional.

## 2. Ambiente e escopo
O único candidato cloud é o projeto Free sintético `oes-d1-t2-a2-synthetic` (`tiny-pond-20086371`), branch `synthetic-main`, banco `oes_t2a2_synthetic`, PostgreSQL 18, sem tocar em `oes-sandbox`. Papel app `oes_t2a2_app` existe, sem novos GRANTs; `oes_t2a2_runtime` tem privilégios excessivos e **NÃO DEVE SER USADO**; N1-D2 não foi concluído. A CI N1-E3 39737616716 verificou TLS no trecho cliente→endpoint usando Psycopg/verify-full e CA, com `pg_stat_ssl.ssl=false` no backend. A topologia e segurança dos segmentos internos não estão demonstradas. Nenhuma nova conexão é autorizada.

## 3. Desenho físico candidato — não executável nesta decisão
Schema candidato `oes_t2a2_proto` com exatamente `scenario` (scenario_id TEXT chave primária; revision BIGINT positiva; state JSONB não nulo; synthetic BOOLEAN verdadeiro), `event` (scenario_id FK, sequence BIGINT positiva, kind TEXT não vazio, payload JSONB; chave composta por scenario_id e sequence) e `receipt` (scenario_id FK, request_id não vazio, fingerprint canônico, response JSONB válido e revision BIGINT positiva; chave composta por scenario_id e request_id). Regras de nulidade, JSONB e índices essenciais exigem aprovação textual/DDL específica futura. **O repositório genérico T2-A1 admite resposta escalar, portanto `receipt.response` não pode ser limitado indiscriminadamente a objetos JSON; o domínio M2 tem contratos próprios.** `synthetic=true` é declaração, não prova factual. Não criar tabelas adicionais, migrations históricas, procedimentos científicos, triggers de workflow, API ou RLS sem novo fundamento e aprovação.

## 4. Contrato transacional proposto
Os cinco comandos T2-A1 (`create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`) permanecem intocados em `prototypes/d1/` e `prototypes/d1_t2/a1/`. Uma futura UoW PostgreSQL deverá ler recibo, cenário e log numa única visão transacional, executar domínio Python em cópia, validar invariantes e confirmar Scenario+Event+Receipt na mesma transação ou revertê-los. O `bridge.py` corrente chama `repo.list_events` separadamente, protegido atualmente por `RLock`; esse padrão não pode ser transportado sem contexto transacional comum.

Para cenário existente, `READ COMMITTED` com lock antes de leituras e controle de revisão é hipótese; replay/snapshot independente pode exigir `REPEATABLE READ` ou outra visão comprovadamente coerente. Criação inexistente requer unicidade e tratamento correto de colisão em transação recuperável; `SELECT FOR UPDATE` não bloqueia linha inexistente. `scenario.revision` cresce de um por comando novo; a sequência do único novo evento e `receipt.revision` correspondem à revisão final; repetição idempotente não altera nada. Os eventos incorporados em `scenario.state` devem coincidir integralmente com a tabela de eventos e o replay deve reconstruir e detectar divergência. A chave única não garante contiguidade de sequência.

Preservar fingerprint SHA-256 sobre `encoded(payload)` Python existente, e diferenças intencionais `RepositoryConflict`/`DomainError`. Repetir criação com mesmo request e fingerprint devolve snapshot **corrente**; demais comandos repetidos devolvem resposta original; request reaproveitado com fingerprint divergente falha; cenário existente com novo request de criação falha como `DomainError`. `pending` não permite segunda avaliação; baseline e conclusão científica sintéticos são imutáveis; quatro estados de projeção continuam distintos.

Falha de conexão durante COMMIT gera resultado **indeterminado** até reconciliação por cenário/request/fingerprint. Ausência imediata do recibo não constitui prova de rollback; se continuar indisponível, não concluir sucesso/falha nem repetir cegamente.

## 5. Achados F01–F07: respostas e evidências pendentes
| ID | Resposta documental incorporada | Evidência posterior exigida |
|---|---|---|
| F01 (CRITICAL) | UoW com visão de estado/evento/recibo conjunta | O-01/O-05: leitura e replay sem revisão mista |
| F02 (HIGH) | Unicidade, colisão de criação e rechecagem de recibo | O-02/O-03: criação única e conflitos compatíveis |
| F03 (HIGH) | Correspondência revision/sequence/receipt + replay | O-04/O-05: atomicidade e divergência detectada |
| F04 (HIGH) | Reconciliação por recibo e indeterminação explícita | O-06: commit incerto sem duplicar efeito |
| F05 (HIGH) | Owner segregado, `oes_t2a2_app` mínimo e ameaça limitada | O-07/O-10: ACL e escopo de descarte |
| F06 (MODERATE) | PK/FK/NOT NULL/CHECK, JSONB compatível | O-04/O-09: validade física e semântica legada |
| F07 (MODERATE) | Neon Free candidato sob gates independentes | Preflight de quotas, ownership e fronteira TLS antes de operações |
**Classificação:** `DOCUMENTARY_RESOLUTION_PROPOSED`. Não converter em `OPERATIONAL_CLOSED` sem ensaios futuros expressamente autorizados.

## 6. Lacunas L1–L4 mantidas como condições
L1: nível de isolamento ainda hipótese a verificar; L2: integridade semântica não decorre apenas de DDL/atomicidade; L3: capacidades efetivas de proprietário e ACL não verificadas para criação; L4: aprovação documental não amplia autorizações Neon, CI, SQL, drivers ou infraestrutura. Todas exigem decisão/evidência correspondente em gates separados.

## 7. Oráculos futuros — absolutamente NÃO EXECUTADOS
| ID | Prova pretendida e resultado esperado |
|---|---|
| O-01 | Concorrência escrita/leitura: snapshot apenas de revisão íntegra |
| O-02 | Criações concorrentes: cenário único e um só evento inicial |
| O-03 | Repetição idempotente e payload conflitante: respostas/exceções históricas e nenhuma duplicação |
| O-04 | Falha entre gravações: nenhuma confirmação parcial |
| O-05 | Alteração divergente entre JSONB e tabela de eventos: replay detecta |
| O-06 | Perda de conexão durante commit: reconciliação ou estado indeterminado |
| O-07 | Tentativa de DDL pela app: negada, sem escalada |
| O-08 | Reinício Python: estado/eventos/recibos duráveis |
| O-09 | Regressão T1 (36 históricos) + T2-A1 (39 históricos) e diferencial futuro T2-A2: sem divergência não aprovada |
| O-10 | Descarte isolado: apenas recursos expressamente autorizados afetados |
Não confundir reinício de processo, servidor e falha física; registrar testes negativos e limites da evidência. Nenhum PASS novo declarado.

## 8. Parecer de suficiência e minuta de autorização — **NÃO APROVADA**
Parecer `SUFFICIENT_FOR_CONDITIONAL_DESIGN_DELIBERATION`: há material para deliberação restrita de arquitetura, **não** para execução ou validação operacional. Minuta para ato separado do proprietário:

> **PROPOSED — OES / D1-T2-A2 / A2-G1 / CONDITIONAL_DOCUMENTARY_DESIGN_APPROVAL** — Aprovar exclusivamente como referência documental condicionada o desenho de três entidades sintéticas do Documento 205 complementado pelo Documento 206; preservar integralmente T1/T2-A1 e contratos atuais; considerar F01–F07 endereçados documentalmente, não validados; manter L1–L4 e O-01–O-10 como condições para operações futuras expressamente autorizadas. **Não autorizar** SQL, DDL, DML, GRANT, objetos, roles, novas conexões Neon, CI, adaptador, tests remotos, dados reais, migrations canônicas, deploy, API pública, buscas científicas, serviços pagos, promoção de gates ou fases. A2-G2–G6 dependem de decisões autônomas, preflight e pós-condições específicas.

**A2-G1 PENDENTE de decisão expressa; a publicação deste documento não significa aprovação.** Os rótulos A2-G1–G6 são auxiliares, não gates oficiais instituídos. Estado: T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 PASS históricos), T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 PASS históricos), T2-A2 `NOT_AUTHORIZED`; Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`. D0 editorial concluído → D1 prioritário → D2 factual futuro → governança operacional completa depois.

## 9. Continuidade e STOP
Próximo `Prossiga` permite somente atividade delimitada; recomendar avaliação da minuta A2-G1 e, se o proprietário expressamente aprovar, registrar a decisão em ato autônomo, sem executar o desenho ou preparar automaticamente operações. Aplicar Freshness Gate. Não tocar em Neon, SQL, CI ou roles. **STOP.**
