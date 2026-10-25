# Documento 293 — Encerramento técnico restrito de P2: apresentação sintética Django

**Data:** 2026-10-25.  
**Status:** `P2_CLOSED_TECHNICAL_RESTRICTED_SYNTHETIC_PRESENTATION`.  
**Natureza:** encerramento técnico restrito, não aceitação científica nem prontidão operacional.

## 1. Escopo e proveniência decisória
O Documento 290 priorizou P1→P2→P3 para piloto sem pesquisadores vinculados. O Documento 292 registrou a aprovação expressa da alternativa B: página Django estática, segregada, GET-only, exemplificando percurso E6→D1→referência documental, sem chamada dinâmica a P1-A3 e sem PostgreSQL. Implementação explicitamente autorizada pelo responsável para P2-A5. As provas técnicas não conferem autoridade científica.

## 2. Código incluído
- Fixture `applications/oes_web/evidence/fixtures/p2_synthetic_receipt.json` — exemplo ilustrativo identificado, nove campos sanitizados.
- `applications/oes_web/evidence/p2_presentation.py` — validação estrita de invariantes e estado HOLD sanitizado.
- `applications/oes_web/evidence/views.py` e `urls.py` — GET `/synthetic-path/`, POST rejeitado.
- `applications/oes_web/evidence/templates/evidence/synthetic_path.html` — limites e proveniências distintas.
- `applications/oes_web/evidence/tests/test_p2_presentation.py` — 16 casos definidos, incluídos na suíte.
- `applications/oes_web/scripts/validate_browser.py` — ampliado para quatro páginas × três viewports = 12 verificações previstas, mais navegação.

Referência de execução testada em `main`: **`3901787f9c6a8d177f236f30310624d4a993a402`**; primeiros commits P2-A5 `44a81b13b64aaafad55e309e5c4dab45a7a8410d`, correção `d751234722e69ae956131ce36fee39b487fd793b`, cobertura Chromium `3901787f9c6a8d177f236f30310624d4a993a402`.

## 3. Evidência factual de validação
- GitHub Actions [40217150462](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40217150462), `OES Django vertical slice - manual test`, `workflow_dispatch`, head SHA exato acima, estado `completed`, conclusão `success`. Job `django-read-only-tests`: configuração Django e etapa `python manage.py test evidence.tests --verbosity 2` concluídas com sucesso.
- GitHub Actions [40217256102](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40217256102), `OES Django real browser - manual validation`, `workflow_dispatch`, mesmo SHA, `completed/success`. Job `django-real-browser`: configuração, Chromium e upload de artefato com sucesso.
- Artefato `oes-django-real-browser-evidence` constatado como presente e não expirado à época da verificação. **Não** houve inspeção visual individual de screenshots nem extração dos totais internos dos logs/relatório; os 16 casos e as 12 verificações representam o escopo previsto pelo código, não contagens internamente auditadas. Não converter `success` em laudo de acessibilidade ou segurança.

## 4. Resultado delimitado e reservas
Declara-se **encerramento técnico restrito de P2** como apresentação sintética estática, respaldado por jobs GitHub `success` no SHA correto. Mantêm-se as fixtures documentais e as rotas preexistentes. Não comprova consulta factual, execução real HTTP de P1-A3, associação clínica independente, readback/persistência física PostgreSQL, identificação científica, elegibilidade, síntese crítica, GRADE, nem prontidão operacional.

A avaliação científica externa segue diferida até haver pesquisadores vinculados; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`. Não modificar Neon/roles/grants/credenciais, ativar workflows factuais, executar GET factual ou implantar. Documentos 287–292 preservados.

## 5. Próximo incremento
**P3-A1 — inventário de suficiência técnico-funcional e mapa de lacunas**, utilizando evidências já existentes, sem repetir testes automaticamente. Classificar comprovado / parcial / diferido / bloqueado, estabelecer critérios proporcionais e registrar os limites de ausência de pesquisadores. Não autorizar P3 implementação, novos serviços ou operação por força deste encerramento.
