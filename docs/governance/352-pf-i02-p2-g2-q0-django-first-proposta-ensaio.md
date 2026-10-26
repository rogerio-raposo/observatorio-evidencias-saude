# Documento 352 — PF-I02/P2 — Gate G2 proposto para ensaio Q0 Django-first
**Data:** 2026-10-26. **Estado:** PROPOSTA DOCUMENTAL, NÃO AUTORIZAÇÃO. **Base:** CP311; CI [40284472284](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40284472284), SUCCESS 165/165, SHA `b141afe86f9dfb2f7fc89271f66dae61b7e8cf12`; Docs 347–351.

## Objetivo e fronteira
Demonstrar, após **aprovação nominal separada**, se cinco gravações Q0 (quatro registros e receipt) podem ser conduzidas pelo Django ORM na mesma transação PostgreSQL, com integridade canônica, locks compatíveis com ACL e ausência de dados reais. **Este documento não autoriza SQL, conexão, alterações de privilégios ou execução de ensaio.**

Destino previsto, somente após preflight aprovado: Neon Free sandbox `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`; nenhuma outra instância. `oes_qprep_writer` é NOLOGIN; sua identidade de execução, capacidade de SET ROLE e grants precisam de avaliação nominal e READ ONLY antes de qualquer DML. Django `DATABASES={}` por padrão e alias de reader não pode ser reaproveitado para escrita.

## Sequência de gates, sem autorização implícita
**G2-P0 documental e catálogo READ ONLY:** obter confirmação expressa separada para verificação mínima de grants atuais, defaults, constraints, identidade runtime, catálogo e tabelas da sandbox; não consultar conteúdo de registros nem associar usuários. Se qualquer invariante divergir: HOLD.

**G2-P1 integração do backend dormant (código somente):** implementar sob revisão a factory ORM única, as consultas e os advisory transaction locks antes de revalidar autorização; manter o bloqueio de instanciação e a ausência de alias writer até uma autorização específica. Executar CI offline e inspecionar plano SQL. Não confundir uma classe com métodos `objects.create` com backend seguro e completo.

**G2-P2 ensaio conectado sintético e transacional:** requer nova aprovação nominal contendo projeto, branch, banco, identidade, conta/serviço autorizado, SQL DML permitido, volume máximo, plano de limpeza e critérios de stop. Em uma transação `transaction.atomic(using=alias_aprovado)`, com lock de request e lock cooperante por `question_id` na mesma conexão, validar escopo, criar exatamente uma pergunta Q0 e receipt com identificadores artificiais exclusivos. Confirmar os cinco vínculos UUID e stage Q0. No ensaio preferir **rollback intencional** verificável, sem afirmar validação de commit durável. Se a hipótese exigir commit real, requer aprovação adicional e limpeza verificável posteriormente.

## Critérios obrigatórios
- Nenhuma role/grant, DDL, migration, RLS, credencial, Django setting persistente ou deploy alterados sem aprovação própria.
- Não utilizar `SELECT ... FOR UPDATE` em `investigation.question`, pois esse acesso não está concedido. Acesso a `core.entity_version` e locks por identidade exigem rechecagem de grants e mesma conexão.
- `oes_id` é único globalmente: colisão falha sem vazamento de pergunta de outro responsável.
- Ledger usa PK composta `(actor_id,request_id)`; replay só pode seguir após nova verificação de escopo. Não usar dados reais.
- Não tentar Q1, revogação de responsabilidade, pesquisa factual, criação de usuários, E9, API pública ou HTTP write.
- Falha/timeout/comit incerto: interromper (HOLD), registrar evidência sanitizada, sem retry cego ou limpeza especulativa.
- Confirmação de segurança deve diferenciar **rollback intencional** de persistência efetivamente confirmada; zero linhas residuais não é pressuposto, mas resultado a verificar com acesso autorizado.

## Critérios de conclusão
Aprovação exige, no mínimo, rastreabilidade do commit e do run, preflight READ ONLY compatível, evidência sanitizada de cinco escritas em uma transação com rollback e verificação de inexistência residual sem leituras amplas. O estado G2 só muda após autorização expressa e execução factual. Nenhuma CI offline habilita operacionalização.

**Situação atual:** `G2_PROPOSAL_DOCUMENTED / G2_NO_GO / CP311_ACTIVE / READINESS_NOT_READY / E9_NO_GO`.
