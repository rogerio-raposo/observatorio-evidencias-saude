# Documento 252 — Análise integrada de prontidão e dependências sem pesquisadores

**OES | 2026-10-23 (America/Recife) | CP267 | READINESS_DEPENDENCIES_ANALYZED / RECOMMENDATIONS_ONLY / OWNER_DECISION_PENDING**

## 1. Mandato, base e limites

O proprietário autorizou expressamente, em **modo alto**, uma análise integrada da prontidão técnica e científico-metodológica **sem disponibilidade atual de pesquisadores**. A aprovação cobre diagnóstico, classificação de dependências e recomendação, não novos gates, implementação, CI, SQL/Neon, consulta factual conectada, homologação científica, contratação ou início de Fase 5.

Base verificada no Freshness Gate: `main` no commit `2fe4d369a7acd04725837ca971cb176d09620e26`, ponteiro CP267; `STATE.md` e handoff CP267. Fontes estruturantes: governança [04](04-governanca-garantia-revisao.md), [05](05-protocolo-transversal-atualizacao.md), [135](135-proporcionalidade-gates-e-priorizacao-fase4.md), [139](139-matriz-minima-prontidao-piloto-empirico-f4.md), [164](164-revisao-estrategica-simplificacao-cp209.md), [226](226-d1-t2-a2-reorientacao-proporcional-cp251.md), [227](227-d1-reescopo-aprovado-persistencia-diferida-cp252.md), [228](228-encerramento-demonstrador-sintetico-d1-cp253.md), [237](237-decisao-criterio-encerramento-metodologico-documental-fase4-cp260.md), [238](238-f4-c01-c06-matriz-evidencias-gate-documental.md), [240](240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md), [241](241-prioridades-pos-fase4-d2-multifonte-delimitado.md), [248](248-d2-ctgov-e4-conciliacao-documental-20-ncts.md), [249](249-decisao-arquitetural-preliminar-primeiro-vertical-slice-django.md), [251](251-c2-delimitacao-contrato-documental-study-report-proveniencia.md), e Docs. arquitetura 20, 28 e 29. O exame é **documental proporcional**, não auditoria linha a linha de todos os arquivos, reexecução dos testes ou verificação Neon ao vivo. Documentos antigos são snapshots; prevalecem decisões posteriores.

## 2. Parecer executivo

**É possível progredir tecnicamente sem pesquisadores.** Sua indisponibilidade não bloqueia inspeção do demonstrador, testes de integridade sintética, preparação de protocolos de avaliação, engenharia de leitura nem uma coleta factual não adjudicativa que venha a ser separadamente autorizada. Entretanto **bloqueia a atribuição de autoridade científica especializada inexistente**, quando exigida pela governança. A2 do proprietário não equivale a A3 independente; conforme Documento 04, N2 padrão pode admitir divulgação A2 com disclosure explícito, sem transformar o owner em especialista. N2 crítico/N3/N4 permanecem sujeitos aos requisitos correspondentes.

O demonstrador Django GET-only A1/B1/UX-02/C1/C2 alcançou **30/30 PASS automatizados** na [CI 40049293022](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40049293022) sobre `8e9aae482eb8581eaac2d474aa62dd012cc61790`; em CP267 foi consolidado no HEAD `2fe4d369a7acd04725837ca971cb176d09620e26`. O demonstrador **ainda não foi validado em navegador real**. Não opera em banco, não implementa P1–P6 de proveniência integral, não oferece revisão humana nem Monitor M3. C1 e C2 aqui referem-se aos *incrementos Django*, distintos das *condições C1–C6 do gate da Fase 4*.

A Fase 4 encerrou-se **somente no plano metodológico e documental**, Documento 240, com F4-C1–C6 vinculantes. `12/12` cenários documentados, `0/12` execuções integradas da matriz, `0` revisões científicas independentes. `readiness=NOT_READY`, `PHASE_5=NOT_STARTED`.

## 3. Matriz por tipo de ato, não por desejo abstrato de produção

| Uso ou ato pretendido | Pesquisador agora? | Pré-condição operacional aplicável | Classificação |
|---|---|---|---|
| Ler e demonstrar Django local GET-only com duas fixtures existentes | Não | Conferir apresentação no **Django real em navegador** para alegar validação visual; sem homologação científica | FACTIBLE_WITH_BOUNDED_TECHNICAL_CHECK |
| Adicionar testes de invariantes sintéticos sem dados novos | Não | Autorização de execução/código correspondente; escopo limitado e oráculos explícitos | CONDITIONAL_TECHNICAL |
| Preparar material para futura revisão humana | Não | Preservar status não revisado, evidência/versão e responsabilidades futuras; não inventar assinatura | FACTIBLE_DOCUMENTARY |
| Consulta pública factual read-only sem adjudicação | Não necessariamente | Fonte, parâmetros, volume e registro de proveniência aprovados; resultado não decide elegibilidade, novidade ou currentness | CONDITIONAL_EXPLICIT_AUTHORIZATION |
| Deduplicação ou classificação científica **autoritativa** de sinal, exclusão, materialidade clínica, ROBIS/RoB2/GRADE | **Sim, quando competência qualificada exigida** | Revisão humana real sob governança adequada; manter pendente sem profissionais | EXPERT_DEPENDENCY |
| Nova escrita durável, Neon/SQL, ledger e executor factual | Não para engenharia, mas exige controles técnicos | Segurança/least privilege/TLS, auditoria, ledger/recovery, backup/restore e custo relevantes demonstrados e aprovados **antes da escrita** | OPERATIONAL_BLOCKED |
| Atualização científica autoritativa, publicação fora dos gates ou M3 | Conforme produto e ato: competência especializada quando exigida | Autoridades científicas e operacionais aplicáveis; nenhum auto-update de versões/conclusões | BLOCKED |

A aprovação para leitura/sintético não transfere autoridade para execução externa. Nenhuma consulta científica foi executada por esta análise.

## 4. Mapa de impedimentos e dependências concretos

**R1 — Garantia científica (sem especialistas).** Fonte: governança 04, F4-gate 240 C1/C2/C4. O impedimento aplica-se aos **julgamentos formais** e à promoção não autorizada de produtos, não à engenharia ou preparação documental. Ações viáveis: manter estados inconclusivos, registrar lacunas e fornecer pacote de revisão futura. **Não há ação técnica que substitua uma revisão humana especializada**.

**R2 — Evidência funcional de navegador Django.** Fonte: CP267, STATE. Testes de rotas e templates não correspondem a uma interação verificada em navegador com aplicação real. Ação de menor custo: validar páginas `/` e `/signals/NCT01438697/`, `/signals/NCT07836491/`, fontes e avisos por execução controlada, registrar ambiente, revisão, observação/erros; nenhuma publicação ou coleta factual necessária. Inspeção em navegador continua `PENDING` até prova executada e registrada, sem inferir resultado.

**R3 — Persistência e segurança operacional.** Fonte: Docs. 135/139/227/240. Para um **piloto factual persistente**, BRG-03 (privilégios/TLS/segredos/auditoria), BRG-06 (ledger/migrations), BRG-07 (supervisor/fencing), BRG-08 (backup/restore), BRG-09 (custo/cotas) permanecem bloqueados/parciais conforme estado canônico; SA-05/06/07/08/10 abertos ou diferidos. **36 migrations UNREVIEWED**, pós-condições não aprovadas, evidências 034–036 não coletadas, controles de roles não satisfeitos. Não forçar revisão nem implantação **de todas as 36** para um protótipo sem banco; se houver futura persistência, selecionar primeiro caminho de esquema e cadeia transitiva adequada, sem supor que as 36 devam ser executadas ou que ORM resolva riscos de negócio.

**R4 — Recuperação factual e cobertura.** Fonte: Docs. 229, 240, 241, 248. D2 global permanece parcial; leitura NCBI pontual, identificação histórica Shaffer e crosswalk de **20 NCTs** limitado a IDs. Os 16 não localizados no corpus examinado **não são novos ensaios comprovados**; metadados completos não foram persistidos no retorno limitado. A coleta pode ser preparada/efetuada somente mediante autoridade própria, sem promover conhecimento científico.

**R5 — Monitor, temporalidade e produto.** Fonte: Docs. 05/135/240. `M3 BLOCKED`, cadence/thresholds/SLA normativos não calibrados; `Signal`, `Monitor`, `Alert` e ausência de hits não atualizam automaticamente `CurrencyState`, `ProductVersion`, certeza ou assurance. Produto N2 `OES-P-2026-000401`, baseline 2026-10-04, permanece A2 interno com limites conhecidos.

## 5. Dependências ordenadas — caminho mínimo

**Passo candidato 1 — Observação real do demonstrador existente (maior benefício/risco).** Teste visual e de navegação real Django, sem C3 nem infraestrutura nova. Requer autorização específica para execução e identificação de um meio de navegador; registrar resultados e limitações, não aceitar por analogia com CI.

**Passo candidato 2 — Decisão sobre finalidade imediata.** O proprietário escolhe **uma** entrega: (a) demonstração controlada a futuros pesquisadores; (b) recuperação documental factual restrita e inconclusiva; ou (c) primeiro piloto persistente. A escolha é necessária porque as dependências variam significativamente. Sem usuários/pesquisadores disponíveis, (a) pode ser preparado sem produzir julgamentos científicos; (b) exige finalidade clara e autorização de consulta; (c) exige pré-gates técnicos e não é proporcional por enquanto.

**Passo candidato 3 — Evidenciar apenas os gates aplicáveis ao caso escolhido.** Se (a), demonstrador e documentação de limites. Se (b), fontes/provenance/falhas e STOP sem adjudicação. Se (c), decisão de arquitetura e dados antes de requisitos concretos de BRG/ODB, autorização de owner/custos e provas operacionais; nenhum atalho a controles mandatórios antes do ato de risco. Produzir um único pacote de gate quando materialmente necessário, sem reabrir ciclicamente checklists históricos.

**Dependência transversal futura:** pesquisadores com competência apropriada para revisões, decisões científicas materiais e assurance quando as regras os exigirem. Nenhum prazo é inferido.

## 6. Recomendação e critério de parada

**Recomendação à decisão do proprietário, NÃO aprovada por este parecer:** `DJANGO_DEMONSTRATOR_STABLE / FUNCTIONAL_EXPANSION_DEFERRED / READINESS_DEPENDENCIES_PRIORITIZED`. Suspender novas funções Django até aparecer necessidade demonstrada; primeiro verificar a aplicação existente em navegador real. Não há razão proporcional para C3, A2-G4 artesanal, integração Neon ou reabertura da Fase 4 agora.

**Critério de parada documental:** o inventário atual é suficiente para esta decisão; estudos adicionais só se novo fato alterar prioridade, requisito de segurança aplicável, autoridade de julgamento ou ação concreta. Múltiplos documentos e novos checkpoints não são medida de progresso.

**Estados preservados:** CP267; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`; readiness `NOT_READY`; D1 reescopado fechado somente no demonstrador sintético/memória; D2 parcial; BRG/SA/migrations sem promoção. Branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` intocada. Nenhuma implementação, banco, consulta conectada ou CI executados nesta análise.

**STOP — avaliação integrada concluída, próxima escolha de prioridade pendente do proprietário.**
