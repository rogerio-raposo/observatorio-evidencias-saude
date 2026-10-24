# Documento 261 — PG-A3-G2: avaliação crítica e encerramento técnico restrito do ensaio sintético

**OES | 2026-10-24 | Base: CP271, main `f7c2190dffaca277cecb31f02f74bf0a43a4c79e` | PG_A3_G2_LIMITED_TECHNICAL_CLOSURE / PG_A4_NOT_AUTHORIZED**

## 1. Deliberação técnica

**PG-A3 pode ser encerrado tecnicamente em escopo restrito**, como prova experimental de instalação e comportamento básico PostgreSQL/Neon, **não** como banco homologado, integração Django, segurança operacional ou prontidão científica. Não há benefício proporcional em ampliar agora o protótipo com concorrência, idempotência transacional complexa, extração de subset SQL ou uma nova framework de repositório. Esses tópicos retornam apenas quando exigidos pelo slice real e gates de produção.

## 2. Evidências efetivamente demonstradas

Conforme CP271 e consultas desta atividade: branch isolada não principal `oes-pg-a3-synthetic-20261024` (ID `br-gentle-hall-b6jaxehf`) no projeto `oes-sandbox` (ID `weathered-boat-65779510`), derivada de `br-wild-field-b6qg7k3p`. Endpoint `ep-wispy-dream-b6021bw0` limitado a 0,25 CU e em estado `idle`/suspenso na consulta read-only de 2026-10-24.

- Baseline `database/poc-s1.sql`: 8 schemas, 32 tabelas, 5 views; Study e Report tipados, versões e vínculo Study–Report presentes.
- Migration `003_poc_s3_provenance_guard.sql`: função e triggers de UPDATE/DELETE identificados após instalação.
- Teste sintético em subtransação com reversão controlada: quatro entidades, três vínculos e proveniência; rejeição de versão current duplicada, entidade de tipo incorreto, FK ausente, UPDATE material e DELETE de proveniência; consulta posterior confirmou ausência dos dados sintéticos inseridos.
- Arquivos SQL e hashes registrados no CP271; nenhuma migration 002 ou 004–036 aplicada. Compatibilidade **limitada ao comportamento exercitado**, não auditoria global do baseline.

A instalação foi executada por `oes_sandbox_owner`, papel amplo e **inadequado para a futura identidade de leitura**. Os testes não investigaram eventual semântica de leitura com identidade de baixo privilégio.

## 3. Lacunas relevantes e decisão sobre expansão

**Não demonstrado:** sessão Django real, autenticação de app com privilégio apenas SELECT, isolamento de credenciais, mapeamento `Signal` documental↔Study/Report/provenance, coexistência de dois tipos de identidades (NCT e UUID OES), consultas filtradas por estado, desempenho, privacidade/factualidade, acesso público, restauração, falha/COMMIT incerto, idempotência, concorrência e revisão das 36 migrations para produção. Não converter essas ausências em requisito para *refazer* PG-A3.

O demonstrador Django existente `applications/oes_web/evidence/services.py` somente lê `fixtures/signals.json`; `config/settings.py` contém `DATABASES = {}`, `DEBUG=True` e chave de desenvolvimento. Nenhuma integração persistente existe. Os controles `KNOWN_DOCUMENTED` e `NOT_IDENTIFIED_IN_SCOPED_INVENTORY` não devem ser inferidos automaticamente da mera existência de registros SQL.

## 4. Critérios mínimos para submeter PG-A4 à autorização

1. **Contrato funcional limitado:** um endpoint/serviço interno read-only de Study–Report/proveniência a partir de dados **somente artificiais** já autorizados, sem mudar o significado do `Signal` documental e sem adjudicar NCT não identificado.
2. **Contrato de dados explícito:** projeção definida de `core.entity`, versões, `evidence.study`/`report`, vínculo e `provenance.record`; reconhecer campos sem equivalência. Dados devem ser preparados em fixture SQL sintética, versionada e com rollback/descarte planejado.
3. **Permissões:** definir função/identidade PG de **SELECT apenas** nas tabelas/views necessárias; sem escrever via Django; sem usar `oes_sandbox_owner` como credencial de runtime. Provisionamento de role, grants e secrets requer **ato autorizado** separado.
4. **Implementação proporcional:** usar conectividade PostgreSQL suportada pelo Django, adaptador simples ou modelos `managed=False` estritamente necessários; nenhuma migration gerenciada Django sobre o esquema PoC; preservar contrato SQL canônico e não ressuscitar D1-T2-A2.
5. **Testes e segurança:** testes locais e integrados sobre ambiente sintético isolado, consultas que não contaminem a leitura atual por JSON, testes de vazamento entre fontes, falhas tratadas explicitamente e verificação de que as operações Django não escrevem.
6. **Operação e custo:** branch `br-gentle-hall-b6jaxehf` identificada antes de cada ação, limites Free revalidados, endpoint com auto-suspensão, sem acesso científico factual, CI externa ou deploy por inferência. Excluir a branch apenas sob autorização específica.

## 5. Estados e próxima atividade

**Decisão técnica recomendada:** `PG_A3_G2_REVIEW_COMPLETE / PG_A3_CLOSED_SYNTHETIC_RESTRICTED / PG_A4_NOT_AUTHORIZED`. Encerramento de PG-A3 é apenas metodológico-técnico neste recorte e **não autoriza PG-A4 automaticamente**. A próxima atividade mediante novo `Prossiga` pode preparar, **documentalmente**, o escopo preciso e o gate de aprovação de PG-A4 (primeiro leitor Django com dados sintéticos), evitando novos documentos genéricos ou testes SQL redundantes. STOP.

Preservar CP271 vigente (sem novo checkpoint nesta atividade), Fase 4 encerrada apenas metodologicamente/documentalmente, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, D2 `PARTIAL`, E6-G1 `NOT_APPROVED`, job factual desabilitado, M3 `BLOCKED`, BRG/SA pendentes e 36 migrations `UNREVIEWED`. Nenhum SQL, branch, endpoint, grant, CI, dados reais, Django ou Neon modificado nesta revisão.
