# OES — Continuidade CP252

**2026-10-22 | APPROVED_D1_RESCOPE_DEFER_A2G4 | DOCUMENTARY_ONLY**

Checkpoint anterior CP251. Documento 227 `docs/governance/227-d1-reescopo-aprovado-persistencia-diferida-cp252.md`. O usuário **aprovou explicitamente** o reescopo proposto: preservar T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` e T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`, suspender T2-A2/A2-G4 como `DEFERRED_BY_APPROVED_RESCOPE / NOT_TECHNICALLY_ACCEPTED`, transferindo integração durável para decisão futura de stack. Isso não fecha D1 globalmente nem autoriza runtime, testes A2-G5, SQL, Neon, CI, driver, migrations, custos, API, deploy, dados factuais ou gates.

Ponto de partida canônico pré-publicação `main` `84f8f31e84c01273c854f130c6df5e8a039eb8ae`. Branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1` contém seis fontes A2; sem `a2/` em `main`. Não alterar branch. Riscos SA-05/06/07/08/10 permanecem abertos e **diferidos**, não resolvidos. SA-02 dependente, SA-03 parcial, SA-11/12 mitigadas apenas estaticamente. T1 36/T2-A1 75 PASS históricos; Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED; D2 factual diferido.

**Próximo `Prossiga`: D1-R1 — inventário conciso de entregas e lacunas do demonstrador sintético reescopado**, sem retomar A2-G4, reanalisar infraestrutura ou executar código. Uma atividade, STOP. Protocolos de continuidade, autorizações e Freshness Gate permanecem.

**STOP — CP252 documental.**
