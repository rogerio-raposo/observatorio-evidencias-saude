# Documento 256 — PG-A1: prioridade aprovada e inventário inicial de integração PostgreSQL

**OES | 2026-10-24 | base main 5842830ce80a60b30d53f7b87bcf2b024146cc2b | OWNER_APPROVED_ARCHITECTURAL_EVALUATION / READ_ONLY_INVENTORY / NO_DB_EXECUTION**

## Decisão aprovada e fronteira

O proprietário aprovou, em modo alto, a avaliação arquitetural delimitada de entrada do PostgreSQL/Neon no OES; a atividade PG-A1 de inventário prosseguiu em modo médio. A aprovação é de **avaliação e priorização**, não de integração implementada, adoção definitiva da stack, criação/alteração de recursos, SQL, migrations, drivers, testes conectados, gastos, novos dados factuais, Fase 5 ou alteração dos gates de D2-E6.

Preservar decisão 227 (não retomar adaptador artesanal T2-A2/A2-G4); decisão 249 (Django 5.2 LTS candidato preliminar, não stack de produção homologada); política de migrations do Documento 30; D1 sintético restrito, Fase 4 documentalmente encerrada, readiness NOT_READY, D2 PARTIAL, E6-G1 NOT_APPROVED e job factual com if: false.

## PG-A1 — inventário estático proporcional

- `database/poc-s1.sql`: baseline experimental PostgreSQL com identidades versionadas, relações e proveniência. **Candidato à base para análise da cadeia mínima**, ainda não aprovado para implantação.
- `002_poc_s2_search_screening_risk.sql`: Search, SearchHit, screening/deduplicação/risk; depende explicitamente do baseline. **Possivelmente necessário apenas se o primeiro slice incluir busca/ingestão**; não presumir.
- `003_poc_s3_provenance_guard.sql`: guardas de imutabilidade de proveniência; depende do baseline. **Candidato necessário quando houver escrita persistente de proveniência**; requer análise contratual.
- `004_poc_s4_report_relation_impact.sql`: ReportRelation e travessia de impacto; depende de baseline + 002 + 003, segundo cabeçalho do arquivo. **Opcional para primeiro slice de identidade Study ≠ Report**, salvo requisito específico de relações entre Reports.
- `005_poc_s5_specialized_methods.sql`: métodos NMA, PredictionModel e CERQual; depende de baseline + 002–004. **Fora do recorte mínimo inicial**.
- `006`–`020`: contratos de produtos e projeções F3. **Não requeridos automaticamente para leitura Study/Report**.
- `021`–`026`: Monitor/Alert e projeções. **Diferidos**, M3 bloqueado.
- `027`–`036` e arquivos auxiliares 031a–033e: protocolo de atualização, risco, temporalidade, medições e controles. **Diferidos**, gates operacionais não satisfeitos.
- `applications/oes_web/config/settings.py`: `DATABASES = {}`, sem modelos ORM em `evidence` no inventário; demonstrador GET-only por fixtures. Não há conexão PostgreSQL funcional atual.
- Neon (inspeção de metadados read-only): `oes-d1-t2-a2-synthetic` em São Paulo, branch `synthetic-main`, esquema `oes_t2a2_proto` com três tabelas experimentais (`scenario`, `event`, `receipt`); `oes-sandbox` em São Paulo, branch `production`, sem tabelas listadas. Nomes de branch não atestam homologação produtiva.

**Limite explícito do inventário:** classificação preliminar de arquivos e cabeçalhos relevantes, não auditoria integral das dependências SQL, revisão das 36 migrations, análise de esquema em runtime ou compatibilidade Django. Não declarar as migrations como revisadas.

## Recomendação para PG-A2

Definir **um único vertical slice sintético de leitura Study/Report/proveniência**, enumerar tabelas, constraints, funções e dependências SQL transitivas concretas do baseline, decidir entre mapeamento Django unmanaged/read-only e ORM gerenciado apenas onde houver necessidade comprovada, com uma única autoridade para schema/migration ledger. Não instalar toda a cadeia 001–036. Delimitar testes e ambiente descartável em proposta separada. A migração e qualquer escrita em Neon exigem autorização específica.

## Registro operacional

Atividade: PG-A1 inventário estático e formalização de prioridade. Sem SQL, CI, GET, migration, mudança de banco ou desbloqueio E6-G1. **CP270 permanece checkpoint vigente**; este registro posterior é documental e não modifica o ponteiro até novo checkpoint proporcional. Próximo `Prossiga`: PG-A2, **análise de desenho e cadeia mínima SQL**, sem implementação por inferência. STOP.
