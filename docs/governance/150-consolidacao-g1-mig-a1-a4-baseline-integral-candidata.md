# 150 — Consolidação G1-MIG A1–A4: baseline integral candidata e critérios de revisão

**OES | Fase 4 | 2026-10-20 (America/Recife) | CP195 | modo médio**  
**Estado:** `G1_BASELINE_CANDIDATE_FULL_MANIFEST_36 — NOT_APPROVED_FOR_EXECUTION`. Registro de consolidação de quatro atividades internas posteriores ao CP194; nenhum SQL, CI, Neon, consulta de fonte ou gasto.

## 1. Freshness Gate, escopo e autoridade

HEAD CP194/main `8c89d3ae5b3f1a99fcba26d4422c36b712ae59b5` = identical, ahead 0, behind 0. Template equilibrado CP194, ponteiro e handoff CP194, Docs 146–149 e manifesto de 36 entrypoints constituem a base canônica. As atividades A1–A3 foram relatadas na conversa como **não persistidas**; A4 consolida seu conteúdo neste documento. A autoridade `PREPARE_G1_DOCUMENTARY_ONLY` permite análise GitHub e publicação documental, **não implantação**.

## 2. Evidências recuperadas de A1–A3

| Atividade | Constatação | Limite |
|---|---|---|
| A1 | Arquivos 021–028 inspecionados novamente; 021 define `maintenance.monitor_cycle`, 027 contém política/sinais/decisões. Busca textual limitada nas partes temporais 033c/033d/033e/035 não encontrou referências diretas aos objetos monitor/update selecionados. | Busca textual não prova independência de todas as funções/objetos ou de 031–032 |
| A2 | Inspeção estática de 031a–e e 032a–d identificou FKs obrigatórias de 031c, 032a e 032b para objetos preexistentes, inclusive `monitor_cycle`, `update_policy`, `update_signal`, `sla_rule`, `sla_instance`, `workflow_round`. | Referência em PL/pgSQL difere de FK; ainda não houve compilação, execução ou validação dos guards |
| A3 | Comparação arquitetural: cadeia integral preserva um manifesto e reduz a divergência de schema; versão reduzida exigiria nova closure de objetos, alteração de contratos e validação independente de invariantes. | Nenhuma das opções está pronta, e a extensão instalada pela cadeia integral amplia a superfície de risco |
| A4 | Consolidação das análises e escolha de baseline **somente candidata** para a próxima revisão de G1, com critérios de aceitação/rejeição explícitos. | Não concede OWNER_APPROVAL nem libera BRG |

**Interpretação técnica:** instalar somente 033–036 sobre banco vazio **não** é plano válido a partir dos scripts existentes: wrappers 031–032 apresentam FKs para a camada anterior. Não há demonstração de que todas as 36 entradas sejam tecnicamente indispensáveis, mas promover um subconjunto agora implicaria custo de projeto, auditoria e reconciliação adicional sem justificativa suficiente.

## 3. Comparação dos caminhos

| Critério | Manifesto integral de 36 entradas | Instalação reduzida |
|---|---|---|
| Aderência ao artefato versionado | Direta, preservado o manifesto candidato | Requer novo plano/possíveis variantes |
| Closure de FKs e contratos | Mantém os produtores previstos pela ordem, mas ainda não testada | Exige prova de subset, alterações ou compatibilização |
| Controle de divergência | Uma sequência principal | Duas variantes e risco de deriva |
| Superfície e permissões | Potencialmente maior; exige minimização e auditoria | Potencialmente menor, porém não demonstrada |
| Pós-condições e recibos | 36/36 UNREVIEWED, 0 aprovados | Também pendentes; provas possivelmente duplicadas |
| Adequação operacional hoje | **NOT_READY** | **NOT_DEMONSTRATED** |

**Recomendação documental:** `G1_BASELINE_CANDIDATE=FULL_MANIFEST_36`, para organizar a próxima inspeção — **não** para implantá-la. `REDUCED_VARIANT=DEFERRED_NOT_REJECTED`; reconsiderar se for demonstrado benefício material e cadeia comprovável, especialmente se superfície excessiva representar risco.

## 4. Critérios de aceitação/rejeição de qualquer baseline

**Aceitação exigirá, antes da execução e mediante decisões separadas:**

1. Revisão individual das 36 migrations, hashes de bytes, 14 subarquivos `\\ir`, closure de dependências e fronteiras transacionais.
2. Ledger imutável/verificável, evidência de migração independente do executor, sem replay automático de aplicação incerta.
3. Pós-condições verificáveis de objetos/FKs/triggers/ACLs; gates BRG-06/07/08 não podem ser preenchidos apenas pela leitura de cabeçalhos.
4. Papéis mínimos, separação de autoridade, trilha independente, backup externo e restauração comprovada.
5. Recursos dentro da política aprovada pelo proprietário; nenhuma cobrança, upgrade ou novo serviço pago autorizado.
6. Testes controlados em ambiente descartável **apenas após autorização específica**; não usar default branch do Neon como substituto de sandbox autorizado.
7. Decisão separada sobre novo epoch prospectivo, fontes PubMed/ClinicalTrials.gov e primeiras medições; nunca reabrir B1R1 expirado.
8. Avaliação humana/científica quando pertinente; nenhuma validação independente foi realizada.

**Rejeição ou suspensão:** falha de closure, manipulação privilegiada não auditável, ausência de backup/restore, impossibilidade de provar pós-condições ou privilégio mínimo, risco de cobrança, ou ausência de autorização do proprietário. Nesses casos preservar `BLOCKED` e considerar redução/alternativa documental sem operação.

## 5. Estado preservado

- `G1_BASELINE_CANDIDATE=FULL_MANIFEST_36` é **recomendação de planejamento**; `G1_EXECUTION_AUTHORIZATION=NOT_GRANTED`.
- `G0-D1..D5=PENDING_OWNER`; D6 habilita exclusivamente preparação documental.
- `BRG-03/06/07/08=BLOCKED`; BRG-04/05 históricos; BRG-09 evidência parcial, gate operacional não aprovado.
- 36 migrations `UNREVIEWED`; 0 pós-condições aprovadas; 36 requisitos 034–036 `NOT_COLLECTED`; 12 controles de roles insatisfeitos.
- B1R1 `EXPIRED_NOT_EXECUTED`, `NEW_EPOCH=NOT_AUTHORIZED`, `P_B_FACTUAL=NOT_AUTHORIZED`, M3 BLOCKED, Fase 4 documental NOT_READY e Fase 5 NOT_STARTED.

## 6. Continuidade equilibrada

Quatro atividades internas A1–A4 consolidadas em **um CP195 persistente**, reduzindo o custo de handoffs intermediários. O próximo `Prossiga` autoriza apenas **A1 do bloco pós-CP195**, começando pela inspeção documental de evidências verificáveis para o gate de migrations (G1-MIG/BRG-06), priorizando riscos concretos do manifesto integral e sem executar SQL. Relatar progresso durante trabalho prolongado.

**STOP.**
