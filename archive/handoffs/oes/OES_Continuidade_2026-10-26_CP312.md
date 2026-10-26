# OES — CP312 | G2-P0 verificado e G2-P1 validado offline
**Data:** 2026-10-26. **Anterior:** CP311. **Status:** checkpoint de continuidade vigente após ativação do ponteiro. **Base HEAD pré-checkpoint:** `35b90cb52ab7737d001c476fa1fb03567fd6f6e2`.

## Resumo executivo
A estratégia **Django-first** avançou da compilação ORM de 150 testes para **167/167 testes PASS**. O G2-P0 foi executado exclusivamente como catálogo Neon READ ONLY sob autorização nominal; o G2-P1, autorizado para código somente, foi implementado e validado offline. **G2-P2 não está autorizado.** O repositório ORM Q0 é propositalmente ininstanciável; não há writer Django nem transação conectada. Manter Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO, Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY.

## Rastreabilidade e evidências
- CP311 e Docs 347–349: decisão Django-first; 5 modelos `managed=False` com PK composta do ledger. CI [40282204788](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40282204788) 150/150 PASS.
- Correção ORM da relação composta e exposição de Q0 `original_text`, CI [40282697352](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40282697352) 150/150 PASS.
- Doc350 e compilação offline dos INSERTs e UPDATE Q1, CI [40283190757](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40283190757) 154/154 PASS.
- Fronteira atômica simulada com rollback e replay, CI [40283529418](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40283529418) 158/158 PASS.
- Doc351 e port Q0 somente offline, CI [40284115786](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40284115786) 162/162 PASS.
- Repositório ORM Q0 dormente, CI [40284472284](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40284472284) 165/165 PASS.
- Doc352 propõe gates G2-P0/P1/P2 em separado; Doc353 registra G2-P0 executado com autorização READ ONLY: projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`. Session/current user `oes_sandbox_owner`; papel-alvo `oes_qprep_writer NOLOGIN`, USAGE schemas core/investigation, SELECT+INSERT cinco tabelas; UPDATE de coluna apenas `core.entity_version(version_status,valid_to)`; sem UPDATE investigation.question, sem DELETE, RLS off. Sem DML, DDL, SET ROLE ou leitura de conteúdo.
- Doc354 registra G2-P1 **código somente**, autorizado separadamente: complementou repositório dormente com consultas por escopo e recibo e dois advisory locks. CI [40285338405](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40285338405), commit `35b90cb52ab7737d001c476fa1fb03567fd6f6e2`, **167/167 PASS**, Django check sem problemas.

## Arquitetura e fronteira
`applications/oes_web/evidence/models.py`: cinco modelos `managed=False` para `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version`, `investigation.question_command_receipt`; PostgreSQL permanece fonte de verdade para FKs compostas, índices e CHECKs.
`question_preparation.py`, `question_uow_offline.py`: contratos de comando, fingerprint, escopo, versões e replay. `question_orm_transaction_offline.py`: QuerySets compilados; `question_orm_atomic_boundary_offline.py`: factories simuladas. `question_orm_q0_dormant.py`: coordenação sintética Q0 e recibo. `question_orm_q0_repository_dormant.py`: cinco métodos Django `objects.using(alias).create`, leitura ORM e SQL restrito para advisory xact locks; o `__init__` **sempre lança PreparationHold**. Q1 ainda bloqueado. `question_sql_port_offline.py`: laboratório histórico, não backend obrigatório de produção.

## Bloqueios e riscos
- **G2-P2 NO-GO**, precisa de autorização nominal nova e preflight proporcional antes de qualquer ensaio transacional sintético (mesmo com rollback).
- Nenhum alias writer configurado; não contornar construtor nem usar `oes_sandbox_owner` como writer por conveniência. Identidade runtime de privilégios mínimos ainda não provada.
- Ensaios de SQL/ORM e rollback sintético **não** provam execução PostgreSQL real, concorrência, atomicidade ou isolamento de acesso; `managed=False` não impede escrita por si só.
- Não executar `FOR UPDATE` em `investigation.question`, sem privilégio UPDATE; qualquer alteração de responsável deve cooperar nos locks. Sem usuários reais/pesquisadores, consultas factuais, HTTP write, E9, deploy ou serviços pagos.
- Não criar mais simulações como substituto indefinido para validação conectada; manter registro preciso das limitações.

## Próximo passo controlado
Preparar a decisão nominal G2-P2 com identidade técnica, protocolo de rollback, execução mínima e verificação de resíduos; **não executar antes de aprovação específica**. Caso a identidade mínima não seja viável sem grants ou mudanças de configuração, HOLD e propor alternativa explicitamente. Preservar protocolo equilibrado de checkpoints, Freshness Gate na retomada e pré-commit.

**Estado:** `CP312_ACTIVE / G2_P0_READ_ONLY_COMPLETE / G2_P1_OFFLINE_167_PASS / G2_P2_NO_GO / E9_NO_GO`.
