# Documento 299 — M2-A1–A6: integração documental mínima e limites de prontidão

**Data:** 2026-10-25. **Base:** CP293, documentos 294, 297 e 298.
**Natureza:** parecer de suficiência técnica restrita do percurso histórico Q → I → P, não encerramento do Marco B.

## Diagnóstico de macroatividades (M2-A1–A2)
Demonstrador sintético P1/P2/P3 encerrado restritamente no Documento 294; F1 consulta documental N2 encerrada internamente (Documento 297); F2 preparação Q0–Q2 e roteamento encerrada documentalmente (Documento 298). E9, captura factual e prontidão operacional permanecem bloqueadas/não homologadas. Stack e autenticação dependem de revisão futura; pesquisadores associados seguem indisponíveis.

## Auditoria de vínculos e especificação (M2-A3–A5)
O arquivo `database/f3-real-case-01-dcbti.sql` registra Question `OES-Q-2026-000401`, Investigation `OES-I-2026-000401` e Product `OES-P-2026-000401`. `investigation.investigation_question` associa versões Q–I; `product.investigation_link` associa versões I–P. São vínculos explícitos do caso histórico, não inferências por IDs parecidos. A Ficha N2 usa EvidenceSheetView e renderizador já existentes.

MI-01, MI-02, MI-03, MI-04: evidência documental positiva. MI-05 proveniência e MI-06 assurance A2: presentes estruturalmente/historicamente; não reavaliados cientificamente. MI-07 sem abertura E9 na auditoria. MI-08–MI-10 eram pendentes de regressão específica.

## Validação M2-A6
A suíte `tests/test_m2_a6_historical_links.py` e o workflow `.github/workflows/oes-m2-a6-link-checks.yml` foram publicados nos commits `b7fdb4fd2ff2756a0315ec4fbf191c794fb7f97e` e `c478fdc5aa9e3f15c453703de34296b43471d637`.
Run GitHub Actions **40237401239** no SHA `c478fdc5aa9e3f15c453703de34296b43471d637`: **completed/success**. Cobertura específica: MI-08 ID divergente, MI-09 vínculo ausente, MI-10 cálculo determinístico do digest do manifesto de IDs/versões. Esse digest **não é prova de integridade do conteúdo científico inteiro**. Testes de mutação usam strings em memória, não transações ou SQL conectado.

## Parecer de decisão
**GO técnico-documental restrito** para verificação offline da cadeia Q → I → P do caso histórico. Não há justificativa atual para novo schema de identidade, nova interface Django ou integração conectada apenas para repetir a prova. Não se declara todas as integrações funcionais ou readiness do Marco B aprovados. MI-01–MI-07 permanecem sustentados pelos alcances documentais expressos; MI-08–MI-10 pelos testes específicos, sem generalização irrestrita.

## Fronteiras e próximos passos
E9 **NO-GO**; sem abertura automática, busca factual, SQL/Neon conectado, alteração de grants/credenciais, publicação externa, implantação ou serviços pagos. A3 não foi realizado; proprietário não substitui revisor especializado. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`. Marco B continua aberto.
Próxima atividade proposta: **examinar critérios explícitos de encerramento do Marco B** e distinguir o que é realizável sem pesquisadores de dependências científicas/operacionais inevitáveis; inicialmente apenas parecer read-only.
