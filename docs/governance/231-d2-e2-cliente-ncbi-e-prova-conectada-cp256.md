# Documento 231 — D2-E2: cliente Python e prova conectada NCBI (CP256)

**OES | 2026-10-23 | D2_E2_CONNECTED_NCBI_RETRIEVAL_PASS | TECHNICAL_SCOPE_ONLY**

## Autorização e implementação

O proprietário aprovou D2-E2/A1 (cliente Python ESearch/ESummary, testes locais sintéticos) e expressamente D2-E2/A2 `SINGLE_CONNECTED_NCBI_PROBE` (um workflow manual, sem credenciais, SQL, Neon ou serviços pagos). Código publicado em `prototypes/d2_e2/ncbi_client.py`, `test_ncbi_client.py`, `run_connected_probe.py`, `test_connected_probe.py` e workflow `.github/workflows/d2-e2-single-ncbi-probe.yml`. Commit executado: `380f87976bc5a4853248ff5765896c5f63b42beb`. Sem Work.

## Evidência operacional

GitHub Actions [run 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270): `workflow_dispatch`, primeira tentativa, `completed/success`, 2026-10-23T15:20Z, job `ncbi-probe` success. Logs verificados: **11 testes unitários PASS**, consulta de controle PubMed recuperou os **4/4 PMIDs-semente** (33328044, 41343796, 40075149, 42240717). ESearch executado com PICO conceitual e filtro `2026/10/05`–`2026/10/23` [Date - Publication]; `total_count=1`, `returned_count=1`, `pmid=42841437`; ESummary retornou um registro. `query_translation` e consulta literal, URL, horário UTC e metadados figuram nos logs. Nenhum warning reportado pela API.

Registro: Shaffer et al. 2026, *Sleep Healthy Using the Internet: A Meta-Analysis of Twenty Years of Research on a Digital Cognitive Behavioral Therapy for Insomnia Program*, *Sleep*, PMID 42841437, DOI 10.1093/sleep/zsag264, `epubdate=2026 Oct 7`. **Candidato, não julgado elegível nem materialmente novo**. Sobreposição com os estudos conhecidos não verificada.

## Natureza do PASS e limitações

**PASS exclusivamente para conectividade, resposta estruturada, contagem da query executada, recuperação dos quatro estudos-semente por query de controle e metadados de até 20 registros.** A contagem 1 pertence à consulta literal e intervalo específicos: não indica que só exista uma publicação nova de interesse. O teste de quatro PMIDs conhecidos não mede recall global nem garante estratégia bibliográfica suficientemente sensível; data de publicação, disponibilização eletrônica e indexação podem divergir. Sem deduplicação por ensaio, seleção independente, appraisal, GRADE, reanálise, certeza, materialidade, conclusão ou alteração de Ficha.

Nenhuma inserção em Neon, SQL ou migrations, nenhuma execução continuada ou serviços pagos; CI manual de leitura e testes locais, sem integração Monitor. CP255 permanece registro histórico fiel da falha instrumental anterior; CP256 registra que **o caminho alternativo Python/E-utilities superou aquela limitação técnica**.

## Estado e próximo marco

D2-E2/A1 publicado e D2-E2/A2 **`CONNECTED_NCBI_RETRIEVAL_PASS` restrito**; prova pontual encerrada. Ficha `OES-P-2026-000401` permanece A2 interno, sem revisão científica independente. D1 sintético/reescopado encerrado no CP253; T2-A2/A2-G4 diferido/não aceito; A2-G5/runtime não autorizado; riscos SA abertos/diferidos; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`; nenhuma promoção de gate.

Próximo `Prossiga`: **preparar uma decisão científica proporcional sobre triagem de elegibilidade e sobreposição da síntese Shaffer**, sem executar novas buscas, appraisal, atualização, ou alterar o produto por inferência. Evitar repetir testes da conectividade já comprovada.

**STOP — CP256 exclusivamente consolidação documental.**
