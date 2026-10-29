# OES — Continuidade CP337 — 2026-10-29

**Anterior:** CP336. **Branch:** main. **Base de código inspecionada:** `79bd9c684e74bcc1659e19e0ef2133976e9071be`.
**Escopo:** PF-I03 Django First — revisão proporcional e reconciliação separada do candidato ORM Q0 sintético rollback-only.
**Situação:** Marco B OPEN; E9 NO-GO; Fase 5 NOT_STARTED; escritor conectado HARD HOLD.

## Consolidação A1–A4
- A1: Freshness Gate e diagnóstico; CP336 identificado como vigente, substituindo a referência histórica CP316 do prompt. Alteração posterior `c10fe203` em STATE define separação entre executor ORM temporário e reconciliador READ ONLY independente. Não a desconsiderar.
- A2: revisão estática confirmou reutilização de Django auth, PreparerIdentity, modelos `managed=False`, repositório e receita ORM de cinco INSERTs/rollback. Nenhuma razão para criar camada de persistência paralela; identidade sintética `oes:actor:<UUID4>` não prova identidade Django persistida.
- A3: commit `23afaadb9abc0594d18c4290cb579c9b4843f9a1`, receita ORM dormente passou a requerer `reconcile_alias` diferente do escritor, validar PostgreSQL e `transaction_read_only=on` da sessão de leitura, e consultar os cinco resíduos pelo alias separado. Configuração transacional executora e ativação do repositório NÃO implementadas.
- A4: commit `79bd9c684e74bcc1659e19e0ef2133976e9071be` deslocou callback de fase da reconciliação para dentro do bloco try/finally, evitando escapar ao fechamento do reader nesse caminho de falha. Correção **estática**, sem CI, sem execução conectada e sem comprovação de rollback PostgreSQL.
- O repositório `DjangoQ0Repository.__init__` e o entrypoint `execute_connected_q0` continuam HARD HOLD. O uso de `_trial_repository` não autoriza contornar o bloqueio. `settings_pf_i03_q0_readonly_trial.py` não é configuração escritora.

## Ressalvas técnicas materiais
- O alias separado, a verificação `transaction_read_only` e `current_user` não demonstram por si sós conexão ao mesmo branch/endpoint, nem privilégio exclusivamente SELECT; requer validação de configuração e ACL no gate próprio.
- Se `connection.in_atomic_block` permanecer verdadeiro após falha, o código entra em HOLD antes de reconciliar. Garantia de rollback, fechamento e verificação independente após falhas de banco ainda exige revisão dirigida.
- Nenhum teste automatizado pós-commits A3/A4 foi reportado. Não declarar PASS de CI ou prontidão operacional.
- Não há pesquisador vinculado; não atribuir a identidade sintética a pessoa real. Preservar Q0 e recibo sintéticos legados, baseline não vazia e cinco tabelas existentes.
- Documentos 360/361 não foram localizados pela busca da retomada; conferência documental específica ainda pendente, sem presumir que estejam ausentes.

## Próximo ponto de retomada
**Uma revisão proporcional do menor caminho Django-First executável, ainda offline**: inspecionar e sanar problemas transacionais materiais restantes, confirmar isolamento do alias e ACL da reconciliação, e determinar se a configuração temporária e ativação explícita do repositório podem ser implementadas sem novas abstrações. Evitar revalidações sintéticas repetitivas. Antes de qualquer teste com INSERT no Neon: proposta nominal integrada com escopo, credencial efêmera, rollback obrigatório, reconciliação independente, snapshot dos IDs, ausência de retry e recuperação fail closed. Somente executar após aprovação específica.

**Proibições preservadas:** sem novo SQL Neon, DML/DDL/GRANT, alteração de papéis, secrets, workflow conectado, HTTP write, deploy, serviço pago, dados reais, publicação ou promoção científica/operacional. G2-P2-B encerrado e não reabrir.

**Documentação de autoridade:** Documento 347 (Django First), Documento 362 (governança proporcional), `STATE.md`; este handoff é operacional, não normativo. Ponteiro único: `archive/handoffs/oes/README.md`.
