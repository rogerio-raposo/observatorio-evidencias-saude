# OES — CP323 | PF-I04/P4-A21–A24 — pacotes SQL sob HOLD e ressalva PUBLIC

**Data:** 2026-10-27. **Anterior:** CP322. **HEAD-base verificado no início:** `3186476599a750d5e9eaeb184b6b59f3c8af50a8`. **Objetivo:** persistir com integridade os artefatos documentais da etapa e registrar limitações de aceitação. **NENHUM dos arquivos deste checkpoint autoriza SQL, operação administrativa, conexão Django, HTTP, deploy, ou dados reais.**

## 1. Alvo e decisões preservadas
- Projeto Neon exclusivamente sintético `weathered-boat-65779510` / branch `br-gentle-hall-b6jaxehf` / banco `oes_sandbox`. Nenhuma consulta ou mutação Neon em P4-A21–A24 ou na publicação deste checkpoint.
- `oes_runtime`: papel técnico criado manualmente em P4-A13, LOGIN=true, INHERIT=false, sem poderes administrativos ou memberships, com credencial privada; nenhuma conexão runtime aprovada. A baseline P4-A14 negou direitos nas 9 tabelas Django, 5 tabelas Q0 e 8 sequências Django. CONNECT no banco já presente.
- `oes_django_migrator`: preservado NOLOGIN e sem CREATE no schema; é proprietário das tabelas Django. Associação original migrador→owner (`oes_sandbox_owner`) catalogada em P4-A18: OID `155649`, `grantor=cloud_admin`, `ADMIN=true`, `INHERIT=false`, `SET=false`. Não alterar, revogar, substituir ou supor reversibilidade sem teste/gate.
- Bloco A de privilégios Django ainda não concedido. Bloco B Q0 separado e diferido. Permissão Django `evidence.prepare_question` (P4-A9 ID 41) cadastrada, não atribuída. Autenticação Django real, sessão conectada e fluxo HTTP indisponíveis.

## 2. Atividades consolidadas
**P4-A21 — SQL transacional v2 candidato, DOCUMENTAL / HOLD.** Preparados contrato Markdown, transação v2 e postflight separado. Transação contém `RAISE EXCEPTION` incondicional antes de operações mutantes; sua retirada NÃO está autorizada. O contrato pretende preflight, associação temporária via grantor owner, `SET LOCAL ROLE`, GRANTs mínimos do Bloco A, restauração, REVOKE grantor-aware com RESTRICT e validação, mantendo migrador NOLOGIN e ownership. SQL não validado em PostgreSQL 18, nem ensaiado no Neon; não usar como procedimento operacional. SQL de P4-A19 continua SUPERADO, nunca executar.

**P4-A22 — parecer independente estático.** Encontrada insuficiência do postflight independente P4-A21: produz informações para inspeção, mas não um único resultado automatizado PASS/HOLD com contrato integral. Pendentes validação sintática, atomicidade de sessão/canal, grantor, rollback e comportamento de revogação. Resultado `STATIC_REVIEW_PASS_WITH_RESERVATIONS / OPERATIONAL_HOLD`.

**P4-A23 — verificador READ ONLY PASS/HOLD candidato.** Preparado um único `WITH ... SELECT` para checagem de catálogos e privilégios; compara matrizes por operação/coluna, inventário nominal, propriedades, memberships e ACLs **diretas ao runtime**. Consulta não executada no PostgreSQL 18 nem no Neon. Baseline **esperada** é SUMMARY=HOLD pré-Bloco A, pois não houve GRANTs; não presumir resultado de execução. SHA-256 imutável da versão proposta: `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7`.

**P4-A24 — parecer de revisão estática e gate READ ONLY candidato.** O verificador A23 passou checagem léxica/estrutural, NÃO parsing/executabilidade em PostgreSQL 18. Achado **A24-R01 BLOQUEANTE PARA ACEITAÇÃO FINAL**: compara ACLs apenas de `oes_runtime`, não examina integralmente privilégios para `PUBLIC` (grantee=0) nem terceiros; PASS da versão atual poderia ocultar exposição adicional. Achados adicionais: ausência de inventário fechado de colunas, escopo limitado a objetos nominais, resultado potencialmente extenso/truncado, parser conectado não testado, transação administrativa não ensaiada. P4-A24 preparou gate P4-A25 para execução de **um SELECT catalogal específico** A23 identificado por SHA-256, apenas após aprovação nominal. O gate é de **validação técnica e baseline esperada HOLD**, NÃO certificação de isolamento ou concessão.

## 3. Artefatos originais preservados no GitHub
Diretório **`archive/handoffs/oes/artifacts/CP323/`**. Todos os sete arquivos foram publicados e seus **Git blob SHA-1 conferidos byte a byte** contra os arquivos locais; não confundir com hashes SHA-256 de conteúdo.

1. `OES_PF-I04_P4-A21_TRANSACAO_V2_CANDIDATA_HOLD.sql` — **NÃO EXECUTAR**, trava `RAISE EXCEPTION`; Git blob `8a857c1e415a7fb9445ba077d53287b19a6a7e73`.
2. `OES_PF-I04_P4-A21_POSTFLIGHT_INDEPENDENTE_CANDIDATO.sql` — postflight parcial, NÃO suficiente; Git blob `22a69db0f394e1d4a76c2c489ef269849deee4f8`.
3. `OES_PF-I04_P4-A21_REVISAO_V2_CANDIDATA.md` — contrato/HOLD; Git blob `4c05e00387b70a243f61e7b4575f7403d122c85e`.
4. `OES_PF-I04_P4-A22_PARECER_INDEPENDENTE.md` — reservas da revisão; Git blob `5d581e5bdd25e38b148b48c2e7243a5e2417ec52`.
5. `OES_PF-I04_P4-A23_VERIFICADOR_PASS_HOLD_CANDIDATO.sql` — **somente candidato READ ONLY**, não validado conectado, SHA-256 `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7`; Git blob `e1b6de7b0787387c970d38169e419540178bc197`.
6. `OES_PF-I04_P4-A23_CONTRATO_VERIFICACAO.md` — limitações e expectativas; Git blob `e115b5f3051c59ea87702ac846620ac7c58df66e`.
7. `OES_PF-I04_P4-A24_PARECER_E_GATE_READ_ONLY.md` — riscos A24-R01–R06 e texto exato de autorização P4-A25 ainda não concedida; Git blob `a95729719609cecfcc49cd6c128a0c6d095dd915`.

Os pacotes ZIP locais A21 e A23 foram inspecionados e continham os respectivos arquivos acima. Os ZIPs em si não foram versionados; **as fontes originais, completas e verificadas, foram persistidas**.

## 4. Gates e fronteiras
- Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; PF-I04/P4 `NOT_AUTHORIZED`. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`. Sem pesquisadores vinculados, dados reais, trabalho científico promovido, serviço pago, HTTP ou deploy.
- Proibidos sem aprovação nominal própria: GRANT, REVOKE, SET ROLE, ALTER ROLE, associação de roles, remoção da trava HOLD, SQL mutante, atribuição de permissão a usuários, credenciais, conexão do Django, INSERT Q0 e scripts administrativos.
- P4-A23 candidato pode ser testado exclusivamente como READ ONLY, com autorização **P4-A25** exata no parecer A24. Um esperado HOLD pré-GRANT não autoriza mutação; saída truncada/incompleta ou inesperado PASS é HOLD de investigação.
- A lacuna A24-R01 precisa ser corrigida em **versão futura diferente e identificada por novo SHA** para aceitação final; não afirmar que A23 certifica ausência de exposição PUBLIC.

## 5. Ponto exato de retomada
**PF-I04/P4-A25 (condicionado à autorização nominal):** avaliar e, se autorizado, executar exatamente um SELECT catalogal do arquivo A23 SHA-256 `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7` na branch sintética para validar parsing e baseline HOLD, sem dados da aplicação e sem nenhuma modificação. Alternativamente, próxima `Prossiga` sem autorização nominal permite apenas preparar documentação/gate ou corrigir A24-R01 offline, não rodar SQL. Após A25, priorizar melhoria do checker de PUBLIC e decisão sobre testes em ambiente seguro. Freshness Gate antes de qualquer commit; checkpoint proporcional; cada `Prossiga` = uma atividade interna e STOP.
