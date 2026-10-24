# Documento 262 — PG-A4: gate de autorização do primeiro leitor Django–PostgreSQL

**OES | 2026-10-24 | Base CP271 e Documento 261 | main `21521b490ab841bb32811358a8bbb8ed2175cdb1` | PG_A4_SCOPE_READY / IMPLEMENTATION_NOT_AUTHORIZED**

## Decisão de escopo
Propõe-se **um único incremento estritamente sintético e somente leitura** na aplicação Django: serviço interno isolado `list_synthetic_study_report_links()` (nome indicativo, não contrato de API pública), que retorne uma projeção tipada e explicitamente **experimental** de Study, Report, vínculo e referência de proveniência. Nenhum endpoint público novo é necessário no primeiro ato. `catalog` e `detail` atuais continuam usando `signals.json` e preservam seu comportamento; não ligar automaticamente esses sinais às tabelas PostgreSQL.

**Ajuste crítico ao Documento 261:** o banco de ensaio encontra-se vazio de fixtures após os testes com rollback. A primeira prova Django pode demonstrar conexão e leitura vazia; para provar projeção com linhas relacionadas será necessária **etapa separadamente autorizada** de inserção de fixtures artificiais versionadas na branch sintética. Não presumir que PG-A3 tenha deixado dados de teste.

## Contrato funcional mínimo
- Entradas: nenhuma identidade factual/NCT; parametrização exclusivamente por conexão isolada à branch de ensaio.
- Saída: registros tipados com `study_entity_uuid`, versão corrente de Study, `report_entity_uuid`, versão corrente de Report, tipo do vínculo e, quando existir, ID/field_path de proveniência explicitamente vinculada à versão. Vínculo N:M preservado; não converter ausência de proveniência em evidência de ausência científica.
- Sem equivalência afirmada entre `Signal.identity_state`, `Signal.provenance`, `DocumentaryMilestone`, `StudyReference`, NCT e a persistência SQL. O estado `NOT_IDENTIFIED_IN_SCOPED_INVENTORY` não pode se tornar identidade reconciliada por efeito de JOIN.
- Dados marcados `SYNTHETIC_TECHNICAL_ONLY`. Nenhum parecer científico, agregação clínica, ingestão ou publicação factual.

## Implementação proposta, apenas após aprovação
1. **PG-A4-G0 (autorização de infraestrutura):** conferir head/branch `br-gentle-hall-b6jaxehf`, quotas Free, e criar role de **SELECT apenas** sobre as estruturas estritamente necessárias. Não usar `oes_sandbox_owner` como credencial Django. Grants, role, credencial/conexão são mutações e exigem autorização específica. Nenhuma branch nova; não tocar `production`.
2. **PG-A4-G1 (código local):** acrescentar uma configuração **opt-in**, por variáveis de ambiente e sem credenciais versionadas, para alias PostgreSQL experimental e serviço de leitura via SQL parametrizado/connection Django; não criar modelos gerenciados nem aplicar migrations Django ao esquema PoC. Não modificar comportamento dos endpoints existentes. Driver e configuração sob aprovação técnica específica.
3. **PG-A4-G2 (dados e demonstração):** preparar fixture **estritamente sintética**, versionada, separando aprovação da inserção no Neon; validar leitura com zero registros antes de inserir, depois leitura de duas Studies, dois Reports, vínculos N:M e proveniência artificial. Decidir explicitamente o destino dos dados de ensaio, sem apagar branch por inferência.
4. **PG-A4-G3 (aceite):** testes isolados de projeção, cardinalidade e ausência de escrita, cenários de conexão indisponível e role SELECT, preservação dos testes/regressões atuais Django. Evidência de qual branch/role foi usada, nenhum segredo em logs. PASS técnico **não** promove prontidão operacional.

A implantação conectada deve ocorrer em ambiente de ensaio, não em serviço publicado; manter `DEBUG=True` e segredo de desenvolvimento fora de qualquer deployment. Não acoplar as credenciais do ambiente ao arquivo de configurações padrão.

## Exclusões e STOP
Sem D1-T2-A2 artesanal, reimplementação da camada de persistência, novo schema, novas migrations 002/004–036, backend escrito à mão, API pública, CI conectada por inferência, coleta ClinicalTrials.gov, serviços pagos, produção ou Fase 5. Nenhuma alteração nos gates E6-G1, BRG, SA. Permissões e testes devem ser suficientes para o primeiro incremento, sem antecipar todas as exigências operacionais.

## Estado e retomada
`PG_A3_CLOSED_SYNTHETIC_RESTRICTED / PG_A4_SCOPE_DEFINED / PG_A4_G0_NOT_AUTHORIZED`. CP271 continua vigente. **Próxima decisão:** solicitar aprovação **PG-A4-G0 somente**, autorização da identidade de leitura limitada ao banco da branch sintética. Qualquer `Prossiga` antes dessa aprovação autoriza apenas preparação documental/read-only; não criar role nem grants por inferência. STOP.
