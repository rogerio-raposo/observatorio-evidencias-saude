# D2-E5-A3 — preservação offline/sintética

Biblioteca padrão Python; sem HTTP, Django, banco ou consulta factual. Execute a partir desta pasta:
`python -m unittest discover -s tests -v` (execução local voluntária; CI não configurada).

`preserve.package_evidence(raw: bytes, provenance: dict, destination: Path)` preserva
os **bytes exatos** em `response.raw.json`, gera `manifest.json` e `summary.json`.
Usa staging no mesmo diretório pai e renomeação local após integridade verificada.
O diretório destino precisa não existir; não há sobrescrita. Falhas antes da
publicação eliminam staging; erros/interruptores de processo fora do controle
do Python não constituem garantia transacional de filesystem.

**Restrições:** o chamador precisa fornecer metadados verdadeiros. O módulo
não autentica origem; um JSON sintético também pode ser empacotado. A aceitação
de `PASS_TECHNICAL_QUERY_ONLY` não prova cobertura científica. `nextPageToken`
não é gravado no manifesto (somente presença), mas permanece no JSON bruto.
Destino durável e qualquer uso conectado requerem decisões posteriores.

Documento de base: docs/governance/253-d2-e5-a2-contrato-preservacao-metadados-clinicaltrials.md.
