# CP348 — OES | Primeiro Q0 sintético persistente pelo fluxo canônico: PERSISTED

**Data:** 2026-11-08 (America/Recife).  
**Situação:** checkpoint técnico e documental de continuidade; não é GO de Q0 geral ou autorização para novo despacho.  
**Antecessor:** [CP347](OES_Continuidade_2026-11-08_CP347.md), mantido integralmente como registro histórico.  
**Base operacional do ensaio:** `b48360c862c33b42bc04c9800569a4da855eaff7` (`main` no despacho).  
**Decisão de governança aplicável:** [primeira tentativa administrativa supervisionada](../../../docs/governance/OES_Q0_PRIMEIRO_ENSAIO_PERSISTENTE_AUTORIZACAO_ADMINISTRATIVA_2026-11-08.md) (CP347/PR #29).  
**Execução conectada determinante:** [GitHub Actions #42491887254](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42491887254).

## 1. Implementação incorporada desde CP347

- [PR #30](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/30) squash merge `6ce56217dff562240aeb3b0bc8550fced333a1c6`: CLI reservada, workflow manual, testes e vínculo restrito do ORM à identidade sintética persistida, comando/fingerprint, conexão writer, transação, trace e xid. Relato Codex de 133 testes offline PASS; arquivos/hashes revisados na integração; não tratar como testes conectados.
- [PR #31](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/31) squash merge `b48360c862c33b42bc04c9800569a4da855eaff7`: ativação delimitada de escrita sintética e recuperação independente READ ONLY com autorizações distintas; workflow `workflow_dispatch`, `REVIEW_ONLY` por padrão; jobs mutuamente exclusivos por condições de modo/autorização. Relato Codex de 139 testes offline PASS; revisão de patch e hashes na integração; testes não reexecutados independentemente.
- **Bloqueios gerais intocados:** `DjangoQ0Repository` sem writer interno permanece HOLD, `execute_connected_q0()` permanece HOLD, HTTP mutante Q0 retorna 423. Caminho excepcional do PR #25 não foi utilizado.

## 2. Primeira execução sintética persistente: evidência da run

- **Run:** [#42491887254](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42491887254).
- **Data/hora GitHub:** 2026-11-08 14:51:55–14:52:42 UTC; evento `workflow_dispatch`; branch `main`; SHA `b48360c862c33b42bc04c9800569a4da855eaff7`; `run_attempt=1`.
- **Resultado geral:** `completed/success`.
- **Jobs:** `review-only` `success`, `first-commit` `success`, `independent-reconciliation` `skipped` (não houve despacho de recuperação separado).
- **Marcador terminal observado no log do job conectado:** `phase=RESULT`, `outcome=PERSISTED`, `scope=Q0_RECORDS`, `automatic_retry=false`, fingerprint e identificadores reservados correspondentes ao manifesto embutido no CLI.
- **Request ID fixo:** `q0-general-first-6bf4279cc0844fda9ad4d07f5656fb0a`.
- **Question ID fixo:** `OES-SYNTH-Q0-GENERAL-FIRST-6bf4279cc0844fda9ad4d07f5656fb0a`.
- **Fingerprint:** `5331c6337bb7fe19c29a43b659722844b8591c100a56d3e7333b3c853a2ae667`.
- **Interpretação restrita:** o job passou pela execução canônica Django e emitiu `PERSISTED` conforme o contrato de verificação D3 da própria aplicação; constitui a **primeira evidência conectada positiva de persistência Q0 sintética pelo fluxo canônico**. O marcador, e não apenas `success` do job, fundamenta essa classificação.

## 3. Limitações e fronteira de evidência

- Logs e implementação foram conferidos; **não foi feita uma auditoria SQL READ ONLY adicional e independente dos cinco registros após a run** neste checkpoint. A reconciliação D3 embutida no caminho normal foi executada de acordo com o contrato reportado; o job de recuperação separado ficou `skipped`.
- Não afirmar que todos os cenários de falha/recuperação foram comprovados em PostgreSQL conectado, nem que houve validação do sistema com pesquisadores reais.
- Nenhum retry ou nova tentativa de COMMIT é recomendado ou autorizado. Se evidências futuras forem contraditórias ou insuficientes, classificar e tratar por mecanismo READ ONLY autorizado separadamente, nunca por nova tentativa automática.
- A decisão do CP347 aceitou **ausência de consumo atômico/durável da autorização** somente neste ensaio supervisionado; o resultado `PERSISTED` não transforma a autorização em exactly-once.
- O responsável **declarou a exclusão** das variáveis `OES_Q0_FIRST_APPROVED_SHA` e `OES_Q0_FIRST_AUTHORIZATION` após a execução. Não foi feita consulta independente à configuração administrativa do GitHub. Não afirmar confirmação técnica de revogação, nem modificação dos secrets existentes.
- A exclusão das variáveis da atestação READ ONLY anterior também havia sido declarada pelo responsável antes do despacho atual, sem verificação administrativa independente.

## 4. Encerramento proporcional do marco

Classificar como **PASS conectado restrito — FIRST_CANONICAL_Q0_COMMIT / PERSISTED / Q0_RECORDS** para **uma questão sintética reservada** no ambiente experimental. O marco comprova capacidade do fluxo canônico D1/D2/D3 no escopo executado; não representa GO geral, autorização de novas escritas, HTTP mutante, implantação, dados reais ou promoção científica.

**Gates após o ensaio:** Marco B OPEN; Q0 geral HARD HOLD para uso normal; E9 NO-GO; Fase 5 NOT_STARTED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY.

## 5. Continuidade, macroatividades e acordos

1. **Encerrar** a tentativa persistente e preservar o link da run, SHA, manifesto reservado e decisão CP347 como evidência. Não repetir a tentativa.
2. **Reavaliar macroatividades** para transição do demonstrador ao uso controlado: governança de identidade e acesso de pesquisadores reais (ainda indisponíveis), contrato de registro Q0 pela interface, controle transacional/idempotência, política de auditoria e configuração futura de ambiente de produção. Não converter a prova sintética diretamente em disponibilidade pública.
3. Priorizar evolução funcional proporcional e evitar novos executores sintéticos, diagnósticos redundantes e microgates. Não supor que E9 ou Fase 5 estejam autorizados.
4. Estratégia ChatGPT–Codex–GitHub: ChatGPT coordena/revisa, Codex implementa e testa em branch isolada, GitHub `main` persiste decisões e código. Autorização única condicional de publicação+merge para **patch offline revisado** não abrange execução conectada, segredos, SQL, grants, deploy ou ativação de HTTP.
5. Na retomada, executar Freshness Gate consultando `main`, `STATE.md`, ponteiro de handoff, este CP348 e CP347. Usar registros antigos como históricos e não descrever seus estados anteriores como atuais.

**STOP:** este checkpoint não autoriza qualquer nova operação conectada, dispatcher, recuperação READ ONLY ou alteração de gates.
