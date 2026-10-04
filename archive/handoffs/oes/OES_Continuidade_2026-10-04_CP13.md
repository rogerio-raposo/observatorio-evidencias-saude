# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP13  
**Checkpoint anterior:** CP12  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 2 — execução e fechamento do GATE F2-B  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP13

Estado formal:

> **Fase 0 — Concepção e fundamentos: BASE INICIAL CONSOLIDADA**  
> **Fase 1 — Manual Metodológico: BASE INICIAL DOS DOCUMENTOS 10–15 CONSOLIDADA**  
> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **GATE F2-A — PASS / APROVADO**  
> **OES-H1 — ARQUITETURA CANDIDATA**  
> **OES-P1 — CANDIDATO FÍSICO VALIDADO NO ESCOPO DO F2-B**  
> **GATE F2-B — PASS**  
> **STACK DE PRODUÇÃO / SCHEMA DEFINITIVO — NÃO APROVADOS**

Base documental anterior à criação deste checkpoint:

`main @ 12fdf474f5ae40fa47cb0517e5fc4ac3222b95aa`

---

# 2. Freshness Gate que antecedeu este checkpoint

O ponteiro operacional ainda indicava CP12.

A comparação contra `main` mostrou avanço material posterior ao CP12, incluindo:

- Documento 30 — Política de Migrações;
- migration `OES-DBM-2026-0002`;
- Documento 31 — PoC-S2;
- workflow real de validação PostgreSQL;
- execução parcial anterior do F2-B.

Consequência:

> **CP12 permaneceu válido como snapshot histórico, mas deixou de ser base operacional atual.**

A retomada foi ajustada conforme a documentação canônica, sem reabrir trabalho já persistido.

---

# 3. Artefatos consolidados desde CP12

## Arquitetura

- `docs/architecture/30-politica-migracoes.md`
- `docs/architecture/31-poc-s2-validacao.md`
- `docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md`
- `docs/architecture/32-resultado-gate-f2b.md`

## Database / PoC

- `database/002_poc_s2_search_screening_risk.sql`
- `database/003_poc_s3_provenance_guard.sql`
- `database/f2b-fixtures.sql`
- `database/f2b-tests.sql`
- `database/f2b-rebuild-check.sql`

## CI

- `.github/workflows/validate-f2b.yml`

---

# 4. Resultado formal do GATE F2-B

Execução final válida:

- **GitHub Actions run:** 37187885839
- **Run number:** 9
- **Commit testado:** `de168908d8fe311e64c07937dc70df36af39d910`
- **PostgreSQL server:** 18.6
- **Conclusão:** success
- **T01–T19:** PASS
- **Rebuild do zero:** PASS

Artifact de evidência:

- ID: **11297272424**
- nome: `oes-f2b-evidence-37187885839`
- digest: `sha256:5381605d34064f95a2d4444e34d275b8c89ceb28a19cc915db104da9362c1d7c`

Registro persistente:

`docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md`

---

# 5. Propriedades validadas em runtime

A bateria comprovou, dentro do escopo do candidato:

1. instalação limpa do baseline e migrations;
2. smoke da cadeia científica principal;
3. unicidade de versão corrente;
4. supersessão dentro da mesma entidade;
5. integridade de subtipo;
6. integridade referencial;
7. invariantes de Result;
8. coerência de intervalo de confiança;
9. regra de certainty para `no_evidence`;
10. versionamento v1→v2 preservando histórico;
11. provenance history-preserving;
12. lineage canônico e dependency projection;
13. rollback atômico;
14. rebuild do zero;
15. detecção de reaplicação acidental de migration;
16. regras de ScreeningDecision;
17. integridade de RiskAssessment;
18. preservação de SearchHits após deduplicação;
19. reconstrução Search → Product.

---

# 6. Provenance hardening

A migration `OES-DBM-2026-0003` adicionou proteção contra:

- DELETE de registros materiais de provenance;
- UPDATE destrutivo de origem/target/transformação;
- retorno indevido de registros superseded/invalidated a estados incompatíveis.

Correção de provenance ocorre por novo registro e cadeia de supersessão.

T11 validou esse comportamento em PostgreSQL real.

---

# 7. Correções operacionais ocorridas

## T09/T10

O harness inicialmente criava colisão artificial de `version_no` entre T09 e T10.

Foi corrigido para que T09 use uma versão de teste isolada.

A correção não relaxou nenhuma invariant do schema.

## GitHub Actions concurrency

Uma execução antiga permaneceu em fila e bloqueou runs posteriores sob a política de concurrency existente.

A cláusula de concurrency foi removida para permitir a execução final independente.

Esse evento é classificado como:

> **questão operacional de CI, não falha metodológica ou estrutural do modelo.**

A política futura de concorrência do workflow permanece item operacional a revisar antes de uso contínuo intensivo.

---

# 8. Decisão sobre OES-P1

Conforme Documento 27:

> **GATE F2-B = PASS**

Entretanto, conforme Documento 25, os critérios para promoção integral de OES-P1 são mais amplos.

Portanto:

> **OES-P1 permanece candidato físico, agora VALIDADO NO ESCOPO DO F2-B.**

Não fica autorizado tratar:

- OES-P1 como schema definitivo;
- PostgreSQL como stack de produção definitiva;
- OES-H1 como arquitetura final;
- Fase 2 como encerrada.

---

# 9. Critérios ainda não suficientemente cobertos para promoção

O Documento 25 contém 15 critérios de promoção.

O F2-B cobriu vários componentes fundamentais, mas não valida integralmente, entre outros:

- NMA;
- PredictionModel;
- síntese qualitativa/CERQual;
- cenários ampliados de Study ↔ Report;
- ReportRelation para correções/retrações;
- impact analysis completo;
- outros métodos especializados.

Não se deve expandir o schema por conveniência. Novas PoCs devem corresponder a lacunas demonstradas nessa matriz de promoção.

---

# 10. Ponto exato de retomada

## Revisão de Promoção Arquitetural Pós-F2-B

Próxima tarefa:

1. recuperar os 15 critérios de promoção do Documento 25;
2. classificar cada um como:
   - validado;
   - parcialmente validado;
   - não validado;
   - fora do escopo imediato;
3. apontar a evidência concreta para cada classificação;
4. identificar o menor conjunto de PoCs adicionais;
5. separar critérios de **baseline arquitetural** de critérios de **produção**;
6. definir o caminho objetivo para fechamento da Fase 2.

Não criar novas extensões de schema antes dessa revisão, salvo correção necessária de defeito já demonstrado.

---

# 11. Regra para retomada

Antes de continuar:

1. consultar o ponteiro operacional;
2. ler este CP13;
3. aplicar o Template Canônico em Modo Continuidade;
4. executar Freshness Gate contra `main`;
5. consultar `STATE.md`, Documentos 25, 27 e 32;
6. confirmar o resultado F2-B;
7. iniciar a Revisão de Promoção Arquitetural Pós-F2-B.

---

**Fim do CP13**
