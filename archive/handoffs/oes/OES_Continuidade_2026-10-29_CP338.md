# OES — Continuidade CP338 — 2026-10-29

**Anterior:** CP337. **Branch:** main. **Freshness Gate inicial:** `16a184071ab5ad36c977556bc9a9557ad067f77a`.
**Escopo:** Django First, Marco B técnico-demonstrativo restrito, incremento offline do fluxo Q0 e validação de CI.
**Estado:** Marco B OPEN; E9 NO-GO; Fase 5 NOT_STARTED; execução ORM conectada HARD HOLD.

## Alterações e evidência desde CP337
- `cec30066`: STATE registra decisão expressa de orientar o futuro encerramento de Marco B à suficiência técnico-demonstrativa restrita, mantendo validação científica pendente; não é encerramento antecipado nem alteração do Marco A/Documento 294.
- `8bbfa78a`: função interna dormente `_verify_committed_q0_readback`, conferindo cinco registros Q0 por alias separado de leitura; não executa commit e não comprova sozinha igualdade do branch/endpoint ou ACL SELECT-only.
- `d6cbd82c`: port ORM dormente conserva IDs internos da Q0 e situação do recibo.
- `065b6c5c`: disponibiliza `last_completed_q0` como metadado candidato após saída normal dos contextos; **não** é prova de commit; contrato `PREPARATORY_ONLY` preservado.
- `c8183ff6`: amplia testes offline do port para metadados, falha de recibo e replay.
- CI [40861801605](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40861801605) FAIL 4/253, por testes legados incompatíveis com exigência de alias READ ONLY separado.
- `befdfe82`: atualiza asserções e mock da reconciliação; CI [40862216534](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40862216534) FAIL 1/253 por mock dict sem `connections.databases`.
- `16a18407`: corrige exclusivamente mock Django; CI [40862416668](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40862416668) **SUCCESS, 253/253 PASS**; instalação, compilação e `manage.py check` também PASS. Suíte sem DB; não evidência de DML Neon/commit/readback real.

## Limitações e riscos ainda abertos
- `execute_connected_q0` e `DjangoQ0Repository.__init__` permanecem HARD HOLD. Sem settings writer, segredo ou workflow conectado ativo.
- `_rollback_recipe` força rollback. O readback positivo é interno e não integrado a executor autorizado; `last_completed_q0` é candidato, não resultado persistido.
- Confirmar identidade autenticação/PreparerIdentity e vínculo ao ator; commit efetivo e readback independente das cinco tabelas no mesmo branch; consistência com privilégio mínimo; idempotência/conflito/rollback; apresentação Django. É necessário **gate operacional nominal próprio** antes de qualquer escrita ou configuração conectada. Sem pesquisador vinculado.
- Preservar baseline científica e Q0 sintética legada, não usar limpeza DELETE ou repetir workflows históricos; sem dados reais, E9 ou deploy.
- **Nota histórica:** STATE/CHANGELOG registram ensaio Q0 sintético com commit em [40695250735](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40695250735), com outro executor. Reutilizar essa evidência onde suficiente, mas não atribuir a ela integração do novo port autenticado Django.

## Próximo ponto exato de retomada
Preparar **uma proposta nominal proporcional** para ensaio integrado Django-auth persistido → Q0 ORM → transação com commit autorizado → recibo → readback independente → apresentação; confrontar evidências existentes e reduzir ao mínimo operações necessárias. Antes de requerer autorização, verificar isolamento das credenciais, alvo branch/banco, ACL do writer/reader, escopo DML, snapshot legado, critérios de aceite e resposta a falha; não criar abstrações ou documentação redundante. **Não executar** Neon DML/DDL/GRANT, secrets, workflows conectados ou HTTP write sem autorização expressa nova.

**Governança:** Documento 347 Django First, Documento 362 proporcionalidade, Documento 294 Marco A, STATE decisão de Marco B. CP337 e anteriores preservados. Ponteiro único `archive/handoffs/oes/README.md`.
