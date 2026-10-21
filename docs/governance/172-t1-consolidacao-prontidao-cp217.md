# Documento 172 — D1-T1: consolidação dos incrementos e prontidão (CP217)

**OES | 2026-10-21 | avaliação documental | T1 EM DESENVOLVIMENTO — NÃO ENCERRADO**

## Autoridade
- Prioridade vigente (Documento 169): D0 concluído documentalmente → D1 funcional sintético (atual) → D2 factual condicionado → governança operacional completa posterior.
- Estrutura técnica candidata (Documento 170): núcleo Python modular, persistência preferencial PostgreSQL apenas em etapa futura autorizada, preferência por nuvem e software livre/gratuito, sem serviços pagos.
- Autorização efetivamente concedida e registrada no Documento 171: `OES / D1-T1 / PYTHON_SYNTHETIC_DOMAIN_ONLY`, com Python/testes locais/in-memory/renderer/versionamento GitHub; exclui SQL, Neon, CI remota, nuvem, API pública, dados factuais, migrations, serviços pagos e mudança de gates.
- O Documento 165 mantém o valor histórico de sua aprovação documental mais estreita. Os documentos posteriores suplementam prospectivamente, sem falsificar autorizações antigas.

## Inventário material conferido em main
HEAD pré-CP217: `bbd0d61d7270cf139c1a895503fc29dd0ec043ab`.
Arquivos publicados:
- `prototypes/d1/monitor.py` — serviços de domínio sintéticos, rollback sequencial em memória, snapshot/renderer distinto da View SQL canônica.
- `prototypes/d1/test_monitor.py` — fluxo M2, integridade, idempotência, falhas injetadas e apresentação.
- `prototypes/d1/test_isolation.py` — isolamento e descarte em memória (S6).
- `prototypes/d1/test_s1_s5_adversarial.py` — seis casos negativos complementares S1–S5.
- `prototypes/d1/README.md` — registra **21 testes** e está defasado frente ao conjunto completo; atualização pendente, sem reescrever código ou resultado histórico neste checkpoint.

Histórico relatado durante as atividades técnicas: testes locais passaram de 13 para 18, 21, 26 e por fim **32/32 PASS**. Este checkpoint **não executou novamente os testes**. Portanto 32/32 é evidência histórica reportada das execuções locais, não certificação independente do HEAD atual.

## Matriz de aceitação provisória

| Critério | Evidência publicada | Pendência essencial T1 | Situação |
|---|---|---|---|
| S1 Identidades | referências de alvo/Monitor distintas, ciclo sequencial; testes negativos | revisar consistência e forma de IDs para o recorte sintético; mapear testes ao requisito | PARCIAL |
| S2 Proveniência | `synthetic:` obrigatório para fixture/sinal, ator fictício, disclosure | fortalecer coerência de proveniência e garantir que nenhum texto declare validação factual real | PARCIAL |
| S3 Registro | eventos em sequência, request idempotente, falhas injetadas | consolidar invariantes/adversariais, demonstração do replay por caso | PARCIAL |
| S4 Avaliação | impactos múltiplos, rationale, decisão explícita, conclusão imutável | consolidar transições/negações e integridade do alvo | PARCIAL |
| S5 Projeção | quatro estados, períodos/cutoffs fictícios, histórico, disclosure e não-equivalência SQL | **baseline sintético inicial ausente**; validar contra apresentação sem fabricar dados | PARCIAL |
| S6 Auditoria | replay, isolamento entre cenários/instâncias, descarte explícito | evidência final da reprodutibilidade/limpeza e limitação de concorrência | PARCIAL |

Critérios A–F de encerramento permanecem definidos no Documento 171: suíte documentada por HEAD, rastreabilidade S1–S6, rejeições atômicas, snapshot demonstrativo suficiente, limpeza isolada e documentação/hashes versionados. **Nenhum foi homologado integralmente por este checkpoint.**

## Sequência mínima de fechamento sugerida (não autoriza além de T1)

1. Definir e testar **baseline/cutoff exclusivamente fictício**, imutável e separado das janelas dos ciclos; manter explícito o alcance do contrato `oes.d1.monitor_snapshot/0.1`.
2. Atualizar o `prototypes/d1/README.md` com todos os testes e instruções; registrar matriz requisito → teste → evidência HEAD.
3. Executar localmente a suíte inteira no código definitivo, registrar comando e resultado, revisar riscos residuais e submeter **encerramento T1** à decisão expressa do proprietário.

Não exigir para encerrar T1 PostgreSQL, concorrência, API, nuvem, equivalência SQL canônica, revisão científica ou promoção de gates; esses itens são posteriores e dependem de atos próprios. O protótipo não é produção.

## Estado preservado e retomada
36 migrations UNREVIEWED; 0 pós-condições aprovadas; 36 controles 034–036 NOT_COLLECTED; 12 controles de papéis pendentes; BRG-03/06/07/08 BLOCKED, BRG-04/05 históricos, BRG-09 parcial; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado; Fase 4 NOT_READY e Fase 5 NOT_STARTED. Artefato S5 histórico não preservado/inspecionado nesta trilha, expiração anteriormente indicada para 2026-11-06.

**Próxima atividade, somente após novo `Prossiga`:** implementar/testar baseline sintético de Monitor em T1, sem dados factuais, e publicar alterações verificadas no GitHub. STOP.
