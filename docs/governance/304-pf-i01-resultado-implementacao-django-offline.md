# Documento 304 — PF-I01: implementação restrita Django e validação offline

**Data:** 2026-10-25. **Autorização:** responsável autorizou expressamente PF-I01 após Documento 301. **Escopo:** consulta histórica N2 GET-only em Django, sem PostgreSQL, captura factual ou novo conhecimento científico.

## Entrega
- Snapshot histórico original fixado em `artifacts/pf-i01/rc01-evidence-sheet-view.json`; SHA-256 dos bytes originais `82a828e98b97dd5b6fe392135ed172d8c896f562e698353922b23cc419cc22d9`, conforme Docs. 302–303 e workflow de preservação 40242962374 success.
- `applications/oes_web/evidence/n2_historical.py` lê apenas o arquivo local, valida SHA-256, ID `OES-P-2026-000401`, Investigation `OES-I-2026-000401`, N2, assurance A2 e ausência de reviews A3; utiliza o renderizador e o mapa editorial N2 já existentes. Falha retorna HOLD sanitizado.
- `views.py`, `urls.py` e `templates/evidence/evidence_sheet_n2.html`: rota segregada `GET /evidence-sheets/OES-P-2026-000401/`; métodos mutantes negados; identificadores desconhecidos 404; resposta HOLD 503 sem conteúdo quando fonte falha; aviso A2 ≠ A3.
- `tests/test_pf_i01_n2.py`: cenários de consulta, ID desconhecido, métodos mutantes, ausência e adulteração de arquivo e regressão das três rotas antigas.
- Workflow `.github/workflows/oes-pf-i01-django-offline.yml`: CI isolada com Django check e suíte `evidence.tests` sem banco conectado.

## Evidência CI
GitHub Actions **40243303174** para HEAD `942a6f30a013a380c22af16db0d095268ef9b4c2`: **completed/success**. Job `test`, etapas `Django system check` e `PF-I01 and existing regression suite` ambas success. Totais de casos individuais não foram extraídos; não extrapolar para acessibilidade, teste humano ou segurança operacional.

## Parecer
PF-I01 **implementado e validado tecnicamente no escopo Django offline/GET-only**. Não é consulta pública operacional nem readiness. AC01/AC02/AC05/AC07–AC10 têm cobertura por implementação e/ou regressão; AC03 referente à validação completa de vínculos Q→I→P no caminho HTTP **não foi demonstrado integralmente** (o módulo confere IDs de produto e investigação e SHA-256, não recomputa vínculos SQL); AC04/AC06 dependem da exatidão editorial da projeção já revalidada historicamente. Não registrar aceite exaustivo AC01–AC10. A origem da ficha é fixa; nenhuma atualização factual e nenhuma aprovação A3.

## Próximo passo
Inspecionar o resultado de PF-I01 em nível de usuário e confrontar AC01–AC10 proporcionalmente antes de habilitar outros consumidores ou preparação com escrita. Reavaliar autenticação, gestão de segredos, deploy e persistência somente após novo gate explícito. Marco B aberto; E9 NO-GO; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
