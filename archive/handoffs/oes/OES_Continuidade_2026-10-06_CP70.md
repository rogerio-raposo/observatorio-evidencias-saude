# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP70  
**Checkpoint anterior:** CP69  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Emenda 01 + micro-gate de autorização de persistência do OVR-01 dCBT-I

## 1. Marco

> **OVR-01 = READY_TO_PERSIST_DEVELOPMENTAL_A0.**

Documentos canônicos:

- `docs/products/160-emenda-01-protocolo-developmental-ovr01-dcbti.md`;
- `docs/products/161-micro-gate-autorizacao-persistencia-ovr01-dcbti.md`.

## 2. Freshness Gate desta retomada

O Freshness Gate identificou que o repositório já estava em CP69, apesar de a conversa ter sido retomada inicialmente a partir de referência anterior.

HEAD antes da Emenda 01:

`0284be1758f103e743df9b0cc88f5043efe9f83a`

Nenhum trabalho CP62–CP69 foi refeito.

## 3. Emenda 01

A Emenda 01 foi criada prospectivamente antes de qualquer persistência real do OVR-01.

Ela:

- aplica-se somente à rota developmental A0/A1;
- mantém C2 = BLOCKED / NOT_VERIFIED;
- permite Gao com `last_search_date=NULL`;
- exige `currentness_status='unclear'`;
- exige rationale explícita;
- proíbe inferência de data;
- preserva `MISSING_LAST_SEARCH_DATE` como publication error;
- mantém `publishable=false`;
- não altera a rota formal.

Documento 149 foi atualizado somente para apontar para a emenda, preservando sua história metodológica.

## 4. Verificação arquitetural

Migration 019 confirmada diretamente:

- `last_search_date` nullable;
- `currentness_status` admite `unclear`;
- rationale obrigatória quando currentness não é `current`;
- ReviewItem ativo sem last-search date gera `MISSING_LAST_SEARCH_DATE` com severity `error`.

Não é necessária migration corretiva para a Emenda 01.

## 5. Micro-gate

Resultado:

> **READY_TO_PERSIST_DEVELOPMENTAL_A0**

C1–C12 permanecem com seus estados documentados; C2 não foi reclassificado como PASS.

A autorização é estrita para:

- Question própria;
- Investigation própria;
- Product/ProductVersion `overview_of_reviews`;
- materialização rastreável de Nazari;
- ReviewItems Hwang/Gao/Nazari;
- memberships a partir da matriz canônica;
- overlap/CCA derivados pelo banco;
- assurance inicial A0;
- sem publicação.

## 6. Limites preservados

Ainda é proibido:

- inferir last-search date de Gao;
- calcular CCA manualmente;
- criar nova meta-analysis;
- colapsar comparadores indevidamente;
- marcar verificação humana inexistente;
- criar owner approval ou expert review;
- promover para A2/A3;
- publicar;
- alterar a rota formal.

## 7. Integridade

Até este checkpoint:

> **nenhuma entidade real OVR-01 foi criada.**

Commits materiais desta etapa:

- Documento 160: `cc1a2f32ba7289960a8637d241ef68a123017078`;
- referência da Emenda no Documento 149: `d8eb32fbc1ab8b1ed7b40f440fa6bc4510f589d0`;
- Documento 161: `b8df35a34f9613a12fa7783261c349c8d3c8893d`;
- índice de produtos: `99701bbad27da60cb8b579c2154d252ec9d41824`.

## 8. Ponto exato de retomada

> **Persistir de forma controlada o OVR-01 dCBT-I em A0; depois executar testes específicos, rebuild/regressões, validar memberships e overlap derivado, confirmar MISSING_LAST_SEARCH_DATE, renderizar via OverviewOfReviewsView e somente então realizar verificação metodológica adversarial antes de eventual A1.**

**Fim do CP70**
