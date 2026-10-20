# 132 — Modelo-alvo provisório de roles, propriedade de objetos e auditoria DDL independente

**OES — Fase 4 | 2026-10-19 (America/Recife) | modo alto**  
**Classificação:** STATIC_TARGET_SECURITY_MODEL_16_OF_16_TESTS_PASS — DESIGN_NOT_APPROVED — NO_NEON_WRITE — NO_PAID_SERVICES.  
**Entrada:** CP175, HEAD `0d81a9eff96ba545075c4bfe9c5071414f45510c`.

## 1. Continuidade e método

Freshness Gate CP175/`main`: `identical`, ahead=0, behind=0. Ponteiro em CP175 e checkpoint integral verificados. Documento 131, política canônica 30, manifesto de 36 migrations e matriz documental 034–036 examinados. O catálogo principal continua **36/36 `UNREVIEWED`**, sem pós-condições validadas nem autorização de replay, reconciliação ou execução.

O checkpoint desenha somente uma **arquitetura candidata**, sem aplicação de SQL, consulta a dados do Neon, criação de credenciais, configuração de logs, serviço pago, branch, backup ou migration. O modelo executável existente é um **linter documental fail-closed**, não mecanismo de autorização ou executor.

## 2. Conflito central de segurança

No PostgreSQL, o direito de alterar ou destruir um objeto é inerente à propriedade e não pode ser revogado com `REVOKE`. Um papel que seja proprietário de tabela/função protegida — ou que possa chegar ao proprietário por uma cadeia de membership/`SET ROLE` — pode modificar sua definição e, em condições apropriadas, interferir nos triggers. A opção de papel `NOLOGIN` não impede que um usuário autorizado por membership com `SET TRUE` passe a executar como a role. `INHERIT`, `SET` e `ADMIN` devem ser testados separadamente e em cadeias transitivas. Referências: https://www.postgresql.org/docs/18/ddl-priv.html ; https://www.postgresql.org/docs/18/role-membership.html ; https://www.postgresql.org/docs/18/sql-grant.html .

**Consequência:** não é tecnicamente correto prometer que um executor de DDL, temporariamente proprietário dos objetos-alvo, será incapaz de desabilitar os guards **somente por ACL**. O modelo propõe *elevação temporária, isolada, explicitamente autorizada e auditada externamente* para migrations revisadas, com inspeções antes/depois, e não uma falsa garantia de bloqueio absoluto durante a janela privilegiada. A solução de *fencing* e o supervisor de 36 migrations ainda precisam ser projetados e validados.

## 3. Seis papéis e respectivas fronteiras

| Papel conceitual | Acesso pretendido | Negativas/condições indispensáveis |
|---|---|---|
| **Schema owner** | Role sem login para possuir objetos versionados | Não compartilhar credencial; não conceder membership por padrão a runtime/CI; qualquer elevação exige decisão individual |
| **Runtime** | Credencial eventual com DML e `EXECUTE` estritamente necessários | Sem `CREATE`, DDL, propriedade, membership de owner ou `SET ROLE` de elevação |
| **Migration executor** | Processo isolado para aplicar **hash SQL aprovado** em janela delimitada | Sem elevação persistente; elevação exige autorização separada do titular, identidade forte, auditoria externa e pós-condições; não presume que ACL sozinha previne DDL destrutivo |
| **Audit reader** | Principal externo de leitura/verificação de logs e lacunas | Sem modificação de eventos, controle da retenção ou de configurações do produtor |
| **Backup operator** | Principal isolado para obter/restaurar cópia verificada em ambiente de teste | Não restaurar sobre canonical sem aprovação específica; não alterar logs nem apagar snapshots canônicos |
| **Break-glass admin** | Intervenção excepcional restrita ao titular e por tempo determinado | Sem token compartilhado na CI, sem acesso rotineiro e sem alterações não registradas |

Além disso, são **duas camadas independentes de autorização**: (A) permissões de organização/projeto e chaves de API no painel Neon; (B) roles, ownership e ACL do PostgreSQL. Uma permissão `Viewer` no projeto não define, por si, os privilégios de uma credencial SQL já distribuída, e uma role SQL restrita não limita automaticamente uma chave de gerenciamento Neon `Editor`. Documentação do modelo de permissões Neon publicada em 03/08/2026: https://neon.com/blog/neon-now-has-per-project-permissions .

Nenhuma role listada foi criada no Neon. Seus nomes são categorias arquiteturais e não decisões sobre usuários finais. A matriz estruturada formaliza seis perfis, 12 controles e suas restrições.

## 4. Auditoria: quatro alternativas não equivalentes

| Alternativa | O que cobre | Lacuna que impede aprovação |
|---|---|---|
| **Exportação de logs PostgreSQL pela Neon para OTLP** | Potencialmente logs de servidor para um coletor externo, conforme configuração e cobertura | Recursos divulgados no plano **Scale**; elegibilidade e custo no projeto Free não verificados pelo titular. Não habilitar nem assumir serviço gratuito |
| **Runs, commits e artifacts GitHub Actions** | Ações do controlador aprovadas e executadas em CI sintética, com hashes e logs | Não vê necessariamente qualquer SQL manual ou administrativo efetuado fora da CI; artifact com retenção não é log externo imutável e completo |
| **Event trigger interno com tabela de auditoria** | Pode registrar DDL bem-sucedido/confirmado no mesmo banco | Compartilha transação e privilégios privilegiados; o CP175 comprovou que o rollback elimina a linha de auditoria correspondente |
| **Coletor externo independente** | Objetivo: registrar tentativas, falhas/rollback, DDL confirmado, actor e alterações de controle, com recibos verificáveis e retenção independente | Nenhum mecanismo/provedor/custo/retention operacional selecionado, provisionado, testado ou aprovado |

Referências públicas verificadas em 2026: Neon log export https://neon.com/blog/logs-open-telemetry e descrição comercial https://neon.com/blog/why-we-no-longer-lock-premium-features ; consultar também a disponibilidade efetiva no console e os preços **somente antes de pedir autorização**. A consulta recente ao Neon sobre `neon logs` para Functions/Object Storage **não** autoriza inferir cobertura de DDL do banco PostgreSQL; https://neon.com/blog/query-neon-backend-logs . Não introduzir custo sem aprovação.

**Diretriz para continuar sem despesas:** aproveitar as provas gratuitas e descartáveis da CI como trilha de desenvolvimento sintético, sem tratá-las como substitutas da auditoria SQL independente exigida antes da operação persistente. Se não houver alternativa externa gratuita comprovada, **manter o gate bloqueado** e submeter ao titular escolhas de arquitetura/custo no momento apropriado.

## 5. Doze controles mandatórios — ainda NÃO comprovados

A matriz `docs/governance/security/f4-target-roles-external-audit-draft.json` reúne: (1) ausência de acesso de runtime à propriedade; (2) conflito entre DDL e ownership — **não resolvido**; (3) elevação temporária autorizada por migration; (4) trilha externa fora da transação; (5) segregação do administrador do log; (6) integridade, continuidade e recibos do log; (7) cobertura de ações diretas, falhas e rollback; (8) elegibilidade financeira e de funcionalidades Free; (9) separação do plano de controle Neon/roles SQL; (10) TLS/segredos/rotação; (11) backup/restore independente; (12) revisão humana especializada.

Todos estão em estados como `NOT_TESTED_NEON`, `NOT_CONFIGURED`, `UNRESOLVED_DESIGN`, `OWNER_CONFIRMATION_PENDING` ou `NOT_REVIEWED`. O formulário JSON usa `DENY_UNLESS_EXPLICITLY_APPROVED_AND_PROVEN` e `HOLD_NEON_WRITES_UNTIL_GATES_APPROVED`, incluindo proibições explícitas de serviços pagos, runner operacional, replay e alterações Neon.

Os controles não constituem cronograma de implementação nem decisão de arquitetura normativa; seu conteúdo deverá ser revisado por especialistas antes de promoção.

## 6. CI estática, resultado comprovado e escopo exato

Artefatos criados:
- `docs/governance/security/f4-target-roles-external-audit-draft.json`: matriz do modelo-alvo, seis roles, 12 controles, quatro opções de auditoria em estado bloqueado.
- `scripts/oes_f4_role_audit_target_lint.py`: verifica inconsistências de privilégios, tentativas de promoção, identidade do catálogo principal e integridade da matriz 034–036, sempre **offline**.
- `tests/test_oes_f4_role_audit_target_lint.py`: 16 testes (1 cenário positivo que confirma `draft`, 15 controles de mutação/falsificação).
- `.github/workflows/f4-role-audit-target-static.yml`: CI somente Python 3.13, `contents:read`, checkout sem credenciais persistentes, paths restritos, nenhum PostgreSQL ou acesso externo.

**Run:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39361692980  
**Job:** `118429107779`; `completed/success`.  
**Commit fixado:** `fd75b3a41a1cdf9fe23ec1cb2626bb349efdd431`.  
**Log:** `Ran 16 tests`, `OK`; `ROLE_AUDIT_MODEL_DRAFT_ONLY_BLOCKED_NOT_AN_OPERATIONAL_PASS`.

Artifact `f4-role-audit-target-draft-only`, ID `12236864111`, ZIP recuperado com `testzip()=None`. SHA-256 ZIP `d91577ca76868f4612eda88a5a6cb7c9083d243f12afd5574b1490133a8e902c`, correspondente ao digest do GitHub. `status.json`: 6 roles, 12 controles, 4 opções, 36 migrations bloqueadas e 36 requisitos ainda não coletados. SHA-256 de `status.json` `1a4795c8ab9604eb87e7f1f14d02120333c79c2e258104511bb5b16b13af0c1e` confere com recibo interno. Nenhum SQL executado e nenhuma configuração de log ou serviço pago realizada.

**A CI prova somente que o modelo documental está consistente e permanece bloqueante.** Não prova viabilidade operacional no Neon Free, completude de auditoria, capacidade de migrar com privilégios mínimos ou invariantes científicos.

## 7. Gates e próxima atividade

- `BRG-03`: prova ACL/DDL **somente PG18 descartável** no CP175; propriedade/elevation/log externo/TLS/Neon ainda não verificados.
- `BRG-06`: ledger operacional ausente.
- `BRG-07`: supervisor, fencing e runner operacionais não aprovados.
- `BRG-08`: backup e restore independente ausentes.
- `BRG-09`: conferência billing/consumo pelo titular pendente.
- Catálogo das migrations 001–036: **36 `UNREVIEWED`, 0 pós-condições aprovadas**; matriz 034–036: **36 requisitos não coletados**.
- `BRANCH_AUTHORIZATION=PREPARED_NOT_APPROVED`; `NEON_TEST_BRANCH=NOT_CREATED`; `NEON_SCHEMA_MIGRATION=NOT_STARTED`; `B1R1=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

**Proposta para próximo checkpoint:** ensaio PostgreSQL 18 **estritamente descartável** com identidades `LOGIN` separadas, testes negativos de membership `SET/INHERIT/ADMIN`, simulação de elevação do migrator para owner e entrega de evidências externas à transação com lacunas/falhas artificiais. Não transformar simulação de log externo em garantia do Neon. Manter modo alto para privilégios, auditoria e custo.

**Fim do Documento 132.**