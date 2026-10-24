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

## E5-A5: preflight de arquivamento offline

`archive_preflight.prepare_archival_plan(package_dir, existing_paths=())` lê o pacote
E5-A3, compara hash SHA-256 de bytes brutos, contagens, paginação e consistência
manifesto/resumo, valida o identificador e gera plano determinístico com caminhos
e hashes. Rejeita pacotes incompletos, links simbólicos e colisões informadas.

**Não** consulta GitHub, não cria commit, não inspeciona conteúdo factual para
publicação, não verifica HEAD e não autoriza arquivamento. A lista
`existing_paths` é uma declaração externa: revisão humana do JSON integral,
Freshness Gate e nova verificação de colisões no GitHub permanecem obrigatórios.
Sem isto não classificar como arquivo durável.

Testes offline: `python -m unittest discover -s tests -v`.
