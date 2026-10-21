# OES — Continuidade CP225

**2026-10-21 | checkpoint anterior CP224 | HEAD pré-registro `5794864cb2bc3093fb741813a6e88e3fccc4835e`**

## Marco
Documento 200 registra decisão do proprietário de criar um **novo projeto Neon exclusivamente sintético**, e a criação efetiva e verificada de `oes-d1-t2-a2-synthetic` (ID `tiny-pond-20086371`), plano Free, São Paulo, PostgreSQL 18, branch `synthetic-main`, banco `oes_t2a2_synthetic`. Projeto `oes-sandbox` original não foi alterado. A criação inicial com parâmetro não permitido de suspensão falhou HTTP 412, sem criar recurso; a repetição sem tal parâmetro foi bem sucedida.

## Advertências técnicas e de segurança
Endpoint inicial read_write estava ativo na verificação; `block_public_connections=false`, lista de IPs vazia, branch primária não protegida e suspensão `0` definida pelo plano. **Sem alegar que isso é seguro para uso, que há scale-to-zero, ou que inexistirão custos**. Plano `free_v3` verificado, consumo momentâneo mínimo. Nenhuma inspeção de registros, credenciais ou schema, nenhum SQL executado, nenhum dado T2-A2 inserido. Sem testes novos e sem promoção de gates.

T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 testes históricos), T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 históricos), **T2-A2 `NOT_AUTHORIZED`**. P2-C1 local e demais permissões de adaptação/SQL não aprovados. Preservar semânticas T1/T2-A1 e bloqueios de migrations, papéis, BRGs, Fases 4/5.

## Ponto exato de retomada
Após novo `Prossiga`, uma única atividade de **análise e proposta de autorização de segurança/custos para o projeto Neon novo**, usando metadados somente leitura e separando operações que exigem aprovação; sem SQL, criação de tabelas, roles, alterações de rede/branch ou desenvolvimento T2-A2. Freshness Gate. STOP.
