# Documento 249 — Primeiro vertical slice e decisão arquitetural preliminar (pós-CP265)

**OES | 2026-10-23 | OWNER_APPROVED_STACK_RECOMMENDATION / DOCUMENTARY_ONLY / IMPLEMENTATION_NOT_STARTED**

## 1. Origem e autoridade

Após o Documento 248 (D2-CTGOV-E4 concluído), a retomada confirmou CP265 no ponteiro e HEAD `475f694d8b79dc1adece8aae0fa7d4ec9eaeaad8`. Em conversa, o proprietário autorizou A1 (delimitação funcional) e A2 (comparação de stacks), e afirmou **“Modo médio. Recomendação aprovada. Prossiga.”** Esta decisão aprova **a orientação arquitetural preliminar recomendada**, e autoriza sua formalização documental. Não autoriza desenvolvimento, CI, migrations, SQL, Neon, implantação, coleta de fontes, gasto ou início da Fase 5. Freshness Gate antes da escrita: HEAD confirmado igual à base citada.

## 2. A1 — Vertical slice candidato

**Objetivo:** demonstração web local, reproduzível, de um sinal de evidência documentado com rastreabilidade científica e indicação explícita de limites e de avaliação humana pendente. Fluxo: abrir sinal de fixture → apresentar fonte/identificadores → mostrar relação Study/Report conhecida e proveniência disponível → distinguir dado conhecido de identidade não reconciliada → exibir pendência de julgamento humano **sem executá-lo ou persistir decisão científica**.

**Caso de referência candidato:** `NCT01438697`, Ritterband 2017/Shaffer 2020, relatórios relacionados ao mesmo Study (Doc. 248); uma segunda fixture pode demonstrar identificador ainda não reconciliado. Nenhum outro vínculo, elegibilidade ou metadado clínico será inventado.

**Dentro do recorte:** uma página de leitura, fixtures locais explícitas, serviço de aplicação pequeno, identidade Study/Report separada, origem e incertezas visíveis, testes mínimos funcionais. **Fora:** banco remoto/durável, autenticação real, revisão científica, workflow de adjudicação, agendamento M3, consulta PubMed/ClinicalTrials, API pública, integração CI conectada, deploy, serviços pagos e gestão editorial completa.

**Critérios de aceitação propostos, não gate normativo:** aplicação local acessível em navegador; fixture controlada exibida; Study e Reports não duplicados indevidamente; provenance exibida com lacunas; NCT indeterminado preservado como indeterminado; nenhuma alteração científica nem acesso externo ou ao banco; execução local reproduzível.

## 3. A2 — Comparação proporcional e decisão aprovada

Comparadas quatro opções: Django com templates HTML, FastAPI com Jinja2, Streamlit e Next.js com backend Python. Django apresenta melhor equilíbrio inicial para interface tradicional, maturidade, organização modular, capacidade futura de autenticação/administração e afinidade com o Python já utilizado em `prototypes/d1/`, `prototypes/d1_t2/a1/` e `prototypes/d2_e2/`. FastAPI permanece alternativa técnica válida; Streamlit é preferível a dashboards exploratórios; Next.js com serviço separado introduziria complexidade não justificada neste primeiro percurso.

**Decisão aprovada:** **Django 5.2 LTS como framework candidato preferencial**, Python 3.12 como referência inicial, templates Django + HTML/CSS, aplicação monolítica modular, serviço de aplicação independente da interface e adaptador inicial para fixtures locais. Congelamento exato de versões e dependências fica para eventual implementação autorizada, após conferência de compatibilidade/suporte. A aprovação é arquitetural e preliminar, **não aceitação de stack de produção**.

**Estrutura lógica mínima:**

`Django/templates → serviço de aplicação → domínio OES independente → adaptador de leitura (fixtures)`

Django deve fornecer infraestrutura web, não definir critérios de elegibilidade, assurance, GRADE, RoB, currentness, ProductVersion nem regras de identidade/provenance do domínio. Nenhum novo framework customizado de eventos, repositórios, transações ou orquestração é necessário neste recorte.

## 4. Evolução e dependências

O desenho metodológico canônico mantém identidade `Study ≠ Report`, aliases externos NCT/PMID/DOI, proveniência e versionamento conforme Docs. arquitetura 20, 28 e 29. PostgreSQL é candidato histórico ao núcleo relacional (Doc. 24), sem obrigação de uso neste incremento. As **36 migrations `UNREVIEWED` não serão executadas ou absorvidas automaticamente pelo ORM/migrations do Django**; qualquer integração exige avaliação separada dos gates pertinentes. Não alterar ou mesclar a branch preservada `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`.

Na evolução em nuvem, exigir análise específica de hospedagem, camada de persistência, segurança, custos, portabilidade e planos gratuitos efetivos, antes de operar infraestrutura. Simplicidade e capacidade de substituir adaptadores são preferenciais, mas não demonstram readiness operacional.

## 5. Limites científicos e operacionais vinculantes

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` com C1–C6 (Doc. 240); D1 `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, A2-G4 diferido/não aceito, A2-G5 não autorizado; D2 factual global `PARTIAL`; Fase 5 `NOT_STARTED`; prontidão operacional `NOT_READY`; M3 `BLOCKED`. Preservar N2 `OES-P-2026-000401` baseline 2026-10-04 A2 interno, GRADE, RoB, ProductVersion, currentness e assurance. BRG-03/06/07/08 bloqueados; BRG-09 parcial; SA-05/06/07/08/10 abertos/diferidos e 36 migrations `UNREVIEWED`. Evidência de recuperação técnica de PubMed e ClinicalTrials.gov não constitui avaliação científica independente ou cobertura exaustiva.

## 6. Próximo passo e STOP

**Próxima atividade possível, sob novo `Prossiga`:** propor um plano de implementação mínimo de Django/fixtures (arquivos, dependências, testes e gates de não-regressão) **sem começar a codificar por inferência**. Antes de qualquer implementação, solicitar autorização operacional apropriada, delimitando execução local, dependências e ausência de efeitos em rede/banco/CI. Não abrir a Fase 5 automaticamente.

Esta publicação formaliza A1/A2 e a aprovação da recomendação; **CP265 permanece vigente** segundo a política de checkpoints proporcionais. Não criar CP novo apenas em razão da numeração do documento.

**STOP — decisão preliminar registrada; nenhuma implementação autorizada por este ato.**
