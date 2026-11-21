# OES — M3-C | Encerramento técnico da campanha privada sintética

**Data:** 2026-11-21 (America/Recife)  
**Classificação:** `SUCCESS — PRIVATE_SYNTHETIC_Q0 / PERSISTED / Q0_RECORDS`  
**Base de código da execução:** `main` `6029b39a71f7aa1cce1af6e137a34a5fde686ef7` (PR #48).  
**Natureza:** registro histórico do resultado operacional supervisionado; **não é liberação Q0 geral nem homologação de produção**.

## 1. Objeto e ambiente

Jornada única autenticada de preparação Q0 via Django, transação PostgreSQL, recibo, verificação independente D3 e recuperação posterior por referência. Ambiente: GitHub Codespaces, porta 8000 Private segundo operador, Gunicorn com configuração versionada, ingresso HTTPS `*.app.github.dev`. Neon projeto `weathered-boat-65779510`, origem `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), banco `oes_sandbox`. Branch de segurança separada `br-silent-dream-b6mvn50u` (`oes-m3c-pretrial-safety-20261118`), sem restauração executada.

A exceção experimental `OES_CODESPACES_CSRF_LOCALHOST_ORIGIN=1` adicionou exclusivamente `https://localhost:8000` às origens confiáveis sob o perfil privado aprovado. O diagnóstico observou no navegador origem nominal e na entrada WSGI `localhost`. A causa exata dentro das camadas intermediárias não foi isolada; a exceção reduz a garantia de procedência por Origin e pode aceitar origens externas se normalizadas pelo mesmo ingresso. Token CSRF nativo, Auth, permissões, Host nominal e cookies permaneceram em uso. O risco foi aceito para o experimento sintético e não para produção.

## 2. Resultado observado

- O preparador sintético existente autenticou-se após redefinição administrativa de senha. O acesso GET ao formulário confirmou passagem pelas verificações `require_question_preparer` e `persisted_preparer_actor_id`, sem provar autorização para perfis adicionais.
- Três aliases Django (`default`, `oes_q0_writer`, `oes_synthetic_reader`) foram validados em transações explicitamente READ ONLY com papéis, bancos e timeouts esperados; PASS informado pelo operador.
- Imediatamente antes da tentativa, consulta Neon READ ONLY indicou zero colisões em `core.entity.oes_id` e `investigation.question_command_receipt.request_id` e contagens prévias 6 entidades / 2 questões / 2 recibos.
- Uma única submissão HTTP Q0 foi executada, sem retry. A interface apresentou «Registro Q0 íntegro confirmado por leitura independente».
- Solicitação: `OES-M3C-20261118-R01`. Questão: `OES-M3C-20261118-Q01`. Texto original: «Em um cenário inteiramente fictício de serviço de saúde, qual é a diferença entre registrar uma pergunta de pesquisa e realizar sua avaliação científica?».
- Consulta independente **direta ao Neon** após o POST confirmou um recibo correspondente, cinco objetos vinculados, versão inicial 1, estado `current`, etapa `q0_draft`, texto original integral, texto normalizado NULL e autoria compatível com o ator persistido. `committed_at=2026-11-21T13:30:16.169Z`. Totais observados: 7 entidades, 7 versões de entidade, 3 questões, 3 versões de questão, 3 recibos.
- Consulta posterior pelo GET da aplicação retornou `PERSISTED / Q0_RECORDS`, questão e versão 1, fingerprint e texto preservado. Uma primeira consulta informou falta de autenticação/permissão; nova autenticação seguida do GET permitiu recuperação. Expiração de sessão de 900 s é hipótese plausível, não causa comprovada.

## 3. Encerramento, limites e custódia

O operador confirmou logout Django, Gunicorn encerrado e, nos **dois terminais**, `OES_MB_OC1_RELEASE_MODE=HOLD` e `OES_CODESPACES_CSRF_LOCALHOST_ORIGIN=0`. Não houve última atestação independente de ausência universal de listeners nem verificação administrativa de revogações adicionais. Parar processo e alterar variáveis do shell não equivale a revogar segredos ou usuários; não inferir tais efeitos.

A branch de segurança foi observada `ready` após o experimento, mas captura ponto anterior à redefinição da senha e à submissão; recuperação/restauração não testada, RPO/RTO não garantidos. Preservar branch, registros e recibo até decisão de retenção. A preservação de preexistentes foi observada por contagens e referências limitadas, não por auditoria exaustiva de integridade de todo o banco.

**Classificação final M3-C:** sucesso técnico da jornada delimitada, janela encerrada conforme confirmação do operador, com limitações documentadas. Não reutilizar os identificadores para nova submissão, não reabrir escrita ou repetir tentativa.

**Gates inalterados:** Marco B `OPEN`; Q0 geral `HARD HOLD`; Q1 conectado `HOLD`; E9 `NO-GO`; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`.

## 4. Rastreabilidade

- Contrato [P2](OES_Q0_OPERATIONAL_CONTRACT_P2.md), [Documento 362](362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md), [preparo Codespaces](OES_CODESPACES_PREPARATION.md).
- Termo M3-C de preflight/histórico: `review/oes-m3c-preflight-20261118`, commit `c7bf9c7a505abaf93cfe09c37fb6bc06b7186591` (não integrado à main nesta documentação).
- [PR #48](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/48) e squash `6029b39a71f7aa1cce1af6e137a34a5fde686ef7`.
- Capturas operacionais e confirmações do responsável na conversa OES de 2026-11-21. A interface e os resultados do operador não equivalem a CI reexecutada nem a auditoria independente de todos os controles.
