# Documento 278 — Gate para adaptação offline da persistência privada E6

**OES | 2026-10-24 | CP274 | HEAD de referência:** `fef6d0ce8d932cbe7566d8bedb9562cb02c6d2ac`  
**Situação:** `PROPOSAL_ONLY / OWNER_APPROVAL_PENDING / E6_G1_FACTUAL_BLOCKED`

## 1. Justificativa e dependência

Os Documentos 269–277 fixam que JSON bruto não pode ser distribuído por artifact público, que PostgreSQL privado `bytea` é o armazenamento somente do piloto e que a bateria de autenticação encerrou-se **parcialmente**: a identidade real negou acessos indevidos, mas INSERT autenticado positivo e recuperação independente ainda não foram comprovados. O workflow factual permanece bloqueado por `if: ${{ false }}` e contém etapa histórica de `actions/upload-artifact`, cuja execução seria incompatível com a política vigente.

## 2. Autorização proposta — exclusivamente código offline

Autorizar elaboração incremental, no repositório público, de um **adaptador mínimo de persistência privada PostgreSQL**, com interface injetável e testes locais inteiramente sintéticos ou simulados, que:

1. Receba bytes originais, metadados de proveniência e identificador de observação sem refazer o capturador HTTP.
2. Confira limite de 2.000.000 bytes, hash SHA-256 calculado sobre bytes brutos e parâmetros exigidos, antes do INSERT.
3. Construa INSERT **parametrizado** para `oes_raw_private.source_observation`; não interpolar payload ou credenciais em SQL, logs ou mensagens de erro.
4. Use transação atômica e falha fechada; em erro, rollback sem declarar persistência bem-sucedida.
5. Separe resultado sanitizado de bytes brutos e impeça qualquer upload de JSON. Não criar caminho alternativo de publicação pública.
6. Inclua testes negativos simulados: credencial ausente, role insuficiente, duplicidade, tamanho excedido, SHA divergente, falha de transação e vazamento de conteúdo em logs.
7. Mantenha abstração mínima: não introduzir object storage, ORM, migrações de produção ou arquitetura de múltiplos backends.

## 3. Fronteiras de implementação

- **Permitido somente após aprovação:** código Python e testes offline no repositório; mocks e fixtures sintéticas; CI offline sem credenciais ou serviços conectados.
- **Não permitido:** chamadas ao Neon ou ClinicalTrials.gov; criar login, grants, secrets, triggers ou tabelas; testes positivos conectados; publicar qualquer JSON factual; alterar `if: ${{ false }}`; despachar ou habilitar workflow factual; instalar serviço pago.
- É possível preparar um workflow de teste offline separado, sem conexão externa, mas sua execução remota deverá ser explicitamente delimitada na implementação.
- O capturador `e6_capture.py` e o workflow factual não devem ser modificados nesta primeira atividade: preparar adaptador independente e testes, preservando o bloqueio factual. Qualquer integração posterior necessita decisão própria.

## 4. Critérios de aceite e rastreabilidade

Revisão do diff, testes locais PASS, demonstração de que dados de teste são sintéticos, nenhum segredo em arquivos, nenhuma escrita no Neon, nenhum JSON em artifacts e documentação de lacunas conhecidas. Freshness Gate imediatamente antes do commit. O avanço não equivale a liberação científica ou operacional.

## 5. Decisão solicitada

`APPROVED — OES / D2-E6 / OFFLINE_PRIVATE_POSTGRES_ADAPTER_SYNTHETIC_ONLY / no connected tests / no factual GET / no public JSON / keep workflow disabled / no credentials / no paid services / fail closed`

**Estado:** `OFFLINE_ADAPTER_GATE_PREPARED / CODE_NOT_APPROVED / FACTUAL_GET_BLOCKED`.

**STOP — aguardar autorização específica.**

## 6. Implementação e verificação local — 2026-10-24

Autorização para implementação offline recebida do proprietário. Criados em `main` os arquivos `tools/d2_e5_preservation/e6_private_pg_offline.py` e `tools/d2_e5_preservation/tests/test_e6_private_pg_offline.py`, HEAD `29ea47348b672a52eb79d1a189ac70d52c6561b1`.

**Execução:** cópia local do conteúdo dos dois arquivos recuperados pelo conector GitHub (acesso HTTPS direto do ambiente de execução indisponível). Comando executado na cópia: `python -m unittest -v test_e6_private_pg_offline`. Resultado observado: **9 testes, 9 PASS, 0 falhas, 0 erros**. Testes exclusivamente sintéticos com conexão simulada; não ocorreu consulta ou escrita no Neon. O workflow factual continua bloqueado por `if: ${{ false }}`.

**Limites da evidência:** a execução foi da reprodução local do conteúdo recuperado, não de um checkout autenticado; não houve execução remota da CI. Os mocks não simulam ainda especificamente erro de duplicidade e divergência de SHA informado, e não provam ACL ou recuperação posterior; a implementação marca explicitamente `PRIVATE_PERSISTED_UNVERIFIED`. Não conectar a operação factual sem revisão complementar e aprovação distinta.

**Estado:** `OFFLINE_UNIT_TESTS_9_OF_9_PASS_LOCAL_COPY / REMAINING_NEGATIVE_TESTS_PENDING / NEON_NOT_ACCESSED / E6_G1_BLOCKED`.

## 7. Ampliação da suíte offline — 2026-10-24

Adapter e suíte atualizados em `tools/d2_e5_preservation/`; verificação adicional de bytes, digest SHA-256, comprimento e identificador do objeto preparado antes da chamada ao cursor. Quatro testes sintéticos acrescentados: (i) simulação de erro de duplicidade com rollback e erro sanitizado, (ii) SHA adulterado, (iii) payload adulterado após preparação, (iv) limite inclusivo exato de 2.000.000 bytes. Execução local da suíte reproduzida: `python -m unittest -v test_e6_private_pg_offline` → **13 testes PASS, 0 failures, 0 errors**. Não é teste de integração com PostgreSQL; duplicidade é simulada como falha do cursor, não pela constraint real. Nada conectado ao Neon, sem credenciais, JSON factual ou GET. Workflow factual continua `if: ${{ false }}`.

**Estado:** `OFFLINE_TESTS_13_OF_13_PASS / INTEGRATION_NOT_VALIDATED / E6_G1_BLOCKED`.
