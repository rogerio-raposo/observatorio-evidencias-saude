# Documento 259 — PG-A3: revisão de proporcionalidade e minuta de autorização

**OES | 2026-10-24 | base main `6b3f2356fa77d95ae699f8ab3d1213d102cb49c6` | AUTHORIZATION_DRAFT_ONLY / PG_A3_NOT_APPROVED**

## 1. Parecer

A análise dos Documentos 256–258 confirmou uma intervenção proporcional: **um ensaio isolado de schema PostgreSQL existente, com fixtures integralmente sintéticas, antes de integrar Django**. Não criar schema alternativo, framework de persistência ou projeto Neon adicional. O Documento 258 permanece o contrato técnico de referência; esta minuta apenas delimita as duas decisões executivas e não duplica seus controles.

Referências SQL em `main` examinadas nesta revisão:
- `database/poc-s1.sql` (Git blob SHA `887d61a3da77ac1fa7fa654085ef2a856627caca`), baseline experimental inteiro, que instala estruturas adicionais ao slice Study/Report;
- `database/003_poc_s3_provenance_guard.sql` (Git blob SHA `411d9b218be050057745a8389eeec251a2318a2d`), guardas de imutabilidade na tabela `provenance.record`.

Estes são identificadores de **blob Git**, não hashes SHA-256 de segurança de distribuição. Reconfirmar blobs e calcular hashes conforme gate de execução; não tratar estes identificadores como autorização de SQL.

## 2. Minuta de aprovação PG-A3-G0 — infraestrutura, somente

Objeto candidato: projeto Neon existente `oes-sandbox`, ID `weathered-boat-65779510`, região `aws-sa-east-1`, plano Free, branch principal `production` (ID `br-wild-field-b6qg7k3p`). Verificar novamente região, limite de branches/cotas, custo potencial e ausência de conteúdo real antes do ato.

**Autorização específica a solicitar:** permitir a criação de **uma única branch isolada descartável**, derivada da branch principal, com denominação `oes-pg-a3-synthetic-<identificador>`, exclusivamente para ensaio; **não** executar SQL, copiar dados factuais, tocar na principal, alterar grants de outros ambientes, contratar serviço ou excluir branches existentes. Verificar ID retornado, diferença em relação ao ID principal e acesso mínimo antes de prosseguir. Qualquer custo/limite inesperado ⇒ STOP. A criação da branch **não** autoriza G1 nem seu descarte.

## 3. Minuta de aprovação PG-A3-G1 — SQL, separadamente e somente depois de G0

**Autorização específica futura a solicitar:** após confirmar a nova branch por ID, executar nela, e somente nela, `database/poc-s1.sql` na revisão exata então congelada; decidir explicitamente se incluir `003_poc_s3_provenance_guard.sql` (recomendado para testar integridade de provenance). Exigir checksum/histórico de execução, conexão direta para SQL de schema, privilégios mínimos, revisão de dependências, fixtures inteiramente fictícias, testes de FKs/versionamento/vínculos/proveniência e logs sem segredos. Não incluir migrations 002, 004–036 por inferência. Nenhuma alteração em Django no G1. Divergência de base, schema ou resultado ⇒ HOLD/STOP.

**Condição importante:** o baseline inteiro contém tabelas de múltiplos domínios; a avaliação deve registrar esse escopo instalado sem classificá-lo como esquema de produção. Não afirmar cobertura de SA/BRG de produção a partir de PASS sintético.

## 4. Decisão recomendada

**PG-A3-G0 pode ser submetido à autorização específica do proprietário**, com delimitação acima. **PG-A3-G1 permanece dependente do resultado de G0**, de verificação de cota, branch e checksums. Não solicitar autorização simultânea para instalação sem conhecer o ID de branch isolada.

Após qualquer G0 aprovado, um `Prossiga` autorizaria somente o ato delimitado e explicitamente aprovado, respeitando o protocolo uma atividade por comando. Nenhuma exclusão automática de branch.

## 5. Estado e continuidade

`PG_A3_PROPORTIONALITY_REVIEW_COMPLETE / G0_DRAFT_PREPARED / G0_NOT_GRANTED / G1_NOT_GRANTED`.

Nenhum SQL, CREATE BRANCH, teste conectado, alteração Neon, ingestão real, Fase 5 ou gate E6 foi realizado nesta revisão. O checkpoint vigente permanece CP270 até consolidação explícita proporcional. Documentos 256–259 são rastreáveis no GitHub; 36 migrations permanecem UNREVIEWED. A próxima decisão concreta é aprovação ou rejeição de **G0 apenas**. STOP.
