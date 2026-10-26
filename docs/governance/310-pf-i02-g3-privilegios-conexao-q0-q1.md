# Documento 310 — PF-I02-G3: privilégios mínimos e fronteira de conexão Q0→Q1

**Data:** 2026-10-25. **Natureza:** diagnóstico técnico read-only; sem SQL conectado, alteração de roles/grants/segredos, implantação ou escrita. **Base:** Docs. 306–309, CP297.

## Situação verificada
- Django atual tem `DATABASES={}` por padrão; PG-A4 opcional é leitor sintético com `default_transaction_read_only=on`; configuração de desenvolvimento `DEBUG=True` e secret fixo não serve ao ambiente operacional.
- Doc. 215 confirmou concessões mínimas **exclusivamente** no banco experimental `oes_t2a2_synthetic` para tabelas `oes_t2a2_proto.scenario/event/receipt`; tais concessões **não abrangem** `core.entity`, `core.entity_version` ou `investigation.question[_version]`. Proibido reciclar `oes_t2a2_app` como writer Q0/Q1.
- Doc. 285 diferiu o ensaio isolado G2-I2 ao piloto integrado, exigindo autenticação independente e prova de transação/commit/leitura restrita/cleanup em ambiente autorizado. Não há evidência de que este gate esteja concluído.
- Login humano Django, role PostgreSQL, proprietário de schema e identidades experimentais E6 são **fronteiras distintas**.

## Política candidata para writer de preparação
1. Uma identidade técnica **não-owner, sem BYPASSRLS, SUPERUSER, CREATEROLE, CREATEDB, herança ampliada ou GRANT OPTION**, dedicada ao write path preparatório e separada da identidade de leitura.
2. `CONNECT` ao banco autorizado, `USAGE` apenas nos schemas necessários; `SELECT/INSERT` e UPDATE **estritamente por coluna/semântica necessária** em `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e objetos de auditoria/idempotência que vierem a ser aprovados. Sem `CREATE` de schema, `DELETE`, `TRUNCATE`, `ALTER`, `DROP` ou acesso à criação de `investigation.investigation`. Examinar o efeito de referências FK, índices de versão corrente e funções/trigger existentes antes de aprovar uma lista definitiva de SQL grants; **nenhum GRANT foi executado**.
3. Conceder ao processo servidor uma credencial técnica via secret manager/variáveis seguras, nunca ao browser, template ou repositório; TLS verificado, credenciais separadas por finalidade e rotação/revogação documentadas. Não reutilizar PG-A4, E6 ou credencial administrativa.
4. Autoria do comando deriva de sessão autenticada Django e é validada na aplicação; o banco verifica a fronteira do papel técnico e a transação. Não confiar em `created_by` fornecido pelo cliente. Logs sem conteúdo de perguntas ou segredos.
5. Dados de teste sintéticos sob autorização; testes negativos obrigatórios de login ausente, permissão ausente, SQL em tabela proibida, tentativa de E9, conflitos concorrentes, retry idempotente, rollback e falha após commit. Procedimento de cleanup e reconciliação explícito.
6. Sem autenticação/host seguros, a escrita HTTP permanece bloqueada. Se a política de Neon Free, quotas, billing ou backup não estiver comprovada no ambiente escolhido, HOLD antes da conexão; nenhum serviço pago.

## Gate técnico do piloto integrado — recomendado
**G3 avaliado apenas como contrato; não aprovado operacionalmente.** Antes de autorizar G4: (a) decisão de ambiente/banco destino e revisão atual de privilégios; (b) aprovação da adaptação mínima Q0-only do Doc. 309; (c) identidade Django real e políticas de sessão/CSRF; (d) proposta de grants exatos com negativas e plano de recuperação; (e) teste conectado restrito explicitamente autorizado e verificável, retomando a obrigação diferida no Doc. 285. Distinguir autorização de alteração de schema, criação/concessão de role e execução de transações: nenhuma implícita.

## Próxima decisão proporcional
Consolidar Docs. 306–310 num **único pacote de decisão PF-I02-I01** para o menor fluxo real Q0→Q1, com sequência de execução, arquivos/esquema afetados, gates e rollback. Não criar demonstrações paralelas ou mais documentação repetitiva.

**Invariantes:** Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; E9 NO-GO; A3 não realizada; pesquisadores indisponíveis.
