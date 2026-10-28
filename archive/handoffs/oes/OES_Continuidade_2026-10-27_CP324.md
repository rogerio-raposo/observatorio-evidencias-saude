# OES — CP324 | PF-I04/P4-A25–A27 — verificador v3 executado READ ONLY, baseline HOLD confirmada

**Data:** 2026-10-27. **Checkpoint anterior:** CP323. **HEAD base ao Freshness Gate de abertura:** `14bec7c4534dac21448eeab25b53476ed854b319` (`main` idêntica). **Natureza:** persistência documental de auditoria catalogal, sem autorização de mutações.

## 1. Destino e estado anterior
- Neon sintético: projeto `weathered-boat-65779510` (`oes-sandbox`), branch `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), database `oes_sandbox`, executor `oes_sandbox_owner`. Nenhuma utilização da branch de produção, nenhum dado factual de usuários/sessões/Q0 lido.
- `oes_runtime` já criado em P4-A13 com senha privada, LOGIN=true, INHERIT=false, sem poderes administrativos/memberships; **GRANTs Bloco A NÃO executados**. `oes_django_migrator` continua NOLOGIN, sem CREATE, proprietário das nove tabelas Django. Associação originária migrator→owner: OID `155649`, grantor `cloud_admin`, ADMIN=true, INHERIT=false, SET=false.
- Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED; nenhum pesquisador vinculado.

## 2. Fatos de P4-A25 a P4-A27
### P4-A25 — teste conectado v2/A23 falhou controladamente
- Após **autorização nominal exata**, submetida uma única consulta `WITH ... SELECT` do A23 SHA-256 `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7` no Neon sintético.
- PostgreSQL retornou **`ACL arrays must be one-dimensional`**, sem qualquer linha SUMMARY ou PASS/HOLD. Nenhuma repetição ou consulta adicional. Classificação `CONNECTED_VALIDATION_FAILED / HOLD`. Diagnóstico provável: `aclexplode` recebendo array ACL vazio de dimensão zero (particularmente `attacl` nulo com fallback vazio); causa específica NÃO isolada por ensaio independente.
- A23 continua preservado em CP323, inválido como candidato aprovado para novo teste sem outro gate; não sobrescrever a evidência.

### P4-A26 — verificador v3 corrigido DOCUMENTALMENTE
- Novo arquivo `OES_PF-I04_P4-A26_VERIFICADOR_V3_PUBLIC_ACL_HOLD.sql`, SHA-256 **`136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a`**, 429 linhas. Identidade diferente de A23; aprovação A25 não se transfere.
- Tratamento `CASE WHEN cardinality(ACL)>0 THEN ACL ELSE NULL::aclitem[] END` antes de `aclexplode` em tabelas, schemas, sequências e colunas, evitando arrays vazios com dimensão zero.
- CTE `actual_public_acl` e contagens/linhas individuais para grants com `grantee=0` (`PUBLIC`) nos schemas `oes_app`, `core`, `investigation`, nas 14 tabelas escopadas e suas colunas, e nas 8 sequências Django. `public` schema excluído intencionalmente da regra negativa; USAGE histórico de `public` não foi revogado.
- Nova política conservadora: **zero ACL PUBLIC no universo examinado**, sujeita a auditoria e sem revogação automática. Consulta ainda não é prova universal de isolamento; terceiros, funções, triggers, RLS, default privileges, TEMP, objetos fora do escopo e inventário fechado de colunas não são plenamente avaliados.

### P4-A27 — revisão estática e um SELECT conectado após nova autorização nominal
- A27 revisou a v3 sem executar; o responsável forneceu aprovação nominal da **única execução READ ONLY** do arquivo A26 SHA acima, com projeto/branch/db/executor explícitos e sem SQL mutante.
- Freshness Gate `main` idêntico ao CP323. Confirmada fonte local integral e o SHA-256 de **`136c41...`**; enviado **exatamente um** SELECT com apenas catálogos e funções de privilégios.
- Resultado técnico factual no Neon PostgreSQL 18: **execução SQL PASS**; o erro de ACL de A25 **não se reproduziu**. Retornadas **947 linhas**, sendo 1 SUMMARY + **946 checks**, sem truncamento aparente. Resumo reportou **`64 mismatches / 946 checks`**, `passed=false`, `overall_status=HOLD`; 882 checks conformes e 64 divergências. Contagem do SUMMARY conferida com número de linhas recebidas e total de detalhes falhos.
- **Distribuição exata das 64 divergências:** `column_privilege=39`, `table_privilege=11`, `table_acl=11`, `column_acl=1`, `schema=1`, `schema_acl=1`. Todas compatíveis com direitos Django pretendidos ainda não concedidos. Sem divergências em identidade, papéis, memberships, propriedade e inventário das 14 tabelas, 8 sequências, controles de grant option, ACL sequências e `PUBLIC` no escopo.
- Regra de `PUBLIC`: `public_grants_in_scoped_objects=0` (**zero concessões explícitas observadas no universo da v3**). Isso não significa ausência de privilégios de PUBLIC em todo o banco, não abrange schema `public`, nem estabelece análise geral de privilégios de terceiros.
- Interpretação correta: **`CONNECTED_SQL_VALIDATION_PASS / PRE_GRANT_BASELINE_HOLD_EXPECTED`**. A consulta executa e classifica corretamente a baseline atual; não aprova GRANT, isolamento geral, login Django ou escrita Q0. Nenhuma tabela de conteúdo de usuários/sessões/Q0 foi consultada, nenhuma DDL/DML/role/membership/GRANT/REVOKE/SET ROLE executada.

## 3. Artefatos originais preservados e integridade
Diretório GitHub: `archive/handoffs/oes/artifacts/CP324/`; todas as três fontes locais completas foram preservadas e os **Git blob hashes** verificados equivalentes aos originais. Arquivos:
1. `OES_PF-I04_P4-A26_VERIFICADOR_V3_PUBLIC_ACL_HOLD.sql`: SHA-256 `136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a`; Git blob `007cdab98854fe9878657db4993f81755731dfa2`.
2. `OES_PF-I04_P4-A26_NOTA_DE_CORRECAO_E_LIMITES.md`: Git blob `1d524d8e7c401fdd08785a52cb6163f66be50980`; identifica provável erro anterior e escopo.
3. `OES_PF-I04_P4-A27_PARECER_E_GATE_V3_READ_ONLY.md`: Git blob `1d7c3695705217674919d32edc4b890b50236e8b`; registra estado anterior à autorização e gate solicitado. **A execução conectada efetiva e seus resultados estão neste CP324**, cronologicamente posteriores ao parecer.
- Os ZIPs foram usados como empacotamento local; fontes integrais com integridade verificada são a referência persistente.

## 4. Fronteiras e decisões inalteradas
- P4-A19: SQL transacional original **SUPERADO, NÃO EXECUTAR**.
- P4-A21: transação administrativa v2 ainda **HOLD incondicional** e NÃO testada no Neon; não remover bloqueio. Postflight parcial A21 não equivale ao verificador A26; consulta A26 pós-GRANT jamais executada.
- A v3 executada não resolve atomicidade de concessão temporária com `SET LOCAL ROLE`, comportamento `GRANTED BY`, reversão grantor-aware, rollback/commit incerto, permissões de terceiros nem operação Django.
- Necessitam aprovação nominal separada: quaisquer mutações de role, membership, GRANT/REVOKE, SET ROLE, ALTER, atribuição de permissão a usuários Django, conexão/runtime, ensaios com sessão, Q0 e HTTP.
- Não repetir consultas A23/A26 automaticamente; cada novo teste requer seu próprio gate e a identidade exata do arquivo.

## 5. Ponto seguro de retomada
**PF-I04/P4-A28 (somente desenho/revisão documental):** avaliar lacunas residuais e viabilidade **não mutante** da sequência administrativa: provas de atomicidade/sessão única, concessão de membership por grantor e retirada `RESTRICT`, escopo de ACLs de terceiros, e proposta de experimento sintético isolado/rollback sob gate próprio. Evitar prolongar revisões sem progresso real; estabelecer uma decisão testável com critérios proporcionais. **Não iniciar GRANTs ou ensaio transacional conectado apenas por “Prossiga”.** Aplicar Freshness Gate e checkpoints 3–5 atividades ou por risco; uma atividade por “Prossiga” e STOP.
