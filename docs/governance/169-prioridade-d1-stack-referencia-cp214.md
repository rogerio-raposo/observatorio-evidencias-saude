# Governança 169 — Repriorização D1 e arquitetura de referência evolutiva (CP214)

**OES | 2026-10-21 | decisão estratégica de continuidade e diretriz de projeto | sem autorização operacional**

**Proveniência da decisão:** orientação expressa do proprietário na abertura da trilha D1 (D0 encerrada → D1 → D2 → governança operacional completa), seguida da avaliação crítica sobre excesso de lógica em SQL e da preferência expressa por **solução em nuvem e softwares gratuitos**. A continuidade D1-A2 foi autorizada por `Prossiga`. As tecnologias nominadas abaixo são **candidatas**, não escolhas definitivas homologadas pelo proprietário.

## 1. Relação com a decisão histórica

O Documento 165 (`docs/governance/165-decisao-prioridade-d0-d1-cp210.md`) preserva integralmente o alcance histórico de CP210: D0 prioritário, D1 exclusivamente documental, D2 diferido. O presente suplemento registra a **nova prioridade prospectiva**, após a conclusão editorial de D0; não reescreve nem atribui à decisão de CP210 permissões inexistentes. Documentos 166–168 e derivados editoriais aprovados continuam íntegros; D0 não será reaberto por padrão.

**Sequência de trabalho vigente:** (1) **D0 — concluído no escopo documental/editorial**, sem afirmar produção/publicação externa ou operação integrada; (2) **D1 — protótipo sintético funcional**, prioridade atual de trabalho; (3) **D2 — piloto factual**, futuro e condicionado a decisões/autorizações próprias; (4) **governança operacional completa**, fase de amadurecimento posterior, sem eliminação dos controles essenciais desde já.

A ativação da **prioridade de D1** permite análise, delimitação e preparação documental nesta atividade, mas **não constitui autorização genérica de execução**. Qualquer implementação técnica, instalação, Neon, SQL, execução local de código de protótipo, CI, consulta científica externa ou implantação exige delimitação e autorização compatíveis com o respectivo ato. Gate nenhum é promovido por esta diretriz.

## 2. Diagnóstico e correção arquitetural

OES-H1/OES-P1 da Fase 2 seguem como baseline arquitetural vigente; PostgreSQL foi validado para desenvolvimento/PoC, não homologado como stack final (Documento 38). O acervo SQL 021/022/027/029 contém funções e triggers para integridade e também coordenação de estados, justificando investigar **concentração excessiva de regras de negócio na persistência**. A concentração é indício de acoplamento e custo de evolução, **não prova causal de atrasos nem invalida os testes anteriores**.

**Princípio orientador prospectivo:**
- **Persistência:** identidade, chaves, FKs, unicidade, invariantes críticas, versionamento durável, atomicidade transacional e trilha persistente.
- **Aplicação/domínio:** orquestração de ciclos, casos de uso, transições de processo, avaliação/decisão explicitamente registrada, autorização contextual, integrações e composição de produtos.
- **Apresentação:** projeções verificáveis, templates, API/UI quando necessários; apresentação não determina decisões científicas.
- **Governança científica:** requisitos de método e revisão continuam externos à escolha da linguagem e do framework; o protótipo não cria parecer especializado.

A alocação concreta de cada regra herdada exigirá **inventário e testes de conformidade**. Evitar duplicação divergente de regras entre SQL e Python; não reescrever migrations integralmente, não abandonar OES-P1 nem suprimir invariantes sob pretexto de simplificação.

## 3. Preferências e candidaturas tecnológicas

**Critérios expressamente definidos pelo proprietário:** preferência por **execução/hospedagem na nuvem** e por **software gratuito**, sem contratação ou habilitação de serviços pagos. Onde houver alternativa tecnicamente equivalente, priorizar software livre/open source, componentes portáveis, plano gratuito verificável e independência de fornecedor. Nuvem não equivale a aprovação para implantar ou publicar; eventual custo, método de cobrança, cartão, limites de quotas, retenção e termos deverão ser verificados no momento da escolha. A disponibilidade futura de planos gratuitos **não é presumida**.

**Stack candidata para estudo de D1 (não homologada):**
1. **Backend:** Python; monólito modular, com serviços de domínio testáveis independentemente do framework.
2. **API:** FastAPI como candidato; Django ou alternativa enxuta poderão ser comparados em decisão técnica breve; **não há obrigação de API pública no D1**.
3. **Persistência:** PostgreSQL como opção preferencial pela evidência e contratos existentes; desacoplar acesso por interfaces/adaptadores, sem duplicar o modelo canônico.
4. **Apresentação:** reaproveitar templates/renderizadores atuais e saídas legíveis; interface web sofisticada não integra o mínimo.
5. **Implantação:** preferência por ambiente cloud gratuito ou gratuito sob quotas reais, com isolamento sintético, segurança e descarte verificáveis; a infraestrutura definitiva de produção permanece **não definida**. O sandbox Neon Free pré-existente é uma referência histórica autorizada no seu escopo, **não autorizado aqui para operação**.

**Não incluir por padrão no D1:** microsserviços, Kubernetes, serviços permanentemente ativos, filas gerenciadas, sistemas pagos, autenticação institucional completa ou migração geral de 36 scripts. Estes itens dependem de necessidade demonstrada e autorização.

## 4. Primeiro incremento D1 proposto

D1 deverá procurar produzir uma **fatia vertical funcional e reaproveitável** da arquitetura futura — em vez de apenas um simulador isolado que reproduz respostas conhecidas —, sempre com conteúdo **exclusivamente sintético**.

Fluxo candidato: identidade de produto sintético → Monitor M2 sintético → evento/candidato sintético → avaliação explícita e decisão registrada → projeção de histórico → apresentação fiel. Os critérios S1–S6 do Documento 164 permanecem critérios de demonstração; não constituem gates de produção nem aprovação de métodos científicos. Proibida a atualização silenciosa da conclusão científica.

**Fidelidade de execução obrigatoriamente declarada:** distinguir (a) serviços de aplicação efetivamente executados; (b) banco PostgreSQL efetivamente executado, se houver e se autorizado; (c) dados reproduzidos de fixtures/artefatos históricos; (d) comportamento simulado; e (e) integrações científicas não realizadas. Execução de serviços Python nunca será apresentada como validação das funções SQL originais.

**Persistência do primeiro incremento em aberto:** comparar adaptador simples local/descartável versus PostgreSQL isolado, inclusive possibilidade cloud gratuita, considerando custo operacional, fidelidade, dependências e reutilização. A decisão **não pode ser antecipada pela conveniência** antes da análise de dependências e limites técnicos.

## 5. Critérios objetivos para a seleção do caminho técnico

D1-A3 deverá examinar os contratos SQL 021–023, fixtures/testes e artefato histórico S5, além dos limites de hospedagem gratuita se a nuvem fizer parte da execução proposta, e recomendar uma opção usando: (1) aderência S1–S6; (2) reutilização de código; (3) preservação de invariantes OES-P1; (4) ausência de segunda fonte de verdade; (5) custo zero verificável; (6) isolamento, reprodutibilidade e limpeza; (7) menor número possível de componentes; (8) migração evolutiva para D2 sem expor dados sensíveis; (9) limitações de garantia declaradas.

Uma escolha tecnológica específica será registrada com rationale, alternativas rejeitadas, pontos reversíveis, requisitos mínimos de execução e autorização separada antes da implementação.

## 6. Estado operacional preservado

36 migrations permanecem **UNREVIEWED**, zero pós-condições aprovadas, 36 requisitos 034–036 **NOT_COLLECTED**, 12 controles de papéis pendentes; BRG-03/06/07/08 **BLOCKED**, BRG-04/05 históricos, BRG-09 parcial, B1R1 **EXPIRED_NOT_EXECUTED**, M3 bloqueado; Fase 4 **NOT_READY**, Fase 5 **NOT_STARTED** no sentido de promoção/execução institucional. Não houve nesta decisão SQL, Neon, CI, migração, fonte científica factual, implantação, contratação nem alteração de gate.

## 7. Próxima atividade delimitada

**D1-A3 (somente após novo `Prossiga`):** revisar documentalmente dependências técnicas do Monitor, fixtures, renderer e artefato S5, identificando o menor incremento funcional e a necessidade real de PostgreSQL no D1. Comparar alternativas de execução proporcional, preferindo nuvem/software gratuito quando possível, **sem executar, contratar ou provisionar nada**. Classificar decisões candidatas e pontos de autorização. STOP.
