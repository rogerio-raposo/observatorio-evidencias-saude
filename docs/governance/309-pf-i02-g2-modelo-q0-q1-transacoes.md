# Documento 309 — PF-I02-G2: adaptação mínima do schema Question para Q0→Q1

**Data:** 2026-10-25. **Natureza:** parecer de desenho read-only, sem autorização para DDL/DML, migration, grants, autenticação, deploy ou escrita HTTP. **Base:** Docs. 306–308, CP297, `database/poc-s1.sql`.

## Conclusão de compatibilidade
As tabelas `core.entity`, `core.entity_version`, `investigation.question` e `investigation.question_version` são base suficiente para **planejar** Q0→Q1. Ainda não são suficientes para realizar o fluxo sem decisão sobre semântica de Q0, ator e concorrência:
- `question_version.original_text` e `normalized_text` são ambos `NOT NULL`; logo a inserção isolada de Q0 sem normalização Q1 exige uma adaptação. **Proibição explícita de copiar Q0 para `normalized_text` e fingir Q1.**
- `core.entity_version` fornece `version_no`, `supersedes_version_uuid`, `created_by`, estados e unicidade de versão; estes controles não implementam sozinhos autenticação ou proteção contra corrida.
- `ux_entity_version_current` permite no máximo uma versão marcada `current`; propostas Q1 não devem ser promovidas a conclusão científica.
- O caso histórico de `database/f3-real-case-01-dcbti.sql` escreve Q0 e Q1 juntos numa versão já existente. Não implica autorização para substituir esses dados nem modelo para registrar Q0 preliminar.

## Adaptação proposta — mínima e sujeita a G3/G4
**Preferência:** aceitar `normalized_text NULL` exclusivamente enquanto o registro está no estágio de Q0 preparatório, condicionado por estado controlado de preparação, e exigir `normalized_text NOT NULL` para as versões com Q1 efetivamente proposta. Esse estado precisa ser persistente, auditável e inequivocamente independente dos estados científicos; escolher entre extensão estritamente mínima do esquema e mecanismo já aprovado antes de elaborar migration. Não executar a mudança neste gate. Alternativa de armazenar Q0 em área provisória deve ser rejeitada se introduzir segundo registro durável sem integração transparente com `core.entity_version`.

**Transação candidata T1 (Q0):** validar sessão/permissão, atribuir ID único no servidor e chave idempotente, `BEGIN`; inserir `core.entity` tipo Question, `investigation.question`, `core.entity_version` versão 1 e `investigation.question_version` com Q0 literal, Q1 ausente; registrar auditoria; `COMMIT`. Falha: rollback, sem registro parcial e sem mascarar commit incerto como rollback.

**Transação candidata T2 (Q1):** validar sessão e propriedade/permissão, bloquear a entidade/versionamento para serializar duas alterações concorrentes, exigir `expected_version_uuid`/versão vigente, preservar o mesmo `original_text` imutável e escrever `normalized_text` proposta em nova `entity_version` com `supersedes_version_uuid` e justificativa. Alterar status de versão anterior com cuidado para satisfazer índice único e rastreabilidade; commit atômico com log do ator e resultado.

## Regras que precisam de verificação na implementação
1. Integridade Q0: comparar texto exatamente, sem `strip`/normalização silenciosa; limites de tamanho e tratamento Unicode explícitos na fronteira HTTP.
2. Identidade: evitar `created_by` arbitrário vindo do formulário; persistir identificador estável de usuário autenticado e autoria da ação, com politica de acesso.
3. Concorrência: `SELECT ... FOR UPDATE` ou semântica equivalente sob transação, restrições de unicidade, tentativa obsoleta gera conflito sem sobrescrever.
4. Idempotência: retry com a mesma chave/payload deve retornar resultado existente; mesma chave com payload diferente deve falhar sem escrita.
5. Estados e imutabilidade: não sobrescrever `original_text` de Q0; novas versões para mudanças Q1; `draft/current` técnicos não equivalem a aprovação E9.
6. Auditoria: registrar tentativa/resultado e transações relevantes, evitar introduzir uma segunda trilha descoordenada; distinguir falha pré-commit de resultado incerto.
7. Autorização no banco: role de menor privilégio futura só para tabelas estritamente necessárias, sem `investigation.investigation`; a permissão SQL não substitui autorização Django.
8. Migração: provar compatibilidade com dados históricos e snapshots imutáveis e oferecer rollback explícito **antes** de qualquer DDL.

## Lacunas e proibições
Não há implementação aprovada de identidade/sessões Django, nem política persistente Q0-only, nem role de escrita operacional, nem transação Q0→Q1 validada conectadamente. O esquema atual **não** permite representar Q0-only fielmente sem adaptação. E9 fica fora do grafo de comandos/rotas. Não utilizar dados reais clínicos de usuários, conexões PG-A4/E6 ou serviços pagos.

## Parecer e próxima fronteira
**PF-I02-G2: desenho mínimo especificado, não validado em banco.** Recomendo prosseguir a **G3 — análise de privilégio mínimo, infraestrutura de segredos e isolamento de autenticação** e depois produzir um único pacote implementável G4, evitando subdivisões artificiais. Marco B aberto; A3 ausente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
