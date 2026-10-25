# Documento 291 — Encerramento técnico restrito P1-A3

Data: 2026-10-25. Status: CLOSED_TECHNICAL_RESTRICTED_OFFLINE.

A composição sintética offline E6 → D1 → domínio documental Django foi implementada no commit a6a873ba38bfe400d5af73a274c005ba93df2e8e e corrigida no commit 3c9672e0fb4b961eedd28ab3d7399ab403d756f7 para consultar `event_log` no replay do D1.

Primeiro teste CI 40198850247: FAILED, 3 erros nos cenários de sucesso. Reexecução CI https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40214460778: 107/107 PASS, oito novos testes P1-A3 PASS, zero erros. O resultado é restrito à composição offline, preparação SHA-256, sinal D1 e referência documental explícita. Não comprova gravação, readback PostgreSQL, captura factual, avaliação científica nem integração Django via HTTP.

Continuidade: P2 deve começar com contrato mínimo de apresentação sintética segregada no Django; evitar vínculos científicos presumidos e infraestrutura transitória. Documentos 287, 288 e 290 preservados; pesquisadores ainda não disponíveis, validação externa diferida. Fase 4 documental apenas, NOT_READY; Fase 5 NOT_STARTED. Nenhum gate operacional liberado.
