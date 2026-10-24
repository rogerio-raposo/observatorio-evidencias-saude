# Documento 257 — PG-A2: desenho mínimo Study/Report/proveniência para integração Django–PostgreSQL

**OES | 2026-10-24 | main bae4cb281bc9e19db5d4b9980376ea77da828156 | STATIC_ARCHITECTURAL_ASSESSMENT_ONLY / IMPLEMENTATION_NOT_AUTHORIZED**

## 1. Propósito e base

Atividade PG-A2 em modo médio, após PG-A1 (Documento 256). Inspeção estática do SQL `database/poc-s1.sql`, dos cabeçalhos de `002`–`005`, de `applications/oes_web/evidence/{services,domain}.py`, do Documento 227 e da política de migrações (arquitetura Documento 30). Nenhum SQL, teste, CI, aplicação, banco ou Neon foi executado/modificado. Esta análise não revisa nem libera as 36 migrations para implantação.

## 2. Encadeamento técnico mínimo comprovado

O baseline `poc-s1.sql` (599 linhas) contém, entre outras estruturas:
- `core.entity` e `core.entity_version` (identidade, versão e restrição de uma versão current por entidade);
- `evidence.study`, `evidence.study_version`, `evidence.report`, `evidence.report_version` (entidades e versões tipadas; FK/trigger `core.assert_entity_type()`);
- `evidence.study_report_link` (associação Study–Report, possível pluralidade em ambas as direções);
- `provenance.record` (proveniência vinculada a `core.entity_version`; referência opcional a `evidence.report_version`);
- outros schemas, tabelas, funções e views para investigação, resultados, síntese, produto, appraisal, artifacts e lineage, fora do slice pretendido.

O arquivo `003_poc_s3_provenance_guard.sql` acrescenta triggers de preservação de histórico à tabela `provenance.record` criada no baseline. Seus cabeçalhos indicam dependência direta do baseline. Não afirmar que a proteção integral de proveniência se resume a esse único arquivo sem ensaio.

O arquivo `002_poc_s2_search_screening_risk.sql` depende do baseline e adiciona busca/triagem, mas **não é requisito direto identificado** para a leitura das cinco estruturas centrais acima. `004_poc_s4_report_relation_impact.sql` depende, segundo seu cabeçalho, do baseline + 002 + 003 e acrescenta ReportRelation/impact traversal; não é necessário para um simples vínculo Study–Report. `005` (métodos especializados) e `006`–`036` ficam fora desse recorte.

**Cuidado:** executar o baseline *como está* instala muito mais que o recorte mínimo. Extrair somente parte dele criaria uma nova derivação de schema/migrations, que exigiria decisão de autoridade e testes próprios. Não alegar que já exista script de instalação do subconjunto.

## 3. Contrato Django atual e lacunas de integração

`services.py` lê `fixtures/signals.json`; `domain.py` possui dataclasses `Signal`, `StudyReference`, `ReportReference`, `StudyReportReference`, `SourceReference` e milestones de referência documental. O estado `KNOWN_DOCUMENTED` é separado de `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`. Os vínculos documentais tipados dependem de fonte/locator explicitamente restritos. O aplicativo não possui ORM nem conexão habilitada: `DATABASES={}`.

O esquema físico não demonstra, por si, representação 1:1 de todos os campos e fronteiras do `Signal` documental (especialmente `identity_state`, NCT externo, `certainty_boundary`, `limitations` e `source` documental). **Não afirmar equivalência sem mapeamento explícito e ensaio.** A eventual persistência de NCT não deve inventar adjudicação de identidade Study/Report para `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`.

## 4. Duas alternativas e recomendação

A. **Baseline integral experimental em banco isolado**, com Django inicialmente leitor: maior reutilização e fidelidade à PoC; porém instala estruturas não utilizadas, exigindo avaliação de permissões e isolamento. Não é produção nem autoriza migrations posteriores.
B. **Subset SQL mínimo extraído**, com versões de `core.entity`, Study, Report, vínculo e proveniência: menor superfície de schema, mas introduz manutenção de um contrato derivado e divergência em relação ao baseline canônico.

**Recomendação PG-A2:** preferir A como hipótese de teste técnico *descartável* para validar integração e equivalência, sem tratar o banco como operacional e sem reescrever baseline; somente após ensaio decidir se B realmente se justifica. Para Django, preferir consultas read-only encapsuladas em adaptador simples ou modelos `managed=False` mapeados, **sem `makemigrations` para tabelas legadas**. Não replicar o D1-T2-A2 artesanal; não criar framework de repositório genérico. A autoridade de migração deve permanecer nos SQL versionados da PoC enquanto o ORM apenas lê. Revisar a autoridade antes de introduzir qualquer tabela Django gerenciada.

## 5. Teste futuro delimitado (não autorizado)

Um futuro PG-A3 exigiria gate próprio para criar/usar **ambiente descartável isolado**; executar baseline autorizado por conexão direta, com ledger/checksum ou evidência equivalente definida previamente, sob privilégios mínimos; carregar **somente fixtures artificiais**; confirmar (i) Study ≠ Report e cardinalidades, (ii) versionamento e FKs, (iii) provenance/guards se `003` aplicado, (iv) saída read-only de Django sem inferir identidade, (v) reversibilidade/descarte e ausência de impacto sobre outras branches. A escolha de projeto/branch de Neon, custos, grants, dados, scripts e CI requer autorização explícita posterior. Não utilizar automaticamente a branch chamada `production`, nem alterar o projeto sintético existente sem decisão.

## 6. Estados e retomada

**PG-A2 = STATIC_DESIGN_COMPLETE / CANDIDATE_A_PREFERRED / PG-A3_NOT_AUTHORIZED.** Uma implementação PostgreSQL real não foi demonstrada. D2 E6-G1 permanece NOT_APPROVED e bloqueado por `if: false`; Fase 4 somente documentalmente encerrada, Fase 5 NOT_STARTED, readiness NOT_READY, M3 BLOCKED, BRG/SA pendentes, 36 migrations UNREVIEWED. CP270 permanece vigente.

Próxima atividade, mediante novo `Prossiga`: especificar **um gate PG-A3 operacional e proporcional**, com seleção explícita de ambiente descartável, escopo mínimo de fixtures, autorizações e salvaguardas, **sem executar SQL ou modificar recursos por inferência**. STOP.
