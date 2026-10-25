# OES — CP287 / Continuidade após formalização de P2-A3

**Data:** 2026-10-25 (America/Recife).  
**Anterior:** CP286, `archive/handoffs/oes/OES_Continuidade_2026-10-25_CP286.md`.  
**Base Git anterior:** `f8cfbfd040b5f9b1bd48001494db9fd929a88b32`.  
**Status:** checkpoint operacional imutável. Fonte normativa: documentos canônicos, em especial 287–292.

## Base consolidada
Fase 4 apenas metodológica/documentalmente encerrada (`CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`); prontidão `NOT_READY`; Fase 5 `NOT_STARTED`; piloto integrado aberto. Pesquisadores não vinculados; avaliação científica externa diferida, não dispensada. P1-A3 offline encerrado restritamente no Doc. 291, CI 40214460778 107/107 PASS; Django documental no Doc. 289, 50/50 testes e 9/9 Chromium históricos. Não há integração dinâmica por HTTP, SQL conectado ou validação científica.

## Novas decisões desde CP286
- **P2-A1** analisou proporcionalidade: Django atual com catálogo/duas páginas por fixture; P1-A3 fornece recibo independente offline; página dinâmica não justificada.
- **P2-A2:** proprietário aprovou expressamente **Alternativa B** em modo médio; uma apresentação estática sintética separada no Django, não execução P1-A3 na view.
- **P2-A3:** contrato mínimo e critérios P2-AC01–P2-AC08 formalizados no **Documento 292**; a aprovação é de **escopo**, sem autorização de implementar código.
- Preservar os Docs. 287–288 (diferimento da dupla autenticação inicial, nenhuma infraestrutura transitória desproporcional), 289–291 (fronteiras Django/P1/científica) e `signals.json` inalterada. Não inventar vínculo entre `observation_id`, `signal_id`, NCT ou PG.

## Ponto exato de retomada
**P2-A4 — preparar especificação mínima da página isolada (arquivos, rota proposta, exemplo determinístico, matriz de testes), ainda sem codificar**, para eventual aprovação específica de implementação. Antes de prosseguir: Freshness Gate na `main`, conferir ponteiro CP287, STATE, CHANGELOG e Documento 292. Uma instrução `Prossiga` autoriza uma atividade interna delimitada. Checkpoint após 3–5 atividades ou risco/decisão, Freshness Gate também antes de publicação. Fornecer atualizações de progresso.

## Limites
Sem GET factual adicional, alteração Neon/SQL/roles/grants/credenciais, payload bruto público, execução Django↔P1-A3 HTTP, mudança automática de fixtures/catálogo, ativação de workflows factuais, deploy, serviços pagos ou alegações científicas. P3 posterior: suficiência técnica, sem homologação humana. Não executar P2-A4 automaticamente ao concluir este checkpoint: **STOP** e aguardar `Prossiga`.
