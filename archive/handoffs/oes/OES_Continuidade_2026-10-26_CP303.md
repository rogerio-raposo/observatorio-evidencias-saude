# OES — CP303 | Handoff de encerramento e retomada segura

**Data:** 2026-10-26. **Anterior:** CP302. **HEAD de referência (antes deste checkpoint):** `58209b873d75291603f4bb9a8519f3ab2c6d3fa2`. **Documentos materiais:** 317, 319, 321–334.

## Freshness Gate e reconciliação
No encerramento, `main` avançara um commit além do Documento 333: o Documento 334, política mínima de leitura e fronteira do writer, já constava na branch. Foi lido e incorporado. Não reverter, sobrescrever nem duplicar Doc.334. Verificar novo HEAD no começo da conversa seguinte, após os commits deste handoff.

## Estado técnico comprovado
- **PF-I02 I01-C/D0:** esquema Q0-only aplicado e verificado na branch sintética `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`, banco `oes_sandbox` (Docs.317/319); ensaio Q0→Q1 sob owner aprovado, com versão atual única, Q0 preservada e limpeza completa; zero resíduos.
- **Ledger:** `investigation.question_command_receipt` criado conforme DDL Doc.330 e verificado em modo READ ONLY (Doc.331). Não aplicar DDL novamente. Zero registros observados após criação, sem DML de ledger.
- **W1/W1B:** contrato Django em `applications/oes_web/evidence/question_preparation.py`, porta UoW offline em `question_uow_offline.py` e testes, inclusive replay reautorizado e justificativa Q1. CI final de correção `40266729081` success. Não existe adapter PostgreSQL writer funcional, ledger operacional nem endpoint write habilitado.
- **Privilégios:** `oes_qprep_writer` inexistente. RLS ausente nas tabelas de preparação e ledger. `PUBLIC` sem SELECT/INSERT/UPDATE nessas tabelas nem CREATE/USAGE nos schemas `core`/`investigation`. Função `core.assert_entity_type()` SECURITY INVOKER, referência qualificada a `core.entity`, EXECUTE por PUBLIC, sem evidência de elevação por SECURITY DEFINER. Dono `oes_sandbox_owner` tem BYPASSRLS/memberships experimentais: jamais identidade Django.
- **Doc.334:** piloto conectado candidato restrito a um preparador sintético; matriz NOLOGIN só design; `W2A_RUNTIME_HOLD` enquanto não demonstrados isolamento de leitura, privilégios negativos e identidade efetivamente independente. Sem autorização para CREATE ROLE/GRANT, credenciais, SET ROLE ou HTTP.

## Invariantes e método
Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; A3 ausente, não há pesquisadores vinculados; E9 NO-GO; sem dados científicos factuais novos, sem publicações/operações externas, sem serviços pagos. `Prossiga` autoriza uma atividade delimitada, nunca mutações SQL/roles/credenciais sem aprovação nominal. Freshness Gate antes de alterações e commits. Checkpoint normalmente após 3–5 atividades, com atualizações materiais em STATE/CHANGELOG. Informar progresso.

## Ponto exato de retomada
**Não abrir W2a automaticamente.** Ler Docs. 333–334 e rever com espírito crítico se resta alguma verificação proporcional para pacote de autorização **NOLOGIN sintético de laboratório** sem conceder privilégio que simule segurança de runtime. Preferir conclusão objetiva de gate, não novos documentos circulares. Se segurança e escopo estiverem suficientemente descritos, produzir uma autorização única com SQL preciso, checks positivos/negativos, cleanup/revoke grantor-aware, sem LOGIN/credentials, sem Django, sem E9. Se não, registrar impedimento concreto e propor alternativa de menor complexidade. Qualquer execução depende de aprovação expressa do usuário.

## Instrução para nova conversa
Usar o template `archive/continuity/OES_Template_Abertura_Continuidade.md` em Modo Continuidade; consultar `archive/handoffs/oes/README.md` como ponteiro único; ler este CP303 e executar Freshness Gate em `main`. Não retomar esta conversa encerrada sem dupla confirmação.
