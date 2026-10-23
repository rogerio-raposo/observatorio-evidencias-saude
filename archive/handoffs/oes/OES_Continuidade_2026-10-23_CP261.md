# OES — Continuidade CP261: Fase 4 concluída somente metodológica/documentalmente

**Data:** 2026-10-23. **Antecessor:** CP260. **Conversa atual: aberta.**  
**Estado atual:** `PHASE_4_CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY / OPERATIONAL_NOT_READY / PHASE_5_NOT_STARTED`.

## 1. Decisão expressa e evidência

O proprietário disse **“Minuta aprovada.”** ao [Documento 239](../../../docs/governance/239-minuta-gate-final-encerramento-metodologico-documental-fase4.md) (proposta de `APPROVED — OES / F4-FINAL-GATE / PASS_DOCUMENTARY_ONLY`); a manifestação aprovou **as seis condições C1–C6** e a delimitação de encerramento. O **[Documento 240](../../../docs/governance/240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md)** é o registro decisório final. Docs. 237–239 são antecedentes (critério → matriz → minuta) **não reescritos retroativamente**. O gate final é **`PASS_DOCUMENTARY_ONLY`**, *não* evidência operacional ou avaliação científica independente.

**O que foi aceito:** matriz F4-C01–F4-C06, cobertura SF-01–14, runbook R0–R8 e 12 cenários documentais (9 coerentes sem ressalvas adicionais; 3 condicionados AT-05/09/12). **Nenhum** dos 12 foi executado end-to-end na matriz; zero revisão humana independente. `C1` invalid_signal científico só por humano qualificado, `C2` A2≠A3 e competências reais, `C3` versionamento editorial protegido, `C4` currentness/sinais sem transições automáticas, `C5` BRGs/SA/migrations antes do ato futuro de risco, `C6` disclosure e fronteira de encerramento.

## 2. Fonte canônica e forma de trabalho

Repositório `rogerio-raposo/observatorio-evidencias-saude` branch `main`; ponteiro `archive/handoffs/oes/README.md`, template `archive/continuity/OES_Template_Abertura_Continuidade.md`, `STATE.md`, `CHANGELOG.md`. Ao retomar, ler ponteiro/CP261 e executar **Freshness Gate** contra HEAD `main` antes de qualquer ação e commit.

Cada `Prossiga` autoriza uma atividade delimitada seguida de **STOP**; checkpoint normalmente após 3–5 atividades ou risco/decisão; comunicações de progresso em trabalhos longos; nova ciência/operação requer nova autorização. Não utilizar ChatGPT Work. Usar ferramentas e frameworks existentes quando decidir implementação; evitar ciclos documentais e provas técnicas redundantes. Modos médio/alto conforme complexidade/risco.

## 3. Limites que permanecem vinculantes

- **Fase 4:** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; **readiness operacional:** `NOT_READY`; **Fase 5:** `NOT_STARTED`; `M3` formal `BLOCKED`; cadence/SLA normativos não calibrados. Encerramento documental não autoriza operação.
- **D0:** fechado documentalmente. **D1:** `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY` (Doc 228); T2-A2/A2-G4 deferido/não aceito, A2-G5/runtime não autorizado. Histórico 36 testes T1 e 75 totais T2-A1 PASS, sem validação factual. Branch preservada `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` SHA `96f16ec908b3f0f28199d841c90da471aa9e0ce1`; não modificar/mesclar.
- **D2:** factual global parcial e aberto. D2-E2 cliente NCBI recuperação pontual (run [39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270), 11/11 testes, quatro sementes, um Shaffer PMID 42841437 da consulta literal, não busca exaustiva). D2-E3 `CLOSED_RESTRICTED_DOCUMENTARY_RECONCILIATION_ONLY` (Doc 236). Estudos Zhou/Nazem como adendo de rastreabilidade no Doc 49, não modificaram Ficha ou GRADE. Fonte Shaffer original ZIP na Biblioteca pessoal `/OES/source-supplements/supplementary_material_zsag264.zip`, SHA-256 `d361ebf72e0b37c7d0bb0cb4adda0d61fac336e152e9371620278c419c8c7140`, não subir ao GitHub público; nova conversa deve confirmar acesso real ao arquivo.
- **Ficha N2** `OES-P-2026-000401`, baseline 2026-10-04, permanece A2 interno sem expert review; Documento 49 adendo factual autorizado, Docs 52/53, `ProductVersion`, currentness, assurance, gates científicos inalterados.
- **Governança técnica:** 36 migrations `UNREVIEWED`, BRG-03/06/07/08 `BLOCKED`, BRG-09 parcial, SA-05/06/07/08/10 abertos/diferidos, ledger/auditoria/backup/restore/fencing não homologados. Exigências antes de seus respectivos atos de risco, não dispensadas por fechamento da Fase 4. Nenhum Neon/SQL/CI, serviço pago, implantação ou autorização automática de Fase 5.

## 4. Ponto exato de retomada

**Próximo `Prossiga`: preparar comparação proporcional de opções para a prioridade pós-Fase 4**, distinguindo completar D2 factual delimitado, planejar implementação e governança operacional. Propor o mínimo avanço de benefício verificável e os gates correspondentes, **sem iniciar Fase 5, nova busca, código, infraestrutura, banco ou publicação por inferência**. Usar Doc 240 e CP261 como estado vigente; Docs 237–239 ficam como histórico do processo decisório.

**STOP — CP261; Fase 4 aprovada como encerrada apenas metodológica/documentalmente.**
