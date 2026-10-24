# OES — CP273: PG-A4 encerrado; D2-E6 pré-upload sintético validado

**Data:** 2026-10-24. **Anterior:** CP272. **HEAD pré-checkpoint:** `2764a6c0f4c55024dea3819ae0048451429d1722`. **Estado:** `PG_A4_CLOSED_SYNTHETIC_TECHNICAL_RESTRICTED / D2_E6_PREUPLOAD_OFFLINE_PASS_38_OF_38 / E6_G1_NOT_APPROVED / FACTUAL_CAPTURE_BLOCKED`.

## 1. Fonte canônica e evidências
Repositório `rogerio-raposo/observatorio-evidencias-saude`, branch `main`; aplicar Freshness Gate antes de qualquer escrita. CP272 continua histórico e é substituído por este checkpoint. Documentos 262–266 tratam PG-A4; Documento 267 registra encerramento técnico restrito do hardening pré-upload D2-E6; Documento 255 contém gate E6-G1 ainda não executivo. `STATE.md` é cumulativo e tem referências históricas desatualizadas; ponteiro `archive/handoffs/oes/README.md` e checkpoint atual prevalecem.

## 2. PG-A4 — encerramento restrito
- Neon Free `oes-sandbox`, projeto `weathered-boat-65779510`, branch sintética **não principal** `br-gentle-hall-b6jaxehf`, endpoint `ep-wispy-dream-b6021bw0`, database `oes_sandbox`, role SELECT `oes_pg_a4_reader`; `production` não tocada.
- Fixture artificial foi inserida **uma vez** na branch sintética e permanece: 4 entidades (2 Studies, 2 Reports), 3 vínculos Study–Report, 1 proveniência, `SYNTHETIC_TECHNICAL_ONLY`. Não repetir inserção nem remover sem nova decisão.
- CI conectada [40110909348](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40110909348): `success`, 3 vínculos e 1 proveniência confirmados via Django, identidade read-only. CI offline [40111540817](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40111540817): **33/33 PASS**, inclusive indisponibilidade de conexão **simulada**. Documento 266 formaliza PG-A4 `CLOSED_SYNTHETIC_TECHNICAL_RESTRICTED`.
- Usuário confirmou rotação da senha temporária e exclusão de `OES_PG_A4_PASSWORD`; confirmação humana, não auditoria administrativa. Não reabrir acesso conectado automaticamente.
- Avaliação posterior: **reter provisoriamente** a branch e fixture, sem reinserção/limpeza nem novos recursos por inferência.

## 3. D2-E6 — validação sintética pré-upload
- Implementados em `tools/d2_e5_preservation/e6_capture.py`: `HOLD` conservador para estrutura inesperada; `resultsSection` e `documentSection` aceitos; rótulos `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED / TEMPORARY_ARTIFACT` em manifesto e resumo; novo passo `--verify-upload` antes de `actions/upload-artifact@v4` no workflow factual, com identificação pública dos dados brutos.
- CI [40112281012](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112281012) 32/32 PASS; [40112626355](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112626355) 36/36 PASS; [40112908037](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112908037), revisão `59c9f34ce725c64df82177a33d61b07ed7a9568b`, **38/38 PASS**. Documento 267 encerra apenas o hardening no escopo sintético.
- Limites: não prova compatibilidade total da API, segurança de publicação do JSON bruto, ausência de dados pessoais, ingestão, validade científica ou execução conectada.
- O workflow `.github/workflows/d2-e6-a2-gated-capture.yml` permanece com job `if: ${{ false }}`. **Nenhum GET factual autorizado/executado nesta sequência.**

## 4. Ponto exato de retomada
**Preparar revisão proporcional e decisória de E6-G1 sem executar factual**, com base no Documento 255 e Documento 267: identificar responsabilidade humana e prazo de análise integral do JSON, aceitação explícita de potencial exposição pública do artifact temporário, conferência de termos de reutilização e URL/commit atuais. Distinguir claramente decisões pendentes de condições já atendidas; não gerar nova infraestrutura privada sem exigência. Solicitar aprovação específica do proprietário antes de qualquer desbloqueio ou GET. E6-G2 de publicação durável permanece separado.

## 5. Restrições e maneira de trabalhar
Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; `NOT_READY` operacional; D1 demonstrador sintético restrito; D2 `PARTIAL`; E6-G1 `NOT_APPROVED`; M3 `BLOCKED`, BRG/SA pendentes; 36 migrations `UNREVIEWED`; Fase 5 `NOT_STARTED`. Não promover ciência, liberar público, executar HTTP factual, migrar banco, tocar produção ou contratar serviços por inferência.

`Prossiga` = uma atividade delimitada; aguardar STOP; checkpoint a cada 3–5 atividades ou risco; avisos de progresso quando necessário. Freshness Gate antes de alteração e commit. Sem segredos no repo/log. Sem retrabalho ou abstrações antecipadas.

**STOP — CP273.**
