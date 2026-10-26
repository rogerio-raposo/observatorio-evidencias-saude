# Documento 334 — PF-I02: política mínima de leitura e fronteira do writer

**Data:** 2026-10-26. **Estado:** `DESIGN_DECISION_ONLY / W2A_NO_GO_FOR_RUNTIME`. Base: CP302, Docs. 320, 323–333. Sem autorização para DDL, DML, papéis, GRANT, credenciais, SET ROLE ou HTTP.

## Decisão proporcional
**Piloto conectado inicial: um único preparador sintético controlado.** Isso limita o escopo do teste, mas **não substitui autorização no banco**. A autenticação da pessoa pertence ao Django; a identidade técnica compartilha uma conexão com direitos limitados. Não permitir perguntas reais, múltiplos preparadores, acesso público ou dados sensíveis até existir segregação por linha comprovada. O writer técnico NÃO deve ser `oes_sandbox_owner`, `oes_pg_a4_reader` nem qualquer papel E6.

## Política de autorização de leitura
- O serviço exige permissão `evidence.prepare_question` e uma identidade autenticada antes de abrir conexão. Identidade e escopo são derivados da sessão persistida e não de campos manipuláveis do POST.
- Registro Q0: confirmar ausência da identidade OES; consultar somente identificadores e metadados estritamente necessários. Consulta Q0/Q1 e replay: vincular ator e pergunta por política verificável e negar leitura cruzada inclusive quando há recibo idempotente anterior.
- Não confiar somente em `created_by`, `request_id`, senha do writer ou filtro Django para isolamento entre usuários: `SELECT` amplo no banco permite contornar o serviço se a credencial for comprometida.
- Para expansão multiusuário, escolher e provar **RLS com contexto de identidade não falsificável** ou API de funções SQL estritamente delimitadas, inclusive testes negativos de acesso cruzado. Não selecionar nem aplicar RLS global sem revisão de dependências e autorização DDL separada.
- Testes sintéticos com único preparador não podem ser promovidos automaticamente para uso humano ou prontidão científica.

## Matriz de privilégio mínimo para o candidato NOLOGIN W2a (somente design)
| Objeto | Privilégio candidato | Restrição |
|---|---|---|
| banco `oes_sandbox` | CONNECT | somente branch sintética |
| schemas `core`, `investigation` | USAGE | sem CREATE |
| `core.entity` | SELECT/INSERT | identidade Question; sem UPDATE/DELETE |
| `core.entity_version` | SELECT/INSERT; UPDATE de `version_status` e `valid_to` | sem UPDATE de autoria/IDs, sem DELETE |
| `investigation.question` | SELECT/INSERT | sem UPDATE/DELETE |
| `investigation.question_version` | SELECT/INSERT | sem UPDATE/DELETE |
| `investigation.question_command_receipt` | SELECT/INSERT | sem UPDATE/DELETE; recibos imutáveis |
| `investigation.investigation*`, famílias E6/produtos | nenhum | testes negativos obrigatórios |

**Risco remanescente:** SELECT de tabela em quatro objetos e ledger permite ver registros de outros preparadores; esta matriz NÃO é aprovação para LOGIN/runtime. Considerar privilégios por coluna ou funções delimitadas após implementar porta SQL e policy, sem ampliar o escopo. A função `core.assert_entity_type()` é SECURITY INVOKER, usa `core.entity` qualificado e tem EXECUTE por PUBLIC; manter o achado sem REVOKE automático. Não assumir que ausência de grants diretos garante negativa em memberships/funções.

## Sequência sem reabrir protótipos
1. Validar contrato SQL concreto e política de acesso mínima contra código W1/W1B e ledger já criado. Não repetir ensaios administrativos Q0→Q1.
2. Preparar autorização **W2a restrita a role NOLOGIN e grants** somente após revisão detalhada de grants efetivos e alcance sintético; nenhum LOGIN, credencial ou uso Django.
3. Prova negativa em sessão de role restrita, caso autorizada. `SET ROLE` não constitui teste de credencial independente.
4. Separadamente W2b: identidade LOGIN independente, armazenamento seguro de segredo e integração do adaptador, com sessão Django persistente.
5. Separadamente W3: testes conectados de idempotência, concorrência, isolamento, recibos e cleanup sintético. Só avançar para atores reais após policy comprovada.

## Critérios de HOLD
Qualquer permissão indireta não explicada, ACL de PUBLIC inesperada, ausência de segregação para escopo pretendido, uso do owner no runtime, rota HTTP exposta, DDL divergente ou credencial em log => HOLD sem ajuste silencioso. A inspeção existente confirma RLS ausente, função trigger revista e writer ainda inexistente. O ledger Doc.330 já foi criado na branch sintética e não deve ser recriado.

**Parecer:** `WRITER_MINIMAL_READ_POLICY_DEFINED / W2A_RUNTIME_HOLD`. Marco B aberto; E9 NO-GO; A3 ausente; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
