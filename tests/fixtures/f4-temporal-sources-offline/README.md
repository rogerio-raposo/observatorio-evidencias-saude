# OES F4 — synthetic offline source cases

**SYNTHETIC_TEST_ONLY**. These cases are generated deterministically in memory by
`scripts/validate_temporal_source_offline_contracts.py`; this directory documents
their provenance. There are no responses obtained from PubMed or ClinicalTrials.gov
and no genuine search results, timestamps, or identifiers.

The script reads frozen interface/query artifacts without modifying them.
No HTTP, database connection or external execution is part of the harness.

## Proveniência verificável

As fixtures são geradas em memória, não existem snapshots JSON individuais neste diretório. O relatório técnico usa `evidence_paths: []` e `fixture_provenance` com `kind: generated_in_memory`, `fixture_id` e `persisted_fixture: false`. Essas referências descrevem a origem sintética, não evidência externa.

Os validadores agora leem os bytes dos cinco artefatos congelados e comparam hashes Git blob fixos e o conteúdo da interface recebido pelo parser. O hash informado pelo chamador, isoladamente, não é uma prova de identidade. Uma divergência produz diagnóstico fail-closed.
