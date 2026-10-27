# OES — CP314 | Encerramento do ensaio conectado Django Q0 com rollback
**Data:** 2026-10-27. **Anterior:** CP313. **Base factual HEAD:** `789b304c4fb23b1010c2ffdbf6932a18b7bb8868`.
**Natureza:** checkpoint de continuidade e encerramento técnico experimental, sem promoção operacional.

## Marcos confirmados
- Django READ ONLY conectado como `oes_qprep_login`: [run 40506158071](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40506158071) PASS; papel mínimo, `session_user=current_user`, banco `oes_sandbox`, sem privilégios administrativos.
- CI offline: [run 40525714502](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40525714502), commit `29af77e28722973dc75319bb4a9bbb6525d0e19b`: 177/177 PASS, Django check PASS, compilação de script e recipe PASS.
- Ensaio conectado transacional sintético Q0: [run 40525954698 tentativa 2](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40525954698) PASS com `oes_qprep_login`; cinco INSERTs ORM verificadas na transação; rollback obrigatório; cinco checagens pós-rollback sem resíduos; `PASS_ROLLED_BACK_ZERO_RESIDUES`. Tentativas anteriores falharam antes da conexão e não são evidência de inserção.
- **Segredo descartável:** proprietário confirmou nesta conversa exclusão de `OES_QPREP_LOGIN_PASSWORD` no GitHub Actions e rotação de senha do perfil. Registro declaratório; não implica verificação independente do estado do segredo ou da senha. Não reconstituir, solicitar nem guardar credenciais.

## Limites inalterados
- Ensaio experimental de rollback **encerrado**; não interpretar como autorização de escrita persistente, ativação do writer da aplicação, GET factual, HTTP write, E9, deploy, migração ou dados reais.
- `applications/oes_web/config/settings.py` permanece sem writer operacional habilitado por padrão; repositório ORM público dormente e `execute_connected_q0` bloqueados. O workflow manual de ensaio é histórico; não repetir sem necessidade e controle específico de credencial.
- **G2-P2B operacional NO-GO; E9 NO-GO; Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED. Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY.** Django-first mantido. Neon branch `br-gentle-hall-b6jaxehf`, project `weathered-boat-65779510`, DB `oes_sandbox`.

## Próximo passo de continuidade
Retomar **reavaliação das macroatividades e critérios do Marco B**, priorizando decisão funcional e governança sobre novas provas redundantes de ORM/rollback. Examinar o que é estritamente necessário para evolução controlada do protótipo Django, identificar dependências de pesquisadores reais (ainda indisponíveis) e preservar os gates. Não aprovar nem executar escrita persistente, acesso público ou Fase 5 por inferência.

## Disciplina
Cada `Prossiga` autoriza uma atividade interna delimitada; checkpoints normalmente após 3–5 atividades significativas ou novo marco. Freshness Gate no início e antes de alterações. Atualizar `STATE.md` e `CHANGELOG.md` somente por relevância. CP314 substitui CP313 como ponteiro canônico, preservando CP313 imutável.
