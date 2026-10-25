# Documento 289 — Encerramento técnico restrito do refinamento editorial Django

**Data:** 2026-10-25  
**Escopo:** demonstrador documental sintético em `applications/oes_web`, sem integração factual e sem homologação científica.  
**Decisão:** `CLOSED_TECHNICAL_RESTRICTED_DOCUMENTARY_DEMONSTRATOR`.

## Evidências verificadas

- Alteração editorial autorizada `DJANGO_MINIMAL_DOCUMENTARY_PRESENTATION_REFINEMENT`, commit `359a8d3cd5f8883db4fd8d4f8cba766f462ea81f`. Únicos arquivos modificados: `evidence/templates/evidence/signal_catalog.html`, `signal_detail.html`, `evidence/static/evidence/styles.css`.
- A CI executou a revisão `2c7df6d0538cf0be06a44e10b49e4d9dc3a72af5` da branch `main`, que inclui esse refinamento.
- GitHub Actions [40196984551](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40196984551), Django vertical slice: **50/50 testes PASS**, 0 falhas, 0 erros; configuração Django aprovada.
- GitHub Actions [40197070277](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40197070277), Chromium: **9/9 páginas×dimensões PASS** (catálogo, identidade conhecida, identidade não reconciliada × desktop/tablet/mobile), `BROWSER_VALIDATION_STATUS=PASS`. Navegação por teclado e verificações automáticas de layout, CSS e fontes PASS.
- Artefato de navegador `oes-django-real-browser-evidence`, id `12600072410`, confirmado no run, retenção limitada; **capturas individuais não foram inspecionadas visualmente** nesta avaliação.

## Suficiência funcional restrita

O demonstrador permite localizar um identificador, distinguir identidade documentada da não reconciliada, identificar estudo e relatórios sem dupla contagem, acessar referências dos Docs. 247/248/products/154 e reconhecer proveniência, limites e ausência de nova avaliação científica. Casos: `NCT01438697` (Ritterband 2017 / Shaffer 2020 relacionados a um estudo documentado) e `NCT07836491` (não encontrado no inventário delimitado, sem inferência científica).

O encerramento restringe-se à entrega de apresentação funcional documental e aos controles comprovados acima.

## Excluído do encerramento

- **Piloto OES integrado permanece aberto**; nenhuma homologação científica por pesquisadores externos, avaliação de utilidade, validação factual, revisão clínica independente ou prontidão de produção foi demonstrada.
- PostgreSQL conectado, TLS/aplicação final, autenticação, limpeza e INSERT/readback real continuam não comprovados ou não autorizados. Evidência E6 offline de 99/99 PASS não altera essa fronteira.
- Factual GET, captura automatizada, API pública de dados brutos, alterações Neon/ACL/roles/credenciais, workflows bloqueados e serviços pagos continuam proibidos sem autorização específica.
- Documentos 287/288 preservados: autenticação independente diferida do piloto e revisão obrigatória de requisitos na definição da stack completa.

## Próxima prioridade

Preparar roteiro curto para demonstração e avaliação por pesquisadores dos dois casos já documentados; identificar lacunas críticas antes de qualquer nova infraestrutura. Não gerar novos fatos científicos, nem iniciar automaticamente divulgação externa.

## Contexto

Checkpoint atual CP285. Este documento é uma decisão de encerramento **restrito da entrega editorial Django**, sem promover a fase 4 a readiness, sem iniciar Fase 5 e sem encerrar o piloto integrado.
