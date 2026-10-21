# Documento 192 — D1-T2/A1: autorização expressa e limites de execução (CP219)

**OES | 2026-10-21 | decisão do proprietário | T2-A1 APPROVED_SCOPED / NOT_STARTED**

## 1. Aprovação literal registrada

> APPROVED — OES / D1-T2-A1 / PYTHON_IN_MEMORY_REPOSITORY_BOUNDARY_ONLY / Autorizar exclusivamente a refatoração e os testes locais, em Python, da interface de repositório e Unit of Work com adaptador em memória, em diretório experimental separado, preservando o T1 e seus 36 testes, a semântica atual e as limitações científicas; permitir versionamento no GitHub com Freshness Gate; sem SQL, PostgreSQL, Neon, drivers de banco, CI remota, nuvem, implantação, API pública, consultas factuais, dados reais, serviços pagos, alteração de gates ou autorização de T2-A2.

A grafia `PYTHON\_IN\_MEMORY\_REPOSITORY\_BOUNDARY\_ONLY` recebida na mensagem é representação Markdown escapada do mesmo identificador `PYTHON_IN_MEMORY_REPOSITORY_BOUNDARY_ONLY`. Não altera o alcance da aprovação.

**Autoridade:** decisão expressa posterior ao Documento 191. Documentos 189 e 190 permanecem propostas arquiteturais, e o Documento 191 é o pedido histórico cuja autorização está agora concedida **apenas para T2-A1**. Nenhuma implementação foi iniciada na atividade documental CP219.

## 2. Escopo de implementação autorizado

- Desenvolver **somente Python local** para uma interface de repositório e Unit of Work com adaptador **em memória**; demonstrar limites atômicos de comandos, idempotência e rollback lógico em testes.
- Usar um diretório experimental distinto, preferencialmente `prototypes/d1_t2/a1/`; manter intactos `prototypes/d1/`, os arquivos e os **36 testes T1** da base aprovada no Documento 173.
- Preservar explicitamente semântica atual de `create_scenario` (repetição devolve snapshot corrente) e `record_assessment(pending)` (não admite segundo registro no mesmo sinal); **não corrigir implicitamente** comportamentos assinalados no Documento 190. Propostas de mudança permanecem para deliberação específica.
- Reusar regras sintéticas de domínio: cenário, proveniência, baseline/cutoff, identidades, ciclo, avaliações, conclusão científica e histórico; eventos/snapshot apenas demonstrativos.
- Executar testes locais, inclusive regressão integral T1 com resultado e HEAD rastreáveis. Publicar código, testes e documentação no GitHub com Freshness Gate, hashes verificados e checkpoints proporcionais.

**Esta autorização não concede T2-A2**. Qualquer implementação durável ou prova de transação entre processos necessitará de nova aprovação.

## 3. Exclusões absolutas

Sem SQL (inclusive consultas), PostgreSQL, Neon, drivers de banco, outros bancos, CI remota, serviços cloud, implantação, API pública, dados científicos/factuais/pessoais, integrações PubMed/ClinicalTrials, contratações, cartão, serviços pagos, migrations, schema OES-P1 ou alteração de gates. Não declarar maturidade científica, concorrência real, atomicidade de banco ou equivalência à View SQL canônica.

T1 permanece `CLOSED_SYNTHETIC_LOCAL_ONLY`; encerramento técnico T1 aprovado sob `SYNTHETIC_LOCAL_TECHNICAL_CLOSURE` não é reaberto.

## 4. Critérios para cada incremento T2-A1

1. Validar Freshness Gate e arquivos T1 antes de editar.
2. Implementar uma **atividade delimitada por `Prossiga`**, com relatórios de progresso e execução exclusivamente local.
3. Provar em testes estado+evento+recibo sob um commit lógico em memória e rollback em falha injetada; sem reivindicação de transação SQL.
4. Confrontar comportamento T2-A1 com T1 em cenários sintéticos e registrar divergências bloqueantes; não mascarar falhas.
5. Registrar quantitativos de testes, saída, versão do código, comando, integridade e ausência de uso de infraestrutura.
6. Parar se forem necessários banco, driver, serviço pago, dados reais, mudança de semântica ou gates; solicitar autorização nova em vez de ampliar automaticamente escopo.

## 5. Estado, prioridade e ponto de retomada

- D0 documental: encerrado; **D1 permanece prioridade atual**, T1 fechado restritamente, T2-A1 aprovado **mas não iniciado**; T2-A2 e T3 não autorizados. D2 factual e governança operacional completa posteriores.
- Bloqueios mantidos: 36 migrations `UNREVIEWED`, zero pós-condições aprovadas, 36 controles 034–036 `NOT_COLLECTED`, 12 controles de papéis pendentes; BRG-03/06/07/08 `BLOCKED`, BRG-04/05 históricos, BRG-09 parcial, B1R1 `EXPIRED_NOT_EXECUTED`, M3 bloqueado, Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`.
- **Próximo `Prossiga`:** primeira atividade de implementação T2-A1, limitada à criação da estrutura experimental e à interface Python Unit of Work em memória com testes locais iniciais, preservando o T1 integralmente. Freshness Gate inicial e pré-commit. Não avançar para T2-A2.

**STOP — aguardar novo `Prossiga`.**
