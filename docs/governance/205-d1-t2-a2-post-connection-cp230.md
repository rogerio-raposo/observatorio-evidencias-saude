# Documento 205 — D1/T2-A2: fronteira PostgreSQL pós-conexão e revisão adversarial (CP230)

**2026-10-22 | DOCUMENTARY_CANDIDATE_REVISED | REVISE_BEFORE_IMPLEMENTATION_AUTHORIZATION | T2-A2 NOT_AUTHORIZED**

## 1. Contexto e fonte
Consolidação documental A1 (fronteira pós-conexão), A2 (modelo físico e autorizações) e A3 (revisão adversarial), após CP229. Fontes: Documento 197, Documentos 200–204 e código/testes existentes de `prototypes/d1/` e `prototypes/d1_t2/a1/`. T1 = `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 PASS históricos) e T2-A1 = `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 PASS históricos incluindo T1). **Nenhum teste ou operação PostgreSQL nesta consolidação.** Não é autorização de implementação.

## 2. Fronteira de infraestrutura
Projeto Neon Free `oes-d1-t2-a2-synthetic`, ID `tiny-pond-20086371`, branch `synthetic-main`, banco `oes_t2a2_synthetic`, PostgreSQL 18, independente de `oes-sandbox`. Papel `oes_t2a2_app` existente, restrito e sem concessões de escrita T2-A2. Papel anterior `oes_t2a2_runtime` excessivamente privilegiado e proibido de uso; N1-D2 não concluído. N1-E3 comprovou conexão de cliente Psycopg/verify-full e autenticação apenas nos limites externos (run 39737616716), enquanto `pg_stat_ssl.ssl=false` foi observado no backend; **não declarar TLS ponta a ponta até PostgreSQL**. Não modificar Data API, rede, papéis ou infraestrutura.

## 3. Esquema candidato — SEM SQL/DDL
Namespace isolado candidato `oes_t2a2_proto`:
| Tabela | Campos candidatos | Invariantes previstas |
|---|---|---|
| `scenario` | `scenario_id TEXT`, `revision BIGINT`, `state JSONB`, `synthetic BOOLEAN` | PK scenario_id; revision positiva e monotônica; synthetic TRUE; estado não nulo |
| `event` | `scenario_id TEXT`, `sequence BIGINT`, `kind TEXT`, `payload JSONB` | PK (scenario_id,sequence), FK scenario, sequence positiva, payload não nulo |
| `receipt` | `scenario_id TEXT`, `request_id TEXT`, `fingerprint TEXT`, `response JSONB`, `revision BIGINT` | PK (scenario_id,request_id), FK scenario, revision positiva, fingerprint não vazio |
Tipos, nomes, CHECKs, NULLs e índices permanecem candidatos sujeitos a revisão e aprovação específica. Não instalar migrações históricas, outras tabelas, funções de domínio, triggers de workflow, API pública, RLS ou log externo. O marcador synthetic é declaratório, não prova de origem.

## 4. Transação, consistência e contrato legado
Manter cinco comandos Python: `create_scenario`, `start_cycle`, `register_signal`, `record_assessment`, `close_cycle`. Por comando futuro: abrir transação, resolver proteção/conflito de cenário, consultar recibo/fingerprint, ler estado e eventos na mesma visão consistente, executar domínio Python em cópia isolada, gravar cenário + único evento + recibo na mesma transação ou reverter integralmente. `READ COMMITTED` com lock de linha e verificação de revisão é **candidato não aprovado** para escrita em cenário existente; leituras independentes/replay exigem snapshot coerente, possivelmente `REPEATABLE READ`. Criação concorrente de linha inexistente exige chave única, captura correta de colisão e nova avaliação de recibo, sem presumir lock de linha ausente.
O estado JSONB contém eventos e há tabela `event` separada: a correspondência deve ser demonstrada, com `scenario.revision` e sequência final alinhadas e `receipt.revision` igual à revisão do comando. Replay deve detectar divergência. Fingerprint segue codificação Python existente, não hash arbitrário de JSONB. `create_scenario` repetido com request/payload iguais retorna **snapshot corrente**; outros comandos retornam resposta original; payload divergente com mesmo request rejeitado sem efeito. Preservar `pending` sem segunda avaliação do sinal, diferenças intencionais `RepositoryConflict`/`DomainError`, conclusão científica sintética e baseline imutáveis e quatro estados de projeção distintos.
Perda de conexão durante COMMIT implica resultado **indeterminado** até reconciliação por recibo; ausência imediata de recibo não comprova rollback. Não declarar segurança multiusuário, durabilidade de desastre, trilha inviolável ou equivalência à View SQL científica.

## 5. Permissões candidatas — SEM GRANT
Owner/administrador técnico separado, identidade a confirmar mediante privilégios efetivos; não presumir `oes_t2a2_owner` habilitado para criação/GRANT. `oes_t2a2_app`: USAGE exclusivamente no namespace, SELECT/INSERT nas três tabelas, UPDATE apenas em scenario; **sem** DELETE, TRUNCATE, CREATE/ALTER/DROP, poderes administrativos, membership elevada, UPDATE em event/receipt ou concessão a terceiros. Verificar ACL real de PUBLIC, heranças, ownership e default privileges antes de qualquer proposta operacional. Acesso SQL arbitrário mesmo sob ACL restrita pode corromper lógica; o modelo de ameaça é somente experimento controlado com dados fictícios. Não alterar `oes_t2a2_runtime`, `authenticator`, `anonymous`, `authenticated` ou Data API.

## 6. Revisão adversarial A3
| ID | Severidade | Bloqueio e correção exigida |
|---|---|---|
| F01 | CRITICAL | `bridge.py` lê log via repositório fora da UoW; garantir mesma visão transacional de cenário/eventos/recibo e replay |
| F02 | HIGH | Lock de linha não protege criação inexistente; tratar unicidade e colisão preservando idempotência/exceções |
| F03 | HIGH | Duas representações de eventos podem divergir mesmo na mesma transação; especificar revisão/sequência/recibo/replay |
| F04 | HIGH | Commit com desconexão exige reconciliação por recibo e estado indeterminado, nunca rollback presumido |
| F05 | HIGH | ACL sozinha não garante integridade semântica contra escrita SQL arbitrária; explicitar ameaça e conferir ownership/PUBLIC |
| F06 | MODERATE | Fechar NOT NULL, positividade, tipo JSONB e checks de chaves; synthetic TRUE não garante dado fictício |
| F07 | MODERATE | Documento 197 propôs PostgreSQL local; Neon atual é ambiente candidato provisionado sob autorizações posteriores, sem permissão geral de operação |
Resultado **REVISE_BEFORE_IMPLEMENTATION_AUTHORIZATION**. Fechar F01–F07 primeiro documentalmente, depois comprovar hipóteses apenas sob autorizações de execução separadas.

## 7. Testes futuros (NÃO EXECUTADOS)
P01 reinício do processo/durabilidade; P02 rollback pré-commit; P03 idempotência e request conflitante após reinício; P04 criação simultânea; P05 concorrência de atualizações; P06 replay e divergência de log; P07 commit incerto e reconciliação; P08 regressão integral T1 36 + T2-A1 39 e testes diferenciais; P09 controle de acesso e descarte. Não confundir reinício de aplicação e indisponibilidade de servidor/rede/armazenamento. Critérios E01–E12 do Documento 197 mantidos como requisitos candidatos, não pós-condições aprovadas.

## 8. Autorizações futuras independentes — NÃO CONCEDIDAS
`A2-G1` aprovação do desenho físico/semântico apenas; `A2-G2` criação de namespace e objetos mediante preflight/escopo preciso; `A2-G3` GRANTs mínimos após verificação ACL/owner; `A2-G4` implementação/publicação de adaptador experimental isolado; `A2-G5` testes SQL/CI, local/remoto, após autorização específica; `A2-G6` parecer de encerramento técnico restrito, sem promoção científica/operacional. Nomenclatura auxiliar **não cria gates oficiais**. Proibir sem autorização: SQL, DDL, DML, GRANT, CI, novas conexões, infra, preços/planos, serviços pagos, dados reais, PubMed/ClinicalTrials, APIs ou implantação. Freshness Gate antes de intervenções; exigir isolamento, custo, rollback e descarte. STOP ante alterações de HEAD, privilégios indevidos, custo possível, dados factuais ou violação de contrato.

## 9. Continuidade
T2-A2 `NOT_AUTHORIZED`, Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`; gates íntegros. D0 documental/editorial concluído → D1 sintético funcional prioritário → D2 factual futuro → governança completa. **Próxima atividade exclusivamente documental:** fechar F01–F07 com contrato/oráculos detalhados antes de eventual deliberação A2-G1; não avançar automaticamente. STOP.
