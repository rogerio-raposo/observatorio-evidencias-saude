# OES — CP329 | Simplificação proporcional da governança técnica, PF-I04/P4 deferido

**Data:** 2026-10-28 (America/Recife)  
**Checkpoint anterior:** CP328, `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP328.md`.  
**Base do Freshness Gate pré-publicação:** `main` SHA `25c7c907eabdf83ee0ae23254ddaede0ceaccbd3`.  
**Status:** checkpoint documental da decisão expressa do responsável `APPROVED — OES / SIMPLIFICACAO_PROPORCIONAL_GOVERNANCA_TECNICA`. Sem autorização de operação conectada.

## 1. Mudança canônica desde CP328
- **Documento 362**, `docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md`, registra decisão **aprovada** de controles proporcionais ao risco para trabalho técnico futuro; preserva rigor científico e rastreabilidade.
- PF-I04/P4, enquanto **trilha autônoma de experimentação de roles**, fica **SUSPENSA/DEFERIDA**; não é declarada concluída ou aprovada no Neon. Evitar continuidade automática P4-A43 ou repetição integral de A41 sem hipótese funcional nova.
- Prioridade seguinte: **análise offline objetiva de permissões e integração Django–PostgreSQL**, reaproveitando contratos e provas existentes, para definir um teste sintético mínimo e mensurável. Nova autorização específica será exigida para operação conectada conforme escopo e risco.
- Credenciais sintéticas: menor privilégio, uma unidade de trabalho aprovada por credencial quando adequado, prazo curto e desativação/revogação controladas; não exigir correspondência de vencimento ao segundo histórico. Nenhuma senha em logs/chat/commits ou exposição pública.

## 2. Evidências técnicas preservadas e seus limites
- A37–A41: fontes e pareceres canônicos anteriores permanecem imutáveis em `archive/handoffs/oes/artifacts/P4-A38/`, `P4-A39/`, `P4-A40/`, `P4-A41/`; a execução GitHub Actions A41 [40631160589](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40631160589) foi `SUCCESS` em PostgreSQL 18 descartável, **não no Neon**.
- A42: preparadas três versões locais de consulta catalogal (sem execução SQL, sem promover versão a requisito) e parecer histórico. O endpoint DIRECT foi revalidado em metadados via consulta direta ao ID `ep-wispy-dream-b6021bw0`; a listagem geral de computes havia retornado HTTP 401, sem causa conclusiva.
- **A42 fontes integrais: NÃO PERSISTIDAS NO GITHUB neste checkpoint**. A transferência via integração foi bloqueada; preservar identidade e pendência sem afirmar upload:
  - `OES_PF-I04_P4-A42_BASELINE_NEON_CATALOG_READ_ONLY_CANDIDATE_HOLD.sql` — SHA-256 `2d3b98299db7ecf36026ff444e58f5672ef0a23ab8de6ee5c8298eb790ce753b`.
  - `OES_PF-I04_P4-A42_BASELINE_NEON_CATALOG_READ_ONLY_V2_REVIEW_HOLD.sql` — SHA-256 `360bb3f00e60c8ac2b4d20ff9b2c8b29dd557768d8a759db53824d1742ea6fd7`.
  - `OES_PF-I04_P4-A42_BASELINE_NEON_CATALOG_READ_ONLY_V3_STRICT_EXPIRY_HOLD.sql` — SHA-256 `158ee2171543770f58cad66d5320a71e1383fc59546d65e3d9a9bd1c02e686d4`.
  - `OES_PF-I04_P4-A42_REVISAO_FINAL_E_GATE_NOMINAL_PROPOSTO_HOLD.md` — SHA-256 `e9e99ab8ad049db10d2875b5b36e8391de359f8a9f8f9d635bcbd686836cc0f5`.
- Arquivos A42 continuam acessíveis como artefatos desta conversa, mas a recuperabilidade em uma conversa futura **não é garantida**. Se necessário retomá-los, conferir os SHA-256 antes de uso; o trabalho A42 não é necessário para o próximo passo funcional.

## 3. Proteções e gates NÃO modificados
- Fase 4: `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`. Marco B: `OPEN`; G2-P2B: `NO-GO`; E9: `NO-GO`; readiness: `NOT_READY`; PF-I04/P4 operacional: `NOT_AUTHORIZED`; Fase 5: `NOT_STARTED`.
- A32/A35 workflows continuam com job conectado em `if:false`; nenhum workflow conectado ativado; nenhuma mudança de grants/roles, segredos, credenciais, deploy, pagamento ou coleta factual.
- O documento 362 estabelece um **novo regime-alvo** de autorização por escopo/riscos, **não um gate operacional autoexecutável**. Enquanto não houver nova autorização explícita de escopo, os bloqueios específicos do CP328 permanecem vigentes, inclusive para SQL Neon de leitura.
- Associação histórica OID `155649` e os objetos Django permanecem intocados. Nenhum pesquisador real foi incorporado.

## 4. Continuidade
**Ponto exato:** na próxima instrução `Prossiga`, executar **uma análise offline de suficiência funcional Django–PostgreSQL**: consultar os diagnósticos existentes (p.ex. Documentos 347–361, CPs de demonstrador e Django), identificar privilégios necessários e efetivamente comprovados, e propor o menor teste integrado com critérios de aceite e recuperação; **sem executar conexão, SQL ou mutação** nessa atividade.

**Não reabrir sem nova justificativa:** ensaio A41 integral já PASS na fixture, A42 como trilha de revisão crescente, workflows A32/A35 e regras científicas. Se houver risco novo material, registrar em vez de assumir autorização.

**Ponteiro único:** `archive/handoffs/oes/README.md`; aplicar Freshness Gate e ler Documento 362 e este CP antes de retomar. CP329 é snapshot operacional; Documento 362 é canônico. Concluída publicação de CP, **parar até comando posterior do responsável**.
