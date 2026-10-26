# Documento 346 — PF-I02 / P2 — Contrato mínimo de concorrência e revogação (offline)
**Data:** 2026-10-26. **Base:** CP310, Docs.343–345, CI https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40278790506 — 142/142 PASS sobre `14560c468a7777b325e121ad45723c12075da186`.
**Natureza:** contrato técnico proposto; não é prova conectada nem habilitação de mutações de responsabilidade.

## 1. Invariantes obrigatórias
- Toda operação Q0, Q1, replay e futura atribuição, transferência ou revogação de responsabilidade de uma mesma pergunta deve utilizar o **mesmo espaço de chaves consultivas**, `hashtextextended('oes:question:' || question_id,0)`, independentemente do ator.
- A identidade `question_id` deve ser canônica e imutável; sem normalização divergente entre implementações. O lock deve ser adquirido **antes da primeira leitura de escopo da pergunta** e mantido até fim de commit/rollback pelo mesmo vínculo transacional. A chave não é um controle de autorização.
- A operação de Q1 revalida `responsible_actor_id`, versão corrente e texto original dentro da mesma transação, com `FOR UPDATE OF ev` na versão modificada; conflitos não podem causar escrita parcial ou vazamento de entidade de outro ator.
- Revogação/transferência por qualquer caminho **não pode contornar** o mesmo lock; sem uma implementação homologada para isso, mutações de responsabilidade permanecem bloqueadas. Exceções administrativas e SQL manual também devem respeitar o contrato quando introduzidos.
- Lock da requisição precede lock da pergunta nos comandos atuais; estabelecer ordem determinística para fluxos que usem ambos. O código impede segunda pergunta na mesma transação; operações multi-pergunta exigiriam novo projeto e teste de deadlock.
- Um lock consultivo só serializa atores cooperantes. Transações externas que o ignorem podem invalidar a garantia. Não supor que PostgreSQL enforce o contrato por ACL/RLS.
- A fábrica conectada futura deve garantir atomicidade e que lock e SQL executem na **mesma conexão e transação**, com rollback em exceção, timeout definido, retry restrito e resolução de commit incerto por recibo idempotente. Evitar deadlocks entre lock consultivo e locks de linha.
- `hashtextextended` pode colidir; colisões de chave serializam adicionalmente, não podem conceder autorização. Usar domínios distintos para lock de requisição e pergunta, revisar protocolo de chave antes de G2.
- Regras de privilégios mínimos persistem: sem UPDATE em `investigation.question` para runtime até aprovação nominal; `FOR UPDATE OF ev` requer validação efetiva com ACL de coluna. Ausência de RLS significa que lock consultivo não substitui isolamento entre usuários.

## 2. Matriz de situações e resultados pretendidos
| Situação | Resultado obrigatório |
|---|---|
| Duas Q1 concorrentes na mesma pergunta e versão | Uma transição completa; outra detecta versão obsoleta e aborta |
| Q1 vs transferência/revogação | Ordem serial; Q1 recusada quando a revogação tiver precedido sua revalidação |
| Replay após revogação | Não entregar recibo como autorização; negar por escopo atual |
| Duas tentativas do mesmo request_id | No máximo um efeito, recibo consistente; conflito no fingerprint divergente |
| Q0 com oes_id global duplicado | Conflito sanitizado, rollback integral e nenhuma descoberta de propriedade de terceiro |
| Falha depois de gravar versão e antes do recibo | Rollback integral |
| Commit de resultado incerto | Não repetir mutação às cegas; conferir recibo em transação separada aprovada |
| Implementação de revogação sem lock cooperante | Fail closed: operação não habilitada |

## 3. Evidência e limites
A CI 142/142 verifica **somente protocolo e SQL gerado em simulações offline**. Não observa concorrência real, contenda, deadlock, SQL PostgreSQL, semântica da sessão ou privilégios efetivos de row lock. Não há fluxo de revogação homologado. O desenho de responsabilidade é sintético e não define usuários pesquisadores.

## 4. Próximos gates
1. Antes de G2, registrar uma especificação executável de *revocation protocol* ou manter revogações bloqueadas, e definir como garantir que nenhuma via concorrente não cooperante existe.
2. Preparar protocolo G2 fechado (apenas projeto/branch/banco sintéticos, identidade autorizada, casos/cleanup e limites), para **autorização nominal futura**. Não inferir aprovação de G2 a partir da autorização de G1.
3. Adiar Django conectado, contas de pesquisadores, HTTP write, RLS, deploy e E9 até gates próprios.

**Conclusão:** `P2_CONCURRENCY_REVOCATION_CONTRACT_DOCUMENTED / G2_NO_GO`. CP310 continua vigente, Marco B aberto, readiness NOT_READY, Fase 5 NOT_STARTED e E9 NO-GO.
