# OES — Continuidade CP339 — 2026-10-29

**Anterior:** CP338. **Branch:** main. **HEAD de referência antes do checkpoint:** `40ae2141f8e5aa4de3f5a602ec665038f6422e2f`.
**Escopo:** Marco B / Bloco A — incrementos do port Django ORM Q0 dormente, tratamento de resultado incerto e validações offline.
**Gates:** Marco B OPEN (futuro encerramento técnico-demonstrativo restrito; validação científica pendente), E9 NO-GO, Fase 5 NOT_STARTED, execução ORM conectada HARD HOLD.

## Conquistas desde CP338
- `1023b7fc` e `6230f481`: port dormente produz argumentos do readback independente a partir de metadados candidatos; testes associados. CI [40863866102](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40863866102) **253/253 PASS** no SHA `6230f481`.
- `806b559a` e `a60ce72b`: verificador injetável opcional, invocado somente após saída normal de ambos os contextos sintéticos; HOLD para readback negativo, testes específicos. CI [40869853541](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40869853541) **255/255 PASS** no SHA `a60ce72b`.
- `c6bded68` e `924583c4`: `last_uncertain_q0` preserva identificadores em memória diante de falha de readback; impede nova tentativa **na mesma instância**, sem garantia interprocessos. CI [40870702644](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40870702644) **256/256 PASS**.
- `e3498c84` e `30b3aaa9`: decisões proporcionais em STATE: não criar ledger paralelo; reconciliar por recibo persistido e cinco registros Q0, sessão independente READ ONLY, resultado ausente/parcial/incongruente = HOLD, sem retry nem DELETE. Compor por instância de port por comando e reaproveitar Django auth e unidade de trabalho já existentes.
- `732bfc09` e `40ae2141`: port dormente preserva candidato Q0 também quando a **saída do contexto transacional** simulado falha após sua constituição; regressão específica. CI [40872403076](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40872403076) **257/257 PASS**, commit `40ae2141f8e5aa4de3f5a602ec665038f6422e2f`. Configuração Django e compilação da receita PASS, sem banco real.

## Suficiência, restrições e riscos
- Camada offline suficiente para os comportamentos ensaiados; evitar novos mocks e ciclos documentais sem objetivo material.
- `submit_authenticated_question_command` obtém ator de `PreparerIdentity` persistido via alias `default`; configuração e vínculo real ainda não demonstrados em conjunto com o novo port.
- `OfflineQuestionUnitOfWork` coordena idempotência, locks e recibo. `DjangoQ0Repository.__init__` e `execute_connected_q0` rejeitam conexão incondicionalmente. `_rollback_recipe` sempre força rollback: não é executor de commit.
- Injeção de context manager/readback nos testes não é evidência de commit PostgreSQL. `last_completed_q0` e `last_uncertain_q0` são mutáveis e **somente memória**; evitar port compartilhado, presume-se instância por comando, ainda sem mecanismo durável de recuperação de falha antes do recibo. Readback pós-commit não reverte escrita confirmada.
- A verificação positiva independente necessita alias/credencial de leitura separada, efetivo READ ONLY, ACL de SELECT mínimo, mesmo projeto/branch/banco e reconciliação por recibo persistido. Uma ausência isolada não prova rollback.
- Prova anterior de Q0 sintético com commit e replay [40695250735](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40695250735) é reaproveitável, mas foi feita por outro executor e não comprova o fluxo Django autenticado atual.
- Não há pesquisadores vinculados; validar Marco B apenas técnico-demonstrativamente quando os critérios próprios forem cumpridos, sem promover resultados científicos. Preservar registros sintéticos e baseline legados.

## Ponto exato de retomada
**Não expandir novamente a preparação simulada.** Delimitar a menor composição conectada Django-auth persistido → port por comando → `transaction.atomic` e cinco INSERTs/recibo Q0 → confirmação de commit → readback independente no mesmo branch/banco → reconciliação por recibo diante de resultado incerto → apresentação sintética Django. Antes de implementar ou ativar conexão, revisar controles de identidade, rollback, ACL/aliases, baseline e efeito da falha após commit; preparar gate nominal específico para eventual execução única, sem supor autorização por `Prossiga`.

**Proibições:** nenhum Neon SQL/DML/DDL/GRANT, mudança de roles, credentials/secrets, workflow conectado, HTTP write, deploy, captura factual, dados reais, serviços pagos ou promoção de gates, até autorização expressa de escopo. O checkpoint é operacional, não normativo.

**Autoridades:** Documento 347 (Django First), Documento 362 (proporcionalidade), Documento 294 (Marco A), `STATE.md` (Marco B), CP338 histórico. Ponteiro único `archive/handoffs/oes/README.md`.
