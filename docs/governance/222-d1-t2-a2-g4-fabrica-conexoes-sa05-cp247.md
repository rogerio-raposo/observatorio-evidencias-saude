# Documento 222 — D1/T2-A2: fábrica de conexões e revisão estática SA-05 (CP247)

**OES | 2026-10-22 | DOCUMENTARY_CHECKPOINT_SOURCE_STAGED_UNPUBLISHED_SA05_OPEN | A2-G5/T2-A2_RUNTIME_NOT_AUTHORIZED**

## 1. Autoridade e finalidade

Este documento consolida **apenas documentalmente** as atividades A1–A7 pós-CP246 e a publicação de continuidade A8. Fonte canônica pré-publicação: `main` HEAD `c7570d842c02949ee0ba1308438e700a01bcda81` e ponteiro CP246, Freshness Gate `identical`. Autoridade restrita do Documento 218/CP243: `APPROVED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`. A autorização permite criar, revisar estaticamente e eventualmente publicar controladamente **seis arquivos** em `prototypes/d1_t2/a2/`; não autoriza execução, instalação, testes A2-G5, acesso PostgreSQL/Neon nem operação.

A8 publica **exatamente cinco arquivos de governança/continuidade**, sem publicar nenhum dos seis arquivos técnicos do adaptador. Os arquivos técnicos foram preparados no staging **local desta conversa**, com disponibilidade futura não garantida. Inspeção textual, verificação de presença e SHA-256 **não são** execução, compilação, testes, prova do contrato com PostgreSQL, aceitação técnica ou evidência de exclusividade de conexão.

Referências: Documento 216 (contrato), Documento 217 (proposta), Documento 218 (aprovação), Documentos 219/220/221 e handoffs CP244/CP245/CP246. Exigir novo Freshness Gate antes de qualquer commit posterior.

## 2. Atividades pós-CP246: A1–A7

| Atividade | Trabalho relatado no staging | Resultado e limites |
|---|---|---|
| **A1** | Triagem adversarial textual SA-05, exclusivamente README | Checks passivos de `closed`, `autocommit`, status e transação não comprovam exclusividade, papel, banco ou TLS |
| **A2** | `DedicatedConnectionFactory` nominal e exigida no `repository.py`; atualização README | Contrato explícito contra `Callable` avulso, mas opener arbitrário pode violá-lo |
| **A3** | Revisão adversarial da fábrica; apenas README | SA05-R1: opener fora do `try` e reentrada possível; SA05-R2: retorno `None` ou handle inválido classificado inadequadamente |
| **A4** | Correções textuais em `repository.py`, `errors.py` e README | UoW consumida antes da aquisição; `ConnectionAcquisitionError` para opener com erro, `None` ou interface incompleta |
| **A5** | Revisão adversarial de R1/R2, somente README | Mitigações encontradas; SA05-R3: interface exigia `execute/rollback/close`, omitindo `commit` |
| **A6** | Correção textual R3 em `repository.py` e README | Fábrica passa a exigir métodos chamáveis `execute`, `rollback`, `commit`, `close`, sem executar qualquer método |
| **A7** | Revisão adversarial independente R3; somente README | Mitigação estática da omissão de `commit` observada; nenhum novo bloqueador distinto nesta revisão limitada |

**A8:** consolidação documental CP247 apenas. Não houve import, compilação ou execução do código, testes, SQL, Neon, CI, instalação de Psycopg, alterações em grants, DDL/DML, migrações, serviços pagos ou novos arquivos técnicos.

## 3. Inventário de staging local: fonte NÃO publicada

Caminho da cópia local **nesta conversa**: `/mnt/data/oes_cp243_staging/prototypes/d1_t2/a2/`. Foi observada a existência de **exatamente** seis arquivos e calculado SHA-256 de seus bytes, **sem importação ou execução dos módulos**. Este caminho não é fonte canônica; os hashes não comprovam funcionalidade nem garantem recuperação em outra sessão.

| Arquivo | SHA-256 da cópia de preparação pré-CP247 |
|---|---|
| `README.md` | `427dd60ecbc13fe72fbc72e39ffd34a89212bdf28f8c5e18d799e0794bae5e70` |
| `__init__.py` | `ad38331d4c7cad003386219a74d5eb3c6492b8d716b0bc52e77c53e8c6fd74cc` |
| `bridge.py` | `b8288630ff75d8b62a81ca9b230aa214f4d1ba7ba97964cfa6986d8dcb748e70` |
| `codec.py` | `f22c181f7775d4bdc67841a37815e7917ba332b5cc2e38616b4c64ce797cef11` |
| `errors.py` | `9c0bc0930b898612243311d3598521536ae9feaf4ea9476b3a47a31e911d3fc4` |
| `repository.py` | `7ea106f8fe5d819887e2b59abf96b1b8b9f631785b03140997f45d52f1ce8a66` |

**Não criar inferência de publicação:** o diretório `a2/` está **ausente no GitHub** ao iniciar A8; somente `a1/` existia em `prototypes/d1_t2/`. Os hashes não são hashes de blobs Git do código. Se staging desaparecer ou divergir em nova conversa, interromper e recuperar por procedimento autorizado; não inventar resultados nem alegar disponibilidade garantida.

## 4. SA-05 — contrato reforçado, risco ainda aberto

`DedicatedConnectionFactory` exige um opener chamável e entrega um handle somente após verificação estrutural de quatro métodos; falhas, `None` ou interfaces faltantes geram `ConnectionAcquisitionError`. `PostgresUnitOfWork` é consumida antes de chamar o opener para impedir reentrada após aquisição falha. A ponte `bridge.py` mantém retentativa específica para `23505/scenario_pkey` apenas com rollback e fechamento observados; erro de aquisição não habilita retentativa.

| Item | Estado CP247 | Razão |
|---|---|---|
| SA05-R1 — UoW one-shot em falha de opener | Mitigada textualmente, revisão adversarial delimitada | Não atesta ausência de recursos criados antes da exceção do opener |
| SA05-R2 — `None` e handle sem métodos necessários | Mitigada textualmente, revisão adversarial delimitada | Não atesta classe Psycopg ou responsabilidade de descarte sobre objeto inválido |
| SA05-R3 — `commit` não verificado | **Mitigada e revisada estaticamente** | Verificação de método chamável não atesta semântica de commit |
| **SA-05 global — ALTA** | **ABERTA** | Opener pode fornecer objeto compartilhado, alugado de pool ou falsamente compatível; role, banco, TLS, libpq, timeouts e propriedade efetiva dependem de prova de integração/ambiente ainda não autorizada |

**Não confundir contrato nominal com prova de propriedade exclusiva.** Um objeto que imite a interface pode passar, propriedades dinâmicas podem mudar, e o opener permanece responsável por recursos que abrir mas não devolver. Não se pode validar isolamento real com leitura de fonte nem com a simples disponibilidade de `closed`/status. Nenhum acesso operacional para obter essas evidências está autorizado.

## 5. Demais achados e fronteiras

| Achado | Estado delimitado |
|---|---|
| SA-01/04/09 | Mitigações estruturais anteriores, não testadas |
| SA-02 | Mitigada textualmente; condicionada a SA-05 para confiança em rollback/retry |
| **SA-03** | **PARCIAL**, pareamento semântico recibo–evento não integralmente demonstrável |
| **SA-06** | **ABERTA**, pós-COMMIT e close têm diagnósticos estáticos; commit indeterminado requer reconciliação/limites de classificação |
| **SA-07** | **ABERTA/MODERADA**, compatibilidade numérica/precisão/round-trip JSONB não demonstrados |
| **SA-08** | **ABERTA/ALTA**, associação de recibos e fidelidade de replay não comprovadas |
| **SA-10** | **ABERTA/MODERADA**, classificação contextual de SQLSTATE incompleta |
| SA-11/12 | Mitigadas e revisadas estaticamente, sem PASS operacional |

**Não elevar A2-G4 à condição de implementação aceita/publicada.** Nenhuma validação ou migração por aproximação está autorizada; usar Psycopg `3.3.6` apenas como referência **estática** de API. A2-G5 e T2-A2 runtime `NOT_AUTHORIZED`. Não alterar `oes-sandbox`, grants/papéis, schema, banco, conexão, CI, serviços, dados reais, API ou gates científicos.

Preservar T1 **36 PASS históricos** e T2-A1 **75 PASS históricos** (incluídos 36 T1), **não reexecutados**. A2-G2/E somente estrutural; A2-G3 grants mínimos previamente registrados; F01–F07 apenas documentais, L1–L4 e O-01–O-10 pendentes, 36 migrações `UNREVIEWED`; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. Prioridade D0 encerrado, D1 sintético, D2 factual diferido, governança operacional posteriormente.

## 6. Próxima atividade exata

**A1 pós-CP247, apenas após novo `Prossiga`:** triagem adversarial **estritamente estática** de **SA-07 (codec/JSONB numérico)**, discriminando incompatibilidades detectáveis por análise textual, limites que só runtime poderia testar e alterações proporcionais candidatas nos seis arquivos autorizados. Verificar HEAD e ponteiro CP247, hash/identidade dos seis arquivos locais e o Documento 222 antes de agir. Não importar/compilar/executar codec ou Psycopg, não instalar driver, não conectar Neon, executar testes, CI ou SQL, nem publicar código automaticamente. Retomar SA-08/SA-10/SA-06 em atividades futuras delimitadas. Se staging estiver ausente ou divergir, sinalizar em vez de inferir sucesso.

Protocolo CP194: `Prossiga` = uma atividade; checkpoint normalmente após 3–5 atividades, por risco antecipado; Freshness Gate inicial/pré-commit, comunicação de progresso e STOP.

**STOP — CP247 exclusivamente documental; A2 técnico não publicado.**
