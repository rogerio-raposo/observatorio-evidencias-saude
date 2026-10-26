# Documento 313 — PF-I02-I01-B: proposta verificável de migração Q0→Q1

**Data:** 2026-10-25. **Estado:** `DESIGNED_NOT_APPLIED`. **Atenção:** SQL abaixo é somente proposta; **não executar** nem interpretar como autorização de DDL, DML, Neon, roles, migrações ou deploy. Base: Docs. 309, 311 e 312, CP298.

## Lacuna confirmada
`database/poc-s1.sql` exige `investigation.question_version.normalized_text NOT NULL`. Isso impossibilita representar Q0 recebido sem Q1. O esquema oferece `core.entity_version` (unicidade de versão, supersessão, `created_by`) e `investigation.question_version`; a nova função deve reutilizá-los e **não criar Investigation**.

## Alteração estrutural mínima proposta
Adicionar estado **técnico de preparação** na tabela `investigation.question_version`, não um estado de aprovação científica. Atribuir `legacy_complete` a versões já existentes, sem reinterpretá-las como preparação nova. Permitir `normalized_text=NULL` só em `q0_draft`; `q1_proposed` e `legacy_complete` exigem texto Q1 presente. Contrato de Q0 original continua `NOT NULL`.

### Candidato SQL para revisão humana (não executar)
```sql
-- REVIEW ONLY — PF-I02-I01-B; require approved target/schema preflight.
BEGIN;
ALTER TABLE investigation.question_version
  ADD COLUMN preparation_stage text NOT NULL DEFAULT 'legacy_complete';
ALTER TABLE investigation.question_version
  ALTER COLUMN normalized_text DROP NOT NULL;
ALTER TABLE investigation.question_version
  ADD CONSTRAINT ck_pf_i02_question_preparation_stage
  CHECK (
    (preparation_stage = 'q0_draft' AND normalized_text IS NULL)
    OR (preparation_stage IN ('q1_proposed', 'legacy_complete')
        AND normalized_text IS NOT NULL)
  );
COMMIT;
```

**Limitações explícitas:** o `DEFAULT legacy_complete` serve à compatibilidade histórica, não à criação de nova Q0. O estado `q1_proposed` não equivale a `core.entity_version.version_status=current` nem autoriza E9. A solução não implementa audit trail transacional, idempotência nem guarda imutável de `original_text`; esses controles precisam existir no primeiro write path e/ou constraints adicionais validadas. Não executar automaticamente o script acima em banco existente sem inspeção dos objetos atuais, privilégios e política de migração.

## Critérios de verificação antes de aprovar qualquer DDL
1. Verificar schema real, versões de migração e dependências em ambiente alvo explicitamente autorizado; `poc-s1.sql` é PoC, não prova de estrutura em Neon.
2. Confirmar que todas as linhas legadas têm `normalized_text` não nulo; validar que `legacy_complete` preserva histórico sem falsificar assurance.
3. Simular em ambiente descartável aprovado: linha Q0 sem normalizada é admitida **apenas** com `q0_draft`; `q1_proposed` exige texto; valores de estágio inesperados são rejeitados.
4. Verificar rollback em transação e concorrência com `core.entity_version`; documentação de lock/timeout e comportamento de falha.
5. Confirmar que a migration não toca `investigation.investigation`, qualquer produto N2 ou a abertura E9.
6. Separadamente decidir idempotency key, audit trail e actor ID em transações T1/T2; sem isso `PF-I02-I01-D` não pode ser aceito.
7. Definir rollback operacional seguro: após novas Q0 com `normalized_text=NULL`, `SET NOT NULL` não é reversível sem decisão de preservar/migrar tais dados. **Não** preencher Q1 artificialmente, apagar Q0 nem prometer rollback automático após gravação real.

## Decisão
**I01-B preparado no âmbito documental**, não comprovado conectadamente. Próxima decisão útil: autorização/seleção de ambiente para verificar schema e implementar gate de persistência, com preflight read-only antes de qualquer DDL e autorizações independentes para mudanças. Não incrementar protótipo em memória.

Invariantes: E9 NO-GO; sem pesquisadores e sem A3; Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
