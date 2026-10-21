# Documento 189 — D1-T2: proposta documental de persistência PostgreSQL sintética

**OES | 2026-10-21 | D1-T2/A0 | ESTUDO DOCUMENTAL — NÃO AUTORIZADO PARA EXECUÇÃO**

**Fundamento:** Documentos 165 (histórico), 169 (prioridades/arquitetura), 170 (sequência T1–T4), 171–172 (testes/prontidão T1), 173 (aprovação formal de encerramento técnico T1), CP218. HEAD de referência pré-documento: `739042937371618fb31a3e81ff919161588a4c87`. Identificador **189** escolhido para não reutilizar os números 174–188 já existentes em `docs/products`.

## 1. Decisão existente, alcance e exclusões

O proprietário aprovou `OES / D1-T1 / SYNTHETIC_LOCAL_TECHNICAL_CLOSURE` **somente** para T1 Python sintético local, com 36/36 testes locais PASS e rastreabilidade S1–S6. **Não aprovou T2**. O próximo trabalho é preparar uma proposta para deliberação; este documento não instala componentes, acessa uma instância, executa DDL/SQL, aciona Neon, CI ou cloud, implanta serviços, contrata plano pago, solicita credenciais ou altera gates.

Sequência: D0 documental encerrado → D1 prioritário (T1 encerrado restritamente, T2 a deliberar) → D2 factual condicionado → governança operacional completa. Fase 4 NOT_READY e Fase 5 NOT_STARTED.

## 2. Diagnóstico de viabilidade do código existente (limite de integração)

O T1 usa `InMemoryRepository` com mapas `scenarios`/`receipts`. `SyntheticMonitorService` lê e escreve esses mapas diretamente, inclusive na função `_idempotent`, criação, rollback, snapshots e replay. Portanto **não há, hoje, interface de repositório suficientemente abstraída** para substituir memória por PostgreSQL com segurança.

**Condição técnica T2-A0:** desenhar/extrair em Python uma interface de unidade de trabalho e transações, com métodos de leitura e persistência de cenário, recibo idempotente, evento e snapshot. Manter as regras de domínio, avaliações/decisões e a conclusão científica na aplicação; somente chaves, constraints, transações, consistência e auditoria persistente no banco. Uma mera tradução 1:1 das operações para stored procedures criaria o acoplamento que o Documento 169 pretende reduzir.

No projeto T2, a evolução deve ser incremental: contrato da interface + testes de conformidade em memória → adaptador PostgreSQL experimental isolado → testes positivos/adversariais de transação/concorrência → eventual prova em cloud, se autorizada separadamente. T1 permanece histórico e reproduzível; mudanças incompatíveis exigem nova versão de contrato e testes comparativos.

## 3. Alternativas comparadas, sem seleção definitiva de serviço

| Alternativa | Pontos favoráveis | Limites/riscos | Parecer |
|---|---|---|---|
| A. PostgreSQL local isolado, sem serviços gerenciados | Software livre, sem tarifa de licença, controle de testes destrutivos, isolamento reprodutível | Requer disponibilidade de servidor/container e esforço local; não demonstra rede/quotas cloud | **Candidato de referência para testes T2**, após autorização |
| B. Projeto Neon Free **exclusivamente sintético e separado** | Postgres gerenciado em nuvem; alinha-se à preferência por cloud, sem tarifa Free anunciada | Quotas e mudanças de termos, credenciais, rede, retenção, limpeza e isolamento; não reutilizar branch do OES canônico ou ambiente cuja ausência de dados factuais não foi comprovada | **Candidato cloud condicionado** a preflight e autorização específica |
| C. Somente SQLite ou dicionários | Baixo custo e testes rápidos | Não testa locking, constraints/transações e semântica concorrente PostgreSQL desejadas em T2 | Recurso auxiliar, **não substitui T2** |
| D. Postgres gerenciado pago ou hospedagem com upgrade automático | Potencial escalabilidade | Conflita com a autorização/custo e risco de cobrança | **Excluído** |

**Critério de preferência:** software livre e custo demonstravelmente zero, portabilidade PostgreSQL, risco mínimo ao repositório/infraestrutura atuais e separação entre T2 e T3. Para compatibilizar preferência de nuvem com risco mínimo, recomenda-se arquitetura **independente de provedor**: prova local primeiro, seguida de prova Neon Free apenas se a autorização a incluir expressamente. Nenhuma infraestrutura está selecionada ou contratada por esta proposta.

### Consulta pública de custo — apenas documental, 2026-10-21

- `https://neon.com/pricing` e `https://neon.com/docs/introduction/plans` (páginas públicas consultadas em 2026-10-21): plano Free anunciado a **US$ 0/mês, sem cartão**, até **100 projetos**, **100 CU-horas/projeto/mês**, **1 GB/projeto** (20 GB por conta), **10 branches/projeto**, **5 GB de tráfego público/projeto**; escala automática e `scale-to-zero` sujeitos ao plano. Esses limites **não equivalem a validação da conta OES** nem garantia futura; confirmar novamente e verificar custos no preflight antes de qualquer ação.
- `https://www.postgresql.org/about/licence/`: licença PostgreSQL permite uso sem tarifa de licença; isso **não elimina** custos operacionais locais ou de hospedagem.

**Regra financeira:** não cadastrar cartão, migrar plano, ativar cobrança, exceder quota deliberadamente nem adotar recursos pagos. Se custo zero não puder ser demonstrado, **parar**, registrar bloqueio e pedir nova decisão. Não assumir que a existência histórica de um sandbox Neon autoriza uso em T2.

## 4. Limite mínimo de dados e transação propostos

Somente **cenários sintéticos com nomes e atores explicitamente fictícios**. Não migrar ou ler as 36 migrations canônicas nem importar dados do schema científico OES-P1. Sem execução de busca PubMed/ClinicalTrials; não armazenar DOI, identificadores pessoais ou informações factuais obtidas de fontes reais.

Entidades de persistência em um **namespace dedicado T2**, a detalhar somente após aprovação: cenário e versões; baseline sintético; ciclos e janelas; sinais sintéticos; avaliações com impactos multivalorados; decisões; eventos ordenados e imutáveis; recibos idempotentes com fingerprint de payload. Evitar duas fontes de verdade: estado estruturado e log de eventos devem ser gravados na **mesma transação** e reconciliáveis por replay; não inferir dados reais do histórico T1.

**Invariantes de desenho**:
1. Escopo de cada escrita/consulta limitado ao `scenario_id`; target/Monitor não intercambiáveis; integridade de ciclo, sinal e avaliação com chaves e constraints.
2. Idempotência: unicidade `(scenario_id, request_id)`; mesma chave + mesmo payload retorna recibo determinístico; mesma chave + payload diferente rejeita sem efeito; concorrentes não produzem dois eventos.
3. Uma transação atômica por comando: gravar estado, evento e recibo juntos; em falha, rollback integral observável.
4. Corridas no mesmo cenário resolvidas por locking/controle explícito de versão; sequência do log monotônica, sem duplicatas nem fechamento contraditório.
5. Baseline sintético imutável; cutoff do ciclo temporalmente posterior; conclusão científica sintética original e hash invariáveis por decisões do Monitor.
6. Replay e projeção determinísticos, com distinção entre dados fictícios, execução Python e execução real do adaptador DB; disclosure deve refletir **o que foi realmente executado**.
7. Isolamento por projeto/base/schema e credencial de mínimo privilégio. Sem endpoint público de escrita; segredos apenas em ambiente/secret manager autorizado, nunca em Git, logs, artefatos ou conversa.
8. Retenção e descarte com verificação de ausência de linhas/objetos e de recursos órfãos. Não prometer eliminação imediata de backups/snapshots do provedor: declarar janela e limitações reais.

## 5. Matriz de aceitação futura (ainda SEM execução)

| Área | Teste de aceitação exigido após autorização |
|---|---|
| S1 | identidades consistentes, duplicatas e alvo inexistente rejeitados, vínculos estáveis |
| S2 | fixtures `synthetic:` obrigatórias, ausência de ingestão factual, disclosure e ator de cenário preservados |
| S3 | idempotência em reinício, duas requisições simultâneas idênticas e conflitantes, unicidade de sequência e rollback |
| S4 | múltiplos impactos, avaliação/decisão explícitas, conclusão preservada mesmo sob falha e corrida |
| S5 | snapshot persistente com baseline/cutoff e quatro estados; comparação com comportamento T1 por fixtures; sem equivalência à View SQL 021–023 |
| S6 | replay após reinício do processo, isolamento entre cenários, falhas injetadas, limpeza e ausência de integração externa não declarada |
| Custos/segurança | preflight Free, sem cartão/upgrade, nenhum segredo em logs/código, controle de privilégio e confirmação de recursos descartados |

Evidências futuras: comando/testes e versões de Postgres/driver, hashes/HEAD, transações e resultados de corrida, identificadores **não sensíveis** de ambiente, configuração de isolamento, contagem pré/pós-limpeza, estimativa/limites de custo. Nunca registrar connection strings ou senhas. Dados científicos canônicos e gates não são evidência T2.

## 6. Decisões pendentes para autorização

- D1-T2 pode incluir **código/driver e PostgreSQL local experimental**? Isso exige autorização nova; não está abrangido pelo encerramento T1.
- A prova no **Neon Free** será parte de uma subetapa autorizada expressamente ou permanecerá diferida? **Recomendação: diferir sua execução até preflight próprio**, deixando a interface pronta para cloud.
- Confirmar previamente se há runtime de PostgreSQL local sem custo e sem exigência de instalação ou privilégios elevados. Se não houver, rever a sequência e retornar ao proprietário antes de qualquer provisionamento.
- Definir versão experimental do contrato do adaptador e critérios de cancelamento/limpeza; exigir revalidação do status científico e dos gates antes de D2.

## 7. Texto de aprovação sugerido — **NÃO APROVADO / NÃO EXECUTAR**

`APPROVED — OES / D1-T2-A / POSTGRES_SYNTHETIC_LOCAL_ONLY / Autorizar apenas o desenho e a implementação/testes locais de adaptador PostgreSQL experimental, sobre dados integralmente sintéticos, com isolamento, atomicidade, idempotência, concorrência, replay, descarte e documentação de custo zero; sem Neon, serviços externos, CI remota, deploy, API pública, consultas factuais, migrações canônicas, alteração de gates ou serviços pagos.`

**Esse texto é proposta para decisão futura; não constitui aprovação implícita** e não deverá ser interpretado como executável por um simples `Prossiga` genérico. Uma futura aprovação do uso Neon Free exigirá escopo explícito distinto ou ampliação expressa desta autorização.

## 8. Continuidade

T1 continua **CLOSED_SYNTHETIC_LOCAL_ONLY**; T2 **DOCUMENTARY_PROPOSAL_ONLY / NOT_AUTHORIZED**. O checkpoint vigente permanece **CP218**. Sob novo `Prossiga`, preparar **o detalhamento do contrato de repositório T2-A0 e desenho dos testes transacionais**, ainda exclusivamente documental, ou apresentar a proposta de autorização para decisão do proprietário quando solicitada. Uma atividade delimitada por `Prossiga`; Freshness Gate antes de escrever; checkpoint após atividades suficientes ou decisão material. STOP.
