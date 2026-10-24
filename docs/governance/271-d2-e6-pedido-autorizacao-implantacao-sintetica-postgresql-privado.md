# Documento 271 — Pedido de autorização restrita para implantação sintética do armazenamento privado D2-E6

**OES — 2026-10-24 | Referências: Documentos 269 e 270, CP273 | HEAD da proposta: `016b44f138cb3c4073ca370d1341dd24db9a7959`**  
**Status: `PROPOSAL_ONLY / OWNER_APPROVAL_PENDING / NO_SQL_EXECUTION / E6_G1_BLOCKED`.**

## 1. Decisão solicitada
Autorização **separada e específica** para uma implementação controlada de **armazenamento privado apenas com dados sintéticos** na branch Neon experimental `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`, database `oes_sandbox`. A autorização, se concedida, abrangerá exclusivamente: esquema `oes_raw_private`, uma tabela `source_observation` baseada no Documento 270, papéis de aplicação de menor privilégio, grants explícitos e testes sintéticos/negativos. Não abrange captura factual, SQL de dados reais, publicação pública, workflow factual, criação de projeto, serviços pagos ou migração para object storage.

## 2. Pré-condições obrigatórias antes de qualquer mudança
1. Freshness Gate do HEAD do GitHub e revisão do DDL proposto, sem desvio de escopo.
2. Preflight de catálogo do branch escolhido, conflitos, privilégios efetivos, propriedade e `ALTER DEFAULT PRIVILEGES`; snapshot das condições das fixtures PG-A4 e seus grants.
3. Aprovar detalhamento executável dos papéis com credenciais operacionais separadas e sem exposição de segredos em logs/documentos. **Não conceder ao writer `SELECT`, `UPDATE`, `DELETE`, `CREATE` ou papel proprietário.**
4. Plano reversível de migração com rollback explícito para objetos novos, sem `DROP` ou `REVOKE` em objetos existentes, sem tocar a branch primária.
5. Escolher testes com payloads inequivocamente sintéticos de até 2 MB; validar digest calculado sobre bytes sem reserializar JSON.
6. Checar se o acesso negativo pode ser efetivamente exercitado com papéis distintos e não apenas estimado pela visão administrativa.

## 3. Plano de aceitação sintética
- Um insert sintético autorizado, `octet_length` e SHA-256 conferidos antes e após recuperação sob identidade segregada.
- Negação de acesso ao novo esquema/tabela para `oes_pg_a4_reader`, `PUBLIC` e escritor onde não seja necessário; negar escrita ao papel verificador.
- Inserção repetida, tamanho acima do limite, dados incompletos e erro de integridade devem falhar fechados, sem linha residual.
- Confirmar ausência de bytes brutos em logs e artifact GitHub e ausência de alterações nas fixtures PG-A4, objetos anteriores e grants.
- Registrar testes e evidência técnica apenas com metadados não sensíveis, com STOP obrigatório diante de qualquer falha.

## 4. Fronteiras e operação futura
A decisão de armazenar os bytes em `bytea` é **restrita ao piloto**, sem obrigação de manter o JSON bruto no PostgreSQL na produção; deverá permanecer possível migrar para object storage privado, com verificação de integridade e continuidade de proveniência. Retenção sem prazo numérico universal: preservar até encerramento documental e decisão explícita sobre manutenção/descarte.

O arquivo `.github/workflows/d2-e6-a2-gated-capture.yml` continua com job `if: ${{ false }}`, e **não deverá ser desbloqueado** por esta autorização. O plano histórico de artifact público com JSON bruto foi superado pela política do Documento 269.

## 5. Forma sugerida para deliberação
`APPROVED — OES / D2-E6 / PG_RAW_SYNTHETIC_ONLY_SCHEMA_ROLES_AND_TESTS / branch br-gentle-hall-b6jaxehf / no factual GET / no public JSON / no paid services / fail closed`

**Esta redação é sugestão de autorização, não uma autorização emitida.** Implementação futura deverá usar o gate e a análise técnica do momento da execução; se houver mudança material de modelo de privilégios, apresentar revisão antes de executar.

**STOP — aguardando aprovação explícita do proprietário.**
