## CP344 — Django–Q0 rollback sintético: prontidão offline, execução HOLD (2026-10-29)

- [CP344](archive/handoffs/oes/OES_Continuidade_2026-10-29_CP344.md) é o checkpoint operacional vigente; [Actions 40964845881](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40964845881) **303/303 PASS offline** (SHA `d4a02a64f3ccd111d6b3dc344cd25222104c808c`); atestação conectada **somente leitura** da identidade sintética [40962343481](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40962343481) PASS.
- Composição interna da identidade persistida → trial sintético → cinco INSERTs ORM na transação com ROLLBACK obrigatório → leitor independente de resíduos preparada e testada offline. CLI `scripts/q0_manual_rollback_trial.py` publicado, mas workflow de ensaio conectado mantém `if: false`. **Nenhum INSERT conectado sob a autorização atual; autorização de um único ensaio rollback-only não consumida.**
- Decisão de simplificação proporcional: não usar marcador Git de consumo, rulesets, novos microgates ou terceiro executor. Retomar pela revisão final objetiva e integração controlada do CLI ao workflow manual (SHA fixado, credenciais existentes verificadas sem divulgação e nenhum retry). Marco B OPEN; executor Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED; produção intocada. Histórico anterior abaixo, não confundir com estado vigente.

## CP340 — Leitor Django conectado READ ONLY validado (2026-10-29)

- [CP340](archive/handoffs/oes/OES_Continuidade_2026-10-29_CP340.md) vigente. Workflow manual leitor [40877254997](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40877254997) SUCCESS no `b44278b1`: Django `oes_synthetic_reader`, usuário `oes_pg_a4_reader`, banco `oes_sandbox`, `default_transaction_read_only=on`, `transaction_read_only=on`, USAGE/SELECT nas cinco tabelas ORM Q0, sem INSERT/UPDATE/DELETE nessas tabelas. ACL de leitor foi corrigida apenas com USAGE em investigation e SELECT nas três tabelas Q0 desse schema; escritor já tinha SELECT/INSERT em todas as cinco. Configuração de papel `default_transaction_read_only=on` persistida; conexão Neon MCP anterior estava reutilizada. Não extrapolar ACL a todo o banco.
- Secret `OES_PG_A4_READER_PASSWORD` **não excluído por decisão expressa do usuário**; pode permanecer para ensaios de leitura recorrentes mediante auditoria proporcional do escopo geral e dos acessos/validade da credencial. Não afirmar que houve renovação/rotação; nenhuma senha em documentos. Credenciais temporárias writer/admin continuam sob descarte/revogação.
- Blueprint Django Q0 dormente `5103f9b7`, `d4983342`, `0f4135a2`; CI offline [40873846271](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40873846271) **257/257 PASS**. `execute_connected_q0` e `DjangoQ0Repository` HARD HOLD; sem commit real, sem prova de auth integrada ou reconciliação interprocessos. Próximo: revisão material dos requisitos de writer Django e gate nominal mínimo; não criar mocks/ledger novo nem repetir validação do leitor. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## CP339 — Q0 Django offline e controle pós-transação (2026-10-29)

- [CP339](archive/handoffs/oes/OES_Continuidade_2026-10-29_CP339.md) vigente. Commits `1023b7fc`, `6230f481`, `806b559a`, `a60ce72b`, `c6bded68`, `924583c4`, `732bfc09`, `40ae2141`: argumentos e verificador readback injetado, retenção de IDs após falha de readback ou saída transacional. CI [40872403076](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40872403076) **257/257 PASS offline**.
- Resultado incerto somente em memória não comprova commit nem recuperação interprocessos; exigir reconciliação por recibo persistido com leitor independente antes de qualquer retry. `DjangoQ0Repository` e `execute_connected_q0` HARD HOLD. Próximo: composição mínima Django autenticado → Q0 → commit → readback, com gate nominal. Marco B OPEN, ciência pendente, E9 NO-GO, Fase 5 NOT_STARTED.

## Marco B / Bloco A — revisão da composição executável mínima (2026-10-29)

- Revisão no HEAD `e3498c84`, sem conexão ou execução. Ponto de entrada autenticado existente: `submit_authenticated_question_command` usa `persisted_preparer_actor_id` no alias Django `default`; exige verificar configuração real do auth store e usuário sintético persistido. `OfflineQuestionUnitOfWork` já coordena lock, idempotência, Q0 e recibo; reutilizar, não duplicar.
- `DjangoQ0Repository.__init__` e `execute_connected_q0` seguem HARD HOLD. `_rollback_recipe` força rollback e **não serve** como executor de commit. A montagem futura exigirá revisão nominal específica de writer alias, privilégios e fronteira `transaction.atomic`, com uma instância de port por comando.
- `DormantQ0OrmPort` aceita factories injetadas e mantém `last_completed_q0`/`last_uncertain_q0` mutáveis apenas em memória. Não oferecer garantia de commit, isolamento interprocessos ou retry seguro a partir desses atributos. No pós-commit, readback pode falhar sem desfazer dados já gravados; conservar HOLD e reconciliar via recibo persistido em leitor independente. Ausência de recibo por leitura isolada não basta para declarar rollback.
- Para proposta nominal conectada: demonstrar (1) identidade/perm Django persistidas, (2) configuração isolada e comprovada de aliases/ACL no mesmo branch/banco, (3) Q0 única com cinco INSERTs/recibo numa transação, (4) commit verificável e readback independente, (5) idempotência e reconciliação sem segundo INSERT nem DELETE, (6) apresentação sintética Django. Reaproveitar evidência [40695250735](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40695250735) da persistência Q0 histórica, que não equivale ao novo fluxo autenticado.
- Não autorizar execução por este registro. Sem Neon DML/DDL, secrets, configuração writer, workflows conectados, HTTP write, custos ou mudança de gates. CI offline [40870702644](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40870702644) 256/256 PASS; CP338 vigente; Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## Marco B / Bloco A — recuperação de resultado incerto sem novo ledger (2026-10-29)

- Revisão de suficiência no HEAD `924583c4`; CI offline [40870702644](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40870702644) 256/256 PASS. `last_uncertain_q0` é apenas memória da instância e **não** mecanismo durável entre processos. Não presumir que HOLD após readback implica rollback.
- Decisão técnica preparatória: reutilizar `investigation.question_command_receipt` e quatro registros Q0 relacionados para reconciliação independente READ ONLY. Localizar tentativa por ator/request_id, conferir fingerprint e comparar IDs, versão e conteúdo dos cinco registros. Recibo encontrado e correspondência integral são evidência de persistência; qualquer ausência, parcialidade, erro ou incongruência permanece INDETERMINADO/HOLD, sem retry automático ou DELETE compensatório. Para distinguir rollback efetivo de tentativa ainda em trânsito, exigir contexto de execução e fronteira transacional verificáveis; leitura isolada ausente não basta.
- Preparação posterior: configuração temporária nominal por comando autenticado, credenciais e aliases independentes no mesmo projeto/branch/banco, privilégio mínimo, snapshot do legado e caminho de reconciliação pós-falha. Nenhuma ativação autorizada nesta decisão; `execute_connected_q0` e `DjangoQ0Repository` HARD HOLD. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. CP338 ainda vigente.

## CP338 — validação Django Q0 offline e próximo gate integrado (2026-10-29)

- Checkpoint [CP338](archive/handoffs/oes/OES_Continuidade_2026-10-29_CP338.md) vigente; commits `8bbfa78a`, `d6cbd82c`, `065b6c5c`, `c8183ff6`, `befdfe82`, `16a18407` adicionaram verificador positivo dormente, metadados candidatos e testes de rollback/readback sem ativação. GitHub Actions [40862416668](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40862416668) SUCCESS, 253/253 offline; duas execuções anteriores falharam e foram corrigidas.
- Contrato `PREPARATORY_ONLY`, `execute_connected_q0` e construtor de `DjangoQ0Repository` permanecem HARD HOLD. Não atribuir resultado de commit ao metadado `last_completed_q0`. Reutilizar evidência histórica de Q0 sintético com commit [40695250735](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40695250735), sem confundir com novo port ORM autenticado.
- Próximo ponto: proposta nominal proporcional para fluxo Django-auth persistido → Q0/recibo → commit autorizado → readback independente → apresentação, sem execução conectada antes de aprovação específica. Marco B OPEN, validação científica pendente, E9 NO-GO, Fase 5 NOT_STARTED.

## Decisão de escopo do Marco B — encerramento técnico-demonstrativo restrito (2026-10-29)

- **Decisão expressa do responsável:** orientar o futuro encerramento do Marco B ao **escopo técnico-demonstrativo restrito**, mantendo **validação científica externa pendente**, sem pesquisadores vinculados. Isto **não declara encerrado o Marco B neste momento** e não modifica retroativamente o Documento 294 ou o Marco A.
- Reconciliação com Documento 294: critérios P3-S01–S06 fundamentaram a suficiência **do Marco A**; Marco B deve comprovar sua própria integração funcional. Priorizar Django First: (A) autenticação/identidade e persistência Q0 integrada; (B) readback, apresentação e integridade ponta a ponta, reutilizando evidências prévias; (C) confronto de aceitação e declaração formal do encerramento restrito, se suficientes. Não impor repetição literal de P1 dinâmico quando a funcionalidade integrada equivalente for demonstrada.
- **Critérios propostos de aceite técnico do Marco B (a verificar, não aprovados como PASS):** autenticação e autorização Django sintéticas; vínculo persistido de preparador/ator; transação Q0 e recibo em PostgreSQL com comportamento de rollback, rejeição e repetição/conflito; readback e apresentação Django; proveniência, limites e rastreabilidade; verificação documental final. A prova de rollback-only isolada **não** equivale ao fluxo persistente integral.
- **Diferimentos expressos:** pesquisadores e revisão científica, captura factual, stack e readiness de produção, deploy e uso público. E9 NO-GO; Fase 5 NOT_STARTED; Marco B permanece OPEN. A decisão de escopo **não autoriza** Neon SQL, DML/DDL/GRANT, secrets, mudança de roles, workflows conectados, HTTP write, custos ou promoção científica. Documento 362 aplica governança proporcional e evita microgates e redundância.
- Evidência de base: Documento 294 (P3-R01–R11, S01–S06), CP289, CP337 e Documento 362. **Próximo:** retomar pendência técnica Django ORM Q0 do CP337, sem abrir uma nova frente documental.

## CP337 — PF-I03 Q0 Django First (2026-10-29)

- Checkpoint [CP337](archive/handoffs/oes/OES_Continuidade_2026-10-29_CP337.md) vigente. A1–A4: revisão de suficiência Django ORM existente; reconciliação separada READ ONLY adicionada em `23afaadb`; callback movido para dentro do fechamento `finally` em `79bd9c68`. Modificações de código verificadas estaticamente, **sem CI posterior nem execução conectada**.
- Executor e construtor ORM continuam HARD HOLD; configuração científica existente é somente leitura, sem alias escritor autorizado. Identidade UUID4 sintética não comprova ator Django; preservar Q0 legado. A revisão futura deve examinar fronteiras de transação, isolamento de credenciais, privilégios e teste mínimo conectado **somente após gate nominal independente**.
- Marco B OPEN; E9 NO-GO; Fase 5 NOT_STARTED. Documento 362 e Django First preservados; nenhuma autorização de DML, DDL, GRANT, HTTP write, deploy ou ciência real.

## Pos-CP336: separacao do executor Q0 e reconciliador (2026-10-29)

- Revisao arquitetural apenas, sem DML: executor Django ORM temporario (papel oes_qprep_login, alias oes_qprep_trial, cinco INSERT na mesma transacao, rollback obrigatorio, sem commit) e verificador PostgreSQL independente (outra sessao, credencial de leitura separada, SELECT somente). Os dois operam no mesmo banco oes_sandbox e branch br-gentle-hall-b6jaxehf; nenhum deles pode habilitar HTTP.
- Sequencia futura: snapshot READ ONLY de identificadores e baseline da Q0 legada; uma tentativa autorizada de escrita sintetica com rollback; sessao de leitura separada prova ausencia de residuos por cinco tabelas e preservacao do legado. Divergencia ou impossibilidade de verificacao leva a HOLD, sem retry nem DELETE compensatorio. Contagens globais isoladas nao comprovam isolamento quando ha concorrencia.
- Pendencias: repositorio e entrypoint ORM continuam HARD HOLD; configuracao existente e somente de leitura; nao existe configuracao executora aprovada; formato UUID4 sintetico nao prova identidade Django persistida. Exigir gate nominal de DML depois de revisao tecnica. Nao criar nova camada de persistencia.
- CP336 vigente; Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## CP336 — checkpoint de continuidade ativo (2026-10-29)

- Checkpoint [CP336](archive/handoffs/oes/OES_Continuidade_2026-10-29_CP336.md) ativo; ponteiro atualizado em `archive/handoffs/oes/README.md`. PF-I03 Q0: sessão Django READ ONLY conectada PASS; rollback após exceção exercitado com fakes offline PASS; repositório e executor ORM conectados continuam HARD HOLD. Secret temporário declarado excluído. Próximo: revisão de configuração transacional e ativação controlada antes de solicitar gate DML independente. **Marco B OPEN; E9 NO-GO; Fase 5 NOT_STARTED.**

## PF-I03-Q0 — revisão de falha transacional comprovada offline (2026-10-29)

- Commit `202eb34c135f6c7ed7260ae4a93d49981536baea`: `transaction.set_rollback(True)` precede o callback de fase opcional. Commit `486356dffb531878908fda26df3677f69fd2eab7`: teste simula falha transacional com mocks e verifica rollback, fechamento, cinco consultas de resíduos e HOLD após reconciliação; CI [40819580824](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40819580824) SUCCESS.
- Limite: teste sintético não comprova rollback PostgreSQL real; repositório ORM e executor conectado continuam HARD HOLD. Falta revisão e liberação nominal da configuração transacional do executor, credencial efêmera e eventual reconciliação externa independente. Sem Neon DML/DDL/GRANT, deploy ou HTTP write.
- CP335 vigente, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — revisão de ativação temporária, DML ainda HOLD (2026-10-29)

- Autorização do usuário para prosseguir após a revisão de preparação do ensaio; **não interpretar como liberação incondicional de escrita**: a revisão atual identificou duas lacunas concretas.
- `_rollback_recipe` aplica rollback no `finally` transacional, mas **a reconciliação de resíduos e o fechamento explicitamente independente só são alcançados na saída normal do bloco `transaction.atomic`**. Se um INSERT ou verificação gerar exceção, falta um caminho obrigatório de reconciliação READ ONLY e reporte de resultado incerto. Não executar até corrigir.
- `DjangoQ0Repository.__init__` e `execute_connected_q0` seguem HARD HOLD; `settings_pf_i03_q0_readonly_trial` força transação READ ONLY e não pode ser usada para DML. Não burlar bloqueios via `_trial_repository` ou `object.__new__`. Nenhum secret ativo confirmado, nenhum workflow escritor aprovado.
- Próxima entrega proporcional: corrigir a receita para garantir fechamento/reconciliação em falhas, revisar separadamente a ativação restrita a um único ensaio sintético rollback-only, então formalizar escopo exato do DML/credencial. Nenhuma DML/DDL/GRANT, deploy, HTTP write ou alteração de gates; CP335 vigente, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — revisão do candidato rollback-only (2026-10-29)

- Commit `5b15775f8c55aba15ba7f1fcbf63d731cdbad96e`, CI [40818900543](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40818900543) SUCCESS. O candidato offline passou a conferir o plano de rollback já existente (alias, 5 INSERT previstos, nenhum commit, rollback obrigatório, identidade UUID4 sintética). `execute_candidate` e o construtor ORM permanecem HARD HOLD.
- **Limite importante:** este incremento não constitui executor conectado, não valida a proveniência persistida da identidade e não autoriza DML. Próxima atividade deve revisar **um executor conectado temporário realmente executável sob gate nominal próprio**, sem ampliar testes offline ou acrescentar novos documentos redundantes. Baseline sintética legada preservada; nenhum segredo registrado ou alteração Neon. CP335 vigente, Marco B OPEN, E9 NO-GO e Fase 5 NOT_STARTED.

## PF-I03-Q0 — candidato offline validado; encerrar preparações redundantes (2026-10-29)

- CI [40818644362](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40818644362) SUCCESS no commit `5ed826c1478ee5dacd55d2a7a2513935d42eef30`. O candidato `scripts/pf_i03_q0_rollback_candidate_offline.py` gera metadados inéditos e valida contrato exclusivamente offline, com execução conectada explicitamente HOLD.
- Avaliação de proporcionalidade: não criar novos preparadores, portas ou testes offline para o mesmo contrato. Existe bloqueio real entre receita ORM dormente e executor conectado: construtor do repositório e entrypoint público negam execução; o alias READ ONLY aprovado não permite DML; dados científicos sintéticos anteriores devem permanecer intocados.
- **Próximo marco substantivo:** uma revisão delimitada de código do executor temporário **rollback-only** e de sua configuração científica separada, antes de solicitar gate DML nominal. Não inferir proveniência Django de um UUID4 sintético. Nenhum DML, DDL, permissão ou workflow conectado autorizado nesta etapa. CP335 vigente; Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — decisão de prontidão para um único rollback ORM conectado (2026-10-29)

- Revisão em `main` HEAD `380fdbe52a761ce0638d7cb99c0e780ce478e380`: `DjangoQ0Repository.__init__` continua HARD HOLD; `execute_connected_q0` continua HARD HOLD. `_rollback_recipe` contém cinco INSERTs, rollback via `transaction.set_rollback(True)` e consultas após fechar a sessão, mas o uso de `_trial_repository` é gancho experimental e **não é um gate de produção nem licença para contornar o construtor**.
- A configuração `settings_pf_i03_q0_readonly_trial.py` impõe `default_transaction_read_only=on`, portanto serve apenas a catálogo e **não pode** ser usada no ensaio DML. Uma nova sessão científica separada, de duração limitada e com credencial descartável, exige revisão específica e aprovação do executor antes do disparo.
- **Critério mínimo de gate futuro:** exclusivamente 1 Q0 sintética inédita sob `oes_qprep_login` na branch/database conhecidos, 5 INSERT ORM em uma transação com rollback incondicional, nenhuma confirmação/commit, sem retries nem DELETE compensatório; identidade de ator UUID4 apenas estrutural e não atribuída a pesquisador Django real; manter intacto o Q0 legado; snapshot anterior + prova externa de ausência de cinco resíduos e baseline preservada; falha/incerteza → HOLD e reconciliação somente leitura. Para reduzir risco, primeiro submeter o executor e a configuração de escrita temporária a revisão de código, com o caminho público bloqueado, e somente depois solicitar autorização nominal DML.
- **Sem autorização DML neste turno.** Nenhuma modificação de schema, ACL, secret, deployment ou serviços pagos. CP335 vigente, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — revisão de fronteira após CI offline (2026-10-29)

- CI [40818251168](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40818251168) **SUCCESS** no HEAD `d94e1a4b47018b28e7675e1aaa7ac627661cb319`; preflight sintético valida apenas formato `oes:actor:<UUID4>`, não proveniência.
- `preparer_identity.models.PreparerIdentity` reside na store de autenticação separada; `persisted_preparer_actor_id` consulta `default`. O ensaio científico independente no alias `oes_qprep_trial` **não tem como certificar vínculo real ao Django auth apenas pelo UUID4**. Não inventar pesquisador nem converter o ator legado. Decisão proporcional: distinguir claramente ensaio de integridade do ORM/rollback (ator sintético estrutural) da integração end-to-end com auth persistida (gate futuro). Sem identidade persistida criada, a conclusão end-to-end permanece HOLD.
- Mapeamentos `models.py` já apontam para tabelas qualificadas com `managed=False`; não recriar esquema no SQLite. Próximo passo viável é revisão/autorizaçao **específica** de um único ensaio científico sintético rollback-only, com isolamento de identidade, execução PostgreSQL sob papel mínimo e evidência externa pós-rollback. Nenhuma autorização DML inferida de `Prossiga`.
- Nenhuma mudança no Neon, nenhum secret ativo confirmado, sem HTTP write, deploy ou promoção de gates. CP335 vigente, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — pós-session smoke e preparo proporcional de gate ORM (2026-10-29)

- Usuário **declarou excluído** o secret temporário `OES_PF_I03_Q0_PASSWORD`; não houve auditoria independente do GitHub Secrets nem rotação/revogação da senha do papel Neon. Sessão Django READ ONLY 40816706429 SUCCESS já registrada e encerrada.
- Revisão da receita ORM em `question_orm_q0_connected_recipe_dormant.py`, repositório `question_orm_q0_repository_dormant.py` e preflight `q0_rollback_trial_preflight_offline.py`: cinco INSERTs e rollback/reconciliação planejados, mas executor público e construtor do repositório são **HARD HOLD**. A configuração de sessão validada força `default_transaction_read_only=on`, portanto NÃO pode ser reutilizada para qualquer teste INSERT. Não contornar o HOLD por injeção ou manipulação de objetos sem revisão de código.
- Antes de propor autorização de um rollback conectado: identificar fonte de identidade sintética `oes:actor:<UUID4>` e admissibilidade conforme regras do banco, validar mapeamento ORM/constraints, criar caminho de execução *separado e restrito* com rollback forçado e nova sessão de reconciliação, explicitar privilégio mínimo e fronteira de transação. Não reutilizar o ator legado `oes_synthetic_q0` nem registros existentes. Requer revisão de segurança e autorização nominal de DML independente. Evitar gerar outra camada de persistência ou testes redundantes.
- Nenhum Neon DML/DDL/GRANT, deploy, HTTP write ou alteração de gates. CP335 vigente, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — sessão Django científica READ ONLY validada (2026-10-29)

- Execução manual [40816706429](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40816706429) **SUCCESS** no commit `4c151004ba23634bb9afa48c96f16fa0eb02f8ab`, log `READ_ONLY_SESSION_CONTRACT_PASS`. Verificados via sessão Django: alias `oes_qprep_trial`, PostgreSQL `oes_sandbox`, `session_user=current_user=oes_qprep_login`, `search_path=core,investigation,public`, `transaction_read_only=on`, SELECT nas cinco tabelas científicas.
- Somente catálogo e metadados; nenhuma escrita Q0, nenhuma migração, DDL, GRANT ou mudança de role. O probe fecha a conexão em `finally`. A exclusão do secret `OES_PF_I03_Q0_PASSWORD` foi **solicitada ao usuário**, ainda não confirmada; não declarar revogação da senha no Neon.
- **Gate encerrado:** PF-I03-Q0 / SINGLE_DJANGO_SCIENTIFIC_READ_ONLY_SESSION. A receita ORM de cinco INSERT com rollback permanece HARD HOLD e exige autorização distinta. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED; CP335 vigente.

## PF-I03-Q0 — contrato científico de sessão validado offline (2026-10-28)

- CI [40793424259](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40793424259) SUCCESS no commit `12c5f04508fe47ecb221b49672d8793861565f0e`. Contrato `config/pf_i03_q0_session_contract.py` verificado sem conexão: alias `oes_qprep_trial`, banco `oes_sandbox`, papel `oes_qprep_login`, `transaction_read_only=on`, conjunto exato de cinco tabelas.
- Evidência de teste puro NÃO equivale a sessão Django conectada. Próximo gate sugerido: **uma sessão Django READ ONLY**, credencial protegida efêmera, identidade efetiva e catálogo verificados na mesma conexão, sem DML, DDL, grants, mudanças de role, migrations ou execução da receita de rollback Q0. Requer autorização nominal separada. G2-P2-B não reabrir. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED; CP335 vigente.

## PF-I03-Q0 — preparação do ensaio ORM sintético com rollback (2026-10-28)

- Diagnóstico sobre o código existente: `_rollback_recipe` realiza cinco INSERT ORM, verifica cinco relações dentro de `transaction.atomic`, força `transaction.set_rollback(True)` e consulta a ausência dos cinco resíduos após sair da transação. Entradas públicas `execute_connected_q0` e `execute_connected_q0_rollback_trial` permanecem HOLD; `DjangoQ0Repository.__init__` é bloqueante. **Nenhum escritor conectado foi habilitado**.
- Guardas antes de autorizar execução: (1) usar somente identificador novo `OES-SYNTH-Q0-*`, UUIDs novos e request_id novo; (2) preservar a entidade/recibo anterior com ator legado `oes_synthetic_q0`; (3) distinguir o papel real `oes_qprep_login` do alias de design `oes_qprep_trial` — papel `oes_qprep_trial_login` não existe na branch; (4) validar em Django a sessão, role, alias, schemas, constraints, gatilho, permissões e rollback; (5) resolver explicitamente o vínculo de identidade estável `oes:actor:<UUID4>` em sandbox, sem tratar identificador inventado como pesquisador real; (6) obter snapshot READ ONLY de baseline e reconciliação independente posterior; (7) qualquer erro/resultado incerto → HOLD, sem retry, sem DELETE compensatório.
- Atenção: o preflight READ ONLY constatou 5/5/1/1/1 registros nas cinco tabelas e 1 Q0 sintético legado; não presumir baseline vazia. O papel possui INSERT, mas **não DELETE** nas cinco tabelas; o ensaio eventual deve demonstrar rollback transacional, não limpeza posterior. O catálogo acusou um trigger definido pelo usuário em `investigation.question` e 8 FKs.
- **Próximo gate separado proposto:** apenas revisão da configuração de uma sessão Django científica e do isolamento/reconciliação, seguida de autorização nominal específica para um único rollback conectado, se tecnicamente justificado. O `Prossiga` atual não autoriza DML, não estabelece janela exclusiva e não valida credenciais. Sem HTTP write, migração, GRANT, role, deploy, custos ou reabertura G2-P2-B. CP335 vigente, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.

## PF-I03-Q0 — identidade e integridade sintética verificadas READ ONLY (2026-10-28)

- Neon `oes_sandbox`, papel `oes_qprep_login`, somente SELECT: exatamente 1 entidade identificada `OES-SYNTH-Q0-*`, 1 `investigation.question`, 1 `core.entity_version`, 1 `investigation.question_version` e 1 recibo referenciando-a. Campos coerentes: `Question`, version=1/current, `q0_draft`, normalized_text NULL, `REGISTER_Q0`, identificadores ator/pergunta/versão/entidade concordantes, SHA256 hexadecimal formatado.
- Gatilho `investigation.tr_question_entity_type` existente e CHECKs de responsável, estágio e recibo inspecionados. **Ressalva material:** ator legado `oes_synthetic_q0` NÃO segue o contrato de identidade persistida `oes:actor:<UUID4>`; correspondência de campos não equivale a identidade Django válida. Não reatribuir nem excluir este registro sem gate independente; preservar a baseline não vazia e evitar colisões de ID.
- Sem alterações no Neon, sem autorização de DML, sem nova infraestrutura, sem HTTP write ou promoção de gates. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED; CP335 vigente.

## PF-I03-Q0 — preflight científico READ ONLY conectado (2026-10-28)

- Autorização nominal restrita a catálogo/SELECT. Neon projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`; papel efetivo `oes_qprep_login` (a tentativa do nome não cadastrado `oes_qprep_trial_login` falhou sem conexão).
- Cinco tabelas ORM `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version`, `investigation.question_command_receipt`: presentes; schema USAGE e SELECT/INSERT existentes para o papel; DELETE ausente em todas, UPDATE em `core.entity_version` ausente. INSERT é constatação de ACL, **não autorização para DML**. Sessão administrativa da ferramenta exibiu search_path padrão `"$user", public` e `transaction_read_only=off`; consultas executadas somente como SELECT com relações qualificadas. Futuro alias Django requer configuração/revalidação.
- Inventário factual (contagens gerais): 5 `core.entity`, 5 `core.entity_version`, 1 `investigation.question`, 1 `investigation.question_version`, 1 `investigation.question_command_receipt`. Há **uma entidade identificada como Q0 sintética, uma pergunta correspondente e um recibo sintético** já existentes; baseline não vazia. Catalogadas 8 FKs saindo das cinco tabelas e 1 gatilho de usuário; sem alteração.
- **Decisão:** preflight estrutural e de leitura concluído; proposta de novo teste ORM não deve presumir zero registros, exclusividade de identidade ou ausência de recibos. Antes de DML, revisar identificadores e isolamento, gatilhos/constraints e propósito do ensaio; exigir gate separado. Nada executado além de SELECT; G2-P2-B encerrado, Marco B OPEN, E9 NO-GO e Fase 5 NOT_STARTED. CP335 permanece vigente.

## Pós-CP335 — PF-I03 Q0: gate mínimo de persistência Django ORM (2026-10-28)

- Revisão do código canônico: `evidence/question_orm_q0_connected_recipe_dormant.py` já define um ensaio de **cinco INSERT ORM com rollback obrigatório**, verificação intratransacional e ausência de resíduos após rollback; `execute_connected_q0` é HARD HOLD; `DjangoQ0Repository.__init__` também bloqueia. `scripts/q0_rollback_trial_preflight_offline.py` já fornece `SyntheticQ0Trial` com alias-alvo `oes_qprep_trial` e identificadores sintéticos. Não implementar outro port nem nova configuração de escrita antes da necessidade verificada.
- **Lacunas antes de qualquer conexão**: confirmar catálogo e privilégios do papel/alias científico em gate READ ONLY próprio, comprovar fronteira de transação e consistência dos cinco modelos `managed=False` com tabelas físicas; preservar ausência de preparadores reais; demonstrar que o ensaio, se autorizado futuramente, faz rollback obrigatório e reconciliação externa READ ONLY, sem possibilidade de commit e sem retries.
- **Próximo gate recomendado:** uma verificação conectada proporcional **READ ONLY**, dedicada ao Q0 científico, para identidade da sessão, 5 tabelas, integridade do schema, privilégios já existentes e baseline sintética; sem DML, DDL, GRANT, novas credenciais, workflows ou serviços pagos. Pedir autorização nominal independente antes de conectar.
- G2-P2-B encerrado e não reabrir. Nenhum HTTP write, deploy ou nova implantação. Marco B OPEN, E9 NO-GO e Fase 5 NOT_STARTED; CP335 vigente.

## Pós-CP335 — diagnóstico de integração de persistência PF-I03 (2026-10-28)

- Após CI [40781780237](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40781780237) PASS, a cadeia Django auth/permission/PreparerIdentity(UUID4) → Q0 → recibo foi verificada com autenticação real SQLite e Unit of Work em memória.
- Revisão dirigida: `evidence/question_orm_q0_dormant.py` já implementa o protocolo de cinco efeitos ORM Q0 e preserva Q1 HOLD; `evidence/question_orm_q0_repository_dormant.py` já contém mapeamento ORM mas bloqueia a instanciação; `evidence/models.py` usa modelos `managed=False` nas tabelas reais `core`/`investigation`, com FKs compostas e triggers PostgreSQL-owned. `evidence/question_orm_transaction_offline.py` contém consultas lazy, não execução. Não existe conector de escrita autorizada.
- **Decisão de proporcionalidade:** não duplicar essas tabelas no auth SQLite nem criar nova implementação de persistência para repetir contratos offline. A lacuna real é executar e reconciliar o port ORM já existente em banco sintético isolado, mediante gate técnico/nominal separado que especifique alias, identidade, DML, rollback e reconciliação; fora desse gate, o escritor permanece HOLD. Nenhuma habilitação realizada. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED; CP335 vigente.

## Pós-CP335 — seleção de prioridade funcional Django First (2026-10-28)

- Avaliação comparativa de `applications/oes_web/evidence/{views,urls,q0_access_status,q0_synthetic_preview,preparation_auth,question_preparation,models}.py`: catálogo e preview GET-only disponíveis, autorização Django e serviço de comando de preparação separados; falta integração fim a fim Q0 em escopo sintético.
- **Prioridade selecionada:** PF-I03, integrar identidade autenticada, checagem de permissão, comando Q0 e recibo transacional com componentes existentes, primeiramente em sandbox isolado. Critérios de aceitação: rejeitar não autorizado, persistir uma Q0 sintética com identidade do ator, verificar recibo, versão, conflito/replay e rollback, sem construir novos contratos puros genéricos.
- **Não autorizado por essa seleção:** HTTP POST conectado, usuários reais, novas concessões Neon, deploy, produção, ciência nova ou promoção de gates. G2-P2-B não deve ser reaberto. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. CP335 permanece checkpoint vigente.

## CP335 — G2-P2-B encerrado no escopo sintético (2026-10-28)

- Checkpoint vigente `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP335.md`; provisionamento `40773613528` PASS, limpeza `40775904096` PASS e baseline 44 permissões, zero usuários, links, identidades e sessões reconciliada pelo runner em conexão READ ONLY.
- Responsável confirmou exclusão dos segredos efêmeros, inclusive `OES_AUTH_G2_P2B_CLEANUP_PASSWORD` (sem verificação independente do cadastro GitHub). Não repetir os workflows, nem transferir autorizações a outros ensaios. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED.
- Próximo: avaliar incremento Django First substantivo, proporcional, sem novos testes repetitivos e sem autorização implícita de operação.

## G2-P2-B — ciclo sintético conectado concluído (2026-10-28)

- Provisionamento único: [40773613528](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40773613528), `PASS_POST_COMMIT`. Preflight de limpeza conectado READ ONLY: PASS.
- Limpeza única: [40775904096](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40775904096), tentativa 1, commit `417ee2eb266d8f28c0d87ccc07ace6e1bfa8732b`, SUCCESS, `PASS_CLEANUP_POST_COMMIT`; baseline reconciliada pelo runner: permissions=44, users=0, links=0, identities=0, sessions=0.
- **Encerramento técnico restrito ao ensaio sintético:** não repetir workflows, sem limpeza pendente neste ciclo. Segredo efêmero `OES_AUTH_G2_P2B_CLEANUP_PASSWORD` ainda com exclusão não confirmada. Não autoriza usuários reais, HTTP write, deploy ou alteração de gates. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. CP334 segue checkpoint de referência até formalização de novo checkpoint.

## Pós-CP334 — G2-P2-B connected single synthetic trial (2026-10-28)

- Workflow manual [40773613528](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40773613528), tentativa 1, commit `4215a7eb66e9213953dc691c681b75dade7002cc`: SUCCESS e marcador `OES_G2_P2B_TRIAL_RESULT=PASS_POST_COMMIT`. Evidência do runner para provisionamento Django ORM sintético e reconciliação pós-commit READ ONLY; sem consulta Neon independente adicional nesta atividade.
- **STOP:** não repetir workflow; registros sintéticos persistem até decisão nominal de limpeza. Exclusão do segredo `OES_AUTH_G2_P2B_TRIAL_PASSWORD` solicitada, mas não confirmada pelo responsável. Nenhuma limpeza autorizada. Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. CP334 continua checkpoint vigente enquanto atualização de continuidade não for formalizada.

## Pós-CP334 — G2-P2-B READ ONLY administrativo consolidado (2026-10-28)

- Preflight conectado Neon sob `oes_auth_migrator`: baseline 44 permissões, 0 usuários/vínculos/identidades/sessões, ContentType correto, permissão customizada ausente, quatro tabelas INSERT/DELETE e quatro sequências USAGE confirmadas. A ferramenta Neon abriu schema `public`, sem demonstrar configuração Django.
- Smoke Django manual [40756319997](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40756319997) SUCCESS, SHA `3a7c86f8fa3f13e831406376b5f2ff1143cf5cb6`: `oes_auth_migrator`, `oes_sandbox`, `current_schema=django_auth`, `search_path=django_auth`, transação READ ONLY. Exclusão do segredo `OES_AUTH_G2_P2B_SMOKE_PASSWORD` confirmada pelo responsável (não independentemente auditada). Evidência consolidada no documento canônico de arquitetura; nenhum DML conectado autorizado ou executado.
- Pendências reais: serialização diante de escritores externos, pacote único autorizado de provisionamento DML, verificação após commit e limpeza sob gate distinto. Configuração de provisionamento conectado continua bloqueada; Marco B OPEN, G2-P2-B HOLD/NO-GO, E9 NO-GO, Fase 5 NOT_STARTED. Checkpoint CP334 permanece vigente.

## CP334 — G2-P2-B Django First / A11–A15 (2026-10-28)

- Checkpoint vigente `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP334.md` (CP333 histórico). A11 suficiência; A12 configuração administrativa `settings_auth_pg_g2_p2b_dormant.py` com HOLD incondicional, CI [40754760803](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40754760803) SUCCESS; A13 revisão; A14 contrato puro `auth_pg_g2_p2b_admin_preflight.py`; A15 CI [40755134420](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40755134420) SUCCESS no SHA `343554e2ed0d0c3800a9f85cf9c4fc315efe22c6`.
- Sem DML Neon, segredos, alterações de roles/grants ou habilitação de workflow conectado; G2-P2-B conectado HOLD/NO-GO, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. Próximo passo útil: obter evidência real de sessão e baseline via preflight conectado READ ONLY mediante gate próprio; reduzir refinamento apenas offline.

## CP333 — G2-P2-B Django First / A6–A10 (2026-10-28)

- Checkpoint vigente `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP333.md`; anterior CP332 preservado. A7 corrigiu preflight dentro de `transaction.atomic`, controle de `django_session` e alias ORM; A9 adicionou contrato offline não autorizativo da baseline 44/0/0/0/0 e postflight 45/1/1/1/0. A6/A8 foram revisões estáticas; A10 consolidação.
- CI [40746209036](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40746209036) SUCCESS e [40748916868](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40748916868) SUCCESS (`175bcb94753f9ee1dce41613d369daee4c17111f`). Nenhum DML Neon, GRANT, secrets, workflow conectado, deploy ou HTTP write. G2-P2-B conectado HOLD/NO-GO, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. Próximo passo revisão proporcional de suficiência e pacote mínimo antes de eventual autorização nominal.

## CP332 — Django First / G2-P2-B offline (2026-10-28)

- Checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP332.md`; anterior CP331 preservado. A1–A5: confirmação do preflight administrativo, criação e refatoração do núcleo Django ORM `config/auth_pg_g2_p2b_offline.py`; entrada pública bloqueia PostgreSQL e só aceita SQLite efêmero.
- CI [40744588262](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40744588262) FAILURE por URI SQLite de testes; corrigida. CI [40745400376](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40745400376) SUCCESS, CI [40745725023](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40745725023) SUCCESS; commit A5 `1a05f8e2`.
- Nenhum DML Neon, role/grant/segredo/execução conectada ou HTTP write. G2-P2-B conectado HOLD; G2-P2B operacional NO-GO, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. Próximo passo revisão dirigida do contrato de execução conectada e riscos ORM; autorização nominal antes de mutação.

## CP331 — retomada G2-P2-B (2026-10-28)

- Ponteiro: `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP331.md`. G2-P1 conectado [40740532848](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40740532848) PASS; workflow novamente desabilitado, segredo excluído segundo responsável. B2-M1 [40730386136](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40730386136) 16/16 migrations PASS, segredo excluído segundo responsável.
- G2-P2-A READ ONLY baseline: auth_user=0, 44 permissões preexistentes, 0 identidades, 0 sessões e permissão `evidence.prepare_question` ausente. G2-P2-B 197/197 testes offline PASS [40741871726](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40741871726). `oes_auth_migrator` owner de 49 objetos; USAGE em quatro sequências necessárias e INSERT/DELETE sobre tabelas pertinentes confirmados por consultas pontuais. Nenhum DML conectado autorizado/executado.
- `oes_auth_trial_login` com grants mínimos G1 PASS; credenciais de trial/migrator expiram em 2026-10-31 23:59:59 UTC (sem revogar objetos). **G2-P2-B conectado HOLD**, G2-P2B operacional NO-GO, E9 NO-GO, Fase 5 NOT_STARTED; Marco B OPEN. Próxima atividade: formalizar evidência administrativa final e gate de provisionamento, sem executar sem autorização.

## Pós-CP330 — B2-M1 migrations PostgreSQL PASS (2026-10-28)

- Execução única autorizada [40730386136](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40730386136) **SUCCESS**: Django schema `django_auth`, 16/16 migrations aplicadas; 49 objetos; postflight `B2_M1_POSTFLIGHT_PASS`. Inventário científico 315 registros, SHA-256 estável `2e75e4c018b62f8b288b5f84e9a70fe0ebf9eea64e928468130e4950d38f6b81`.
- Workflow B2-M1 desabilitado após consumo, sem autorização de repetição. **Segredo `OES_AUTH_B2_M1_PASSWORD` deve ser excluído pelo responsável; confirmação pendente**. Runtime auth grants, contas reais, HTTP write e deploy não autorizados.
- CP330 permanece ponteiro vigente (snapshot histórico pré-execução); este STATE registra evolução posterior. Marco B OPEN, G2-P2B NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.

## CP330 — Estado vivo Django auth PostgreSQL (2026-10-28)

- Checkpoint: `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP330.md`; Documento 362 normativo.
- Arquitetura: banco único `oes_sandbox`, schema `django_auth` segregado. Gate A e B1 PASS; papel `oes_auth_migrator` temporário com prazo 2026-10-31 23:59:59 UTC. Gate B2-P1 Django READ ONLY [40727429944](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40727429944) PASS com `search_path=django_auth`.
- **B2-M1 HOLD, não autorizado:** workflow `.github/workflows/oes-auth-b2-m1-migrations-manual.yml` permanece `if:false`; segredo específico B2-M1 não cadastrado; migrations PostgreSQL não executadas. CI offline [40729253488](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40729253488) **191/191 PASS**.
- Segredo B2-P1 excluído segundo confirmação do responsável, sem verificação administrativa independente; prazo da senha não revoga grants.
- Próxima etapa: deliberação nominal B2-M1; antes dela, não habilitar workflow, não cadastrar segredo e não executar `migrate`.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.


## Marco funcional pós-CP329 — autenticação SQLite + leitura Neon integradas PASS (2026-10-28)

- **Ensaio conectado único:** workflow manual `oes-auth-pg-integrated-readonly-manual.yml`, [run 40701127859](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40701127859), `workflow_dispatch` na `main`, SHA `b5d74b3da90c3be4ebe80fbd233683713c4a0acc`, tentativa 1, conclusão **SUCCESS**; log `PASS SQLITE_AUTH_PG_READ_ONLY_SYNTHETIC_THREE_LINKS_Q0_WRITE_BLOCKED`.
- Comprovadas na mesma execução: autenticação/sessão e permissão Q0 de usuário sintético em SQLite temporário, conexão Neon `oes_sandbox` como `oes_pg_a4_reader` em modo **READ ONLY**, três vínculos sintéticos Study–Report, renderização HTML e bloqueio de POST Q0. Migrations executadas **somente no SQLite efêmero**, não no Neon. Nenhum DML/DDL PostgreSQL, alteração de role/grant, deploy, Q1 ou escrita HTTP.
- CI offline prévia [40699959556](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40699959556): **155/155 + 11/11 PASS**; validação offline inclui recusa de execução conectada sem autorização. Segredo temporário `OES_PG_A4_PASSWORD`: **exclusão manual declarada pelo responsável após sucesso**, sem verificação independente por inventário. Execução única consumida; não repetir.
- **Decisão de continuidade:** encerrar iterações de demonstração equivalentes; avaliar a lacuna funcional de Q0 autenticado persistente e a arquitetura de identidade em ambiente de aplicação antes de qualquer proposta de escrita HTTP. CP329/Documento 362 preservados; Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED.

## Marco funcional pós-CP329 — Q0 sintético persistente PASS (2026-10-28)

- **Execução única autorizada:** workflow manual `oes-q0-synthetic-commit-manual.yml`, [run 40695250735](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40695250735), SHA `869798455c7129dfb0ebb63e7088dc7e15f1d66b`, **SUCCESS**; logs: `PASS Q0_SYNTHETIC_COMMIT_REPLAY_CONFLICT_READBACK`. O executor relata commit Q0 sintético, conferência dos cinco registros, replay idempotente e rejeição de conflito. Não equivale a liberação de escrita operacional.
- Pré-requisitos comprovados: catálogo de privilégios de `oes_qprep_login` (SELECT/INSERT nas cinco tabelas); teste anterior de cinco INSERTs com rollback, run 40525954698 PASS; suite offline [40693704967](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40693704967) **146/146 PASS**.
- Segredo temporário `OES_QPREP_LOGIN_PASSWORD`: **exclusão declarada pelo responsável após o sucesso**, não verificada independentemente. Não repetir workflow automaticamente; não consultar dados reais. CP329 e Documento 362 vigentes; PF-I04/P4 autônomo deferido; Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY e Fase 5 NOT_STARTED.

## Marco funcional pós-CP329 — Django–PostgreSQL READ ONLY integrado PASS (2026-10-28)

- **Evidência:** GitHub Actions [40691185683](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40691185683), `workflow_dispatch`, commit `59754c1a61d864399b60093ff29b5642b7c3993e`, conclusão **SUCCESS**. Logs: `PASS PG_A4_DJANGO_CONFIG_PREFLIGHT_NO_CONNECTION`, `PASS PG_A4_G2_B_DJANGO_CONNECTED_THREE_LINKS_ONE_PROVENANCE`, `PASS PG_A4_DJANGO_CONNECTED_SYNTHETIC_HTML`.
- Comprovada integração sintética de leitura **Django → Neon PostgreSQL → página HTML** pelo cliente de testes, usando `oes_pg_a4_reader` na branch `br-gentle-hall-b6jaxehf` / `oes_sandbox`: três vínculos Study–Report e distinção de proveniência. Suíte offline anterior: **136/136 PASS**, run [40689017577](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40689017577).
- Segredo temporário `OES_PG_A4_PASSWORD`: **exclusão declarada pelo responsável** após a execução; não se declara verificação independente no inventário de segredos. Workflow não foi reexecutado. Nenhum DML/DDL, migração, grants, alterações de papéis ou deploy nesta validação.
- **Próximo incremento recomendado:** priorizar fluxo funcional sintético de preparação Q0/Q1 em Django-first, começando por revisão dirigida do repositório ORM e um contrato mínimo de escrita transacional; qualquer teste conectado de escrita exige nova autorização específica. Não retomar PF-I04/P4 autônomo. CP329 permanece vigente, Documento 362 normativo; Marco B OPEN, G2-P2B NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED.

## CP329 — Governança técnica proporcional aprovada; PF-I04/P4 autônomo deferido (2026-10-28)

- **Decisão canônica:** Documento 362 `docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md`, aprovação explícita `SIMPLIFICACAO_PROPORCIONAL_GOVERNANCA_TECNICA`. Aprovação somente documental; nenhuma operação conectada.
- PF-I04/P4 autônomo **SUSPENSO/DEFERIDO**; A41 PASS restrito a PostgreSQL 18 descartável (Actions 40631160589), sem validação operacional Neon. Evidências A37–A41 intactas; A42 três versões SQL e parecer **arquivados no GitHub em `archive/handoffs/oes/artifacts/P4-A42/`, não executados**; hashes identificados no CP329.
- Proporcionalidade: autorizações futuras por escopo/procedimento; sem promover retroativamente SQL Neon. Fim da exigência genérica de expiração de senha ao segundo; menor privilégio, prazo de uso e revogação proporcional. A32/A35 mantêm `if:false`; sem roles/grants/segredos/workflows/deploy/gastos/dados reais.
- **Próxima atividade:** análise OFFLINE de requisitos reais de privilégios Django–PostgreSQL e proposta do teste integrado mínimo. Não avançar automaticamente P4-A43. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Marco B `OPEN`, G2-P2B `NO-GO`, E9 `NO-GO`, readiness `NOT_READY`, PF-I04/P4 `NOT_AUTHORIZED`, Fase 5 `NOT_STARTED`.
- **Checkpoint:** `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP329.md`; seguir Freshness Gate e parar após publicação.

## CP328 — P4-A39–A41 | PostgreSQL 18 descartável PASS integral, Neon ainda NO-GO (2026-10-28)

- **P4-A39:** SQLs v2 setup/postflight/lockdown/cleanup sob HOLD, identidade SHA-256 e parecer em `archive/handoffs/oes/artifacts/P4-A39/`; credential lockdown `NOLOGIN PASSWORD NULL` em COMMIT independente do cleanup.
- **P4-A40:** fixture PostgreSQL 18.6 detectou falha real da v2 `target not pristine` após `CREATE ROLE`; causa: autogrant `ADMIN TRUE / INHERIT FALSE / SET FALSE` ao criador não-superusuário. Runs 40630179968/40630287399/40630416910, todos HOLD; sem Neon. Workflow A40 manual somente.
- **P4-A41:** três SQLs v3 (SETUP `68e364af8927a67bf0f9f743084ed79cbc0d4114f7af9aa98c6d3e2c8f84fa62`, POSTFLIGHT 28 checks `3dacfa56e85d8acbdde2f235d981e57e82d5da946c2392e19cde3433c286c8dd`, CLEANUP `3bb320045e431d77b9596da2312fcce3bd13458def316042d7546eb5b8e04454`) em `archive/handoffs/oes/artifacts/P4-A41/`, sem execução Neon; originais A37 TRIAL ROLLBACK e A39 LOCKDOWN intactos.
- **Run A41 real [40631160589](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40631160589):** PostgreSQL 18 descartável, status **SUCCESS**, todas as fases PASS: autogrant creator, setup, GRANT/SET LOCAL ROLE/REVOKE/ROLLBACK, postflight v3 de 28 checks, negativos de terceiros, LOCKDOWN transação separada, CLEANUP e postcleanup catalogal; fixture exclusivamente sintética, **sem conexão Neon**. Run precedente A41 40631051160 falhou apenas no verificador pós-cleanup antigo, posteriormente corrigido. Workflow A41 agora **workflow_dispatch** somente; A32/A35 continuam HARD HOLD.
- Evidência detalhada `archive/handoffs/oes/artifacts/P4-A41/OES_PF-I04_P4-A41_PG18_V3_VALIDATION_PASS_WITH_LIMITS.md`, checkpoint vigente **CP328** em `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP328.md`. **P4-A42:** revisão/definição do gate Neon READ ONLY para inventário roleid E member do `oes_p4_trial_login`, owner autogrant e OID 155649, reconfirmar endpoint da branch. NÃO executar Neon SQL sem autorização nominal. Marco B OPEN, G2-P2B NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.

## P4-A40 — PostgreSQL 18.6 descartável confirma NO-GO do setup A39 (2026-10-28)

- Workflow de CI isolada `.github/workflows/oes-pf-i04-p4-a40-pg18-disposable.yml` e harness `scripts/oes_p4_a40_pg18_disposable.py`: PostgreSQL **18.6** em contêiner efêmero, cliente só `127.0.0.1`, identidades/senhas sintéticas; Neon não acessado. Após a experiência, workflow voltou a **`workflow_dispatch` somente**, sem acionamento automático.
- Runs [40630179968](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40630179968) (HOLD por guarda de bridge excessiva), [40630287399](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40630287399) (HOLD por contagem OID na cópia), e [40630416910](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40630416910) (**falha real do SETUP A39**). Todos cinco hashes SQL originais PASS; CREATE ROLE target executou dentro de BEGIN e o DO de inspeção seguinte rejeitou `target not pristine` antes de GRANT ou COMMIT. Nada persistiu fora do contêiner.
- **Causa:** PostgreSQL 18 concede automaticamente ao criador não-superusuário com CREATEROLE `ADMIN TRUE, INHERIT FALSE, SET FALSE` no papel novo (grantor bootstrap). Setup A39 v2 exige zero associações target e é estruturalmente incompatível; **NO-GO** para setup real. Postflight, trial A37, lockdown e cleanup não foram exercitados. A baseline informada do trial só avaliou `member=trial`, não `roleid=trial`; é necessário conferir dois sentidos antes de gate.
- Parecer persistido em `archive/handoffs/oes/artifacts/P4-A40/OES_PF-I04_P4-A40_PG18_DISPOSABLE_RESULTADO_NO_GO.md`. Próxima **P4-A41**: v3 com autogrant do criador explicitamente esperado e PG18 sintético PASS completo, mantendo SQL A37/A39 canônicos históricos imutáveis; não conceder SQL no Neon/segredo com `Prossiga`. **CP327 vigente**; todos os gates globais NO-GO.

## P4-A39 — postflight v2 e separacao do lockdown de credencial/cleanup, SEM SQL conectado (2026-10-28)

- **Quatro fontes novas em `archive/handoffs/oes/artifacts/P4-A39/`:** postflight v2 READ ONLY 26 checks SHA-256 `fac7b3146f56e9f69375cc2f6330d335cc29c961d87ca5c3d02243e0d75fca5d`; setup v2 mutante SHA-256 `236ab6ae232bc6080453345957f6a5e7711911ed50471078a5e53e94ff8f6daa`; lockdown separado `ALTER ROLE NOLOGIN PASSWORD NULL` SHA-256 `ff9782bfbc2bdec1503187d69f0b12b1c10a53d7cc08176a79ab15ef7a11baa7`; cleanup v2 sem ALTER ROLE, exigindo lockdown prévio, SHA-256 `83d76fabcf489ba4ac49151f19c799dadade3a956f9f5113da1a3b8ec843954c`. Todos **HOLD** e sem execução PostgreSQL.
- Postflight enumera `pg_auth_members` target como granted e membro, trial como membro, `pg_shdepend` para dependências de objeto exceto arestas `pg_auth_members` previstas no PostgreSQL 18, `pg_db_role_setting`, identidade da sessão, versão, 0 conexões trial, OID 155649 e ausência SET/USAGE sensível. Cleanup não poderá desfazer invalidação da senha por falha no DROP: lockdown é transação COMMIT independente.
- Auditoria e identidades Git blob/SHA-256: `archive/handoffs/oes/artifacts/P4-A39/OES_PF-I04_P4-A39_REVISAO_V2_GATES_E_HASHES_HOLD.md`. Fontes A37/P4-A38 imutáveis, workflows A32/A35 inalterados. **Próxima P4-A40:** ensaio de parsing/comportamento de candidato em PostgreSQL 18 **inteiramente descartável/offline**, sem Neon ou segredo. Gates individuais SETUP/TRIAL/POSTFLIGHT/LOCKDOWN/CLEANUP/POST-CLEANUP não concedidos.
- **CP327 continua vigente**. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.

## CP327 — P4-A35–A38 | login temporário isolado; quatro SQLs sintéticos preservados e auditados com HOLD (2026-10-28)

- **P4-A35:** workflow candidato separado `.github/workflows/oes-pf-i04-p4-a35-connected-role-trial-candidate-hold.yml`, ainda `if: false`, `APPROVED_HEAD=NOT_AUTHORIZED`, `CREDENTIAL_LIFECYCLE_GATE=NOT_APPROVED`; **não adaptar A35 automaticamente** à identidade trial.
- **P4-A36:** responsável criou `oes_p4_trial_login`, LOGIN/NOINHERIT, sem privilégios administrativos, CONNECTION LIMIT=1, validade da senha até 31/10/2026 03:30:53 UTC. Consulta informada: 0 memberships, SET migrator/owner false, associação original migrator→owner OID 155649 preservada. Nenhuma credencial cadastrada pelo assistente.
- **P4-A37:** decisão de usar `oes_p4_trial_target` **novo NOLOGIN sem objetos**, nunca migrator/owner; setup sintético, trial ROLLBACK, postflight e cleanup concebidos como **quatro gates independentes**; SQLs não executados.
- **P4-A38:** quatro SQLs integrais A37 preservados com **Git blob SHA comprovado** em `archive/handoffs/oes/artifacts/P4-A38/`, todos SHA256 idênticos ao pacote local, auditoria independente em `archive/handoffs/oes/artifacts/P4-A38/OES_PF-I04_P4-A38_AUDITORIA_E_GATE_HOLD.md`. Scanner estático PASS (setup 9 instruções BEGIN→COMMIT; trial 19 BEGIN→ROLLBACK; postflight 1 SELECT/12 checks; cleanup 8 BEGIN→COMMIT); **PostgreSQL engine não executado**. Bloqueios A38-R01 (pós-check não inventaria associações de terceiros nem dependências target), R02 (identidade de sessão e branch não certificadas no SELECT), R03 (cleanup NOLOGIN não comprova PASSWORD NULL), R04 (ADMIN sintético requer inventário completo), R05 (workflow A35 ainda usa owner e SQL A29). Requer **novas versões SQL v2** antes de qualquer execução; preservar fontes originais imutáveis.
- **CP327 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP327.md`, CP326 anterior. Próxima **P4-A39 exclusivamente OFFLINE**: corrigir postflight v2, inventário de memberships do alvo nos dois sentidos, identidade e dependências, e revisar cleanup. Proibidos GRANT/CREATE ROLE/ALTER ROLE/SET ROLE/SQL conectado, segredo GitHub, mudança de `if:false`, Django/Q0, HTTP ou deploy por `Prossiga`. Gates: Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.

## P4-A37 — login temporário isolado; ensaio migrado para papel-alvo inteiramente sintético (2026-10-28)

- Consulta READ ONLY reportada pelo responsável: `oes_p4_trial_login` sem associações, original `oes_django_migrator`→`oes_sandbox_owner` com exatamente uma associação OID 155649 intacta; nenhum SET do trial para migrator/owner. Senha trial expira em 2026-10-31 03:30:53 UTC; **não cadastrada no GitHub**.
- **Decisão de menor privilégio:** NÃO conceder migrator ou owner ao login temporário. Preparada offline variante limitada a novo alvo `oes_p4_trial_target` NOLOGIN sem objetos. Sua associação ao trial com ADMIN TRUE INHERIT FALSE SET FALSE permite testar grantor-aware self-GRANT/SET LOCAL ROLE/REVOKE/ROLLBACK sem delegar direitos Django. Setup (CREATE ROLE/GRANT persistentes), trial transacional, postflight independente e cleanup foram criados localmente e empacotados, **não executados**.
- Parecer com SHA-256 dos quatro scripts: `archive/handoffs/oes/artifacts/P4-A37/OES_PF-I04_P4-A37_DECISAO_SINTETICA_E_HASHES_HOLD.md`. **Os quatro arquivos SQL integrais permanecem apenas locais**, não alegar persistência GitHub. Qualquer setup/trial/postflight/cleanup requer gate nominal separado; o teste sintético não prova o caso histórico migrador OID 155649. Workflow A35 `if:false` permanece inalterado.
- **CP326 ainda vigente.** Próximo P4-A38: revisão e persistência de fontes SQL integrais; nenhuma operação Neon ou registro de segredo por `Prossiga`. Gates globais permanecem NO-GO.

## P4-A35 — workflow conectado candidato SEPARADO, fisicamente bloqueado (2026-10-27)

- **Novo workflow:** `.github/workflows/oes-pf-i04-p4-a35-connected-role-trial-candidate-hold.yml`, blob `41e1be3bad3aa0dee479306d8b55f6af321220ea`. `workflow_dispatch` somente, job conectado **`if: false`**, `APPROVED_HEAD=NOT_AUTHORIZED` e `CREDENTIAL_LIFECYCLE_GATE=NOT_APPROVED`; nenhuma credencial ou environment configurados nesta atividade. A32 imutável e offline-run 40622890545 PASS preservados.
- **Controles offline estáticos PASS:** SHA-256 imutáveis A29 trial `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17` e postflight `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`; tentativa `run_attempt=1` (não impede novo run_id); revisão do commit antes de qualquer conexão; conexão/direct psql projetada, mas NUNCA executada.
- **Credencial permanece NO-GO:** apagar GitHub Secret não revoga senha PostgreSQL, e rotacionar senha do `oes_sandbox_owner` pode interromper outros consumidores; não foram alterados papéis, senhas, grants ou executado SQL. Parecer: `archive/handoffs/oes/artifacts/P4-A35/OES_PF-I04_P4-A35_WORKFLOW_CANDIDATO_E_GATE_CREDENCIAL.md`. Próxima P4-A36: decidir viabilidade de credencial descartável e negativas offline, ainda sem alteração de banco. **CP326 vigente**; gates gerais inalterados.

## CP326 — PF-I04/P4-A31–A34 | GitHub Actions offline PASS; ativação conectada HOLD (2026-10-27)

- **P4-A31:** canal preferido GitHub Actions manual com `psql` direto; fonte original preservada em `archive/handoffs/oes/artifacts/CP326/`. Nenhum psql local/Neon executado.
- **P4-A32:** workflow manual `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml` publicado, Git blob `955de382252e10a287880f387111b2f35d755daf`; `connected-role-trial if: false` incondicional; segredos não cadastrados.
- **P4-A33:** run factual [40622890545](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40622890545) `workflow_dispatch` em main, commit `01553be79f77b198673d45caddfa77f739b042a3`: offline SUCCESS/log `OFFLINE_PASS`; job conectado SKIPPED/log `HARD_HOLD_CONFIRMED`. **Zero SQL Neon**; evidência em `archive/handoffs/oes/artifacts/P4-A33/OES_PF-I04_P4-A33_RESULTADO_REMOTO_40622890545.md`.
- **P4-A34:** auditoria independente `ACTIVATION_HOLD`, parecer `archive/handoffs/oes/artifacts/P4-A34/OES_PF-I04_P4-A34_PARECER_GATES_E_RISCOS_CONEXAO.md`. Bloqueios: (R01) remover `if:false` quebraria a própria asserção do offline; (R02) apagar segredo GitHub não invalida senha privilegiada no PostgreSQL; (R03) concorrência não impede novo dispatch/re-run; (R04) postflight independente ainda requer autorização nominal separada e em nova sessão; (R05) novo diff, SHA/commit, endpoint DIRECT, logs e contagem/ROLLBACK precisam revisão. R06: proteção por environment opcional, viável somente conforme contas/revisores.
- **CP326 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP326.md`, sucessor imutável de CP325. **P4-A29 SQL ROLLBACK-ONLY e postflight não executados**. Próximo **P4-A35**: preparar candidato novo, somente offline, preservando o workflow A32 imutável, e resolver pré-condição de credencial administrativa verdadeiramente descartável. Nenhuma ativação ou SQL concedidos por `Prossiga`.
- Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED.

## P4-A33 — validação remota offline REAL PASS (2026-10-27, 23:46 America/Recife)

- **Run GitHub [40622890545](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40622890545):** `workflow_dispatch` em `main`, SHA `01553be79f77b198673d45caddfa77f739b042a3`, primeira execução, run **SUCCESS**. Job `offline-contract` **SUCCESS**, 6 etapas success; job `connected-role-trial` **SKIPPED**, como determinado pelo `if: false`.
- Logs confirmados: `OFFLINE_PASS: A29 SQL identities and ROLLBACK verified; NO SQL CONNECTION` e `HARD_HOLD_CONFIRMED: connected-role-trial is SKIPPED unconditionally`. Conclusão restrita `GITHUB_OFFLINE_VALIDATION_PASS`; **nenhum SQL Neon, GRANT/REVOKE/SET ROLE ou ensaio conectado**.
- Evidência durável: `archive/handoffs/oes/artifacts/P4-A33/OES_PF-I04_P4-A33_RESULTADO_REMOTO_40622890545.md`. P4-A34 deve avaliar controles adicionais e gate **nominal** de ensaio, sem ativação automática. CP325 segue vigente; Bloco A e Gates globais inalterados.

## CP325 — PF-I04/P4-A28–A30 | ensaio rollback-only candidato e canal psql direto (2026-10-27)

- **P4-A28 (documental):** escolha proporcional de um ensaio de associação temporária + SET LOCAL ROLE + REVOKE grantor-aware **terminado obrigatoriamente por ROLLBACK**, sem GRANT em objetos Django/Q0. A associação original OID `155649`, grantor `cloud_admin`, deve permanecer intacta.
- **P4-A29 (documental):** SQL candidato 171 linhas com quatro marcadores `A29_PRE/TEMP_GRANT/MIGRATOR/CLEAN`, contagem 1→2→2→1 e **ROLLBACK**; SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`. Postflight independente READ ONLY SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`; ambos **NÃO EXECUTADOS E NÃO AUTORIZADOS**.
- **P4-A30 (documental):** canal preferido condicional `psql` por conexão direta, uma sessão e transação explícita com `ON_ERROR_STOP`, sem `-1`, exigindo ambiente local comprovado, rollback visível e postflight em nova sessão. Neon MCP `run_sql` e `run_sql_transaction` / SQL Editor **não aprovados** para A29 sem novo desenho/prova. Nenhuma conexão ou credencial local verificada.
- **CP325 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP325.md`; quatro arquivos originais A29/A30 preservados com hashes Git conferidos em `archive/handoffs/oes/artifacts/CP325/`. **Próxima P4-A31:** verificar modalidade operacional de ensaio e sua viabilidade; não executar GRANT/REVOKE/SET ROLE sem autorização nominal específica e pré-condições comprovadas. Fase 5 NOT_STARTED, Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED.

## CP324 — PF-I04/P4-A25–A27 | verificador v3 executado; baseline HOLD confirmada (2026-10-27)

- **P4-A25:** uma consulta A23 READ ONLY nominalmente autorizada no Neon sintético falhou com `ACL arrays must be one-dimensional`, sem SUMMARY nem mutações; não repetida. Causa provável: `aclexplode` sobre ACL vazia de dimensão zero.
- **P4-A26:** verificador v3 com `aclexplode(CASE WHEN cardinality(...)>0 THEN ... ELSE NULL::aclitem[] END)` e auditoria de `PUBLIC` (`grantee=0`) em `oes_app/core/investigation`, 14 tabelas e colunas, 8 sequências Django. SQL SHA-256 exato `136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a`. Revisão documental; não autoriza GRANT.
- **P4-A27:** após aprovação nominal independente, uma consulta v3 catalogal no Neon PostgreSQL 18 **executou sem erro**: 947 linhas recebidas (1 SUMMARY + 946 checks), `64 mismatches / 946 checks`, `SUMMARY/HOLD` **esperado pré-GRANT**; 882 conformes. Divergências: coluna 39, tabela 11, ACL tabela 11, ACL coluna 1, schema 1, ACL schema 1. `public_grants_in_scoped_objects=0`; não implica isolamento universal ou ausência de privilégios `PUBLIC` fora do escopo.
- **CP324 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP324.md`; três fontes A26/A27 persistidas em `archive/handoffs/oes/artifacts/CP324/` com hashes Git conferidos. **P4-A21 transação SQL ainda HOLD incondicional, jamais executada; P4-A19 superado**. Não houve role/GRANT/REVOKE/SET ROLE/DDL/DML/login Django. Próxima **P4-A28**: revisar documentalmente estratégia administrativa e desenhar teste proporcional de atomicidade, grantor e rollback; qualquer Neon mutante requer aprovação nominal separada.
- Gates inalterados: Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED; sem pesquisadores vinculados.

## CP323 — PF-I04/P4-A21–A24 | SQL v2 HOLD; verificador A23 limitado por ACLs PUBLIC (2026-10-27)

- **P4-A21:** pacote candidato transacional v2 (Bloco A de auth/sessions Django) e postflight independente; `RAISE EXCEPTION` incondicional precede GRANTs; **NÃO EXECUTAR**. SQL não validado PostgreSQL 18; nenhum Neon/GRANT. SQL anterior P4-A19 permanece SUPERADO.
- **P4-A22:** revisão independente PASS estático com ressalvas, HOLD operacional; postflight A21 incompleto e não produz decisão automatizada única; sem validação de rollback, atomicidade do canal e grants transitórios.
- **P4-A23:** verificador READ ONLY `WITH ... SELECT`, resumo PASS/HOLD, candidato não executado. SHA-256 exato `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7`. Baseline pré-GRANT esperada HOLD, mas nunca comprovada no servidor.
- **P4-A24:** revisão estática PASS com ressalvas. **A24-R01 bloqueante:** ACLs diretas a `oes_runtime` são inspecionadas, mas concessões a `PUBLIC` e terceiros não são integralmente comparadas; eventual PASS do checker atual **não** prova isolamento. Outros limites: inventário de colunas e escopo, saídas longas, parser PostgreSQL 18 e transação não ensaiados.
- **CP323 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP323.md`. Persistidos e conferidos **sete artefatos originais** em `archive/handoffs/oes/artifacts/CP323/`, com hashes Git idênticos aos locais; ZIPs locais não versionados. Próximo **P4-A25**, somente após aprovação nominal, seria um SELECT catalogal do A23 SHA acima para validar parsing e baseline HOLD; não é aceite final nem autorização de GRANT. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.

## CP322 — PF-I04/P4-A17–A20 | bloqueio administrativo e correção do SQL candidato (2026-10-27)

- **P4-A17 (documental):** alternativa preferencial, condicionada, de associação `SET ROLE` temporária e reversível para GRANTs Django pelo proprietário dos objetos, sem reativar `oes_django_migrator` NOLOGIN nem transferir ownership. Não executada.
- **P4-A18 (um SELECT catalogal nominalmente autorizado):** relação `oes_django_migrator`→`oes_sandbox_owner` tem associação original única de OID **155649**, `grantor=cloud_admin`, `ADMIN=true`, `INHERIT=false`, `SET=false`. Nenhum membership ou privilégio alterado.
- **P4-A19 (documental):** desenho de uma única transação com associação temporária/SET LOCAL ROLE/GRANTs Django/restauração/REVOKE restrito/COMMIT, mas **SQL integral SUPERADO E NÃO EXECUTÁVEL** após revisão crítica P4-A20.
- **P4-A20 (documental):** corrigir postflight, pois `has_table_privilege(..., 'SELECT, INSERT, UPDATE, DELETE')` testa **qualquer** privilégio, não todos. Exigir verificações individuais positivas/negativas; inventário exato de 9 tabelas, ACL/grantor de objetos e colunas, direitos das 8 sequências Django e 5 Q0, integridade da associação `cloud_admin`, rollback e postflight independente. Não houve SQL conectado no A19/A20.
- **CP322 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP322.md`. Próxima **P4-A21**: elaborar script integral v2 e contrato de verificação **somente documental**, sem ativação ou GRANT/role/SQL mutante; gate nominal separado para qualquer operação no Neon. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.

## CP321 — PF-I04/P4-A12–A16 | oes_runtime criado e bloqueio de GRANT Django (2026-10-27)

- **P4-A13:** proprietário criou `oes_runtime` com senha privada no SQL Editor do Neon sintético (`weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox`). Preflight/postflight SELECT: LOGIN=true, NOINHERIT, sem atributos administrativos, **zero memberships**. Nenhum GRANT ou conexão runtime.
- **P4-A14:** 4 SELECTs catalogais: CONNECT=true, `public` USAGE=true/CREATE=false; `oes_app`, `core` e `investigation` USAGE=false/CREATE=false; `oes_runtime` sem DML/SELECT nas 9 tabelas Django e 5 tabelas Q0 e sem acesso às 8 sequências Django.
- **P4-A15/A16:** matriz candidata separa Django Auth/sessions (Bloco A) de Q0 (Bloco B), sem concessões. 3 SELECTs catalogais autorizados: `oes_sandbox_owner` pode conceder USAGE dos 3 schemas e DML nas 5 tabelas Q0, mas **não tem GRANT OPTION nas 9 tabelas Django** pertencentes a `oes_django_migrator`. Relação owner→migrator MEMBER=true, USAGE=false, SET=false. Bloco A bloqueado; não reativar migrador ou modificar membership/ownership automaticamente.
- **CP321 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP321.md`. Próxima P4-A17: comparar alternativas administrativas para GRANT nas tabelas Django **somente documental**, sem SQL/SET ROLE/GRANT. Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.

## CP320 — PF-I04/P4-A10–A11 | Django preparer gate offline reforçado (2026-10-27)

- P4-A10: desenho da identidade técnica `oes_runtime` candidata ainda não provisionada, matriz candidata de grants mínimos, separação de administração de contas e runtime. Permissão `evidence.prepare_question` criada no catálogo em P4-A9, mas não atribuída.
- P4-A11: `require_question_preparer` passou a exigir usuário autenticado, ativo, não staff, não superusuário, método `has_perm` válido e autorização explícita; testes offline legados adequados e testes negativos adicionais. CI GitHub Actions [40572406644](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40572406644) PASS 130/130 no commit `0bfda5a5bbe751b67b335fed44e2dabe84e45cde`. Nenhuma ligação Django runtime, SQL, usuário, papel, grant, HTTP write ou deploy foi habilitada.
- **CP320 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP320.md`. Próxima PF-I04/P4-A12: pacote nominal de identidade runtime e credencial, documental somente. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.

## CP319 — PF-I04/P4-A7–A9 | permissão prepare_question criada (2026-10-27)

- P4-A7: consulta READ ONLY no Neon sintético confirmou ausência de `evidence.prepare_question` em auth_permission/contenttype, sem ler usuários ou sessões. P4-A8: contrato administrativo idempotente. P4-A9: após autorização nominal, INSERT condicional executado por `oes_sandbox_owner`, preflight contenttype único e permissão ausente, `inserted_count=1`; postflight independente confirmou `evidence.prepare_question`, ID 41, contenttype `evidence.oesquestion`, 41 permissões totais. PASS.
- Sem atribuição a usuário, role/grant, migrations, Q0, HTTP, deploy ou E9. `oes_runtime` não provisionado; P4 operacional permanece NOT_AUTHORIZED.
- **CP319 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP319.md`. Próxima P4-A10 apenas documental para gate runtime/gestão segregada de contas. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED.

## CP318 — PF-I04/P4-A3–A6 | preflight e identidade Django runtime (2026-10-27)

- P4-A4: inspeção Neon READ ONLY na branch sintética oes-pg-a3-synthetic-20261024: migrador Django NOLOGIN, owner das 9 tabelas e 8 sequências oes_app; qprep login/writer têm SELECT e INSERT nas cinco tabelas Q0, mas não acesso às tabelas administrativas Django; oes_runtime não provisionado. Nenhum SQL mutante, dado pessoal ou científico lido.
- P4-A5: recomendado runtime PostgreSQL dedicado de privilégio mínimo, separado da administração de contas, sem criar role/grant; P4-A6: `evidence.prepare_question` exigida pelo serviço, mas existência no catálogo não comprovada; verificar registro e contenttype em consulta específica autorizada.
- **CP318 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP318.md`. Próxima atividade P4-A7: preparar gate de leitura restrita auth_permission/contenttype, sem DML. P4 NOT_AUTHORIZED; Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED.

## CP317 — PF-I04/P4-A1–A2 | contrato candidato Q0 autenticado (2026-10-27)

- Matriz de identidade e privilégios candidata consolidada: Django Auth/sessions, preparador individual e `actor_id=str(user.pk)`; uma identidade técnica runtime mínima ainda não definida/provisionada, privilégios administrativos locais são apenas experimentais. `DATABASES={}`, configuração de desenvolvimento, repositório e execução Q0 bloqueados.
- Primeira fatia proposta: login sintético, formulário GET/POST protegido, Q0 com cinco INSERTs atômicos, recibo e consulta read-after-write somente após commit; sem Q1/Q2/roteamento/E9. P4 não autorizado; não reutilizar migrador nem repetir P3b.
- **CP317 vigente:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP317.md`; próxima PF-I04/P4-A3 análise read-only da suficiência de identidade/ACL, exigindo gate próprio para acessos e mutações. Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## CP316 — PF-I04 | P3a/P3b tecnicamente concluídos (2026-10-27)

- Neon sintético `br-gentle-hall-b6jaxehf`/`oes_sandbox`: schema `oes_app` criado (P3a), migrations Django administrativas 15/15 PASS (P3b), CI [40555198917](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40555198917). Postflight independente: 40 permissões, 9 tabelas, 8 sequências, zero objetos Django em public.
- Após autorização explícita, `oes_django_migrator` recebeu NOLOGIN e perdeu CREATE em `oes_app`; 44 objetos próprios preservados, 15 migrations intactas. Usuário declarou segredo Actions descartável excluído; não verificado independentemente. Não repetir workflow P3b.
- **Checkpoint canônico CP316:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP316.md`; ponteiro atualizado. PF-I04/P4 não autorizado; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## CP315 — PF-I04-A2/P1 | isolamento Django local PASS (2026-10-27)

- CI [40541606299](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40541606299) no commit `a5cf31ab4652c5c6a93d09338732517d6b62caec`: PostgreSQL 16 descartável, 15/15 migrations PASS, 9 tabelas e 8 sequências em `oes_app`, 40 permissões, nenhum objeto Django em `public` no inventário. **Não é Neon nem autorização P3.**
- Parecer e matriz candidata de privilégios: `docs/governance/330-pf-i04-a2-p1-parecer-isolamento-e-gates-p3.md`. Alternativa B aprovada arquiteturalmente; P3 DDL/migrations, grants e P4 uso funcional continuam sujeitos a aprovações específicas.
- **Checkpoint vigente CP315:** `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP315.md`. Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## PF-I04-A2 — preflight catalogal não mutante da alternativa B (2026-10-27)

- Neon: projeto weathered-boat-65779510, branch sintética br-gentle-hall-b6jaxehf, banco oes_sandbox. Consulta somente SELECT confirmou schemas core, investigation, public; schema candidato oes_app ainda ausente. Conexão de inspeção reportou current_user=oes_sandbox_owner; nenhum SQL mutante executado.
- Roles: oes_qprep_login pode login, não possui CREATE no banco nem em public e possui USAGE em investigation; oes_pg_a4_reader não possui CREATE no banco/public nem USAGE em investigation; proprietário dispõe dos privilégios administrativos. Esses achados não significam que qualquer identidade esteja aprovada para migrations ou uso Django operacional.
- Alternativa B permanece candidata: isolar Django Auth/sessões em schema dedicado, distinguir papel transitório de migração e identidade runtime mínima, validar search_path/migrations e segurança antes de execução. Não criar schema, migrations, grants, credenciais ou rotas. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY.

## PF-I04-A2 — inventário Neon e decisão de isolamento Django (2026-10-27)

- Consulta não mutante via catálogo Neon: projeto weathered-boat-65779510, branch sintética br-gentle-hall-b6jaxehf, database oes_sandbox. A tabela investigation.question_version possui normalized_text nullable, preparation_stage e CHECK ck_pf_i02_question_preparation_stage; investigation.question_command_receipt dispõe de PK (actor_id,request_id), fingerprint e CHECK para REGISTER_Q0/PROPOSE_Q1. Não criar ou repetir DDL Q0.
- O inventário de tabelas da branch não exibiu tabelas Django auth_user/django_session. Django config ainda DATABASES={} por padrão; armazenamento de login/sessões e mapeamento de responsável não definidos. Recomendar isolamento das tabelas Django em área/esquema de aplicação ou base separada antes de migrations, sem criar agora. Não presumir que o Neon aceita migração padrão sem desenho de schema/search_path e grants.
- Próximo gate: especificar escolha entre banco/namespace Django separados e conexão de app com privilégios mínimos, ciclo de contas sintéticas, política de sessão/CSRF e read-after-write; submeter plano de migrations e conexão a aprovação específica. Nenhum SQL, DDL, DML, grants, segredos ou HTTP write executado. Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY.

## PF-I04-A2 — autorização de avanço e fronteira de execução (2026-10-27)

- O responsável autorizou prosseguir com PF-I04-A2 após o diagnóstico do Documento 316-PF-I04-A1. A autorização cobre preparação e desenvolvimento controlado da primeira fatia funcional Q0, **não** revoga gates específicos existentes para conexão/SQL, migrations, criação de usuários reais, roles/grants, secrets, escrita HTTP pública ou deploy.
- Impedimentos confirmados no código: `DATABASES={}` por padrão, configuração de desenvolvimento, ausência de sessão/login respaldados por banco; `DjangoQ0Repository.__init__` bloqueia instanciação; `execute_connected_q0` bloqueia execução. Não contornar esses bloqueios por alterações implícitas.
- Próximo passo operacional necessário: contrato de localização e isolamento das tabelas Django Auth/sessões, identidade responsável e reader/writer de privilégio mínimo; inspeção não mutante do esquema Q0 existente e procedimento de segurança/rollback. Somente depois, solicitar aprovação nominal da primeira conexão/mutação técnica com destino e escopo exatos. Não repetir testes puramente sintéticos sem lacuna específica.
- CP314 canônico; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## PF-I04 — diagnóstico inicial do piloto funcional (2026-10-27)

- Revisão PF-05/06/08/09: Django Auth e permissão evidence.prepare_question existem apenas como arcabouço offline; Unit of Work e ORM/recibos estão comprovados experimentalmente, não como fluxo durável de usuário; settings.py contém DEBUG e chave de desenvolvimento, DATABASES={} por padrão e leitor PG-A4 opcional somente leitura; procedimentos de CI não equivalem a operação/recuperação do piloto.
- Prioridade candidata PF-I04: preparador autenticado utiliza Django para Q0, Q1, Q2/roteamento preliminar e consulta de estados/histórico, sem E9. Primeiro definir contrato mínimo do usuário, identidade, persistência, ambiente, autorização e rollback, antes de implementar. Respeitar Docs. 287 e 288: uma identidade de aplicação pode bastar no piloto; não construir workarounds de produção ou novo mecanismo de autenticação. Nenhuma operação conectada aprovada nesta análise.
- PF-I03 permanece CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY (CI 40535916973, 201/201 PASS). CP314 canônico; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## PF-I03 — fechamento técnico offline (2026-10-27)

- CI 40535916973: commit dac5ab536116e0abf1b47c72767bd1eb8b12e23e; 201/201 testes PASS. Teste de composição sequencial Q0-Q1-Q2-roteamento PASS; Django check PASS.
- Classificação: CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY. Q2 e roteamento são propostas não persistidas; sem HTTP mutante, usuários reais, PostgreSQL operacional, revisão científica A3 ou abertura E9.
- Prioridade: analisar dependências operacionais PF-05 (identidade), PF-06 (persistência), PF-08 (segurança) e PF-09 (operação). Nenhuma implementação ou mudança de gate autorizada nesta etapa. CP314 canônico; Marco B OPEN; E9 NO-GO; G2-P2B operacional NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## PF-I03-A3 e PF-I03-A1–A3 — encerramento técnico integrado restrito (2026-10-27)

- **PF-I03-A3 CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY:** [CI 40535205792](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40535205792), commit `12279a64b76aa76c6fd5df901c3cc8af713db287`, `completed/success`: **200/200 PASS**, dos quais **8/8 PF-I03-A3**, e Django system check PASS. A projeção Q2/roteamento restringe identificação sintética, vínculo a readback Q1/versionamento, classificação N0–N4/M0–M3 e justificativa; admissibilidade NOT_DECIDED, investigação NOT_OPENED e E9 BLOCKED.
- **Parecer integrado PF-I03-A1–A3: CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY para demonstração preparatória sintética em camadas**, com A1 Q0 (7/7 testes), A2 Q1 (8/8) e A3 Q2/roteamento (8/8). **Limitação material:** a função A3 recebe projeção Q1 injetada; os testes A3 utilizam readback fabricado, sem teste ponta-a-ponta executando em uma única sequência A1→A2→A3. Não denominar esse conjunto fluxo operacional integrado comprovado. Q2/roteamento não possui comando de escrita transacional nem backend; nenhuma autorização científica, operação E9, usuários reais ou SQL persistente.
- **Decisão de proporcionalidade:** não adicionar novas camadas ou testes apenas por contagem. Próximo passo recomendado é avaliação funcional curta do percurso completo com os componentes existentes, e, somente se necessário à aceitação do piloto, um teste offline de composição A1→A2→A3 sem banco e sem novos serviços; em paralelo permanecem pendências reais PF-05/PF-06/PF-08/PF-09 para operação. CP314 canônico; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## PF-I03-A3 — diagnóstico Q2 e Routing Record (2026-10-27)

- Templates canônicos `templates/question-record.md` e `templates/routing-record.md` confirmam separação de Q2 (pergunta operacional, critérios de elegibilidade/busca/análise e contexto) de Routing Record (classe metodológica, criticidade, complexidade, profundidade N0–N4, manutenção M0–M3 e justificativas). Admissibilidade e autorização de abertura E9 são controles independentes.
- Modelos Django existentes possuem `question_type`, `structure_type`, `context_payload`, `time_horizon_payload`, mas não há contrato de comando Q2 nem serviço de roteamento autorizado. Não supor mapeamento integral nem criar schema.
- **Próximo incremento candidato:** projeção offline não persistente de Q2 e de proposta de roteamento, reutilizando o histórico Q0/Q1 e contratos documentais; entrada explícita e justificada, ausência de abertura de Investigation ou invocação E9, testes negativos proporcionais. Sem implementar nesta atividade. CP314 canônico; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.

## PF-I03-A2 — encerramento técnico restrito (2026-10-27)

- **CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY:** [CI 40534194664](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40534194664) em `aa89f44523d0fa0c64fc7637221fb147a26eae8c`, `completed/success`: **192/192 testes PASS**, incluindo **8/8 PF-I03-A2**; Django system check PASS e compilação Q0 PASS. Q0→Q1 sintético na Unit of Work offline, versão 2, original preservado, normalização/justificativa propostas, autorização, conflitos e idempotência testados. Nenhum HTTP mutante, conexão SQL, operação persistente ou revisão científica.
- **Próxima atividade PF-I03-A3, exclusivamente análise de contrato:** examinar `templates/question-record.md` e `templates/routing-record.md`, separar Q2 (estruturação e proposta metodológica) da decisão de roteamento, explicitar campos, autoria, estado provisório e fronteira E9. Comparar com Django atual antes de qualquer implementação; não inventar autorização de Q2 conectado, revisão A3 ou abertura de investigação. CP314 canônico; G2-P2B operacional NO-GO, E9 NO-GO, Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED.

## PF-I03-A2 — diagnóstico de escopo Q1/Q2 (2026-10-27)

- **Revisão do código:** `QuestionCommand` + `submit_question_command` + `OfflineQuestionUnitOfWork` já suportam `PROPOSE_Q1` com `normalized_text`, justificativa, preservação do original, versão esperada, controle de escopo, idempotência e conflito. `PF-I03-A1` encerrado 184/184 PASS. Não duplicar serviços ou adaptadores.
- **Próximo incremento recomendado (ainda não implementado):** apresentação offline de Q1 usando a mesma UoW injetada, com Q0 sintético precedente e prova de versão 2, original intacto, justificativa, autorização e rejeição por conflito/replay indevido. Q2 e Routing Record permanecem documentais e fora do contrato operacional; E9 bloqueado. Nenhuma rota HTTP POST, SQL conectado, sessão real ou alteração de gates. CP314 vigente; Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY.

## PF-I03-A1 — encerramento técnico restrito (2026-10-27)

- **CLOSED_TECHNICAL_RESTRICTED_OFFLINE_ONLY:** CI [40530802923](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40530802923), commit `556cd56fe6990cfa54005a351c5931e765785aff`, `completed/success`: **184/184 PASS**, incluindo **7/7 testes PF-I03-A1**, compilação dos módulos Q0 e Django system check PASS. A apresentação sintética Q0 reutiliza `QuestionCommand`, autorização por permissão e `OfflineQuestionUnitOfWork` injetada, com recibo `PREPARATORY_ONLY`, estado de revisão científica `NOT_PERFORMED` e E9 `BLOCKED`. Não cria rota HTTP de escrita ou conexão SQL.
- **Limites:** sem usuários reais, persistência durável, autenticação de aplicação integrada, Q1/Q2 funcional no piloto, fluxo E9, deploy ou decisão científica A3. Próximo incremento candidato: integrar apresentação das transições Q1 (normalização proposta) e delimitar Q2/roteamento sem execução, aproveitando o serviço/UoW existente e controles de replay/escopo; primeiro inventariar o contrato Q2 e suas dependências, sem implementá-lo por inferência. CP314 permanece canônico; Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Fase 5 NOT_STARTED.

## PF-I03-A1 — contrato candidato para primeiro fluxo Django integrado (2026-10-27)

- **Proposta, não autorização de implementação:** reutilizar `QuestionCommand`/`submit_question_command`, `require_question_preparer` e `OfflineQuestionUnitOfWork` para preparar Q0 sintético e apresentar somente `question_id`, `version` e `PREPARATORY_ONLY` mediante Unit of Work injetada em testes; preservar bloqueio sem UoW e negar acesso por padrão. Nenhuma rota pública POST, sessão real, escrita PostgreSQL, Q1/Q2 funcional ou E9 nesta delimitação.
- **Critérios mínimos candidatos:** usuário anônimo/sem permissão negado; Q0 válido recebe recibo sintético e versão 1; entrada inválida/versão conflitante em HOLD; replay sem bypass de autorização; GET documental N2 e rotas 404 de escrita preservados. Priorizar regressões offline proporcionais, sem reconstruir auth, ORM ou framework. CP314 canônico, G2-P2B operacional NO-GO, E9 NO-GO, Marco B OPEN, readiness NOT_READY.

## CP314 — 2026-10-27 (checkpoint canônico; credencial descartável encerrada por confirmação)

- **Secret:** o proprietário confirmou a exclusão de `OES_QPREP_LOGIN_PASSWORD` no GitHub Actions e anteriormente a rotação da senha de `oes_qprep_login`. Declaração do proprietário, sem auditoria independente. Encerrar o ciclo dessa credencial; não solicitar senha no chat nem repetir o workflow experimental sem novo propósito e controle específico.
- **Ensaio Q0 sintético conectado encerrado PASS:** run 40525954698 tentativa 2, cinco INSERTs intratransacionais, rollback e zero resíduos. CP314 em `archive/handoffs/oes/OES_Continuidade_2026-10-27_CP314.md` passa a ser referência de continuidade. Próxima prioridade: reavaliar macroatividades e os critérios do Marco B, sem reabrir teste redundante. G2-P2B operacional NO-GO, E9 NO-GO, Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED.

## Encerramento técnico formal — OES G2-P2B — 2026-10-27

- **ENCERRADO COM SUCESSO exclusivamente o ensaio transacional conectado sintético Django ORM Q0.** Evidência [GitHub Actions 40525954698, tentativa 2](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40525954698): papel restrito `oes_qprep_login`, cinco INSERTs verificados na mesma transação, rollback obrigatório, zero resíduos verificados após rollback; `PASS_ROLLED_BACK_ZERO_RESIDUES`. O primeiro acionamento e a primeira tentativa desse run falharam por `OperationalError` antes das inserções. A CI offline no commit `29af77e28722973dc75319bb4a9bbb6525d0e19b` registrou 177/177 PASS e compilação dos módulos instrumentados.
- **Fronteira de encerramento:** este marco encerra a prova experimental restrita, NÃO abre o gate de escrita operacional G2-P2B, não prova persistência, não promove Marco B ou readiness, não autoriza serviço HTTP, E9, migrações, usuário real ou deploy. G2-P2B operacional NO-GO; E9 NO-GO; Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED.
- **Credencial:** o proprietário informa rotação da senha. A exclusão do secret GitHub não é condição técnica para encerrar a evidência de rollback: mantê-lo com senha atualizada é possível, porém preserva capacidade de acesso a partir de workflows; a postura recomendada para credencial descartável sem novo uso aprovado é excluí-lo. **Não há confirmação do estado atual do secret**; não declarar exclusão/atualização como comprovada. Recomenda-se não repetir o workflow de ensaio já encerrado. CP313 preservado como checkpoint canônico.

## Evidência conectada CP313 — 2026-10-27 — Q0 rollback PASS (sem promoção de gate)

- **G2-P2B ensaio sintético conectado PASS:** [GitHub Actions 40525954698, tentativa 2](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40525954698), commit `29af77e28722973dc75319bb4a9bbb6525d0e19b`, `completed/success`. Logs registram conexão, identidade restrita, início da transação, cinco INSERTs ORM, verificação intratransacional, rollback obrigatório e cinco consultas pós-rollback sem resíduos; marcador `PASS_ROLLED_BACK_ZERO_RESIDUES`. Evidência restrita a uma execução sintética, não equivale a habilitação permanente de DML, HTTP, E9 ou deploy.
- Tentativa 1 do mesmo run falhou antes da conexão; o proprietário confirmou atualização do secret após rotação de senha, sem verificação de conteúdo pelo assistente. **Ação pendente do proprietário:** excluir `OES_QPREP_LOGIN_PASSWORD` do GitHub Actions e rotacionar novamente a senha descartável no Neon. Nenhuma senha registrada. G2-P2B como gate operacional ainda NO-GO até deliberação explícita; E9 NO-GO, Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED. CP313 permanece canônico.

## Atualização factual CP313 — CI Django offline de 2026-10-27

- CI manual [40521292336](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40521292336), commit `2325b7c192985220ca5a9476ea25531e8e07d6a9`: 177/177 testes Django offline PASS, incluindo três testes de preflight Q0, UUIDs e bloqueios; system check PASS. Não houve INSERT ou rollback conectado nesta CI.
- G2-P2B permanece NO-GO. Proposta pendente de autorização nominal: uma única transação Django ORM Q0 com cinco INSERTs sintéticos, usando `oes_qprep_login` em `oes_sandbox` na branch sintética `br-gentle-hall-b6jaxehf`, rollback obrigatório e checagem de zero resíduos. Antes, revisar executor experimental segregado. Proibidos owner, commit de dados, DDL, grants, credenciais no repositório, usuários reais, deploy e HTTP write. E9 NO-GO; Marco B OPEN; readiness NOT_READY. CP313 continua canônico.

## Marco de continuidade CP313 — 2026-10-27 (evidência posterior; checkpoint CP313 preservado)

- **Django READ ONLY conectado PASS:** execução manual [40506158071](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40506158071), tentativa 1, concluída com sucesso em 2026-10-27, commit `43037dd2ac56adbe8e455aaceb6b31e6ff481924`. O script Django/PostgreSQL verificou `session_user=current_user=oes_qprep_login`, DB `oes_sandbox`, `transaction_read_only=on`, `default_transaction_read_only=on`, atributos não administrativos, herança de `oes_qprep_writer` sem `SET ROLE` e ausência de vínculo com `neon_superuser`. Evidência factual restrita ao login conectado e consultas de catálogo, não à execução Q0.
- **Credencial descartável encerrada por confirmação do proprietário:** informou exclusão do secret `OES_QPREP_LOGIN_PASSWORD` no GitHub Actions e rotação manual da senha no Neon. Confirmação declaratória, sem verificação independente de exclusão/rotação; não armazenar senha ou recriar role.
- **Próxima ação proposta, NÃO autorizada para execução:** delimitar ensaio Django ORM Q0 sintético de cinco registros com transação `atomic`, rollback explícito e checagem posterior de zero resíduos, usando somente identidade mínima, configuração temporária, branch sintética e autorização nominal independente. `question_orm_q0_repository_dormant.py` e `question_orm_q0_connected_recipe_dormant.py` permanecem bloqueados. Nenhum DML, DDL, grant, alteração de role, deploy ou ativação HTTP nesta consolidação. G2-P2B NO-GO, E9 NO-GO, Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED; Fase 4 encerrada metodológica/documentalmente. CP313 continua canônico.

## Marco de continuidade CP313 — 2026-10-26 (vigente)

- **Django-first confirmado; testes com perfil correto, nunca owner.** A identidade restrita `oes_qprep_login` foi recriada pelo usuário no SQL Editor com senha descartável e herança de `oes_qprep_writer`; Neon verificou atributos não administrativos, ausência de associação a `neon_superuser` e SELECT+INSERT (sem UPDATE/DELETE de tabela) nas cinco tabelas. **Autenticação Django real ainda não testada**, e a senha é rotacionada manualmente pelo usuário após testes, mediante confirmação. Tentativa Neon API com grants superuser foi excluída; não repetir.
- CI [40287856367](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40287856367) **174/174 PASS**, SHA `2660f98e9444935b78450b394b458e0e9592a374`; módulos ORM e rollback ainda dormentes, sem transação conectada demonstrada. Docs 355–359. Próximo passo: autenticação Django READ ONLY e confirmação de identidade, somente após verificar viabilidade operacional, sem credencial em chat/repo.
- CP313 canônico; G2-P2B NO-GO, Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO. Fase 4 encerrada somente metodológica/documentalmente.

## Marco de continuidade CP312 — 2026-10-26 (histórico)

- PF-I02/P2 Django-first: avanços offline Q0/ORM acumulados de 150/150 para **167/167 PASS**, última CI `40285338405` no SHA `35b90cb52ab7737d001c476fa1fb03567fd6f6e2`. Docs.350–354: suficiência e integração ORM, proposta do ensaio, G2-P0 factual READ ONLY e G2-P1 de código somente autorizado, repositório Q0 **dormente** com consultas de escopo, recibo e advisory locks. G2-P0 confirmou no Neon apenas catálogo/permissões em `oes_sandbox`; sessão `oes_sandbox_owner`, papel-alvo `oes_qprep_writer NOLOGIN` com INSERT+SELECT nas cinco tabelas, UPDATE restrito a duas colunas de `core.entity_version`. **G2-P2 não autorizado**; não houve DML conectado, SET ROLE, writer Django ou ativação de Q0. CP312 canônico, Marco B aberto, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO.

## Marco de continuidade CP311 — 2026-10-26 (histórico)

- PF-I02/P2: consolidação arquitetural **Django-first, exclusivamente offline**. Cinco modelos `managed=False`, ledger com PK composta e planos de QuerySets para Q0→Q1 compilados sem conexão. CI `40281783742`: 146/146 PASS (SHA `87af14c7c24be06c560704dc85419b49cd6ef4b1`); CI `40282204788`: **150/150 PASS** (SHA `d8612a6172f6f90d794c6cf141d1456b61d4f720`). Docs.343–349 registram G1 READ ONLY, contrato de concorrência/revogação, decisão Django-first e limitações ORM. Adaptador SQL preservado como evidência experimental, não implementação operacional. G2 **não autorizado**, sem writer, DML/DDL conectado, usuários reais, HTTP write ou E9; Marco B aberto, readiness NOT_READY, Fase 5 NOT_STARTED. CP311 canônico.

## Marco de continuidade CP310 — 2026-10-26 (histórico)

- PF-I02/P2: encerramento **técnico restrito, sintético e offline** do fluxo Q0→Q1, incluindo ledger, rollback e replay em cursores injetados. CI GitHub Actions `40277043796`, commit `a18f90575ae8ede0ac7bce779623e980c86c5ede`, 140/140 testes PASS, Django check OK. Auditoria Doc.342, handoff CP310: pendências de concorrência/locks PostgreSQL, factory transacional conectada, ACL e isolamento multiusuário, `change_type` Q1, conflitos globais e vínculo UUID; nenhum gate conectado liberado. Marco B aberto, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO.

## Marco de continuidade CP309 — 2026-10-26 (histórico)

- PF-I02/P2: Documento 341 registra encerramento técnico exclusivamente offline do fluxo Q0 com transação e ledger simulados. GitHub Actions 40275424108, commit `d2a531b1cf480920f17c2b7123a385b78b93e6ec`: 126/126 testes PASS e Django check OK. `propose_q1` e recibo Q1 seguem HOLD; replay conectado, concorrência real e isolamento multiusuário não demonstrados. A migração sintética de responsabilidade está documentada em Doc.338; nenhuma escrita SQL conectada foi autorizada. Marco B aberto, readiness NOT_READY e E9 NO-GO.

## Marco de continuidade CP308 — 2026-10-26 (histórico)

- PF-I02-P2-A9: migração sintética aprovada e aplicada na branch Neon `br-gentle-hall-b6jaxehf`, DB `oes_sandbox`: `investigation.question.responsible_actor_id text NULL` e CHECK de comprimento 1–128 (ou NULL), pre/post READ ONLY confirmados. Documento 338; sem DML/backfill, grants, SET ROLE, Django, HTTP ou E9. Papel writer NOLOGIN permanece com ACL W2a. Adaptador SQL offline parcial, CI anterior 40271463247: 109/109 PASS; política por registro e revogação concorrente ainda sem validação conectada. CP308 ativo; Marco B aberto, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO.

## Marco de continuidade CP307 — 2026-10-26 (histórico)

- Documento 336 registra política experimental aprovada PF-I02-P2-A5: criador de Q0 como responsável único inicial, revalidação de responsabilidade vigente para Q1/replay, ledger imutável. Sem Neon/SQL/DDL/DML; fonte persistente não identificada, catálogo read-only futuro requer autorização nominal. P2 SQL offline parcial (CI 40271463247: 109/109 PASS). Marco B aberto, readiness NOT_READY, E9 NO-GO.

## Marco de continuidade CP306 — 2026-10-26 (histórico)

- PF-I02-P2: GitHub Actions 40271463247 completed/success, Django check PASS, 109/109 testes offline PASS incluindo 9 do adaptador SQL injetado; falha de sintaxe da primeira CI 40271314159 corrigida antes. P2 ainda parcial: `can_access_question`, `current_question` e escritas Q0/Q1/ledger em HOLD até identificação de vínculo autorizativo confiável preparador↔pergunta. Nenhum SQL conectado, SET ROLE, DML, credencial ou HTTP. CP306 ativo; readiness NOT_READY e E9 NO-GO.

## Marco de continuidade CP305 — 2026-10-26 (histórico)

- Documento 335: W2a encerrado tecnicamente em escopo restrito após criação autorizada de `oes_qprep_writer NOLOGIN` e grants mínimos verificados por catálogo READ ONLY. Membership administrativa automática compatível com PostgreSQL (`oes_sandbox_owner` membro do writer, ADMIN TRUE / INHERIT FALSE / SET FALSE, concedente cloud_admin); sem alteração corretiva. Writer e ACLs permanecem na branch sintética. Runtime, SET ROLE, DML, W2b/W3 e E9 continuam bloqueados; Marco B aberto e readiness NOT_READY. CP305 ativo.

## Marco de continuidade CP304 — 2026-10-26 (histórico)

- PF-I02-W2a: pacote candidato e recuperação controlada documentados no CP304; preflight Neon A2 exclusivamente READ ONLY confirmou cinco tabelas, writer ausente, sem RLS, ACL pública de CONNECT no DB, trigger SECURITY INVOKER e concessões preexistentes PG-A4. Nenhum CREATE ROLE, GRANT, REVOKE, SET ROLE ou DML executado. Provisionamento segue HOLD até autorização nominal. E9 NO-GO, readiness NOT_READY.

## Marco de continuidade CP303 — 2026-10-26 (histórico)

- Handoff de encerramento: Docs. 333–334 lidos, política de leitura de writer definida apenas como design; W2A_RUNTIME_HOLD; papel de writer não criado, ledger sintético criado, sem HTTP ou E9. Novo ponto de retomada no CP303.

## Marco de continuidade CP302 — 2026-10-26 (histórico)

- Doc.331: DDL do ledger sintético verificado; metadados READ ONLY confirmam writer inexistente e ausência de RLS; CP302 vigente. Nenhum novo GRANT, DML ou Django; E9 NO-GO, readiness NOT_READY.

## Marco de continuidade CP301 — 2026-10-26 (histórico)

- Docs. 321–329: contrato Django Q0→Q1 e Unit of Work offline, replay reautorizado e justificativa Q1 em recibo simulado; CI 40266729081 success. PostgreSQL writer/ledger e HTTP pendentes, E9 NO-GO, readiness NOT_READY.

# STATE — Estado Atual do Projeto OES

**Última atualização:** 25 de outubro de 2026  
**Fase 4 — Protocolo de Atualização:** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` (readiness operacional `NOT_READY`)  
**Fase 5:** `NOT_STARTED`  
**Status geral:** projeto em desenvolvimento; protocolo da Fase 4 encerrado apenas metodológica/documentalmente; D1 demonstrador sintético encerrado restritamente; D2 factual parcial


## Marco de continuidade CP300 — 2026-10-26 (histórico)

- Documento 319: teste transacional sintético PF-I02-I01-D0 Q0→Q1, com versões e supersessão verificadas em branch sintética Neon, seguido de cleanup preciso e zero resíduos. Não comprova autenticação independente, concorrência, idempotência ou Django HTTP. CP300; E9 NO-GO e readiness NOT_READY.

## Marco de continuidade CP299 — 2026-10-26 (histórico)

- Documento 317: migração sintética Q0-only aprovada e aplicada no Neon sandbox branch br-gentle-hall-b6jaxehf; preflight e postflight READ ONLY, sem DML, grants ou Django. Q0→Q1 operacional não implementado; Marco B aberto, E9 NO-GO, readiness NOT_READY.

## Marco de continuidade CP298 — 2026-10-25 (histórico)

- PF-I02 G1–G3 consolidado Docs. 306–310; Doc. 311 define pacote único de implementação Q0→Q1 em fases A–D, com primeiro gate offline Django auth code only ainda sujeito a autorização expressa. Nenhuma escrita SQL, identidade real, grants ou deploy autorizados. CP298. Marco B aberto; E9 NO-GO, readiness NOT_READY.

## Marco de continuidade CP297 — 2026-10-25 (histórico)

- Documento 305: PF-I01 GET-only N2 histórico encerrado em âmbito técnico offline restrito após PF-I01-R1 e CI 40243932508 success; sem validação humana ou operação conectada. Próximo: analisar fluxo de preparação Q0–Q2 com gates e persistência, inicialmente read-only. Marco B aberto e readiness NOT_READY.

## Marco de continuidade CP296 — 2026-10-25 (histórico)

- Documento 304: PF-I01 implementado como consulta N2 GET-only offline no Django. Snapshot original preservado sob hash; CI Django 40243303174 success; sem integração DB, E9 ou A3. Aceite AC01–AC10 ainda não exaustivo, AC03 vinculativo no endpoint parcial. Próximo: inspeção proporcional dos critérios e apresentação antes de ampliar funcionalidade.

## Marco de continuidade CP295 — 2026-10-25 (histórico)

- Documento 300/M2-A7: mudança aprovada de prioridade, de demonstrações isoladas para planejamento de piloto técnico-funcional mínimo integrado, sem implementação autorizada. Critérios candidatos PF-01–PF-10; E9 NO-GO, Marco B aberto, readiness NOT_READY. Próximo: inventário read-only de rotas Django, contratos, persistência e serviços versus PF-01–PF-10.

## Marco de continuidade CP294 — 2026-10-25 (histórico)

- Documento 299 consolida M2-A1–A6; histórico Q–I–P explicitamente vinculado e CI offline 40237401239 SUCCESS, escopo restrito; E9 NO-GO; Marco B aberto e readiness NOT_READY. Próximo: auditoria dos critérios de encerramento do Marco B.

## Marco de continuidade CP293 — 2026-10-25 (histórico)

- Documento 298: F2-A1–A5 encerrada somente como preparação documental Q0/Q1/Q2 e roteamento. E9 abertura formal NO-GO, sem autorização/gate comprovados. Próximo diagnóstico: reavaliar macroatividades restantes do Marco B. CP292 preservado como antecedente.

## Marco de continuidade CP292 — 2026-10-25 (histórico)

- **Documento 297:** M1-A9–A11, verificação documental N2 (histórico 6 PASS/2 PARTIAL, versão atual reproduzida via CI offline 40226403431 success). Alternativa A encerrada **apenas no escopo funcional documental interno**; sem pesquisa com usuários, revisão A3, publicação externa ou prontidão operacional. Próxima: inventário documental read-only F2 (preparação de questão/investigação).

## Marco de continuidade CP291 — 2026-10-25 (histórico)

- **Documento 296**: Alternativa A consulta documental controlada N2 aprovada; E01–E04 e testes publicados. CI offline N2 40225338793 PASS isolado; S5 amplo 40221429351 FAIL em gate temporal B1R1 histórico, não imputável à etapa F3-TEMPLATE/RC01. Fechamento editorial restrito, sem A3, publicação externa, produção operacional ou Django. Próxima atividade: roteiro de avaliação funcional controlada.

## Marco de continuidade CP290 — 2026-10-25 (histórico)

- **Documento 295** consolida M1-A1–M1-A4: 9/9 produtos Fase 3 formalizados, Ficha N2 (Caso dCBT-I A2/documentado) candidata a F1 consulta, reaproveitar `EvidenceSheetView`, template, renderizador; template atual v0.2 não herda automaticamente PASS histórico v0.1. Nenhuma implementação F1 aprovada, Django atual não demonstrou rota N2. Próxima: comparar alternativas de primeiro uso funcional. Marco A demonstração restrita encerrado, Marco B piloto amplo aberto; readiness `NOT_READY`, Fase 5 `NOT_STARTED`.

## Marco de continuidade CP289 — 2026-10-25 (histórico)

- **Documento 294** formaliza parecer **P3-A3 aprovado**: suficiência técnico-demonstrativa **restrita** P1/P2 reconhecida (Marco A), com matriz P3-R01–R11 e critérios P3-S01–S06; **piloto OES amplo (Marco B) não encerrado**. P3 documental, sem novas CI, serviços, testes ou código. Próximo: reavaliação proporcional das macroatividades remanescentes. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`; avaliação científica humana diferida.

## Marco de continuidade CP288 — 2026-10-25 (histórico)

- P2 concluído **exclusivamente em escopo técnico restrito de apresentação sintética segregada Django** (Doc. 293). Run Django [40217150462](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40217150462) e Chromium [40217256102](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40217256102) terminaram `completed/success` no SHA `3901787f9c6a8d177f236f30310624d4a993a402`; totais internos não extraídos e screenshots individuais não inspecionadas. Próxima atividade **P3-A1**, inventário de suficiência, ainda sem código nem autorização operacional. Piloto aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`; revisão científica externa diferida.

## Marco de continuidade CP287 — 2026-10-25 (histórico)

- P2-A1 inspecionou a necessidade de apresentação; P2-A2 recomendou B e obteve aprovação expressa do responsável em modo médio; P2-A3 formalizou **Documento 292** (página Django sintética separada somente leitura, offline, sem execução dinâmica), com critérios P2-AC01–P2-AC08. **Nenhum código implementado, nenhum teste novo, nenhum acesso conectado.** Próxima atividade P2-A4: preparar especificação mínima para autorização separada. CP287 vigente, HEAD no commit de publicação; piloto ainda aberto; ciência diferida, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.

## Marco de continuidade CP286 — 2026-10-25 (histórico)

- Novo handoff preventivo `archive/handoffs/oes/OES_Continuidade_2026-10-25_CP286.md`; base técnica anterior `ca9a66edc14349d24a7c21d4439460a99b8d688c`. P1-A3 `CLOSED_TECHNICAL_RESTRICTED_OFFLINE` (Doc. 291; Actions [40214460778](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40214460778) 107/107 PASS, oito novos testes PASS). Django documental `CLOSED_TECHNICAL_RESTRICTED_DOCUMENTARY_DEMONSTRATOR` (Doc. 289; Django 50/50 PASS e Chromium 9/9 PASS). **Próximo passo é P2-A1: especificar contrato mínimo de projeção sintética segregada no Django, sem codificar antes de exame e autorização proporcional**. Nenhuma integração real Django ↔ P1-A3 foi demonstrada por HTTP. Ausência atual de pesquisadores não bloqueia desenvolvimento; validação científica externa diferida (Doc. 290). Factual GET, Neon conectado/escrita, workflow factual e gastos continuam bloqueados. Piloto integrado não encerrado, Fase 4 documental apenas, readiness NOT_READY, Fase 5 NOT_STARTED.

## P1-A3 — Encerramento técnico restrito / Documento 291

- Integração sintética offline E6 → D1 → domínio documental Django: CI [40214460778](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40214460778), **107/107 PASS**, oito novos testes PASS. Corrigida chave `event_log` do replay D1 no commit `3c9672e0`. Estado `CLOSED_TECHNICAL_RESTRICTED_OFFLINE`. Sem gravação PostgreSQL ou consulta factual. **Próxima atividade: especificar a projeção sintética segregada no Django (P2), sem implementação automática.** CP285 permanece checkpoint vigente.

## Nova prioridade funcional sem pesquisadores — Documento 290 / 2026-10-25

- Não há pesquisadores vinculados disponíveis para validação externa; tal validação fica **diferida, não dispensada**, sem bloquear engenharia sintética e documental. Prioridade aprovada: **P1 integração sintética offline ponta a ponta** (primeiro inventário de interfaces e contratos existentes); **P2** apresentação Django integrada somente após P1; **P3** demonstração de suficiência técnico-funcional com testes. Não exigir captura factual nem PostgreSQL conectado para iniciar P1; manter fronteira científica e proibição de relações inventadas. **Próximo passo:** mapear interfaces E6, domínio e serviços de demonstração, com escopo mínimo e critérios de aceite; nenhuma autorização de escrita, conexão ou deploy implícita.

## Encerramento restrito Django — Documento 289 / 2026-10-25

- Refinamento editorial e demonstrador documental Django declarados **CLOSED_TECHNICAL_RESTRICTED_DOCUMENTARY_DEMONSTRATOR** após verificações no HEAD `2c7df6d0538cf0be06a44e10b49e4d9dc3a72af5`: Django [40196984551](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40196984551) 50/50 PASS; Chromium [40197070277](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40197070277) 9/9 PASS, artefato visual preservado temporariamente, capturas individuais não inspecionadas. Suficiência estritamente documental dos dois casos existentes; não equivale a avaliação por pesquisadores, piloto integrado encerrado ou readiness. Próxima prioridade: preparar roteiro de demonstração/avaliação externa, sem contato ou divulgação não autorizada. CP285 permanece ponteiro vigente até checkpoint posterior.

## Marco de continuidade CP285 — 2026-10-25 (vigente)

- Macroatividades do piloto reclassificadas conforme Documento 288: essenciais a jornada documental de evidência, identidade, vínculo Study–Report, proveniência, limites e demonstração; integração conectada PostgreSQL e autenticação definitiva diferíveis conforme necessidade efetiva, sem dispensar gates de segurança para eventual execução. Captura factual segue bloqueada.
- Auditoria Django (código, fixtures, templates, CSS e script Chromium): rotas `/`, `/signals/NCT01438697/` e `/signals/NCT07836491/`; estados de identidade explícitos; relatório múltiplo do mesmo estudo apenas quando documentado; fontes dos Docs. 247/248/products/154; limitações da revisão científica. Avaliação por inspeção, não homologação científica nem prova de navegador executado nesta etapa.
- Refinamento editorial aprovado e publicado: commit `359a8d3cd5f8883db4fd8d4f8cba766f462ea81f`, **somente** catálogo, detalhe e CSS; nenhuma alteração de fixtures/domínio/serviços/rotas. **CI Django e Chromium ainda não verificada para este commit**; testes anteriores não equivalem a regressão PASS da alteração atual.
- Preflight Neon administrativo somente leitura em `oes-sandbox`, branch `br-gentle-hall-b6jaxehf`: roles E6 NOLOGIN, writer INSERT sem SELECT, verifier SELECT sem INSERT; owner tem direitos amplos e **não recomendado como identidade de aplicação**. Não foram feitas mudanças. Identidade com privilégio mínimo simultâneo INSERT+SELECT não encontrada; ensaio conectado permanece pendente, não autorizado; possível diferimento conforme necessidade funcional.
- **Próximo passo imediato:** executar e analisar workflows manuais existentes `oes-django-vertical-slice-validation.yml` e `oes-django-real-browser-validation.yml` para o commit editorial em `main`. Não declarar PASS sem run/logs. Após validação, avaliar encerramento restrito da entrega de apresentação e as lacunas restantes; checkpoint proporcional.

## Marco de continuidade CP284 — 2026-10-25 (histórico)

- Checkpoint preventivo sem encerramento de conversa. D2-I-A fechado offline (39/39); D2-I-B fechado offline (50/50); D2-I-C modelo simplificado de **uma identidade** com reutilização direta de funções E6, suite Python [40194548767](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40194548767) **99/99 PASS**, 4 testes novos. Execução PostgreSQL conectada e cleanup NÃO demonstrados nem autorizados. Documentos 287 e 288 prevalecem na definição de escopo sobre exigência anterior de dois logins independentes no piloto. Requisitos diferidos devem ser reavaliados na definição da stack completa; evitar workarounds do piloto. Captura factual bloqueada, serviços pagos proibidos, Fase 5 não iniciada. Próximo passo: **planejar pré-condições mínimas de ensaio sintético conectado sem modificar Neon**, e solicitar autorização específica antes de qualquer mudança/conexão/escrita/cleanup.

## Regra de escopo do piloto — Documento 288 / 2026-10-25

- Diretriz do responsável: foco no objetivo central do piloto; evitar contornos e infraestrutura temporária para resolver problemas que a stack completa solucionará naturalmente. Requisitos relevantes retirados do piloto devem ser **registrados e obrigatoriamente reavaliados na definição da stack completa**, antes da respectiva operação/produção; diferido não significa dispensado. Exemplo: dupla autenticação independente (Documento 287). D2-I-C deve ser simplificado proporcionalmente. Nenhuma autorização operacional nova.

## Decisão de escopo D2-I-C — 2026-10-25 (posterior ao CP283)

- **Documento 287:** por decisão direta do responsável, autenticação com dois logins independentes **não é requisito do piloto inicial**. Fica diferida; todos os demais controles de integridade, privacidade, proveniência, TLS, menor privilégio proporcional, cleanup e HOLD continuam. Esta decisão substitui apenas esse item do Documento 285 no piloto. Ainda não autoriza escrita, modificação de grants/roles/credenciais, conexão, workflow ou captura factual. Adaptadores E6 atuais requerem duas identidades: compatibilidade com identidade única **ainda não implementada nem testada**; testes 50/50 PASS continuam evidência do modelo anterior.

## Marco de continuidade CP283 — 2026-10-25 (vigente)

- D2-I-B: composição Django com adaptador E6 real usando apenas mocks validada no commit `5511eff6598b11b18b6cb47966a1c2b52fb70830`, CI 40192039182: **50/50 PASS** incluindo quatro testes de composição; encerramento técnico **somente offline**. D2-I-C gate conectado pendente. Captura factual e infraestrutura permanecem bloqueadas.

## Marco de continuidade CP282 — 2026-10-25 (histórico)

- D2-I-A: implementação de leitor sintético opt-in no serviço Django, commit `6352fcc1fb19cd03cafcbd93230189b56058115e`, CI [40190923646](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40190923646), **39/39 PASS** offline, seis testes novos. Encerramento restrito ao contrato offline.
- D2-I-B: serviço interno `run_synthetic_private_roundtrip` com orquestrador injetado, commit `60e088af4a1bc1fb05ba889f2893598fc0608f47`, CI [40191544839](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40191544839), **46/46 PASS** offline, sete testes novos. **Composição real dos adaptadores existentes com o Django ainda não demonstrada**, nem mesmo por teste conjunto offline.
- PostgreSQL conectado, autenticação independente, persistência real e captura factual **NÃO autorizados/comprovados**. G2-I2 diferido para gate obrigatório no piloto integrado. Ponto de retomada: definir e testar composição offline mínima dos adaptadores reais com o serviço Django, mediante autorização; sem integração conectada implícita.

## Deliberação vigente — 2026-10-25 / Documento 285 / CP281

- **APROVADO:** G2-I2 isolado **diferido para gate obrigatório do piloto integrado**, conforme autorização expressa do proprietário em 2026-10-25. Não é teste dispensado nem prova de autenticação independente. G2-I1 permanece inconclusivo com cleanup PASS. Sem novos logins ou ensaio conectado nesta decisão.
- **Gate obrigatório antes de qualquer captura factual:** autenticação independente de menor privilégio, TLS e isolamento; INSERT/commit/leitura privada/sha de dados estritamente sintéticos; HOLD após falha pós-commit e limpeza precisa; ausência de raw JSON ou credenciais em API, logs e CI; critérios de aceite e autorização separados.
- **Prioridade D2:** (1) mapear os entregáveis realmente necessários do piloto; (2) integrar componentes já disponíveis com stack existente; (3) validar gate conectado sintético no contexto integrado com autorização específica; (4) somente depois avaliar gate factual. Evitar novos ensaios isolados redundantes. **G2-I2 NOT_AUTHORIZED / E6-G1 FACTUAL BLOCKED**, workflow factual e G2-I1 hard-disabled; Fase 4 permanece encerrada apenas metodológica/documentalmente, Fase 5 NOT_STARTED.

## Marco de continuidade CP280 — 2026-10-24 (histórico)

- G2-I1: duas identidades temporárias provisionadas com ACL restrita, execução conectada 40140467057 falhou sem causa identificável; segunda tentativa não ocorreu por bloqueio da ferramenta. Diagnóstico offline e testes adicionados nos commits posteriores a CP279. Limpeza SQL grantor-aware PASS; 0 papéis temporários e 0 observações privadas, proveniência total 1, papéis permanentes mantidos NOLOGIN/NOINHERIT. Autenticação real permanece INCONCLUSIVE; G2-I2 NÃO AUTORIZADO; E6-G1 factual bloqueado. Workflow G2-I1 hard-disabled. Detalhes no CP280.

## Marco de continuidade CP279 — 2026-10-24 (histórico)

- **G2-P1:** preflight Neon autorizado somente leitura na branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`. `current_user=session_user=oes_sandbox_owner`; `oes_raw_private.source_observation` com **0 linhas**; registro do quarto invariante PG-A4 em `provenance.record` com UUID `a4300000-0000-4000-8000-000000000001` **1 linha atualmente**. ACL: `oes_e6_capture_login` NOLOGIN, sem USAGE/INSERT/SELECT/membership; writer NOLOGIN, USAGE+INSERT/sem SELECT; verifier NOLOGIN, USAGE+SELECT/sem INSERT; todos `rolinherit=false`; sem grants pelo owner para esses papéis segundo consulta. Catálogo com 16 colunas, raw `bytea`, sem ler bytes.
- **G2-P2:** plano documental para duas identidades autenticadas distintas, driver Python proposto `psycopg 3` não instalado, TLS, transações sem autocommit, readback SHA-256 e cleanup específico. Antes de executar, resolver identidade e defaults das colunas obrigatórias e demonstrar manejo de falhas pós-commit; nenhuma autorização conectada operacional.
- **G2-P3:** commit `d9780153a7d73e96bca3533362f5a088210d9dd8`, módulo `e6_g2_identity_gate_offline.py` e 8 testes sintéticos para identidade de sessão e ACL com conexões injetadas. GitHub Actions [40135713382](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40135713382), job `120996673027`, HEAD `d9780153a7d73e96bca3533362f5a088210d9dd8`, **87/87 PASS**, 0 falhas/erros. Não comprova autenticação conectada nem independência real.
- **Deliberação:** preparação G2 validada; **prontidão operacional condicional, NÃO liberada**. G2-I1 (identidades transitórias) e G2-I2 (ensaio Python/PostgreSQL) exigem autorizações operacionais específicas distintas. Nenhuma credencial, GRANT/REVOKE, login novo, DML/DDL ou GET factual aprovado. E6-G1 factual bloqueado; workflow `if: ${{ false }}`. Fase 4 encerramento apenas metodológico/documental; D2 parcial, readiness `NOT_READY`, Fase 5 não iniciada.

## Marco de continuidade CP278 — 2026-10-24 (histórico)

- **G1-A5:** adaptador de proveniência offline `e6_private_capture_provenance_offline.py`, commit `56b38a783e4f3df234ee778fff3638d9180bcd96`, converte timestamps ISO UTC-aware, fixa `source_name`, preserva bytes e rejeita falhas com HOLD; sem alterar `e6_capture.py` factual.
- **G1-A6:** GitHub Actions [40133870873](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40133870873), no commit G1-A5, **73/73 PASS**, incluindo cinco novos testes de proveniência.
- **G1-A7:** adaptador `e6_private_roundtrip_injected_offline.py` e seis testes, commit `ef26b03cbbf9f038c31eb2ee146d45f10b0453ca`: conecta leitor ao orquestrador somente com objetos de conexão injetados/mockados, simulando commit, verificação privada e HOLD pós-commit; separação de objetos não demonstra autenticação efetiva.
- **G1-A8:** GitHub Actions [40135045815](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40135045815), job `120994679254`, commit `ef26b03cbbf9f038c31eb2ee146d45f10b0453ca`, **79/79 PASS**, seis novos testes de integração aprovados. **G1 encerrado tecnicamente apenas como protótipo sintético offline**; não há prova conectada PostgreSQL, login independente ou captura factual.
- **Barreiras:** G2 conectado `NOT_AUTHORIZED`, E6-G1 factual `NOT_AUTHORIZED`, workflow factual `if: ${{ false }}`; sem rede Neon, GRANT, credencial, GET, SQL real ou JSON bruto público. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 `PARTIAL`, prontidão `NOT_READY`, Fase 5 `NOT_STARTED`.

## Marco de continuidade CP277 — 2026-10-24 (histórico)

- **G1-A1:** proprietário aprovou expressamente `G1_MINIMAL_OFFLINE_PYTHON_POSTGRES_INTEGRATION`, exclusivamente dados sintéticos, conexões injetadas e mocks, sem Neon/rede/credenciais/GET/workflow factual.
- **G1-A2:** criados `tools/d2_e5_preservation/e6_private_reader_offline.py` e `tests/test_e6_private_reader_offline.py` no commit `78a2d3a9bef2c203c9a9b2f3e6068610e061dcd8`. SELECT parametrizado com conexão injetada e exceções sanitizadas; sem driver, sem autenticação real. Nenhum outro código modificado.
- **G1-A3:** análise de compatibilidade estrutural com `verify_private_readback()`; validação local reportada de cinco testes, sem resultado canônico de CI até A4. Nenhuma alteração remota.
- **G1-A4:** GitHub Actions run [40133419311](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40133419311) sob `78a2d3a9bef2c203c9a9b2f3e6068610e061dcd8`, Python 3.12, **68/68 PASS, zero erros/falhas**, incluindo os cinco testes novos e regressão anterior de 63. Evidência de contrato **offline**, não de autenticação ou execução PostgreSQL conectada.
- **Próxima fronteira:** compatibilizar proveniência (`source_name`, timestamps aware) e integrar o leitor com o orquestrador usando mocks/injeção; G2 conectado exige aprovação própria. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 `PARTIAL`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`; E6-G1 factual bloqueado, workflow `if: ${{ false }}`, sem JSON bruto público.

## Marco de continuidade CP276 — 2026-10-24 (histórico)

- **A1 / PG-A4:** o quarto invariante tem origem identificada em `provenance.record`, UUID `a4300000-0000-4000-8000-000000000001`, por `LEFT JOIN` com versão corrente de Study. A execução histórica `40110909348` confirmou a associação; `evidence.result_source=0` não é teste desse invariante. **Presença atual do UUID ainda não foi reatestada por SQL**.
- **A2 / B2:** encerramento técnico **restrito recomendado**, sobre demonstração positiva previamente documentada (um INSERT de 18 bytes, verificação SHA-256, limpeza, restauração dos grants), sem declarar identidade de login independente, integração por Python/driver ou preservação atual do quarto invariante.
- **A3 / próximo gate:** desenho documental G1 sem rede para integração Python/DB-API e leitor injetável; G2 conectado e sintético somente após aprovação específica e preparação segura de identidade. Corrigir contrato de proveniência/timestamps e explicitar HOLD pós-commit; não repetir B2 ou suíte 63/63 sem alteração material.
- Mantidos: Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 `PARTIAL`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, E6-G1 factual `NOT_AUTHORIZED`, workflow `if: ${{ false }}`, política de nenhum JSON bruto publicamente disponível; nenhuma operação Neon efetuada em A1–A3.

## Marco de continuidade CP275 — 2026-10-24 (histórico)

- D2-E6: adaptação offline e roundtrip sintético validados na CI **63/63 PASS** (GitHub run 40126123398); SQL conectado B2 sintético **INSERT + readback por SET ROLE + SHA-256 e tamanho PASS**, 18 bytes, segundo Documento 284. **Nenhuma autenticação independente** foi comprovada.
- Após a limpeza, `oes_raw_private.source_observation` contém **0 linhas**; apenas memberships administrativas preexistentes do grantor `cloud_admin` com `SET FALSE`; `oes_e6_capture_login` permanece `NOLOGIN`, senha antiga não comprovadamente invalidada.
- Fixture PG-A4: 2 estudos, 2 relatórios, 3 vínculos confirmados; origem exata do **1 registro de proveniência da projeção Django PG-A4** ainda a identificar; `evidence.result_source=0` não permite concluir perda. Ver CP275 e Docs 265/284.
- D2 `PARTIAL`, Fase 4 apenas encerrada metodológica/documentalmente, Fase 5 `NOT_STARTED`; workflow factual bloqueado `if: ${{ false }}` e contém artifact antigo **proibido para JSON bruto**. E6-G1 **não autorizado**.

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP276 — 2026-10-24**.

### Nota de leitura do STATE cumulativo

Este arquivo preserva snapshots históricos acumulados de marcos anteriores. Portanto:

- o **estado corrente** é o declarado no topo desta seção e no ponteiro `archive/handoffs/oes/README.md`;
- referências posteriores no corpo a “checkpoint vigente” ou “próximo passo” de CPs antigos são **snapshots históricos**, não instruções atuais;
- em caso de divergência aparente, prevalecem: ponteiro atual → checkpoint atual → Freshness Gate.


## Pós-CP270 — auditoria estática dos controles pré-upload E6-G1 (2026-10-24)

O Documento 255 registra auditoria estática em `main` (HEAD de referência `b7a53d43da4fa60fa99e2dd3c08777311f97097f`) de `preserve.py`, `archive_preflight.py`, `e6_capture.py`, workflow factual e testes sintéticos. Já existem validações de URL quanto a host/path, tamanho 2 MB, até 20 NCT únicos, JSON, integridade SHA-256, proveniência e preflight sem publicação; **não duplicar**. Lacunas limitadas: falta de política `ALLOW/HOLD` para campos inesperados antes de publicar artifact bruto, falta de rótulos literais `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED` no pacote factual/artifact, workflow sem gate de conteúdo imediatamente antes do upload e teste da URL completa não existente. Recomendada pequena correção técnica com testes sintéticos, sob autorização separada. `E6_G1_PREUPLOAD_STATIC_AUDIT_COMPLETE / LIMITED_GAPS_IDENTIFIED / GATE_NOT_READY`; E6-G1 não aprovado, job `if: false` preservado, sem consulta ou execução. CP270 continua vigente e demais estados não mudaram.

## Pós-CP270 — revisão de proporcionalidade da publicidade do artifact E6-G1 (2026-10-24)

Após exame da finalidade dos metadados públicos do ClinicalTrials.gov, retirada a **exigência absoluta** de repositório privado para este piloto. O artifact bruto temporário pode residir no GitHub público apenas mediante **aceitação explícita da exposição antes de E6-G2**, rotulagem `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED`, verificações pré-upload de estrutura/fonte/campos, termos e dados inesperados, e procedimento `HOLD` em caso de dúvida; a validação não garante automaticamente ausência de dados pessoais. **E6-G2 permanece independente** para publicação durável e promoção científica; expiração não revoga downloads. Documento 255 atualizado; controles de pré-upload ainda requerem implementação/validação, responsável e prazo pendentes, autorização E6-G1 `NOT_GRANTED`, job factual `if: false`. Status `E6_G1_PUBLIC_RAW_ARTIFACT_OPTION_ACCEPTABLE_CONDITIONALLY / NOT_APPROVED / WORKFLOW_BLOCKED`. Não houve GET, alteração de workflow ou criação de repositório. CP270 vigente, D2 parcial e readiness `NOT_READY`.

## Pós-CP270 — revisão crítica do gate E6-G1: acesso público a artifacts (2026-10-24)

Confirmado via GitHub que o repositório OES possui visibilidade `public`. A documentação GitHub permite download de artifacts por usuários autenticados com leitura; assim, `actions/upload-artifact@v4` em repositório público pode **expor o JSON bruto antes** da revisão integral e do gate E6-G2. O prazo de sete dias não torna o artifact confidencial. O Documento 255 foi revisado, com recomendação de repositório de staging privado e controle explícito de leitores, responsável `UNASSIGNED`, prazo de revisão `NOT_AGREED`, contingência `REJECT/HOLD` e verificação de custos/acessos. **Status `E6_G1_NOT_READY_PUBLIC_ARTIFACT_EXPOSURE / FACTUAL_CAPTURE_BLOCKED`**. Sem mudanças no workflow; `if: false` mantido, nenhuma consulta ou publicação factual. CP270, D2 parcial, Fase 5 não iniciada e readiness global não pronta inalterados.

## Pós-CP270 — minuta E6-G1 preparada (2026-10-24)

Criado `docs/governance/255-d2-e6-g1-minuta-autorizacao-observacao-factual.md` com URL codificada literal extraída dos parâmetros de `e6_capture.py`, SHA baseline `16945a04f6ad9fe67da53b9360df13c4151c948a`, limites da requisição, retenção de 7 dias, responsabilidades pendentes de revisão integral e gates separados E6-G1 (captura) / E6-G2 (publicação). **Não é autorização:** `D2_E6_G1_AUTHORIZATION_DRAFT_PREPARED / NOT_APPROVED / FACTUAL_WORKFLOW_BLOCKED`. O job factual permanece `if: false`; nenhum GET, workflow ou publicação nesta atividade. CP270 e demais gates preservados.

## CP270 — D2-E6-A3 artifact sintético verificado (2026-10-24)

A execução manual [GitHub Actions 40084945270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40084945270), revisão `20458dcb844cbb0731131578da329d8c6dbc4dbf`, terminou `completed/success`. Artifact `oes-e6-a3-synthetic-40084945270`, ID `12556772199`, 1.783 bytes ZIP, retenção informada até 2026-10-31 10:11 UTC. ZIP recuperado e inspecionado: três arquivos (`response.raw.json` 207 B, `manifest.json` 1941 B, `summary.json` 396 B); digest do ZIP `2bb494a7704e46401aa9c0612154a27ebf91ed221e26626f5edc3aa639a8076a`; SHA-256 do JSON bruto `b4e549b09a40f172e0b971820ad372d0734862f1b00b6f0691048e0775f0c696` idêntico ao manifesto e resumo. Marcadores `synthetic_fixture=true` conferidos. **`D2_E6_A3_SYNTHETIC_ARTIFACT_TRANSPORT_AND_INTEGRITY_PASS`** demonstra transporte temporário, não preservação factual durável nem prontidão conectada. Workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` permanece com `if: false`, confirmado no HEAD; E6-G1 específico não aprovado. Próximo passo: avaliar e formalizar gate E6-G1 com URL exata e plano de revisão do JSON antes de qualquer ativação ou GET. CP270 vigente, D2 `PARTIAL`, F4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, F5 `NOT_STARTED`, readiness `NOT_READY`, M3/BRG/SA e 36 migrations inalterados.

## Pós-CP269 — D2-E6-A3 ensaio de transporte sintético preparado (2026-10-24)

Após confirmação de bloqueio factual `if: false` pelo proprietário (HEAD `6f8b0312075be587cc61c945564bb6e2961e08e2`), criado workflow manual independente `.github/workflows/d2-e6-a3-synthetic-artifact.yml` e gerador offline `tools/d2_e5_preservation/e6_synthetic_artifact.py`. O gerador usa E6-A2/E5-A3/E5-A5 com dados inteiramente artificiais, sinalização explícita de metadados inventados, revalidação de SHA-256 e pacote de três arquivos; o workflow publica **apenas artifact sintético temporário de sete dias**, sem GET ou commit de evidência factual. **Ainda não executado nem verificado artifact remoto.** `D2_E6_A3_SYNTHETIC_ARTIFACT_WORKFLOW_PREPARED / RUN_PENDING / FACTUAL_CAPTURE_BLOCKED`. CP269, gates e readiness global mantidos.

## Pós-CP269 — D2-E6-A2 encerramento técnico restrito offline/sintético (2026-10-24)

Execução manual [GitHub Actions 40069936004](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40069936004) verificada em metadados, job e logs: `workflow_dispatch`, tentativa 1, revisão `a143b66665c57a8ae22664df9f50b3719679c782`, `completed/success`, **27/27 testes PASS, sem falhas ou erros** (`Ran 27 tests in 0.030s — OK`): 12 E5-A3, 11 E5-A5 e 4 novos E6-A2. Integração sintética entre empacotamento e preflight demonstrada; consulta real, upload de artifact temporário, execução do workflow conectado e arquivamento factual **não verificados**. Classificação `D2_E6_A2_OFFLINE_SYNTHETIC_TESTS_PASS_27_OF_27 / TECHNICAL_CLOSURE_SYNTHETIC_ONLY`. Alerta Node.js 20 depreciação não bloqueante. Próxima atividade recomendada: avaliação de prontidão e segurança operacional do workflow conectado, com URL e parâmetros literais, falha fechada, retenção e gates de revisão/publicação, **sem executar consulta por inferência**. CP269 vigente, D2 `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3/BRG/SA inalterados. Notas inferiores de testes pendentes são snapshots históricos.

## Pós-CP269 — E6-A2 integração mínima implementada (2026-10-24)

Autorizada implementação **sem execução conectada**. Criados `tools/d2_e5_preservation/e6_capture.py`, testes sintéticos de integração `tests/test_e6_capture.py` e workflow manual independente `.github/workflows/d2-e6-a2-gated-capture.yml`. Captura GET único sem redirects/retry, limites existentes, execução real de `package_evidence` e `prepare_archival_plan`, artifact temporário de 7 dias. **O workflow não foi executado; não houve HTTP, coleta, publicação factual nem teste CI nesta atividade.** O campo de confirmação no dispatch é uma trava operacional, **não** substitui autorização específica do proprietário para consulta. Classificação `D2_E6_A2_MINIMAL_INTEGRATION_IMPLEMENTED / INTEGRATION_TESTS_PENDING / CONNECTED_RUN_NOT_AUTHORIZED`. CP269, D2 parcial, F5 não iniciada, readiness não pronta e gates intactos.

## Pós-CP269 — D2-E6-A1 protocolo factual preparado (2026-10-24)

Aprovada **preparação técnica e documental somente** de nova observação ClinicalTrials.gov; criado `docs/governance/254-d2-e6-a1-protocolo-observacao-factual-controlada.md`. Delimitados parâmetros históricos literais de E3, novo gate para URL exata e GET único, captura de bytes, integração futura E5-A3 + E5-A5, artifact temporário, revisão **integral** do JSON e segundo gate de publicação factual, seguido de commit atômico e verificação. Workflow E3 não preserva corpo JSON e **não pode ser reutilizado sem adaptação explicitamente aprovada**. Estado `D2_E6_A1_FACTUAL_OBSERVATION_PROTOCOL_PREPARED / NO_CONNECTED_EXECUTION`. Nenhum HTTP, CI, dado factual, alteração funcional ou publicação realizada. Próximo passo é avaliar adaptação mínima E6-A2, separadamente autorizada. CP269 e gates mantidos.

## CP269 — E5-A6, prova sintética de arquivamento (2026-10-24)

Autorizado D2-E5-A6: pacote explicitamente **sintético** versionado em único commit `5e430ff09f372d68d4ffac60d326d0a8c98151d1`, diretório `artifacts/d2/clinicaltrials-gov/observations/SYNTHETIC-OES-D2-E5-A6-20261024/`. Três arquivos recuperados do GitHub. SHA-256 bruto `eec9389a274b0b2c8957ad57bbbab35c3b038342130e1c9c23ac78fdef673091` verificado. Nenhum HTTP real: NCT e metadados de run/status/tempos são artificiais, expressamente ressalvados no manifesto. **`D2_E5_A6_SYNTHETIC_GITHUB_ARCHIVAL_DEMONSTRATED / INTEGRATED_FUNCTION_EXECUTION_NOT_VERIFIED`**: publicação e leitura demonstradas, mas não se executou sequência integrada E5-A3 → E5-A5 → commit. E5-A3 12/12 PASS, E5-A5 23/23 PASS; política E5-A4 aprovada, revisão de JSON factual obrigatória. D2 `PARTIAL`, Fase 4 metodológico-documental fechada, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 bloqueado, BRG/SA e 36 migrations não promovidas. Próximo passo: análise de custo-benefício entre teste sintético integrado adicional e preparação factual controlada, sem novas execuções por inferência.

## Pós-CP268 — D2-E5-A5 encerramento técnico restrito offline/sintético (2026-10-24 local)

A execução manual [GitHub Actions 40068408546](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40068408546) foi conferida em metadados, etapas e logs: `workflow_dispatch`, tentativa 1, SHA testado `f826f453f4c65e2d8b78846dc9ee8a162f354075`, `completed/success`; job `e5-a3-offline-unittest` `success`; `Ran 23 tests in 0.020s — OK`, **23/23 PASS, zero falhas/erros** (12 E5-A3 + 11 E5-A5). Resultado `D2_E5_A5_OFFLINE_SYNTHETIC_TESTS_PASS_23_OF_23 / TECHNICAL_CLOSURE_SYNTHETIC_ONLY`. O preflight verifica pacote local, hashes, consistência e colisões **informadas**; não consulta repositório remoto nem comprova integridade pós-publicação. Assim, E5-A5 está encerrado somente no escopo offline/sintético: **não houve** publicação factual, demonstração de commit de evidência, armazenamento durável comprovado, nova consulta ClinicalTrials.gov, Neon/SQL, revisão científica ou promoção de fase. Alertas Node.js depreciação não bloqueantes. Próxima decisão: avaliar **se** uma demonstração sintética de arquivamento versionado oferece valor suficiente antes de preparar observação conectada; requer aprovação e proteção contra publicação pública inadvertida. CP268 vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, D2 global `PARTIAL`, readiness `NOT_READY`, M3 `BLOCKED` e BRG/SA preservados. Notas de testes pendentes abaixo são históricas.

## Pós-CP268 — D2-E5-A5 preflight offline implementado (2026-10-24 local)

Autorizada a implementação sintética, criou-se `tools/d2_e5_preservation/archive_preflight.py` com validação independente de pacote E5-A3 e preparação determinística de caminhos e hashes, mais 11 casos unittest e README. Rejeita pacote incompleto, conteúdo/manifesto/resumo incoerentes, symlinks, identificador de diretório inseguro e colisões informadas; indica explicitamente revisão de conteúdo, Freshness Gate e autorização de publicação ainda pendentes. **Status `D2_E5_A5_OFFLINE_PREFLIGHT_IMPLEMENTED / TESTS_NOT_YET_RUN / PUBLICATION_NOT_AUTHORIZED`.** Não efetua rede, upload, commit de dados, coleta, CI, SQL ou Neon. Política E5-A4 aprovada, CP268, D2 parcial e demais gates preservados.

## Pós-CP268 — política D2-E5-A4 de preservação durável aprovada (2026-10-24 local)

O proprietário aprovou expressamente a política `D2_E5_A4_GITHUB_VERSIONED_EVIDENCE_PRESERVATION`: usar inicialmente arquivos versionados no GitHub como destino durável de evidência factual **somente para piloto delimitado**, com diretório único por observação (`artifacts/d2/clinicaltrials-gov/observations/<observation-id>/`), `response.raw.json` preservado byte a byte, `manifest.json` com hash SHA-256 e proveniência e `summary.json`, histórico sem sobrescrita e correções como novas versões. Restrições por observação: máximo de 2.000.000 bytes de resposta e 20 registros; reavaliar solução se volume ou finalidade mudar. **Publicação do corpo JSON integral condicionada à conferência prévia de conteúdo, termos de reutilização e eventual dado pessoal**, mesmo que a API de origem seja pública. Histórico Git auxilia auditoria, não garante imutabilidade absoluta contra administradores ou alterações de permissão. GitHub Actions artifacts são temporários, não substituem preservação versionada; revisar hash, commit, identificação do run e integridade do pacote. **A aprovação da política não autoriza implementá-la, realizar upload de JSON factual, novas consultas ClinicalTrials.gov/PubMed, CI, integração Neon/SQL, implantação ou alterações de gates.** Próximo passo: delimitar rotina mínima de arquivamento e controles de publicação, offline/sintéticos e sob autorização específica. D2 `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, CP268 e BRG/SA preservados.

## Pós-CP268 — D2-E5-A3 encerramento técnico restrito sintético (2026-10-23 local / 2026-10-24 UTC)

A execução manual autorizada pelo proprietário [GitHub Actions 40055328811](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40055328811) foi verificada em metadados, jobs e logs: `workflow_dispatch`, tentativa 1, commit testado `3e4220b7abfa77646f2e1cffa57d951b009512c6`, `completed/success`, job `e5-a3-offline-unittest` `success`, Python 3.12, `Ran 12 tests in 0.006s — OK`, **12/12 PASS, zero falhas e erros**. Testes sintéticos cobrem preservação de bytes, SHA-256, identificação de adulteração, validação NCT, limites de tamanho/quantidade, totalCount, campos opcionais e ausência de sobrescrita. **Classificação `D2_E5_A3_OFFLINE_SYNTHETIC_TESTS_PASS_12_OF_12 / TECHNICAL_CLOSURE_SYNTHETIC_ONLY`**. Isso encerra E5-A3 apenas no escopo offline; não é evidência de recuperação ClinicalTrials.gov, durabilidade de arquivos, segurança, autenticação de fonte, avaliação científica ou implantação. O workflow de coleta E3 permanece intocado; nenhuma nova chamada API, SQL, Neon, CI adicional ou gasto foi realizado neste registro. Próximo ponto de decisão: política e destino de preservação durável de dados factuais, **antes** de qualquer nova recuperação conectada autorizada. CP268 vigente, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 global `PARTIAL`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, BRG/SA preservados. As notas de teste pendente abaixo são snapshots anteriores, não estado atual.

## Pós-CP268 — workflow manual para testes sintéticos D2-E5-A3 (2026-10-23 local)

O acesso local aos arquivos publicados foi bloqueado por DNS, impedindo execução local fiel. Criado workflow manual independente `.github/workflows/d2-e5-a3-offline-tests.yml`, que usa Python 3.12 e somente `unittest discover -s tests -v` em `tools/d2_e5_preservation`. Não inclui código de acesso à API, segredos, Neon, banco, pacotes externos, deploy nem eventos automáticos. **Estado `E5_A3_MANUAL_UNITTEST_WORKFLOW_PENDING_RUN`: testes ainda não executados/validados no novo workflow**, acionamento manual exige decisão separada. Não alegar PASS com base em inspeção de fonte. CP268, D2 parcial, readiness NOT_READY, Fase 5 NOT_STARTED e gates preservados.

## Pós-CP268 — D2-E5-A3 módulo de preservação sintética implementado (2026-10-23 local)

Sob autorização específica, foi criado `tools/d2_e5_preservation/` com módulo `preserve.py`, testes unittest sintéticos e README. Recebe bytes e proveniência fornecidos pelo chamador, valida forma/limites/NCTs, preserva `response.raw.json` exato, produz manifesto SHA-256 e resumo, prepara em diretório temporário e publica por rename local somente depois de verificações. **Nenhuma rede, consulta ClinicalTrials.gov, CI, SQL, Neon, modificação do workflow E3 ou prova científica.** Estado `D2_E5_A3_OFFLINE_IMPLEMENTED / TEST_EXECUTION_NOT_CLAIMED / CONNECTED_USE_NOT_AUTHORIZED`. Testes incluídos, não executados neste ato; próximos passos: verificação técnica autorizada de testes sintéticos e decisão independente de retenção durável antes de coleta real. CP268, Fase 4 documental encerrada, Fase 5 não iniciada, readiness NOT_READY e gates preservados.

## Pós-CP268 — D2-E5-A2 contrato de preservação especificado (2026-10-23 local)

Documento 253 `docs/governance/253-d2-e5-a2-contrato-preservacao-metadados-clinicaltrials.md` formaliza o contrato mínimo de evidência (JSON bruto exato, manifesto de proveniência/SHA-256, resumo técnico), critérios de falha fechada e distinção entre artifact GitHub de 7 dias e preservação durável ainda não aprovada. Reconhece que `clinicaltrials-interface-v2.json` não é a consulta literal E3 e que o JSON histórico E3 não pode ser reconstruído. Classificação `D2_E5_A2_CONTRACT_SPECIFIED / NO_COLLECTION / IMPLEMENTATION_NOT_AUTHORIZED`. Próximo passo recomendado: decidir escopo de implementação mínima offline/sintética e política de destino durável antes de qualquer coleta factual. Sem CI, API, código ou promoção de gates; CP268 e prontidão operacional `NOT_READY` preservados.

## Pós-CP268 — prioridade D2-E5 aprovada (2026-10-23 local)

O proprietário aprovou expressamente a recomendação de prioridade para **D2-E5 — preservação e rastreabilidade de metadados de registros públicos ClinicalTrials.gov**, classificação de planejamento `D2_E5_FACTUAL_METADATA_PRESERVATION_PRIORITY / E5_A1_REUSE_DIAGNOSIS_NEXT`. Objetivo: reduzir a lacuna factual do Doc. 247/248 (20 NCTs recuperados em execução anterior, sem JSON integral arquivado) mediante primeiro diagnóstico de reutilização dos mecanismos/artefatos existentes e identificação das perdas de proveniência; depois, somente se necessário, delimitação de estrutura e eventual recuperação mínima sob aprovação própria. O próximo `Prossiga` habilita **apenas E5-A1, diagnóstico documental/técnico read-only dos arquivos e evidências já existentes**, não criação de workflow, alteração de código, acesso à API ClinicalTrials.gov/PubMed, acionamento CI, ingestão, SQL/Neon, nova coleta, custo ou adjudicação científica. Django permanece estabilizado, C3 diferido, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, D2 global `PARTIAL`, M3 bloqueado, BRG/SA e CP268 preservados. O plano não converte ausência de ID no corpus delimitado em novidade científica.

## CP268 — consolidação do navegador real (2026-10-23 local / 2026-10-24 UTC)

O proprietário autorizou a execução única da validação Django/Chromium. [Run 40054002708](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40054002708), commit testado `1c7400c909d1af74ed17c1d42ba16b24de7026d9`, `completed/success`; Django `manage.py check` sem erros, **9/9 páginas/viewport PASS**, navegação e CSS via Django real verificados, `BROWSER_VALIDATION_STATUS=PASS`. Artifact `oes-django-real-browser-evidence` (ID 12544582293, nove screenshots, relatório JSON e log, retenção limitada). Classificação `REAL_DJANGO_BROWSER_VALIDATION_PASS_9_OF_9 / FUNCTIONAL_SCOPE_PARTIAL`; não comprova segurança, acessibilidade integral ou ciência. O CP268 em `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP268.md` consolida esse marco, a análise integrada Doc. 252 e a prioridade de estabilização aprovada. As notas anteriores de navegador pendente são **históricas**. O workflow de 30 testes não foi reexecutado nesta run. Readiness `NOT_READY`, Fase 5 `NOT_STARTED`, D2 parcial, M3 bloqueado e BRG/SA inalterados. Próximo passo: decidir finalidade concreta do demonstrador estabilizado sem iniciar desenvolvimento automaticamente.

## Pós-CP267 — workflow de navegador Django implementado, execução pendente (2026-10-23 local)

O proprietário autorizou implementar exclusivamente a correção de staticfiles do demonstrador e uma validação de navegador real com Chromium/Playwright em workflow manual separado. Corrigido o registro de django.contrib.staticfiles e STATIC_URL absoluta; adicionados script de inspeção de três páginas em desktop/tablet/celular (nove screenshots), verificação de CSS efetivamente servido por Django, navegação, identidade Study/Report, fontes conhecidas sem visita externa, limites científicos, foco de teclado e ausência de transbordamento. O workflow novo só tem workflow_dispatch, mantém permissões contents:read e preserva resultados e logs em artifact mesmo na falha; o workflow dos 30 testes antigos permanece intacto. **Estado: REAL_BROWSER_WORKFLOW_IMPLEMENTED_PENDING_RUN**, sem execução/CI/PASS de navegador ainda; a tentativa local anterior demonstrou apenas reprodução visual estática, não Django real. Execução requer autorização separada. CP267 e Fase 4 documental encerrada preservados; Fase 5 NOT_STARTED, readiness NOT_READY, D2 parcial, M3 BLOCKED, BRG/SA e 36 migrations UNREVIEWED mantidos. Sem banco, Neon, consulta externa científica, implementação C3 ou deploy.

## Pós-CP267 — prioridade de estabilização aprovada pelo proprietário (2026-10-23 local)

O proprietário aprovou expressamente a prioridade recomendada após a Análise Integrada de Prontidão e Dependências (Documento 252): **estabilizar temporariamente o demonstrador Django, diferir novos incrementos funcionais e priorizar validação empírica da aplicação real em navegador antes de C3 ou integração de infraestrutura**. Estado decisório `STABILIZATION_PRIORITY_APPROVED / DJANGO_FUNCTIONAL_EXPANSION_DEFERRED / REAL_BROWSER_VALIDATION_PENDING`. A aprovação da **prioridade** não autoriza por si só execução local, CI, ferramenta de navegador, alteração de código, novas fontes, SQL/Neon, migrations, deploy ou novas despesas; tais atos requerem escopo e autorização correspondentes. Plano mínimo candidato para futura autorização: executar a aplicação Django com as duas fixtures existentes, observar as rotas `/`, `/signals/NCT01438697/` e `/signals/NCT07836491/`, verificar navegação, legibilidade de proveniência/limites e ausência de vínculos científicos inferidos; documentar ambiente e evidência observável, distinguir problemas visuais de falhas de domínio, não simular homologação científica. **Próxima atividade:** delimitar mecanismo factível de validação em navegador real e submeter execução à aprovação específica, sem abrir novo ciclo de desenvolvimento por inferência. Documento 252 conserva seu status histórico de proposta pendente na data de elaboração; a decisão posterior do proprietário está registrada nesta seção atual. CP267 vigente, `Fase 4=CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, `Fase 5=NOT_STARTED`, readiness `NOT_READY`, D2 parcial, M3 bloqueado e gates BRG/SA preservados.

## Pós-CP267 — diagnóstico integrado de prontidão sem pesquisadores (2026-10-23 local)

Documento 252 `docs/governance/252-analise-integrada-prontidao-dependencias-sem-pesquisadores.md` consolida matriz de dependências técnicas, científicas e operacionais sem executar ações novas. Resultado `READINESS_DEPENDENCIES_ANALYZED / RECOMMENDATIONS_ONLY / OWNER_DECISION_PENDING`: pesquisadores não são necessários para engenharia, testes sintéticos, preparação documental ou coleta factual exclusivamente não adjudicativa autorizada; são requeridos nos julgamentos especializados previstos pelos gates. Recomendação **ainda não aprovada**: pausar expansão Django, avaliar navegação real do demonstrador e escolher finalidade efetiva antes de investir em persistência/novas fontes. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, CP267, D2 parcial e BRG/SA preservados. Nenhum novo CI/SQL/Neon/consulta científica, código ou gate nesta atividade.

## CP267 — continuidade consolidada (2026-10-23 local)

CP267 publicado em `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP267.md`: C1 catálogo 25/25 PASS (run 40048357640), C2 Study/Report documental tipado 30/30 PASS (run 40049293022), ambos em escopo funcional restrito. Navegador Django real não verificado; readiness `NOT_READY`, Fase 5 `NOT_STARTED`, D2 parcial e gates preservados. Próximo passo: avaliação crítica de próximo valor substantivo ou pausa de incrementos; nenhuma implementação implicitamente autorizada.

## Pós-CP266 — C2: validação automatizada de identidade e proveniência (2026-10-23 local; 2026-10-24 UTC)

A execução manual autorizada [GitHub Actions run 40049293022](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40049293022) foi verificada em metadados, jobs, etapas e logs: `workflow_dispatch`, tentativa 1, HEAD testado `8e9aae482eb8581eaac2d474aa62dd012cc61790`, `completed/success`, job `django-read-only-tests` `success`. Python 3.12, Django 5.2.18; `manage.py check` sem problemas; **30 testes, 30 PASS, zero falhas** (25 anteriores + cinco C2). O log indica `Skipping setup of unused database(s): default.`. Testes C2 confirmam um Study documentado com dois Reports, identidade NCT não conciliada sem Study/Report, rejeição de vínculos duplicados ou fonte não verificada e continuidade das páginas e catálogo. Classificação restrita: `C2_AUTOMATED_TESTS_PASS_30_OF_30 / FUNCTIONAL_SCOPE_PARTIAL`. A anotação C2 anterior de validação pendente é histórica; a suíte foi validada, **não** houve homologação em navegador real, auditoria de segurança ou conformidade completa P1–P6 de proveniência. Nenhum novo CI, coleta científica, SQL/Neon, migration, deploy ou promoção de fase nesta atividade. CP266 permanece vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, D2 parcial, BRG/SA e 36 migrations `UNREVIEWED`. Próximo marco recomendado: avaliar CP267 proporcional antes de novo incremento.

## Pós-CP266 — C2: referências documentais tipadas implementadas (2026-10-23 local)

Após autorização específica do proprietário para a implementação C2, commit `91b8629051ce1d5c021311f792c6a2a6ac694008` atualizou `applications/oes_web/evidence/domain.py`, `fixtures/signals.json` e adicionou cinco testes `tests/test_c2_identity.py`. Incluídas referências locais tipadas `StudyReference`, `ReportReference`, `StudyReportReference` e `SourceReference`; vínculos positivos limitados ao Documento products/154 §5.5, com validação de unicidade, correspondência com os relatórios já documentados e origem explícita. NCT01438697 tem uma referência Study e dois vínculos Report; NCT07836491 permanece sem Study/Report. Campos legados, rotas, serviços e apresentação preservados. **C2_IMPLEMENTED / AUTOMATED_VALIDATION_PENDING**: total previsto 30 testes (25 anteriores + cinco novos), **sem execução de CI nesta atividade**; o último PASS 25/25 se refere à revisão anterior. Nenhuma identificação OES inventada, adjudicação, versão, ORM/migrations, SQL/Neon, consulta HTTP externa, serviço pago ou deploy. CP266 vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, D2 parcial, BRG/SA e 36 migrations `UNREVIEWED` preservados. Requer autorização específica para eventual validação conectada.

## Pós-CP266 — C2: contrato documental delimitado (2026-10-23 local)

O proprietário aprovou a **delimitação técnica de C2**. O Documento 251 (`docs/governance/251-c2-delimitacao-contrato-documental-study-report-proveniencia.md`), commit `49b79f4935a05e538f9939f0b1eb6ddadcdf9346`, confronta o demonstrador Django com os Docs. arquitetura 20/28/29 e a reconciliação products/154; propõe referências tipadas mínimas Study, Report, vínculo e fonte, sem emitir novas identidades científicas, versões, julgamentos ou dados clínicos. Preserva NCT01438697 como um Study documentado com dois Reports e NCT07836491 sem vínculo atribuído. **C2_SCOPE_DELINEATED / IMPLEMENTATION_NOT_AUTHORIZED**; nenhum código C2 ou CI executado. CP266 vigente, Fase 4 documental encerrada, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, D2 parcial, gates inalterados. Próximo passo depende de autorização específica para implementar C2.

## Pós-CP266 — C1: testes automatizados confirmados (2026-10-23 local; 2026-10-24 UTC)

O [GitHub Actions run 40048357640](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40048357640), acionado manualmente mediante autorização expressa, foi verificado em execução, job, etapas e logs: `workflow_dispatch`, tentativa 1, HEAD testado `cf7c2fcc07ad75366bd639312aca211f37e6f851`, `completed/success`; job `django-read-only-tests` `success`. Python 3.12, Django 5.2.18, `manage.py check` sem problemas; **25 testes, 25 PASS, zero falhas** (20 anteriores + 5 C1). Log: `Skipping setup of unused database(s): default.`. Testes C1 confirmam catálogo das duas fixtures, links para detalhes existentes, identidade não reconciliada sem inferências, proibição de POST e preservação das rotas. Classificação restrita: `C1_AUTOMATED_TESTS_PASS_25_OF_25 / FUNCTIONAL_SCOPE_PARTIAL`. O aviso anterior de `AUTOMATED_VALIDATION_PENDING` é snapshot histórico superado pela execução; não há teste com navegador Django real, homologação, revisão científica, deploy ou prontidão operacional. CP266 permanece vigente, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, D2 global parcial, M3 `BLOCKED`, 36 migrations `UNREVIEWED` e BRG/SA inalterados. **Próximo passo:** deliberação proporcional sobre avanço funcional, sem inferir nova autorização de implementação/CI.

## Pós-CP266 — C1: catálogo documental demonstrativo implementado (2026-10-23 local)

Proprietário aprovou expressamente C1 e sua implementação. Commit de código `fd30370039e44ec730c9b9903069096ad8171bfc`: catálogo GET-only na rota `/`, leitura das mesmas duas fixtures por `list_signals()`, links para `/signals/NCT01438697/` e `/signals/NCT07836491/`, estados legíveis, limites e aviso explícito de inventário demonstrativo parcial. Cinco testes adicionais `evidence/tests/test_catalog.py` cobrem inventário local, navegação, não inferência sobre identidade não reconciliada, ausência de escrita e rotas preexistentes. **C1_IMPLEMENTED / AUTOMATED_VALIDATION_PENDING**: nenhum teste do novo commit foi executado; os anteriores **20/20 PASS** correspondem à revisão UX-02 anterior. Total previsto agora: **25 testes**; execução do workflow manual exige autorização própria. Nenhum SQL/Neon, migração, consulta externa, nova dependência, deploy ou alteração científica. CP266 vigente, D2 global parcial, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 bloqueado, BRG/SA e 36 migrations `UNREVIEWED` inalterados.

## CP266 — consolidação de continuidade (2026-10-23 local)

Checkpoint `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP266.md` consolida Docs. 248–250, Django A1/B1/UX-02, runs `40044041757` (8/8), `40046496477` (16/16), `40047175669` (**20/20 PASS**) e `REAL_BROWSER_VALIDATION_PENDING_NON_BLOCKING_FOR_PROTOTYPE`. CP265 preservado imutável. Próxima atividade: comparar opções de incremento substantivo, **sem implementar por inferência**. Fase 4 apenas metodológico-documental encerrada, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, D2 global parcial e gates preservados.

## Pós-CP265 — UX-02: pendência visual proporcional e decisão de continuidade (2026-10-23 local)

Após o run 40047175669 (20/20 testes PASS), uma inspeção exploratória baseada em reprodução estática foi relatada na conversa, mas **não constitui prova de renderização do Django em execução**. A tentativa subsequente de validar em navegador com servidor Django local **não foi concluída por indisponibilidade de dependência Django e instalação de rede naquele ambiente**; não há evidência de teste real de browser, acessibilidade assistiva ou usuário. Classificação: `UX02_AUTOMATED_TESTS_PASS_20_OF_20 / REAL_BROWSER_VALIDATION_PENDING_NON_BLOCKING_FOR_PROTOTYPE`. A lacuna é **não bloqueante apenas para evolução do demonstrador local**; deverá ser reavaliada antes de qualquer homologação, uso externo ou alegação de acessibilidade. **Não repetir CI, não propor infraestrutura nova ou outro ciclo UX por essa causa isolada.** Próxima decisão de valor: selecionar, com aprovação do proprietário, o incremento substantivo mínimo seguinte, observadas as fronteiras da arquitetura Django e os gates existentes. CP265 vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, M3 `BLOCKED`, D2 parcial, 36 migrations `UNREVIEWED`, BRG/SA sem promoção. Nenhum código ou dado científico alterado nesta atividade.

## Pós-CP265 — UX-02: validação automatizada de apresentação (2026-10-23 local; 2026-10-24 UTC)

O [GitHub Actions run 40047175669](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40047175669) foi examinado em metadados, job e logs: `workflow_dispatch`, tentativa 1, commit `4e9c1ac149954414ececf426183b09ebee3c2af6`, `completed/success`. Job `django-read-only-tests` com todas as etapas `success`; Python 3.12 e Django 5.2.18; `python manage.py check` sem problemas; `python manage.py test evidence.tests --verbosity 2` encontrou **20 testes, 20 PASS, 0 falhas** (16 anteriores e 4 novos de apresentação). Log: `Skipping setup of unused database(s): default.`. Estado técnico delimitado `UX02_AUTOMATED_TESTS_PASS_20_OF_20 / VISUAL_UX_NOT_YET_VALIDATED`. P1 (rótulos humanos), P2 (três seções), P3 (mapeamento controlado de links) e P4 (estrutura da trajetória) estão cobertos em graus restritos por testes; **não houve inspeção visual real de navegador, auditoria de acessibilidade ou teste com usuários**. A anotação anterior de validação pendente é histórica, superada apenas para esta suíte. Sem nova coleta científica, migrations, Neon, SQL, deploy, alteração da Ficha ou autorização de novos gates. CP265 vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 global parcial, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, 36 migrations `UNREVIEWED`, controles BRG/SA inalterados. Próximo passo recomendado: avaliação visual local proporcional, separadamente autorizada se envolver execução operacional.

## Pós-CP265 — UX-02: apresentação e links documentais implementados, validação pendente (2026-10-23)

Após aprovação expressa das quatro melhorias UX-01/P1–P4, publicado commit `38a454333b15d553b35a281a4fe81c1494a8caec` em `applications/oes_web/evidence/`: etiquetas humanas para os estados sem modificar códigos científicos, três seções de leitura, links de fontes explicitamente verificadas dos Docs. 247, 248 e products/154, trajetória vertical com fonte/limite, e quatro testes adicionais de apresentação. Referências sem correspondência no mapa verificado ficam apenas como texto; não se inventam URLs. Nenhuma alteração de domínio ou fixtures, banco, consulta factual, serviço pago ou implantação. **Testes UX-02 NÃO EXECUTADOS nesta atividade**; os 16/16 PASS anteriores pertencem ao commit anterior. Total previsto: 20 testes (16 históricos + 4 novos), sem PASS novo até execução autorizada. CP265 permanece vigente, Fase 4 encerrada exclusivamente no escopo metodológico-documental, D2 parcial, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 bloqueado, BRG/SA e 36 migrations `UNREVIEWED` inalterados. Próxima atividade recomendada: executar, sob autorização própria, o workflow manual Django já existente e avaliar evidências, sem criar workflow adicional.

## Pós-CP265 — B1: validação automatizada de 16 testes (2026-10-23 horário local; 2026-10-24 UTC)

O [GitHub Actions run 40046496477](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40046496477) foi verificado em metadados, jobs e logs: `workflow_dispatch`, tentativa 1, HEAD testado `e195f32bf86e12c1ab68cf5746359d62e220a5fc`, `completed/success`; job `django-read-only-tests` `success`. Django 5.2.18 instalado no Python 3.12; `python manage.py check` sem problemas; `python manage.py test evidence.tests --verbosity 2` executou **16 testes, 16 PASS, 0 falhas** (8 legados + 8 B1). O log registra `Skipping setup of unused database(s): default.`. **Classificação restrita `B1_AUTOMATED_TESTS_PASS_16_OF_16 / FUNCTIONAL_SCOPE_PARTIAL`**: VS2-01–06 e VS2-08–09 satisfeitos no limite das verificações; VS2-07 possui evidência parcial porque ausência absoluta de rede não foi auditada. Não demonstra uso real em navegador externo, produção, segurança operacional, revisão científica independente, nem execução dos gates. A pendência de validação do registro B1 anterior fica superada apenas no escopo dos 16 testes. Sem novo acesso científico, alterações científicas, migrations, Neon, deploy ou promoção de fases. **CP265 vigente**, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 global parcial, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, BRG/SA, 36 migrations `UNREVIEWED`, Ficha N2 e garantias inalteradas. Próxima atividade recomendada: avaliação proporcional da experiência de uso dos dois incrementos, sem nova implementação automática.

## Pós-CP265 — B1 implementado no código; execução de testes pendente (2026-10-23)

Sob autorização expressa do proprietário para implementar B1, publicado commit `dcf21ddc0135e846085bb68f5ff37cced3db0cb6`: extensão de `applications/oes_web/evidence/domain.py`, fixtures `signals.json`, template `signal_detail.html` e oito novos testes `tests/test_trajectory.py`. Marcos documentais retrospectivos de `NCT01438697` e `NCT07836491` com fonte e limite explícitos; datas não sustentadas omitidas. Nenhuma adjudicação científica ou fluxo operacional adicionado. **Código publicado; testes B1 não executados nesta atividade, portanto VS2-01–VS2-09 NÃO DECLARADOS PASS.** Os 8/8 PASS do run histórico 40044041757 aplicam-se ao commit anterior e não validam o novo código. Nenhuma CI disparada, migração, SQL/Neon, consulta externa ou implantação. CP265 permanece vigente, Fase 4 documental fechada, D2 global parcial, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 bloqueado, gates BRG/SA e 36 migrations `UNREVIEWED` preservados. Próximo passo: avaliação da validação proporcional da nova versão em workflow manual somente mediante autorização separada.

## Pós-CP265 — B1: escopo aprovado para segundo vertical slice Django (2026-10-23)

**Documento 250** `docs/governance/250-b1-aprovacao-escopo-segundo-vertical-slice-trajetoria-documental.md` formaliza a aprovação expressa do proprietário para a visualização retrospectiva da **trajetória documental de sinais** na aplicação Django já publicada, com fixtures existentes, fonte de cada marco, data apenas quando documentada, distinção Study/Report e fronteira entre conciliação documental e decisão científica. Critérios propostos VS2-01–VS2-09 aprovados como escopo funcional, **não executados**. Estado `B1_SCOPE_APPROVED / IMPLEMENTATION_NOT_STARTED`. Sem autorização de código, nova CI, SQL/Neon, consultas factuais, migrations ou implantação. Primeiro incremento mantém 8/8 testes PASS no run 40044041757 e limitações de aceitação funcional. CP265 vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 parcial, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, migrações `UNREVIEWED`, BRG/SA e Ficha N2 inalterados. Próximo passo: autorização específica para implementar B1, sem novos frameworks ou mecanismos operacionais.

## Pós-CP265 — Verificação automatizada do vertical slice Django (2026-10-23)

Run GitHub Actions [40044041757](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40044041757), acionado manualmente (`workflow_dispatch`, tentativa 1), concluído com `success` no commit `16d6cb321770a80836dfd47c12c38c642c9b73f3`. Logs: Python 3.12.15; Django 5.2.18; `manage.py check` sem problemas; `manage.py test evidence.tests --verbosity 2`: **8 testes executados, 8 PASS, 0 falhas**; banco de testes não utilizado. Classificação restrita: `DJANGO_VERTICAL_SLICE_AUTOMATED_TESTS_PASS_8_OF_8 / FUNCTIONAL_SCOPE_PARTIAL`. VS-01/03/06/07/08 permanecem parciais; navegador/servidor real, auditoria integral da proveniência, não regressão completa e prontidão de produção não foram demonstrados. O registro anterior de validação pendente é histórico, superado apenas nos oito testes executados. Nenhuma alteração científica, migrations, Neon, nova consulta ou implantação. CP265, Fase 4 documental fechada, D2 parcial, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 bloqueado, 36 migrations `UNREVIEWED`, controles BRG/SA e Ficha N2 preservados. Próximo marco candidato: delimitar segundo incremento funcional sem escrita científica automática.

## Pós-CP265 — Primeiro código do vertical slice Django publicado, validação funcional pendente (2026-10-23)

Após autorização expressa para o plano mínimo A3, publicado o commit `48e2452d4298b6423bb41cffcb6067cb3bdf99d2` em `applications/oes_web/`: estrutura Django local, domínio e serviço de leitura, duas fixtures documentais dos Docs. 247/248, página somente leitura e testes Django propostos. **Código publicado; validação funcional NÃO EXECUTADA / NÃO ACEITA**: o ambiente executor não possuía Django e a instalação de pacote gratuito falhou por DNS, sem substituição por prova simulada. Nenhum teste Django, servidor, CI, consulta factual, migrations/SQL/Neon ou implantação executados. Não promover `VS-01–VS-08` a PASS. Continuam Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 global parcial, D1 sintético restrito encerrado, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, 36 migrations `UNREVIEWED`, BRGs/SA e Ficha N2 sem alteração. **Próximo passo:** decidir rota proporcional para validação local com Django disponível, sem CI conectada automática e sem alterar ciência. CP265 preservado até checkpoint proporcional posterior.

## Pós-CP265 — Decisão preliminar do primeiro vertical slice (2026-10-23)

**Documento 249** `docs/governance/249-decisao-arquitetural-preliminar-primeiro-vertical-slice-django.md` consolida A1/A2 e aprovação expressa do proprietário da recomendação técnica. **Django 5.2 LTS é o framework candidato preferencial** para um primeiro percurso web local e somente leitura de sinal de evidência, com Python 3.12 como referência inicial, templates HTML/CSS, fixtures controladas, domínio independente e vínculo Study/Report/provenance visível; versões e dependências exatas ainda não congeladas. A decisão é **arquitetural preliminar/documental**, não seleção homologada de produção, nem autorização de codificação, banco, CI, infraestrutura, consultas externas ou serviço pago. **CP265 permanece vigente**. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` com C1–C6, D1 demonstrador restrito fechado, D2 científico global parcial, Fase 5 `NOT_STARTED`, M3 `BLOCKED`, prontidão `NOT_READY`; Ficha N2, GRADE, currentness/assurance/ProductVersion, BRGs/SA e 36 migrations `UNREVIEWED` inalterados. Próximo ato: plano mínimo de implementação e delimitação de autorização, sem implementação automática.

## Pós-CP265 — Conciliação documental de identidades D2-CTGOV-E4 (2026-10-23)

**Documento 248** `docs/governance/248-d2-ctgov-e4-conciliacao-documental-20-ncts.md` confrontou os **20 NCTs** do Doc.247 com os inventários científicos OES (Docs. products 48/49/52/148–163 e governance 232–236), **sem nova consulta/CI**: **4 IDs `KNOWN_DOCUMENTED`** (`NCT03613519` Zhou; `NCT03213132` OASIS; `NCT04564807` Verlinden; `NCT01438697` Ritterband 2017/Shaffer 2020 como cluster do mesmo estudo) e **16 IDs `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`** (não classificáveis como novos, elegíveis ou excluídos sem metadados). Nazem `NCT03366870` permanece conhecido no OES, **ausente apenas na primeira página**. Mantidos 20/87 apenas para consulta literal, JSON integral não persistido, nenhum resultado científico promovido, um único workflow consumido. **CP265 permanece checkpoint vigente**; Fase 4 documental fechada; D2 global parcial; Fase 5 `NOT_STARTED`; Ficha N2, GRADE, currentness, assurance, BRG/SA/36 migrations inalterados. Próxima atividade: decisão proporcional entre investigação factual **dirigida sob nova autorização** ou migração de prioridade para o primeiro vertical slice sem declarar D2 concluído.

## CP265 — D2 ClinicalTrials.gov: primeira página recuperada e verificada, sucesso técnico parcial

Proprietário forneceu o [run 40021883998](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40021883998) do workflow manual aprovado `D2-CTGOV-E3`. GitHub confirmou `workflow_dispatch`, `run_attempt=1`, `completed/success`, job `clinicaltrials-one-get` success e **API HTTP 200** em 2026-10-23T20:47:12Z, JSON `630386` bytes, **20 NCTs únicos retornados de `totalCount=87` na consulta literal, `nextPageToken=true`**, resultado de rotina **`PARTIAL_FIRST_PAGE_ONLY`**. O **Documento 247** `docs/governance/247-d2-ctgov-e3-primeira-recuperacao-estruturada-parcial-cp265.md` preserva URL, horários, 20 IDs e evidências: Zhou `NCT03613519`, OASIS `NCT03213132`, Verlinden `NCT04564807` já conhecidos; Nazem `NCT03366870` não aparece **na primeira página**, não inferir ausência global. **A autorização de um único disparo está consumida**; nenhuma paginação/lookup adicional, deduplicação científica, appraisal, mudança da Ficha N2, GRADE/currentness/assurance ou gate. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 factual global ainda parcial, readiness operacional `NOT_READY`, Fase 5 `NOT_STARTED`, M3 bloqueado; BRG/SA/36 migrations preservados. Handoff vigente **CP265**, `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP265.md`. Próximo `Prossiga`: conciliação **documental sem nova consulta** dos 20 NCT com inventário existente, expondo limitações de dados; STOP. Conversa aberta.

## CP264 — Workflow D2-CTGOV-E3 autorizado/criado; despacho manual ainda pendente

Proprietário declarou **“Workflow aprovado.”** sobre pacote `D2-CTGOV-E3/ONE_SHOT_GITHUB_ACTIONS_PUBLIC_GET` do Documento 245, autorizando um workflow manual e **uma única execução pública GET**. Criado `.github/workflows/d2-ctgov-single-public-get.yml` no commit `aaebd17b4246c2623c36954d8bedc01795eb4912`, leitura sem segredos/checkout/Neon/SQL, um único GET sem retry/redirect, 20 registros máximo, relatório mínimo UTC/HTTP/NCT. O **Documento 246** `docs/governance/246-d2-ctgov-e3-workflow-criado-despacho-pendente.md` registra aprovação e **limite da integração GitHub: não expõe disparo workflow_dispatch**. Nenhum job foi acionado pelo assistente, nenhum HTTP/JSON da API CTgov foi observado, `DISPATCH_PENDING` — não anunciar `PASS`. **CP264 vigente**, `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP264.md`. Próximo ato único: titular clicar **Run workflow** uma vez na branch `main` em `https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/workflows/d2-ctgov-single-public-get.yml` e compartilhar link da execução; então verificar run/logs e registrar resultado, sem rerun. Fase 4 documental encerrada, D2 parcial, Fase 5 `NOT_STARTED`, readiness operacional `NOT_READY`; Ficha e gates científicos/BRGs/SA/migrations preservados. Conversa aberta.

## CP263 — D2 ClinicalTrials.gov: HTTP direto autorizado interrompido por DNS

O proprietário autorizou **“Execução http autorizada”** para nova via **direta** após CP262. Uma única tentativa `curl GET` com os parâmetros do Doc. 242 terminou em 2026-10-23T20:33:01Z com **exit=6, `Could not resolve host: clinicaltrials.gov`**; `curl http_code=000` indica **ausência de HTTP observado**, não código real da fonte. Nenhum resultado JSON, `totalCount`, NCT ou hora da fonte. **Documento 244** `docs/governance/244-d2-ctgov-e2-http-direto-dns-stop.md` distingue DNS do canal HTTP de E1 (Doc. 243); não houve retry, lookup NCT, CI, código novo, Neon/SQL ou resultado científico. Estado `D2_CTGOV_E2_STOP_DNS_IN_EXECUTOR / SOURCE_AVAILABILITY_UNVERIFIED`. **CP263** `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP263.md` vigente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 factual parcial, Fase 5 `NOT_STARTED`, Ficha N2 e BRGs/SA inalterados. Próximo `Prossiga`: decidir entre um **único** ambiente alternativo com aprovação separada, export oficial ou diferimento; não repetir chamada no ambiente sem DNS. Conversa aberta.

## CP262 — D2 ClinicalTrials.gov: tentativa conectada sem resposta verificável da API

Após prioridade D2 multifonte aprovada (Doc. 241) e preflight documental (Doc. 242), proprietário declarou **“Aprovada a primeira consulta conectada.”** O **Documento 243** (`docs/governance/243-d2-ctgov-e1-consulta-conectada-indeterminada-stop.md`) registra a tentativa de `GET ClinicalTrials.gov /api/v2/studies` em um canal de abertura pública. A ferramenta retornou **URL inacessível por esse mecanismo**, sem status HTTP originário, payload, `totalCount`, `returned_count`, NCT ou resposta UTC. Um primeiro endereço com delimitadores `&` mal codificados, seguido de um endereço correto, não resultou em resposta da fonte. **`STOP / INDETERMINATE / SOURCE_RESPONSE_NOT_OBSERVED`**; não afirmar API inoperante nem zero registros e não efetuar retries ou três lookups NCT. **CP262 vigente** `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP262.md`; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, D2 factual parcial e Ficha N2 intacta, BRGs/SA/migrations preservados. Próximo `Prossiga`: deliberação sobre um caminho alternativo único autorizado de leitura pública, export oficial fornecido pelo proprietário ou diferimento da consulta, **sem ação externa por inferência**.

## Pós-CP261 — Prioridade D2 multifonte aprovada; ClinicalTrials.gov preflight documental preparado (2026-10-23)

Após o Doc. 241, o proprietário afirmou **“Prioridade aprovada.”** e autorizou o preflight mínimo com `Prossiga`. O **Documento 242** (`docs/governance/242-d2-clinicaltrials-preflight-api-v2-prioridade-aprovada.md`) registra `APPROVED — OES / POST-F4-PRIORITY / D2_MULTISOURCE_READ_ONLY_FIRST`, parâmetros candidatos da API v2 ClinicalTrials.gov, **uma página de até 20 registros** e até três consultas NCT de controle **somente se futuramente autorizadas**, critérios PASS/PARTIAL/STOP, relatório mínimo de proveniência e minuta de aprovação operacional específica. **Nenhuma chamada a dados ClinicalTrials.gov, CI/código/Neon/SQL, persistência factual, gasto ou mudança científica autorizada/executada.** Estado `D2_CTGOV_PREFLIGHT_DOCUMENTARY_COMPLETE / OWNER_CONNECTED_PROBE_DECISION_PENDING`. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness operacional `NOT_READY`. CP261 continua o checkpoint de continuidade vigente; não inventar CP262. Próxima decisão: aprovar ou revisar pacote de consulta conectada Doc. 242 §7.

## CP261 — Encerramento metodológico-documental aprovado da Fase 4

Em resposta à **minuta final Documento 239**, o proprietário manifestou **“Minuta aprovada.”** em 23/10/2026. O **Documento 240** `docs/governance/240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md` registra **`APPROVED — OES / F4-FINAL-GATE / PASS_DOCUMENTARY_ONLY`**, condicionado a **C1–C6** do Doc. 239. **Estado Fase 4: `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`.** Sua aceitação abrange os critérios `F4-C01–F4-C06` e desenho documental `SF-01–14/R0–R8/AT-01–12`, com 9 cenários coerentes sem ressalvas adicionais, 3 condicionados (AT-05/09/12), **zero end-to-end executados** na matriz e **nenhuma revisão científica independente**. A2 não equivale a A3; invalidar sinal científico exige revisor humano apropriado; alterações editoriais respeitam proveniência/versionamento. **Readiness operacional `NOT_READY`; M3 `BLOCKED`; Fase 5 `NOT_STARTED`.** Gates BRG/SA, 36 migrations `UNREVIEWED`, riscos de persistência, auditoria, recuperação e calibração normativa continuam exigíveis **antes das operações respectivas**, não dispensados. D0 documental encerrado; D1 sintético memória restrito; D2 factual parcial, D2-E3 documental restrito encerrado; Ficha N2 e GRADE, ProductVersion, currentness e assurance não alterados. **Handoff vigente CP261**, `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP261.md`. Próximo `Prossiga`: avaliar prioridades pós-Fase 4, sem iniciar Fase 5/infra/pilotos por inferência. Conversa aberta.

## CP260 — Marco determinante de encerramento metodológico e documental da Fase 4

**Decisão expressa do proprietário (23/10/2026):** adotar **o encerramento metodológico e documental como marco determinante de conclusão da Fase 4**, segundo **Documento 237** (`docs/governance/237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md`). **Critério aprovado, encerramento NÃO concedido.** Estado `PHASE_4_DOCUMENTARY_METHODOLOGICAL_EXIT_CRITERION_APPROVED / PHASE_4_CLOSURE_PENDING / OPERATIONAL_NOT_READY`. Condições de saída `F4-C01–F4-C06`: rastreabilidade SF-01–SF-14; confronto documental integrado R0–R8 e AT-01–AT-12, com ressalvas AT-05/09/12; governança N/A e revisão humana; limites temporais/currentness/M3; ledger de riscos operacionais diferidos; parecer final e aprovação expressa. **Não exigir** Neon, migrations, M3 ou produção para o encerramento exclusivamente documental; **não dispensar** BRGs/SA antes da operação aplicável. D1 sintético e D2 factual restrito são evidências de escopo limitado, não homologação operacional. Sem alteração de Ficha N2, GRADE, assurance, currentness, gates científicos ou Fase 5. Próximo `Prossiga`: montar matriz de evidências e lacunas documentais F4-C01–F4-C06, sem execução factual/CI/SQL/Neon. Ponteiro de continuidade CP260; conversa atual aberta.

## CP259 — Encerramento técnico-documental restrito D2-E3

O proprietário autorizou adendo de rastreabilidade no inventário N2; `docs/products/49-caso-real-01-busca-triagem-inicial.md`, seção 14, registra Zhou 2022 (PMID 35442432, NCT03613519) e Nazem 2023 (PMID 37999953, NCT03366870) como candidatos PICO diretos, anteriores ao baseline 2026-10-04, com vinculação quantitativa a Hwang ainda parcial/não verificada e pré-appraisal não formal. **Documento 236** `docs/governance/236-d2-e3-encerramento-restrito-rastreabilidade-shaffer-cp259.md` encerra **apenas** as atividades D2-E3 de recuperação, reconciliação, triagem e rastreabilidade: `D2_E3_CLOSED_RESTRICTED_DOCUMENTARY_RECONCILIATION_ONLY`. **Não** indica validação científica, fechamento de D2, busca exaustiva, novo RCT pós-baseline ou prontidão de Fase 4. Sem mudança Ficha, síntese Docs. 52/53, RoB2 formal, GRADE, ProductVersion, currentness, assurance ou gates. Fonte ZIP original em Biblioteca pessoal conforme CP257/258, não no GitHub. D1 sintético, T2-A2/A2-G4 diferido, A2-G5/runtime não autorizado, SA abertos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, migrations UNREVIEWED. Handoff vigente `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP259.md`. Próximo `Prossiga`: decidir prioridade do próximo avanço factual proporcional de D2 **sem executar** ações científicas/operacionais por inferência. Conversa aberta.

## CP258 — Avaliação metodológica focal D2-E3/A3 e continuidade

Após CP257, Documento 234 registrou triagem de Zhou/Nazem/OASIS/Verlinden/Malarkey e sobreposição com Hwang/Nazari delimitada. O proprietário autorizou avaliações, e o Documento 235 registra pré-appraisal cinco domínios tipo RoB 2 para Zhou e Nazem no ISI pós-tratamento (~9 semanas): **pelo menos algumas preocupações**, dados ausentes relevantes, avaliação **não formalmente validada**; Nazem ISI pós 91/116 SHUTi vs 98/115 IEW; Zhou não resposta possivelmente ligada à adesão; nenhum indício comprovado de reversão da direção favorável. Discrepância de limite superior no resumo PubMed de Nazem (seguimento 1 ano) registrada. **Sem alteração de Ficha, ProductVersion, GRADE, currentness, assurance ou gates**. Evidência binária original Shaffer persiste em Biblioteca pessoal conforme CP257. Handoff vigente `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP258.md`; CP258 preventivo/proporcional, não encerramento de conversa. D1 sintético reescopado, T2-A2/A2-G4 diferido, runtime não autorizado, SA abertos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Próximo `Prossiga`: decidir se **adendo documental restrito ao corpus N2** é útil; exigir autorização expressa antes de editar documento de produto; não reabrir buscas/appraisal sem materialidade.

## CP257 — Checkpoint preventivo de continuidade D2-E3/A1

Handoff `archive/handoffs/oes/OES_Continuidade_2026-10-23_CP257.md` consolida a reconciliação do suplemento Shaffer em `docs/governance/233-d2-e3-a1-reconciliacao-suplemento-shaffer.md` após a triagem preliminar histórica no Doc 232. A fonte original `supplementary_material_zsag264.zip` foi preservada **na Biblioteca pessoal do ChatGPT** (fora do GitHub público): `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`. Identificados 10 estudos/12 estimativas no conjunto SHUTi vs controle educacional; Christensen/HealthWatch é não aderente ao comparador de sono, braços Zhou e OASIS compartilham controle, estudos com populações especiais exigem exame. Status **`D2_E3_A1_SHAFFER_STUDY_SET_RECONCILED / PICO_ELIGIBILITY_PARTIAL / SCIENTIFIC_MATERIALITY_NOT_ASSESSED`**. CP257 **não** autoriza modificar Ficha, GRADE, certainty, currentness, assurance ou gates; D2-E2 prova NCBI PASS técnico no run 39977371270 permanece histórica, sem nova CI. D1 reescopado, A2-G4 diferido, A2-G5/runtime não autorizado; SA abertos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. **Não utilizar ChatGPT Work.** Próximo `Prossiga`: preparar decisão focal de elegibilidade e sobreposição dos estudos indicados, sem avaliação material automática. Conversa atual continua aberta.

## CP256 — Prova conectada NCBI D2-E2 tecnicamente PASS

Documento 231 e handoff CP256 consolidam cliente Python em `prototypes/d2_e2/`, workflow manual e execução conectada [GitHub Actions 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270) concluída `success`: 11/11 testes PASS, 4/4 PMIDs-semente identificados em ESearch de controle; query PubMed limitada a 2026-10-05–2026-10-23 com `count=1`, um PMID recuperado e ESummary (Shaffer 2026, PMID 42841437). `D2_E2_CONNECTED_NCBI_RETRIEVAL_PASS` somente **técnico e restrito à query**, sem busca exaustiva, appraisal, avaliação de sobreposição, certeza, conclusão ou alteração da Ficha N2. CP255 registra falha do mecanismo anterior, agora superada com Python/E-utilities. D1 reescopado encerrado, A2-G4 diferido/não aceito, A2-G5/runtime não autorizado; SA-05/06/07/08/10 abertos/diferidos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Sem Work, Neon, SQL, serviços pagos, novas execuções de CI ou gates. Próximo `Prossiga`: preparar delimitação científica da triagem do candidato Shaffer para aprovação específica, sem executá-la por inferência.

## CP255 — D2-E1 factual parcialmente executado; cobertura não verificada

Documento 230 registra autorização expressa de D2-E1 PubMed somente leitura, relato de quatro estudos-semente identificados individualmente, cinco referências exploratórias e candidato Shaffer 2026 PMID 42841437, **sem export verificável da busca combinada**. Acesso E-utilities/interface estruturada não demonstrado; resultado `D2_E1_PARTIAL_RETRIEVAL_SEARCH_REPRODUCIBILITY_NOT_VERIFIED`, sem PASS de cobertura, sem alegação científica nova e sem atualização da Ficha. Proprietário **não utilizará ChatGPT Work**. Não repetir o mesmo acesso malsucedido; alternativa futura condicionada: export PubMed por navegador comum/manual ou mecanismo aprovado, com consulta literal, filtros, contagem, data e PMIDs. A tentativa D2-E1 está encerrada PARCIAL, não homologada. D1/CP253 e limites D2-P0/CP254, A2-G4 diferido, riscos abertos, Fase 4 NOT_READY, Fase 5 NOT_STARTED e 36 migrations UNREVIEWED inalterados. Próximo `Prossiga`: orientação/procedimento proporcional para mecanismo alternativo, sem executar coleta por inferência.

## CP254 — Preparação científica D2-P0 aprovada e viabilidade delimitada

Documento 229 registra aprovação expressa `D2-P0 / SCIENTIFIC_PILOT_SCOPING_ONLY`, exclusivamente documental, e consolida A1 (comparação N2/N1/N0/N3; candidato N2 dCBT-I produto `OES-P-2026-000401` A2 interno), A2 (PICO/baseline de 2026-10-04, elegibilidade, fontes e registro mínimo) e A3 (parecer `FEASIBLE_WITH_BOUNDED_OPERATIONAL_AUTHORIZATION`, **sem prontidão operacional comprovada**). D2-E1 `FIRST_FACTUAL_RETRIEVAL_READ_ONLY` permanece **PROPOSTO / NOT_AUTHORIZED**: nenhuma consulta PubMed/ClinicalTrials/BVS ou registro factual novo. Próximo `Prossiga`: preparar proposta objetiva de autorização D2-E1 e submeter decisão, sem execução. D1 sintético encerrado no escopo CP253; T2-A2/A2-G4 diferido/não aceito, A2-G5/runtime NOT_AUTHORIZED; branch experimental preservada sem merge. SA-05/06/07/08/10 abertas/diferidas; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrations `UNREVIEWED`; nenhum código, teste, SQL, Neon, CI, deploy, serviço pago, alteração de conclusão/assurance/currentness ou promoção de gates.

## CP253 — Encerramento restrito aprovado do demonstrador sintético D1 reescopado

Documento 228 e handoff CP253 consolidam D1-R1 (inventário de entregas/lacunas), D1-R2 (suficiência estática do código T1/T2-A1) e D1-R3 (proposta **expressamente aprovada** pelo proprietário). Estado do **demonstrador sintético D1 reescopado**: `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`; o plano D1 originalmente mais amplo **não foi homologado globalmente**. T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 PASS históricos) e T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (39 próprios + 36 T1 = 75 PASS históricos) inalterados; S1–S6 somente nos limites sintéticos locais. Nenhum teste foi reexecutado e nenhum código modificado. T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`, A2-G5/runtime `NOT_AUTHORIZED`. Riscos SA-05/06/07/08/10 permanecem abertos/diferidos, SA-02 condicionada, SA-03 parcial, SA-11/12 apenas mitigadas estaticamente. Branch A2 preservada `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, sem merge em `main`. D2 factual diferido; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`; nenhuma autorização nova para SQL/Neon/CI/nuvem/deploy/API/fonte factual/serviços pagos/gates. **Próximo `Prossiga`: propor decisão proporcional de prioridade do marco seguinte; não iniciar nova implementação automaticamente.**

## CP252 — Reescopo aprovado: A2-G4 diferido, demonstrador D1 preservado

Documento 227 registra aprovação expressa do reescopo: interromper antecipação da infraestrutura PostgreSQL. T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` e T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` mantidos; T2-A2/A2-G4 `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`; A2-G5/runtime NOT_AUTHORIZED; D1 global `RESCOPED_NOT_GLOBALLY_CLOSED`. Riscos SA-05/06/07/08/10 permanecem abertos para futura integração por stack definida, não declarados resolvidos. Branch preservada `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`; `main` sem A2. T1 36 e T2-A1 75 PASS históricos. Próximo `Prossiga`: inventário de entregas e lacunas do demonstrador reescopado.

## CP251 — Reorientação proporcional aprovada do método de trabalho

Documento 226: interromper sequência redundante por risco (triagem, invariantes, revisão adversarial, não correção, revisão da não correção, checkpoint). Priorizar análise integrada do caminho mínimo até conclusão **estática** A2-G4, com riscos classificados uma vez em correção comprovável, dependência de testes e decisão de contrato. KPI passa a ser decisão/entrega técnica verificável, não volume documental. Próximo `Prossiga`: avaliação integrada SA-05/06/07/08/10, não triagem isolada SA-10. **Gates e autorização por atividade preservados**. A2-G4 ainda não aceita; A2-G5/runtime NOT_AUTHORIZED. Branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1` intacta, `main` sem `a2/`. SA-05 e SA-08 abertas/altas, SA-07 moderada/aberta; T1 36/T2-A1 75 PASS só históricos.

## CP250 — SA-08 recibos e replay, exclusivamente documental

Documento 225 consolida A1–A5 pós-CP249. SA08-R1/R2/R3; sete invariantes I-01–I-07; adversarial AV08-01/02/03 e mitigação proporcional A4/A5 sem implementação. Estrutura (contagem, sequência e revisão) **não prova** semântica dos recibos. Sem payload original, fingerprints históricos não são genericamente reconstruíveis. Criação repetida retorna snapshot corrente; quatro comandos não-create repetidos retornam respostas históricas. Replay T1 do estado não é auditoria independente de todos os recibos. **SA-08 ABERTA/ALTA**; branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, sem alteração; `main` não contém `a2/`. A2-G4 não aceita, A2-G5/runtime NOT_AUTHORIZED, SA-05 alta aberta, SA-06 aberta, SA-07 moderada aberta, SA-10 aberta, SA-03 parcial; T1 36/T2-A1 75 PASS apenas históricos. Próximo `Prossiga`: triagem estática SA-10/SQLSTATE.

## CP249 — Política numérica JSONB SA-07 somente documental

Documento 224 consolida A1–A5 pós-CP248 e checkpoint documental A6: SA07-N1/N2/N3 abertos (finitude/faixa, precisão/round-trip, serializer Psycopg). Quatro comandos T1 declaram `cycle_no: int`; `True`, `1` e `1.0` podem ser comparáveis mas não identicamente codificados. Política candidata: preservar `SHA-256(encoded(payload).encode("utf-8"))`, não introduzir coerções, distinguir domínio/idempotência/persistência; atenção às leituras SQL antes de qualquer escrita e ao fingerprint que pode falhar antes do codec. AV-01–AV-08 revisadas somente estaticamente, sem PASS operacional. **SA-07 ABERTA/MODERADA**. Seis arquivos A2-G4 somente na branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`; não publicados em `main`. A2-G5/runtime NOT_AUTHORIZED, SA-05 aberta/alta, SA-03 parcial, SA-06/08/10 abertas; T1 36/T2-A1 75 PASS históricos. Próximo `Prossiga`: triagem SA-08 estática.

## CP248 — Preservação segregada do código experimental A2-G4 (sem promoção)

Documento 223 formaliza a decisão expressa do proprietário de preservar os **seis arquivos exatos** de `prototypes/d1_t2/a2/` em branch separada: `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit fixo `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, descendente direto do CP247 `7f3b25aa5563455a98e01c7c358118dfe9c38546`. Comparação branch/commit `identical` no preflight; bytes e objetos Git descritos no Documento 223; hashes SHA-256 locais no Documento 222. **`main` não contém o código A2-G4** e não deve recebê-lo por merge/PR/execução sem decisão separada; branch não protegida explicitamente contra exclusão. Não presumir presença do staging entre conversas; recuperar pelo commit Git. Esta é uma preservação técnica, **não aceitação estática, teste ou autorização operacional**. SA-05 global ABERTA/ALTA, SA05-R1/R2/R3 mitigadas só estaticamente; SA-02 dependente de SA-05; SA-03 parcial; SA-06/07/08/10 abertas; SA-11/12 apenas mitigadas estaticamente. A2-G4 escrita de fonte aprovada mas não aceita; A2-G5/T2-A2 operacional NOT_AUTHORIZED. T1 36/T2-A1 75 PASS históricos, Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrações UNREVIEWED; D1 sintético prioritário. Próximo `Prossiga`: triagem estritamente estática SA-07/JSONB, sem importação, execução, SQL, CI ou Neon.

## CP247 — A2-G4: fábrica dedicada e SA05-R1/R2/R3 somente estáticos

Documento 222 consolida A1–A7 pós-CP246 e publicação A8 **exclusivamente documental**. `DedicatedConnectionFactory` nominal, uso único da Unit of Work em falha de aquisição, exceção `ConnectionAcquisitionError` e exigência dos métodos `execute/rollback/commit/close`; SA05-R1/R2/R3 mitigadas textualmente e R3 revisada adversarialmente. **SA-05 GLOBAL ABERTA/ALTA:** exclusividade, conexão nova, role, banco, TLS e configuração operacional não comprovados. SA-02 depende de SA-05; SA-03 parcial; SA-06/07/08/10 abertas; SA-11/12 mitigadas/revisadas somente estaticamente. Seis arquivos técnicos `prototypes/d1_t2/a2/` **não publicados**, só staging local, hashes no Documento 222; A2-G4 não aceita tecnicamente. Sem import/compilação/execução, Psycopg instalado, testes, CI, SQL, Neon, grants, dados reais ou custos; A2-G5/T2-A2 operacional `NOT_AUTHORIZED`. T1 36/T2-A1 75 PASS históricos, F01–F07 documentais, L1–L4/O-01–O-10 pendentes, Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrações UNREVIEWED. Próximo `Prossiga`: triagem adversarial estritamente estática SA-07/JSONB após Freshness Gate.

## CP246 — A2-G4: revisão SA-11/SA-12, SA-06 parcialmente mitigada; fonte somente local

Documento 221 consolida A1–A6 pós-CP245 e checkpoint A7 **exclusivamente documental**. Seis arquivos do adaptador em staging local, hashes SHA-256 registrados no Documento 221; **nenhum `prototypes/d1_t2/a2/` publicado no GitHub**. SA-11 (falha de rollback pré-COMMIT) e SA-12 (falha de fechamento após rollback que retornou) mitigadas/revisadas **somente por inspeção textual**. SA-06 mitigada parcialmente: `CommitOutcomeUnknown` armazena falhas de fechamento na saída canônica do contexto, mas reconciliação, resultados do servidor e cobertura adicional continuam abertos. SA-02 condicionada a SA-05. SA-05 ALTA, SA-07 MODERADA, SA-08 ALTA, SA-10 MODERADA **abertas**, SA-03 parcial; não há testes novos ou aceitação A2-G4. A2-G4 **aprovada apenas para código estático**, sem publicação técnica; A2-G5/T2-A2 operacional `NOT_AUTHORIZED`. Sem importação, compilação, execução, Psycopg instalado, CI, SQL, Neon, grants, dados reais, custos ou deploy. T1 36/T2-A1 75 PASS apenas históricos; F01–F07 documentais, L1–L4/O-01–O-10 pendentes, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Próximo `Prossiga`: triagem adversarial estática SA-05 após Freshness Gate.

## CP245 — A2-G4: SA-11 bloqueia aceitação estática, sem publicação técnica

Documento 220 consolida A1–A6 pós-CP244 e a publicação **somente documental** A7. Seis arquivos A2-G4 estão apenas no staging local, com hashes no Documento 220; **nenhum arquivo `prototypes/d1_t2/a2/` integra o GitHub**. SA-02 mitigada no fluxo textual, condicionada a SA-05; SA-06 mitigada parcialmente por comunicação tipada de falha de limpeza pós-COMMIT. **SA-11 novo BLOQUEADOR ALTO**: exceção anterior a COMMIT seguida de rollback falho em `__exit__` pode não comunicar rollback não confirmado por tipo estruturado. SA-05/07/08/10 abertas; SA-03 parcial. A2-G4 autorizado só para código estático pelo Documento 218, mas ainda **não aceito nem publicado tecnicamente**; A2-G5/T2-A2 operacional NOT_AUTHORIZED. Sem import/execução/compilação, driver, testes, CI, SQL, Neon, grants, dados ou custos; T1 36/T2-A1 75 PASS históricos, F01–F07 documentais, L1–L4/O-01–O-10 pendentes, Fase 4 NOT_READY, Fase 5 NOT_STARTED e 36 migrações UNREVIEWED. Próximo `Prossiga`: correção estática SA-11, não publicar automaticamente código.

## CP244 — A2-G4: código apenas em staging, publicação técnica bloqueada

Documento 219 registra A1–A6 pós-CP243: seis arquivos experimentais **em staging local e não publicados**; revisões SA-01–SA-10, mitigação estática parcial SA-01/03/04/09 e **SA-02 REABERTO, BLOQUEADOR CRÍTICO** — lógica de retry por `23505` sem confirmação inequívoca de rollback após falha de limpeza. SA-05/06/08 pendentes ALTA; SA-07/10 MODERADA. Autorização do Documento 218 permanece válida **somente para código-fonte estático** com Psycopg 3.3.6 como referência, mas **A2-G4 NÃO ACEITO NEM PUBLICADO TECNICAMENTE**; nenhum dos seis arquivos `a2/` integra o GitHub. Nenhuma execução, instalação, SQL, Neon, CI ou testes. A2-G5/T2-A2 operacional NOT_AUTHORIZED. T1 36 e T2-A1 75 PASS apenas históricos; F01–F07 documentais, L1–L4/O-01–O-10 pendentes, Fase4 NOT_READY, Fase5 NOT_STARTED e 36 migrações UNREVIEWED. Próximo `Prossiga`: correção estática SA-02, sem publicar código.

## CP243 — A2-G4: autorização expressa de código estático, ainda não implementado

Documento 218 registra `APPROVED / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE` concedido expressamente pelo proprietário. Limitado a seis arquivos técnicos em `prototypes/d1_t2/a2/`, sem modificar T1/T2-A1, usando Psycopg 3.3.6 exclusivamente como referência de API. **A2-G4 estático aprovado, código NÃO INICIADO neste checkpoint**; nenhuma instalação, execução/import operacional, SQL, Neon, CI, testes, DDL, grant ou custo. A2-G5 e T2-A2 operacional NOT_AUTHORIZED. T1 36/T2-A1 75 PASS históricos, F01–F07 só documentais, L1–L4 e O-01–O-10 pendentes; Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima atividade código estático restrito sob novo `Prossiga`.

## CP242 — A2-G4: minuta de autorização estática proposta, não aprovada

Documento 217 consolida A1–A4 pós-CP241 e formula somente `PROPOSED_NOT_APPROVED / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY`: seis arquivos técnicos candidatos em `prototypes/d1_t2/a2/`, sem execução de código, SQL, Neon, CI ou testes. Revisão AA-01–AA-09 e ajustes AF-01–AF-05 endereçados **documentalmente**; AF-03 requer decisão expressa sobre versão/distribuição de Psycopg 3 ou exceção estática antes da implementação. Identidade de classes entre contextos de importação não é garantida; commit explícito sem confirmação implícita é exigência; `CommitOutcomeUnknown` continua candidato. **A2-G4/G5 e T2-A2 NOT_AUTHORIZED**. Nenhum arquivo técnico criado, nenhum grant/schema/data alterado. F01–F07 apenas documentais, L1–L4/O-01–O-10 pendentes; T1 36 e T2-A1 75 históricos PASS; Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED. Próximo: deliberação preparatória AF-03 apenas documental sob novo `Prossiga`.

## CP241 — A2-G4: contrato documental do adaptador consolidado (sem autorização)

Documento 216 consolida A1–A4 pós-CP240 (desenho de adaptador Python/PostgreSQL, adversarial RA-01–RA-10, ajustes RF-01–RF-05 e suficiência exclusivamente documental). UoW transacional, concorrência por cenário, criação com colisão e rechecagem, idempotência/replay, confirmação incerta e limites JSONB permanecem **especificações candidatas não executadas**. A2-G4/G5 e implementação T2-A2 `NOT_AUTHORIZED`; nenhum código, SQL, Neon, CI, driver, dados, GRANT ou gates alterados. F01–F07 apenas documentais, L1–L4/O-01–O-10 pendentes. T1 36/T2-A1 75 históricos PASS; Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED. Próximo: minuta estrita de deliberação A2-G4, somente documental sob `Prossiga`.

## CP240 — A2-G3: concessões mínimas de aplicação verificadas

Documento 215 registra autorização expressa e execução de A2-G3 no Neon sintético: USAGE do schema ao app, SELECT/INSERT nas três tabelas, UPDATE por coluna apenas revision/state em scenario. Verificação READ ONLY confirmou ausência de CREATE, DELETE/TRUNCATE, UPDATE irrestrito, privilégios adicionais e acesso PUBLIC, com zero linhas nas três tabelas. Owner administrativo elevado permanece risco, runtime proibido, TLS externo N1-E3 com limites. A2-G3 COMPLETED_MINIMAL_GRANTS_VERIFIED; A2-G4/G5 e T2-A2 NOT_AUTHORIZED. T1 36 e T2-A1 75 históricos PASS, Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima atividade apenas proposta documental A2-G4.

## CP239 — A2-G2/E: criação estrutural aprovada e verificada

Documento 214 registra aprovação expressa e execução Neon sob owner para criação transacional do namespace `oes_t2a2_proto` e três tabelas vazias `scenario`, `event`, `receipt`. Pós-verificação SQL somente leitura PASS para schema/tabelas, três PK, FK, CHECK/NOT NULL, propriedade de `oes_t2a2_owner`, zero registros, PUBLIC e app sem USAGE/CREATE schema. Sem GRANT, inserções, CI ou adaptador; owner administrativo elevado segue risco explícito. A2-G3–G5/T2-A2 NOT_AUTHORIZED; T1 36 e T2-A1 75 PASS históricos, Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima atividade: proposta documental A2-G3.

## CP238 — P2 SQL catálogos, achados de privilégios

Documento 213 registra autorização expressa e execução Neon P2 somente leitura sob `oes_t2a2_app`, `REPEATABLE READ READ ONLY`, Q01–Q07. Schema `oes_t2a2_proto` e objetos não encontrados, owner CREATE efetivo verdadeiro e app falso; owner/runtime com CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS e associação `neon_superuser`; ACL PUBLIC CONNECT/TEMP e não CREATE; transação, identidade e timeouts confirmados. P2 `COMPLETED_WITH_SECURITY_FINDINGS`, E/T2-A2 `NOT_AUTHORIZED`; TLS do plugin não demonstrado ponta a ponta. Não houve DDL, DML, GRANT, CI ou implementação; T1 36 e T2-A1 75 PASS históricos, Fase4 NOT_READY, Fase5 NOT_STARTED. Próximo passo documental: proposta A2-G2/E.

## CP237 — Preflight P1 autorizado e concluído administrativamente

Documento 212 registra aprovação expressa de P1 e consultas administrativas Neon read-only. Projeto, branch, banco e owner nominal confirmados; branch não protegida, rede pública não bloqueada, endpoint read_write idle configurado em 0,25 CU, tempo compute reportado 1376s. Consumo não prova billing, e owner não prova CREATE/ACL SQL. P1 COMPLETED_WITH_LIMITATIONS, P2/E/T2-A2 NOT_AUTHORIZED; sem SQL, CI, alteração infra, GRANT ou implementação. Política Free Doc 211 permanece, sem novos gastos. T1 36 e T2-A1 75 PASS somente históricos; Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima atividade apenas proposta documental P2.

## CP236 — Política transversal de recursos gratuitos e despesas

Documento 211 registra decisão de governança transversal aplicável a serviços gratuitos previamente autorizados: consumo ordinário, consultas e repetições justificadas sem aprovação financeira por chamada; rate limits e controles técnicos preservados; acompanhar quotas conforme risco, STOP em limites materiais; qualquer upgrade, contratação, cartão ou cobrança exige aprovação expressa. Limites pontuais de três chamadas e uma por operação de P1 não se generalizam. **P1/P2/E e T2-A2 permanecem NOT_AUTHORIZED para atos técnicos**; A2-G1 permanece aprovação documental. Nenhuma nova operação Neon/SQL/CI nesta decisão; T1 36 e T2-A1 75 PASS somente históricos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED.

## CP235 — Controle financeiro proporcional Neon Free e proposta P1

Documento 210 consolida correção de circularidade C0/C1/C2 e manifestação do proprietário de que controles financeiros prévios para cada GET P1 são desproporcionais no Neon Free sem cartão. Regra prospectiva: Free apenas, sem cartão/upgrade/serviços pagos, acompanhar quotas proporcionalmente e STOP em risco material; não exigir prova individual de zero custo por chamada. P1 ainda NOT_AUTHORIZED (3 consultas de metadados, uma cada); P2, E e T2-A2 NOT_AUTHORIZED. A2-G1 aprovação somente documental, F01–F07 sem validação, L1–L4 e O-01–O-10 pendentes. Nenhum Neon, SQL, CI, teste ou gasto neste checkpoint. T1 36 PASS e T2-A1 75 PASS somente históricos. Próximo passo: avaliação e deliberação expressa P1.

## CP234 — Proposta restrita de allowlist P1

Documento 209 consolida atividades documentais A1–A3 pós-CP233: P1 com somente describe_project, get_branch e get_postgres_database, parâmetros fixos e sem repetição automática; endpoints excluídos, achados R1–R4 e condição financeira prévia obrigatória. Minuta P1 NÃO APROVADA; P2/E e T2-A2 NOT_AUTHORIZED. A2-G1 aprovação apenas documental condicionada; F01–F07 somente endereçados documentalmente, L1–L4, PA-01–PA-08 e O-01–O-10 preservados. Nenhum Neon, SQL, CI, DDL/DML, GRANT, teste, adaptador ou gasto. T1 36 PASS e T2-A1 75 PASS históricos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrações UNREVIEWED. Próximo passo apenas avaliar minuta e pré-condições para decisão eventual P1.

## CP233 — Protocolo de preflight A2-G2/P e revisão adversarial

Documento 208 consolida três atividades somente documentais desde CP232: D0 histórico, P1 metadados Neon, P2 catálogos SQL read-only e E estrutura futura, todos com autorizações separadas; PF-01–PF-10, PA-01–PA-08 (2 CRITICAL, 4 HIGH, 2 MODERATE), AC-01–AC-10. Parecer A2-G2/P_REVISE_BEFORE_OPERATIONAL_AUTHORIZATION. A2-G1 CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED; **P1, P2, E e T2-A2 NOT_AUTHORIZED**. Sem operações Neon, SQL, CI, GRANT, DDL/DML, adaptador, testes remotos ou gastos. F01–F07 só endereçados documentalmente, L1–L4 vigentes, O-01–O-10 não executados. N1-E3 TLS externo cliente comprovado e backend SSL_FALSE observado. T1 36 e T2-A1 75 testes PASS apenas históricos; Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima atividade: minuta documental P1 exclusivamente, sob novo Prossiga.

## CP232 — Decisão expressa A2-G1 documental condicionada

Documento 207 registra aprovação expressa do proprietário exclusivamente da referência arquitetural documental condicionada A2-G1, conforme Documentos 205–206. F01–F07 somente endereçados documentalmente, L1–L4 condicionantes, O-01–O-10 não executados. A2-G2 e posteriores NÃO AUTORIZADOS; T2-A2 NOT_AUTHORIZED para implementação/execução. Nenhum SQL, DDL/DML/GRANT, CI, Neon, teste remoto ou adaptador. N1-E3 TLS cliente verificado e backend SSL_FALSE observado; papel privilegiado oes_t2a2_runtime NÃO USAR. T1 36 PASS e T2-A1 75 PASS históricos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrações UNREVIEWED. Próximo Prossiga: somente preparação documental A2-G2.

## CP231 — Pacote deliberativo documental A2-G1 sem aprovação

Documento 206 consolida propostas de solução documental F01–F07, lacunas L1–L4, oráculos O-01–O-10 e minuta de aprovação de desenho condicional A2-G1 PENDENTE. Nada executado em Neon, SQL/DDL/DML/GRANT, CI, drivers, testes ou adaptador; T2-A2 NOT_AUTHORIZED, T1 36 PASS e T2-A1 75 PASS apenas históricos. Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima atividade sob Prossiga: avaliação de decisão documental A2-G1 sem presumir aprovação.

## CP230 — Fronteira PostgreSQL pós-conexão exclusivamente documental

Documento 205 consolida A1–A3 e sete achados F01–F07 em REVISE_BEFORE_IMPLEMENTATION_AUTHORIZATION. Modelo de três tabelas, privilégios e transações permanecem candidatos, não executados. Nenhum SQL/Neon/CI/GRANT/implementação; T2-A2 NOT_AUTHORIZED. T1 36 PASS/T2-A1 75 PASS históricos; Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrations UNREVIEWED. Próxima: fechamento documental F01–F07 sob novo Prossiga.

## CP229 — N1-E3 autenticação e TLS externo

Documento 204: cinco execuções controladas de CI, com quinta execução PASS (run 39737616716, SHA 36f519f795331ffd83d5ef574f3d188b4921f2ea). Psycopg com `sslmode=verify-full` e CA confiável conectou como `oes_t2a2_app` ao banco `oes_t2a2_synthetic`, consulta read-only bem-sucedida. `pg_stat_ssl.ssl=false`, sem versão/cifra: observação interna divergente; não concluir segurança dos segmentos internos do Neon. N1-E3 encerrada **somente** para conexão externa verificada; T2-A2 NOT_AUTHORIZED.

## 1A. Prioridade vigente e diretriz arquitetural — CP214

- **Ordem prospectiva aprovada:** D0 documental/editorial concluído → **D1 protótipo sintético funcional prioritário** → D2 factual posterior → governança operacional completa posteriormente. O Documento 165 conserva a decisão histórica restrita a D0/D1 documental.
- **Preferência expressa do proprietário:** solução na nuvem e softwares gratuitos, sem uso de serviços pagos ou compromisso com fornecedor.
- **Arquitetura técnica em avaliação:** separar regras de domínio/processo da integridade de persistência; Python/monólito modular e FastAPI são candidatos; PostgreSQL permanece implementação de referência validada para PoC, não escolha final de produção. Não há implantação ou API autorizada.
- **Base canônica suplementar:** `docs/governance/169-prioridade-d1-stack-referencia-cp214.md`. **D1-A2 = somente consolidação documental**; D1-A3 = análise documental de dependências, fixtures e alternativas de execução, exclusivamente após novo `Prossiga`.
- **Gates/pendências permanecem integralmente inalterados:** Fase 4 NOT_READY; Fase 5 NOT_STARTED; nenhuma autorização adicional para SQL, Neon, CI, fontes factuais, cloud provisioning, contratação ou publicação.

## 1B. D1-A3–A5 — preparação técnica documental (CP215)

- `docs/governance/170-especificacao-minima-d1-a3-a5-cp215.md` consolida diagnóstico, plano mínimo S1–S6, incompatibilidades de vocabulário SQL/presentação e **pedido de autorização T1 ainda NÃO CONCEDIDO**.
- Execução proposta T1: serviços Python e testes isolados estritamente sintéticos; sem SQL, Neon, CI remota, deploy, APIs públicas, consultas factuais ou serviços pagos. T2 banco sintético e T3 cloud exigem aprovações separadas.
- Snapshot demonstrativo `oes.d1.monitor_snapshot/0.1` é proposta distinta da View SQL canônica; validações S5 históricas **não** demonstram execução atual ou equivalência.
- Artefato S5 run `37558043092`, id `11455658237`, tem expiração histórica prevista para 2026-11-06; ZIP ainda não foi inspecionado/preservado.
- **Próxima atividade D1-A6 após novo `Prossiga`:** submeter solicitação explícita para T1 sem iniciar implementação antes de aprovação. Estado dos gates, Fase 4/5 e demais pendências inalterado.

## 1C. D1-T1 — execução sintética autorizada e avaliação CP216

- Autorização expressa `OES / D1-T1 / PYTHON_SYNTHETIC_DOMAIN_ONLY`: Python, testes locais em memória, renderer e GitHub. Exclui SQL, Neon, CI remota, cloud, APIs públicas, busca factual, serviços pagos, migrations e mudança de gates.
- Código: `prototypes/d1/monitor.py`, `test_monitor.py`, `README.md`; HEAD pré-CP216 `c4c1e4aaaa2b00d3394e98f0e66148e891a93d1d`. Resultado histórico dos testes locais: **13/13 PASS**, não retestado neste checkpoint.
- Documento 171 contém matriz S1–S6 (**todas PARCIAIS**), riscos e critérios A–F de encerramento; `oes.d1.monitor_snapshot/0.1` não é View SQL original; T1 **NOT_CLOSED**.
- Próximo passo sob `Prossiga`: testes e correções de atomicidade/imutabilidade no núcleo Python, mantendo o escopo T1.

## 1D. D1-T1 — consolidação de incrementos CP217

- Decisão estratégica confirmada: D0 documental concluído → D1 funcional sintético atual → D2 factual posterior → governança operacional completa posterior (Documento 169). Python modular, preferência cloud e software gratuito (Documentos 169–170).
- Autorização expressa T1, registrada no Documento 171, permanece vigente apenas para Python em memória, testes locais, renderer e GitHub. SQL/Neon/CI/cloud/API pública/consultas factuais/serviços pagos/gates excluídos.
- Incrementos até HEAD pré-CP217 `bbd0d61d7270cf139c1a895503fc29dd0ec043ab`: teste local histórico 32/32 PASS, testes adversariais S1–S6, rollback sequencial e renderer próprio. README do protótipo ainda relata 21 testes; correção documental pendente.
- Documento 172: critérios S1–S6 PARCIAIS e T1 NOT_CLOSED. Próximo `Prossiga`: baseline sintético explícito com testes e versionamento, sem expansão de escopo.

## 1E. D1-T1 — encerramento técnico restrito aprovado (CP218)

- Aprovação literal: `APPROVED — OES / D1-T1 / SYNTHETIC_LOCAL_TECHNICAL_CLOSURE`. **T1 CLOSED_SYNTHETIC_LOCAL_ONLY**, sem homologação científica ou operacional (Documento 173).
- Evidência: Python sintético em memória, `prototypes/d1/`, 36 testes locais PASS reportados na revisão `768e2190ecde8a8713b80fd2bb378449f2d49033` e `TRACEABILITY.md`; sem reteste nesta formalização. Avaliações T1 anteriores dos Documentos 171–172 são snapshots históricos anteriores à aprovação de encerramento.
- D1 permanece prioritário; **T2 NÃO AUTORIZADO**. Próximo `Prossiga`: preparar requisitos e autorização de T2 documentalmente, sem PostgreSQL, Neon, SQL, CI, nuvem, API pública, consultas factuais, serviços pagos ou alteração de gates.
- D0 documental encerrado → D1 (T1 fechado) → D2 factual condicionado → governança operacional completa posterior.

## 1F. D1-T2/A1 — autorização expressa restrita (CP219)

- `APPROVED — OES / D1-T2-A1 / PYTHON_IN_MEMORY_REPOSITORY_BOUNDARY_ONLY` recebido e formalizado no Documento 192; **T2-A1 autorizado mas ainda não iniciado**.
- Permitido apenas: refatoração e testes Python locais de fronteira repositório/Unit of Work com adaptador em memória, diretório experimental separado, T1 e seus 36 testes intactos, GitHub/Freshness Gate.
- Exclusões expressas: SQL/PostgreSQL/Neon/drivers, CI remota, cloud/deploy/API pública, consultas factuais, dados reais, serviços pagos, migrações, gates e T2-A2. Sem mudança silenciosa de semântica `create_scenario`/`pending`.
- Próximo `Prossiga`: primeiro incremento T2-A1 do contrato Python em memória com testes locais, uma atividade delimitada e verificação de HEAD.

## 1G. D1-T2/A1 — consolidação CP220

- Cinco comandos integrados em memória; 19 testes ponte, 8 repositório e 36 T1 PASS historicamente; nenhum reteste no CP220.
- Documento 193: pendências de replay, falhas injetadas, documentação e cópia T1. T2-A1 não encerrado. T2-A2, PostgreSQL/SQL/Neon/CI/cloud não autorizados.
- Próximo `Prossiga`: testes locais de replay/atomicidade, com Freshness Gate.

## 1H. D1-T2/A1 — encerramento técnico restrito aprovado (CP221)

- Decisão expressa `OES / D1-T2-A1 / SYNTHETIC_IN_MEMORY_TECHNICAL_CLOSURE`, registrada no Documento 196: **T2-A1 = CLOSED_SYNTHETIC_IN_MEMORY_ONLY**.
- Cinco comandos sintéticos integrados em Python/memória, evidência local histórica de 39 testes T2-A1 e 36 testes T1 PASS; não reexecutados nesta atualização.
- T1 preservado e encerrado restritamente; diferenças de exceções, semânticas de criação e `pending`, limitações científicas e todos os gates mantidos.
- **T2-A2 NOT_AUTHORIZED**. Sem SQL, PostgreSQL, Neon, CI remota, cloud, implantação, API pública, dados reais, serviços pagos ou promoção científica/operacional. Próximo `Prossiga`: exclusivamente proposta documental para T2-A2.

## 1I. D1-T2/A2 — especificação documental consolidada (CP222)

- Documento 197 consolida A1–A3 e revisão adversarial F01–F05: adaptador PostgreSQL local sintético candidato, três registros lógicos, matriz E01–E12 e testes ainda NÃO EXECUTADOS.
- **T2-A2 = NOT_AUTHORIZED.** Proposta de autorização no documento é apenas minuta; preflight operacional, instalação, driver, SQL, PostgreSQL, Neon, CI, cloud, consultas factuais e custos permanecem sem autorização.
- T1 e T2-A1 encerrados tecnicamente de modo restrito, com evidência histórica 36 e 75 PASS, sem reteste. Gates, migrations, BRGs, papéis e fases inalterados.
- Próximo `Prossiga`: revisão documental final e pacote deliberativo; nenhuma implementação.

## 1J. D1-T2/A2 — preparação local escalonada P1/P2 (CP223)

- Documento 198 consolida autorizações de **P1 e P2-A somente leitura**, pacote P1–P4 e candidatos PostgreSQL 17/Psycopg 3; observações de inventário relatadas na conversa carecem de logs técnicos brutos persistidos, devendo ser revalidadas.
- **P2-C1 NÃO APROVADO**; P2-C2/P3/P4 e T2-A2 igualmente não autorizados. Nenhuma instalação, driver, servidor, SQL, Neon, CI, cloud, fonte factual ou gasto foi executado neste checkpoint documental.
- T1/T2-A1 encerrados de modo restrito, 36/75 testes somente históricos; nenhuma mudança semântica, migração, gate ou fase.
- Próximo `Prossiga`: preparar apenas pacote final de decisão P2-C1 com origem/versões, caminhos, isolamento, rollback e critérios de parada.

## 1K. D1-T2/A2 — decisão de ambiente ainda pendente (CP224)

- Documento 199 consolida três atividades documentais: pacote P2-C1, revisão da persistência em `/mnt/data` e alternativas A persistente versus B temporária.
- **Ambiente de destino não escolhido; P2-C1 não aprovado; T2-A2 NOT_AUTHORIZED.** Nenhuma instalação ou execução PostgreSQL/SQL/Neon/CI/cloud, teste ou despesa nesta formalização.
- Relatos de inventário e persistência local ainda não possuem logs brutos canônicos; revalidar antes de autorização concreta.
- Próximo `Prossiga`: matriz documental de decisão A/B; preservar T1/T2-A1 e todos os gates.

## 1L. D1-T2/A2 — projeto Neon Free sintético provisionado (CP225)

- Documento 200 registra autorização expressa e criação verificada de `oes-d1-t2-a2-synthetic`, ID `tiny-pond-20086371`, Free, região São Paulo, PostgreSQL 18, branch `synthetic-main`, banco `oes_t2a2_synthetic`, separado do `oes-sandbox` histórico.
- **T2-A2 NOT_AUTHORIZED**: nenhum SQL, DDL, tabela, dados sintéticos, adaptador, testes, CI ou migrations canônicas. Conexões públicas não bloqueadas, branch não protegida e suspensão `0` exigem parecer de segurança/custo antes do uso.
- T1/T2-A1 e bloqueios científicos/operacionais preservados. Próximo `Prossiga`: análise documental de riscos e minuta específica de autorização para uso seguro do novo projeto Neon.

## 1M. CP226 — N1/N1-B Neon

Identidade `oes_t2a2_runtime` criada com autorização específica; nenhuma concessão, SQL ou conexão; T2-A2 NOT_AUTHORIZED. Documento 201.

## 1N. CP227 — segurança Neon N1-C/N1-D1

Documento 202: consultas SQL somente leitura autorizadas identificaram CREATE, CREATEDB, CREATEROLE e membership em neon_superuser no papel experimental. `pg_stat_ssl` false não prova segurança ou insegurança do transporte externo. Correção N1-D2 não autorizada. T2-A2 NOT_AUTHORIZED.

## 1O. CP228 — N1-D3 Neon

N1-D3 autorizado e executado: papel `oes_t2a2_app` criado com atributos mínimos verificados. N1-D2 não concluído, N1-E e T2-A2 não autorizados. Documento 203.

## 2. Estado das fases

- Fase 0 — Concepção e fundamentos: base inicial consolidada;
- Fase 1 — Manual Metodológico: base inicial dos Documentos 10–15 consolidada;
- Fase 2 — Modelo de Dados da Evidência: **concluída no nível de baseline arquitetural**;
- Fase 3 — Produtos do Observatório: **concluída**;
- Fase 4 — Protocolo de Atualização: **em desenvolvimento**;
- Fases 5–7: ainda não iniciadas formalmente.

## 3. Arquitetura

### OES-H1

**Arquitetura de referência.**

Núcleo relacional canônico + estruturas documentais controladas + object storage + projeções derivadas.

### OES-P1

**Baseline arquitetural da Fase 2.**

Foi promovido após:

- GATE F2-A PASS;
- GATE F2-B PASS;
- PoC-S4 PASS;
- PoC-S5 PASS;
- 15/15 critérios de promoção validados.

### PostgreSQL

**Implementação de referência validada para desenvolvimento/PoC.**

Não constitui escolha definitiva de stack de produção.

## 4. Evidência técnica principal

### F2-B

- run 37187885839;
- T01–T19 PASS.

### PoC-S4

- run 37188934837;
- S4-T01–T15 PASS.

### PoC-S5

- run 37189646452;
- regressão F2-B PASS;
- regressão S4 PASS;
- S5-T01–T17 PASS;
- artifact 11297653844;
- digest `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`.

## 5. Matriz de promoção do Documento 25

> **15 VALIDADO / 0 PARCIAL / 0 NÃO VALIDADO**

## 6. Decisão de fechamento da Fase 2

Documento:

`docs/architecture/38-decisao-promocao-fechamento-fase2.md`

Decisão:

- OES-P1 promovido a baseline arquitetural;
- Fase 2 concluída;
- schema de produção não congelado;
- stack de produção não escolhida;
- evolução futura deve ocorrer por migrations controladas.

## 7. Reservas metodológicas/operacionais

Ainda não finalizados:

- templates individuais dos produtos;
- ApplicabilityAssessment operacional;
- protocolo de atualização/monitoramento;
- automação e IA;
- infraestrutura de produção;
- autenticação/autorização;
- backup/HA.

## 8. Fase 3 — estado atual

Documento 04 — **Governança de Garantia Metodológica, Aprovação e Revisão**: vigente como regra transversal A0–A3.

Documento 40 — **Taxonomia e Arquitetura dos Produtos do OES**: consolidado.

### Ficha de Evidência — N2

Documentos 41–67: trilha inicial especificada, implementada e validada ponta a ponta.

Estado do Caso Real 01:

- Product `OES-P-2026-000401`;
- assurance **A2**;
- `publication_date=2026-10-04`;
- `published`;
- `publishable=true`;
- expert independent review não realizada;
- run final **37229070210** = PASS.

### Resposta de Evidência — N1

Documentos 68–85: trilha inicial especificada, implementada e validada ponta a ponta.

Estado do Caso Real N1-01:

- Product `OES-P-2026-000501`;
- ProductVersion atual = 2;
- assurance **A2**;
- `publication_date=2026-10-05`;
- `published`;
- `publishable=true`;
- expert independent review ausente;
- primeira verificação adversarial = REVISE;
- segunda verificação = PASSED;
- run final **37362554094** = PASS.

### Evidence Scan — N0

Documentos 86–98: trilha inicial especificada, implementada e validada ponta a ponta.

Arquitetura/contrato:

- migration 013;
- EvidenceScanView `oes.evidence_scan_view/0.1`;
- publication gate N0;
- template Markdown próprio;
- presentation map;
- renderer/validator;
- nenhuma nova tabela/coluna;
- Synthesis/Certainty/RiskAssessment não obrigatórios;
- scan formal persistente exige A2;
- scan interno pode encerrar em A1.

Validação técnica do contrato/template:

- ES-T01–T15 PASS;
- F3-ES-TEMPLATE PASS;
- migration 013 idempotente;
- rebuild through migration 013 PASS.

Caso Real N0-01 — GenAI/LLMs e apoio à saúde mental:

- Question `OES-Q-2026-000601`;
- Investigation `OES-I-2026-000601`;
- Product `OES-P-2026-000601`;
- ProductVersion 1;
- depth `N0`;
- maintenance `M0`;
- maturity `partially_synthesized`;
- seis fontes centrais;
- duas buscas exploratórias;
- três controvérsias;
- três gaps aparentes;
- três candidate questions;
- routing `N2`;
- `requires_question_reformulation=true`;
- AI methodological verification = `passed`;
- owner governance approval = ausente;
- expert independent review = ausente;
- assurance final = **A1**;
- editorial status = `under_review`;
- publication_date = NULL;
- publishable = `false`;
- uso = artefato interno de roteamento.

Validação final do caso real N0:

- run **37382201584** = **success**;
- commit validado `eb503c571557b5b7078b6f148e9ca9c0651da2a4`;
- artifact **11374937122**;
- digest `sha256:be56277103192065dedf555423191d3d2f8fca149f7f568a6c8f54c0b67b8b18`;
- RN0-T01–T13 PASS;
- RN0-A1-T01–T08 PASS;
- RN0-TEMPLATE-A0 PASS;
- RN0-TEMPLATE-A1 PASS;
- rebuild A1 PASS.

Produtos com trilha inicial consolidada:

1. **Ficha de Evidência — N2** — caso real A2/published;
2. **Resposta de Evidência — N1** — caso real A2/published;
3. **Evidence Scan — N0** — caso real A1/interno, não publicado.

### Síntese Rápida de Evidências — N3

Documentos 99–114:

- 99 — especificação científica e funcional;
- 100 — revisão de coerência e decisão arquitetural;
- 101 — contrato de dados;
- 102 — resultado da validação técnica: **PASS**;
- 103 — contrato de renderização;
- 104 — especificação do template operacional;
- 105 — resultado da validação do template: **PASS**;
- 106–110 — Caso Real N3-01: protocolo, busca/seleção, appraisal, síntese/GRADE/SoF e validação técnica A0;
- 111 — primeira verificação adversarial: **REVISE**;
- 112 — busca suplementar corretiva;
- 113 — segunda verificação adversarial: **REVISE**;
- 114 — encerramento experimental controlado.

Implementação validada:

- migration 014;
- `investigation.method_decision`;
- `investigation.quality_control_record`;
- RapidEvidenceSynthesisView `oes.rapid_evidence_synthesis_view/0.1`;
- publication gate N3;
- template/presentation map/renderer/validator;
- validator dedicado do Caso Real N3;
- RS-T01–T15 PASS;
- F3-RS-TEMPLATE PASS;
- rebuild through migration 014 PASS.

Governança N3 consolidada:

- N3 formal exige A3;
- A3 não substitui controles humanos qualificados de etapa;
- AI quality controls são transparentes e não satisfazem qualified human controls;
- technical PASS não equivale a methodological PASS;
- adversarial `revise` não eleva assurance;
- busca N3 deve ser sistemática, reproduzível, documentada e proporcionalmente abrangente;
- padrão inicial: pelo menos duas bases bibliográficas relevantes, salvo exceção metodologicamente defensável.

### Caso Real N3-01 — ambient AI scribes

Product:

- `OES-P-2026-000701`;
- ProductVersion 1 = superseded;
- ProductVersion 2 = current;
- depth `N3`;
- maintenance `M1`;
- editorial status `under_review`;
- assurance **A0**;
- `publishable=false`;
- `publication_date=NULL`.

Corpo experimental:

- três estudos randomizados/comparativos principais;
- 11 Results estruturados;
- 10 appraisals;
- quatro SynthesisVersion narrativas;
- GRADE experimental: 3 LOW + 1 VERY LOW;
- seis AI quality controls, todos `qualified=false`.

Primeiro adversarial:

- resultado **REVISE**;
- motivo: cobertura insuficiente/não duplicação após falha do Europe PMC;
- correção: ProductVersion 2 com terminologia ampliada, terceira Search, 20 hits, 34 screening decisions e 13 referências.

Segundo adversarial:

- resultado **REVISE**;
- motivo: arquitetura de busca ainda insuficiente para N3;
- PubMed foi a única base bibliográfica executada de forma reproduzível;
- Europe PMC indisponível via API/interface;
- OpenAlex direto indisponível;
- publisher/DOI/citation chasing não equivale a segunda base bibliográfica;
- nova busca adversarial continuou encontrando estudos elegíveis, tornando a exceção de uma base não defensável.

Estado final:

> **A0 experimental / metodologicamente bloqueado / não publicável.**

Não criar ProductVersion 3 sem segunda base bibliográfica relevante e reproduzível.

Validação técnica final:

- run **37413884319** = **success**;
- commit validado `f2ba21eaaa2d3c43a95ceb908dd0b097b8e9a1b4`;
- artifact **11389784878**;
- digest `sha256:c4b53864e60be656a1e3de9039b8480746bbeff8f9fcf5b76257989a47a73b58`;
- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- regressões e rebuild PASS.

### Revisão de Evidências — N4

Documentos 115–122:

- 115 — especificação científica e funcional;
- 116 — revisão de coerência e decisão arquitetural;
- 117 — contrato de dados;
- 118 — resultado da validação técnica do contrato: **PASS**;
- 119 — contrato de renderização;
- 120 — especificação do template operacional;
- 121 — resultado da validação do template/renderização: **PASS**;
- 122 — Infrastructure Readiness Gate pré-caso real: **NOT_READY**.

Implementação validada:

- migration 015;
- `investigation.reviewer_assignment`;
- extensão de `appraisal.assert_risk_target_type()` para alvo `Synthesis` em ROB-ME;
- EvidenceReviewView `oes.evidence_review_view/0.1`;
- publication gate N4;
- Infrastructure Readiness Gate;
- fixture formal sintética A3;
- template Markdown N4;
- presentation map;
- renderer/validator;
- disclosure `audit.synthetic_fixture`;
- ER4-T01–T27 PASS;
- F3-ER4-TEMPLATE PASS;
- rebuild through migration 015 PASS.

Governança N4 consolidada:

- N4 formal exige A3 + controles humanos qualificados específicos do protocolo;
- A3 não substitui search peer review, dupla seleção, dupla extração, appraisal, certainty ou statistical review;
- IA não satisfaz reviewer assignment humano;
- uma única base bibliográfica não é suficiente para N4 formal;
- protocolo prospectivo e reprodutibilidade são obrigatórios;
- ROB-ME pode ser representado em nível de Synthesis;
- Caso Real N4 formal permanece proibido na configuração humana atual.

Validação técnica final do contrato:

- run **37417796591** = **success**;
- commit validado `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`;
- artifact **11391167525**;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

Validação final do template/renderização:

- run **37418624629** = **success**;
- commit validado `4bd35271e94dfb05bf572fe76b49fa5c5af47bac`;
- artifact **11391724857**;
- digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`;
- F3-ER4-TEMPLATE validation PASS;
- cenário adversarial A3 + `publishable=false` corretamente renderizado como gate bloqueado;
- regressões e rebuild PASS.

Readiness real N4:

- cobertura bibliográfica = `not_ready`;
- equipe metodológica = `not_ready`;
- estatística = `ready_with_documented_conditions`;
- ferramentas/artefatos = `ready`;
- governança/A3 = `not_ready`;
- resultado agregado = **NOT_READY**;
- nenhuma Investigation N4 real foi aberta;
- nenhuma busca definitiva N4 foi iniciada;
- Caso Real N4 permanece deferido até mudança real das condições humanas/infrastruturais.

### Mapa de Evidências

Documentos 123–137:

- 123 — Especificação Científica e Funcional;
- 124 — Revisão de Coerência e Decisão Arquitetural Inicial;
- 125 — Contrato de Dados v0.1;
- 126 — Resultado da Validação Técnica: **PASS**;
- 127 — EvidenceMapView: Contrato de Renderização;
- 128 — Resultado da Validação do Projection Readiness: **READY**;
- 129 — Especificação do Template Operacional;
- 130 — Resultado da Validação do Template/Renderização: **PASS**;
- 131 — Readiness Gate Pré-Caso Real: **exploratório READY_WITH_DOCUMENTED_CONDITIONS / formal NOT_READY**;
- 132 — MAP-01: protocolo pré-especificado;
- 133 — MAP-01: inventário formal de 17 MapItems;
- 134 — MAP-01: codebook v0.1;
- 135 — MAP-01: correção arquitetural — Question/Investigation próprias + N3-01 como `source_corpus`;
- 136 — source_corpus: validação técnica **PASS**;
- 137 — MAP-01: resultado e encerramento controlado — **A1 interno / não publicável**.

Implementação validada:

- migration 016;
- schema `mapping`;
- `framework`, `framework_version`, `dimension`, `category`, `map_item`, `assignment`, `cell_scope`;
- `mapping.evidence_map_cells()` para derivação de células, contagens e gaps;
- publication gate do Mapa;
- EvidenceMapView `oes.evidence_map_view/0.1`;
- fixture formal sintética `evidence_gap_map + systematic_comprehensive + formal_within_scope`;
- dupla classificação humana sintética + consenso;
- qualified search/screening/classification controls sintéticos;
- assurance A3 sintético;
- EM-T01–T22 PASS;
- rebuild through migration 016 PASS;
- regressões N0–N4 PASS.

Validação técnica:

- run **37464023391** = **success**;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`;
- artifact **11413512318**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

Decisões preservadas:

- OES-P1 permanece como núcleo científico;
- células, contagens, concentrações e gaps são derivados;
- gap formal exige coverage e CellScope compatíveis;
- A3 não contorna controles metodológicos de etapa;
- fixture sintética não constitui evidência real;
- nenhum Caso Real do Mapa foi iniciado.

Estado técnico:

> **Contrato de dados e EvidenceMapView = PASS técnico.**

Estado de apresentação:

> **Contrato de renderização definido; Projection Readiness Gate = READY.**

Implementação aditiva validada:

- migration 017;
- EvidenceMapView 0.1 ampliada;
- `product.evidence_map_reference_reports()`;
- synthetic fixture disclosure;
- conclusão;
- protocolo/codebook;
- reviewer assignments;
- method controls;
- lineage/invalidation;
- references via Study–Report linkage;
- EMV-T01–T11 PASS;
- rebuild through migration 017 PASS.

Validação:

- run **37466183355** = success;
- commit validado `0cd132d215bf156dee51c1ce49e3dd2a2c2adde2`;
- artifact **11414726018**;
- digest `sha256:44ee38666b3d502bae5936adb388cdd49660b0f763990eb23b00b2a01bd420c6`.

Camada de apresentação:

- `templates/evidence-map.md`;
- `templates/evidence-map-presentation-map.json`;
- `scripts/render_evidence_map_reference.py`;
- `scripts/validate_evidence_map_render.py`;
- fixture formal PASS;
- cenário A3 + gate bloqueado PASS;
- cenário apparent gap PASS;
- F3-MAP-TEMPLATE PASS;
- rebuild through migration 017 PASS.

Validação final da apresentação:

- run **37467388595** = success;
- commit validado `5b3e7b30d8b0104501fb167e5ab0077fca6119d7`;
- artifact **11415721992**;
- digest `sha256:889f31280259bf1f90439957d12652567d0a3542a465c379623d3810840b7afe`.

Readiness pré-Caso Real:

- rota A — exploratória / structured non-exhaustive = **READY_WITH_DOCUMENTED_CONDITIONS**;
- rota B — systematic map / EGM formal = **NOT_READY**;
- candidato autorizado: MAP-01 — ambient AI scribes, reutilizando o corpus N3-01;
- MAP-01 deve ser novo Product interno A1;
- subtype `descriptive_mapping_review`;
- coverage `structured_non_exhaustive`;
- gaps `apparent_only`;
- sem novos ReviewerAssignments humanos;
- sem alteração do N3-01.

Pré-persistência MAP-01:

- protocolo concluído;
- 5 StudyVersions elegíveis;
- 8 ReportVersions contextuais elegíveis;
- 4 SynthesisVersions elegíveis;
- total = 17 MapItems;
- 20 CellScope previstos;
- codebook v0.1 fechado;
- `descriptive_mapping_review`;
- `structured_non_exhaustive`;
- `apparent_only`;
- counting unit = `study`;
- decisão anterior de reutilizar N3-01 como primary Investigation foi superada pelo Documento 135;
- MAP-01 terá Question/Investigation próprias;
- N3-01 será ligada ao Product com role `source_corpus`;
- Search/Screening canônicos permanecerão na N3-01 e serão herdados pela EvidenceMapView sem duplicação.

Source-corpus support:

- migration 018 = PASS;
- EvidenceMapView preserva pergunta da primary MAP Investigation;
- Searches/Screening podem ser herdados via `source_corpus` em mapas não sistemáticos;
- systematic/formal map continua exigindo Search na primary Investigation;
- EMVSC-T01–T05 PASS;
- rebuild through migration 018 PASS;
- run **37479566944** = success;
- artifact **11420063123**;
- digest `sha256:c7dc99be7781200e0ad603b0d03f9e90e3022ed7eafabd32be5138f41c29024b`.

MAP-01 real:

- Product `OES-P-2026-001401`;
- 17 MapItems;
- 67 assignments finais IA/unverified;
- 20 CellScope;
- 13 referências;
- 3 Searches + 20 SearchHits + 34 ScreeningDecisions herdados via `source_corpus`;
- MAP01-T01–T15 PASS;
- AI methodological second pass = passed;
- assurance final = **A1**;
- owner approval ausente;
- expert review ausente;
- `publishable=false`;
- MAP01-A1-T01–T07 PASS;
- MAP01-RENDER-A1 PASS;
- run **37487017809** = success;
- artifact **11423951911**;
- digest `sha256:ae81f09905853a395b0bf4ba03e5209938d1cb7e6175390531d117e49f0a46e8`;
- rebuild through migration 018 + MAP-01 A1 PASS;
- N3-01 permaneceu inalterado em A0.

Estado final:

> **MAP-01 concluído — A1 interno / não publicável.**

Próxima etapa naquele marco histórico:

> **iniciar a Especificação Científica e Funcional do Overview de Revisões.**

Essa etapa foi posteriormente concluída nos Documentos 138–140; o ponto vigente de retomada é o registrado no CP51.

Produtos exercitados até aqui:

1. **Ficha de Evidência — N2** — caso real A2/published;
2. **Resposta de Evidência — N1** — caso real A2/published;
3. **Evidence Scan — N0** — caso real A1/interno;
4. **Síntese Rápida N3** — contrato/template validados; caso real experimental corretamente bloqueado em A0;
5. **Revisão de Evidências N4** — especificação, contrato, gate, view e template validados com fixture formal sintética A3; readiness real = **NOT_READY**, sem abertura de Caso Real formal.

Taxonomia restante da Fase 3:

- Overview de Revisões;
- Monitor de Evidências;
- Alerta de Evidência.


### Overview de Revisões

Documentos **138–164**: trilha inicial especificada, implementada, exercitada em caso real developmental e encerrada de forma controlada.

Arquitetura/contrato:

- unidade principal = systematic review;
- migration 019 = PASS;
- migration 020 = PASS;
- `OverviewOfReviewsView` = PASS;
- OV-T01–T33 = PASS;
- OVR-T01–T12 = PASS;
- template/presentation map/renderer/validator = PASS;
- rota developmental interna A0/A1 = suportada;
- rota formal publicável exige Investigation N4 + A3 + qualified human controls.

Caso Real OVR-01 — dCBT-I:

- Product = `OES-P-2026-001601`;
- rota = developmental interna;
- ReviewItems = Hwang 2025 + Gao 2026 + Nazari 2025;
- memberships = **27 / 15 / 44**;
- occurrences = **86**;
- unique primary Study candidates = **59**;
- pairwise overlap derivado pelo banco = **6 / 17 / 9**;
- CCA permanece exclusivamente derivado por `overview.overlap_metrics`;
- Gao mantém `last_search_date=NULL` e `currentness_status='unclear'`, sem inferência;
- comparadores permanecem separados;
- nenhuma nova meta-analysis OES foi criada;
- certainty review-level não foi inventada;
- ROBIS e memberships permanecem AI-assisted/unverified.

Trilha adversarial:

- Documento 162 = primeira passagem adversarial, decisão **REVISE**;
- achados: Search execution não sustentada, regra retrospectiva `minimum_bibliographic_sources=2` e drift da Question;
- achados corrigidos e protegidos por OVR01-T15–T16;
- Documento 163 = segunda passagem adversarial, decisão **PASS**;
- Documento 164 = encerramento controlado da trilha developmental.

Estado final:

- assurance = **A1**;
- `ai_methodological_verification=passed`;
- editorial status = `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- owner approval = ausente;
- expert independent review = ausente;
- human verification = ausente;
- rota formal = **NOT_READY**.

Validação final:

- OVR01-T01–T16 = **PASS**;
- OVR01-A1-T01–T09 = **PASS**;
- OVR01-RENDER-A1 = **PASS**;
- regressões integradas = **PASS**;
- rebuild-from-zero = **PASS**;
- run **37549135468** (#117) = **success**;
- HEAD validado = `ecc04933dd5ba116345dc4dcf8d352a646b6aed7`;
- artifact **11452420926**;
- digest `sha256:4dff568129b92a6a4565c33c015afbbe7bec2cc872333b4f99b2701b9c9151a6`.

Publication blockers formais permanecem, incluindo:

- `MISSING_LAST_SEARCH_DATE`;
- `MISSING_OWNER_APPROVAL`;
- `MISSING_EXPERT_INDEPENDENT_REVIEW`;
- `ASSURANCE_BELOW_REQUIRED_LEVEL`;
- `UNVERIFIED_REVIEW_APPRAISAL`;
- `UNVERIFIED_MEMBERSHIP`;
- `MISSING_OVERLAP_CONTROL`;
- `UNVERIFIED_OUTCOME_EVIDENCE`.

Marco:

> **OVR-01 = DEVELOPMENTAL_A1_INTERNAL_VALIDATED — concluído / não publicável.**

## 9. Monitor de Evidências — estado atual

Documentos:

- 165 — Especificação Científica e Funcional;
- 166 — revisão de coerência científica/arquitetural = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- 167 — Contrato de Dados v0.1 = **READY_FOR_IMPLEMENTATION**;
- 168 — Resultado da Validação Técnica = **PASS**.

Arquitetura consolidada:

> **Monitor = Product próprio + Investigation própria de manutenção que herda N do alvo + camada especializada `maintenance`, reutilizando Search/SearchHit, currency_state, version_change_class e provenance existentes.**

Implementação:

- migration `database/021_evidence_monitor_contract.sql`;
- schema `maintenance`;
- estruturas:
  - `monitor_definition`;
  - `monitor_target`;
  - `monitor_state`;
  - `monitor_cycle`;
  - `cycle_search`;
  - `evidence_event`;
  - `candidate_assessment`;
  - `cycle_currency_state`;
- fixture M2 formal/A2;
- fixture M3 estruturalmente completa e formalmente bloqueada até Fase 4;
- MON-T01–T32 = **PASS**;
- MON-T33 migration 021 idempotent re-apply = **PASS**;
- rebuild-from-zero through migration 021 = **PASS**.

Semântica preservada:

- Monitor não é N5;
- M2/M3 permanecem dimensão de manutenção;
- Search do Monitor não contamina a Investigation científica histórica;
- ciclo rotineiro não cria ProductVersion científica;
- baseline cutoff da Monitor ProductVersion é estático;
- cutoffs posteriores pertencem aos ciclos;
- Monitor Product currency e target scientific currency são distintos;
- decisão de cycle pode gerar novo `product.currency_state` sem nova ProductVersion;
- target conclusion não é alterada silenciosamente;
- assurance do target não é herdada;
- Monitor M2 formal v0.1 exige mínimo A2;
- expert independent review ausente é warning em M2 v0.1;
- M3 formal permanece bloqueado por `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`;
- Alert completo e thresholds transversais permanecem fora desta etapa/Fase 4.

Validação final:

- workflow **OES PoC-S5 PostgreSQL Validation**;
- run **37553271462** (#122);
- HEAD validado `d7ca356c8cc4d58552a9e52868fce92f27eaad9e`;
- conclusão = **success**;
- artifact **11453871816**;
- digest `sha256:71dd0b68c92ce3d30832862545ac45efbfb94cba51580d77f2673f12a94fbaf8`.

Readiness:

- scientific/functional = PASS;
- architecture = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data contract = PASS;
- migration/fixtures/tests/rebuild = PASS;
- **Projection Readiness = NOT_READY** — Documento 169;
- template readiness = NOT_EVALUATED.

## 10. Próxima etapa da Fase 3

> **Implementar hardening de Projection Readiness do Monitor na migration 022.**

Documento 169 identificou cinco blockers materiais antes de uma EvidenceMonitorView segura:

1. cardinalidade múltipla de impactos não normalizada;
2. source policy parcialmente interpretada;
3. exceções de cobertura via MethodDecision não integradas;
4. semântica temporal cycle/Search incompleta, incluindo drift dinâmico de Search;
5. vínculo Cycle → CurrencyState ainda regravável.

A migration 022 fica reservada ao hardening desses pontos. A EvidenceMonitorView passa a ser candidata para migration 023, somente após novo Projection Readiness Gate = READY.

Nenhum template deverá ser criado enquanto o gate permanecer NOT_READY.

## 11. Checkpoint de continuidade

O checkpoint vigente é **CP88 — 2026-10-06**.

Ponto exato de retomada:

> **Especificar e implementar o hardening de Projection Readiness na migration 022, antes de qualquer EvidenceMonitorView.**


### Monitor de Evidências — Projection Readiness hardening

Documento 170 — **PROJECTION_HARDENING_SPEC_READY**.

Decisões:

- migration 022 = hardening semântico, não View;
- adicionar `maintenance.candidate_impact` para cardinalidade 1:N de impactos;
- adicionar `maintenance.monitor_source_requirement` como fonte machine-readable de requisitos;
- `candidate_assessment.impact_class` permanece como primary impact summary legado;
- SourceRequirement integra exceções via `investigation.method_decision`;
- source coverage deverá distinguir `fulfilled` de `exception_applied`;
- temporal consistency será derivada por helper específico;
- Search drift será revalidado dinamicamente;
- todos os cycles completed serão considerados no hardening gate;
- `cycle_currency_state` será imutável;
- `product.evidence_monitor_is_publishable()` passará a exigir também ausência de hardening errors;
- EvidenceMonitorView permanece candidata à migration 023 após novo Projection Readiness Gate.

Próxima etapa:

> **Implementar migration 022 + atualizar fixture + MONH-T01–T24 + regressões/rebuild.**


### Monitor de Evidências — hardening técnico

Documento 171 — **EVIDENCE_MONITOR_PROJECTION_HARDENING = TECHNICALLY_VALIDATED**.

Implementação:

- migration `database/022_evidence_monitor_projection_hardening.sql`;
- `maintenance.candidate_impact`;
- `maintenance.monitor_source_requirement`;
- source requirement status com `fulfilled` / `exception_applied` / `satisfied`;
- exceções reutilizando `investigation.method_decision`;
- temporal/Search hardening dinâmico;
- avaliação de todos os completed cycles;
- `cycle_currency_state` imutável;
- `product.evidence_monitor_projection_hardening_issues(...)`;
- publishability endurecida.

Validação:

- MON-T01–T32 = PASS;
- MONH-T01–T22 = PASS;
- MON-T33 = PASS — chain 021→022 re-apply;
- MONH-T23 = PASS — migration 022 re-apply;
- MONH-T24 = PASS — rebuild-through-022;
- run final **37555588465** (#125) = **success**;
- HEAD validado `a66ea298b30ffacda10ce16fe2bc0974362b87fe`;
- artifact **11453649661**;
- digest `sha256:002f0a0fdde28bb20bdba9e86263b275bd140d2aec2ae1e67e69f74579089bf6`.

Projection Readiness permanece formalmente:

> **NOT_READY até novo gate explícito.**

Próxima etapa:

> **Reexecutar adversarialmente PR-MON-01–05 e decidir READY/NOT_READY antes da EvidenceMonitorView.**


### Monitor de Evidências — Projection Readiness Gate 02

Documento 172 — **EVIDENCE_MONITOR_PROJECTION_READINESS = READY**.

Resultado adversarial:

- PR-MON-01 múltiplos impactos = RESOLVED;
- PR-MON-02 source policy machine-readable = RESOLVED;
- PR-MON-03 source exceptions via MethodDecision = RESOLVED;
- PR-MON-04 temporal/Search drift = RESOLVED;
- PR-MON-05 Cycle→CurrencyState imutável = RESOLVED.

Correção pós-CP79:

- temporal/gap exceptions agora exigem `stage='search'`;
- decisão accepted em estágio incorreto não satisfaz a exceção;
- run final pós-correção **37555981343** (#127) = **success**;
- HEAD validado `06ea4b203b3d2d3a1425f7f4c7fe3c4a1d764aed`;
- artifact **11454409428**;
- digest `sha256:c2cc76b684d1e89f5a4ae4aadf8067d6c1a659b62384242f7ebc9a48cb69e4ad`.

Autorizado:

> `database/023_evidence_monitor_view_rendering_readiness.sql`

Próxima etapa:

> **Implementar EvidenceMonitorView 0.1 + testes de projeção + idempotência + rebuild.**

Template readiness permanece NOT_EVALUATED. Caso Real, Alert e Fase 4 continuam não autorizados.


### Monitor de Evidências — EvidenceMonitorView 0.1

Documento 173 — **EVIDENCE_MONITOR_VIEW_0_1 = PASS**.

Implementação:

- migration `database/023_evidence_monitor_view_rendering_readiness.sql`;
- schema de projeção `oes.evidence_monitor_view/0.1`;
- `product.evidence_monitor_target_projection(...)`;
- `maintenance.monitor_cycle_projection(...)`;
- `product.evidence_monitor_view(...)`;
- funções read-only / STABLE;
- nenhuma Search, CurrencyState, ProductVersion ou Alert é criada pela View.

Semântica de projeção validada:

- target ProductVersion e InvestigationVersion permanecem explicitamente distintos;
- Monitor editorial status, operational status, Monitor currency e target currency permanecem quatro dimensões separadas;
- baseline cutoff permanece separado do latest completed cycle cutoff;
- Searches/SearchHits vêm dos registros canônicos;
- source requirements projetam `fulfilled`, `exception_applied` e `satisfied` separadamente;
- CandidateAssessments preservam múltiplos `CandidateImpact`;
- EvidenceEvent permanece distinto de CandidateAssessment;
- histórico Cycle→CurrencyState preserva estados superseded/active;
- Monitor assurance e target assurance não são colapsados;
- AI verification não é apresentada como human verification;
- blocker M3/Fase 4 permanece explícito.

Validação:

- MONV-T01–T17 = **PASS**;
- MONV-T18 migration 023 idempotent re-apply = **PASS**;
- MONV-T19 rebuild-through-023 = **PASS**;
- workflow **OES PoC-S5 PostgreSQL Validation**;
- run **37556593132** (#128) = **success**;
- HEAD validado `613a9ced4ad43a3eb890a2b5db35acf51a08127e`;
- artifact **11454488440**;
- digest `sha256:6043e52ac33800ec5d944b1a4633bfe5049a9c8ecff2613eb577aadea2916630`.

Readiness atual:

- scientific/functional = PASS;
- architecture = PASS;
- data contract = PASS;
- projection hardening = PASS;
- Projection Readiness = READY;
- EvidenceMonitorView 0.1 = PASS;
- **template/presentation = NOT_YET_SPECIFIED**;
- Caso Real do Monitor = NOT_AUTHORIZED;
- Alert = NOT_IMPLEMENTED;
- Fase 4 = NOT_STARTED.

Próxima etapa:

> **Definir o contrato de renderização e a Especificação do Template Operacional do Monitor de Evidências.**

A camada de apresentação deverá consumir exclusivamente a `EvidenceMonitorView` e preservar explicitamente Monitor × target × currentness × cycles × assurance × exceptions.


### Monitor de Evidências — camada de apresentação concluída

Documentos 174–176 concluídos.

Estado:

> **MONITOR_DE_EVIDENCIAS = FORMALIZED_IN_PHASE_3**

Apresentação:

- `templates/evidence-monitor.md`;
- `templates/evidence-monitor-presentation-map.json`;
- `scripts/render_evidence_monitor_reference.py`;
- `scripts/validate_evidence_monitor_render.py`.

Validação final:

- run **37558043092** (#130) = **success**;
- HEAD validado `40762d00f874599716fcbb86271bea4084ca19ef`;
- artifact **11455658237**;
- digest `sha256:6d80f9f80622713717d373d99ea200481f8926c295587e223a15a2f179bde0e3`.

Run #129 falhou apenas porque o template acessava resulting target currency em target InvestigationVersion; correção tornou esse bloco condicional sem alterar contrato científico/View.

Caso Real do Monitor não é requisito para a formalização taxonômica da Fase 3.

Próxima etapa:

> **Especificação Científica e Funcional do Alerta de Evidência — último produto da taxonomia da Fase 3.**

Fase 4 permanece explicitamente não iniciada.


### Alerta de Evidência — especificação científica e decisão arquitetural

Documentos 177–178 concluídos.

Estado:

> **EVIDENCE_ALERT_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

Decisões principais:

- Alert formal = Product/ProductVersion com `product_type='evidence_alert'`;
- **não cria Investigation nova**;
- exatamente um `product.investigation_link(role='source_context')`;
- target especializado = exatamente um ProductVersion ou InvestigationVersion;
- `maintenance.evidence_alert` 1:1 com Alert ProductVersion;
- `maintenance.alert_source` 1:N, exatamente uma primary source;
- `maintenance.alert_affected_dimension` 1:N;
- classification `informational|relevant|critical` é persistida, não calculada;
- reassessment priority `routine|priority|urgent` é qualitativa, sem SLA;
- lifecycle `triage|evaluation|incorporated|discarded` é versionado;
- incorporated exige linkage rastreável;
- discarded exige rationale;
- Alerta não cria `product.currency_state` próprio;
- `conclusion_text` do Alert ProductVersion permanece NULL;
- assurance reutiliza A0–A3;
- publicação formal v0.1 exige A2 + human verification explícita do Alerta;
- target assurance/currentness permanecem separados;
- critical não gera A3 obrigatório, prazo ou auto-update na Fase 3;
- Fase 4 permanece não iniciada.

Próxima etapa:

> **Contrato de Dados v0.1 do Alerta de Evidência; depois migration 024 + fixtures + testes.**


### Alerta de Evidência — Contrato de Dados v0.1

Documento 179 concluído.

Estado:

> **EVIDENCE_ALERT_DATA_CONTRACT = READY**

Migration autorizada:

> `database/024_evidence_alert_contract.sql`

Escopo 024:

- `maintenance.evidence_alert`;
- `maintenance.alert_source`;
- `maintenance.alert_affected_dimension`;
- integrity/versioning guards;
- publication issues;
- publishability helper;
- fixtures/tests.

EvidenceAlertView permanece posterior a Projection Readiness explícito.

Fase 4 permanece não iniciada.


### Alerta de Evidência — contrato técnico PASS / Projection Readiness NOT_READY

Documento 180 — **EVIDENCE_ALERT_CONTRACT_0_1 = TECHNICALLY_VALIDATED**.

Validação:
- run **37559879675** (#132) = success;
- HEAD validado `180b11324ed19dbf51aa8a902dec4c51f6587025`;
- AL-T01–T29 = PASS;
- AL-T30 = PASS;
- rebuild-through-024 = PASS;
- artifact **11456436623**;
- digest `sha256:28974dd66cf678abd3ae3f154e8853894489379bc1293c84ae70980d3fc7886d`.

Documento 181 — **EVIDENCE_ALERT_PROJECTION_READINESS = NOT_READY**.

Blockers:
1. AlertSource ainda aceita INSERT pós-publicação;
2. affected dimensions ainda aceitam INSERT pós-publicação;
3. supporting sources não são todas revalidadas dinamicamente;
4. EntityVersion AlertSource não exige `maintenance_alert_source` dependency;
5. source_context deverá ser selado após publicação.

Próxima etapa:
> **migration 025 de projection hardening + ALT-H tests, antes de qualquer EvidenceAlertView.**

Fase 4 permanece não iniciada.


### Alerta de Evidência — Projection Readiness READY

Documentos 182–183 concluídos.

Estado:

> **EVIDENCE_ALERT_PROJECTION_HARDENING = TECHNICALLY_VALIDATED**

> **EVIDENCE_ALERT_PROJECTION_READINESS = READY**

Hardening 025:
- sealing pós-publicação de AlertSource/dimensions/source_context;
- ProductVersion publicado history-preserving;
- all-source dynamic validation;
- EntityVersion source lineage obrigatório;
- hardening issues integrados à publishability.

Validação:
- run **37560513048** (#135) = success;
- HEAD validado `bb1cd11c1882583b001597044dda94ac34b966af`;
- ALT-H01–H13 = PASS;
- rebuild-through-025 = PASS;
- artifact **11456149431**;
- digest `sha256:1606e2b0379910b9100a285fba0dd62d250d07bec70aaa1374d45c797e30fb3b`.

Autorizado:
> `database/026_evidence_alert_view_rendering_readiness.sql`

Fase 4 permanece não iniciada.


### Alerta de Evidência — EvidenceAlertView 0.1

Documento 184 concluído.

Estado:

> **EVIDENCE_ALERT_VIEW_0_1 = PASS**

Validação final:

- migration 026 = PASS;
- EAV-T01–T15 = PASS;
- EAV-T16 idempotent re-apply = PASS;
- EAV-T17 rebuild-through-026 = PASS;
- run **37560891043** (#138) = success;
- HEAD validado `7e41436bb02b47b039356c9ec51aa5d3708a2615`;
- artifact **11456283842**;
- digest `sha256:9513fab7aa3209c8fc4cc008f7b26b687b31d167cbd51ed68a60bae6289740d6`.

Próxima etapa:

> **Contrato de renderização + Template Operacional do Alerta de Evidência.**

Fase 4 permanece não iniciada.


### Alerta de Evidência — camada de apresentação concluída

Documentos 185–187 concluídos.

Estado:

> **ALERTA_DE_EVIDENCIA = FORMALIZED_IN_PHASE_3**

Apresentação:

- `templates/evidence-alert.md`;
- `templates/evidence-alert-presentation-map.json`;
- `scripts/render_evidence_alert_reference.py`;
- `scripts/validate_evidence_alert_render.py`.

Validação final:

- run **37561515491** (#141) = **success**;
- HEAD validado `7d525fc978ee623f17a981b9bf42cdf18686c51e`;
- artifact **11456897850**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`;
- presentation = PASS;
- migration 024/025/026 re-apply = PASS;
- rebuild-through-026 = PASS;
- regressões globais = PASS.

Runs #139 e #140 falharam exclusivamente por defeitos de template/validator e foram corrigidos sem alteração do contrato científico ou da View.

### Fase 3 — Gate de Encerramento

Documento 188 — **PASS**.

Estado consolidado:

> **PHASE_3_PRODUCTS = COMPLETE**

> **PROJECT_STATE = PHASE_3_COMPLETE / PHASE_4_NOT_STARTED**

Taxonomia:

1. Evidence Scan — formalizado;
2. Resposta de Evidência — formalizada;
3. Ficha de Evidência — formalizada;
4. Síntese Rápida de Evidências — formalizada;
5. Revisão de Evidências — formalizada;
6. Mapa de Evidências — formalizado;
7. Overview de Revisões — formalizado;
8. Monitor de Evidências — formalizado;
9. Alerta de Evidência — formalizado.

Critério do encerramento:

- arquitetura/contratos/gates/projeções/apresentação de referência concluídos para os nove produtos;
- rebuild e regressões globais verdes;
- blockers específicos de rotas/casos reais continuam preservados;
- encerramento não implica readiness de produção;
- encerramento não implica A3 universal;
- encerramento não torna M3 operacional.

Fronteira obrigatória:

> **Fase 4 não foi iniciada e não deve ser iniciada sem consentimento explícito do usuário, em nova conversa.**

### Fase 4 — início formal e baseline conceitual do Protocolo de Atualização

Autorização explícita do usuário recebida em nova conversa após Freshness Gate completo.

Documentos:

- Documento 05 — `docs/governance/05-protocolo-transversal-atualizacao.md`;
- Documento 06 — `docs/governance/06-revisao-adversarial-protocolo-atualizacao.md`.

Estado:

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

Decisões consolidadas:

- versão científica, currentness, manutenção e estado operacional/comunicacional permanecem distintos;
- ProductVersion recebe CurrencyState; InvestigationVersion não recebe CurrencyState artificial;
- signal operacional é distinto de signal científico/currentness;
- cadence vencida/ciclo incompleto não altera currentness automaticamente;
- atualização científica material exige versionamento history-preserving do alvo apropriado;
- Alert não é atualização científica;
- Monitor não é síntese;
- propagação abre impact assessment, sem reescrever dependentes;
- M3 permanece ortogonal a N0–N4;
- automação autoritativa permanece não autorizada sem gate específico.

M3:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece ativo.**

Documento metodológico não remove o blocker técnico. Desbloqueio exigirá contrato físico, migration, testes, idempotência, rebuild, regressões e gate explícito.

Estado técnico:

- nenhuma migration/View/template/workflow alterada na abertura da Fase 4;
- última validação técnica continua sendo S5 run **37561515491** (#141) = success;
- HEAD técnico validado `7d525fc978ee623f17a981b9bf42cdf18686c51e`;
- artifact **11456897850**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`.

Readiness:

- conceptual update protocol = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data contract = NOT_YET_SPECIFIED;
- migration de Fase 4 = NOT_AUTHORIZED;
- thresholds numéricos = NOT_DEFINED;
- SLAs numéricos = NOT_DEFINED;
- M3 formal operacional = BLOCKED.

Próximo passo exato:

> **Especificar o Contrato de Dados v0.1 do Protocolo Transversal de Atualização, começando por maintenance policy/version, update signal, materiality assessment e update decision; antes de qualquer migration, executar gate de coerência física.**

### CP89

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP89.md`;
- ponteiro de continuidade movido para CP89;
- Fase 4 formalmente iniciada;
- Documentos 05–06 consolidados;
- retomada movida para Contrato de Dados v0.1;
- M3 formal continua bloqueado.

### Fase 4 — Contrato Transversal de Atualização v0.1 tecnicamente validado

Documentos:

- Documento 07 — Contrato de Dados v0.1;
- Documento 08 — Gate de Coerência Física = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- Documento 09 — Resultado da Validação Técnica = **PASS**.

Implementação:

- migration `027_transversal_update_protocol_contract.sql`;
- fixtures `f4-update-protocol-fixtures.sql`;
- testes `f4-update-protocol-tests.sql`;
- sete estruturas aditivas no schema `maintenance`;
- nenhuma tabela científica existente alterada por `ALTER TABLE`.

Validação:

- F4-UP-T01–T63 = **PASS**;
- F4-UP-IDEM = **PASS**;
- rebuild-through-027 = **PASS**;
- regressões F2-B/S4/S5 = **PASS**;
- regressões Monitor/Alert e demais produtos F3 = **PASS**.

Evidência canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37570978847** = **success**;
- HEAD técnico validado `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- artifact **11460960487**;
- digest `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

Estado:

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_027 = PASS**

M3:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece ativo.**

A existência de UpdatePolicy M3 foi validada sem desbloquear publicação formal de Monitor M3.

Não definidos/autorizados neste marco:

- thresholds quantitativos;
- SLAs numéricos;
- score global de prioridade;
- scheduler;
- notifications;
- auto-classification;
- auto-escalation;
- propagation automática;
- Monitor re-baselining;
- M3 readiness;
- auto-publication;
- auto-update científico.

Próximo passo exato:

> **Definir a arquitetura transversal de perfis de risco operacional/científico que parametrizará cadence, thresholds, SLAs e prioridade, sem ainda fixar números universais.**

### CP90

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP90.md`;
- ponteiro de continuidade movido para CP90;
- contrato físico v0.1 da Fase 4 tecnicamente validado;
- migration 027 = PASS;
- retomada movida para perfis de risco operacional/científico.

### Fase 4 — Perfis de risco e política temporal consolidados

Documentos:

- 16 — Perfis de Risco Operacional e Científico para Atualização;
- 17 — Revisão Adversarial dos Perfis de Risco;
- 18 — Política Transversal de Cadence e Thresholds Temporais;
- 19 — Revisão Adversarial da Política Temporal.

Estado:

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

Decisões consolidadas:

- risco científico/decisório e capacidade operacional permanecem separados;
- score agregado aditivo não é autorizado;
- taxonomia paralela R0–R3 foi rejeitada;
- recomendação de manutenção usa M0–M3 sem ativação automática;
- cadence, cobertura, processamento, reassessment de policy/profile e duração da atualização científica permanecem semanticamente separados;
- M1 periódico não cria Monitoring Cycle por default;
- M2 periódico usa Monitor governante;
- overdue/gap são estados operacionais e não mudam currentness automaticamente;
- M3 formal permanece bloqueado.

Correção de inventário:

- `investigation.method_decision` existe desde a migration 014;
- permanece distinta de `maintenance.update_decision`;
- a correção não altera o PASS técnico da migration 027.

Próximo passo exato:

> **Definir a arquitetura transversal de SLA como contratos operacionais entre eventos claramente definidos, sem fixar durações universais antes do gate semântico.**

### CP92 — reconciliação e disciplina de interação

- CP91 reconciliado com o estado documental;
- README principal e CHANGELOG alinhados aos Documentos 16–19;
- template canônico atualizado com pausa obrigatória após checkpoints;
- após cada checkpoint formal, o trabalho deve parar e aguardar instrução explícita do usuário antes do bloco seguinte;
- nenhuma migration 028 foi criada;
- nenhum bloco de SLA foi iniciado neste checkpoint.

### Fase 4 — Arquitetura Transversal de SLA consolidada

Documentos:

- 20 — Arquitetura Transversal de SLA do Protocolo de Atualização;
- 21 — Revisão Adversarial da Arquitetura Transversal de SLA.

Estado:

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_PRIORITY_ARCHITECTURE**

> **MIGRATION_028 = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

Decisões consolidadas:

- SLA mede obrigação operacional, não estado científico;
- seis clocks mínimos foram definidos;
- late normalization não reinicia SLA-1;
- evento pré-policy preserva pre_policy_age sem breach retroativo;
- MaterialityAssessment e UpdateDecision usam timestamps qualificantes quando verificação humana ocorre depois;
- rule snapshot é congelada no início da SLA Instance;
- nominal_due_at e effective_due_at permanecem separados;
- pause não apaga breach e não é substituto de backlog/capacidade baixa;
- execution_status e compliance_status são eixos distintos;
- breached_then_satisfied preserva atraso histórico;
- Alert priority/classification pode informar SLA sem duração embutida;
- Monitor fornece timestamps upstream, mas cycle lateness continua pertencendo à cadence;
- SLA-4/5/6 exigem identidade causal por workflow/review round;
- triage transversal e milestones de workflow permanecem gaps físicos;
- currentness não deriva de SLA compliance;
- automação de breach/escalation não possui autoridade científica.

Próximo passo exato:

> **Definir a arquitetura transversal de prioridade e escalation antes de qualquer migration 028.**

### CP93

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP93.md`;
- ponteiro movido para CP93;
- arquitetura transversal de SLA aprovada com decisões arquiteturais;
- nenhuma migration 028 criada;
- nenhuma duração universal de SLA definida;
- retomada movida para prioridade/escalation;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Auditoria retrospectiva e hardening corretivo

Documentos:

- 22 — Auditoria Retrospectiva da Fase 4 até CP93;
- 23 — Gate de Coerência Física Corretivo pós-Auditoria;
- 24 — Resultado da Validação Corretiva pós-Auditoria.

Estado:

> **RETROSPECTIVE_AUDIT_CORRECTIVE_BLOCK = CLOSED_PASS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING**

> **MIGRATION_028_CORRECTIVE_HARDENING = PASS**

> **F4_UP_PLAN_MIRRORED_REQUIREMENTS = P01–P63 PASS**

Decisões e correções:

- migration 027 foi preservada historicamente;
- migration 028 foi usada somente para hardening corretivo;
- `signal_type='other'` passou a respeitar fronteira scientific_currentness × operational;
- nova UpdateDecision exige UpdateSignal ativo;
- novo linkage para CurrencyState exige UpdateDecision ativa;
- issue helpers de policy/signal/materiality/decision foram ampliados;
- suíte histórica T01–T63 permanece verde;
- suíte P01–P63 passa a espelhar explicitamente os 63 requisitos mínimos do Documento 07;
- a run #143 falhou por erro de desenho do teste P62 e não é evidência de PASS;
- a run #144 é a evidência canônica do hardening.

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37576434417** (#144);
- technical HEAD: `3f36b5dd4103e15834adde107fedeeb1c81fb084`;
- conclusion: **success**;
- artifact: **11462802190**;
- digest: `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- T01–T63 = PASS;
- P01–P63 = PASS;
- migration 027 idempotency = PASS;
- migration 028 idempotency = PASS;
- rebuild-through-028 = PASS;
- F2-B/S4/S5 regressions = PASS;
- Monitor/Alert regressions = PASS.

Limites preservados:

- M3 formal continua bloqueado por `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`;
- prioridade/escalation ainda não foi iniciada;
- nenhuma duração numérica universal de SLA foi definida;
- nenhum contrato físico adicional de prioridade/SLA foi autorizado;
- triage transversal e milestones de workflow continuam gaps físicos;
- notifications, propagation/re-baselining e M3 readiness continuam pendentes.

Próximo passo exato:

> **Definir a arquitetura transversal de prioridade e escalation, somente após o checkpoint corretivo e nova instrução explícita do usuário.**

### CP94 — auditoria retrospectiva e hardening corretivo

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP94.md`;
- ponteiro movido para CP94;
- bloco corretivo da auditoria encerrado em **CLOSED_PASS**;
- `PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING`;
- migration 028 corretiva = PASS;
- T01–T63 = PASS;
- P01–P63 = PASS;
- rebuild-through-028 = PASS;
- regressões F2-B/S4/S5 e Monitor/Alert = PASS;
- run canônico **37576434417** (#144) = success;
- artifact **11462802190**;
- digest `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- run #143 preservada como falha de desenho do teste P62, não evidência de regressão;
- M3 formal permanece bloqueado;
- prioridade/escalation ainda não iniciada;
- próximo passo: arquitetura transversal de prioridade e escalation;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Arquitetura transversal de prioridade e escalation

Documentos:

- 25 — Arquitetura Transversal de Prioridade e Escalation;
- 26 — Revisão Adversarial da Arquitetura Transversal de Prioridade e Escalation.

Estado:

> **PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT_DESIGN**

> **MIGRATION_029 = NOT_AUTHORIZED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **NUMERIC_PRIORITY_WEIGHTS = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Decisões consolidadas:

- prioridade é avaliada por case/UpdateSignal/target version, não como atributo permanente do Product/Investigation;
- response_class transversal = standard | expedited | urgent | immediate;
- response_class não contém duração de SLA;
- priority e escalation são eixos independentes;
- safety/integrity e validity/use podem criar dominance floors;
- `suspend_current_use` implica floor immediate + rota de current-use governance, sem executar retirada/publicação;
- `material_change_confirmed` isolado e `update_recommended` isolado são strong modifiers, não floors universais;
- priority authoritative baseada em materialidade científica exige qualificação humana apropriada;
- Alert classification/reassessment_priority é input local/comunicacional, sem equivalência automática;
- SLA breach é operational pressure modifier e não retroage SLA Rule snapshot;
- capacity/cost não reduzem prioridade;
- dependency reach aumenta coordenação/propagation assessment, não materiality;
- queue aggregation futura deve ser derivada e manter linkage para casos causais;
- escalation candidate pode ser automático; active escalation exige autoridade humana na baseline;
- nenhum score aditivo ou peso numérico foi autorizado;
- target supersession/invalidation pertence a lifecycle/reassessment, não dominance gate.

Referências metodológicas consideradas:

- Cochrane Handbook Chapter IV;
- Cochrane Handbook Chapter 22;
- Cochrane Interactive Learning Module 14 (2026);
- NICE PMG49 (2025);
- WHO living-guidelines approach.

Próximo passo exato:

> **Definir o contrato de dados integrado do plano operacional da Fase 4 — triage + PriorityAssessment + escalation + SLA Rule/Instance + pause ledger + milestones mínimos de workflow/review — sem migration; depois executar gate físico próprio.**

### CP95 — arquitetura transversal de prioridade e escalation

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP95.md`;
- ponteiro movido para CP95;
- `PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- response_class = standard | expedited | urgent | immediate;
- priority e escalation permanecem eixos independentes;
- priority authoritative científica exige qualificação humana apropriada;
- Alert priority/classification permanece input, sem equivalência automática;
- SLA breach permanece operational pressure modifier;
- capacity não reduz priority;
- dependency reach não vira materiality;
- priority score/pesos numéricos não definidos;
- auto-escalation não autorizada;
- migration 029 não autorizada;
- M3 formal permanece bloqueado;
- último PASS técnico continua sendo run **37576434417** (#144), pois o bloco CP95 foi documental/arquitetural;
- próximo passo: contrato de dados integrado do plano operacional da Fase 4, ainda sem migration;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Contrato operacional integrado

Documentos:

- 27 — Contrato de Dados Integrado do Plano Operacional da Fase 4;
- 28 — Gate Adversarial de Coerência Física do Contrato Operacional Integrado.

Estado:

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_MIGRATION_029**

> **MIGRATION_029_SCOPE = OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Estruturas autorizadas para a futura migration 029:

- update_triage;
- priority_assessment;
- priority_basis;
- escalation_case;
- escalation_reason;
- escalation_route;
- sla_calendar_version;
- sla_rule;
- sla_instance;
- sla_pause;
- workflow_round;
- workflow_milestone;
- validators/guards/readiness/helpers estritamente necessários.

Decisões consolidadas:

- UpdatePolicy continua a âncora; não criar OperationalPlan duplicado;
- triage invalid_signal usa constraint deferred para consistência transacional;
- PriorityBasis usa source_type + locator XOR + snapshot;
- escalation lifecycle possui transições fechadas e activation humana;
- SLA Rule usa rule_code + selection_precedence determinística;
- clock→endpoint e time_basis matrices estão fechadas;
- calendário e fixed deadline possuem shapes fechados/validáveis;
- effective_due/current compliance são derivados, não campos autoritativos livres;
- SLA obligations têm cardinalidade definida por signal/round;
- WorkflowRound planned ancora SLA-4;
- WorkflowRound status não duplica scientific/review/publication milestones;
- WorkflowMilestone usa adapter_type + locator XOR + precisão timestamp/date;
- publication permanece subordinada ao gate especializado do product_type;
- UpdateRiskProfile ainda é snapshot bridge versionado, não pseudo-FK;
- nenhum número/default SLA foi autorizado;
- migration 029 não pode inserir regras SLA normativas arbitrárias;
- F4-OC-T01–T72 será a suíte mínima espelhada da implementação.

Próximo passo exato:

> **Implementar migration 029 + F4-OC-T01–T72 + integração S5 e executar validação canônica completa antes de qualquer PASS técnico.**

### CP96 — contrato operacional integrado

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP96.md`;
- ponteiro movido para CP96;
- `INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READY_FOR_MIGRATION_029`;
- migration 029 autorizada em escopo **OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**;
- migration 029 ainda não implementada;
- nenhuma duração SLA numérica foi definida;
- nenhum priority score/peso foi definido;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- último PASS técnico continua sendo run **37576434417** (#144), through migration 028;
- próximo passo: implementar migration 029 + F4-OC-T01–T72 + S5/idempotência/rebuild/regressões;
- modo médio é seguro para a implementação mecânica; se surgir nova decisão arquitetural, parar e recomendar modo alto;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Validação técnica do controle operacional integrado

Documento:

- 29 — Resultado da Validação Técnica do Controle Operacional Integrado da Fase 4.

Estado:

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_029 = PASS**

> **F4_OC_T01_T72 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37580906483** (#150);
- technical HEAD: `ae45918bb8cbf1ab929aec2e1af53f7239f75323`;
- conclusion: **success**;
- artifact: **11464672034**;
- digest: `sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`;
- F4-OC-T01–T69 = PASS;
- T70 migration 029 idempotency = PASS;
- T71 rebuild-through-029 = PASS;
- T72 regressões completas = PASS;
- F4-UP-T01–T63 = PASS;
- F4-UP-P01–P63 = PASS;
- M3 blocker preservado.

Runs #145–#149 foram diagnósticas/falhas não canônicas, classificadas no Documento 29 como erros de implementação/test setup/test isolation/test editing, e não são evidência de PASS.

Limites preservados:

- nenhuma duração SLA normativa;
- nenhum priority score/peso;
- auto-escalation não autorizada;
- scheduler não implementado;
- notification channels não implementados;
- propagation/re-baselining não implementados;
- UpdateRiskProfile físico ainda não normalizado;
- M3 readiness ainda não autorizada;
- operação humana real não iniciada.

Próximo passo:

> **ser definido no checkpoint pós-PASS; nenhum novo bloco funcional é iniciado automaticamente.**

### CP97 — PASS técnico do controle operacional integrado

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP97.md`;
- ponteiro movido para CP97;
- `INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_029 = PASS`;
- F4-OC-T01–T72 = PASS;
- run canônico **37580906483** (#150) = success;
- technical HEAD `ae45918bb8cbf1ab929aec2e1af53f7239f75323`;
- artifact **11464672034**;
- digest `sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`;
- rebuild-through-029 = PASS;
- regressões completas = PASS;
- F4-UP-T01–T63/P01–P63 permanecem verdes;
- M3 formal permanece bloqueado;
- nenhum SLA normativo/score/auto-escalation foi introduzido;
- próximo bloco da Fase 4 ainda não foi selecionado;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint permanece vigente.


### Fase 4 — Normalização física do UpdateRiskProfile

Documentos:
- 30 — Contrato Físico Candidato do UpdateRiskProfile;
- 31 — Gate Adversarial do Contrato Físico UpdateRiskProfile.

Estado:
> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_MIGRATION_030**

> **MIGRATION_030_SCOPE = UPDATE_RISK_PROFILE_NORMALIZATION_ONLY**

Decisões:
- profile = header versionado + 10 dimensões auditáveis;
- provenance dimensional normalizada com FKs reais/locator XOR;
- profile authoritative exige reviewer/expert no header;
- B5 authoritative exige owner, sem fabricar owner como verifier científico;
- proposal incompleto pode existir, mas não alimenta PriorityAssessment;
- carry-forward explícito por dimensão e mesma lineage entity_uuid;
- UpdatePolicy continua soberana;
- snapshots históricos de PriorityAssessment não serão backfillados;
- novos PriorityAssessment após migration 030 deverão referenciar profile físico + serializer canônico;
- M3 continua bloqueado;
- migration 030 ainda não implementada.

Próximo passo:
> **implementar migration 030 + F4-RP-T01–T87 + validação canônica completa.**

### CP98 — contrato físico do UpdateRiskProfile

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP98.md`;
- ponteiro movido para CP98;
- `UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READY_FOR_MIGRATION_030`;
- migration 030 autorizada apenas como `UPDATE_RISK_PROFILE_NORMALIZATION_ONLY`;
- migration 030 ainda não implementada;
- F4-RP-T01–T87 definido como plano mínimo futuro;
- snapshots históricos permanecem grandfathered, sem backfill fabricado;
- novos PriorityAssessment após migration 030 deverão usar profile físico + serializer canônico;
- risk score/numeric cadence/numeric SLA continuam não definidos;
- auto policy change não autorizado;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37580906483** (#150), through migration 029;
- próximo passo: implementar migration 030 + testes + validação canônica;
- modo médio seguro para implementação mecânica; nova decisão arquitetural exige parada e modo alto;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Validação técnica do UpdateRiskProfile físico

Documento:

- 32 — Resultado da Validação Técnica do UpdateRiskProfile Físico.

Estado:

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_030 = PASS**

> **F4_RP_T01_T87 = PASS**

> **REBUILD_THROUGH_030 = PASS**

> **FULL_REGRESSIONS_AFTER_030 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37618433929** (#161);
- technical HEAD: `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- job id: **112782351104**;
- conclusion: **success**;
- artifact: **11480858194**;
- digest: `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`;
- F4-RP-T01–T84 = PASS;
- T85 migration 030 idempotency = PASS;
- T86 rebuild-through-030 = PASS;
- T87 regressões completas = PASS;
- F4-OC-T01–T72 permanecem compatíveis/verdes;
- F4-UP, F2-B, S4, S5, F3 Products, Monitor e Alert permanecem verdes;
- M3 blocker preservado.

Runs #153–#160 foram diagnósticas e não canônicas, classificadas no Documento 32 como erros de instalação/implementação/setup/order/brittleness/test editing.

Limites preservados:

- nenhum risk score;
- nenhuma cadence numérica;
- nenhum SLA normativo novo;
- nenhum auto-policy change;
- nenhum backfill autoritativo fabricado;
- nenhum auto-signal/auto-alert;
- scheduler/notifications não implementados;
- M3 readiness não autorizado.

Próximo passo:

> **ainda não selecionado; deverá ser escolhido explicitamente após o checkpoint pós-PASS.**

### CP99 — PASS técnico do UpdateRiskProfile físico

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP99.md`;
- ponteiro movido para CP99;
- `UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_030 = PASS`;
- F4-RP-T01–T87 = PASS;
- rebuild-through-030 = PASS;
- regressões completas = PASS;
- run canônico **37618433929** (#161) = success;
- technical HEAD `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- artifact **11480858194**;
- digest `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`;
- F4-OC e F4-UP permanecem verdes;
- M3 formal permanece bloqueado;
- nenhum risk score/numeric cadence/numeric SLA/auto-policy change foi introduzido;
- próxima dívida da Fase 4 ainda não selecionada;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Propagação de mudanças e re-baselining

Documento:
- 33 — Arquitetura Transversal de Propagação de Mudanças e Re-baselining.

Estado:
> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = CANDIDATE_FOR_ADVERSARIAL_GATE**

Decisões estruturais candidatas:
- dependency discovery não equivale a impacto científico;
- propagation não altera currentness automaticamente;
- re-baselining é separado de propagation;
- UpdatePolicy não pode usar supersession cross-target;
- MonitorTarget não pode ser retargeteado in-place;
- novo target M2/M3 exige novo Monitor ProductVersion/binding explícito;
- UpdateRiskProfile, signals, Priority, SLA, workflow e Alerts históricos permanecem ancorados no target original;
- M3 blocker permanece preservado.

Próximo passo:
> **executar revisão adversarial específica do Documento 33 antes de qualquer contrato físico ou migration.**

### Fase 4 — Gate adversarial de propagation/re-baselining

Documentos:
- 33 — Arquitetura Transversal de Propagação de Mudanças e Re-baselining;
- 34 — Revisão Adversarial da Arquitetura de Propagação e Re-baselining.

Estado:
> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **MIGRATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Hardening consolidado:
- maintainable targets separados de objetos intermediários do dependency graph;
- target mantível sem policy usa `maintenance_policy_required`;
- propagation→UpdateSignal exige adapter estruturado futuro, sem apagar causalidade;
- um candidate por assessment + impacted version, com 1:N path snapshots;
- cycle/depth guard e lineage validation obrigatórios;
- rebaseline exige same entity + chain versionada auditável;
- planned e activated rebaseline separados;
- policy cross-target lineage é separada de `supersedes_update_policy_uuid`;
- novo M2/M3 exige novo Monitor ProductVersion current e target coerente antes da policy;
- coverage, UpdateRiskProfile, SLA Rules/Instances, workflow, Priority/Escalation e Alerts preservam história;
- authority operacional separada de scientific/methodological/mixed;
- nenhum currentness/assurance/M3 update automático.

Próximo passo:
> **especificar o Contrato Físico v0.1 de Propagation/Re-baselining e submetê-lo a novo gate antes de qualquer migration.**

### CP100 — arquitetura de propagation/re-baselining

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP100.md`;
- ponteiro movido para CP100;
- `PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY`;
- Documento 33 hardenizado após primeira passagem adversarial REVISE;
- Documento 34 recheck final = PASS_WITH_ARCHITECTURAL_DECISIONS;
- cross-target policy supersession continua proibida;
- MonitorTarget retarget in-place continua proibido;
- new M2/M3 target exige novo Monitor ProductVersion current e coerente;
- propagation→UpdateSignal exige adapter estruturado futuro;
- lineage validation, multiple paths, cycle/depth guard e concurrency estão explicitados;
- UpdateRiskProfile/SLA/workflow/Priority/Escalation/Alert históricos não são retargeteados;
- nenhuma migration autorizada;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37618433929** (#161) do CP99;
- próximo passo: Contrato Físico v0.1 + novo gate, ainda em modo alto;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Contrato Físico candidato de Propagation/Re-baselining

Documento:
- 35 — Contrato Físico v0.1 de Propagation/Re-baselining.

Estado:
> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = CANDIDATE_FOR_PHYSICAL_GATE**

> **F4_PRB_T01_T128 = TEST_PLAN_CANDIDATE**

> **MIGRATION_031 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Estruturas candidatas:
- PropagationAssessment/Candidate/Path/PathStep;
- adapter estruturado PropagationCandidate → UpdateSignalSource;
- RebaselineDecision;
- handover explícito de UpdatePolicy, Monitor, UpdateRiskProfile, coverage, SLA Rules/Instances, signals e workflow;
- issue/readiness helpers;
- grandfathering sem backfill fabricado.

Próximo passo:
> **executar gate adversarial/físico do Documento 35 antes de qualquer migration.**

### Fase 4 — Gate físico de Propagation/Re-baselining

Documentos:
- 35 — Contrato Físico v0.1 de Propagation/Re-baselining;
- 36 — Gate Adversarial/Físico do Contrato de Propagation/Re-baselining.

Estado:
> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_PRB_T01_T145 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_031 = AUTHORIZED_IN_STRICT_SCOPE**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Decisões físicas consolidadas:
- target classes fechadas em maintainable_product / maintainable_investigation / nonmaintainable_version;
- propagation path normalizado e no_action bloqueado por lineage incompleto;
- version chain de rebaseline normalizada em child steps com FKs;
- RebaselineDecision append-preserving com activation authoritative única por old target;
- policy handover cross-target separado de supersession same-target;
- new M2/M3 policy exige novo Monitor current/coerente;
- profile readiness condicional preserva guard da migration 030;
- target supersession não invalida UpdateSignal;
- PropagationCandidate → UpdateSignalSource exige adapter completo;
- contract epoch técnico reservado apenas a grandfathering;
- SLA cross-policy não reutiliza supersession FK;
- SLA Instance handover não contorna lifecycle/first-breach guards;
- migration 031 não pode criar automação científica, numeric SLA/cadence ou remover blocker M3.

Próximo passo:
> **implementar migration 031 + fixtures sintéticas + F4-PRB-T01–T145 + integração S5; depois validar idempotência, rebuild-through-031 e regressões completas.**

Disciplina de modo:
> **a etapa arquitetural de alta complexidade terminou; modo médio é suficiente para a implementação mecânica já especificada.**

### CP101 — contrato físico de propagation/re-baselining

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP101.md`;
- ponteiro movido para CP101;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `F4_PRB_T01_T145 = APPROVED_MINIMUM_TEST_PLAN`;
- `MIGRATION_031 = AUTHORIZED_IN_STRICT_SCOPE`;
- migration 031 ainda não implementada;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37618433929** (#161);
- próximo passo: implementação migration 031 + fixtures/testes/S5;
- modo médio suficiente enquanto o escopo permanecer mecânico;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint preservada.


### Fase 4 — PASS técnico de Propagation/Re-baselining

Documento:
- 37 — Resultado da Validação Técnica de Propagation/Re-baselining.

Estado:
> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_031 = PASS**

> **F4_PRB_T01_T145 = PASS**

> **MIGRATION_031_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_031 = PASS**

> **GLOBAL_REGRESSIONS_AFTER_031 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Evidência canônica:
- S5 run **37644296649** (#167) = success;
- technical HEAD `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- job `postgres-s5` / **112870931087** = success;
- artifact **11494595216**;
- digest `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`.

Implementação:
- migration lógica 031 + fragments 031a–031e;
- fixtures sintéticas PRB;
- F4-PRB-T01–T145;
- adapter PropagationCandidate → UpdateSignalSource;
- child handover validators;
- idempotência/rebuild/regressões integradas no S5.

Runs #163–#166:
- diagnósticas/intermediárias;
- falhas locais de fixture/wiring;
- não são evidência canônica de PASS.

Limites preservados:
- sem numeric SLA/cadence;
- sem scheduler/notifications;
- sem auto-propagation/auto-rebaseline;
- sem automatic currentness/assurance;
- sem backfill/revisão humana fabricados;
- M3 continua bloqueado.

Próximo passo:
> **criar checkpoint técnico pós-PASS e, somente após nova autorização do usuário, selecionar explicitamente a próxima dívida aberta da Fase 4.**

### CP102 — PASS técnico de propagation/re-baselining

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP102.md`;
- ponteiro movido para CP102;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_031 = PASS`;
- F4-PRB-T01–T145 = PASS;
- migration 031 idempotency = PASS;
- rebuild-through-031 = PASS;
- regressões completas = PASS;
- S5 run canônico **37644296649** (#167) = success;
- technical HEAD `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- artifact **11494595216**;
- digest `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`;
- M3 formal permanece bloqueado;
- próxima dívida da Fase 4 ainda não selecionada;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint preservada.


### Fase 4 — seleção do próximo bloco após CP102

Documento:
- 38 — Seleção da Próxima Dívida da Fase 4.

Decisão:
> **NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION**

> **TEMPORAL_CALIBRATION = SELECTED_NOT_STARTED**

> **PRIORITY_SCORE = DELIBERATELY_NOT_REQUIRED_FOR_BASELINE**

Racional:
- scheduler depende de cadence/thresholds normativos;
- breach/overdue normativo depende de SLA duration + calendar;
- notifications dependem de eventos/thresholds definidos;
- M3 readiness depende de cadence/SLA operacionais coerentes;
- priority score aditivo foi deliberadamente rejeitado pela arquitetura aprovada.

Limites:
- nenhum número de cadence/threshold/SLA foi definido;
- scheduler não iniciado;
- notifications não iniciadas;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Disciplina de modo:
> **HIGH_MODE_RECOMMENDED_BEFORE_TEMPORAL_CALIBRATION**

Próximo passo:
> **em modo alto, definir primeiro a metodologia de calibração temporal; somente depois considerar valores normativos.**

### CP103 — seleção do próximo bloco da Fase 4

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP103.md`;
- ponteiro movido para CP103;
- `NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION`;
- `TEMPORAL_CALIBRATION = SELECTED_NOT_STARTED`;
- priority score permanece deliberadamente dispensável no baseline;
- nenhum valor numérico foi definido;
- scheduler/notifications não iniciados;
- auto-escalation não autorizada;
- M3 formal permanece bloqueado;
- modo alto recomendado antes da metodologia de calibração;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


### Fase 4 — metodologia de calibração temporal

Documentos:
- 39 — Metodologia de Calibração Temporal da Fase 4;
- 40 — Gate Adversarial da Metodologia de Calibração Temporal.

Estado:
> **TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Metodologia fechada:
- calibração por envelopes independentes, sem score;
- A1–A5 não mapeiam automaticamente para números;
- seleção por constraints + dominância/Pareto;
- source latency não determina cadence isoladamente;
- replay inclui censura/missingness/falhas;
- PriorityAssessment usado na seleção SLA é snapshot pré-instance;
- calibração provisional não vira rule ativa;
- repeated breach não relaxa SLA automaticamente;
- external deadline exige compatibilidade semântica;
- capacity/calendar laundering proibidos.

Pré-requisitos físicos autorizados apenas para especificação:
- Calibration Dossier + structured basis;
- cadence schema/obligation contract;
- source-scoped cadence support quando necessário;
- canonical SLA rule resolver;
- filter-domain validation;
- canonical rule snapshot;
- nominal due calculator;
- business-calendar arithmetic;
- fixed-deadline lineage;
- calendar effective-window;
- warning/breach/escalation schemas;
- issue/readiness helpers e test plan.

Nenhum valor numérico, calendário real ou SLARule normativa foi autorizado.

Próximo passo:
> **especificar contrato físico v0.1 dos pré-requisitos de calibração temporal e submetê-lo a novo gate antes de qualquer migration ou valor normativo.**

### CP104 — metodologia de calibração temporal

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP104.md`;
- ponteiro movido para CP104;
- `TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY`;
- nenhum valor temporal normativo autorizado;
- migration 032 não autorizada;
- scheduler/notifications/auto-escalation não autorizados;
- M3 formal permanece bloqueado;
- último PASS técnico continua S5 #167;
- próximo passo: contrato físico v0.1 dos pré-requisitos + novo gate;
- modo alto recomendado;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


### Fase 4 — contrato físico de calibração temporal

Documentos:
- 41 — Contrato Físico v0.1 dos Pré-requisitos de Calibração Temporal;
- 41A — Anexo A de auditabilidade;
- 42 — Gate Adversarial/Físico;
- 43 — Recheck Final.

Estado:
> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Decisões consolidadas:
- Calibration Dossier/authority/basis/candidate/evaluation;
- cadence contract/obligation/observation normalizados;
- hybrid por composição de obligations;
- continuous excluído do CadenceContract v0.1;
- source-scope proof;
- causal SLA filter matrix;
- historical/as-of SLARule resolution;
- raw causal start versus contractual start;
- due/calendar arithmetic determinística;
- fixed-deadline lineage;
- pause extension/accountable duration auditável;
- grandfathering por registry técnico explícito, não por backdating;
- due/occurrence snapshots históricos;
- nenhum valor real autorizado.

Uploads manuais reconciliados:
- Documento 41A: commit `3af8f9e1e07a68ca12b29b5d17bf991f7059123f`;
- Documento 43: commit `1cc02552a57a3fb52559b11c2443b12f3d024902`;
- blob SHAs remotos coincidem com os arquivos entregues localmente.

Próximo passo:
> **após CP105 e novo Freshness Gate, implementar migration 032 + fixtures sintéticas + F4-TCAL-PH-T01–T230 e integrar ao S5; parar se surgir nova decisão arquitetural.**

### CP105 — contrato físico de calibração temporal

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP105.md`;
- ponteiro movido para CP105;
- `TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN`;
- `MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE`;
- valores normativos permanecem não autorizados;
- scheduler/notifications/auto-escalation permanecem não autorizados;
- M3 formal permanece bloqueado;
- próximo passo: implementar migration 032 + fixtures/testes e validar tecnicamente;
- modo médio suficiente para implementação mecânica; voltar a alto se surgir nova decisão arquitetural;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


### Fase 4 — migration 032 implementada e validada

Documento técnico:
- `docs/governance/44-resultado-tecnico-migration-032-validacao-temporal-v01.md`.

Estado:
> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = IMPLEMENTED_AND_TECHNICALLY_VALIDATED**

> **F4_TCAL_PH_T01_T230 = PASS**

> **MIGRATION_032_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_032 = PASS**

> **S5_CANONICAL = PASS**

Validação canônica:
- HEAD técnico: `657c69024fafb6c2e6311d47091d5897730668fd`;
- run ID: `37690201061`;
- job ID: `113028117278`;
- artifact ID: `11512707774`;
- artifact: `oes-s5-evidence-37690201061`;
- size: `250711` bytes;
- digest: `sha256:bb145efb29d7c30e607136defa09c828711162e27ac71a307df229449980f826`.

Restrições preservadas:
- `NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED`;
- scheduler/notifications/auto-escalation não autorizados;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após CP106 e novo Freshness Gate, retornar ao nível metodológico/governança em modo alto para decidir qual deve ser o próximo bloco da Fase 4; não iniciar calibração normativa automaticamente.**


### CP106 — migration 032 validada

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP106.md`;
- ponteiro movido para CP106;
- `TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = IMPLEMENTED_AND_TECHNICALLY_VALIDATED`;
- `F4_TCAL_PH_T01_T230 = PASS`;
- `MIGRATION_032_IDEMPOTENCY = PASS`;
- `REBUILD_THROUGH_032 = PASS`;
- `S5_CANONICAL = PASS`;
- valores temporais normativos continuam não autorizados;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 formal continua bloqueado;
- Fase 5 não iniciada;
- próximo passo volta ao nível metodológico/governança;
- modo alto recomendado para decidir o próximo bloco da Fase 4;
- pausa obrigatória preservada.


### Fase 4 — seleção do próximo sub-bloco pós-CP106

Documento:
- `docs/governance/45-inventario-pos-cp106-selecao-evidence-readiness-calibracao-temporal.md`.

Decisão:
> **TEMPORAL_CALIBRATION_TRACK = CONTINUES**

> **NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS**

> **NEXT_PHASE_4_SUBBLOCK = TEMPORAL_CALIBRATION_EVIDENCE_READINESS**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

Dependências preservadas:
- scheduler permanece dependente de obrigações temporais normativas aprovadas;
- notifications permanecem dependentes de eventos/thresholds aprovados;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Racional:
- infraestrutura física da calibration v0.1 já está validada;
- fixtures temporais/operacionais disponíveis são explicitamente sintéticas;
- não há no estado canônico base real suficiente para sustentar genericamente `sufficient_for_calibration`;
- casos reais de produtos científicos não equivalem automaticamente a histórico real de MonitorCycle, source latency, SLA operacional, capacity ou calendário institucional.

Próximo passo:
> **em modo alto, especificar o Protocolo de Evidence Readiness para Calibração Temporal v0.1 e submetê-lo a gate adversarial, ainda sem valores normativos.**


### CP107 — seleção do Evidence Readiness temporal

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP107.md`;
- ponteiro movido para CP107;
- `TEMPORAL_CALIBRATION_TRACK = CONTINUES`;
- `NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS`;
- `NEXT_PHASE_4_SUBBLOCK = TEMPORAL_CALIBRATION_EVIDENCE_READINESS`;
- `REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED`;
- `NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED`;
- nenhum novo migration autorizado;
- scheduler/notifications permanecem deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: Protocolo de Evidence Readiness v0.1 + gate adversarial, em modo alto;
- pausa obrigatória preservada.


### Fase 4 — protocolo de Evidence Readiness temporal

Documentos:
- `docs/governance/46-protocolo-evidence-readiness-calibracao-temporal-v01.md`;
- `docs/governance/47-gate-adversarial-evidence-readiness-calibracao-temporal.md`.

Estado:
> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READINESS_ASSESSMENT_ON_REAL_CONTEXT = AUTHORIZED_UNDER_PROTOCOL**

> **FIRST_REAL_READINESS_ASSESSMENT = AUTHORIZED_FOR_SELECTION_AND_EXECUTION**

> **REAL_CALIBRATION_DOSSIER = CONDITIONALLY_AUTHORIZED_ONLY_AFTER_CONTEXT_SPECIFIC_READY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

Hardening consolidado:
- prova positiva de realidade/admissibilidade;
- human verification para READY;
- blocker-set dominance;
- cohort/window/denominator/representativeness;
- persistência obrigatória de fonte externa material;
- lifecycle non-normative de measurement schedule;
- rationale/verificação para R7;
- source behavior separado de observed/OES detection latency;
- drift invalidation;
- fixed-deadline applicability por autoridade competente;
- pilot inference sem generalização automática;
- prospective observation sob data governance;
- reassess boundary obrigatório.

Próximo passo:
> **após checkpoint, em modo alto, selecionar o primeiro exact real context e executar somente o Evidence Readiness Assessment, sem calibração numérica.**


### CP108 — Evidence Readiness temporal validado

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP108.md`;
- ponteiro movido para CP108;
- `TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READINESS_ASSESSMENT_ON_REAL_CONTEXT = AUTHORIZED_UNDER_PROTOCOL`;
- `FIRST_REAL_READINESS_ASSESSMENT = AUTHORIZED_FOR_SELECTION_AND_EXECUTION`;
- `REAL_CALIBRATION_DOSSIER = CONDITIONALLY_AUTHORIZED_ONLY_AFTER_CONTEXT_SPECIFIC_READY`;
- `NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED`;
- nenhum novo migration autorizado;
- scheduler/notifications continuam deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: selecionar e executar o primeiro exact real context de Evidence Readiness, em modo alto, sem calibração numérica;
- pausa obrigatória preservada.


### Fase 4 — primeiro Evidence Readiness Assessment real

Documento:
- `docs/governance/48-primeiro-evidence-readiness-assessment-real-n1-cadence.md`.

Contexto:
> **N1_01_PRODUCTVERSION_2_CADENCE_POLICY_AGGREGATE**

Resultado:
> **FIRST_REAL_READINESS_ASSESSMENT = COMPLETED**

> **PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE**

> **READY_FOR_CALIBRATION = NO**

> **REAL_CALIBRATION_DOSSIER_FOR_CONTEXT = NOT_AUTHORIZED**

> **TEMPORAL_OBSERVATION_PLAN = NOT_YET_SPECIFIED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Blockers materiais:
- ausência de UpdateRiskProfile real para o target;
- source characterization insuficiente;
- ausência de história longitudinal de surveillance/cadence;
- ausência de human authority específica para readiness/maintenance;
- feasibility/capacity não estabelecida;
- replay longitudinal atualmente inviável.

Princípio validado:
> produto real/publicado + searches reais não equivalem a base temporal operacional suficiente para calibration.

Próximo passo:
> **após checkpoint, decidir em modo alto entre especificar um Temporal Observation Plan não normativo para N1-01 ou executar um segundo real-context readiness assessment antes de iniciar observação prospectiva.**


### CP109 — primeiro Evidence Readiness real

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP109.md`;
- ponteiro movido para CP109;
- `FIRST_REAL_READINESS_ASSESSMENT = COMPLETED`;
- contexto = N1-01 / ProductVersion 2 / cadence / policy_aggregate;
- `PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE`;
- `READY_FOR_CALIBRATION = NO`;
- Calibration Dossier real para o contexto = não autorizado;
- Temporal Observation Plan = ainda não especificado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications continuam deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir em modo alto entre observation plan não normativo para N1-01 ou segundo readiness assessment real;
- pausa obrigatória preservada.


### Fase 4 — reconciliação do primeiro readiness e seleção do segundo contexto real

Documento:
- `docs/governance/49-reconciliacao-selecao-segundo-evidence-readiness-real.md`.

Reconciliação:
> **FIRST_REAL_READINESS_ASSESSMENT_RESULT = PRESERVED**

> **DOCUMENT_48_SELECTION_RATIONALE = PARTIALLY_CORRECTED**

Foi identificada e reconciliada divergência factual na seção comparativa do Documento 48: o Caso Real N2/dCBT-I não permaneceu em pré-publicação. CP28 e Documentos 66–67 confirmam A2, `published`, owner governance approval e publication gate PASS.

A divergência não invalida os blockers específicos do primeiro assessment N1-01.

Decisão:
> **OPTION_B = SELECTED**

> **SECOND_REAL_READINESS_CONTEXT = N2_RC01_PRODUCTVERSION_1_CADENCE_POLICY_AGGREGATE**

> **SECOND_REAL_READINESS_ASSESSMENT = SELECTED_NOT_EXECUTED**

> **TEMPORAL_OBSERVATION_PLAN_N1_01 = DEFERRED_PENDING_SECOND_ASSESSMENT**

O N2 selecionado é Product `OES-P-2026-000401`, ProductVersion `81000000-0000-0000-0000-000000000701`, N2/evidence_sheet, A2/published, com quatro Search rows reais em PubMed/MEDLINE, BVS/LILACS e ClinicalTrials.gov.

Restrições preservadas:
- nenhum Calibration Dossier real autorizado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications permanecem deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, executar o segundo Evidence Readiness Assessment real no N2/dCBT-I, cadence / policy_aggregate, sem calibração numérica nem observação prospectiva.**


### CP110 — reconciliação do readiness e segundo contexto real

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP110.md`;
- ponteiro de continuidade movido para CP110;
- resultado do primeiro readiness N1-01 preservado;
- justificativa comparativa do Documento 48 parcialmente corrigida pelo Documento 49;
- N2/dCBT-I A2/published selecionado como segundo contexto real;
- `SECOND_REAL_READINESS_ASSESSMENT = SELECTED_NOT_EXECUTED`;
- `TEMPORAL_OBSERVATION_PLAN_N1_01 = DEFERRED_PENDING_SECOND_ASSESSMENT`;
- nenhum valor temporal normativo autorizado;
- nenhum Calibration Dossier real autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications continuam deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: executar, em modo alto, o segundo Evidence Readiness Assessment real no N2/dCBT-I;
- pausa obrigatória preservada.


### Fase 4 — segundo Evidence Readiness Assessment real

Documento:
- `docs/governance/50-segundo-evidence-readiness-assessment-real-n2-cadence.md`.

Contexto:
> **SECOND_REAL_READINESS_CONTEXT = N2_RC01_PRODUCTVERSION_1_CADENCE_POLICY_AGGREGATE**

Resultado:
> **SECOND_REAL_READINESS_ASSESSMENT = COMPLETED**

> **PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE**

> **READY_FOR_CALIBRATION = NO**

> **REAL_CALIBRATION_DOSSIER_FOR_N2 = NOT_AUTHORIZED**

Evidência real relevante:
- ProductVersion N2 A2/published;
- 4 searches reais;
- PubMed/MEDLINE, BVS/LILACS e ClinicalTrials.gov;
- 6 SearchHits persistidos;
- 6 ScreeningDecisions;
- provenance/currency/assurance reais.

Blockers materiais:
- `INSUFFICIENT_NEED_EVIDENCE`;
- `NEEDS_SOURCE_CHARACTERIZATION`;
- `NEEDS_PROSPECTIVE_OBSERVATION`;
- `NEEDS_HUMAN_AUTHORITY`;
- `FEASIBILITY_NOT_ESTABLISHED`;
- `REPLAY_NOT_CURRENTLY_FEASIBLE`.

Comparação N1/N2:
- blockers centrais recorrentes nos dois contexts;
- source diversity do N2 não elevou cadence readiness;
- déficit passa a ser interpretado, com cautela, como parcialmente transversal ao estado operacional atual do OES;
- terceiro readiness assessment imediato não selecionado.

Estado:
> **TWO_REAL_CONTEXTS_ASSESSED = YES**

> **THIRD_IMMEDIATE_READINESS_ASSESSMENT = NOT_SELECTED**

> **TEMPORAL_EVIDENCE_ACQUISITION_DESIGN = NEXT_DECISION**

Restrições preservadas:
- nenhum Calibration Dossier real;
- nenhum valor temporal normativo;
- nenhum novo migration;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 formal bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, decidir e especificar o escopo metodológico do próximo bloco de aquisição de evidência temporal não normativa, escolhendo entre plano transversal reutilizável + instância piloto versus plano inicialmente específico de um target.**


### CP111 — segundo Evidence Readiness real

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP111.md`;
- ponteiro de continuidade movido para CP111;
- segundo readiness assessment real concluído no N2/dCBT-I;
- resultado = **INSUFFICIENT_EVIDENCE**;
- READY_FOR_CALIBRATION = **NO**;
- dois contexts reais A2/published agora avaliados;
- blockers temporais centrais recorrentes em N1/N2;
- diversidade de fontes de produção não substitui source characterization temporal ou longitudinal observation;
- terceiro readiness assessment imediato não selecionado;
- próximo problema = desenho de aquisição temporal não normativa;
- nenhum Calibration Dossier real autorizado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir em modo alto entre plano transversal reutilizável + instância piloto e plano inicialmente target-specific;
- pausa obrigatória preservada.


### Fase 4 — arquitetura de aquisição de evidência temporal não normativa

Documentos:
- `docs/governance/51-arquitetura-aquisicao-evidencia-temporal-nao-normativa-v01.md`;
- `docs/governance/52-gate-adversarial-arquitetura-aquisicao-evidencia-temporal.md`;
- `docs/governance/53-recheck-final-arquitetura-aquisicao-evidencia-temporal.md`.

Decisão:
> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **ARCHITECTURE_CHOICE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

> **FIRST_OBSERVATION_INSTANCE = AUTHORIZED_FOR_SELECTION_AND_SPECIFICATION_ONLY**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

Arquitetura:
- protocolo transversal reutilizável;
- instância target/source-specific;
- Observation Epoch versionado;
- measurement schedule explicitamente não normativo;
- M1 pilot não é Monitor;
- Search só pode registrar Search semanticamente real;
- pre-calibration measurement não é CadenceObservation;
- semantic storage mapping obrigatório;
- latency endpoints e precision explícitos;
- candidate source universe separado de production-search sources;
- authority humana explícita exigida para execução;
- outcome de measurement event multidimensional;
- pilot effort separado de sustainable capacity;
- drift partitioning;
- Result Package deve retornar a novo Evidence Readiness antes de Calibration Dossier;
- physical contract novo apenas se houver lacuna material comprovada.

Gate:
- Documento 52 first pass = **REVISE**;
- Documento 51 hardenizado;
- Documento 53 recheck = **PASS_WITH_ARCHITECTURAL_DECISIONS**.

Estado físico:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = DEFERRED_PENDING_INSTANCE_NEED**

Restrições:
- nenhum source check real autorizado;
- nenhuma measurement schedule em execução;
- nenhum UpdateRiskProfile aprovado fabricado;
- nenhum Calibration Dossier;
- nenhum valor temporal normativo;
- nenhum novo migration;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, selecionar entre N1-01 e N2/dCBT-I o primeiro exact target da Temporal Observation Plan Instance e especificar a instância completa, sem executar observação real.**


### CP112 — arquitetura de aquisição temporal não normativa

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP112.md`;
- ponteiro de continuidade movido para CP112;
- arquitetura de aquisição temporal = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- escolha = protocolo transversal reutilizável + instância target/source-specific;
- primeira instância = autorizada apenas para seleção/especificação;
- observação prospectiva real = não autorizada;
- semantic storage mapping, Observation Epoch e authority humana explícita obrigatórios;
- M1 pilot não é Monitor;
- pre-calibration measurement não é CadenceObservation;
- physical contract novo fica deferido até lacuna material comprovada;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: selecionar N1-01 ou N2/dCBT-I e especificar a primeira Temporal Observation Plan Instance, em modo alto, sem execução;
- pausa obrigatória preservada.


### Fase 4 — seleção e especificação da primeira Temporal Observation Plan Instance

Documentos:
- `docs/governance/54-primeira-temporal-observation-plan-instance-n2-dcbti.md`;
- `docs/governance/55-gate-target-specific-topi-n2-dcbti-01.md`;
- `docs/governance/56-pacote-decisao-authority-phase-a-topi-n2-dcbti-01.md`.

Seleção:
> **FIRST_TEMPORAL_OBSERVATION_PLAN_TARGET = N2_RC01_DCBTI_PRODUCTVERSION_1**

> **FIRST_TEMPORAL_OBSERVATION_PLAN_INSTANCE = TOPI_N2_DCBTI_V01**

Racional:
- maior information gain multi-source;
- melhor stress-test de semantic storage e source-specific latency;
- custo operacional maior, mas ainda sem execução;
- authority feasibility semelhante ao N1;
- menor risco de overfitting a um único source ecosystem.

Plano:
- Phase A = source characterization + source-access/data-governance review + semantic storage confirmation + UpdateRiskProfile evidence preparation;
- Phase B = bloqueada até Phase A Result Package + amendment v0.2 + recheck;
- measurement schedule = NOT_SELECTED;
- nenhum intervalo experimental definido antes de source characterization.

Gate target-specific:
> **TARGET_SPECIFIC_GATE = PASS_FOR_AUTHORITY_REQUEST_ONLY**

> **PHASE_A_SPECIFICATION = PASS**

> **PHASE_A_EXECUTION = BLOCKED_PENDING_EXPLICIT_AUTHORITY**

Blockers de execução:
- explicit Phase A execution authority ausente;
- source-access/data-governance review ainda pendente;
- start boundary não satisfeito.

Authority package:
> **AUTHORITY_DECISION = PENDING**

Documento 56 exige decisão explícita APPROVED / REVISE / REJECTED vinculada à Phase A / TOPI-N2-DCBTI-01.

Restrições:
- nenhuma source interaction real antes da decisão;
- Phase B bloqueada;
- nenhum Monitor/MonitoringCycle;
- nenhum cadence/UpdatePolicy/Calibration Dossier;
- nenhum valor temporal normativo;
- nenhum scheduler/notifications/auto-escalation;
- nenhum novo migration;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **obter decisão humana explícita sobre o Documento 56.**


### CP113 — primeira TOPI e authority decision

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP113.md`;
- ponteiro movido para CP113;
- N2/dCBT-I selecionado como primeiro target;
- TOPI-N2-DCBTI-01 v0.1 especificada;
- target-specific gate = **PASS_FOR_AUTHORITY_REQUEST_ONLY**;
- Phase A specification = PASS;
- Documento 56 criado para decisão explícita de authority;
- `AUTHORITY_DECISION = PENDING`;
- Phase A execution = não autorizada;
- Phase B bloqueada;
- measurement schedule = não selecionada;
- nenhuma source interaction real autorizada antes da decisão;
- nenhum valor temporal normativo/migration nova autorizado;
- Fase 5 não iniciada;
- próximo passo: aguardar APPROVED / REVISE / REJECTED explicitamente vinculado à Phase A / Documento 56 / TOPI-N2-DCBTI-01;
- alta complexidade arquitetural deste bloco encerrada; modo médio suficiente após decisão, salvo nova questão complexa;
- pausa obrigatória preservada.


### Fase 4 — authority registrada e Phase A da TOPI-N2-DCBTI-01 concluída

Documentos:
- `docs/governance/57-registro-decisao-authority-phase-a-topi-n2-dcbti-01.md`;
- `docs/governance/58-topi-n2-dcbti-phase-a-characterization-package.md`.

Authority:
> **AUTHORITY_DECISION = APPROVED_FOR_PHASE_A**

> **PHASE_A_OPERATIONAL_EXECUTION_AUTHORITY = GRANTED**

Decisão explícita do owner:
`Approved - phase A / documento 56 / TOPI-N2-DCBTI-01`.

Phase A:
> **PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS**

Source characterization:
- PubMed = `SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_CONTROLS`;
- BVS/LILACS = `PARTIAL`;
- ClinicalTrials.gov = `SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_RUNTIME_CONNECTIVITY_CHECK`.

Achados:
- PubMed possui E-utilities e datas CRDT/EDAT úteis para observability; updates de corpus são documentados como diários, sem implicar latency individual fixa;
- BVS/LILACS possui IAHx/FI-Admin e modelo com creation/change dates, mas acesso programático público reproduzível não foi estabelecido nesta Phase A;
- ClinicalTrials.gov possui API v2 REST/OpenAPI/JSON e posting-date fields adequados para observar processo registral;
- falhas de abertura por ferramenta foram classificadas como `TOOL_MEDIATED / FAILURE_ATTRIBUTION_UNKNOWN`, nunca como source outage.

Data governance:
- PubMed = PASS_WITH_CONTROLS;
- BVS/LILACS = metadata characterization permitida, Phase B access unresolved;
- ClinicalTrials.gov = PASS_WITH_CONTROLS.

UpdateRiskProfile:
> **EVIDENCE_PREPARATION_ONLY**

Nenhum rating A1–A5/B1–B5 foi declarado authoritative.

Measurement:
> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B = NOT_AUTHORIZED**

Physical contract:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_REQUIRED_FOR_PHASE_A**

Necessidade de event object específico para Phase B = unresolved.

Restrições:
- nenhuma repeated prospective measurement executada;
- nenhuma cadence/Monitor/UpdatePolicy/Calibration Dossier;
- nenhum valor temporal normativo;
- nenhum novo migration;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, especificar Plan Amendment v0.2 da TOPI-N2-DCBTI-01 com source inclusion, Phase B event model, storage mapping e eventual measurement schedule non-normative; depois novo target-specific gate e nova authority antes de Phase B.**


### CP114 — TOPI Phase A characterization

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP114.md`;
- ponteiro movido para CP114;
- owner approval da Phase A registrada no Documento 57;
- Phase A Characterization Package = Documento 58;
- `PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS`;
- PubMed = sufficient for Phase B design with controls;
- BVS/LILACS = partial / programmatic path unresolved;
- ClinicalTrials.gov = sufficient for Phase B design with runtime connectivity check;
- UpdateRiskProfile = evidence-preparation only;
- measurement schedule = NOT_SELECTED;
- Phase B = NOT_AUTHORIZED;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: Plan Amendment v0.2;
- modo alto recomendado novamente para source inclusion / schedule / possible physical-event decision;
- pausa obrigatória preservada.


### Fase 4 — TOPI Plan Amendment v0.2 e boundary da Phase B

Documentos:
- `docs/governance/59-topi-n2-dcbti-plan-amendment-v02-phase-b-boundary.md`;
- `docs/governance/60-recheck-target-specific-topi-v02-phase-b-boundary.md`.

Plan Amendment:
> **PLAN_VERSION = V0_2_CANDIDATE_RECHECKED**

Source inclusion:
> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

Event model:
> **PHASE_B_EVENT_MODEL = SOURCE_SPECIFIC_NON_NORMATIVE_MEASUREMENT_EVENT**

Physical finding:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

A lacuna física foi confirmada porque:
- `artifact.artifact` normaliza metadata de arquivo, não event semantics;
- `investigation.search` só é válido para Search científica real;
- `maintenance.evidence_event` exige MonitoringCycle;
- `maintenance.cadence_observation` exige CadenceObligation;
- repeated experimental measurement requer planned opportunities, missingness, source-specific outcomes, failure attribution e replay estruturado.

Measurement schedule:
> **MEASUREMENT_SCHEDULE = DEFERRED_PENDING_PHYSICAL_CONTRACT**

Nenhum número foi selecionado.

Recheck:
> **TOPI_N2_DCBTI_V02_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

O PASS autoriza somente specification do physical contract e test plan.

Restrições:
- Phase B authority não solicitada;
- Phase B execution não autorizada;
- migration não autorizada;
- cadence/UpdatePolicy/Calibration Dossier não autorizados;
- normative temporal values não autorizados;
- scheduler/notifications/auto-escalation não autorizados;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, especificar contrato físico v0.1 de ObservationEpoch/TemporalMeasurementEvent não normativos, com constraints, lifecycle, replay/readiness views e test plan; depois gate adversarial antes de qualquer migration.**


### CP115 — TOPI v0.2 / Phase B boundary

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP115.md`;
- ponteiro movido para CP115;
- Plan Amendment v0.2 rechecked = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- PubMed + ClinicalTrials.gov = included candidates da Phase B;
- BVS/LILACS = deferred source debt;
- event model = source-specific non-normative measurement event;
- physical gap = confirmed;
- non-normative physical contract = authorized for specification only;
- measurement schedule = deferred pending physical contract;
- Phase B authority = not requested;
- Phase B execution = not authorized;
- migration = not authorized;
- nenhum valor temporal normativo autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: contrato físico v0.1 de ObservationEpoch/TemporalMeasurementEvent + test plan + gate adversarial;
- modo alto permanece recomendado;
- pausa obrigatória preservada.


### Fase 4 — contrato físico v0.1 de aquisição temporal não normativa

Documentos:
- `docs/governance/61-contrato-fisico-aquisicao-temporal-nao-normativa-v01.md`;
- `docs/governance/62-gate-adversarial-contrato-fisico-aquisicao-temporal-v01.md`;
- `docs/governance/63-recheck-final-contrato-fisico-aquisicao-temporal-v01.md`.

First pass:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REVISE**

Hardening incorporado:
- execution/item/timepoint separation;
- OpportunityResolution append-only;
- count/novelty semantics;
- direct failure-evidence locator;
- recursive anti-normative JSON guard;
- data-driven runtime connectivity;
- source time-semantics registry;
- retry closure;
- no early completion;
- target drift;
- authority resolver;
- frozen measurement Investigation;
- baseline/novelty semantics;
- latency derived from item timepoints;
- strict effort payload;
- Artifact liveness;
- finite frozen opportunity set;
- explicit source debt;
- no reuse of `maintenance.contract_epoch`;
- migration/fixture separation.

Final recheck:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHYSICAL_SCHEMA = READY_FOR_MIGRATION_DECISION**

> **TEST_PLAN = READY_FOR_IMPLEMENTATION_IF_MIGRATION_AUTHORIZED**

Root physical objects:
- temporal_observation_plan;
- temporal_observation_source;
- temporal_observation_epoch;
- temporal_observation_epoch_source;
- temporal_observation_authority;
- temporal_measurement_opportunity;
- temporal_measurement_event;
- temporal_measurement_opportunity_resolution;
- temporal_measurement_item;
- temporal_measurement_item_timepoint;
- temporal_measurement_event_artifact;
- temporal_observation_deviation.

Test plan:
> **TNO-T01–T90 specified**

Migration:
> **MIGRATION_033 = ELIGIBLE_FOR_SEPARATE_AUTHORIZATION**

> **MIGRATION_033 = NOT_YET_AUTHORIZED**

Measurement:
> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

Restrições:
- zero seed real;
- nenhum numeric schedule;
- nenhum normative temporal value;
- nenhum Monitor/CadenceContract/UpdatePolicy binding;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, decidir autorização e boundary técnico da candidate migration 033, incluindo decomposição de arquivos, testes/fixtures, CI e no-seed guarantee.**


### CP116 — contrato físico v0.1 final PASS

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP116.md`;
- ponteiro movido para CP116;
- contrato físico v0.1 = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- physical schema = ready for migration decision;
- test plan TNO-T01–T90 = ready if migration authorized;
- migration 033 = eligible for separate authorization;
- migration 033 ainda não autorizada;
- schedule = finite frozen opportunity-set contract, mas nenhum timestamp real selecionado;
- measurement schedule = NOT_SELECTED;
- Phase B authority = not requested;
- Phase B execution = not authorized;
- nenhum normative temporal value autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir migration 033 e boundary técnico em modo alto;
- implementação mecânica poderá voltar a modo médio após autorização/boundary;
- pausa obrigatória preservada.


### Fase 4 — autorização e boundary técnico da migration 033

Documento:
- `docs/governance/64-autorizacao-boundary-tecnico-migration-033.md`.

Decisão:
> **MIGRATION_033 = AUTHORIZED_FOR_IMPLEMENTATION**

Boundary:
> **INFRASTRUCTURE_ONLY / SYNTHETIC_TESTS_ONLY / ZERO_REAL_SEED**

Decomposição autorizada:
- `033_non_normative_temporal_observation.sql`;
- `033a_temporal_observation_core.sql`;
- `033b_temporal_measurement_core.sql`;
- `033c_temporal_observation_guards.sql`;
- `033d_temporal_observation_helpers_views.sql`;
- `033e_temporal_observation_issue_validators.sql`.

Testes autorizados:
- `f4-temporal-observation-fixtures.sql`;
- `f4-temporal-observation-smoke-tests.sql`;
- `f4-temporal-observation-tests.sql`.

CI:
- integrar ao workflow canônico `.github/workflows/validate-s5.yml`;
- adicionar path triggers, hashes, install 033, smoke, synthetic fixtures/tests, idempotency, rebuild e regressions;
- logs prefixados `F4-TNO`.

Decisões técnicas:
- master + fragments, coerente com migrations 031/032;
- não criar workflow paralelo;
- não reutilizar `maintenance.contract_epoch`;
- rollback operacional = rebuild-from-zero;
- no-seed guarantee obrigatória;
- normative isolation guarantee obrigatória.

Restrições preservadas:
- measurement schedule = NOT_SELECTED;
- Phase B authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- nenhum real TOPI row/authority/opportunity/event;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, implementar migration 033 + tests + validate-s5 integration e executar CI.**

Modo:
> **modo médio suficiente para implementação mecânica dentro do boundary aprovado; retornar ao modo alto se surgir nova decisão arquitetural/schema/lifecycle.**


### CP117 — autorização da migration 033

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP117.md`;
- ponteiro movido para CP117;
- migration 033 = **AUTHORIZED_FOR_IMPLEMENTATION**;
- boundary = infrastructure-only / synthetic-tests-only / zero-real-seed;
- master + fragments 033a–033e autorizados;
- fixtures/smoke/full tests autorizados;
- integração no `validate-s5.yml` autorizada;
- maintenance.contract_epoch não será reutilizado;
- measurement schedule continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: implementação técnica da 033 em modo médio;
- pausa obrigatória preservada.


### Fase 4 — implementação parcial da migration 033 bloqueada por decisão de schema

Documento:
- `docs/governance/65-blocker-migration-033-frozen-opportunity-set.md`.

Implementação já persistida:
- 033 master;
- 033a core;
- 033b measurement core;
- 033c guards;
- authority resolver hardening.

Estado:
> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = BLOCKED_PENDING_SCHEMA_DECISION**

Blocker:
- o contrato exige finite frozen opportunity set;
- `artifact.artifact` guarda metadados/locator/hash, não o conteúdo JSON;
- PostgreSQL não consegue provar que Opportunity rows correspondem exatamente aos timestamps do Artifact;
- count-only ou validação externa isolada enfraqueceriam replay/integridade.

Opções registradas:
- A: `opportunity_set_payload jsonb` estruturado em EpochSource;
- B: ampliar Artifact para conteúdo consultável;
- C: nova tabela filha de frozen schedule design;
- D: validação externa apenas — não recomendada.

Recomendação ainda não aprovada:
> **Opção A** como menor expansão arquitetural.

Boundary:
- não continuar 033d/033e;
- não criar fixtures/tests/CI;
- não alterar schema para resolver blocker em modo médio;
- measurement schedule continua NOT_SELECTED;
- Phase B continua não autorizada;
- nenhum valor temporal normativo autorizado.

Próximo passo:
> **modo alto: decidir persistência/enforcement do frozen opportunity set; depois retomar implementação.**


### CP118 — blocker de schema na migration 033

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP118.md`;
- ponteiro movido para CP118;
- migration 033 parcialmente implementada, ainda não validada;
- 033 master/033a/033b/033c persistidos;
- frozen opportunity-set enforcement = unresolved;
- Documento 65 registra opções A–D;
- implementação suspensa antes de 033d/033e/fixtures/tests/CI;
- measurement schedule continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value autorizado;
- próximo passo requer modo alto;
- pausa obrigatória preservada.


### Fase 4 — decisão de schema do frozen opportunity set

Documentos:
- `docs/governance/66-decisao-schema-frozen-opportunity-set-migration-033.md`;
- `docs/governance/67-recheck-decisao-schema-frozen-opportunity-set.md`.

Decisão:
> **SCHEMA_DECISION = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD**

> **SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_ONLY**

> **NEW_TABLE_REQUIRED = NO**

> **NEW_COLUMN_REQUIRED = NO**

O payload canônico usa schema lógico:
> `oes.temporal_opportunity_set/0.1`

Regras:
- finite opportunity set;
- timestamps concretos;
- sem recurrence generator;
- sem opportunity_count redundante;
- opportunity numbers positivos, únicos e contíguos;
- planned_for com offset explícito/Z;
- forbidden temporal keys recursivos;
- payload imutável via EpochSource.

Lifecycle corrigido:
- EpochSource + payload + Opportunity rows em `draft`;
- authorization exige igualdade payload↔rows;
- authority precisa ser posterior/simultânea ao design freeze;
- nenhuma Opportunity nova após saída de draft;
- activation permanece etapa separada.

Artifact:
- `schedule_definition_artifact_uuid` = provenance/rationale;
- não controla lista de timestamps;
- não há dependência do conteúdo externo do Artifact para enforcement.

Test plan:
> **TNO-T01–T100**

Supersession documental:
- Documento 66/67 supersedem apenas as partes do Documento 61/63 relativas ao frozen opportunity set/Artifact;
- sem rewrite retroativo.

Estado da migration:
> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = AUTHORIZED_TO_RESUME_AFTER_CHECKPOINT**

Restrições:
- measurement schedule real continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, retornar a modo médio e corrigir 033c; depois concluir 033d/033e, fixtures, TNO-T01–T100, validate-s5 integration e CI.**


### CP119 — frozen opportunity-set schema decision

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP119.md`;
- ponteiro movido para CP119;
- schema decision = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- canonical frozen opportunity set = `measurement_schedule_payload`;
- schedule Artifact = provenance-only;
- nenhuma tabela/coluna nova necessária;
- Opportunity materialization = draft;
- authority freshness guard obrigatório;
- test plan = TNO-T01–T100;
- migration 033 = partially implemented/not validated;
- implementation autorizada a retomar após checkpoint;
- measurement schedule real continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value autorizado;
- próximo passo: modo médio, corrigir 033c e concluir implementação/CI;
- pausa obrigatória preservada.


### Fase 4 — migration 033 tecnicamente validada

Documento:
- `docs/governance/68-resultado-tecnico-migration-033-observacao-temporal-nao-normativa.md`.

Resultado:
> **MIGRATION_033 = TECHNICALLY_VALIDATED**

> **NON_NORMATIVE_TEMPORAL_OBSERVATION_INFRASTRUCTURE = AVAILABLE_NOT_ACTIVATED_FOR_REAL_TOPI**

> **F4_TNO_TESTS = TNO_T01_TO_T100_PASS**

> **MIGRATION_033_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_033 = PASS**

> **ZERO_REAL_SEED = PASS**

> **NORMATIVE_ISOLATION = PASS**

Implementado:
- 033 master;
- 033a–033e;
- synthetic fixtures;
- smoke tests;
- TNO-T01–T100;
- integração no `validate-s5.yml`.

CI promovida:
- workflow: OES PoC-S5 PostgreSQL Validation;
- run: `37802083791`;
- run number: `214`;
- validated HEAD: `6b9efb3a2439aa700fe8b38334995cf008327fb5`;
- conclusion: `success`;
- artifact ID: `11560209688`;
- artifact: `oes-s5-evidence-37802083791`;
- digest: `sha256:fc2909171dfa16f94cccae8cc5bd739b11c6091c4b04bb3ad78136af4ecd0c6b`.

Invariantes:
- frozen opportunity set canônico = `measurement_schedule_payload`;
- schedule Artifact = provenance-only;
- Opportunity materialization = draft;
- authority freshness guard ativo;
- latency derivada de item timepoints;
- source debt preservado;
- nenhum scheduler/recurrence generator;
- nenhuma ligação causal normativa 032.

Restrições:
- TOPI real ainda não materializada;
- measurement schedule real = NOT_SELECTED;
- Phase B authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, definir o desenho experimental finito da Phase B da TOPI-N2-DCBTI-01 antes de qualquer materialização/authority real.**


### CP120 — migration 033 technical PASS

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP120.md`;
- ponteiro movido para CP120;
- migration 033 = TECHNICALLY_VALIDATED;
- infrastructure = available, not activated for real TOPI;
- TNO-T01–T100 = PASS;
- idempotency = PASS;
- rebuild-through-033 = PASS;
- prior regressions = PASS;
- zero-real-seed = PASS;
- normative isolation = PASS;
- promoted CI run = 37802083791 / run 214;
- validated HEAD = `6b9efb3a2439aa700fe8b38334995cf008327fb5`;
- evidence artifact = `11560209688`;
- digest = `sha256:fc2909171dfa16f94cccae8cc5bd739b11c6091c4b04bb3ad78136af4ecd0c6b`;
- TOPI-N2 real materialization = NOT_AUTHORIZED;
- measurement schedule = NOT_SELECTED;
- Phase B authority/execution = NOT_AUTHORIZED;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: modo alto para desenho experimental finito da Phase B;
- pausa obrigatória preservada.


### Fase 4 — desenho experimental finito da Phase B / TOPI-N2-DCBTI-01

Documentos:
- `docs/governance/69-desenho-experimental-finito-phase-b-topi-n2-dcbti.md`;
- `docs/governance/70-recheck-desenho-experimental-phase-b-topi-n2-dcbti.md`;
- `docs/governance/71-pacote-authority-preparacao-phase-b-topi-n2-dcbti.md`.

Decisão:
> **PHASE_B_EXPERIMENTAL_DESIGN = FINITE_IRREGULAR_SOURCE_SPECIFIC_OPPORTUNITY_SET**

> **TOPI_N2_DCBTI_V02_FINAL_DESIGN = READY_FOR_PREPARATION_AUTHORITY_REQUEST**

Candidate Epoch:
- code: `B1`;
- start boundary: `2026-10-19T08:00:00-03:00`;
- review boundary: `2026-11-10T18:00:00-03:00`;
- timezone: `America/Recife`.

PubMed:
- included candidate;
- 8 finite opportunities;
- planned at 09:00 -03 on 2026-10-19, 10-20, 10-22, 10-26, 10-29, 11-03, 11-06, 11-09;
- measurement strategy = fixed union of historical review + RCT discovery scopes;
- no relative date query;
- first successful event = epoch baseline acquisition, not scientific novelty.

ClinicalTrials.gov:
- included candidate;
- 6 finite opportunities;
- planned at 10:30 -03 on 2026-10-19, 10-22, 10-27, 10-30, 11-04, 11-09;
- query semantics preserved from historical case;
- actual API request/parameterization must be frozen after connectivity verification.

BVS/LILACS:
> **DEFERRED_SOURCE_DEBT**

Architectural ordering:
1. preparation authority;
2. minimal runtime connectivity probes;
3. Artifact/query/interface freeze;
4. real draft materialization;
5. design_frozen_at;
6. new Phase B execution authority package;
7. owner decision after freeze;
8. authority row;
9. authorized_non_normative;
10. active;
11. measurement execution.

Reason:
- `runtime_connectivity_status` is immutable in EpochSource;
- execution authority must satisfy `decided_at >= design_frozen_at`.

Recheck:
> **TOPI_N2_DCBTI_PHASE_B_DESIGN_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

Current authority package:
> **DOCUMENT_71 = AWAITING_EXPLICIT_OWNER_DECISION**

Current restrictions:
- generic `Prossiga` is not authority;
- runtime connectivity probes = NOT_AUTHORIZED;
- real TOPI draft materialization = NOT_AUTHORIZED;
- design_frozen_at = NOT_ESTABLISHED;
- Phase B execution authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- normative temporal values = NOT_AUTHORIZED;
- M3 blocked;
- Phase 5 not started.

Schedule expiry:
- if preparation + draft freeze + later execution authority are not completed before first planned opportunity, do not slide dates;
- classify candidate schedule as expired_not_executed and re-version/re-gate.

Next step:
> **aguardar explicit owner decision on Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01.**


### CP121 — Phase B finite design / preparation authority pending

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP121.md`;
- ponteiro movido para CP121;
- Phase B design = finite irregular source-specific;
- PubMed = 8 opportunities;
- ClinicalTrials.gov = 6 opportunities;
- BVS/LILACS = deferred source debt;
- target-specific recheck = PASS_WITH_ARCHITECTURAL_DECISIONS;
- Documento 71 = AWAITING_EXPLICIT_OWNER_DECISION;
- preparation authority = PENDING;
- runtime connectivity probes = NOT_AUTHORIZED;
- real TOPI draft materialization = NOT_AUTHORIZED;
- design_frozen_at = NOT_ESTABLISHED;
- Phase B execution authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- normative temporal values = NOT_AUTHORIZED;
- M3 blocked;
- Phase 5 not started;
- next step = explicit owner decision on Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01;
- generic Prossiga is not authority;
- mandatory pause preserved.


### Fase 4 — Phase B preparation concluída; execution authority pendente

Documentos:
- `docs/governance/72-registro-authority-preparacao-phase-b-topi-n2-dcbti.md`;
- `docs/governance/73-resultado-probes-conectividade-preparacao-phase-b-topi-n2-dcbti.md`;
- `docs/governance/74-resultado-preparacao-phase-b-topi-n2-dcbti.md`;
- `docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md`.

Estado:
> **PREPARATION_AUTHORITY = APPROVED_AND_EXECUTED**

> **RUNTIME_CONNECTIVITY = VERIFIED_FOR_B1_INTERFACES**

> **REAL_TOPI_DRAFT_MATERIALIZATION = COMPLETED**

> **TOPI_PREP_TESTS = TOPI_PREP_T01_TO_T30_PASS**

> **OBSERVATION_EPOCH_B1 = DRAFT_FROZEN**

> **DESIGN_FROZEN_AT = 2026-10-08T13:12:23-03:00**

> **PHASE_B_EXECUTION_AUTHORITY = AWAITING_EXPLICIT_OWNER_DECISION**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT = 0**

Connectivity evidence:
- run `37806308031` / run 215 = success;
- PubMed E-utilities = VERIFIED;
- ClinicalTrials.gov API v2 = VERIFIED;
- no target-specific query executed;
- evidence artifact `11563182298`;
- digest `sha256:7f01b41e7156993c547e936e53d7cf161490d5768b120de5051c4722fd74284f`.

Draft validation:
- run `37807367640` / run 216 = success;
- validated HEAD `f1034c439082ffdf3f2fbba345daf00b2e2c4a35`;
- TOPI-PREP-T01–T30 = PASS;
- rebuild = PASS;
- evidence artifact `11563323408`;
- digest `sha256:3516f2de565655628ab74ecfe5ad0d48fe33658b7ceb9561e61e1802259b12c8`.

Physical identity:
- Plan UUID `b3100000-0000-0000-0000-000000000001`;
- Epoch B1 UUID `b3120000-0000-0000-0000-000000000001`;
- PubMed EpochSource `b3130000-0000-0000-0000-000000000001`;
- ClinicalTrials.gov EpochSource `b3130000-0000-0000-0000-000000000002`;
- PubMed opportunities = 8;
- ClinicalTrials.gov opportunities = 6;
- BVS/LILACS = deferred source debt.

Execution boundary:
- Documento 75 awaits explicit owner decision;
- generic `Prossiga` is not execution authority;
- no transition to authorized_non_normative;
- no transition to active;
- no MeasurementEvent;
- no OpportunityResolution;
- no normative temporal values;
- M3 blocked;
- Phase 5 not started.

Next step:
> **await explicit owner decision: APPROVED / REVISE / REJECTED — Phase B execution / Documento 75 / TOPI-N2-DCBTI-01 / Epoch B1.**


### CP122 — B1 draft frozen / execution authority pending

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP122.md`;
- ponteiro movido para CP122;
- preparation authority = APPROVED_AND_EXECUTED;
- runtime connectivity PubMed/ClinicalTrials.gov = VERIFIED;
- real TOPI Plan v2 + Epoch B1 draft materialization = COMPLETED;
- TOPI-PREP-T01–T30 = PASS;
- rebuild reproducibility = PASS;
- design_frozen_at = `2026-10-08T13:12:23-03:00`;
- Plan UUID = `b3100000-0000-0000-0000-000000000001`;
- Epoch B1 UUID = `b3120000-0000-0000-0000-000000000001`;
- PubMed opportunities = 8;
- ClinicalTrials.gov opportunities = 6;
- BVS/LILACS = deferred source debt;
- Documento 75 = AWAITING_EXPLICIT_OWNER_DECISION;
- Phase B execution authority = PENDING;
- Phase B execution = NOT_AUTHORIZED;
- MeasurementEvent count = 0;
- no normative temporal values;
- M3 blocked;
- Phase 5 not started;
- generic Prossiga is not execution authority;
- mandatory pause preserved.


### Fase 4 — Phase B execution authority validada; B1 autorizado e não ativo

Documentos:
- `docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md` — owner decision recorded;
- `docs/governance/76-resultado-authority-execucao-phase-b-topi-n2-dcbti.md`.

Estado:
> **PHASE_B_EXECUTION_AUTHORITY = APPROVED_AND_VALIDATED**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Owner decision:
- decided_at `2026-10-08T13:31:42-03:00`;
- design_frozen_at `2026-10-08T13:12:23-03:00`;
- authority freshness = PASS.

Physical authority:
- authority UUID `b3150000-0000-0000-0000-000000000001`;
- Plan UUID `b3100000-0000-0000-0000-000000000001`;
- Epoch UUID `b3120000-0000-0000-0000-000000000001`;
- domain `operational_execution`;
- decision `approved`;
- actor type `owner`;
- decision Artifact UUID `b3000000-0000-0000-0000-000000000012`.

Activation hardening:
- migration `034_temporal_observation_activation_chronology.sql`;
- active transition requires persisted `started_at` before first Opportunity;
- authority must already be approved at `started_at`;
- material/invalidating deviation blocks activation;
- existing table constraint requires `started_at >= start_boundary_at`;
- B1 factual activation interval = `2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`;
- this is experimental operational chronology, not cadence/SLA.

Validation:
- TACT-T01–T08 = PASS;
- TOPI-AUTH-T01–T15 = PASS;
- migration 034 idempotency = PASS;
- rebuild-through-034 = PASS;
- TOPI authority rebuild = PASS;
- prior regressions = PASS.

Canonical CI:
- workflow run `37815729503`;
- run number `218`;
- validated HEAD `01c7a72d630fb5fb5c8f6eda8c87fdddc8268bb1`;
- conclusion `success`;
- evidence artifact ID `11567660235`;
- digest `sha256:736cb0f552d944bd1e8506a79e48f7dba1f69278bde01ea3d1b5fd554a007fa0`.

Current temporal boundary:
- start boundary `2026-10-19T08:00:00-03:00`;
- first PubMed Opportunity `2026-10-19T09:00:00-03:00`;
- activation on 2026-10-08 = NOT_ALLOWED.

Next act:
> **at/after start boundary and before first Opportunity, execute a live activation preflight; only if all preconditions pass may B1 transition to active.**

Still blocked:
- early activation;
- MeasurementEvent before real opportunity execution;
- schedule mutation/extension;
- Monitor/M2;
- UpdatePolicy/CadenceContract/SLA;
- normative temporal values;
- M3 formalization;
- Phase 5.


### CP123

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP123.md`;
- B1 permanece `authorized_non_normative`;
- `started_at` permanece NULL;
- zero MeasurementEvent;
- próxima ação operacional somente na janela de 19/10/2026 entre 08:00 e 09:00 -03, após preflight;
- modo alto recomendado para ativação e primeiro measurement;
- pausa obrigatória preservada.


### Fase 4 — activation preflight do B1 validado

Documento:
- `docs/governance/77-runbook-activation-preflight-b1-topi-n2-dcbti.md`.

Infraestrutura:
- migration `035_temporal_observation_activation_preflight.sql`;
- função read-only `maintenance.temporal_activation_preflight(epoch, as_of)`;
- função agregadora `maintenance.temporal_activation_preflight_state(epoch, as_of)`.

Resultado:
> **LIVE_PREFLIGHT_IMPLEMENTATION = VALIDATED**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **ACTIVATION_NOW = WAIT / NOT_IN_ACTIVATION_WINDOW**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

Validação determinística:
- APF-T01–T13 = PASS;
- as-of 2026-10-08 14:47 -03 = WAIT;
- as-of 2026-10-19 08:00 -03 = PASS;
- as-of 2026-10-19 08:30 -03 = PASS;
- as-of 2026-10-19 09:00 -03 = FAIL / EXPIRED_NOT_EXECUTED;
- preflight = read-only / zero mutation.

Canonical CI:
- run `37819755672` / run 219 = success;
- validated HEAD `830fcad1e79b237c5c672c5bf8e19aad66d2711f`;
- evidence artifact `11568343046`;
- digest `sha256:73f147fca89833f944b1bbb55fda324afa005bd0f17e9ea3b29fdc46810d906b`;
- rebuild-through-035 = PASS;
- prior regressions = PASS.

Activation discipline:
- factual activation interval remains `2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`;
- activation SQL must be created only after live preflight PASS;
- started_at must be the actual observed activation timestamp, never pre-authored;
- activation itself creates zero MeasurementEvent;
- first actual measurement remains PubMed Opportunity #1 at 2026-10-19 09:00 -03.

Mode:
- HIGH required for live activation + first real measurement;
- no normative temporal values;
- M3 blocked;
- Phase 5 not started.


### CP124 — activation preflight ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP124.md`;
- B1 = `authorized_non_normative`;
- live preflight implementation = VALIDATED;
- current preflight state = WAIT / NOT_IN_ACTIVATION_WINDOW;
- activation SQL = NOT_YET_CREATED;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- run 219 / `37819755672` = success;
- evidence artifact = `11568343046`;
- digest = `sha256:73f147fca89833f944b1bbb55fda324afa005bd0f17e9ea3b29fdc46810d906b`;
- next valid act = live preflight on 2026-10-19 between 08:00 and 09:00 -03;
- high mode required;
- mandatory pause preserved.


### Fase 4 — contrato do primeiro measurement real e harness sintético

Documento:
- `docs/governance/78-contrato-primeiro-measurement-real-harness-sintetico-b1.md`.

Decisão:
> **FIRST_REAL_MEASUREMENT_CONTRACT = SPECIFIED**

> **SYNTHETIC_POST_ACTIVATION_HARNESS = PLANNED_NOT_IMPLEMENTED**

> **NEW_SCHEMA_MIGRATION_REQUIRED = NO**

Semântica consolidada:
- activation permanece separada de measurement;
- primeira successful observation por source = `OBSERVED_EPOCH_BASELINE_ACQUISITION`;
- aggregate `novelty_state = not_applicable`;
- `new_identifier_count = NULL`;
- `new_to_epoch` é propriedade estrutural do epoch, não scientific novelty;
- missed Opportunity não cria MeasurementEvent;
- failure attribution permanece evidence-based;
- nenhuma execução temporal cria UpdateSignal automaticamente;
- nenhuma alteração automática de conclusion/currentness/assurance;
- B1 real não pode ser usado no harness sintético.

Plano técnico:
- suite proposta `FM-T01–T24`;
- arquivo proposto `database/f4-temporal-first-measurement-tests.sql`;
- harness exclusivamente sintético;
- CI sem network call real;
- prova final obrigatória de zero mutation no B1 real.

Estado corrente:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo passo:
> **em modo médio, implementar FM-T01–T24, integrar ao S5 e validar em CI, sem tocar no B1 real.**


### CP125 — first measurement contract specified

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP125.md`;
- Documento 78 = SPECIFIED;
- first real measurement contract = SPECIFIED;
- synthetic post-activation harness = PLANNED_NOT_IMPLEMENTED;
- FM-T01–T24 = planned;
- new schema migration = NOT_REQUIRED;
- B1 permanece `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- próxima ação = implementação sintética em modo médio;
- qualquer necessidade de migration/semântica nova retorna a modo alto;
- pausa obrigatória preservada.


### Fase 4 — hardening físico da semântica do primeiro measurement

Documento:
- `docs/governance/79-hardening-semantica-primeiro-measurement.md`.

Decisão:
> **FIRST_MEASUREMENT_SEMANTICS_HARDENING = REQUIRED**

> **MIGRATION_036_REQUIRED = YES**

> **FM_T06_AND_FM_T08 = BLOCKED_UNTIL_036**

Escopo de supersessão:
- Documento 78 permanece vigente como contrato metodológico;
- Documento 79 supersede apenas a conclusão técnica `NEW_SCHEMA_MIGRATION_REQUIRED = NO`;
- nova conclusão: `NEW_SCHEMA_MIGRATION_REQUIRED = YES — MIGRATION 036`.

Motivo:
- schema atual permite `novelty_state=not_applicable` com `new_identifier_count` não-NULL;
- não existe guard que diferencie primeira successful observation por source de successful observations subsequentes;
- completed event não é obrigado hoje a usar `failure_attribution=not_applicable`.

Hardening definido:
- baseline aggregate é source-specific;
- primeiro completed event por epoch_source exige `novelty_state=not_applicable`, `new_identifier_count=NULL`, `failure_attribution=not_applicable`;
- completed events subsequentes da mesma source não podem usar `not_applicable`;
- partial/failed/indeterminate não estabelecem successful baseline;
- implementation deve ser aditiva em migration 036;
- migrations 033–035 não serão reescritas.

Estado real preservado:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo passo:
> **após checkpoint, modo médio: implementar migration 036 + FM-T01–T24 + integração S5 + idempotência/rebuild/regressões.**


### CP126 — first measurement semantics hardening required

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP126.md`;
- Documento 79 = ARCHITECTURAL_DECISION / IMPLEMENTATION_PENDING;
- Documento 78 permanece vigente como contrato metodológico;
- conclusão `NEW_SCHEMA_MIGRATION_REQUIRED = NO` do Documento 78 foi supersedida;
- migration 036 = REQUIRED;
- baseline aggregate = source-specific;
- FM-T06/FM-T08 bloqueados até hardening;
- B1 permanece `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- próximo passo = modo médio para migration 036 + FM-T01–T24 + S5 + rebuild/regressões;
- pausa obrigatória preservada.


### Fase 4 — migration 036 e first-measurement harness validados

Documento:
- `docs/governance/80-resultado-migration-036-first-measurement-fm.md`.

Resultado:
> **MIGRATION_036 = TECHNICALLY_VALIDATED**

> **FM_T01_TO_T24 = PASS**

> **MIGRATION_036_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_036 = PASS**

> **REAL_B1_NON_MUTATION = PASS**

CI canônica:
- run `37829798269` / run 222 = success;
- validated HEAD `59225572679ebb0e446956a030f54e700614419a`;
- artifact `11572917207`;
- digest `sha256:a5d01a58f60e1a4424c24753d9a65290a18443408525ebfd2e53081d1e03f347`.

Semântica enforced:
- primeiro completed por epoch_source = baseline aggregate;
- `novelty_state=not_applicable`;
- `new_identifier_count=NULL`;
- `failure_attribution=not_applicable`;
- completed subsequente não pode usar `not_applicable`;
- partial/failed/indeterminate não estabelecem successful baseline.

Estado real preservado:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **PHASE_B_EXECUTION_STARTED = NO**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo ato operacional irreversível:
> **live activation preflight em 2026-10-19, 08:00–09:00 -03, modo alto.**


### CP127 — migration 036 / first-measurement harness validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP127.md`;
- migration 036 = TECHNICALLY_VALIDATED;
- FM-T01–T24 = PASS;
- F4-FM-IDEM = PASS;
- F4-FM-REBUILD = PASS;
- Documento 80 registra o resultado técnico;
- run 222 / `37829798269` = success;
- evidence artifact `11572917207`;
- digest `sha256:a5d01a58f60e1a4424c24753d9a65290a18443408525ebfd2e53081d1e03f347`;
- B1 permanece `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- nenhuma source query real foi executada;
- próximo ato irreversível = live activation preflight em 2026-10-19, 08:00–09:00 -03, modo alto;
- pausa obrigatória preservada.


### Fase 4 — pre-execution readiness do B1 auditado

Documento:
- `docs/governance/81-auditoria-readiness-pre-execucao-b1.md`.

Resultado:
> **B1_PRE_EXECUTION_PACKAGE = READY**

> **PRE_EXECUTION_READINESS = PASS**

> **WAIT_FOR_ACTIVATION_WINDOW = YES**

Auditoria confirmou:
- frozen Plan/design/source/query/interface/schedule artifacts presentes;
- activation path validado;
- first-measurement path validado;
- migration 036 + FM-T01–T24 = PASS;
- deferred BVS/LILACS debt continua visível;
- nenhum scheduler/cron de activation;
- B1 permanece sem mutation.

Gap operacional corrigido:
- S5 artifact retention = 30 → 60 dias;
- run 223 / `37830560002` = success;
- validated HEAD `da18477e1f754e9c27794c851d6be2909c63e039`;
- artifact `11573131877`;
- digest `sha256:8eb1763d0b21a06628766a89c26019a7e1e8eb2beaa549ae8616b63f4dc1247d`;
- expiry `2026-12-07T19:16:09Z`;
- retenção cobre review boundary de 2026-11-10.

Estado real:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **PHASE_B_EXECUTION_STARTED = NO**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo ato:
> **aguardar janela de 2026-10-19 08:00–09:00 -03; live activation preflight em modo alto.**


### CP128 — B1 pre-execution readiness PASS

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP128.md`;
- Documento 81 = PRE_EXECUTION_READINESS_PASS;
- B1_PRE_EXECUTION_PACKAGE = READY;
- run 223 / `37830560002` = success;
- evidence artifact `11573131877`;
- digest `sha256:8eb1763d0b21a06628766a89c26019a7e1e8eb2beaa549ae8616b63f4dc1247d`;
- expiry `2026-12-07T19:16:09Z`;
- S5 retention = 60 days;
- retention covers B1 review boundary;
- B1 remains `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- next irreversível act = 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — defeito de parametrização ClinicalTrials.gov reconciliado arquiteturalmente

Documento:
- `docs/governance/82-reconciliacao-parametrizacao-clinicaltrials-b1.md`.

Resultado:
> **CLINICALTRIALS_EXACT_REQUEST_PARAMETERIZATION = NOT_ACTUALLY_FROZEN**

> **CP128_PRE_EXECUTION_READY_CLAIM = SUPERSEDED_BY_DOCUMENT_82**

> **CURRENT_B1_ACTIVATION_GOVERNANCE_STATUS = BLOCKED**

> **CORRECTIVE_ARCHITECTURE = REPLACEMENT_EPOCH_B1R1_UNDER_PLAN_V2**

Decisão arquitetural:
- não corrigir artifact congelado in place;
- não usar runbook suplementar como substituto de design freeze;
- não criar Plan v3 neste momento;
- invalidar B1 somente após corrective preparation authority explícita;
- preparar replacement Epoch `B1R1` sob Plan v2;
- preservar start/review boundaries e os mesmos 14 timestamps;
- ClinicalTrials.gov normalized parameters candidatos:
  - `query.cond=insomnia`;
  - `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
  - `format=json`;
  - `pageSize=10`;
  - paginação completa via page token;
- nenhuma query target-specific foi executada.

Authority:
> **CORRECTIVE_PREPARATION_AUTHORITY = REQUIRED**

Formulação requerida:
> **APPROVED — corrective preparation / Documento 82 / TOPI-N2-DCBTI-01 / replace B1 with B1R1**

Enquanto não houver essa decisão:
> **CURRENT_B1 = AUTHORIZED_NON_NORMATIVE_BUT_GOVERNANCE_BLOCKED**

> **CURRENT_B1_ACTIVATION = PROHIBITED**

> **B1R1 = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**


### CP129 — ClinicalTrials request freeze defect / corrective authority required

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP129.md`;
- Documento 82 = CORRECTIVE_PREPARATION_AUTHORITY_REQUIRED;
- current B1 = authorized_non_normative but governance-blocked;
- current B1 activation = PROHIBITED;
- CP128 global readiness claim superseded for execution readiness;
- exact ClinicalTrials.gov request parameterization was not actually frozen before EpochSource materialization;
- selected corrective architecture = replacement Epoch `B1R1` under Plan v2;
- candidate normalized mapping = `query.cond=insomnia` + `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- same boundaries and same 14 timestamps must be preserved;
- current B1 has not been invalidated;
- B1R1 has not been created;
- corrective preparation authority = REQUIRED;
- authority from Documento 75 does not transfer to B1R1;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- next action = await explicit owner corrective preparation decision;
- mandatory pause preserved.


### Fase 4 — corrective preparation B1R1 concluída

Authority:
- Documento 83 = APPROVED / corrective preparation executed.

Resultado:
> **ORIGINAL_B1 = INVALIDATED_WITHOUT_EXECUTION**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_DESIGN_FROZEN_AT = 2026-10-08T19:48:20-03:00**

> **B1R1_EXECUTION_AUTHORITY = PENDING**

> **B1R1_ACTIVATION = NOT_AUTHORIZED**

Corrective connectivity:
- run 224 / `37855302262` = success;
- PubMed E-utilities = VERIFIED;
- ClinicalTrials.gov API v2 = VERIFIED;
- apiVersion = 2.0.5;
- no target-specific query;
- artifact `11583468584`;
- digest `sha256:c0d933ca42961e1f0605751544e603dac33039b1c3d1476dbe187c65925f2e52`.

Corrective materialization:
- Documento 84;
- B1R1 Epoch UUID `b3120000-0000-0000-0000-000000000002`;
- PubMed EpochSource `b3130000-0000-0000-0000-000000000003`;
- ClinicalTrials.gov EpochSource `b3130000-0000-0000-0000-000000000004`;
- same boundaries and same 14 timestamps;
- B1R1-T01–T24 = PASS;
- run 229 / `37855834411` = success;
- validated HEAD `cea4c1a67b7de4537bdf95485146199c86989a48`;
- artifact `11583902320`;
- digest `sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`;
- rebuild = PASS.

Request freeze:
- PubMed interface v2 frozen;
- ClinicalTrials query v2 frozen;
- ClinicalTrials interface v2 frozen;
- logical scientific scope unchanged;
- no schedule sliding.

Novo authority gate:
- Documento 85 = PENDING OWNER DECISION;
- formulação requerida:
  `APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1`.

Estado corrente:
> **B1 = INVALIDATED**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_EXECUTION_AUTHORITY = PENDING**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**


### CP130 — corrective preparation B1R1 PASS

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP130.md`;
- Documento 83 = corrective preparation authority APPROVED/EXECUTED;
- Documento 84 = corrective preparation PASS;
- Documento 85 = execution authority package PENDING OWNER DECISION;
- original B1 = invalidated without execution;
- B1R1 = draft_frozen;
- B1R1 UUID = `b3120000-0000-0000-0000-000000000002`;
- design_frozen_at = `2026-10-08T19:48:20-03:00`;
- run 224 = corrective connectivity PASS;
- run 229 = B1R1-T01–T24 + rebuild PASS;
- run 229 artifact = `11583902320`;
- digest = `sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`;
- B1R1 execution authority = PENDING;
- B1R1 activation = NOT_AUTHORIZED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next action = await explicit owner decision on Documento 85;
- mandatory pause preserved.


### Fase 4 — execution authority do B1R1 aprovada e validada

Documentos:
- `docs/governance/85-pacote-authority-execucao-b1r1.md`;
- `docs/governance/86-decisao-authority-execucao-b1r1.md`;
- `docs/governance/87-resultado-authority-execucao-b1r1.md`.

Decisão:
> **B1R1_EXECUTION_AUTHORITY = APPROVED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **B1R1_ACTIVATION = NOT_STARTED**

Owner decision:
- exact approval: `APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1`;
- decided_at = `2026-10-08T20:26:21-03:00`;
- design_frozen_at = `2026-10-08T19:48:20-03:00`;
- authority ordering = PASS.

Physical authority:
- authority UUID `b3150000-0000-0000-0000-000000000002`;
- decision Artifact UUID `b3000000-0000-0000-0000-000000000017`;
- domain = `operational_execution`;
- decision = `approved`.

Validation:
- B1R1-AUTH-T01–T20 = PASS;
- deterministic preflight:
  - current state = WAIT;
  - 2026-10-19 08:00 -03 = PASS;
  - 2026-10-19 08:30 -03 = PASS;
  - 2026-10-19 09:00 -03 = FAIL;
- run 232 / `37859791833` = success;
- validated HEAD `bfcd493a74e095d1c28974c7a033c5dbf0a08b39`;
- artifact `11585626965`;
- digest `sha256:ea7b831fa6b0d8c2547bb5763e8c0cf0072c6dcabac4e279dd4d7bf10266a0a6`;
- rebuild = PASS.

Current state:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1 started_at = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Next irreversible act:
> **live activation preflight for B1R1 on 2026-10-19 in the 08:00–09:00 -03 interval, high mode.**


### CP131 — B1R1 execution authority approved / activation pending

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP131.md`;
- Documento 85 = authority package;
- Documento 86 = owner APPROVED decision record;
- Documento 87 = APPROVED_AND_VALIDATED / ACTIVATION_PENDING;
- B1 = invalidated;
- B1R1 = authorized_non_normative;
- B1R1 authority UUID = `b3150000-0000-0000-0000-000000000002`;
- B1R1 started_at = NULL;
- B1R1-AUTH-T01–T20 = PASS;
- run 232 / `37859791833` = success;
- evidence artifact `11585626965`;
- digest `sha256:ea7b831fa6b0d8c2547bb5763e8c0cf0072c6dcabac4e279dd4d7bf10266a0a6`;
- rebuild ends with B1 invalidated and B1R1 authorized_non_normative / zero execution;
- activation remains pending the 2026-10-19 08:00–09:00 -03 window;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- M3 remains blocked;
- Phase 5 not started;
- mandatory pause preserved.


### Fase 4 — runbook operacional das medições reais do B1R1 concluído

Documento:
- `docs/governance/88-runbook-operacional-medicoes-reais-b1r1.md`.

Resultado:
> **B1R1_REAL_MEASUREMENT_RUNBOOK = READY**

Escopo coberto:
- preflight imediato por Opportunity;
- request PubMed congelada;
- request ClinicalTrials.gov congelada;
- completude/paginação;
- baseline semantics source-specific;
- raw/materialized/new counts;
- MeasurementItem/item_state;
- timepoints;
- execution Artifacts;
- failure attribution;
- execution status;
- retries;
- OpportunityResolution;
- deviations;
- effort payload;
- transação/pós-validação;
- anti-backfill;
- clock discipline;
- scientific triage boundary;
- primeira Opportunity PubMed e ClinicalTrials.gov.

Nenhuma mudança metodológica/schema:
> **NEW_ARCHITECTURAL_DECISION = NO**

> **NEW_MIGRATION_REQUIRED = NO**

Estado operacional preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

Próximo ato irreversível:
> **19/10/2026, 08:00–09:00 -03: live activation preflight do B1R1 em modo alto.**


### CP132 — B1R1 real measurement runbook ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP132.md`;
- Documento 88 = READY_FOR_REAL_OPPORTUNITY_EXECUTION / ACTIVATION_STILL_PENDING;
- B1R1 real measurement runbook = READY;
- no new architectural decision;
- no new migration;
- PubMed and ClinicalTrials.gov real execution paths operationally specified;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- no target-specific source query executed;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — protocolo de review/encerramento do B1R1 pré-especificado

Documento:
- `docs/governance/89-protocolo-review-encerramento-b1r1.md`.

Resultado:
> **B1R1_REVIEW_PROTOCOL = PRE_SPECIFIED**

> **B1R1_REVIEW = NOT_STARTED**

> **B1R1_EPOCH_COMPLETION = NOT_ALLOWED_BEFORE_REVIEW_BOUNDARY**

Escopo:
- Opportunity accounting;
- missingness descritiva;
- attempts/retries;
- failure attribution;
- source-specific completeness;
- identifier history;
- aggregate novelty history;
- source timepoints;
- descriptive latency;
- effort;
- deviations;
- deferred source debt;
- cohort/window/denominator;
- evidence cutoff;
- reassessment triggers;
- physical closure preparation;
- review artifact minimum content;
- Evidence Readiness boundary;
- anti-minimum-N;
- anti-favorable-stopping;
- anti-automatic-extension.

Nenhuma decisão normativa:
> **READINESS_ASSESSMENT = NOT_STARTED**

> **CALIBRATION_DOSSIER = NOT_OPEN**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Estado operacional preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP133 — B1R1 review/closure protocol pre-specified

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP133.md`;
- Documento 89 = PRE-SPECIFIED / REVIEW_NOT_STARTED;
- B1R1 review protocol = PRE_SPECIFIED;
- B1R1 review = NOT_STARTED;
- physical completion before review boundary remains prohibited;
- no hidden minimum-N;
- no favorable stopping;
- no automatic extension;
- no automatic READY_FOR_CALIBRATION;
- no Calibration Dossier opened;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — decision tables de contingência do B1R1 pré-especificadas

Documento:
- `docs/governance/90-decision-tables-contingencias-b1r1.md`.

Resultado:
> **B1R1_CONTINGENCY_TABLES = PRE_SPECIFIED**

Cobertura:
- activation WAIT/PASS/FAIL;
- activation expiry;
- target/authority/artifact/connectivity blockers;
- PubMed HTTP/JSON/count/idlist contingencies;
- ClinicalTrials.gov pagination/schema/token contingencies;
- duplicate/reobserved/updated identifiers;
- timepoint missing/date-only;
- retries;
- missed/failed/indeterminate closure;
- partial-without-closure escalation;
- execution delay;
- query/interface/source-scope drift;
- data-governance incidents;
- failure evidence constraints;
- incidental scientific findings;
- mixed source outcomes;
- review-boundary blockers;
- mode escalation rule.

Nenhuma expansão física:
> **NEW_SCHEMA = NO**

> **NEW_MIGRATION = NO**

> **NEW_AUTHORITY = NO**

> **B1R1_STATE_MUTATION = NO**

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP134 — B1R1 contingency decision tables ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP134.md`;
- Documento 90 = PRE-SPECIFIED / CONTINGENCY_READY;
- B1R1 contingency tables = PRE_SPECIFIED;
- no new schema/migration/authority;
- partial-without-completion remains unresolved unless a physically valid closure path exists;
- any need for new closure state returns to high mode;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — runbook de live activation do B1R1 concluído

Documento:
- `docs/governance/91-runbook-live-activation-b1r1.md`.

Resultado:
> **B1R1_ACTIVATION_RUNBOOK = READY**

> **DOCUMENT_91_SUPERSEDES_DOCUMENT_77_OPERATIONALLY_FOR_ACTIVATION**

Documento 77:
> **HISTORICAL_B1_ACTIVATION_RUNBOOK**

Cobertura:
- Freshness Gate;
- hora factual America/Recife;
- live preflight B1R1;
- checks individuais obrigatórios;
- controlling artifacts;
- connectivity/material drift;
- opportunity equality;
- material deviations;
- zero prestart events/resolutions;
- activation artifact factual;
- SQL factual somente pós-PASS;
- post-activation validation;
- checkpoint pós-activation;
- expiry behavior às 09:00;
- handoff para primeira PubMed Opportunity.

Estado atual:
> **LIVE_PREFLIGHT = NOT_YET_RUN**

> **ACTIVATION = NOT_STARTED**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **ACTIVATION_ARTIFACT = NOT_YET_CREATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP135 — B1R1 live activation runbook ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP135.md`;
- Documento 91 = READY_FOR_LIVE_PREFLIGHT / ACTIVATION_NOT_YET_ALLOWED;
- Documento 91 supersede Documento 77 apenas operacionalmente para activation futura;
- Documento 77 permanece histórico;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- live preflight = NOT_YET_RUN;
- activation = NOT_STARTED;
- activation SQL/Artifact factual = NOT_YET_CREATED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — pacote operacional do dia 19 validado

Documento:
- `docs/governance/92-pacote-operacional-dia-19-b1r1.md`.

Read-only live preflight capture:
- `database/f4-topi-n2-dcbti-b1r1-live-preflight-readonly.sql`;
- transaction mode = READ ONLY;
- termina em ROLLBACK;
- sem mutation de Epoch/Event/Resolution.

Resultado:
> **DAY_19_OPERATOR_PACKET = READY**

> **LIVE_PREFLIGHT_CAPTURE_SQL = READY_READ_ONLY**

> **LIVE_PREFLIGHT_CAPTURE_MUTATION = ZERO_BY_CONSTRUCTION_AND_CI_PROOF**

CI:
- run 233 / `37861733122` = success;
- validated HEAD `8e2659ee425c0decde9915b5e43f9efd592692ef`;
- artifact `11586227719`;
- digest `sha256:7e10af6697bd692cf8e078e2916de03f5b4f0a2b25f71e7eebab4c78529b6957`;
- expiry `2026-12-07T23:52:17Z`;
- TOPI-B1R1-LIVE-PREFLIGHT-READONLY = PASS;
- rebuild = PASS.

Estado real preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP136 — day-19 operator packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP136.md`;
- Documento 92 = READY_FOR_DAY_OF_EXECUTION / NO_FACTUAL_ACTIVATION_PRECREATED;
- read-only live preflight capture = READY;
- TOPI-B1R1-LIVE-PREFLIGHT-READONLY = PASS;
- run 233 / `37861733122` = success;
- artifact `11586227719`;
- digest `sha256:7e10af6697bd692cf8e078e2916de03f5b4f0a2b25f71e7eebab4c78529b6957`;
- zero-mutation proof = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — templates de activation e pós-validação do B1R1 prontos

Documento:
- `docs/governance/93-template-activation-checkpoint-b1r1.md`.

Read-only post-activation capture:
- `database/f4-topi-n2-dcbti-b1r1-post-activation-readonly.sql`.

Resultado:
> **ACTIVATION_ARTIFACT_TEMPLATE = READY**

> **POST_ACTIVATION_CHECKPOINT_TEMPLATE = READY**

> **POST_ACTIVATION_READONLY_CAPTURE = READY**

> **FACTUAL_ACTIVATION_DATA = NONE**

CI:
- run 234 / `37862383146` = success;
- validated HEAD `f1c84729c2061a17a317e5c4b62a24456165aa97`;
- artifact `11587035724`;
- digest `sha256:34a8cb17bd339e9cba9986ea11a9e16af672434815c65f672a6255e4500f276d`;
- expiry `2026-12-07T23:59:52Z`;
- TOPI-B1R1-LIVE-PREFLIGHT-READONLY = PASS;
- TOPI-B1R1-POST-ACTIVATION-READONLY = PASS;
- rebuild = PASS.

Estado real preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **ACTIVATION_SQL_FACTUAL = NOT_CREATED**

> **ACTIVATION_ARTIFACT_FACTUAL = NOT_CREATED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP137 — B1R1 activation templates ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP137.md`;
- Documento 93 = TEMPLATE_ONLY / NO_FACTUAL_ACTIVATION_DATA;
- activation Artifact template = READY;
- post-activation checkpoint template = READY;
- post-activation read-only capture = READY;
- run 234 / `37862383146` = success;
- artifact `11587035724`;
- digest `sha256:34a8cb17bd339e9cba9986ea11a9e16af672434815c65f672a6255e4500f276d`;
- both read-only captures = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- factual activation SQL/Artifact = NOT_CREATED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — pacote da primeira measurement PubMed do B1R1 pronto

Documento:
- `docs/governance/94-pacote-primeira-measurement-pubmed-b1r1.md`.

Read-only precheck:
- `database/f4-topi-n2-dcbti-b1r1-first-pubmed-precheck-readonly.sql`.

Resultado:
> **FIRST_PUBMED_OPERATOR_PACKET = READY**

> **FIRST_PUBMED_PRECHECK_READONLY = READY**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **FIRST_MEASUREMENT_EVENT = NOT_CREATED**

CI:
- run 236 / `37864644053` = success;
- validated HEAD `acac8e1a3dd9dc0eac67c9ba4abf8f0d283e78f0`;
- artifact `11586984803`;
- digest `sha256:e66154c429e25defcb1da91ee96e3bdbc2b38fba16cc74c85e858f724f3292a8`;
- expiry `2026-12-08T00:25:42Z`;
- TOPI-B1R1-FIRST-PUBMED-PRECHECK = PASS;
- pre-activation result = NOT_READY;
- baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP138 — first PubMed measurement packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP138.md`;
- Documento 94 = READY_FOR_FIRST_REAL_PUBMED_OPPORTUNITY / NO_SOURCE_QUERY_EXECUTED;
- first PubMed precheck read-only = READY;
- run 236 / `37864644053` = success;
- artifact `11586984803`;
- digest `sha256:e66154c429e25defcb1da91ee96e3bdbc2b38fba16cc74c85e858f724f3292a8`;
- pre-activation state = NOT_READY;
- baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real source query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 activation then first PubMed measurement in high mode;
- mandatory pause preserved.


### Fase 4 — pacote da primeira measurement ClinicalTrials.gov do B1R1 pronto

Documento:
- `docs/governance/95-pacote-primeira-measurement-clinicaltrials-b1r1.md`.

Read-only precheck:
- `database/f4-topi-n2-dcbti-b1r1-first-clinicaltrials-precheck-readonly.sql`.

Resultado:
> **FIRST_CLINICALTRIALS_OPERATOR_PACKET = READY**

> **FIRST_CLINICALTRIALS_PRECHECK_READONLY = READY**

> **CLINICALTRIALS_TARGET_QUERY = NOT_EXECUTED**

> **FIRST_CLINICALTRIALS_MEASUREMENT_EVENT = NOT_CREATED**

CI:
- run 237 / `37865221303` = success;
- validated HEAD `42a69dd48b3fcd3d8ffa252017ab120793cb6ede`;
- artifact `11588041164`;
- digest `sha256:b001ccb1edcc18a91d7327c9c3298b6355d3a4560e9b50924c2ab07b57a9ef54`;
- expiry `2026-12-08T00:32:24Z`;
- TOPI-B1R1-FIRST-CLINICALTRIALS-PRECHECK = PASS;
- pre-activation result = NOT_READY;
- source-specific baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP139 — first ClinicalTrials.gov measurement packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP139.md`;
- Documento 95 = READY_FOR_FIRST_REAL_CLINICALTRIALS_OPPORTUNITY / NO_SOURCE_QUERY_EXECUTED;
- first ClinicalTrials.gov precheck read-only = READY;
- run 237 / `37865221303` = success;
- artifact `11588041164`;
- digest `sha256:b001ccb1edcc18a91d7327c9c3298b6355d3a4560e9b50924c2ab07b57a9ef54`;
- pre-activation state = NOT_READY;
- source-specific baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real PubMed query = NOT_EXECUTED;
- first real ClinicalTrials.gov query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 activation then first real source measurements in high mode;
- mandatory pause preserved.


### Fase 4 — template de persistência e post-readout das primeiras measurements pronto

Documento:
- `docs/governance/96-template-persistencia-postreadout-primeiras-measurements-b1r1.md`.

Read-only post-readout:
- `database/f4-topi-n2-dcbti-b1r1-first-measurements-postreadout-readonly.sql`.

Resultado:
> **FIRST_MEASUREMENTS_PERSISTENCE_TEMPLATE = READY**

> **FIRST_MEASUREMENTS_POSTREADOUT_READONLY = READY**

> **FACTUAL_MEASUREMENT_DATA = NONE**

> **MEASUREMENT_EVENT_SQL_FACTUAL = NOT_CREATED**

CI:
- run 240 / `37865666856` = success;
- validated HEAD `1b2de6cbdc460aa8fa858a2c23503cadaa327367`;
- artifact `11587648764`;
- digest `sha256:e6a6d891c257172a3aafb47e1caf3a31ec77e0636a68f344f6f06b1dd252047d`;
- expiry `2026-12-08T00:37:43Z`;
- TOPI-B1R1-FIRST-MEASUREMENTS-POSTREADOUT = PASS;
- planned/zero-attempt baseline visible;
- zero mutation = PASS;
- rebuild = PASS.

Intermediário não canônico:
- run 239 falhou apenas por nome incorreto de coluna no read-only deviation query;
- nenhuma mutation ocorreu;
- corrigido em commit `1b2de6cbdc460aa8fa858a2c23503cadaa327367`;
- run 240 supersede tecnicamente o run 239.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP140 — first measurements persistence/post-readout ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP140.md`;
- Documento 96 = TEMPLATE_ONLY / NO_FACTUAL_MEASUREMENT_DATA;
- first measurements persistence template = READY;
- first measurements post-readout read-only = READY;
- run 240 / `37865666856` = success;
- artifact `11587648764`;
- digest `sha256:e6a6d891c257172a3aafb47e1caf3a31ec77e0636a68f344f6f06b1dd252047d`;
- zero mutation = PASS;
- rebuild = PASS;
- run 239 remains non-canonical intermediate read-only failure;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real source query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 in high mode;
- mandatory pause preserved.


### Fase 4 — pacote das Opportunities subsequentes do B1R1 pronto

Documento:
- `docs/governance/97-pacote-opportunities-subsequentes-b1r1.md`.

Read-only readiness matrix:
- `database/f4-topi-n2-dcbti-b1r1-subsequent-opportunities-readiness-readonly.sql`.

Resultado:
> **SUBSEQUENT_OPPORTUNITY_OPERATOR_PACKET = READY**

> **SUBSEQUENT_OPPORTUNITY_READINESS_MATRIX = READY_READ_ONLY**

> **SUBSEQUENT_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **FACTUAL_SUBSEQUENT_MEASUREMENT_SQL = NOT_CREATED**

CI:
- run 241 / `37866002057` = success;
- validated HEAD `bf0ae05b06d2ae4f0e8eea4297147b39c2d496dc`;
- artifact `11588596135`;
- digest `sha256:bc27df73f525774bd43c5484b841d3d72f245c23836820904e4d80ebf7236cff`;
- expiry `2026-12-08T00:41:47Z`;
- TOPI-B1R1-SUBSEQUENT-READINESS = PASS;
- 12 subsequent opportunities visible;
- all NOT_READY in current pre-activation state;
- baseline-if-no-prior-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP141 — subsequent opportunities packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP141.md`;
- Documento 97 = READY_FOR_SUBSEQUENT_OPPORTUNITIES / NO_SOURCE_QUERY_EXECUTED;
- subsequent opportunity readiness matrix = READY_READ_ONLY;
- run 241 / `37866002057` = success;
- artifact `11588596135`;
- digest `sha256:bc27df73f525774bd43c5484b841d3d72f245c23836820904e4d80ebf7236cff`;
- 12 subsequent Opportunities visible;
- all NOT_READY in current pre-activation state;
- baseline-if-no-prior-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first/subsequent real source queries = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 in high mode;
- mandatory pause preserved.


### Fase 4 — audit de prontidão pré-19/10 validado

Documento:
- `docs/governance/98-audit-prontidao-pre-dia19-b1r1.md`.

Read-only audit:
- `database/f4-topi-n2-dcbti-b1r1-pre-day19-readiness-readonly.sql`.

Resultado:
> **PRE_DAY19_READINESS_AUDIT = READY_READ_ONLY**

> **PRE_DAY19_PREPARATION_STATUS = PREPARATION_READY**

> **ACTIVATION_WINDOW_CURRENT_STATE = WAIT**

> **ACTIVATION_ALLOWED_NOW = NO**

CI:
- run 244 / `37926218841` = success;
- validated HEAD `a60ed2f5ab63efaf3354b8511ef3922a888cb25c`;
- artifact `11613929240`;
- digest `sha256:822f753a91f4aefc00f92d5f2c3c1623ed0a0d89694e3144ab5e08d78eaf80d0`;
- expiry `2026-12-08T11:51:21Z`;
- TOPI-B1R1-PRE-DAY19-READINESS = PASS;
- preparation ready = PASS;
- activation window WAIT = PASS;
- zero mutation = PASS;
- rebuild = PASS.

Intermediário não canônico:
- run 243 falhou apenas por uso do nome `check_state` em vez de `check_status` na leitura do preflight;
- nenhuma mutation ocorreu;
- corrigido em `a60ed2f5ab63efaf3354b8511ef3922a888cb25c`;
- run 244 supersede tecnicamente o run 243.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP142 — pre-day19 readiness validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP142.md`;
- Documento 98 = PRE-DAY19 READINESS AUDIT / PREPARATORY ONLY;
- pre-day19 readiness audit = READY_READ_ONLY;
- preparation status = PREPARATION_READY;
- activation window current state = WAIT;
- activation allowed now = NO;
- run 244 / `37926218841` = success;
- artifact `11613929240`;
- digest `sha256:822f753a91f4aefc00f92d5f2c3c1623ed0a0d89694e3144ab5e08d78eaf80d0`;
- zero mutation = PASS;
- rebuild = PASS;
- run 243 remains non-canonical intermediate read-only failure;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real source query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 in high mode;
- mandatory pause preserved.


### Fase 4 — desenho do harness integrado sintético pré-19/10 (Documento 99)

- documento: `docs/governance/99-desenho-harness-integrado-sintetico-pre-dia19-b1r1.md`;
- design sintético dual-source (preflight → activation sintética → attempts/retry → items/timepoints/artifacts → resolutions → replay/review) definido em modo alto;
- harness de integração ainda NÃO implementado nem executado;
- nenhuma nova migration, authority factual ou query real;
- tests propostos ISE-T01–T24 não são PASS;
- estado pre-day19 do CP142 preservado.

> **F4_ISE_DESIGN = DEFINED_NON_NORMATIVE**
> **F4_ISE_IMPLEMENTATION = NOT_STARTED**
> **F4_ISE_CI_PROOF = NOT_AVAILABLE**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP143 — integrated synthetic harness design

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP143.md`;
- Documento 99 = DESIGN_DEFINED / SYNTHETIC_ONLY / NOT_IMPLEMENTED;
- próximo bloco: SQL sintético com ROLLBACK + CI, modo médio após Prossiga e Freshness Gate;
- run 244 permanece evidência pré-existente, não prova do futuro harness;
- B1R1 permanece authorized_non_normative, started_at NULL, zero events/resolutions, activation em WAIT;
- pausa obrigatória preservada.


### Fase 4 — harness integrado sintético dual-source validado (Documento 100)

- arquivo: `database/f4-temporal-integrated-synthetic-harness-tests.sql`;
- CI: `.github/workflows/validate-s5.yml`, step `F4-ISE`;
- cobertura ISE-T01–T24 = 24/24 PASS;
- run 245 / `37933007291` = success, commit validado `af5595d14647df51d076d64081bec1d6a5328c22`;
- job `postgres-s5` = 113828097739, success;
- artifact 11616374106; digest `sha256:ccccba178c51d71f21c56c878c02c333e677e4ae76e14ce087faececd2fe7bb4`;
- ROLLBACK e ausência de resíduos sintéticos = PASS;
- fingerprints B1/B1R1 e contagens operacionais/normativas pré/pós = iguais;
- PRE_DAY19_PREPARATION_STATUS continua PREPARATION_READY, activation window WAIT;
- nenhuma source query factual, nenhum event/resolution B1/B1R1 criado;
- Documento 99 permanece histórico: o estado NOT_IMPLEMENTED nele descreve a época do desenho, não o presente.

> **F4_ISE_IMPLEMENTATION = DONE**
> **F4_ISE_TECHNICAL_VALIDATION = PASS**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP144 — integrated synthetic harness validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP144.md`;
- Documento 100 registra PASS técnico real do harness sintético;
- próximo bloco opcional: decisão em modo alto para contratos offline PubMed/ClinicalTrials.gov;
- próximo ato factual irreversível do B1R1: 19/10/2026 08h–09h America/Recife, sujeito a Freshness Gate/live PASS;
- pausa obrigatória preservada.


### Fase 4 — escopo dos contratos offline de resposta definido (Documento 101)

- documento: `docs/governance/101-decisao-escopo-contratos-offline-respostas-pubmed-clinicaltrials-b1r1.md`;
- decisão em modo alto: desenvolvimento sintético offline de validadores de identidade de request, JSON, cardinalidade, unicidade, paginação, campos mínimos e fail-closed para PubMed ESearch / ClinicalTrials.gov API v2;
- output será relatório técnico `oes.temporal_offline_source_parse_report/0.1`, sem escrita factual ou `MeasurementEvent`;
- matriz OFF-P01–P12, OFF-C01–C16, OFF-X01–X06 = 34 casos propostos, **não executados**;
- interfaces e queries congeladas inalteradas;
- run 245 continua prova do harness ISE anterior, não deste escopo;
- nenhuma source request target-specific, nenhuma activation, nenhum evento B1R1.

> **F4_OFFLINE_SOURCE_SCOPE = APPROVED_FOR_SYNTHETIC_DEVELOPMENT**
> **F4_OFFLINE_SOURCE_IMPLEMENTATION = NOT_STARTED**
> **F4_OFFLINE_SOURCE_CI_PROOF = NOT_AVAILABLE**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP145 — offline source contracts scope decision

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP145.md`;
- próximo bloco em modo médio: implementação dos validadores offline/34 testes e CI, sujeito a Freshness Gate;
- B1R1 mantém PREPARATION_READY, ACTIVATION_WINDOW WAIT e janela factual 19/10;
- pausa obrigatória preservada.


### Fase 4 — contratos offline de fontes validados (Documento 102)

- biblioteca `scripts/temporal_source_offline_contracts.py` e testes `scripts/validate_temporal_source_offline_contracts.py` implementados;
- cenário estritamente offline/sintético: PubMed ESearch + ClinicalTrials.gov API v2;
- 12 testes PubMed, 16 ClinicalTrials.gov e 6 transversais = 34/34 PASS;
- run 248 / `37935448109`, commit validado `6db14ba5107062bec6afa69607c4ff23b23acf7a`, success;
- job `113836220414`, success;
- artifact 11617672877 / digest `sha256:77e26b176458ec70f82333c1ea5149269b2a4ec641c7eb580741876dff7c494d`;
- S5 F4-ISE e rebuild PASS; B1R1 readiness PASS (activation WAIT, zero mutation);
- run 246 falhou na configuração YAML antes dos jobs, reparada; run 247 é intermediária e não canônica;
- frozen artifacts e queries B1R1 inalterados; sem HTTP target-specific, DB writes ou eventos factuais;
- Documento 101 permanece snapshot histórico da decisão original.

> **F4_OFFLINE_SOURCE_IMPLEMENTATION = DONE**
> **F4_OFFLINE_SOURCE_CI_PROOF = PASS**
> **F4_OFFLINE_SOURCE_CASES = 34_OF_34_PASS**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP146 — offline source contracts validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP146.md`;
- Documento 102 = TECHNICALLY_VALIDATED / SYNTHETIC_OFFLINE_ONLY;
- próximo bloco opcional: gate adversarial read-only de fronteira parser/decisão factual em modo alto, somente após Prossiga;
- próximo ato factual B1R1 ainda reservado para 19/10/2026 sob Freshness Gate e live PASS;
- pausa obrigatória preservada.


### Fase 4 — hardening dos contratos offline validado (Documento 103)

- corrigida identidade física dos cinco artefatos congelados via SHA de bytes em disco, não somente pelo SHA declarado;
- corrigida a proveniência das fixtures em memória, sem referência a JSON ausente;
- adicionados OFF-A01–A10; total offline 44/44 PASS;
- run 252 / `37939324857`, job `113849349502`, commit `dbcc79f69bb3ed07306cee5fc05b25eed9bfb2e1`, success;
- artifact `11621145703` / sha256:0aff81c4bf96f477630e40a14f24f040a7820650c5d82d8d1f446b3db50ffb29;
- F4-ISE 24/24 e regressões/rebuild PASS, PRE_DAY19_READY WAIT e zero mutation;
- Documento 103: `docs/governance/103-resultado-hardening-identidade-proveniencia-contratos-offline-b1r1.md`;
- nenhuma mutation B1R1, nenhuma fonte científica consultada; sem ponte automática parser→MeasurementEvent factual.

> **F4_OFFLINE_SOURCE_HARDENING = VALIDATED_SYNTHETIC_ONLY**
> **F4_OFFLINE_SOURCE_CASES = 44_OF_44_PASS**
> **F4_FROZEN_CONTRACT_ATTESTATION = PASS**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP147 — offline identity and provenance hardening

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP147.md`;
- próximo ato factual irreversível segue em 19/10/2026, com live preflight e modo alto;
- pausa obrigatória preservada.

### Fase 4 — impedimento de infraestrutura na janela do B1R1 (Documento 104)

- em 19/10/2026, às 08:00:32 e 08:07:32 America/Recife, relógio factual confirmou janela aberta nos instantes observados;
- Freshness Gate confirmou CP147, HEAD `d53640c76d69755f3c48ae0a39109c545f9b4bef`, run 252 e os cinco blobs congelados;
- o usuário declarou inexistência de instância PostgreSQL operacional persistente;
- o único PostgreSQL identificado no processo técnico é o serviço efêmero dos workflows GitHub Actions;
- live preflight SQL em instância operacional: **NÃO EXECUTADO**; nenhum agregado ou controle individual físico foi observado;
- nenhuma ativação/consulta científica/mutation efetuada; não atribuir estado factual da CI ao ambiente operacional;
- instrução conservadora: não retroagir `started_at`, não mudar os 14 timestamps, não inventar dados experimentais;
- Documento 104 define contenção e requisitos para infraestrutura persistente e futura decisão sobre novo experimento.

> **F4_OPERATIONAL_INFRASTRUCTURE = BLOCKED_NO_PERSISTENT_POSTGRES**  
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **ACTIVATION_WINDOW = OPEN_AT_2026-10-19T08:07:32-03:00_ONLY**  
> **ACTUAL_OPERATIONAL_EVENT_COUNT = NOT_VERIFIABLE_WITHOUT_DATABASE**  
> **PHASE_5 = NOT_STARTED**

### CP148 — bloqueio de infraestrutura registrado

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP148.md`;
- próxima atividade, só após `Prossiga`: gate arquitetural do PostgreSQL persistente, em modo alto, sem deployment automático;
- expiração B1R1 **não** antecipada: exigir verificação factual posterior a 09:00 para declaração final;
- pausa obrigatória.

### Fase 4 — gate arquitetural do banco operacional persistente (Documento 105)

- Freshness Gate confirmou CP148, HEAD `d92a426fcdecfc3392244f8625631d26486a9c09`, sem alterações posteriores e impedimento de datastore persistente não resolvido;
- arquitetura de referência **condicional** para piloto não normativo: PostgreSQL gerenciado persistente + object storage para Artifacts + executor autenticado;
- manter OES-H1/OES-P1, PostgreSQL para core transacional e CI/synthetic completamente segregada;
- shortlist não vinculante: Neon (planos pagos condicionados), Supabase Pro ou superior, AWS RDS; VM autogerida não preferida no piloto;
- **ODB-01–ODB-12** definidos como gates obrigatórios de owner, custo, segurança, migrations, dados, backup/restore e executor;
- nenhum provedor, plano, região, orçamento, credencial, implantação ou novo Epoch aprovado;
- relógio Recife consultado 19/10 às 08:14:15 confirmou janela ainda aberta *naquele instante*; preflight real não executado e nenhuma activation;
- Documento 105: `docs/governance/105-gate-arquitetura-banco-operacional-persistente-oes.md`.

> **PERSISTENT_OPERATIONAL_DB_ARCHITECTURE = APPROVED_WITH_CONDITIONS**
> **PREFERRED_CLASS = MANAGED_POSTGRES_PLUS_OBJECT_STORAGE**
> **PROVIDER_PLAN_REGION_BUDGET = PENDING_OWNER_DECISION**
> **OPERATIONAL_DEPLOYMENT = NOT_AUTHORIZED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

### CP149 — arquitetura candidata de persistência operacional

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP149.md`;
- próximo passo em modo alto, somente após `Prossiga`: seleção responsável de provedor/plano e autorização própria de infraestrutura;
- pausa obrigatória.

### Fase 4 — seleção condicional de infraestrutura gratuita (Documento 106)

- Freshness Gate CP149 confirmado; nenhum commit posterior material identificado antes da decisão;
- preferência do owner: serviço gratuito sempre que satisfizer integralmente ODB-01–ODB-12, sem compromisso de dispêndio;
- **Neon Free** selecionado como candidato prioritário **não contratado/não provisionado**: 1 GB DB, 100 CU-h/mês, restore 6 horas/1 GB e autosuspend após 5 min;
- object storage Neon Free 5 GB em beta é candidato inicial para objetos, insuficiente como cópia independente;
- cópia externa de `pg_dump` e dos artifacts com teste `pg_restore` obrigatório, ainda não implementada; Cloudflare R2 Standard free-tier opcional com necessidade de cadastro de cobrança/risco, não aprovado;
- Supabase Free permanece opção secundária, com 500 MB e risco de pausing, sem backup automático;
- fornecedor/region/security e autorização do owner pendentes, sem acesso factual, sem contrato, sem novos epochs;
- Documento 106: `docs/governance/106-selecao-condicional-piloto-postgresql-gratuito-oes.md`.

> **FREE_FIRST_PRIORITY = APPROVED_AS_USER_PREFERENCE**
> **PREFERRED_CANDIDATE = NEON_FREE**
> **INDEPENDENT_BACKUP = MANDATORY_AND_NOT_CONFIGURED**
> **PROVIDER_OWNER_APPROVAL = PENDING**
> **OPERATIONAL_DEPLOYMENT = NOT_AUTHORIZED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

### CP150 — free-first candidate

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP150.md`;
- próximo bloco: autorização operacional e pacote de configuração Neon Free, modo alto, sem provisionamento automático;
- pausa obrigatória.

### Fase 4 — pacote de autorização de sandbox Neon Free (Documento 107)

- Freshness Gate CP150 / HEAD `b6fe5a242e2e4c5f5ae1ee52f5478c629416fb8d`, sem alterações materiais posteriores à entrada;
- Neon Free mantido como candidato para **sandbox sintético**, ainda sem conta/projeto provisionado;
- região candidata `aws-sa-east-1` / São Paulo: PostgreSQL disponível; Object Storage Neon **indisponível nessa região**;
- informação do Documento 106 sobre Neon Object Storage "beta" **superada** pela GA desde setembro/2026; manter Documento 106 imutável como snapshot histórico;
- formulário textual de autorização específica proposto; `Prossiga` genérico não autoriza aceitar termos ou provisionar recursos;
- conexão segura `sslmode=verify-full`, uso de credenciais fora do repositório/chat e segregação total da CI;
- backup independente e restore/Artifacs (ODB-07/08) não configurados; opções: cópias locais criptografadas em destinos distintos, ou R2 sujeito a risco financeiro e aprovação própria;
- status ODB-01–12: nenhuma comprovação factual de banco operacional; sem criação de Epoch, consulta científica ou mutation;
- Documento 107: `docs/governance/107-pacote-autorizacao-neon-free-sandbox-oes.md`.

> **NEON_FREE_SANDBOX_AUTHORIZATION_PACKAGE = READY**
> **NEON_FREE_SANDBOX = NOT_PROVISIONED**
> **REGION_CANDIDATE = aws-sa-east-1 / UNAPPROVED**
> **NEON_OBJECT_STORAGE_SAO_PAULO = UNAVAILABLE_AS_PUBLISHED**
> **NEON_OBJECT_STORAGE_GA_STATUS = GA_AS_OF_SEPT_2026**
> **BACKUP_INDEPENDENT = NOT_CONFIGURED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

### CP151 — pacote de autorização preparado

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP151.md`;
- próxima etapa: aprovação do owner para sandbox Neon Free/região específica, com testes sintéticos sem despesas;
- pausa obrigatória.

### Fase 4 — autorização específica de Neon Free sandbox (Documento 108)

- proprietário autorizou exatamente `APPROVED — Neon Free sandbox / Documento 107 / OES / synthetic-only / aws-sa-east-1 / no paid services`;
- escopo aprovado: sandbox sintético gratuito na região São Paulo, sem cartão, plano pago, PHI, query científica ou activation de Epoch;
- verificações GitHub CP151 `72bbfc330a23d085d45acc33b7d9f8bb104adede` sem drift; integração Neon disponível, porém **não instalada** neste ChatGPT;
- Documento 108 registra decisão e roteiro manual; script SQL read-only `database/f4-neon-free-sandbox-connectivity-readonly.sql` preparado para primeiro teste;
- nenhum provisionamento efetivo de projeto Neon, nenhuma conexão PostgreSQL, nenhuma migration, nenhum SQL executado;
- backup independente e restore seguem sem configuração, ODB-08 bloqueante; ODB integral não passou;
- próximo bloco condicionado à ação do proprietário no console Neon ou conexão explícita, em modo médio e após `Prossiga`.

> **NEON_FREE_OWNER_SCOPE_APPROVAL = APPROVED**  
> **APPROVED_REGION = aws-sa-east-1**  
> **NEON_FREE_SANDBOX = NOT_PROVISIONED_BY_OES**  
> **NEON_PLUGIN_CONNECTION = NOT_INSTALLED**  
> **NEON_SANDBOX_CONNECTIVITY_TEST = PREPARED_NOT_EXECUTED**  
> **BACKUP_INDEPENDENT = NOT_CONFIGURED**  
> **OPERATIONAL_DB_READINESS = NOT_READY**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **PHASE_5 = NOT_STARTED**

### CP152 — autorização reconhecida, aguardando ação de cadastro

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP152.md`;
- modo médio recomendado após projeto criado; pausa obrigatória.

### CP153 — Primeira conexão Neon Free / Documento 109

- projeto Neon `oes-sandbox` na região aprovada `aws-sa-east-1` observado efetivamente pela integração; PostgreSQL 18.6 e banco `oes_sandbox`;
- branch default `production` apenas nome do provedor, não produção OES;
- `SELECT` read-only executado com sucesso: clock PostgreSQL `2026-10-19T11:59:14.637Z`, role `oes_sandbox_owner`, sem mutation;
- chamada com `BEGIN; SELECT; ROLLBACK` falhou devido a prepared statement de múltiplos comandos, sem side effects;
- Documento 109 em `docs/governance/109-resultado-conectividade-readonly-neon-free-sandbox.md`;
- role owner requer segregação e privilégios mínimos; backup externo, migration ledger e object storage pendentes;
- B1R1 **não ativado** e nenhum measurement factual executado.

> **NEON_FREE_SANDBOX = OBSERVED_ACCESSIBLE**
> **SANDBOX_CONNECTION_READ_ONLY = PASS**
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP153.md`; STOP até `Prossiga`.

### Fase 4 — inventário Neon Free read-only e expiração B1R1 (Documento 110)

- `oes-sandbox` (São Paulo, PostgreSQL 18.6) auditado via SELECT; apenas schema `public`, 0 tabelas e 0 funções de aplicação, `plpgsql` presente; database `oes_sandbox` ~7536 kB;
- role `oes_sandbox_owner` com poderes administrativos, sem role read-only segregada; servidor reportou `ssl=off`, sem conclusão automática sobre TLS externo;
- timestamp PostgreSQL `2026-10-19T12:05:22.721Z` e relógio Recife `2026-10-19T09:05:48-03:00` comprovaram fim da janela, sem preflight/activation válida B1R1; **EXPIRED_NOT_EXECUTED** conforme Documento 91;
- nenhuma migration/DDL/write/fixture ou query científica executada neste checkpoint;
- Documento 110 `docs/governance/110-inventario-readonly-neon-free-e-expiracao-b1r1.md` define preparação de sequência migrations, ledger e branch de teste futura, sem criação ainda;
- ODB-03, ODB-05–10, backup/restore e prontidão operacional continuam bloqueados.

> **NEON_SANDBOX_READONLY_INVENTORY = PASS**
> **B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**
> **OPERATIONAL_DATABASE_READY = NO**
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**
> **PHASE_5 = NOT_STARTED**

### CP154 — inventoried sandbox and B1R1 expiry

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP154.md`;
- próximo passo após `Prossiga`: preparar plano de migrations sintéticas e branch de teste, modo médio;
- pausa obrigatória.

### Fase 4 — preparação de sequência de migrations para branch Neon sintética (Documento 111)

- Freshness Gate CP154 `678a0d8fb007b733e7aa2be10db42d5faceafc7f` consistente; `oes-sandbox` segue sem tabelas de aplicação;
- extraída sequência canônica de 36 arquivos `psql -f` do workflow S5; wrappers 031/032/033 carregam 14 fragmentos por `\ir`;
- manifesto `database/f4-neon-sandbox-schema-migration-manifest.txt` versionado, não executado; Documento 111 fixa gate BRG-01–BRG-10;
- Neon executor `run_sql` não processa `\ir`; preparação exige cliente psql ou executor compatível e hash SHA256 do checkout imutável;
- nenhum branch Neon, role, schema, migration ledger ou seed criado; nenhum dado factual ou source request;
- B1R1 expirado permanece intocado; backup externo ainda não configurado; readiness operacional bloqueado.

> **MIGRATION_SEQUENCE_DOCUMENTED = 36_ENTRY_FILES_14_SUBFRAGMENTS**
> **NEON_TEST_BRANCH = NOT_CREATED**
> **NEON_SCHEMA_MIGRATION = NOT_STARTED**
> **OPERATIONAL_DATABASE_READY = NO**
> **PHASE_5 = NOT_STARTED**

### CP155 — sequência e controles preparados

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP155.md`; pausa obrigatória.



### Fase 4 — Revisão estática do pacote de branch Neon (Documento 112 / CP156)

- Freshness Gate do CP155 confirmou HEAD `097d35b7fc38f81396285798cf314def9bd81aed`, sem drift;
- os 36 arquivos de entrada e os 14 fragmentos `\\ir` foram lidos no GitHub; inspeção estática com limitações, não teste de execução;
- confirmado DML estrutural 031a/032a (epochs, grandfathering), limites transacionais distintos 031–036 e DROP/CREATE TRIGGER em 034;
- proposta de ledger, runner `psql` e gates BRG-01–BRG-10 **não implementados**; SHA-256 de bytes e compatibilidade PG18 ainda pendentes;
- API Neon read-only: projeto `oes-sandbox` na região aprovada e apenas branch default `production`; não criar branch por autorização implícita;
- plano Free publicamente anunciado não substitui checagem factual de saldo, billing e cotas na conta;
- pacote de autorização `create-branch-only` **PREPARED_NOT_APPROVED**, separado de futura autorização de migrations;
- Neon schema/ledger/test branch **NOT_STARTED/NOT_CREATED**, backup independente pendente, B1R1 `EXPIRED_NOT_EXECUTED`, Fase 5 não iniciada;
- próximo passo: pré-gate `psql`/ledger sintético local/CI e quota read-only, sem writes no Neon; pausa obrigatória.


### Fase 4 — Pré-gate offline de migrations Neon e contrato de ledger (Documento 113 / CP157)

- Freshness Gate CP156/HEAD `cd7855c1fa366716569e35acbd5f81337b866caa` = identical;
- `scripts/oes_neon_migration_preflight.py` e `tests/test_oes_neon_migration_preflight.py` versionados: leitura do manifesto S5 36 entradas + 14 fragmentos, HEAD obrigatório, hashes SHA-256 e saída JSON fail-closed; nenhuma conexão SQL;
- 7/7 testes unitários sintéticos locais = OK, código GitHub conferido por Git blob SHA; nenhum teste dos 50 SQL reais em checkout integral e nenhum workflow CI disparado para essa prova;
- cliente `psql` indisponível no ambiente local; runner PostgreSQL 18 e ledger permanecem não implementados;
- contrato lógico de ledger e tratamento de estado incerto após falhas entre commit SQL e ledger preparados no Documento 113, não autorizados/implantados;
- API Neon somente leitura: assinatura `free_v3`, limite 10 branches, uma branch default `production`, projeto lógico até 1 GiB; consumo/billing do titular ainda pendente;
- Documento 113 esclarece prospectivamente notação de `\\ir`/diretiva `\ir`, sem alterar CP156;
- autorização para `oes-schema-test` = PREPARED_NOT_APPROVED; branch, roles, schema, ledger e migrations não criados;
- B1R1 permanece EXPIRED_NOT_EXECUTED; Fase 5 não iniciada; backup independente não configurado;
- próximo passo: prova do preflight no checkout integral e ensaio de runner/ledger em PostgreSQL 18 sintético sem Neon, sujeitos a disponibilidade e novo `Prossiga`; pausa obrigatória.


### Fase 4 — CI offline preparada e PostgreSQL 18 bloqueado (Documento 114 / CP158)

- Freshness Gate CP157/HEAD `3ecb187d04edc75a9b957bef5c252d746607d76e` = identical;
- workflow `.github/workflows/f4-neon-offline-preflight.yml` registrado: checkout fixado, unit tests sintéticos, inventário SHA-256 de 36+14 arquivos, captura de artifact; sem segredos, conexões ou SQL Neon;
- 7/7 testes unitários locais em árvore artificial OK; **nenhum run CI/log/artifact verificado** deste novo workflow, portanto hashes reais dos 50 SQL ainda não comprovados;
- checkout integral local bloqueado por DNS; PG17.11 local identificado, `psql` ausente; **nenhum teste de runner/ledger PostgreSQL 18 executado**;
- ledger = desenho lógico sem tabela/runner; política de locks e recuperação ainda pendente;
- autorização branch `oes-schema-test` não concedida; zero mutation Neon, sem backup independente, B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada;
- próximo bloco: confirmação de run CI e digest real, depois estudo sintético de runner/ledger PG18; pausa obrigatória.

### Fase 4 — Verificação CI sem acesso a run identificável (Documento 115 / CP159)

- Freshness Gate CP158/HEAD `94175cafebd9d960d4cb5341090f02cff4ae146e` = identical, zero drift;
- novo workflow de inventário offline permanece registrado, porém run_id, resultado CI, logs e artifact SHA-256 reais não recuperados nesta etapa;
- integração GitHub permite jobs/logs/artifacts a partir de run_id, mas não enumeração geral de runs; endpoint público indisponível neste ambiente;
- execução CI: DESCONHECIDA, não se conclui que ocorreu nem que não ocorreu, e não se declara PASS;
- Documento 115 documenta meios de obtenção de run_id e critérios de prova; CP159 congela o estado;
- sem execução PostgreSQL 18 de ledger, sem branch/schema/migration Neon, B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada;
- pausa obrigatória até novo `Prossiga`.


### Fase 4 — Prova CI offline do inventário confirmada (Documento 116 / CP160)

- run GitHub Actions `39256905894`: job `inventory` completed/success, 7/7 testes unitários, inventário de 36 entrypoints + 14 fragmentos, artifact `12186719617` recuperado;
- commit testado: `55ef8051054652b3823de743293524f317a33ec6`; checksum SHA-256 agregado `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`;
- `inventory.json` verificado contra checksum: `5694be45dd10c39131e6a74270bbf66cbb30ee21aba7bd47c91e96d2f2ea2504`; BRG-04 STATIC_CI_VERIFIED somente no commit testado;
- evidência não autoriza nem prova migrations PG18, runner/ledger, segurança, billing ou backup; sem write Neon, branch ainda não criada, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo passo: ensaio PG18 exclusivamente sintético em CI/local, avaliação de locks/ledger e falhas; pausa obrigatória CP160.


### Fase 4 — Preparação de ensaio PostgreSQL 18 sintético (Documento 117 / CP161)

- Freshness Gate CP160/HEAD `255663e154067ecca3f5073ec96ad69d084f4e6b` = identical;
- publicado workflow manual `.github/workflows/f4-neon-pg18-schema-rehearsal.yml`, contêiner PG18 descartável em GitHub Actions e credenciais somente sintéticas de job;
- preparação inclui pré-gate SHA-256 em checkout fixado, execução das 36 migrations sem fixtures, logs separados e paragem no primeiro erro; **não houve execução ou resultado verificado**;
- Documento 117 descreve escopo e limitações; BRG-05 ainda pendente, BRG-06 ledger somente desenho, BRG-07 runner CI preparado/não testado;
- nenhuma criação de branch, role, schema, migração ou operação no Neon; B1R1 EXPIRED_NOT_EXECUTED; Fase 5 não iniciada;
- próximo bloco: conferir run manual PG18 e artifacts; pausa obrigatória.


### Fase 4 — CI PG18 automática autorizada (Documento 118 / CP162)

- Owner autorizou acionamento automático apenas da CI sintética; workflow PG18 recebeu gatilho push main limitado ao seu próprio arquivo, preservando execução manual;
- alteração aplicada no commit `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`;
- run/job/artifact de PG18 ainda não confirmado; nenhum PASS de compatibilidade declarado;
- nenhuma alteração Neon, branch, ledger ou migration; B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; pausa obrigatória.


### Fase 4 — Prova PG18 sintética 36/36 (Documento 119 / CP163)

- run GitHub Actions `39261597847`, job `118090362879`, completed/success, HEAD de teste `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`;
- PostgreSQL servidor 18.6, cliente psql 16.15; 36 migrations PASS, 14 fragmentos conferidos; artifact `12190502582`; digest de inventário `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`;
- 275 funções (schemas selecionados), dois registros estruturais contract_epoch; BRG-05 passa apenas para sequência sintética no commit fixado;
- ledger/locks/recuperação, menor privilégio, backup, Neon Free billing pendentes; sem operações Neon, B1R1 expirado sem execução, Fase 5 não iniciada;
- próximo bloco requer avaliação de ledger e falhas sintéticas, recomendado modo alto; STOP.


### Fase 4 — Falhas transacionais e advisory locks em ledger sintético PG18 (Documento 120 / CP164)

- Freshness Gate CP163 HEAD `4a2d9d2e60c2b86ca789944dd69a343c8fb4ee01` = identical;
- criados `tests/fixtures/f4-ledger-synthetic/bootstrap.sql`, `scripts/oes_pg18_ledger_synthetic_test.sh`, `.github/workflows/f4-pg18-ledger-synthetic.yml` com CI apenas PG18 descartável, sem Neon;
- run `39263916981` / job `118098438290` completed/success no SHA `2acabe21102774bae5ce86d15858dc434e905bf5`; PostgreSQL 18.6 / psql 16.15, **17/17** testes sintéticos PASS;
- artifact `12191953694` e ZIP SHA-256 `6eefdb6ed5986330b05cc03cda2e53abff8a3ca46a17fea12fbe475ddc81622f` conferidos; rollback e recibo atômicos no teste, commit-gap, drift, retry bloqueado, append-only e lock de duas sessões;
- BRG-06 modelo sintético verificado/ledger operacional NÃO criado; BRG-07 primitiva lock verificada, **não** há guardião de lock cobrindo 36 subprocessos nem testes de kill/recovery;
- nenhuma branch/role/schema/ledger/migration no Neon, backup independente não configurado, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: guardião de lock e injeção de falhas sintéticas, modo alto, pausa obrigatória após CP164.


### Fase 4 — Guardião persistente de lock PG18 e contraprova após crash (Documento 121 / CP165)

- Freshness Gate CP164/main = identical, HEAD `2ad4da0fbd725273ed253d88fd3ccc29ed2a2ff8`; modo alto;
- criados script `scripts/oes_pg18_guardian_synthetic_test.py` e workflow `.github/workflows/f4-pg18-guardian-synthetic.yml` para PostgreSQL 18 exclusivamente descartável, sem Neon;
- run `39266423818` FAILED: lock não liberado prontamente com query `pg_sleep` ativa após SIGKILL do cliente; run `39266711331` FAILED por newline de stdin incorreto;
- run corrigido `39266780706` SUCCESS, 15/15 testes, PostgreSQL 18.6 e psql 16.15, commit `064d970ddbc1e4a4830a44472074eaec5734698b`, artifact `12193207877`, ZIP SHA-256 `867f2189872cbdd3accf12851f6d4d1843a63bbea7b1a5bf4e7f7c62a39f6175`;
- a sessão ociosa conserva lock em dois subprocessos sequenciais e o libera após SIGKILL, mas um subprocesso SQL em voo **pode concluir commit após morte do guardião**. Intenção durável `prepared` impediu replay e estado `uncertain` persistiu; prova negativa não autoriza runner operacional;
- BRG-06/07 = modelo sintético comprovado com limitação, ledger operacional/supervisor/guarda de subprocessos/reconciliação por pós-condições ainda pendentes; BRG-03/08/09 pendentes;
- nenhum Neon write, branch, role, schema, ledger, migration, backup independente ou operação factual. B1R1 EXPIRED_NOT_EXECUTED; Fase 5 não iniciada;
- próximo bloco: supervisor de processo e falhas induzidas no PG18 sintético, modo alto; STOP CP165.


### Fase 4 — Supervisor PG18 sintético: concorrência, cancelamento e reconciliação (Documento 122 / CP166)

- Freshness Gate CP165/HEAD `2ebd3a56da271a4d98859d6b0e5c9db5c40a8ea3` = identical, 0 drift; modo alto;
- novos artefatos `tests/fixtures/f4-supervisor-synthetic/postconditions.json`, `scripts/oes_pg18_supervisor_synthetic_test.py` e `.github/workflows/f4-pg18-supervisor-synthetic.yml`, exclusivamente PostgreSQL 18 efêmero e sem Neon;
- harness visa testar índice parcial de claim `prepared` sob concorrência, guardião ocioso, SQL confirmado sem recibo, cancelamento de transação ainda aberta, bloqueio de repetição, recusa de novo subprocesso após perda do guardião e pós-condições conservadoras;
- run CI automático `39278420804` no SHA `7bba5cbd3a5c1cf9d628049b2b00643f8d21b226`, job `118148257964` permaneceu `queued` nas consultas: **NÃO há teste executado/comprovado, artifact ou PASS neste bloco**;
- Documento 122 e CP166 registrados; BRG-06/07 permanecem modelos de prova sintética e NÃO autorizam runner/ledger operacional;
- nenhuma branch/role/schema/migration/ledger Neon, backup independente ausente, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próxima retomada: consultar run 39278420804 e artifacts, diagnosticar falhas se houver; modo alto, pausa obrigatória.


### Fase 4 — Evidência sintética supervisor PG18 recuperada (Documento 123 / CP167)

- Freshness Gate CP166/main = identical, HEAD entrada `ab9e7ff7ab64ab8125e073f3f5764ab5257526d6`, modo alto;
- run PG18 sintético `39278420804`, commit `7bba5cbd3a5c1cf9d628049b2b00643f8d21b226`, logs completos e artifact `12199766445` recuperados e auditados; **25/25 controles PASS**, PostgreSQL 18.6, psql 16.15;
- hash SHA-256 ZIP `57dc8e2ba0af83bbfb352735989e48e965cdeafc7111e0725c5a795abadfea9e`; `claim-results.json=[true,false]`, pós-condições de commit sem recibo e de transação cancelada verificadas; replay/applied automáticos recusados;
- **metadados GitHub do run/job passaram de queued para in_progress, com conclusion=null na última leitura**, embora logs e artifact comprovem execução do harness; não alegar conclusão administrativa `completed/success`;
- Documento 123 e CP167 registrados; BRG-06/07 modelo sintético comprovado, **ledger e runner operacionais não liberados**; segurança ACL/TLS, backup, billing pendentes;
- nenhuma criação/alteração de branch, SQL, ledger ou schema Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco modo alto, pausa obrigatória.


### Fase 4 — Desenho fail-closed e catálogo de reconciliação das 36 migrations (Documento 124 / CP168)

- Freshness Gate CP167/HEAD `0d884ab84e449398ec0367a08364cfde1e5cb8f8` = identical; run supervisor anterior `39278420804` passou a `completed/success`, fechando inconsistência de metadados CP167;
- Documento 124 criado: distinção entre advisory lock cooperativo e fencing real; política **proposta/não normativa** de intent durável, claim exclusivo, supervisão e reconciliação, sem modificar a política canônica 30;
- catálogo `database/f4-reconciliation-postconditions-draft.json` com 36/36 migrations na ordem do manifesto, todas UNREVIEWED, 0 pós-condições, 0 autorizações automáticas; observações documentais de fronteiras SQL 031–036;
- linter offline `scripts/oes_f4_reconciliation_catalog_lint.py`, 11 unit tests sintéticos e CI `.github/workflows/f4-reconciliation-catalog-static.yml` criados;
- CI run `39282514522` no commit `52f796f3b500e550335c06a33c761369804fd3e6`: logs mostram 11/11 testes OK e artifact `12201766282` com digest ZIP `208b607dfd72d6ddde9710cef0da0fea093e562fd92a2e76d3e82a3e0f832e8b` conferido; metadados administrativos ainda queued/conclusion=null na última consulta, não declarar run success;
- Nenhum SQL foi executado pela CI documental, nenhuma modificação Neon; BRG-06/07 ainda não operacionais, BRG-03/08/09 pendentes, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: revisar pós-condições reais 031–036 em modo alto e somente sintético/offline; STOP CP168.


### Fase 4 — Revisão estática de pós-condições 031–036, sem liberação operacional (Documento 125 / CP169)

- Freshness Gate CP168/main `d213a618ce6fa87c8008c8e5da30a3ff219048fa` = identical; run anterior `39282514522` confirmado completed/success (11 testes OK);
- inspeção de 031–036 e 14 fragmentos: 031/032/033 wrappers transacionais; 032 contém grandfathering e seed técnico, 034/036 DROP/CREATE trigger sem wrapper, 035 duas substituições de função;
- publicados `docs/governance/reconciliation/f4-031-036-source-candidates.json` (6 candidatos NÃO validados), `scripts/oes_f4_031_036_source_review.py`, 8 testes e workflow estático próprio;
- run CI `39297500185`, commit `feb2b9f115e94a09c975b98f61d7a5ffda53438d`, job `118213715729` completed/success, 8/8 testes, artifact `12209110983`, SHA ZIP `ff1c7b237c5b5c1246b60bdb2f3cae19073acb88e5b793b254559169873551f1`;
- Documentação 125 e CP169; scanner prova somente integridade textual de 20 fontes. Catálogo principal 36 UNREVIEWED/0 pós-condições validadas, nenhuma autorização de execução/replay/reconciliação automática;
- BRG-06/07 operacionais pendentes; nenhuma branch ou SQL Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco PG18 descartável para comparação pré/pós e falhas induzidas, modo alto, STOP.


### Fase 4 — Prova sintética PG18 de falhas estruturais 031–036 (Documento 126 / CP170)

- Freshness Gate CP169/main = identical, HEAD entrada `f928807e76b74dc32b65fe3a707c72232c721c55`; modo alto;
- publicado `scripts/oes_f4_pg18_031_036_fault_rehearsal.py` e `.github/workflows/f4-pg18-031-036-fault-rehearsal.yml`; PG18 descartável em GitHub Actions sem Neon;
- primeira CI `39349451906` FAILED por consulta antecipada do comparador ao objeto `maintenance.contract_epoch` inexistente antes de 031; corrigida prospectivamente; não classificar como erro da migration;
- run corrigido `39349564581`, job `118390284507`, completed/success, 29/29 checks PASS no commit `46af0a575e30d640dedd97edf84315ebc5f6f310`; artifact `12233090040`, ZIP SHA-256 `6aea06318fb097c66066a75e13b8e03ae23ff52c6c7cf07a9bfffb9009431a3e` conferido;
- 031–033: rollback de inventário estrutural em erro induzido antes do commit; 034/036: replay negativo deixou trigger ausente após DROP e falha antes do CREATE; 035: primeira função persistiu, segunda ausente após erro;
- **zero pós-condições operacionalmente validadas, catálogo principal 36 UNREVIEWED**; não houve fixture de registros preexistentes para grandfathering 032, nem prova integral de DML/semântica;
- Documento 126 e CP170 registrados; BRG-06/07 e BRG-03/08/09 operacionais ainda pendentes; nenhuma migração/branch/SQL Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: grandfathering 032 em PG18 descartável, modo alto, pausa obrigatória.


### Fase 4 — Grandfathering 032 com fontes sintéticas preexistentes (Documento 127 / CP171)

- Freshness Gate CP170/main idêntico ao HEAD `238b2a11cf26c94958e075ad852575419958b38e`; modo alto, sem mudança Neon;
- fixture com três fontes preexistentes constraint-consistentes: `update_policy`, `sla_calendar_version` e `sla_rule`, vinculadas a core/product artificiais; harness PG18 descartável e workflow CI sintético publicados;
- run `39350571819` job `118393517271`, completed/success, commit `a060f7055063bf83ce8e880193b08f9c941e46f3`, servidor PG18.6, **19/19 verificações PASS**;
- artifact `12233056788` ZIP SHA-256 `4191c4936b523b7ea9e2d7e176a14770b5daa6eb618dd6832a23f340b899b339` conferido com GitHub; 3 entradas grandfathered na primeira instalação, fontes preservadas, rollback antes COMMIT retorna ao estado estrutural anterior;
- controle negativo: marcador `TEMPORAL_CALIBRATION_V01` artificialmente preexistente suprime grandfathering, logo marker isolado não comprova migration integral;
- Documento 127/CP171 publicados; **catálogo 36 UNREVIEWED, zero pós-condições aprovadas**, BRG-06/07 operacionais não implantados, BRG-03/08/09 pendentes;
- sem Neon branch, SQL ou registro científico; B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada; próximo bloco funções/triggers 034–036 em PG18 descartável, modo alto e pausa obrigatória.


### Fase 4 — Testes comportamentais temporais 034–036 em PG18 (Documento 128 / CP172)

- Freshness Gate CP171/main `e8219a04ab322eb51d401ce37177e5f5e33b1cba` = identical, sem drift, modo alto;
- fixture de plano, fonte, epoch, oportunidades e autoridade **artificiais**, harness `scripts/oes_f4_pg18_034_036_behavior_test.py` e workflow `.github/workflows/f4-pg18-034-036-temporal-behavior.yml` publicados, somente CI PG18 descartável;
- primeiro run `39355352898` FAILED porque fixture reutilizou calendário pré-032 não aceito pelo schema 036; corrigido sem modificar SQL de migration;
- run corrigido `39355448709`, job `118409046787`, completed/success, SHA `d0c378a99b36f331bc1f5df627cd024448a421e1`, PostgreSQL 18.6, **30/30 PASS**;
- artifact `12235255740` ZIP SHA-256 `a9326e8d6d5aa3a2f282460ed3465be295767f6d2d513c4f2d1986523b8e2442` conferido; 034 recusou cronologia inválida/desvio material e aceitou ativação sintética válida; 035 comprovou FAIL/WAIT/PASS sem DML; 036 verificou primeiro e subsequente eventos com novelty/attribution;
- Documento 128/CP172; autoridade artificial não equivale a aprovação científica/humana; catálogo principal **36 UNREVIEWED, 0 pós-condições operacionais aprovadas**, BRG-06/07 não operacionais;
- nenhuma branch, SQL, role, migration, ledger ou alteração Neon; BRG-03/08/09 pendentes, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco lacunas de cenários negativos, modo alto, STOP.


### Fase 4 — Cobertura negativa temporal 034–036 sob PG18 descartável (Documento 129 / CP173)

- Freshness Gate CP172/main = identical, HEAD `f2f89ed65eff43ca38b482506c7106048b805aa4`, 0 drift, modo alto;
- novos `scripts/oes_f4_pg18_034_036_negative_coverage.py` e `.github/workflows/f4-pg18-034-036-negative-coverage.yml`, sete bancos sintéticos para diferentes estados e nenhum acesso Neon;
- run `39356550539`, job `118412553302`, completed/success, commit `b5f0eb3c0b3d95b7e864c3fdbbfb05dfc7baf997`, **27/27 verificações PASS**, artifact `12235317764`, ZIP SHA256 `dec06e6b79afe9eb34902e804578eb10aa28fe04d19dab774f4dd6a3ae5fec34` conferido;
- autoridade ausente/conflitante, conectividade obrigatória bloqueada e oportunidade faltante recusadas pelos guards/preflight;
- contraprova crítica em **superusuário CI sintético**: desabilitar triggers 034 e 036 permite gravar estados inválidos, não corrigidos retroativamente pela reabilitação; requer segregação de roles, auditoria DDL e validação dos dados históricos, **sem afirmar risco de exploração por usuário comum**;
- desvio material gravado depois de `started_at` não bloqueou ativação naquele instante; nenhuma decisão de governança para o futuro foi inferida;
- Documento 129/CP173; catálogo principal 36 UNREVIEWED, zero pós-condições aprovadas, sem ledger/runner operacionais, nenhuma operação Neon, B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada;
- próximo bloco: matriz de suficiência de evidências e separação de privilégios, modo alto, pausa obrigatória.


### Fase 4 — Matriz provisória de suficiência de evidências 034–036 (Documento 130 / CP174)

- Freshness Gate CP173/main `9d39071800343151b917ea7d00862f12f8c00f4a` = identical, sem drift;
- publicada matriz `docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json`: **3 migrations, 36 requisitos NOT_COLLECTED**, 0 validações operacionais e 0 revisões independentes. Exige identificação/hash do SQL, ledger/intenção/recibo, dependências, integridade histórica, roles, auditoria DDL, backup/restore e aprovação humana;
- validador estático `scripts/oes_f4_temporal_sufficiency_matrix_lint.py`, 12 testes e workflow read-only próprios, nenhum SQL executado;
- run `39357315282`, job `118414984671`, completed/success, commit testado `bce4b359c5658ce94342b457cd79b06f3bab6b32`, **12/12 testes PASS**;
- artifact `12235633344` SHA-256 ZIP `6db9387eb7b10476d03ba5403f6b145510f4bbda699da8163b9459c8c7959537` conferido; saída `STATIC_DRAFT_MATRIX_BLOCKED_ONLY`, 0 pós-condições aprovadas, nenhuma permissão de execução/replay/reconciliação automática;
- Documento 130 e CP174 registrados; **catálogo principal 36 UNREVIEWED**, BRG-03/06/07/08/09 pendentes, ausência de qualquer mudança Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco recomendado: teste sintético de ACL/DDL e segregação de roles em PG18 descartável, modo alto, pausa obrigatória.


### Fase 4 — Segregação de roles e auditoria DDL transacional em PostgreSQL 18 sintético (Documento 131 / CP175)

- Freshness Gate CP174/main = identical, HEAD `8c8a54937f9ef1a697c309d4e7876dd473ff8a8c`, sem drift, modo alto;
- publicados `scripts/oes_f4_pg18_acl_ddl_audit_synthetic.py` e `.github/workflows/f4-pg18-acl-ddl-audit-synthetic.yml`, restritos a PG18 descartável e roles artificiais, sem Neon;
- runs `39358068414` e `39358143142` FAILED por comparação incorreta do resultado booleano convertido em texto no harness; as permissões e denials já executadas permaneceram coerentes; correções prospectivas;
- run `39358223730`, job `118417944949`, completed/success no commit `b53897af4e12052c122f5ab1d1c879f1a32c52d1`, **38/38 verificações PASS**, servidor PostgreSQL 18.6;
- artifact `12236325916`, ZIP SHA256 `44107e32b45fcf7b4698572d736e38005370348d6465d3bd320c2544ec23a408` conferido; runtime e migrator de privilégio limitado foram impedidos de alterar/desabilitar objetos 034–036 no contêiner;
- superusuário sintético desabilitou e reabilitou guard 034; event trigger de auditoria em banco registrou duas alterações DDL **confirmadas**, mas não preservou evento em transação revertida; trilha interna não é log externo independente;
- Documento 131/CP175; **BRG-03 ainda sem confirmação Neon/TLS/segredos/DDL externo**, BRG-06/07 operacionais não liberados, BRG-08/09 pendentes; catálogo principal 36 UNREVIEWED, 0 pós-condições aprovadas;
- nenhum SQL/branch/role/ledger Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco modelo offline de roles/auditoria externa, modo alto, pausa obrigatória.


### Fase 4 — Modelo-alvo provisório de roles e auditoria DDL externa (Documento 132 / CP176)

- Freshness Gate CP175/main `0d81a9eff96ba545075c4bfe9c5071414f45510c` = identical, ahead/behind 0, modo alto;
- modelo documental `docs/governance/security/f4-target-roles-external-audit-draft.json`: **6 papéis**, **12 requisitos de segurança não satisfeitos**, **4 alternativas de auditoria sem escolha operacional**, tudo fail-closed;
- PostgreSQL ownership e possibilidade de `SET ROLE` de membro impedem garantir que migrator elevado à propriedade não possa desabilitar guards apenas por `REVOKE`; requer elevação controlada, hashes, supervisor, auditoria externa e revisão especializada; tais controles ainda não existem;
- exportação Neon de logs PG para OTLP publicamente descrita, mas disponibilidade Free e eventual cobrança **não verificadas**; nenhuma ativação de serviço pago e nenhuma suposição de auditoria completa a partir de GitHub Actions ou event trigger transacional;
- validador estático e 16 testes publicados; run `39361692980`, job `118429107779`, completed/success no SHA `fd75b3a41a1cdf9fe23ec1cb2626bb349efdd431`, **16/16 PASS**;
- artifact `12236864111`, ZIP SHA256 `d91577ca76868f4612eda88a5a6cb7c9083d243f12afd5574b1490133a8e902c` validado, status: 6/12/4, 36 migrations UNREVIEWED, 36 requisitos de matriz 034–036 NOT_COLLECTED, nenhum SQL/Neon/serviço pago;
- Documento 132 e CP176; BRG-03/06/07/08/09 não liberados; nenhuma branch, role, DDL ou ledger Neon; B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: somente experimento PG18 descartável de papéis LOGIN, `SET/INHERIT`, elevação e simulação de recibos de logs externos; modo alto, pausa obrigatória.


### Fase 4 — LOGIN, SET/INHERIT e recibos CI fora da transação (Documento 133 / CP177)

- Freshness Gate CP176/main `1bed3de41ebc9dd5a670e867d38bc3c2e6825669` identical, modo alto; data do novo checkpoint 2026-10-20;
- harness `scripts/oes_f4_pg18_login_roles_external_receipt_sim.py` e workflow descartável publicados: autenticação LOGIN de três roles sintéticas, proprietária NOLOGIN, opções `SET/INHERIT`, alteração de owner somente em banco PG18 CI, teste de trigger 034;
- run inicial `39404590522` FAILED por falta de USAGE no schema pela role proprietária artificial; corrigido sem modificar migrations SQL históricas;
- run `39404695131`, job `118567684999`, completed/success no commit `39ad812f55fd7b79c70f80766f0a85c3e9ea713c`, **41/41 PASS**, artifact `12256624023` ZIP SHA256 `e40f13a2254d9e8d41e14b87b3c758f6e2f1a0200e1f35a3d96d6aee240c014f` conferido;
- migrator com membership `SET FALSE/INHERIT FALSE` não pôde assumir owner; credencial com `SET TRUE` pôde, após `SET ROLE`, desabilitar e reabilitar trigger 034 no banco descartável, provando risco de elevação;
- oito recibos JSONL simulados fora da **transação PG**, armazenados no próprio runner CI; rollback preservou recibo no filesystem; cinco corrupções simuladas detectadas. Não há imutabilidade, independente, cobertura SQL direta/fora do wrapper ou coletor externo;
- Documento 133/CP177, catálogo 36 UNREVIEWED/0 pós-condições aprovadas, matriz 034–036 36 NOT_COLLECTED, BRG-03/06/07/08/09 operacionais pendentes, nenhum Neon nem serviço pago; B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco `ADMIN FALSE`, membership transitiva e limites de comprovantes fora da transação em PG18 descartável, modo alto; pausa obrigatória.


### Fase 4 — ADMIN FALSE, membership transitiva e limites de recibos (Documento 134 / CP178)

- Freshness Gate CP177/main em 73280fd0fdc7f0dd440feee0f741299d1d34e476: identical, ahead/behind 0, modo alto.
- Harness sintético e workflow PG18 descartável publicados. Run 39410126403, job 118585562919, commit técnico 909922efd400b237181445c5a206f97b3fcc19e9: completed/success, 40/40 PASS confirmados em logs e checks.tsv.
- Artifact 12259205919, 11 arquivos, ZIP íntegro testzip()=None, SHA256 4577ddde26943d00c05e7dc9b4143ab288d106aa4692ee5e04a1e641f3be5c46 igual ao digest GitHub.
- Seis memberships artificiais ADMIN FALSE; delegações diretas sem ADMIN negadas. Cadeia SET TRUE transitiva possibilitou SET ROLE owner e alteração temporária do trigger 034; cadeia INHERIT TRUE com SET FALSE possibilitou DDL de owner sem SET ROLE; rollback preservou o trigger.
- Recibo incompleto simulado foi rejeitado, mas não prova execução de SQL; SQL direto fora do wrapper alterou trigger sem novos recibos; adulteração simultânea de JSONL e anchor SHA256 foi aceita pelo verificador local. Recibos no mesmo runner NÃO são auditoria externa independente/imutável.
- BRG-03/06/07/08/09 operacionais seguem bloqueados; BRG-04/05 continuam evidências limitadas a commits. 36 migrations UNREVIEWED, zero pós-condições aprovadas e 36 requisitos 034–036 NOT_COLLECTED; 12 controles de roles não satisfeitos.
- Sem SQL/branch/migration Neon, sem serviço pago. B1R1 EXPIRED_NOT_EXECUTED, Fase 5 NOT_STARTED. Documento 134 e CP178. STOP; próximo checkpoint requer novo Prossiga.


### Fase 4 — Proporcionalidade e priorização científico-funcional (Documento 135 / CP179)

- Freshness Gate CP178/main `e78821cc4f377bb51b8640fda7d9c1cd9b538585` identical, ahead/behind=0. Modo alto; decisão somente documental.
- Três camadas analíticas: D0 desenho/testes efêmeros, D1 piloto persistente (não autorizado), D2 operação real e automação autoritativa (não autorizadas). Nenhum BRG ou gate alterado.
- Prioridade imediata: inventário de suficiência científico-funcional do protocolo de atualização, casos manuais/assistidos, revisão humana e lacunas. Novos testes PG18 só se houver decisão dependente e hipótese material nova; achados CP175–178 mantidos em escopo sintético.
- BRG-03/06/07/08/09 bloqueados; BRG-04/05 históricos. 36 migrations UNREVIEWED, zero pós-condições de reconciliação aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos, flags automáticas desabilitadas.
- Sem Neon SQL/branch/migration/role, sem CI nova, sem serviço pago. B1R1 EXPIRED_NOT_EXECUTED; Fase 5 NOT_STARTED; revisão especializada exigível onde aplicável. STOP.


### Fase 4 — Inventário de suficiência científico-funcional (Documento 136 / CP180)

- Freshness Gate CP179/main `cabd12b4ede5a82bcb60cfef4054e2ae88dbe38b` = identical, 0 ahead/behind; modo alto; escopo exclusivamente D0 documental.
- Documento 136: 14 domínios SF-01–SF-14 classificados sem confundir especificação, validação técnica sintética e suficiência científica real; percurso de referência manual/assistido, doze casos candidatos AT-01–AT-12 e lacunas G1–G6.
- RESULTADO = INVENTORY_COMPLETED_WITH_MATERIAL_GAPS; prontidão para encerramento documental da Fase 4 = NOT_READY_FOR_PHASE_4_DOCUMENTAL_CLOSURE. Nenhum caso AT declarado testado/validado neste CP.
- N1/N2 readiness temporal = INSUFFICIENT_EVIDENCE; valores de cadence/SLA normativos NÃO autorizados; B1R1 EXPIRED_NOT_EXECUTED; M3 formal BLOCKED; nenhum início de Fase 5.
- BRG-03/06/07/08/09 bloqueados; BRG-04/05 provas históricas. 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos. Sem Neon SQL/branch/role/migration, sem CI ou serviços pagos novos.
- Próximo ponto mediante novo Prossiga: especificar/confrontar cenários integrados D0, preservar revisão humana qualificada e bloqueios operacionais; pausa obrigatória.


### Fase 4 — Doze cenários adversariais de aceitação documental (Documento 137 / CP181)

- Freshness Gate CP180/main `98886a7cb2d710c88fba9f58bd2decb054a0aedd`: identical, ahead/behind=0; modo alto; escopo exclusivamente D0 documental.
- Documento 137: AT-01–AT-12 **especificados e confrontados textualmente**, 9 leituras coerentes condicionais, 3 ressalvas adversariais AT-05/09/12; **zero cenários integrados executados**, nenhuma validação científica humana, nenhum PASS empírico.
- G1 parcialmente especificada; G2–G6 permanecem com dependências humanas, temporais, operacionais e de runbook. PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY.
- BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos, 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles pendentes.
- Neon intocado, nenhuma CI/PG18/SQL/serviço pago; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado, Fase 5 NOT_STARTED. Próximo somente após Prossiga: runbook e matriz de aceitação D0. STOP.


### Fase 4 — Runbook manual/assistido, aceitação e piloto empírico estratégico (Documento 138 / CP182)

- Freshness Gate CP181/main `148355f845d4c3307738b251924db43cd80c14a1`: identical, ahead/behind=0; modo alto; somente D0/documentação.
- Documento 138: runbook R0–R8; matriz AT-01–AT-12 com evidências e oráculos, **12 especificados, zero executados**; template de registro futuro e STOP por ausência de autoridade, ciência, integridade ou recuperação.
- **Duas frentes de planejamento preservadas:** (1) suficiência científico-funcional documental (G1–G6 ainda pendentes, sem encerramento da Fase 4); (2) piloto empírico futuro PubMed/ClinicalTrials.gov com nove dependências PILOT-01–PILOT-09 e sequência proposta E0–E5, sem autorização de execução.
- `F4_EMPIRICAL_FIRST_MEASUREMENTS = STRATEGIC_PENDING_WITH_BLOCKERS`, `NEW_EPOCH = NOT_AUTHORIZED`, B1R1 `EXPIRED_NOT_EXECUTED`, preflight e medições históricas não executados; pacotes Docs 91/94/95 preservados, não reaproveitados como autoridade válida de execução.
- Neon Free com prova de SELECT histórica apenas, não banco operacional factual aprovado. BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos; 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles não satisfeitos.
- Nenhum SQL/branch/role/migration Neon, nenhuma nova CI/PG18, nenhum request target-specific PubMed/ClinicalTrials, nenhum serviço pago. M3 bloqueado; Fase 5 não iniciada. Próximo candidato CP183 somente após Prossiga: matriz proporcional de mínimo readiness do piloto, documentação sem ações operacionais. STOP.


### Fase 4 — Gate mínimo de retomada do piloto factual (Documento 139 / CP183)

- Freshness Gate CP182/main `9e762b1edfd96262b9782d9fe87c1a508da46051` identical, 0 ahead/behind; modo **médio** documental. Alto somente quando riscos, custos, segurança ou autorização operacional justificarem.
- Documento 139: P-A consulta interface sem persistência (alternativa não selecionada), P-B medições factuais persistidas PubMed/ClinicalTrials (objetivo estratégico mantido, não autorizado), 12 ODBs NOT_READY e trilha G0–G5.
- BRG-03/06/07/08/09 bloqueados; BRG-04/05 históricos; 36 migrations UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles não satisfeitos. Neon Free SELECT histórico PASS apenas, não factual ready.
- B1R1 EXPIRED_NOT_EXECUTED, novo epoch NOT_AUTHORIZED, M3 bloqueado, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED; nenhum Neon, PG18, CI, request de fontes ou gastos neste CP. Próximo candidato CP184 G0 somente após Prossiga. STOP.


### Fase 4 — Pacote de decisão G0 do proprietário (Documento 140 / CP184)

- Freshness Gate CP183/main `dba90c228bc2920f35ef687af368e0bd9a43beda` identical, 0 ahead/behind; modo **médio**, apenas documentação.
- Documento 140: pacote G0 para piloto futuro P-B PubMed/ClinicalTrials.gov, dez dimensões delimitadoras e seis decisões G0-D1..D6 **PENDING_OWNER**; modelo de deliberação não assinado, sem decisão financeira/operacional inferida. P-A interface não persistente continua alternativa não selecionada.
- Neon Free somente sandbox synthetic-only, SELECT histórico; factual use não autorizada. BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos, 36 migrations UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles pendentes.
- B1R1 EXPIRED_NOT_EXECUTED; sem novo epoch, cadastro, branch/migration/role SQL Neon, consulta PubMed/ClinicalTrials.gov, MeasurementEvent, gasto ou autenticação. M3 bloqueado, Fase 4 documental NOT_READY e Fase 5 NOT_STARTED.
- CP185 candidato condicionado a novo Prossiga: revisão proporcional de dependências e um único próximo ato preparatório; recomendar **modo alto** antes de aprovação G0 substantiva. STOP.


### Fase 4 — Priorização de ato único para prontidão do piloto (Documento 141 / CP185)

- Freshness Gate CP184/main `c657e6ec1f5d2542ed828d35922046cc52b5d9bf` identical, zero ahead/behind, modo médio; análise apenas documental.
- Documento 141 seleciona **conferência futura read-only pelo titular** de plano, quotas e riscos de billing Neon Free; **não executada**, G0-D1–D6 PENDING_OWNER. Nenhum dado sensível solicitado, nenhum painel aberto pelo assistente, nenhum ato de cobrança autorizado. Alternativas PG18 repetitivo, mutações Neon ou novo epoch diferidas/bloqueadas.
- BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos; 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles pendentes. B1R1 EXPIRED_NOT_EXECUTED; `NEW_EPOCH=NOT_AUTHORIZED`; Fase 4 documental NOT_READY, M3 bloqueado, Fase 5 NOT_STARTED.
- Nenhum Neon/SQL/CI/PG18, consulta PubMed/ClinicalTrials ou gasto. CP186 candidato só após Prossiga: obter dados não sensíveis do titular e avaliar lacuna BRG-09; alto apenas antes de decisão substantiva G0. STOP.


### Fase 4 — Observação API Neon Free e lacuna de billing (Documento 142 / CP186)

- Freshness Gate CP185/main `8c8eae2f554a1a050bea5d511c89d49dc47d8c6e` identical, 0 ahead/behind; modo médio. `describe_project` via integração Neon read-only: plano `free_v3`, 1 GiB limite lógico por branch, limite de 10 branches, contadores compute/transferência com contexto limitado. Nenhuma informação sensível publicada.
- BRG-09=PENDING_OWNER_FINANCIAL_CONFIRMATION, G0-D5=PENDING_OWNER; API não comprova cartão, fatura, serviços pagos, custo zero garantido ou cobranças futuras. Próximo ato é resumo manual não sensível pelo titular, sem dados bancários.
- Nenhum SQL/branch/role/migration/CI/PG18, nenhuma query PubMed/ClinicalTrials ou gasto. BRG-03/06/07/08 bloqueados, BRG-04/05 históricos; 36 migrations UNREVIEWED, 0 pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles insatisfeitos. B1R1 EXPIRED_NOT_EXECUTED, NEW_EPOCH NOT_AUTHORIZED, M3 BLOCKED, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.
- CP187 candidato sob novo Prossiga: confrontar somente evidência do titular quando existir; alto antes de autorização de custos/risco. STOP.


### Fase 4 — Declarações financeiras do proprietário reconciliadas (Documento 143 / CP187)

- Freshness Gate CP186/main `3c236159ab6ceb0c7c02f48542688b70f39f8be7` identical, ahead/behind 0; modo médio, registro documental sem operações.
- Respostas do owner: Free=SIM, serviços pagos=NAO, método de pagamento=NAO, alertas de cobrança/cota=NAO; declaração sem horário de inspeção certificado. API Neon CP186 `free_v3` confirma plano, não certifica negativos financeiros. `BRG-09_OWNER_FINANCIAL_DECLARATION=RECEIVED`; `BRG-09_OPERATIONAL_GATE=NOT_APPROVED`; G0-D5 informational complete, decisão pending.
- BRG-03/06/07/08 bloqueados, 04/05 históricos; 36 migrations UNREVIEWED, 0 pós-condições, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles pendentes. B1R1 expirado, novo epoch não autorizado; nenhuma escrita Neon, custo, consulta PubMed/ClinicalTrials, CI ou PG18. M3 blocked, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.
- CP188 candidato somente com novo Prossiga: consolidar decisão G0, sem repetir perguntas já respondidas. Avisar se alto for necessário para aprovação substantiva. STOP.


### Fase 4 — Consolidação da proposta G0 (Documento 144 / CP188)

- Freshness Gate CP187/main `cea01ebe0aa3fb3721369e1aa80d233d01046e03` identical, 0 ahead/behind; modo médio e documental.
- Documento 144 integra seis pendências G0-D1–D6, informação de Neon Free API e declaração titular de CP187. `G0_OWNER_DECISION=NOT_GRANTED`, `PREPARE_G1_DOCUMENTARY_ONLY=PROPOSED_NOT_AUTHORIZED`; não repetir coleta financeira sem nova justificativa.
- BRG-03/06/07/08 bloqueados; 04/05 históricos; 09 evidência parcial e gate operacional não aprovado. 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles não satisfeitos. B1R1 expirado, novo epoch não autorizado, sem Neon SQL/branch/migrations/roles, CI ou fonte real. M3 BLOCKED; Fase 4 documental NOT_READY; Fase 5 NOT_STARTED.
- CP189 candidato: apresentar deliberação owner objetiva (preparar G1 documental, adiar P-B ou ajustar escopo); alto se decisão de risco/custo/custódia efetiva. STOP.


### Fase 4 — Mandato limitado G1 documental (Documento 145 / CP189)

- Freshness Gate CP188/main `ee1f7c4c98bbdead73452f093e6d0a924aa64f4b` identical 0 ahead/behind, modo médio.
- Proprietário aprovou expressamente `APPROVED — CP189 / PREPARE_G1_DOCUMENTARY_ONLY / OES / zero paid services / no Neon SQL, branches, roles or migrations / no new epoch / no source queries`. Documento 145 formaliza escopo e seis pacotes de planejamento; nenhuma implantação/consulta de fonte/SQL autorizada. G0-D1–D5 ainda pendentes; G0-D6 restrito à preparação documental.
- BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 evidência parcial; 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles não satisfeitas. B1R1 expirado; M3 bloqueado; Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.
- Próximo CP190 candidato inventário G1-MIG **estático**, novo Prossiga obrigatório. STOP.


### Fase 4 — Inventário estático G1-MIG (Documento 146 / CP190)

- Freshness Gate CP189/main `8a799c86caf900bcf9d149620ee19d91de97c37e` identical, ahead/behind 0, modo médio, somente documentação.
- Manifesto 36 entrypoints = catálogo 36 registros UNREVIEWED, zero pós-condições e flags de execução/replay falsas; 031/032/033 incluem 14 SQL subordinados `\\ir`. Documento 146 classifica oito grupos e papel de 033–036. Nenhum subset de instalação ou order de migrations foi aprovado para P-B.
- BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 parcial. 36 evidências 034–036 NOT_COLLECTED e 12 roles insatisfeitos. Nenhum Neon/SQL/CI/PG18, source query ou custo; B1R1 expirado, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED.
- CP191 candidato, somente após Prossiga: closure detalhada dos wrappers e 033–036. STOP.


### Fase 4 — Closure estática de wrappers e camada temporal (Documento 147 / CP191)

- Freshness Gate CP190/main `53cbd7dad1d21594fe66ba60b589f421d4179de9` identical 0 ahead/behind; modo médio. Documento 147: wrappers 031–033 incluem 14 SQL subordinados, objetos de propagation/rebaseline, calibration/cadence/SLA, observation/measurement e hardening 034–036 mapeados; closure de 001–030 não validada.
- Migrações 36 UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles pendentes; BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. Sem SQL/Neon/PG18/CI, sources reais, custo ou epoch. B1R1 expirado, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED. CP192 candidato só sob Prossiga. STOP.


### Fase 4 — Dependências prévias parciais G1-MIG (Documento 148 / CP192)

- Freshness Gate CP191/main `9904f4af48dafbc53441c005b4c7531f3ce5e449` identical, 0 ahead/behind, modo médio. Documento 148 identifica produtores 001/002/027/029/030 de objetos usados por 031–036; as migrations 003–026/028 não foram varridas, `monitor_cycle` ainda não tem produtor confirmado. `REDUCED_INSTALLATION_PLAUSIBILITY=UNDETERMINED`.
- 36 migrations UNREVIEWED, 0 pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles insatisfeitas; BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. Sem SQL, Neon, CI, PG18, dados PubMed/ClinicalTrials, custo ou novo epoch. B1R1 EXPIRED_NOT_EXECUTED, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. CP193 candidato só após Prossiga. STOP.


### Fase 4 — Produtores 021–028 e arestas temporais (Documento 149 / CP193)

- Freshness Gate CP192/main `a7ef8c1a2ae1cde8a3280b302850b34ae0471c17` identical, ahead/behind zero; modo médio, análise estática de oito arquivos SQL.
- `monitor_cycle` confirmado como CREATE TABLE em 021; `update_policy`, `update_signal` e `update_decision` produzidos por 027. Necessidade de 022–026/028 para subset P-B ainda indeterminada; closure 003–020 e funções dinâmicas não validada. Documento 149 publicado.
- 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles insatisfeitas; BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. Sem Neon/SQL/CI/PG18, queries científicas, custo ou epoch. B1R1 EXPIRED_NOT_EXECUTED, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. CP194 candidato só após Prossiga. STOP.


### Governança de continuidade — protocolo equilibrado aprovado (CP194)

- Proprietário autorizou expressamente protocolo equilibrado e revisão do template canônico. `Prossiga` passa a liberar uma atividade interna por vez; checkpoint persistente normalmente após 3–5 atividades, antecipado por risco/decisão/troca de conversa; Freshness Gate no começo de bloco e antes de commit, STATE/CHANGELOG por relevância. CP só avança com commit; atividades não persistidas não são fonte canônica.
- O ponto técnico permanece CP193 / Doc149, com 36 migrations UNREVIEWED, zero pós-condições, 36 evidências 034–036 NOT_COLLECTED, 12 roles pendentes e demais bloqueios. Próxima A1: análise estática da necessidade de 021–028, sem Neon/SQL/CI, fontes, custos ou novo epoch. STOP.


### Fase 4 — Consolidação G1-MIG A1–A4 (Documento 150 / CP195)

- Freshness Gate CP194/main `8c89d3ae5b3f1a99fcba26d4422c36b712ae59b5` identical, 0 ahead/behind. Quatro atividades internas consolidadas após análise de 021–028, FKs em 031c/032a/032b e comparação integral versus reduzida.
- `G1_BASELINE_CANDIDATE=FULL_MANIFEST_36` recomendado exclusivamente para planejamento; `G1_EXECUTION_AUTHORIZATION=NOT_GRANTED`. Nenhuma baseline aprovada, nenhum Neon/SQL/CI ou source query. 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles insatisfeitos. BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. B1R1 expirado, P-B/novo epoch não autorizados, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED.
- Próximo bloco após CP195: A1 revisão documental de evidências BRG-06, só após novo Prossiga, com mensagens intermediárias de progresso. STOP.


### Fase 4 — BRG-06, evidência de transações/CI (Documento 151 / CP196)

- A1–A4 consolidadas: 36 migrations UNREVIEWED, 0 pós-condições, 30 boundaries UNREVIEWED; 031–033 BEGIN/COMMIT com 14 fragmentos sem transaction control explícito; 034–036 sem wrapper. Workflow validate-s5 define `set -euo pipefail` no passo das 36 migrations, `ON_ERROR_STOP=1`. Leitura estática não é prova de rollback.
- BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 parcial; 36 requisitos 034–036 NOT_COLLECTED e 12 roles pendentes. Nenhum Neon/SQL/CI/PG18, queries científicas, gastos ou novo epoch. B1R1 expirado, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Próximo bloco A1 pós-condições documentais. STOP.


### G1-MIG — Pós-condições documentais da migração 031 (Doc152 / CP197)

- A1–A4 consolidadas: 15 tabelas, 22 definições de funções e 26 triggers esperados (17 explícitos + 9 dinâmicos), mais alterações de FK/CHECK/coluna em maintenance.update_signal_source. Matriz proposta de DDL, FKs, guards, estado anterior e rollback; nada inspecionado em PostgreSQL nem aprovado.
- 36/36 UNREVIEWED, zero pós-condições, BRG-03/06/07/08 bloqueados e demais gates inalterados. Sem SQL, Neon, CI, fontes factuais, novo epoch ou custos. Próximo bloco A1: 032a–d, sob Prossiga. STOP.


### G1-MIG — Pós-condições documentais da migração 032 (Doc153 / CP198)

- Quatro atividades A1–A4 consolidadas: 10 tabelas, 56 definições de funções, 23 triggers (quatro CONSTRAINT DEFERRABLE INITIALLY DEFERRED), sete colunas adicionadas a cinco tabelas anteriores. Pós-condições propostas não executadas nem aprovadas.
- 36 migrações UNREVIEWED, zero pós-condições aprovadas, BRG-03/06/07/08 bloqueados, 36 requisitos 034–036 NOT_COLLECTED e 12 roles pendentes. Sem Neon/SQL/CI/PG18, fontes factuais, custos ou novo epoch. Próximo bloco A1: 033a–e, sujeito a Prossiga. STOP.


### G1-MIG — Migração 033, matriz documental de pós-condições (Doc154 / CP199)

- A1–A4 consolidadas: 12 tabelas, 27 funções, 23 triggers, duas views; verificações futuras de lifecycle, tentativas, autoridade, imutabilidade, FKs e concorrência. Documentação não é validação PostgreSQL.
- 36 migrações UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED e 12 roles pendentes. BRG-03/06/07/08 BLOCKED. Nenhuma execução Neon/SQL/CI, consultas factuais, custo ou novo epoch. B1R1 expirado, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Próximo bloco 034. STOP.


### G1-MIG — Migrações 034–036 e reconciliação proposta (Doc155 / CP200)

- A1–A4 consolidadas: 034 trigger/função de cronologia e autoridade em started_at; 035 duas funções STABLE de preflight (10 checks impeditivos e um INFO), sem ativação obrigatória pelo próprio script; 036 função/trigger para primeira conclusão por epoch_source_uuid, concorrência não demonstrada. Matrizes documentais propostas, não executadas nem aprovadas.
- 36 migrations UNREVIEWED, 0 pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles pendentes. BRG-03/06/07/08 BLOCKED; sem Neon/SQL/CI, fontes, gastos ou novo epoch. B1R1 expirado, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Próximo bloco lacunas transversais 031–036. STOP.


### CP201 — Plano transversal G1-MIG/BRG-06 (Documento 156)

- A1–A4 consolidadas: lacunas das migrações 031–036, matriz G1-E01–E06 e plano exclusivamente documental, sem execução ou homologação.
- 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 roles pendentes, BRG-06 BLOCKED e demais gates preservados. Fase 4 NOT_READY, Fase 5 NOT_STARTED. STOP.


### CP202 — Rastreabilidade e granularidade 031–036 (Documento 157)

- 46 identificadores documentais originais associados às entradas 31–36; 12 detalhamentos candidatos (corrigida contagem anterior de 11). Catálogo não alterado.
- 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 roles pendentes. BRG-06 bloqueado, Fase 4 NOT_READY e Fase 5 NOT_STARTED. Sem SQL/Neon/CI/fonte factual ou custo. STOP.


### CP203 — Cenários de verificação 033–035 (Documento 158)

- Doze cenários V033-01–V035-03, oráculos para V033-06 e V035-03, matriz estática/comportamental/concorrente e riscos documentais. Sem execução, aprovações ou alteração do catálogo.
- 36 UNREVIEWED, 0 pós-condições aprovadas, BRG-06 BLOCKED, Fase 4 NOT_READY e Fase 5 NOT_STARTED; demais bloqueios preservados. STOP.


### CP204 — Checklist auxiliar de pré-execução V033-06/V035-03 (Documento 159)

- A1–A4 documentais consolidadas: lacunas de cobertura, AUT-01–AUT-08 subordinados à governança, sem gate paralelo; cenário não executado.
- 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 roles pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY e Fase 5 NOT_STARTED. Nenhum SQL, Neon, CI, medição factual ou custo. STOP.


### CP205 — Pacote conceitual de evidências e oráculos V033-06/V035-03 (Documento 160)

- A1–A4 consolidaram manifesto documental, registro em três camadas e oito variantes, todas sem observações ou aprovação; AUT-01–AUT-08 continuam auxiliares. Sem mecanismos corretivos.
- 36 UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED; sem SQL/Neon/CI/fonte factual/custo. STOP.


### CP206 — Matriz de alternativas C04/T03/T04 (Documento 161)

- A1–A4 consolidam invariantes, hipóteses e alternativas de concorrência, temporalidade e preflight. Nenhum mecanismo escolhido, implementado ou testado; decisões semânticas pendentes.
- 36 UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED; sem SQL/Neon/CI/fontes factuais/custo. STOP.


### CP207 — Contratos semânticos e deliberação futura (Documento 162)

- A1–A4 consolidadas: SEM-01–SEM-06, alternativas, critérios, evidências e responsabilidades propostas. Nenhuma seleção, parecer especializado, autorização ou teste.
- 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Sem SQL/Neon/CI/fonte factual/custo. STOP.


### CP208 — Pacote de revisão independente SEM-01–SEM-06 (Documento 163)

- A1–A4 consolidadas: partes I–V do pacote, PR-01–PR-06 reconciliados à governança existente, REV-01–REV-09 como inventário auxiliar. Sem revisor designado, parecer, gate novo, decisão semântica ou autorização operacional.
- 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Nenhuma operação SQL/Neon/CI, fonte factual ou custo. STOP.


### CP209 — Revisão estratégica de simplificação (Documento 164)

- A1–A4 consolidadas: inventário de ativos F2/F3 e Monitor, proposta D0 documental, D1 sintético e D2 factual posterior, critérios S1–S6. Reorientação estratégica e execução NÃO aprovadas; somente revisão documental autorizada. Nenhum gate alterado.
- 36 UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Sem SQL/Neon/CI/fonte factual/custo. STOP.


### CP210 — Decisão expressa de prioridade documental D0/D1 (Documento 165)

- Proprietário: `APPROVED — OES / CP209 / SIMPLIFICATION_PRIORITY_D0_D1_DOCUMENTARY_ONLY / Priorizar D0, preparar documentalmente D1, diferir D2; sem execução operacional, sem alteração de gates e sem serviços pagos.`
- D0 prioridade documental; D1 planejamento documental apenas; D2 diferido. Sem SQL, Neon, CI, fontes factuais, epoch ou custo. 36 UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. STOP.


### CP211 — Roteiro demonstrativo documental D0 (Documento 166)

- A1–A4: roteiro em cinco quadros, Ficha dCBT-I N2 A2 (revisão independente ausente), Monitor M2 sintético separado, proveniência/limitações e evidências históricas. D0 documentação apenas; D1 preparo documental, D2 diferido.
- 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 roles pendentes; BRG-06 BLOCKED; Fase 4 NOT_READY e Fase 5 NOT_STARTED. Sem novas execuções nem gates. STOP.


### CP212 — Apresentação editorial D0 para pesquisadores (Documento 167)

- A1–A4: revisão de clareza, texto editorial em cinco partes, conferência de rastreabilidade interna e quatro qualificações críticas (A2 publicação interna, Hwang fonte externa, GRADE OES provisória, Monitor sintético). Documento 167 é material preparatório, não revisão científica independente nem envio externo.
- D1 permanece apenas documental e D2 diferido. 36 UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-06 BLOCKED, Fase 4 NOT_READY e Fase 5 NOT_STARTED. Sem SQL/Neon/CI, consultas factuais ou custos. STOP.


### CP213 — Apresentação executiva D0 (Documento 168)

- A1–A4 pós-CP212: diagnóstico de prontidão, texto executivo em duas páginas conceituais, revisão editorial e consolidação no Documento 168. Material para avaliação do proprietário, não diagramado em PDF, não enviado, sem validação científica independente.
- D0 documental priorizado; D1 apenas documental; D2 diferido. Bloqueios históricos e gates preservados; sem SQL, Neon, CI, consultas externas ou serviços pagos. STOP.
