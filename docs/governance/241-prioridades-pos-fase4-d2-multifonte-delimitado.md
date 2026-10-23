# Documento 241 — Prioridades proporcionais após o encerramento documental da Fase 4

**OES | 2026-10-23 | AFTER_CP261 | PRIORITY_PROPOSAL_ONLY / NO_EXECUTION_AUTHORITY / PHASE_5_NOT_STARTED**

## 1. Mandato e fonte canônica

O proprietário aprovou o encerramento **metodológico/documental** da Fase 4 (Doc. [240](240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md), gate `PASS_DOCUMENTARY_ONLY` com condições C1–C6), e, depois, determinou `Prossiga`. Este ato executa exclusivamente a próxima atividade do handoff **CP261**: **comparar e recomendar prioridades pós-Fase 4**. Não significa autorização para uma consulta factual nova, iniciar a Fase 5, alterar o produto, código, Neon/SQL/CI, infraestrutura, assinatura ou serviços pagos.

**Referências:** [Doc. 229](229-d2-p0-prioridade-e-viabilidade-piloto-cp254.md) para pergunta/PICO e fontes, [Doc. 230](230-d2-e1-recuperacao-factual-parcial-cp255.md) para consulta inicial incompleta, [Doc. 231](231-d2-e2-cliente-ncbi-e-prova-conectada-cp256.md) para prova NCBI, [Doc. 236](236-d2-e3-encerramento-restrito-rastreabilidade-shaffer-cp259.md) para triagem de Shaffer, [Doc. 138](138-runbook-manual-assistido-matriz-aceitacao-piloto-empirico-f4.md) para o piloto histórico persistente B1R1 **expirado**, [Doc. 227](227-d1-reescopo-aprovado-persistencia-diferida-cp252.md) para evitar engenharia prematura, [Doc. 169](169-prioridade-d1-stack-referencia-cp214.md) para preferência do proprietário por nuvem e software gratuito, e [Doc. 240](240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md) para guardas da Fase 4 concluída.

**Distinção essencial:** o D2 da iniciativa científica factual (Docs. 229–236) **não** é a “operação autoritativa D2” das camadas históricas de proporcionalidade do Documento 135. **D2 factual global continua parcial**, e nenhum desses nomes autoriza M3.

## 2. Três opções principais

| Opção | Entrega incremental verificável | Reutilização e dependências | Custo/risco e autorização | Prioridade recomendada |
|---|---|---|---|---|
| **A — D2 factual multifonte mínimo (ClinicalTrials.gov em leitura)** | Consulta pública delimitada pelo PICO N2, registros NCT rastreáveis e comparação dirigida com estudos/publicações já inventariados; relatório de identidades `known/new_to_inventory/related/indeterminate`, sem afirmar cobertura sistemática | Reaproveitar protocolo N2, Doc. 49, IDs conhecidos (Zhou/Nazem/OASIS etc.), cliente NCBI comprovado como *referência* para formato de prova. **Sem reabrir Shaffer ou repetir ESearch só para confirmar conectividade** | Menor esforço relativo e sem necessidade intrínseca de persistência Neon. Exige aprovação **expressa** de fonte, consulta literal, limite de registros, mecanismos de registro/proveniência, handling de falhas e eventual execução de código/CI. `READ_ONLY` não dispensa autorização para chamadas conectadas | **1 — recomendada** |
| **B — Seleção de stack e primeiro incremento de aplicação** | Definir um **vertical slice** limitado: representação de signal de fonte e proveniência, deduplicação de identidade e triage como proposta, sem decisão científica autoritativa; matriz de alternativas de stack e critérios de aceitação | Reaproveitar demonstrador D1 sintético e contratos da Fase 4; definir persistência real somente se necessária. Priorizar componentes maduros/frameworks já existentes, software livre e serviços de custo verificável | Esforço moderado; a escolha de stack em si pode ser documental, mas qualquer execução cloud/banco/SQL/CI exige gate próprio. Riscos SA-05/06/07/08/10 e BRGs aplicáveis antes de persistência | **2 — após incremento factual ou se este for deliberadamente diferido** |
| **C — Implementação integral da governança operacional** | Controles reais de acesso/segredos/TLS, auditoria independente, ledger/reconciliação, backup/restore e validação de execução persistente | Depende da stack, do fluxo efetivamente implementado e das ações de risco escolhidas; histórico de 36 migrations não implica migrar 36 | Alto esforço e risco de redundância se iniciado antes da escolha de implementação. **Os controles não estão dispensados:** devem ser demonstrados **antes** de qualquer ato futuro que os requeira | **3 — transversal por risco, não uma frente isolada antecipada** |

**Juízo:** opção **A** domina no próximo passo por ganho empírico discriminante e baixo acoplamento de infraestrutura. É uma **proposta de prioridade**, não autorização de executar.

## 3. Menor avanço concreto proposto: D2 — prova pública ClinicalTrials.gov

**Hipótese incremental:** uma única recuperação delimitada de registros ClinicalTrials.gov pertinentes a dCBT-I e insônia permite registrar e conciliar identidades de ensaios (NCT) com referências científicas do corpus N2, revelando o que é conhecido, potencialmente adicional ou indeterminado. Isto **não** determina se um RCT é elegível, se existe publicação nova ou se há mudança material do produto.

**Escopo candidato a autorização posterior:**
1. **Fonte:** API/site público oficial ClinicalTrials.gov, leitura única e delimitada, sem acesso a dados pessoais de pacientes, sem credenciais e sem sistemas pagos. Endpoints/parâmetros reais, versão da API e disponibilidades precisam ser confirmados **no ato autorizado**; não presumir URLs ou capacidade futura.
2. **Pergunta:** a mesma PICO N2 de adultos com insônia, dCBT-I autoguiada versus educação digital sobre sono/insônia; não estender a todos os tipos de tratamentos ou condições por conveniência. Identificadores NCT já conhecidos servem como **controles de identidade**, não como prova de recall.
3. **Oráculo mínimo:** consulta/filtros literais, horário UTC, identidade da fonte, contagem reportada quando disponível, página/cursor quando aplicável, lista efetivamente examinada **limitada inicialmente a 20 registros**, status de erro/cobertura, NCT/PMID/DOI ou links publicados quando disponíveis, razões de vínculo `same_trial/different_trial/uncertain`. Se resultado paginado ou volume maior, registrar **parcialidade**, não inferir ausência.
4. **Saída:** registro científico **não conclusivo** comparando `known_in_OES`, `linked_publication`, `new_to_checked_inventory`, `out_of_scope_provisional`, `unresolved` e falhas. IDs distintos não comprovam ensaios elegíveis inéditos; resultados/estimativas ficam intocados.
5. **Fronteira:** nenhuma revisão sistemática completa; nenhuma passagem autoritativa de triage a `invalid_signal` pela IA/owner, appraisal independente fictício, RCT adicional declarado sem prova, nova ProductVersion, mudança de GRADE/currentness/assurance, scheduler, M3, epoch B1R1, alteração na Ficha N2 ou registros factuais persistidos em Neon.
6. **Critério de parada:** fonte inacessível, falha de API, schema incerto, amostragem não auditável ou conjunto inconclusivo => documentar `PARTIAL/INDETERMINATE` e **STOP**, sem engenharia de contorno extensa. No máximo uma estratégia/correção razoável explicitamente delimitada em autorização própria; não repetir tentativas indefinidamente.

O uso de um script existente ou de novo código não está automaticamente autorizado por essa proposta. O artefato pode ser **relato documental** ou um pequeno JSON/CSV estritamente de registros públicos, conforme autorização posterior; preferir não adotar armazenamento operacional antes do estudo de stack.

**Ganho mensurável:** demonstrar ou refutar (no limite da consulta) capacidade de recuperar NCT de outra fonte e relacioná-lo ao corpus N2. Isso informa a modelagem mínima de `Study/Report/Source` no próximo vertical slice e evita construir integrações a partir de exemplos puramente sintéticos.

## 4. Outras rotas e pontos de reavaliação

- Se o proprietário priorizar imediatamente um aplicativo demonstrável por pesquisadores, pode escolher **B primeiro**, mediante decisão explícita da primeira saída visível/funcional. Não pressupor que NCBI + ClinicalTrials cubram a busca científica global.
- Se houver urgência por implantação factual persistente, **C não é opção de diferimento**: os controles **pertinentes** devem preceder a operação conforme C5 do gate F4 e BRGs aplicáveis; a arquitetura e custos devem ser concretizados, não apenas invocados.
- O histórico do piloto B1R1 em banco não será reativado: `EXPIRED_NOT_EXECUTED`; uma futura medição versionada em infraestrutura persistente exigiria novo epoch e aprovação. A **prova A de leitura de registros públicos** é outro experimento e não satisfaz automaticamente as exigências do piloto B1R1.
- A seleção de tecnologia deve ocorrer **quando o incremento funcional exigir**, aproveitando frameworks maduros para transações, pools, migrations, autenticação e interfaces. Segurança de negócio/assurance e idempotência devem continuar submetidas a testes próprios.

## 5. Proposta de decisão e próximos gates — NÃO APROVADA NESTE DOCUMENTO

**Decisão de prioridade proposta:** `PRIORITY_AFTER_F4 = D2_MULTISOURCE_BOUNDED_FACTUAL_READ_ONLY_FIRST / THEN_STACK_DECISION / OPERATIONAL_CONTROLS_AT_RISK_GATE`.

Uma manifestação específica do proprietário pode **selecionar a prioridade A** para preparar o desenho de consulta literal ClinicalTrials.gov. Essa seleção não deve ser confundida com autorização de executar consulta. A **primeira chamada conectada real**, o uso de código/CI, a guarda de artefato ou qualquer escrita persistente exigirão autorização operacional específica, com limites fechados.

**Proposta de autorização de prioridade (somente planejamento):**

```text
APPROVED — OES / POST-F4-PRIORITY / D2_MULTISOURCE_READ_ONLY_FIRST
Priorizar como próximo incremento a prova factual limitada de recuperação
e identidade de estudos via ClinicalTrials.gov, complementar ao NCBI,
usando o mesmo PICO N2 e os registros previamente conhecidos.
Autorizar somente a preparação proporcional dos parâmetros literais,
limite de resultados, oráculos de proveniência e critérios de parada.
Não autorizar ainda novas chamadas conectadas, código, CI,
Neon/SQL, serviço pago, alteração científica, ativação M3 ou Fase 5.
A operação futura exigirá aprovação separada e específica.
```

**Próximo `Prossiga` após essa aprovação:** produzir **somente o preflight mínimo de consulta ClinicalTrials.gov**, preferindo ferramentas existentes, com oráculo PASS/PARTIAL/STOP e pacote de autorização conectada. Caso não haja aprovação, escolher o caminho B/C ou ajustar o escopo mediante nova decisão.

**Status atual:** `POST_F4_PRIORITY_OPTIONS_ASSESSED / OWNER_PRIORITY_DECISION_PENDING / PHASE_4_DOCUMENTARY_CLOSED / PHASE_5_NOT_STARTED`. O CP261 continua vigente; nenhum gate operacional/científico foi alterado.

**STOP — uma comparação estratégica delimitada, sem execução de D2/stack/governança.**
