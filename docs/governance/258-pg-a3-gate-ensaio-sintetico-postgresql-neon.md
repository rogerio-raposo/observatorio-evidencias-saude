# Documento 258 — PG-A3: gate proposto de ensaio sintético PostgreSQL/Neon

**OES | 2026-10-24 | base main `38b0ff49ae8675fa1a0196f2fa23e0d42e3c272a` | GATE_PROPOSED_NOT_APPROVED / NO_DB_WRITES**

## 1. Alcance e autoridade

Este documento **especifica**, sem executar, um único ensaio controlado da hipótese PG-A2/Documento 257: reutilizar `database/poc-s1.sql` como baseline experimental e, se especificamente aprovado, `003_poc_s3_provenance_guard.sql` para testar preservação de proveniência em PostgreSQL. Referências: Documentos 256–257; Documento 227 (T2-A2 artesanal diferido); política de migrations arquitetura 30; CP270. Nenhum ato de PG-A3 está aprovado por este documento. Não iniciar Fase 5, alterar D2-E6 ou alegar prontidão operacional/científica.

## 2. Ambiente candidato e isolamento obrigatório

Neon existente `oes-sandbox`, project ID `weathered-boat-65779510`, região `aws-sa-east-1`, PostgreSQL 18, plano informado `free_v3` na inspeção administrativa de leitura de 2026-10-24. A branch atual é `production`, ID `br-wild-field-b6qg7k3p` (nome NÃO demonstra ambiente produtivo homologado). Na inspeção anterior de tabelas não foram listadas tabelas no banco padrão. O projeto `oes-d1-t2-a2-synthetic` contém `oes_t2a2_proto` experimental e **não deve ser alterado**.

**Condição proposta:** criar branch Neon isolada e descartável a partir do `oes-sandbox`, com nome claramente sintético, após autorização específica de criação, validação de cotas atuais e garantia de ausência de dados factuais. A branch principal `production` fica estritamente intocada. Se não houver disponibilidade no plano gratuito, STOP e decidir alternativa sem provisionamento pago por inferência. Criar branch pode consumir recursos/cotas; não presumir custo zero só pela assinatura Free.

## 3. Escopo máximo de uma execução futura

1. Pré-ensaio read-only: reconfirmar IDs de projeto/branch, inventário de schemas e permissões, hashes dos SQLs, versão PostgreSQL, estado das quotas e escopo de escrita. Não exibir segredos nos registros.
2. Isolamento: criar **apenas uma** branch descartável especificamente autorizada; confirmar `branch_id` diferente da principal e origem esperada antes de qualquer escrita. Se houver qualquer dúvida, STOP.
3. Aplicar no banco isolado somente o baseline `database/poc-s1.sql`, via conexão direta e identidade de execução limitada; registrar hash, resultado, horário e revisão Git. Aplicação eventual do arquivo `003_poc_s3_provenance_guard.sql` é passo **condicional, explicitamente indicado** na futura autorização; não incluir `002`, `004` ou a cadeia até `036` por inferência.
4. Usar exclusivamente fixtures **inteiramente artificiais** de Study, Report, versões, vínculos e proveniência. Não copiar dados ou identidades clínicas factuais, chaves ou objetos do projeto antigo. Sem consultas a PubMed/ClinicalTrials.gov.
5. Verificar Study ≠ Report, vínculo 1:N e N:M onde previsto, FKs, tipagem de entidades, restrição de versão corrente, semântica de proveniência e falhas transacionais. Quando `003` for aplicado, verificar tentativa de mutação material bloqueada. Nenhum teste autoriza ciência ou produção.
6. Integração Django **somente em etapa posterior separada**, PG-A4, após resultados do ensaio SQL. O primeiro PG-A3 não precisa adicionar driver, configurar `DATABASES` ou alterar Django.
7. Evidências: versão/HEAD, projeto e branch (IDs não secretos), hashes SQL, scripts e fixtures versionados, checklist de resultados, logs sem credenciais/payload sensível, contagem de testes e divergências. Fazer auditoria dos efeitos no banco isolado, não apenas contar testes PASS.
8. Destino da branch: descarte controlado **somente com autorização específica para exclusão**, identificando exatamente o ID e certificando que não se trata da branch principal. Não prometer rollback ou exclusão automáticos.

## 4. Gates e não objetivos

**PG-A3-G0 (antes de criar branch):** owner autoriza objeto/ID, uma branch, cotas/custos, região, isolamento, permissões e política de descarte.

**PG-A3-G1 (antes de qualquer SQL mutável):** owner aprova explicitamente SQLs exatos e SHA/commit, alvo isolado conferido, identidade com permissões mínimas necessárias, rota direta para migrations, logs e validação de falha fechada. Revisão estática de dependências e verificação de que o baseline inteiro é compatível com o alvo são requisitos, não fatos já demonstrados.

**PG-A3-G2 (resultado):** somente PASS se instalação, invariantes, preservação e integridade forem comprovadas no ramo de ensaio, sem efeitos externos. FAIL/HOLD diante de inconsistência, permissão excessiva não controlada, alteração em branch principal, dado factual inesperado, custo não aprovado ou evidência incompleta.

**Não objetivos:** escrita em produção, integração de E6, ingestão factual, novos grants permanentes, execução de 36 migrations, adaptação artesanal A2-G4, API pública, credenciais no GitHub, deploy e promoção científica/operacional.

## 5. Decisão recomendada e estado

**Recomendação:** aprovar futuramente um primeiro ensaio PG-A3 **SQL sintético isolado**, com baseline íntegro e guard `003` condicionado à deliberação; adiar PG-A4/Django para depois do resultado. Não construir novo subset SQL nem um framework de migrações. As 36 migrations continuam `UNREVIEWED` para promoção operacional.

**Estado:** `PG_A3_GATE_SPECIFIED / EXECUTION_NOT_APPROVED / NEON_UNCHANGED`. CP270 permanece no ponteiro até checkpoint consolidado. Próximo `Prossiga`: revisão final de proporcionalidade e pacote de autorização PG-A3-G0/G1 (read-only/documental); nenhuma ação operacional antes da aprovação específica. STOP.
