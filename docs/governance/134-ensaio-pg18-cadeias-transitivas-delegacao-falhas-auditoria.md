# 134 — Ensaio PG18: ADMIN FALSE, cadeias de roles e falhas adversariais de auditoria

**Fase 4 — Protocolo de Atualização | 2026-10-20 (America/Recife) | modo alto**

**Estado:** PG18_SYNTHETIC_ROLE_AND_AUDIT_FAILURES_40_OF_40_PASS — NO_NEON — NO_OPERATIONAL_GATES_PROMOTED.
**Entrada:** CP177 / Documento 133 / HEAD 73280fd0fdc7f0dd440feee0f741299d1d34e476.

## 1. Freshness Gate, autorização e fronteira

Ponteiro e handoff CP177, STATE.md, CHANGELOG.md e Documento 133 consultados. HEAD CP177 e main coincidiram: identical, ahead=0, behind=0. Autorização do usuário: um checkpoint sintético e sua documentação; não inclui Neon, qualquer custo, Fase 5, nem reativação de B1R1.

## 2. Implementação restrita

Script: scripts/oes_f4_pg18_role_transitivity_audit_adversarial.py.
Workflow: .github/workflows/f4-pg18-role-transitivity-audit-adversarial-synthetic.yml.

A CI utiliza serviço postgres:18 efêmero, interface 127.0.0.1:5432, banco allowlisted oes_f4_cp178_synthetic, credenciais exclusivamente artificiais e sem segredos Neon. O script exige GITHUB_ACTIONS=true, repositório esperado e variáveis de conexão locais; recusa DATABASE_URL, PGSERVICE e PGSERVICEFILE. Workflow: contents: read, checkout sem credencial persistente, artifact retido também em falhas.

Migrations 001–036 foram aplicadas somente na instância PG18 descartável. Para avaliar DDL proprietário, a tabela maintenance.temporal_observation_epoch e seu trigger de cronologia da migration 034 receberam owner NOLOGIN apenas na fixture. Nenhum arquivo SQL histórico foi modificado.

Foram criadas três identidades LOGIN, role proprietária NOLOGIN e três roles intermediárias NOLOGIN. Seis arestas de membership usaram ADMIN FALSE com combinações separadas de SET e INHERIT. Uma role de destino sem membership permitiu verificar delegação negada.

## 3. CI verificada e integridade do artifact

- Run 39410126403: completed/success.
- Job 118585562919: completed/success, todas as nove etapas concluídas com sucesso.
- Commit técnico 909922efd400b237181445c5a206f97b3fcc19e9.
- 40/40 PASS em checks.tsv, nenhum FAIL; logs e marcador CP178_PG18_SYNTHETIC_LIMITED_PASS conferidos.
- Artifact f4-pg18-role-transitivity-audit-cp178, ID 12259205919, 11 arquivos, ZIP testzip()=None.
- SHA-256 ZIP 4577ddde26943d00c05e7dc9b4143ab288d106aa4692ee5e04a1e641f3be5c46, idêntico ao digest GitHub.
- Arquivos de evidência incluem checks.tsv, result.json, result.txt, membership-options.txt, receipt-runner-only.jsonl, audit-anchor.json, forgery-demonstration.json, commit.txt e versões de cliente/servidor.
- Result.json: neon_accessed=false; neon_sql_executed=false; neon_branch_created=false; paid_services_activated=false; operational_brg_promoted=false.

## 4. ADMIN FALSE e escalada por membership transitivo

1. As três credenciais LOGIN conectaram-se diretamente e identificaram a sessão. A owner NOLOGIN não autenticou. O catálogo pg_auth_members confirmou seis arestas e seis admin_option=false.
2. Sem ADMIN OPTION, tentativas de conceder owner diretamente ou conceder role intermediária foram negadas. Também foi negada no fixture a tentativa de GRANT owner após assumir a própria owner via SET ROLE. Nenhuma membership de teste permaneceu na role-alvo.
3. Caminho actor -> mid_set -> owner, ambas as arestas SET TRUE/INHERIT FALSE: pg_has_role(..., SET) retornou true e USAGE retornou false; a tentativa de ALTER TABLE sem SET ROLE falhou. Após SET ROLE owner, foi possível DISABLE TRIGGER 034 em transação; ROLLBACK preservou o trigger habilitado.
4. Caminho actor -> mid_block -> owner, com uma aresta SET FALSE e INHERIT FALSE: SET ROLE e ALTER TABLE sem acesso proprietário foram negados.
5. Caminho actor -> mid_inherit -> owner, com ambas as arestas INHERIT TRUE e SET FALSE: pg_has_role(..., USAGE) retornou true; SET retornou false. O ator executou DDL para desabilitar trigger 034 **sem SET ROLE**, por herança de privilégios do proprietário. ROLLBACK deixou trigger habilitado.

Interpretação: ADMIN FALSE restringiu a delegação testada, mas não elimina direitos proprietários atingíveis por caminhos transitivos SET ou INHERIT. A presença de uma role NOLOGIN e a negação de ADMIN OPTION não bastam como garantia operacional contra desabilitação de guards.

## 5. Completude, queda simulada e adulteração de recibos

O wrapper produziu quatro recibos JSONL (dois pares attempt/result) com hashes SHA-256 encadeados e âncora final. JSONL e âncora estão no mesmo filesystem do runner GitHub Actions; não são externos à confiança administrativa, apenas à transação PostgreSQL.

- Falha simulada do controlador: inclusão de um attempt sem result em uma cópia dos registros foi rejeitada como trilha incompleta. Não houve kill do processo; a ausência de result NÃO determina se o SQL foi ou não executado. Não há prova de retomada, durability externa ou captura em tempo real.
- Comando fora do wrapper: uma sessão SQL direta usando elevação permitida desabilitou o trigger 034; a cadeia de quatro recibos permaneceu inalterada e considerada válida. Outra sessão direta restaurou o trigger, igualmente sem novos recibos. Integridade não implica completude.
- Mutação isolada do resultado: rejeitada pelo verificador.
- Mutação conjunta do resultado e de todos os hashes subsequentes, acompanhada da substituição da âncora: aceita pelo verificador. O arquivo forgery-demonstration.json registra forged_outcome=FORGED_CONFIRMED, âncora original 72cb64149a72789654fe4e63d805a4245905886748c0c21c902c5f1280ae4a3b e final refeito b1d2830dfd4d130e934025b033dd7430a9226ff6f26951fea3ab01689626250a.

Conclusão restrita: hash chain e âncora no mesmo domínio de controle não provam integridade independente, autenticidade, imutabilidade, disponibilidade, cobertura de SQL fora do wrapper nem transparência de operações administrativas realizadas por fora. A violação comprovada é local e sintética; não existe coletor independente configurado.

## 6. Gates preservados sem promoção

- BRG-03: TLS, privilégios, segurança e auditoria externa Neon não verificados operacionalmente.
- BRG-04/05: evidências estáticas e sintéticas históricas válidas somente para commits específicos.
- BRG-06: ledger não operacional; BRG-07: supervisor/fencing/runner não operacionais; BRG-08: backup/restore independente pendente; BRG-09: console billing e custo sob decisão do titular.
- Catálogo: 36 migrations UNREVIEWED, zero pós-condições aprovadas, flags de reconciliação automática FALSE; matriz 034–036: 36 evidências NOT_COLLECTED.
- Modelo-alvo de seis papéis e doze controles não satisfeitos operacionalmente; revisão humana de segurança/PostgreSQL pendente.
- Nenhuma branch Neon, SQL ou migration Neon; nenhum serviço pago autorizado; B1R1 EXPIRED_NOT_EXECUTED; PHASE_5 NOT_STARTED.

## 7. Retomada proposta, sem execução

Se autorizado em checkpoint seguinte, desenvolver desenho de contenção de propriedade indireta (SET/INHERIT, administração, elevação), oráculos para prova da execução administrativa e condições para evidência de auditoria externamente ancorada, avaliando dependências de custo e revisão humana antes de escolher infraestrutura. Permanecer em documentação/ensaios descartáveis, sem promover gates ou presumir recursos gratuitos.

**STOP — Documento 134 / CP178, requer novo Prossiga para avançar.**
