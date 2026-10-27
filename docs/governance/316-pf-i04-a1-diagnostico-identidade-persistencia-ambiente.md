# PF-I04-A1 — Diagnóstico de identidade, persistência e ambiente do piloto

**Data:** 2026-10-27. **Status:** avaliação técnica documental, não aceite de implementação. **Base:** Documento 315; decisões 287–288; inspeção dos módulos Django vigentes na revisão `8e536d75db82e18a4cb8fece4c02289da11e4cda`.

## 1. Diagnóstico verificável

| Aspecto | Existe | Não demonstrado |
|---|---|---|
| Django Auth | Apps `auth`, `contenttypes` e `sessions`; `AuthenticationMiddleware`; `require_question_preparer` por permissão específica | Banco de contas/sessões ativo, provisionamento e revogação, login/logout privado, escopo real por pergunta |
| Q0 e Q1 | `QuestionCommand`, `OfflineQuestionUnitOfWork`, recibos; mapeamentos ORM unmanaged, SQL port injetável e ensaio conectado transitório anterior | Writer autorizado dentro do Django, commit durável do fluxo real, read-after-write e autenticação de aplicação |
| Q2 / roteamento | Projeção sintética offline; campos `question_type`, `structure_type`, `context_payload`, `time_horizon_payload` em `OesQuestionVersion` | Mapeamento canônico completo do Routing Record e operação transacional persistente; não deduzir compatibilidade só pelos campos |
| Ambiente | `DATABASES={}` por padrão e leitor PG-A4 opt-in somente leitura; `DEBUG=True` e segredo de desenvolvimento | Ambiente privado seguro com `DEBUG=False`, chave/credenciais geridas, hosts/CSRF/TLS, rotina operacional |
| Escrita ORM | `DjangoQ0Repository` contém mapeamento concreto, mas seu construtor bloqueia sempre | Ativação deliberada e autorizada; transação atomic e privilégios mínimos |
| CI | 201/201 testes Django PASS na CI 40535916973, composição sintética | Testes operacionais de login, autorização, recuperação e persistência no ambiente escolhido |

## 2. Dependências e decisão mínima de arquitetura

**Decisão candidata 1 — usuários:** reutilizar Django Auth, sem provedor IAM próprio. Antes de criar usuários, decidir onde residirão tabelas Django de contas/permissões/sessões, como será aplicado o ciclo de vida de contas administrativas e como a identidade Django se relaciona com `responsible_actor_id` e `created_by`. Não executar `migrate` no banco OES sem análise de isolamento e autorização. Manter `evidence.prepare_question` e controle de escopo por pergunta; não supor superuser como acesso implícito.

**Decisão candidata 2 — dados:** aproveitar `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e `investigation.question_command_receipt`. Primeiro verificar sem mutações (catálogo e documentação SQL) a representação completa de Q0/Q1 e capacidade de Q2/roteamento; só então definir diffs estritamente necessários. Preservar transação única, locking, versão esperada, checksum/fingerprint, idempotência, HOLD após resultado incerto e read-after-write autorizado.

**Decisão candidata 3 — ambiente:** primeiro ambiente privado do piloto, com segredo não versionado, `DEBUG=False`, ACL mínima e TLS, custo controlado e operação reversível. A configuração atual de desenvolvimento não deve ser publicada nem receber credenciais de writer por simples variável. O host experimental PG-A4 de leitura não se converte em writer. A decisão do Documento 287 permite uma identidade de aplicação de menor privilégio; não libera usar owner.

## 3. Menor incremento recomendável após aceite

**PF-I04-A2 proposto: integração funcional Q0 autenticada e durável**, com usuário preparador sintético/de teste em Django, registro Q0 privado e read-after-write do próprio registro, mantendo todas as rotas de escrita não habilitadas até aprovação específica. Não incluir simultaneamente Q1, Q2 e routing persistentes antes de comprovar integridade da primeira fatia. Não construir nova Unit of Work ou sistema de autenticação.

**Pré-condições para implementação:** aceite expresso do Documento 315 e deste contrato de execução; decisão sobre armazenamento Django Auth/sessões e vínculo ator→permissão; inventário read-only de tabelas/roles existentes; plano de transação e rollback e credenciais descartáveis; escolha de ambiente privado, requisitos de segurança e custos; autorização nominal de alterações de código/SQL/roles/ativação conforme cabível. Sem essas condições, manter o gate fechado.

## 4. Critérios candidatos de aceite

1. Preparador autenticado e autorizado consegue registrar Q0 sintético de forma durável e consultar exatamente a versão confirmada; outro usuário não consegue.
2. Mesmo `request_id` e fingerprint devolve o mesmo recibo; fingerprint divergente e versão obsoleta falham sem alteração.
3. Falha antes de commit produz rollback completo; resultado de commit incerto produz HOLD sem retry automático.
4. Estados `PREPARATORY_ONLY`, revisão não realizada e E9 bloqueado aparecem no readback; nenhuma rota factual ou pública mutante é aberta.
5. Ambiente privado com autenticação real, TLS/CSRF/segredos e logging sem payload sensível; plano de correção/retorno formal.

## 5. Limites de governança

Este parecer **não autoriza** implementação, migrations, `CREATE ROLE`, grants, SQL conectado, GitHub Secrets, HTTP write, deploy ou operação. PF-I03 permanece encerrado exclusivamente offline (201/201 testes). CP314 canônico; Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED. Revisar os requisitos diferidos na definição da stack completa, conforme Documento 288.
