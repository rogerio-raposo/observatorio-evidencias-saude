# Documento 237 — Decisão vinculante: critério determinante de encerramento da Fase 4

**OES | 2026-10-23 | CP260 | PHASE_4_DOCUMENTARY_METHODOLOGICAL_EXIT_CRITERION_APPROVED / PHASE_4_NOT_YET_CLOSED**

## 1. Decisão expressa do proprietário

Na conversa do OES, em 23/10/2026, após avaliação em macroatividades de alternativas de encerramento, o proprietário declarou:

> "Gostaria de formalizar o encerramento metodológico e documental como marco determinante do encerramento da fase 4."

**DECISÃO APROVADA:** A **Fase 4 — Protocolo de Atualização** tem como **marco determinante de encerramento** a **conclusão e aceitação metodológica e documental** do protocolo transversal de atualização, conforme critérios proporcionais, evidências rastreáveis e deliberação de gate final pelo proprietário. **Não** depende do funcionamento em produção, de migrações antigas integralmente revisadas, de cronograma real de monitoramento, de M3 formal, de um sistema multiusuário ou da implantação de infraestrutura persistente, desde que tais pendências não sejam ocultadas nem declaradas resolvidas.

Esta é **aprovação do CRITÉRIO DE SAÍDA**, não aprovação do resultado do gate nem encerramento retroativo da fase. **Estado atual: `PHASE_4_DOCUMENTARY_EXIT_CRITERION_APPROVED / PHASE_4_CLOSURE_PENDING`**, com prontidão operacional `NOT_READY`.

## 2. Objeto entregue e fronteira entre conclusão documental e execução

**Escopo a concluir na Fase 4:** desenho metodológico coerente, auditável, testável e rastreável para sinal → identificação/triagem/deduplicação → avaliação de materialidade/limitação de cobertura → decisão de atualização/currentness → versionamento e assurance quando autorizados → Monitor/Alert/propagação e rebaselining → suspensão, falha e retomada segura. Distinguir M0–M3, produtos científicos de observações/Alert, decisões humanas de análise assistida por IA, versão científica de edição textual.

A fase será **concluída metodológica e documentalmente**, e não **validada em operação**. Uma prova sintética ou verificação de coerência documental pode apoiar a aceitação; não é prova de operação autoritativa, não garante busca exaustiva, sensibilidade bibliográfica, qualidade científica, recuperação após falha real ou eficácia de controles de segurança.

**Fora do critério determinante desta fase, sem dispensa de obrigações quando aplicáveis futuramente:** seleção/integração da stack, SQL/PostgreSQL/Neon, migrations 001–036, RBAC e segregação operacional, auditoria independente, ledger/supervisor/fencing, backup/restore, implantação, CI operacional conectada, coletas recorrentes em PubMed/ClinicalTrials.gov, cadência/SLA normativos, ativação M3, publicação científica automática, revisão especializada de produtos específicos e abertura da Fase 5. Esses itens serão condicionantes de **seus próprios gates futuros** na implementação ou operação; não desaparecem porque a Fase 4 foi documentalmente encerrada.

## 3. Critérios verificáveis para solicitar o encerramento efetivo

Usar **prioritariamente evidências já existentes**: Docs. [05–09](05-protocolo-transversal-atualizacao.md), [135](135-proporcionalidade-gates-e-priorizacao-fase4.md), [136](136-inventario-suficiencia-cientifico-funcional-fase4.md), [137](137-cenarios-adversariais-aceitacao-cientifico-funcional-fase4.md), [138](138-runbook-manual-assistido-matriz-aceitacao-piloto-empirico-f4.md), demonstrador D1 [228](228-encerramento-demonstrador-sintetico-d1-cp253.md), piloto dirigido D2 [229–236](236-d2-e3-encerramento-restrito-rastreabilidade-shaffer-cp259.md) e governança [04](04-governanca-garantia-revisao.md).

| Critério | Evidência mínima exigida para o gate documental | Restrição/condição de FAIL ou REVISE |
|---|---|---|
| **F4-C01 — cobertura de contratos** | Matriz `SF-01–SF-14` com artefatos, invariantes, rastreabilidade, grau real de validação e lacunas relevantes; revisão única e proporcional das incoerências materiais | Contradição não resolvida em fluxo/autoridade; tratar especificação como validação executável |
| **F4-C02 — aceitação lógica integrada** | Percurso `R0–R8` confrontado documentalmente com **AT-01–AT-12** (entradas, ator autorizado, decisão esperada, ação proibida, oráculo, estado após falha); reexaminar especificamente ressalvas **AT-05, AT-09 e AT-12**; registrar PASS/REVISE/NOT_READY por cenário **no plano documental** | Apresentar `12/12` como execução end-to-end ou deixar ressalva material sem tratamento/limitação declarada |
| **F4-C03 — governança e garantia** | Mapa de competências/autoridades consistente com Doc. 04 e níveis `N0–N4/A0–A3`; separar IA, owner e revisor independente; demonstrar bloqueio de decisões/publicações que precisem de especialistas; explicitar ausência de revisão científica independente onde pertinente | Simular parecer independente, transformar A2 em A3 ou autorizar publicação/alteração científica por inferência |
| **F4-C04 — temporal/currentness e automação** | Justificar método de cadence/threshold/SLA e regras de decisão/currentness sem inventar valores normativos; registrar inadequação de dados reais e `M3 BLOCKED`; preservar fail-closed, eixos de Monitor/Alert e impossibilidade de mudar conclusão automaticamente | Fixar parâmetros sem base, promover `set_current` por ausência de hits ou deduzir autorização a partir de PASS técnico |
| **F4-C05 — riscos e obrigações diferidas** | Matriz mínima de obrigações por **gatilho futuro**: piloto factual persistente, execução conectada, alteração científica, publicação, M3, produção. Para cada uma, BRGs/SA/migrations aplicáveis, prova exigida, autoridade e status real; sem reconstruir documentação histórica sem novo fato | Omitir dívida material, afirmar risco resolvido ou diferir prova de segurança **para depois** de operação que a exige |
| **F4-C06 — decisão e divulgação de escopo** | Parecer integrado que identifique o que está **especificado**, **verificado documentalmente**, **demonstrado de modo sintético**, **observado pontualmente em dados reais**, **não validado cientificamente** e **não operacionalizado**; propor ao proprietário decisão final expressa e divulgar limitações | Usar encerramento da Fase 4 como selo de produto cientificamente validado, de sistema seguro ou de prontidão para Fase 5 |

O gate final deve decidir `PASS_DOCUMENTARY_ONLY`, `REVISE` ou `NOT_READY`, com razões verificáveis e eventuais condições. `PASS_DOCUMENTARY_ONLY` **só produz fechamento após autorização expressa específica de encerramento**, não por criação deste documento nem por mera contagem de artefatos.

**Importante:** não se exige que `AT-01–AT-12` sejam operacionalmente executados para obter o fechamento metodológico; exige-se que o percurso documental seja coerente e que a ausência de execução permaneça explícita. Tampouco é obrigatório provar restauração de Neon, SQL ou M3 antes de fechar a **fase documental**; essas provas continuarão obrigatórias antes das operações para as quais foram desenhadas.

## 4. Governança da revisão e ressalvas

O proprietário pode aprovar o **encerramento do trabalho metodológico/documental**, mas **não** deve ser representado como revisor metodológico independente caso não disponha da competência e independência requeridas. A ausência de validação científica independente deve constar do registro final. Onde houver produto N3/N4 formal ou uso de alta criticidade, gates de parecer especializado mantêm-se integralmente aplicáveis **no momento da publicação/uso correspondente**. Nada neste ato converte juízo de IA em parecer humano.

Os documentos 136–138 preservam valor como **snapshots históricos**: seus estados `NOT_READY` e `0/12_END_TO_END_EXECUTED` registram a situação no momento da redação. A presente decisão **substitui a interpretação anterior que tornaria a prontidão operacional condição necessária ao fechamento da Fase 4**, sem reclassificar automaticamente qualquer resultado de testes históricos ou apagá-los.

## 5. Relação com D0, D1, D2 e controle de risco

- **D0** documental já encerrado no escopo histórico próprio.
- **D1** demonstrador `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`, sem banco/produção; T2-A2/A2-G4 diferido/não tecnicamente aceito; A2-G5 e runtime não autorizados.
- **D2** piloto factual **parcial e limitado**: cliente NCBI E-utilities com prova conectada pontual e triagem Shaffer; D2-E3 `CLOSED_RESTRICTED_DOCUMENTARY_RECONCILIATION_ONLY`. **D2 como um todo não encerrado**, sem revisão independente ou mudança de Ficha N2.
- **36 migrations `UNREVIEWED`**, BRG-03/06/07/08 `BLOCKED`, BRG-09 evidência parcial, SA-05/06/07/08/10 abertos/diferidos, `M3 BLOCKED` e `Fase 5 NOT_STARTED`. Riscos continuam exigíveis por atividade quando reativada e não são “aceitos para produção”.

## 6. Próxima atividade exata e critério de parada

**Próximo `Prossiga`: construir a matriz de evidências `F4-C01–F4-C06`, usando os Docs. 136–138 como baseline, com verificação dos três pontos adversariais AT-05/09/12 e identificação exclusiva de lacunas documentais que possam impedir a decisão de fechamento.** Evitar novos ciclos longos de documentação, CI PostgreSQL ou repetição do piloto Shaffer. Preparar, após a matriz, minuta única para deliberação do **gate final documental**.

Nenhuma nova coleta factual, conexão/CI, alteração da Ficha, Neon/SQL, serviço pago, mudança de currentness ou início da Fase 5 é autorizado aqui.

**DECISÃO: CRITÉRIO DE ENCERRAMENTO METODOLÓGICO-DOCUMENTAL DA FASE 4 APROVADO; FASE 4 AINDA NÃO ENCERRADA.**

**STOP — decisão canônica formalizada.**
