# Documento 196 — Aprovação de encerramento técnico restrito de D1-T2/A1

**OES | 2026-10-21 | DECISÃO EXPRESSA DO PROPRIETÁRIO | CLOSED_SYNTHETIC_IN_MEMORY_ONLY**

## 1. Decisão literal
> APPROVED — OES / D1-T2-A1 / SYNTHETIC_IN_MEMORY_TECHNICAL_CLOSURE / Aprovar exclusivamente o encerramento técnico restrito de T2-A1, como fronteira experimental de repositório e Unit of Work em Python local e memória, com cinco comandos integrados, 75 testes locais historicamente PASS incluindo os 36 testes T1 e rastreabilidade S1–S6 delimitada; preservar T1, limitações, diferenças de exceções, semântica atual e gates; não autorizar T2-A2, SQL, PostgreSQL, Neon, drivers de banco, CI remota, nuvem, implantação, API pública, buscas factuais, dados reais, serviços pagos ou promoção científica/operacional.

O Documento 195 é a proposta histórica; este Documento 196 registra sua aprovação expressa. Referência pré-registro: `2738425c429b22d7120794f95879761e99bd1b07`.

## 2. Evidências e alcance

A fronteira experimental em `prototypes/d1_t2/a1/` possui contrato Python de repositório, Unit of Work em memória, cinco comandos sintéticos integrados, replay e testes adversariais. Evidência anterior: **39 testes T2-A1 + 36 testes T1 = 75/75 PASS históricos**. Nenhum reteste nesta formalização. Rastreabilidade S1–S6 válida somente para protótipo sintético local. O T1 original permanece `CLOSED_SYNTHETIC_LOCAL_ONLY`.

## 3. Limitações vinculantes

Sem persistência durável, reinício recuperável, isolamento interprocessos, banco, SQL, segurança de produção ou equivalência à View SQL canônica. Falhas injetadas antes de commit não demonstram recuperação de commit incerto. Replay em memória não é trilha criptograficamente inviolável. Diferenças `RepositoryConflict`/`DomainError` documentadas; a criação repetida retorna snapshot corrente e `pending` não permite segunda avaliação do mesmo sinal. O T1 não foi modificado.

## 4. Exclusões e continuidade

**T2-A2 NÃO AUTORIZADO.** Não executar PostgreSQL, SQL, Neon, drivers, CI remota, nuvem, implantação, API pública, buscas factuais, dados reais, serviços pagos nem alterar gates, migrations ou estado científico/operacional. D0 documental concluído, D1 prioritário, D2 e governança completa posteriores. Próximo `Prossiga`: apenas preparar documentalmente a proposta de autorização T2-A2, sem implementação. STOP.
