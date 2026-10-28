# OES — PF-I04/P4-A35 | Novo workflow candidato conectado sob HARD HOLD

**Data:** 2026-10-27 (America/Recife). **Estado:** `SEPARATE_WORKFLOW_CANDIDATE_CREATED / STATIC_HARD_HOLD_PASS / CREDENTIAL_LIFECYCLE_NO_GO`. **CP vigente:** CP326. **Nenhum Neon SQL executado e nenhum segredo cadastrado.**

## 1. Referências e alterações realizadas
- HEAD de referência inicial: `8f0795d66cd6caf6f5edc5dc0fcf8bc6cf813ac2`, Freshness Gate idêntico antes de publicar. HEAD antes deste parecer: `5fe2dfc2c077b0668ef34230714e044fb6d4ff9f`.
- **Novo workflow candidato** `.github/workflows/oes-pf-i04-p4-a35-connected-role-trial-candidate-hold.yml`. Git blob `41e1be3bad3aa0dee479306d8b55f6af321220ea`, publicação no commit `5fe2dfc2c077b0668ef34230714e044fb6d4ff9f`.
- **A32 intacto** `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml`, blob `955de382252e10a287880f387111b2f35d755daf`; run offline real A33 `40622890545` PASS, job conectado SKIPPED.
- Fonte SQL transacional A29, ainda NÃO executada: `archive/handoffs/oes/artifacts/CP325/OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql`, SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`.
- Fonte postflight A29, ainda NÃO executada: `archive/handoffs/oes/artifacts/CP325/OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql`, SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`.
- Verificações estáticas locais do workflow publicado: gatilho somente manual `workflow_dispatch`, `permissions: contents: read`, `connected-role-trial if: ${{ false }}`, `github.run_attempt == 1` no job offline, hashes e caminhos fixos, ausência de etapa de conexão no job offline, e duas travas textuais adicionais no job conectado. **Não equivalem a execução do YAML no runner**, e nenhuma execução remota foi disparada para A35.

## 2. Controles implementados; não são autorização
- **Três mecanismos de bloqueio simultâneos no job conectado:** `if: ${{ false }}`, `APPROVED_HEAD: 'NOT_AUTHORIZED'` (nenhum SHA aprovado), `CREDENTIAL_LIFECYCLE_GATE: 'NOT_APPROVED'` (sem programa de revogação). Mantê-los imutáveis até nova revisão e aprovação nominal de diff exato.
- `offline-integrity` compara SHA-256 dos dois SQLs, exige `BEGIN`, `ROLLBACK` e ausência de `COMMIT`, e verifica que as três travas estão presentes. Também só roda em `main` no repositório previsto e na tentativa `run_attempt=1`.
- O job conectado, **inalcançável**, contém projeto de `psql` com uma única invocação do arquivo A29, conexão DIRECT conhecida `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`, banco `oes_sandbox`, usuário `oes_sandbox_owner`, `PGSSLMODE=verify-full`, guardas `GITHUB_SHA=APPROVED_HEAD` e `GITHUB_RUN_ATTEMPT=1`, `ON_ERROR_STOP=on`, `ON_ERROR_ROLLBACK=off`, sem `-1` ou retry; log efêmero com `trap` de limpeza; exige 4 marcadores, mesmo PID, associação 1→2→2→1 e saída final `ROLLBACK`. Nenhum SELECT factual Django/Q0, nenhum GRANT de objetos ou COMMIT planejados.
- `environment: oes-p4-a35-owner-transient` é apenas uma **referência no YAML**; não há alegação de environment existente, revisor configurado ou segredo cadastrado. O segredo futuro candidato `OES_P4_A35_OWNER_PASSWORD_ONE_TIME` só poderá ser definido mediante procedimento de credencial e gate explícito, não agora.
- **Independência do postflight:** nenhum SELECT pós-ensaio automatizado no mesmo job; postflight A29 exige outro processo/sessão e autorização nominal própria, sobretudo em execução incerta. PASS de quatro marcadores não substitui confirmação independente.

## 3. Credencial administrativa — decisão de risco
O Neon documenta que **excluir um GitHub Actions Secret não revoga uma senha PostgreSQL**. Reinicializar senha de uma role no Console/API altera a credencial na origem; todos os consumidores que usam a senha anterior passam a falhar nas próximas conexões e precisam atualização. Isso preserva ownership da role, mas pode interromper outros processos; não presumir que o plugin Neon ou trabalhos anteriores não dependam dessa role.

**Alternativas admissíveis apenas como avaliação futura:**
- **A. Rotacionar `oes_sandbox_owner` antes e depois do ensaio**, com inventário de consumidores, plano de atualização/reversão e aprovação administrativa separada. Não adotar sem verificar impacto; senha nova não deve ser fornecida neste chat.
- **B. Criar papel LOGIN sintético de uso transitório e privilégios mínimos, com associação específica**, sujeito a novo desenho SQL, novo gate de criação/limpeza e testes de propriedade/SET ROLE. Isso adiciona papéis/grants e **não está autorizado**; jamais o fazer automaticamente para contornar o bloqueio.
- **C. Se não houver estratégia revogável e sem interferência de produção, permanecer em `NO-GO`**, sem conexão.
**Decisão A35: C (HOLD até comprovação de A ou B), sem escolher/implantar secret.**

Referências oficiais: https://neon.com/docs/manage/roles ; https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments ; https://docs.github.com/en/actions/reference/workflows-and-actions/contexts ; https://www.postgresql.org/docs/18/app-psql.html .

## 4. Riscos residuais / critérios para futuro gate
1. `run_attempt=1` bloqueia rerun da mesma execução, mas **não impede novo `workflow_dispatch` com novo run_id**. `concurrency` serializa, não entrega exatamente-uma-vez. Exigir invalidação da credencial na ORIGEM e controle de aprovação único.
2. Um workflow publicado com `if:false` e sentinelas não pode ser habilitado apenas alterando uma linha; a própria etapa offline exige as travas. Qualquer evolução demanda nova revisão de código, HEAD/commit SHA, e **reteste offline**, antes de considerar conectividade.
3. A variante A29 só recebeu revisão sintática/lexical, não execução PG18; comportamento `GRANTED BY`, `REVOKE ... RESTRICT` e `SET LOCAL ROLE` continua hipótese empírica.
4. Não há garantia de rollback em perda de rede sem postflight; exigir `SUMMARY/PASS` independente catalogal e nenhuma repetição de ensaio diante de falha.
5. Referência do environment não prova existência/proteções. Aprovação humana de projeto e segredo descartável continuam pré-condições; não instalar serviços pagos.

## 5. Ponto de continuidade
**P4-A35 concluída como implantação documental do candidato HARD HOLD.** Próxima P4-A36 recomendada: resolver e decidir documentalmente a viabilidade do ciclo de vida da credencial sem alterar nenhuma role/senha e preparar teste negativo offline da versão candidata. Se impossível, registrar NO-GO e interromper escalada de scripts administrativos. CP326 permanece vigente; checkpoint proporcional normalmente após 3–5 atividades ou mudança de risco. Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.
