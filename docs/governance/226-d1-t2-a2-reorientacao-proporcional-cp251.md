# Documento 226 — Reorientação proporcional do trabalho OES/D1/T2-A2 (CP251)

**2026-10-22 | USER_APPROVED_PROCESS_REORIENTATION | DOCUMENTARY_ONLY | NO_NEW_TECHNICAL_GRANTS**

## 1. Decisão aprovada

O responsável pelo OES aprovou interromper a sequência padronizada de triagem → invariantes → revisão adversarial → decisão de não corrigir → revisão dessa decisão → checkpoint para cada risco. A prática consumiu cinco atividades em SA-07 (CP249) e cinco em SA-08 (CP250) sem redução demonstrada dos riscos por correção ou teste. A preservação dos seis arquivos do adaptador em branch segregada foi avanço concreto; análises documentais posteriores deram esclarecimentos úteis, mas com retorno marginal decrescente. **Não confundir produção documental com progresso funcional ou aceitação de gate.**

## 2. Novo protocolo proporcional de decisão

A cada atividade, escolher uma única entrega verificável e descrever sua contribuição concreta para o objetivo. Classificar riscos/achados uma vez, sempre que possível, em:
- **Correção estática demonstrável:** evidência textual suficientemente delimitada; formular intervenção mínima, preservar T1/T2-A1 e exigir autorização técnica específica para modificá-la;
- **Requer validação executável:** registrar o teste diferencial ou a condição necessária e diferir para um gate explicitamente autorizado, sem reanálises repetitivas;
- **Decisão de contrato/gate:** apresentar alternativas, risco residual e escolha necessária; nunca presumir autorização por análise;
- **Caracterizado sem novidade:** não reabrir sem evidência nova, defeito concreto ou mudança de escopo.

**Critério de parada de análises:** quando novas leituras não alterarem classificação, correção proposta, teste futuro ou decisão de gate, encerrar a análise e registrar limitação. Revisão adversarial extra somente se existir incompatibilidade nova, risco significativo ou solicitação explícita; não como etapa automática. Documentação consolidada por relevância/checkpoint, evitando documentos redundantes.

O modelo de acompanhamento passa a distinguir explicitamente quatro entregas: (1) problema comprovado por leitura; (2) correção mínima implementada **quando autorizada** e verificada nos limites autorizados; (3) prova por teste **quando autorizada**; (4) decisão de gate. Não anunciar "concluído" tecnicamente com base apenas em documentos.

## 3. Próxima atividade substitutiva

**A1 pós-CP251: avaliação integrada e única do caminho mínimo para encerramento da implementação estática A2-G4.** Reutilizar documentação SA-05/06/07/08/10 e fontes já preservadas; avaliar conjuntamente exceções/SQLSTATE, recibos/replay, normalização JSONB, atomicidade/cleanup. Construir matriz enxuta por risco: fato comprovado, impedimento **estático** de A2-G4, possível correção mínima, dependência de teste A2-G5, prioridade e decisão requerida. **Não iniciar mais uma triagem isolada SA-10** e não repetir os ciclos documentais de SA-07/08. O produto esperado é uma proposta discriminada de atividades técnicas mínimas e gate de autorização, não código alterado.

## 4. Proteções mantidas

Cada `Prossiga` autoriza **uma atividade delimitada**, seguida de STOP. Freshness Gate no início e imediatamente antes do commit. Checkpoints geralmente após 3–5 atividades, antecipados por risco/decisão significativa; esta mudança, por sua natureza, é um checkpoint excepcional. Mensagens de progresso em atividades longas. `STATE.md`/`CHANGELOG.md` atualizados por relevância.

Código A2 experimental **apenas** na branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1` (Documento 223). Nunca editar a branch preservada ou promover para `main` automaticamente. Alterações técnicas futuras exigem gate específico e branch de trabalho separada; mudanças em T1/T2-A1 dependem de autorização expressa. Nenhum import/compilação/execução de A2, testes, CI, SQL, Psycopg/Neon, grants, schema, migração, dados reais, implantação, pagamento ou promoção científica é autorizado por este documento.

Permanecem: SA-05 global ABERTA/ALTA; SA-02 condicionada; SA-03 parcialmente mitigada; SA-06 aberta; SA-07 ABERTA/MODERADA; SA-08 ABERTA/ALTA; SA-10 aberta; SA-11/12 mitigadas só estaticamente. A2-G4 **não aceito**; A2-G5 e runtime `NOT_AUTHORIZED`. T1 36 e T2-A1 75 PASS são **históricos**, não reexecutados. 36 migrações UNREVIEWED; Fase 4 NOT_READY, Fase 5 NOT_STARTED. D0 encerrado; D1 sintético prioritário; D2 factual diferido. CP250 e Documentos 224–225 permanecem evidências históricas, não apagados.

## 5. Critério de sucesso da reorientação

Um novo ciclo só é avanço real quando: fecha uma decisão, identifica um defeito novo que altera o plano, apresenta correção objetiva autorizável, implementa correção autorizada, ou fornece evidência validada autorizada. Número de documentos ou checkpoints não é KPI de progresso. Ao término da avaliação integrada, propor um único plano mínimo com dependências e solicitar aprovação apenas se houver ação fora dos gates vigentes.

**STOP — reorientação documental aprovada; nenhuma permissão técnica ampliada.**
