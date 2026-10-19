# 108 — Decisão do proprietário: sandbox Neon Free sintético na região São Paulo

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 2026-10-19  
**Status:** **OWNER_APPROVED_SYNTHETIC_SANDBOX_SCOPE — ACCOUNT_ACTION_REQUIRED — NOT_PROVISIONED**  
**Referência:** Documento 107 / CP151 e controles ODB do Documento 105.  
**Evidência de autoridade:** aprovação textual explícita fornecida pelo proprietário nesta conversa em 19/10/2026; inspeção do horário atual em Recife registrada às 08:33:36, **não** atribuída retroativamente como horário exato da mensagem.

## 1. Autoridade expressa recebida

O proprietário apresentou exatamente:

> **APPROVED — Neon Free sandbox / Documento 107 / OES / synthetic-only / aws-sa-east-1 / no paid services**

A declaração corresponde integralmente à fórmula de autorização delimitada no Documento 107. Não precisa ser confirmada novamente para preparar ou configurar o sandbox nessas condições; nenhum outro consentimento é inferido.

**Escopo aprovado:**
- tentativa de cadastro/uso do serviço Neon no plano **Free**;
- criação de **um projeto experimental** identificado como `oes-sandbox`, ou nome técnico disponível equivalente;
- região fixada: `aws-sa-east-1` (São Paulo);
- apenas conectividade, configuração de acesso mínimo e testes **sintéticos não normativos**;
- **sem serviços pagos, upgrade, meio de pagamento, custos aprovados ou dados clínicos identificáveis**.

A aprovação **não** constitui execução authority de B1R1, aprovação de consulta PubMed/ClinicalTrials.gov, ativação de Epoch, nova Opportunity, registro de MeasurementEvent ou autorização de dados reais de pacientes. Preservar os cinco artefatos congelados, a janela temporal de B1R1 e os Documentos 85–93.

## 2. Estado de conexão e bloqueio operacional concreto

Na verificação em 19/10/2026, a integração **Neon** para ChatGPT aparecia como disponível para instalação/conexão, mas **não instalada**. Portanto, esta sessão não dispõe de um conector autenticado ao Neon para registrar conta ou criar instância. Nenhum recurso Neon foi provisionado pelo assistente. Uma sugestão de conexão foi apresentada anteriormente; sua aceitação depende de ação explícita do proprietário.

Não pedir, colar, persistir nem anexar: senhas, API keys, tokens, connection strings completas, hashes de segredo ou credenciais de administrador. O titular deve concluir autenticação e, se decidir conectar Neon ao ChatGPT, conceder somente permissões necessárias.

## 3. Procedimento autorizado de provisionamento pelo proprietário

**Ação necessária do titular, através da interface Neon:**
1. Visitar `https://console.neon.tech/` e autenticar-se/cadastrar-se em nome próprio, após leitura dos termos;
2. escolher **Free**, confirmando ausência de cobrança e de campo obrigatório de cartão; **STOP** se o fluxo exigir custo/upgrade;
3. escolher **Create project**;
4. nome candidato `oes-sandbox`;
5. região exata `AWS South America (São Paulo) — aws-sa-east-1`; não aceitar região padrão diferente;
6. selecionar PostgreSQL **18** se disponível no Free; se a opção estiver indisponível ou marcada preview não aceitável, registrar divergência e não improvisar;
7. utilizar database `oes_sandbox` se a interface permitir nomeá-la; do contrário, conservar `neondb` padrão para conexão mínima e declarar que o nome difere;
8. confirmar criação somente quando todos os campos exibidos corresponderem à aprovação;
9. abrir o projeto e conferir no painel **plano Free, região, nome, versão e database**;
10. preservar credenciais somente no gerenciador de segredos local e nunca no GitHub, logs ou conversa.

A localização `aws-sa-east-1` é suportada para PostgreSQL Neon, mas a documentação publicada informa **Object Storage Neon indisponível nessa região**. Não criar bucket ou alterar região silenciosamente para contornar essa restrição. A região é imutável para um projeto já criado; migração exige novo projeto.

Fontes primárias consultadas: https://neon.com/docs/introduction/regions ; https://neon.com/pricing ; https://neon.com/blog/neon-free-plan-1-gb-per-project ; https://neon.com/blog/postgres-18 .

## 4. Teste inicial de leitura — preparado, não executado

Arquivo aditivo versionado: `database/f4-neon-free-sandbox-connectivity-readonly.sql`.

Após o projeto existir, um operador autorizado pode abrir o **SQL Editor** do Neon, selecionar explicitamente o banco de teste e executar todo o script. O script:
- inicia **transação READ ONLY**, executa selects de relógio PostgreSQL, database, user, versão e flags de leitura e termina com **ROLLBACK**;
- não utiliza UUIDs de B1/B1R1, não executa migrations, não insere dados científicos nem faz source HTTP;
- **não** é preflight do B1R1 nem substitui a prova ODB-01–12;
- deve ser executado apenas no sandbox, jamais considerado evidência de conexão a base factual autorizada.

Ao relatar resultado, compartilhar somente: confirmação de execução, região/plano/nome sem segredo, PostgreSQL versão major, sucesso/erro e **horário observado do banco**; remover identificadores operacionais sensíveis conforme política. Não enviar URL de conexão que contenha senha.

## 5. Controles remanescentes

| Gate | Estado após owner approval |
|---|---|
| ODB-01 / Owner-region-plano | **APPROVED_SCOPE_ONLY**; conta/projeto ainda não verificados |
| ODB-02 / Instância persistente | **NOT_PROVISIONED** |
| ODB-03 / Segurança e segredos | **PENDING_CONFIGURATION** |
| ODB-04 / Dados | **SYNTHETIC_ONLY_APPROVED** |
| ODB-05 / Migration ledger e schema | **NOT_EXECUTED** |
| ODB-06 / Bootstrap sem retrofatos | **NOT_EXECUTED** |
| ODB-07 / Objects e hashes | **NOT_CONFIGURED** |
| ODB-08 / Backup independente e restore | **BLOCKED_NOT_CONFIGURED** |
| ODB-09 / Observabilidade | **NOT_CONFIGURED** |
| ODB-10 / Executor factual | **NOT_AUTHORIZED** |
| ODB-11 / Segregação CI | **DESIGN_ONLY** |
| ODB-12 / Smoke test operacional | **SCRIPT_PREPARED_NOT_EXECUTED** |

Aprovado apenas sandbox sintético. **OPERATIONAL_DB_READINESS = NOT_READY**. Não provisionar recursos pagos ou realizar trabalho factual científico por implicação da presente decisão.

## 6. Próxima ação e STOP

Aguardar ação do proprietário na console Neon ou conexão explícita do plugin Neon. Após evidência de cadastro/projeto criado, em modo médio e com novo `Prossiga`, fazer Freshness Gate e teste read-only controlado, registrar resultado sem segredo e checkpoint. Se não houver conexão ou ação do titular, não afirmar que houve provisionamento.

Backup externo continua pré-condição para qualquer futura persistência factual. Não alterar programa B1R1 nem declarar expiração enquanto a condição de tempo não for comprovada.

**Fim do Documento 108**

