# OES — D2-E2/A1 (cliente mínimo NCBI)

Escopo: implementação e teste **locais e sintéticos**, sem acesso ao PubMed na atividade A1. Usar Python 3.10+ e apenas biblioteca padrão.

- `ncbi_client.py`: funções ESearch e ESummary, com injeção de `opener` para testes e limite de até 20 registros.
- `test_ncbi_client.py`: testes unitários sem rede.

Teste: `cd prototypes/d2_e2 && python -m unittest -v test_ncbi_client.py`.

Não há interface de linha de comando nem chamada de rede automática. **Importar o módulo não executa consultas.** Invocar `report(...)` com acesso real ao NCBI constitui uma atividade operacional futura e requer autorização específica do OES. O código não deduplica nem realiza triagem científica, não altera a Ficha e não produz avaliação de materialidade. Não há gravação automática em arquivos ou banco.

A resposta ESearch pode incluir query translation e avisos; a consulta original, o horário e os identificadores retornados são preservados no dicionário retornado. A estabilidade e compatibilidade das respostas reais do NCBI permanecem não verificadas.

**Histórico:** 7 testes locais mockados PASS em 2026-10-23 antes da publicação. O commit de publicação não constitui execução de CI ou homologação factual. CP255 é o checkpoint canônico de partida; sua atualização documental será feita somente em checkpoint proporcional futuro.
