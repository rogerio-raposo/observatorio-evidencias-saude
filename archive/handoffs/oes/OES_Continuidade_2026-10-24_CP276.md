# OES — CP276: reconciliação PG-A4 e próximo gate E6

**Data:** 2026-10-24. **Anterior:** CP275. **HEAD-base:** `3272a702a3c784797cf52bc0d29d94104bcef1e8`. **Ponteiro operacional:** `archive/handoffs/oes/README.md`. Checkpoint imutável e operacional, não normativo. Documentação canônica prevalece.

## Escopo e evidências A1–A3

**A1 — Quarto invariante PG-A4:** inspecionados `database/fixtures/pg_a4_g2b_synthetic.sql`, `applications/oes_web/evidence/synthetic_pg_reader.py`, `applications/oes_web/scripts/check_pg_a4_connected.py` e log do GitHub Actions run `40110909348` (job `120922243646`). A fixture insere exatamente um registro em **`provenance.record`** com UUID `a4300000-0000-4000-8000-000000000001`, associado à Study version `a4100000-0000-4000-8000-000000000001` pelo campo `target_version_uuid`; o leitor Django usa `LEFT JOIN provenance.record p ON p.target_version_uuid = sv.version_uuid AND p.status='active'`. A assertiva histórica valida o UUID e `field_path='title_or_label'` na projeção dos três vínculos; a mesma proveniência aparece em duas linhas porque Study 1 tem dois links. A consulta posterior a `evidence.result_source=0` refere-se a **tabela distinta**. Divergência conceitual esclarecida: **nenhuma perda demonstrada**. Não houve consulta atual a `provenance.record`, logo **persistência presente do quarto invariante não está reatestada**; não declarar 4/4 atestados na data.

**A2 — Revisão B2:** Documento 284 comprova no escopo relatado um INSERT inteiramente sintético de 18 bytes sob `current_user=oes_e6_writer`, leitura privada por `oes_e6_verifier`, integridade SHA-256, DELETE seletivo, retorno a zero linhas e revogação com grantor correto dos grants transitórios; testes ACL negativos históricos no Documento 272. **Recomendado encerramento técnico restrito de B2**, sem ampliar a natureza do ensaio: `session_user=oes_sandbox_owner` e alternância por SET ROLE, **não** duas autenticações independentes; SQL Neon, **não** aplicação Python/driver; login de captura NOLOGIN com senha antiga não comprovadamente invalidada. Nenhuma repetição de B2.

**A3 — Próxima fronteira:** implementação sintética **G1 offline sem rede**, aproveitando `tools/d2_e5_preservation/e6_private_pg_offline.py` e `e6_private_roundtrip_offline.py`, por adaptador mínimo DB-API/driver e leitor restrito injetado; nenhuma nova arquitetura genérica de storage. Corrigir diferenças entre o contrato de `prepare_observation()` (exige `source_name` e timestamps `datetime` aware) e `e6_capture.py` (timestamps ISO string e ausência de `source_name` na proveniência). Manter tratamento fail-closed, sem bytes brutos em resultados/logs. A gravação hoje faz commit antes do readback: falha posterior deve produzir `HOLD`, possível registro persistido e investigação/limpeza autorizada, nunca retry cego. **G2 conectado sintético** é gate independente, sujeito a aprovação específica de identidade, rede, credenciais, permissões, teste e limpeza. Nenhum G1 ou G2 implementado/executado por A3.

## Estado, limites e pendências

- Neon Free: projeto `weathered-boat-65779510`, branch sintética `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`; nenhum SQL realizado em A1–A3. A tabela privada foi observada vazia ao encerrar B2; não reatestada agora. Preservar fixture PG-A4.
- CI anterior `40126123398`: **63/63 PASS offline**, sem equivalência com execução Python conectada.
- Política Documento 269: JSON bruto original nunca em commit, artifact público ou log. Piloto PostgreSQL `bytea` privado e portabilidade futura para object storage; sem serviço pago.
- Workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` mantém `if: ${{ false }}` e caminho antigo `upload-artifact` incompatível com bytes factuais privados. **Não executar ou habilitar**.
- E6-G1 factual **NOT_AUTHORIZED**: sem GET, credenciais, secrets, grants, ativação de workflow, publicação, promoção científica ou operacional por inferência.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 `PARTIAL`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.

## Ponto exato de retomada

1. Em nova conversa aplicar template em Modo Continuidade, ponteiro, CP276 e Freshness Gate (STATE/CHANGELOG/documentos pertinentes).
2. **Próxima atividade única sob novo `Prossiga`:** preparar deliberação de autorização **G1 offline/no-network**, escopo mínimo, interfaces e testes necessários, distinguindo claramente preparação de autorização e sem iniciar código automaticamente; avaliar se presença atual da proveniência precisa de uma consulta read-only independente (requer autorização se realizada).
3. Exigir aprovação própria antes de código G1 se ainda não aprovada; G2 conectado ainda mais restrito e separado. Não repetir B2 ou 63 testes anteriores sem mudança material.
4. Um `Prossiga` por atividade, checkpoints normalmente após 3–5 atividades, observabilidade de progresso, Freshness Gate antes de commits. STOP após checkpoint.

**STOP — CP276.**
