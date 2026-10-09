# 103 — Resultado de Hardening: Identidade dos Artefatos e Proveniência Offline

**Projeto:** OES — Fase 4 — Protocolo de Atualização  
**Data:** 2026-10-09  
**Escopo:** exclusivamente sintético, preparatório e não normativo  
**Decisões anteriores:** Documentos 101–102, CP146 e gate adversarial read-only pós-CP146  
**Status:** **TECHNICALLY_VALIDATED — OFFLINE_SYNTHETIC_ONLY**

## 1. Diagnóstico e correções

A auditoria da fronteira parser offline → decisão operacional factual identificou dois pontos de hardening:

1. O campo `frozen_interface_blob_sha` era aceito diretamente do chamador; a biblioteca não comprovava a identidade física dos bytes congelados.
2. `evidence_paths` apontava para arquivos JSON individuais não existentes; as fixtures são geradas em memória.

Correção no arquivo `scripts/temporal_source_offline_contracts.py`:
- função `verify_frozen` calcula Git blob SHA-1 de **cada um dos cinco** artefatos controladores a partir dos bytes efetivos em disco e compara com pinos literais conhecidos;
- confere que interface passada ao parser é igual ao JSON congelado em disco e que `supplied_sha` corresponde ao SHA congelado;
- para PubMed, confere também que a query passada é o texto integral congelado;
- mismatch, erro de leitura ou inconsistência devolve `FROZEN_CONTRACT_IDENTITY_MISMATCH`, `parse_state=invalid`, `retrieval_completeness=incomplete` e `derived_complete_cardinality=NULL`;
- nenhuma tentativa de atualizar ou autorretificar os artefatos.

Correção de proveniência:
- `evidence_paths=[]` quando não existe arquivo de fixture persistido;
- `fixture_provenance={kind:generated_in_memory,fixture_id:...,persisted_fixture:false}`;
- README das fixtures documenta os limites epistemológicos.
- O campo `frozen_interface_blob_sha` não substitui evidência factual de request e resposta; o relatório permanece `synthetic_test_only=true`.

## 2. Testes e evidência de CI

- Testes originais `OFF-P01–P12`, `OFF-C01–C16` e `OFF-X01–X06`: **34/34 PASS**.
- Novos testes adversariais `OFF-A01–A10`: **10/10 PASS**, incluindo SHA falso, interface adulterada, query divergente, falha segura e proveniência gerada em memória.
- Total: **44/44 PASS**.
- GitHub Actions: run **252**, ID `37939324857`; conclusão **success**.
- HEAD técnico validado: `dbcc79f69bb3ed07306cee5fc05b25eed9bfb2e1`.
- Job `postgres-s5`, ID `113849349502`: **success**.
- CI artifact ID `11621145703`, digest `sha256:0aff81c4bf96f477630e40a14f24f040a7820650c5d82d8d1f446b3db50ffb29`, expiração `2026-12-08T13:47:58Z`.
- Log efetivo inspecionado: **44** avisos individuais `OFF-* PASS`, marcador `F4-OFFLINE-SOURCE-HARDENING PASS — OFF-A01–A10 (10/10); ALL 44/44`.
- Mesma run: `F4-ISE` 24/24 success, `TOPI-B1R1-PRE-DAY19-READINESS PASS` com WAIT e zero mutation, `S5-T16 PASS` e `TOPI-B1R1-AUTH-REBUILD PASS`.

## 3. Limitações explícitas

Não foi implementada nem autorizada ponte automática do relatório offline para `MeasurementEvent`. Um relatório sintético `complete` jamais comprova request factual, timestamps, fonte, preflight, provenance ou OpportunityResolution real.

Os testes de ausência de HTTP são inspeções de código e fluxo local, **não** isolamento de rede imposto pelo ambiente. A execução offline tampouco valida parsing contra respostas reais ou mudanças futuras das APIs.

A migration 033–036, requests científicas, horários, artefatos congelados, authority operacional e controles B1R1 permaneceram intocados. Nenhum acesso target-specific, mutation factual, calibration normativa, scheduler, M3 ou Fase 5 foi iniciado.

## 4. Próximo passo

Não abrir novos blocos redundantes sem lacuna técnica demonstrada. A ativação factual do Epoch B1R1 continua reservada a 2026-10-19, 08:00–09:00 America/Recife, com novo Freshness Gate e live preflight PASS, em modo alto. Opcionalmente, antes disso, somente nova questão independente expressamente autorizada.

**Fim do Documento 103**
