# OES — Continuidade CP227

**2026-10-21 | CP226 anterior | HEAD pré-registro `893e4f35f2a87c3c7c7780f243bc98b4d1f296f7`**

Documento 202 registra, como evidência de duas consultas SQL estritamente de leitura autorizadas, N1-C e N1-D1: `pg_stat_ssl.ssl=false` na sessão observada (não interpretar como prova de transporte externo sem TLS), papel runtime `oes_t2a2_runtime` com `CREATEDB`, `CREATEROLE`, membership hereditária e assumível em `neon_superuser`, e CREATE efetivo no banco. Trata-se de **privilégios excessivos confirmados**. Nenhuma mutação executada; não usar runtime para gravações antes de correção/validação. Neon Free sintético independente, projeto original intocado.

**Status:** N1-D2 e N1-E não aprovados; T2-A2 `NOT_AUTHORIZED`. T1/T2-A1 apenas fechamentos técnicos históricos e gates restantes inalterados.

**Retomada:** uma única atividade documental sob `Prossiga`: especificar N1-D2 com operações mínimas, efeitos, pré/pós-condições e rollback, sem executar ALTER ROLE, REVOKE, GRANT ou SQL; Freshness Gate e STOP.
