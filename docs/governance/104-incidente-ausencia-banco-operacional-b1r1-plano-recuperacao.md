# 104 — Incidente de infraestrutura operacional B1R1 e requisitos de recuperação

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 19 de outubro de 2026  
**Modo:** alto — diagnóstico e governança de impedimento operacional  
**Status:** **OPERATIONAL_INFRASTRUCTURE_BLOCKER_RECORDED — LIVE_PREFLIGHT_NOT_EXECUTED — NO_ACTIVATION**  
**Referências:** CP147; Documentos 88, 90–93, 98, 101–103; migration 035  
**Instância experimental:** TOPI-N2-DCBTI-01 / Epoch B1R1

## 1. Fato comunicado e qualidade da evidência

Em 19/10/2026, ao tentar executar o live preflight de ativação, constatou-se que a sessão do assistente acessa a documentação e os resultados de CI no repositório GitHub, mas não possui conexão com uma instância PostgreSQL operacional persistente. Perguntado se existia instância persistente além do banco temporário de GitHub Actions, o usuário respondeu: **“Não existe”**.

**Natureza probatória:** ausência da instância declarada pelo usuário e falta de acesso operacional constatada nesta sessão. Não se trata de auditoria de todos os ambientes de nuvem nem prova independente de inexistência universal de bancos. O repositório/workflow `.github/workflows/validate-s5.yml` define um PostgreSQL de serviço por run de CI, usado em fixtures/rebuild; esse serviço não constitui datastore factual persistente.

O relógio factual de Recife foi consultado durante a investigação:
- 2026-10-19T08:00:32-03:00 — janela iniciada;
- 2026-10-19T08:07:32-03:00 — janela ainda aberta no instante da consulta.

Não há resultado de live preflight SQL em banco operacional a registrar, tampouco resultado PASS/FAIL dos checks individuais da instância factual. **Não fabricar output de preflight, tempo de ativação, Artifact factual ou contagens observadas no banco inexistente.**

## 2. Freshness Gate e histórico preservado

Na verificação do dia 19:
- branch `main`, HEAD inicial `d53640c76d69755f3c48ae0a39109c545f9b4bef`;
- ponteiro `archive/handoffs/oes/README.md`, `STATE.md`, `CHANGELOG.md` coerentes com CP147;
- nenhum commit posterior ao CP147 no início da análise;
- os cinco blobs de design/requests PubMed e ClinicalTrials.gov mantêm os hashes congelados registrados no Documento 101;
- a run 252 / `37939324857` de 09/10 concluiu `success` para **44/44 testes offline**, F4-ISE 24/24 e rebuild de CI;
- evidência de CI é **sintética/reconstruída** e não se transforma em estado factual de um PostgreSQL operacional.

CP147 e Documentos 101–103 continuam válidos no respectivo escopo técnico.

## 3. Impacto e classificação

**Categoria:** lacuna de infraestrutura entre validação e operação.  
**Severidade operacional:** **BLOCKER** de activation factual.  
**LIVE_PREFLIGHT_B1R1:** **NOT_EXECUTED** (não é FAIL; os checks físicos não foram observados).  
**B1R1_ACTIVATION_EXECUTION:** **NOT_PERFORMED**.  
**B1R1_ACTIVATION_DECISION:** **DO_NOT_ACTIVATE_WITHOUT_PERSISTENT_OPERATIONAL_DATABASE_AND_LIVE_PASS**.

A última reconstrução técnica conhecida reproduzia `B1=invalidated`, `B1R1=authorized_non_normative`, `started_at=NULL`, zero MeasurementEvent/OpportunityResolution. Esse estado é **resultado do ambiente de validação**, não readout factual atual de um ambiente persistente. Nenhuma mutation ou consulta científica real foi realizada nesta investigação.

A activation interval congelada permanece **[2026-10-19T08:00:00-03:00, 2026-10-19T09:00:00-03:00)**. No momento da verificação às 08:07:32, ainda não expirara; não declarar `EXPIRED_NOT_EXECUTED` antes das 09:00. Se o limite for atingido sem ativação válida, aplicar a contingência `EXPIRED_NOT_EXECUTED` do Documento 91 **após confirmação factual de tempo e ausência de ativação**. Não retroagir `started_at`, deslocar oportunidades nem apresentar prova simulada como factual.

## 4. Causa arquitetural e ações de contenção

O processo de prontidão anterior qualificou scripts, guards, fluxos de evidência, contratos congelados e ensaios sintéticos, mas **não incluiu como gate eliminatório a existência e acessibilidade de um datastore PostgreSQL operacional persistente, com migrações implantadas e ciclo de vida verificável**. A falha é de prontidão de implantação, não de parsing da API.

Até novo gate arquitetural:
1. **Não executar** SQL de activation, consulta target-specific, criação de MeasurementEvent, Resolution ou `Search` factual.
2. Preservar B1, B1R1 e respectivos horários congelados no código/documentação, sem reescrita retroativa.
3. Preservar os logs da CI como evidência exclusivamente sintética.
4. Distinguir **estado pretendido/reconstruído em testes** de **estado efetivamente persistido**.
5. Qualquer nova consulta a PubMed/ClinicalTrials.gov requer authority e Opportunity temporal válida em experimento formalmente autorizado.

## 5. Frente de recuperação — infraestrutura PostgreSQL persistente

**Status: REQUIRES_DESIGN_AND_OWNER_DECISION; implantação não autorizada por este documento.**

Uma proposta de solução deverá conter, antes de qualquer deployment:
- definição explícita de ambiente de produção experimental/de desenvolvimento operacional, propriedade, provedor/região, custo e continuidade;
- PostgreSQL com armazenamento persistente, endpoint privado, identidade de serviço, privilégios mínimos, credenciais gerenciadas, TLS e auditoria;
- versionamento/migration ordenada e idempotente, sem usar a CI efêmera como fonte factual de dados;
- segregação inequívoca entre `CI/synthetic` e `operational/factual`, incluindo operadores, arquivos de evidência e connections;
- política de backup automático, retenção, restauração ensaiada, disponibilidade e relógio de referência;
- armazenamento durável dos Artifacts factuais e sua cadeia de provenance, com integridade e controle de acesso;
- classificação de dados, retenção, requisitos de segurança/privacidade aplicáveis e plano de incidente;
- prova read-only de schema/guards, authority, frozen records e 14 Opportunities corretas em **instância real**;
- `maintenance.temporal_activation_preflight` e `..._state` executados no banco operacional no instante apropriado, com captura integral, hashes/logs e critérios de aceitação.

**Importante:** reexecutar fixtures e materializações em ambiente novo pode reproduzir dados de teste, mas não equivale a um histórico factual anterior. O bootstrap do datastore deverá ser claramente declarado como implantação inicial, sujeito a autorização própria; nenhum `started_at` ou MeasurementEvent real pode ser inventado.

## 6. Desenho de novo experimento após perda da janela

Se B1R1 não for ativado validamente antes de 09:00 de 19/10:
- registrar expiração apenas após confirmação temporal;
- abrir decisão de governança para **novo Epoch/versão experimental e novo schedule**, sem reutilizar de forma retroativa o B1R1 congelado;
- preservar B1 e B1R1 e suas evidências, inclusive o motivo da não execução;
- revalidar queries/interfaces, fontes, authority, instante de congelamento, preflight e prova de persistência;
- submeter a escolha do novo desenho e horários à aprovação explícita, em modo alto, antes de criar ou persistir estado.

**Este documento não aprova novo Epoch, novo provedor de banco, budget, nova authority nem migration.**

## 7. Próximo checkpoint e ação autorizável

Abrir gate arquitetural de **Persistent Operational Database Readiness**, em modo alto, somente após `Prossiga`, com decisão explícita sobre infraestrutura e plano de implementação. Subsequentemente, modo médio para implantação controlada, testes de backup/restore e validação de conectividade, voltando ao modo alto para decisão sobre novo experimento.

Até lá: **F4_OPERATIONAL_INFRASTRUCTURE = BLOCKED**; **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**; **B1R1_ACTIVATION = NOT_PERFORMED**; **PHASE_5 = NOT_STARTED**.

**Fim do Documento 104**

