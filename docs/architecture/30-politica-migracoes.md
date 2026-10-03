# 30 — Política de Migrações do Modelo de Dados

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — política arquitetural  
**Data:** 3 de outubro de 2026

## 1. Finalidade

Definir como o schema e os dados estruturais do OES poderão evoluir sem:

- apagar histórico;
- tornar ambientes irreproduzíveis;
- introduzir mudanças manuais invisíveis;
- quebrar provenance;
- misturar correção metodológica com conveniência operacional.

> O estado de um banco OES deve ser reproduzível a partir de artefatos versionados.

---

# PARTE I — PRINCÍPIOS

## 2. Migração é artefato versionado

Toda alteração estrutural material deverá existir em arquivo versionado.

Não serão aceitas como fonte de verdade:

- alterações manuais feitas apenas em console;
- comandos executados sem registro;
- correções “temporárias” não incorporadas ao repositório.

## 3. Baseline

Para a PoC:

`database/poc-s1.sql`

funciona como **baseline experimental inicial**.

A partir do CP12, novas extensões deverão preferencialmente ser aplicadas por arquivos incrementais, evitando reescrita silenciosa do baseline.

Correções necessárias para tornar o baseline executável podem ocorrer antes do F2-B, mas devem permanecer registradas no CHANGELOG.

## 4. Migração de schema × migração de dados

Separar quando possível:

- **schema migration** — estrutura, constraints, índices;
- **data migration** — transformação/backfill dos registros;
- **validation migration** — constraints adicionadas após saneamento;
- **projection rebuild** — regeneração de derivados.

---

# PARTE II — IDENTIDADE DA MIGRAÇÃO

## 5. Migration ID

Formato candidato:

`OES-DBM-AAAA-NNNN`

Metadados mínimos:

- migration_id;
- título;
- data;
- autor/processo;
- dependência anterior;
- finalidade;
- risco;
- reversibilidade;
- validações;
- hash do arquivo.

## 6. Ordenação

Migrações terão ordem explícita e determinística.

Exemplo de arquivo:

`002_poc_s2_search_screening_risk.sql`

A numeração do arquivo é operacional; o Migration ID é a identidade de governança.

---

# PARTE III — PADRÃO EXPAND–MIGRATE–CONTRACT

## 7. Expand

Adicionar estrutura compatível:

- coluna nullable;
- nova tabela;
- novo índice;
- nova relação;
- nova versão de payload.

Evitar quebrar leitores existentes.

## 8. Migrate

- preencher dados;
- validar;
- comparar contagens;
- registrar transformação;
- revisar erros.

## 9. Contract

Somente depois:

- tornar NOT NULL;
- remover estrutura antiga;
- reduzir compatibilidade;
- aplicar constraint final.

Mudança destrutiva não deve ocorrer na mesma etapa em que se descobre se os dados atendem à nova regra.

---

# PARTE IV — TRANSAÇÕES

## 10. Migração transacional

Quando PostgreSQL e o tipo de operação permitirem, uma migração deverá ser executada em transação.

Se operação não puder ser transacional:

- declarar explicitamente;
- registrar risco;
- definir checkpoint;
- definir estratégia de recuperação.

## 11. Falha

Falha não deve deixar estado “quase migrado” sem registro.

Após falha:

1. interromper;
2. capturar log;
3. verificar estado;
4. não editar manualmente silenciosamente;
5. corrigir migration;
6. reconstruir ambiente descartável;
7. reexecutar.

---

# PARTE V — REVERSIBILIDADE

## 12. Rollback

Rollback SQL automático não é obrigatório para toda migração.

Motivo:

reverter schema não significa necessariamente restaurar semanticamente dados transformados.

A política preferida é:

- ambientes descartáveis antes de produção;
- backup/snapshot quando aplicável;
- migração forward-fix;
- scripts de reversão apenas quando seguros.

## 13. Mudanças destrutivas

Exigem:

- backup/snapshot;
- verificação de não uso;
- período de compatibilidade;
- aprovação explícita;
- registro no changelog.

---

# PARTE VI — DADOS E PROVENANCE

## 14. Backfill

Backfill material deverá registrar:

- migration_id;
- critério de seleção;
- contagem esperada;
- contagem alterada;
- erros;
- hash/script;
- validação posterior.

## 15. Dados científicos

Migração técnica não pode alterar significado científico silenciosamente.

Exemplo:

normalizar uma coluna de medida sem preservar:

- valor original;
- transformação;
- provenance

é proibido.

## 16. Provenance

Se uma migração alterar representação de dado crítico:

- preservar provenance anterior;
- criar nova provenance de transformação quando necessário;
- não fazer parecer que o novo formato foi originalmente reportado.

---

# PARTE VII — JSONB

## 17. Promoção de JSONB para coluna normalizada

Processo:

1. adicionar coluna;
2. extrair/backfill;
3. comparar equivalência;
4. mudar leitores;
5. manter payload por período;
6. remover chave somente após validação e decisão.

## 18. Mudança de JSON schema

Payload JSONB deverá possuir:

- schema_name;
- schema_version.

Migração deve ser capaz de identificar a versão de origem.

---

# PARTE VIII — CONSTRAINTS

## 19. Introdução gradual

Para bases com dados existentes:

1. identificar violações;
2. corrigir dados;
3. adicionar constraint;
4. validar;
5. monitorar.

A PoC em banco vazio pode instalar constraints diretamente.

## 20. Constraint como requisito metodológico

Constraints que protegem invariantes metodológicas não devem ser removidas apenas para simplificar ingestão.

Exemplos:

- uma versão current por entity;
- FK de lineage;
- compatibilidade de subtipo;
- supersessão dentro da mesma identity.

---

# PARTE IX — ÍNDICES

## 21. Índice não é invariante semântica

Índices podem evoluir conforme workload.

Toda adição deverá justificar:

- query;
- cardinalidade;
- custo de escrita;
- tamanho;
- evidência de necessidade.

Na PoC, evitar otimização especulativa.

---

# PARTE X — PROJEÇÕES

## 22. DependencyEdge

Como projeção derivada:

- não requer migração semântica manual;
- deve possuir mecanismo de rebuild;
- após mudança relevante, comparar com relações canônicas.

## 23. Busca/grafo futuro

Índices de busca ou graph projections devem ser regeneráveis a partir do core.

---

# PARTE XI — VALIDAÇÃO DE MIGRAÇÃO

## 24. Checklist

Antes:

- dependências atendidas;
- backup/checkpoint quando necessário;
- hash registrado;
- ambiente identificado.

Durante:

- log completo;
- contagens;
- duração;
- warnings.

Depois:

- schema esperado;
- constraints válidas;
- contagens;
- FKs;
- current uniqueness;
- lineage;
- smoke tests.

## 25. Idempotência

Migrações de produção não precisam ser genericamente idempotentes.

Devem, porém:

- saber se já foram aplicadas;
- impedir aplicação dupla acidental;
- registrar migration ledger.

---

# PARTE XII — MIGRATION LEDGER

## 26. Tabela futura

`ops.schema_migration`

Campos candidatos:

- migration_id;
- filename;
- file_hash;
- applied_at;
- applied_by;
- database_version;
- status;
- execution_time_ms;
- notes.

A tabela não é necessária para a validação estática, mas deverá entrar antes de uma implementação persistente.

---

# PARTE XIII — PoC-S2

## 27. Estratégia

A extensão Search/Screening/RiskAssessment será criada como arquivo separado do baseline:

`database/002_poc_s2_search_screening_risk.sql`

Ela deverá:

- depender explicitamente de PoC-S1;
- executar em transação;
- não editar dados existentes;
- adicionar apenas estruturas;
- ser validável separadamente;
- entrar no plano F2-B após T01.

---

# PARTE XIV — DECISÃO

1. baseline não será reescrito silenciosamente após o marco CP12;
2. extensões entram por migrações versionadas;
3. mudança destrutiva exige procedimento explícito;
4. dados científicos preservam significado/provenance;
5. projeções são reconstruíveis;
6. migrations fazem parte da auditabilidade do OES.

---

**Próxima migração experimental: OES-DBM-2026-0002 — PoC-S2 Search/Screening/RiskAssessment.**
