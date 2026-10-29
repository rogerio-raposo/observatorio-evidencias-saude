# OES — Controle de tentativa única via referência Git (candidato inerte)

Data: 2026-10-29. Base: validação Django 293/293 PASS (40962181610) e atestação conectada READ ONLY PASS (40962343481).

## Decisão técnica

Usar criação condicional de **referência Git com nome fixo** `refs/tags/oes-q0-rollback-single-attempt-20261029`, via `POST /repos/{owner}/{repo}/git/refs`. Apenas a criação bem-sucedida HTTP 201 com ref exata marca uma tentativa como CONSUMED. Qualquer erro, exceção, timeout, resposta divergente ou referência preexistente = HOLD, sem retry e sem DML. O marcador é **prévio** à concessão/uso da credencial de escrita. Um ensaio que falhe após consumo **não é repetido**. O SHA alvo deve ser pré-revisado e fixo. A decisão deve ser associada ao run ID em auditoria independente.

Contrato implementado, **ainda não executado**, em `applications/oes_web/scripts/q0_single_use_git_ref_gate.py`. O módulo não tem conexão DB. Por padrão `consume()` rejeita a chamada sem flag explícita; nenhum workflow o importa ou executa. O workflow conectado permanece `if: false` e `contents: read`.

## Limites e risco residual

A GitHub REST API fornece operação de criação de referência com resposta 201 e validações de erro. A unicidade do nome oferece exclusão de uma segunda criação enquanto a referência permanecer. **Não há imutabilidade absoluta:** pessoas/tokens com poder de exclusão podem remover a referência, e APIs do GitHub têm operação DELETE. Por isso, controle de permissões/proteção de tag e revisão de administradores são condições anteriores à alegação de garantia forte. O status 422 também pode ser validação ou limitação; sempre HOLD, sem supor motivo. `concurrency` permanece apenas defesa complementar, jamais o controle primário.

A futura autorização operacional precisa revisar a permissão temporária `contents: write` exclusivamente para o job de consumo, eliminar a possibilidade de disponibilizar segredos científicos antes de confirmar `ATTEMPT_CONSUMED`, fixar SHA e proibir re-run com poderes de escrita. GitHub settings de proteção de referências devem ser inspecionadas antes. Qualquer incerteza = NO-GO.

## Estado atual

Os testes offline do candidato foram adicionados ao CI principal, mas **ainda não estão comprovados por uma execução nova**. Não houve criação de tag, alteração do Neon, novos segredos, INSERT ou consumo da autorização. O verificador READ ONLY já está comprovado. Próximo passo: verificar CI offline; auditar controles de exclusão de tag e definir o workflow operacional isolado de forma que a referência seja consumida antes de qualquer credencial escritora.

CP343 vigente. Marco B OPEN, Q0 geral HARD HOLD, E9 NO-GO, Fase 5 NOT_STARTED.
