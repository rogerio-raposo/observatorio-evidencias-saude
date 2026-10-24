# Documento 269 — Política de retenção e armazenamento privado de JSONs brutos do OES

**Data:** 2026-10-24  
**Decisão do proprietário:** aprovada nesta conversa; complementa e prevalece sobre a proposta anterior de artifact público do Documento 268.  
**Escopo:** preparação arquitetural/documental do piloto D2-E6-G1; não autoriza captura factual, SQL, migração, execução conectada ou serviços pagos.

## 1. Política aprovada de disponibilização e acesso

O repositório GitHub principal do OES permanece público para código, testes, workflows e documentação. **JSONs originais brutos não serão disponibilizados para download público**, nem incluídos em commits, releases, artifacts públicos, logs ou resultados de CI. A anterior aceitação, em princípio, de exposição pública temporária de artifact é **superada por esta decisão posterior e específica**.

O JSON original poderá ser recuperado somente por identidades com autorização operacional específica e necessidade legítima; acesso ao projeto Neon ou à função de leitura sintética já existente **não implica** autorização automática de leitura de dados factuais brutos.

## 2. Retenção por finalidade, sem prazo universal

- **Piloto E6-G1:** preservar o JSON bruto no armazenamento privado até validação da integridade, rastreabilidade, recuperabilidade e encerramento documental do ensaio. **Não descartar automaticamente antes desse marco.** Ao encerramento, documentar decisão de retenção ou descarte, responsável e evidência da decisão.
- **Operação regular:** conservar versões efetivamente necessárias para auditoria, rastreabilidade e reprodutibilidade científica pelo período exigido pelo uso, obrigações institucionais/editoriais/contratuais e legislação aplicável; **ainda não existe prazo numérico universal aprovado**.
- **Duplicatas, artefatos transitórios e respostas não utilizadas:** descarte controlado permitido somente após verificar dependências e obrigações; a integridade e a proveniência não devem ser comprometidas.
- **Metadados e decisões de proveniência:** preservar ligações e evidências pelo período necessário para auditar os resultados associados; descarte de conteúdo bruto não apaga obrigações de registro.
- A duração histórica de 7 dias do artifact GitHub era um mecanismo de transporte, **não** um prazo institucional de retenção, e deixa de ser aplicável à proposta factual.

## 3. Decisão arquitetural aprovada: PostgreSQL privado para o piloto

Para o primeiro ensaio, utilizar **PostgreSQL do ambiente experimental Neon já existente**, se o preflight confirmar segregação suficiente. O JSON bruto será armazenado como bytes originais (`bytea`), com SHA-256, tamanho, origem, URL exata, horário UTC da observação, IDs de execução e status de revisão técnica; não reserializar o JSON para substituir a prova dos bytes de origem. `jsonb` pode futuramente servir à indexação derivada, **não** à cópia probatória integral.

**Implementação ainda não autorizada:** antes de alterar o banco, submeter plano mínimo de esquema, papéis, GRANT/REVOKE, isolamento dos registros factuais frente à fixture sintética PG-A4, transação/rollback, limites de tamanho e testes de acesso negativo. Preservar todas as fixtures já existentes. Não presumir que o papel `oes_pg_a4_reader` deva ler esses dados. Não utilizar a branch primária por conveniência, criar novo projeto pago ou inserir dados factuais sem gate explícito.

Para a operação regular, a decisão sobre object storage versus PostgreSQL será reavaliada com critérios de volume, custo, retenção, backup e operação. Neon Object Storage não deve ser presumido habilitado em `aws-sa-east-1` na avaliação atual. **Decisão expressa do proprietário (2026-10-24): a escolha de PostgreSQL para armazenar o JSON bruto é estritamente restrita ao piloto e deverá permitir migração futura para um serviço privado de armazenamento de objetos (object storage), sem compromisso de manter os bytes no banco em produção.** O piloto não define o mecanismo definitivo de retenção nem condiciona a evolução a um fornecedor específico.

## 4. Mudança necessária no workflow E6

O workflow `.github/workflows/d2-e6-a2-gated-capture.yml` atualmente preserva um pacote em artifact do GitHub Actions, que **não atende à nova política** para JSON factual. Antes do primeiro GET, deve ser proposta uma revisão mínima e revisada que:
1. mantenha `if: ${{ false }}` até autorização executiva;
2. execute uma única consulta ao endpoint previamente aprovado, sem retry, redirect ou paginação;
3. aplique o gate `HOLD` antes de qualquer persistência;
4. grave bytes e proveniência **somente** em tabela com permissões restritas, com transação, checksum e confirmação de leitura controlada;
5. **não faça upload** do JSON ou manifesto com dados factuais a artifacts públicos, nem imprima conteúdo em logs;
6. em falha, não conceda acesso ou publique conteúdo; reexecução requer decisão própria;
7. não interprete a aprovação da arquitetura como autorização do GET.

Os testes offline e a prova histórica de 39/39 PASS continuam válidos para seu escopo anterior; **não validam ainda o novo caminho PostgreSQL**. O novo caminho exigirá testes negativos de autorização, integridade e falha fechada antes do gate executivo E6-G1.

## 5. Pendências e limites preservados

O texto integral dos termos específicos ClinicalTrials.gov de redistribuição do JSON não foi confirmado; entretanto, a **não disponibilização pública dos dados brutos** reduz a relevância imediata dessa pendência para o piloto, sem dispensar atribuição, respeito a condições de uso, privacidade ou revisão futura de resultados públicos derivados.

`RAW_JSON_NO_PUBLIC_DOWNLOAD_APPROVED / PILOT_PRIVATE_POSTGRES_APPROVED_IN_PRINCIPLE / IMPLEMENTATION_PENDING_SEPARATE_GATE / E6_G1_NOT_APPROVED / FACTUAL_CAPTURE_BLOCKED`.

Documento 268 permanece como registro histórico das alternativas e deve remeter expressamente a esta decisão posterior. CP273 permanece ponteiro de continuidade vigente até checkpoint específico posterior.

## 6. Desenho mínimo de isolamento e portabilidade — apenas proposta técnica

**Objeto lógico:** armazenar uma observação factual por identidade única, com payload `bytea` imutável no escopo da captura, `sha256`, tamanho em bytes, fonte, URL de requisição, identificadores de execução, horários UTC e estado técnico. Uma identidade estável de observação vincula metadados e conteúdo sem obrigar consumidores a conhecer o mecanismo físico (tabela PostgreSQL hoje, objeto privado amanhã).

**Limites de implantação:** selecionar uma área de dados factual isolada do esquema de fixtures sintéticas; identidade de escrita limitada a inserir e verificar a observação autorizada; identidade de leitura somente se indispensável; papel `oes_pg_a4_reader` sem acesso ao JSON factual por padrão. Não conceder `PUBLIC` nem oferecer endpoint anônimo, link permanente ou URL pré-assinada pública.

**Prova técnica mínima antes do GET:** com bytes sintéticos, verificar (i) inserção e leitura exata com comparação SHA-256, (ii) limite de 2 MB, (iii) rejeição de duplicatas e gravações incompletas, (iv) rollback em erro, (v) teste negativo de leitura por papel não autorizado, (vi) logs e artifacts sem bytes brutos, (vii) integridade de fixtures PG-A4 preservada. O gate `HOLD` deve impedir persistência quando estrutura ou proveniência não passar. Testes offline prévios não demonstram essa integração.

**Contrato de migração futuro:** separar `observation_id`, metadados de proveniência, `sha256` e classificação de acesso da localização física do JSON; prever substituição controlada do conteúdo `bytea` por referência interna a objeto privado **somente após** validar leitura, checksum, retenção, controles de acesso e rollback. Não criar desde já abstração de object storage, bucket, novos serviços ou projeto Neon apenas em antecipação à migração.

**Gate de execução:** este desenho é documental. Criação de tabela, papéis, permissões, testes conectados e ajustes do workflow dependem de autorização técnica posterior e de Freshness Gate. Consulta factual E6-G1 continua expressamente não autorizada.

**STOP — aprovação da política e da direção arquitetural, não da execução.**
