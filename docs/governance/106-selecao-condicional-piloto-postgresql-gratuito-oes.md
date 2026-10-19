# 106 — Seleção condicional de solução PostgreSQL gratuita para o piloto operacional OES

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data da avaliação:** 19/10/2026  
**Modo:** alto  
**Status:** **FREE_FIRST_ARCHITECTURAL_CANDIDATE_SELECTED_WITH_CONDITIONS — OWNER_PROVISIONING_APPROVAL_PENDING — NOT_OPERATIONAL_READY**  
**Origem:** preferência expressa do proprietário por serviço gratuito, sujeita aos critérios ODB-01–ODB-12 estabelecidos no Documento 105/CP149.  
**Natureza:** recomendação de arquitetura de piloto *não normativo*, sem assinatura, criação de recursos, consentimento financeiro ou autorização de novo experimento.

## 1. Freshness Gate e decisão delimitada

No início desta avaliação: GitHub `main` HEAD `077e329bf1f1aa20857ce74f2a71e70ab8cf3fba`; `archive/handoffs/oes/README.md` aponta CP149; STATE, CHANGELOG, CP149 e Documento 105 coerentes; nenhum commit posterior. Nenhuma instância PostgreSQL persistente foi provisionada ou observada. Os 44 testes offline e 24 de integração permanecem evidência exclusivamente de CI.

**Decisão:** selecionar **Neon Free como candidato prioritário condicionado** de banco operacional persistente para piloto pequeno e com dados de baixo risco. Conservar **Supabase Free como alternativa não selecionada**. Não presumir que o piloto já cabe nas quotas; exigir ensaio factual de footprint e compatibilidade. A opção gratuita só pode prevalecer se satisfizer todos os gates ODB, particularmente backup independente e recuperação.

A escolha não constitui adoção definitiva da stack de produção. OES-H1/OES-P1 continuam válidos e documentação/hashes/cronogramas congelados do B1R1 permanecem intactos.

## 2. Base de comparação em 19/10/2026

| Critério | Neon Free (preferido) | Supabase Free (alternativo) |
|---|---|---|
| Preço-base | US$ 0/mês, sem cartão para inscrição | US$ 0/mês |
| PostgreSQL | **1 GB/projeto** após ampliação anunciada em 02/10/2026 | **500 MB/projeto** |
| Computação | **100 CU-horas/projeto/mês** | CPU compartilhada, limites do plano |
| Inatividade | Compute entra em **scale-to-zero após 5 minutos**, não desativável no Free; conexão subsequente reativa | Pode **pausar projeto** após uma semana de baixa atividade |
| Restauração embutida | Histórico de restauração de **até 6 horas ou 1 GB de mudanças**; insuficiente como backup de longo prazo | **Sem backup automático** e sem PITR no Free |
| Object storage | **5 GB/projeto incluídos**, produto ainda sob ressalva beta | 1 GB de storage no Free |
| Disponibilidade contratual | SLA formal não se aplica ao Free | Sem garantia aqui verificada de serviço contínuo |
| Compatibilidade com OES | Candidato para teste controlado em PostgreSQL 18; não testado com migrations OES | Candidato alternativo; não testado |

**Fontes primárias verificadas na avaliação:**
- Neon pricing (tarifas e limites atuais): https://neon.com/pricing
- Neon anúncio da mudança em 02/10/2026: https://neon.com/blog/neon-free-plan-1-gb-per-project
- Neon scale-to-zero: https://neon.com/docs/introduction/scale-to-zero
- Neon history/restore window: https://neon.com/docs/postgres/backup-restore/history-window
- Neon SLA (Scale/Business apenas): https://neon.com/sla
- Neon Object Storage beta: https://neon.com/blog/neon-backend-is-beta
- Supabase pricing: https://supabase.com/pricing
- Supabase project pausing: https://supabase.com/docs/guides/platform/free-project-pausing

Fontes acima são informativas e sujeitas a mudanças; reconfirmar no painel antes de aceitar termos de uso.

## 3. Arquitetura mínima preferida, sem pagamentos implícitos

1. **Neon Free PostgreSQL**, um único projeto operacional explicitamente identificado, sem CLI de CI com credenciais de escrita. Usar papel operador e papéis separados para leitura/verificação, com SSL/TLS, armazenamento de segredos fora do Git e registro das decisões. Versão PostgreSQL 18 preferida pela CI; confirmar suporte efetivo antes do bootstrap.
2. **Armazenamento de artefatos:** Neon Free Object Storage (limite publicado de 5 GB) como **opção de trabalho preliminar**, não solução automaticamente aprovada, devido a beta, às garantias não verificadas e à dependência do mesmo provedor. Usar chaves estáveis, verificação SHA-256 por byte, objetos privados, versionamento/imutabilidade efetiva ou objetos append-only, auditoria de upload/download. A metadata em `artifact.artifact` não prova existência nem imutabilidade dos arquivos.
3. **Backup independente e fora do Neon:** `pg_dump` com hash + cópia verificável de Artifacts e log de integridade, protegido por criptografia e controle de acesso em destino durável fora da conta/projeto primário. O histórico de restauração de 6 horas **não** satisfaz esse controle. Frequência, retenção, responsável, armazenamento e teste de `pg_restore` devem ser definidos antes de qualquer execução factual.
4. **Candidato externo opcional para os backups:** Cloudflare R2 Standard com franquia publicada de **10 GB-mês, 1 milhão de operações Class A e 10 milhões Class B por mês sem cobrança dentro da franquia**, com acesso S3. **Atenção:** exige ativação de assinatura R2/cadastro de cobrança; consumo excedente ou falha de método de pagamento pode gerar cobrança/bloqueio. Não tratar como serviço com custo máximo tecnicamente garantido em zero, nem criar/usar sem aprovação financeira explícita.
5. **Alternativa sem conta de cobrança externa:** armazenamento local **criptografado, controlado pelo operador e em mídia/local separados** para exportações periódicas do banco e arquivos. Não é, por si só, alta disponibilidade, backup contínuo ou solução comprovada sem um operador confiável, frequência e teste de restauração. O esforço, a responsabilidade e os custos indiretos não são zero.
6. **Executor factual separado:** conta/operador autenticados e mecanismo de execução pontual com idempotência, read-only preflight na base persistente e captura de evidência antes de qualquer escrita. ChatGPT Tasks e a CI existente **não** são scheduler/executor factual.

Fontes R2: https://developers.cloudflare.com/r2/pricing/ ; https://developers.cloudflare.com/r2/get-started/ ; https://developers.cloudflare.com/billing/understand/billing-policy/ .

## 4. Restrições metodológicas e de segurança do plano Free

- **Não autorizar** dados pessoais de pacientes, dados clínicos identificáveis, segredos, credenciais ou PHI em ambiente Free até classificação de dados, requisitos LGPD, contrato, região e controles técnicos analisados e aprovados. Começar apenas com metadados bibliográficos públicos e dados sintéticos em ensaio.
- Sem IP allowlist/private network e outras capacidades avançadas assumidas no plano grátis: verificar disponibilidade real e adotar defesa compensatória, especialmente roles mínimos, TLS, autenticação, rotação e auditoria.
- **Sem SLA de disponibilidade para Neon Free**; operação em horário rígido demanda conexão/pre-aquecimento verificado e operador presencial, plano de falha fechada; pre-aquecimento não altera horário do Epoch nem antecipa Opportunity.
- Verificar consumo de quotas (DB 1 GB, processamento 100 CU-h, object storage 5 GB), alertas, comportamento quando esgota franquia e exportabilidade; qualquer limitação que comprometa completude, segurança, retenção ou agendamento deve bloquear o gate, **não** ser contornada ficticiamente.
- `Neon Object Storage` está em beta; não afirmar durabilidade/garantia definitiva sem validação.
- A configuração gratuita é **opção econômica**, não obrigação de sacrificar critérios ODB. Se um controle eliminatório não puder ser atendido sem custo, devolver decisão ao owner antes de contratar ou avançar.

## 5. Plano de aceitação gratuito, antes do provisionamento

**G0 — decisão do proprietário, obrigatória**: confirmar o uso piloto de Neon Free, jurisdição/região apropriada, sem uso de dados clínicos pessoais, responsabilidades, política de backup externo, exposição a serviço em beta e ausência de SLA. Qualquer cadastro R2 com cobrança exige decisão financeira separada.

**G1 — provisionamento mínimo, mediante nova autorização**: criar uma instância Neon Free controlada pelo proprietário; identificar endpoint/projeto/região, conexão SSL, segredos, papéis e estado do serviço; sem incluir credenciais na conversa, no GitHub ou em logs.

**G2 — ensaio descartável/sintético separado**: testar PostgreSQL 18 e compatibilidade dos objetos OES-H1/OES-P1, `database/poc-s1.sql`, ordem 002–036, migration ledger do Documento de Arquitetura 30, privilégios, constraints, views e `maintenance.temporal_activation_preflight`, evitando inserir fixtures de CI no banco que futuramente será factual.

**G3 — artefatos/backup**: executar upload/download/hash; `pg_dump` para destino independente; `pg_restore` em instância segregada; recuperar os bytes correspondentes, provar FKs/authority/ledger e comparar o hash do artefato. Definir RPO/RTO compatíveis com o ritmo científico.

**G4 — auditoria e capacidade**: coletar medição de armazenamento de fato, CU-horas, cold-start, tempo de preflight e retenção; permitir adequação do plano somente mediante autorização específica.

**G5 — gate final ODB-01–ODB-12**: verificar e registrar todos os resultados `PASS`; uma conta criada ou logs de testes sintéticos não equivalem a `OPERATIONAL_DATABASE_READY`.

**G6 — novo experimento futuro**: somente depois de infraestrutura comprovada, decisão em modo alto, novo Epoch e novo schedule congelados com authority específica; nenhuma reativação retroativa de B1R1.

## 6. Estado do B1R1 nesta decisão

Os horários B1R1 de 19/10/2026 permanecem congelados. Esta decisão **não** executa live preflight, não ativa o B1R1, não consulta PubMed/ClinicalTrials.gov, não cria MeasurementEvents ou OpportunityResolutions e não reprograma as 14 Opportunities. A expiração da janela depende de verificação de horário factual após 09h00 e de comprovação de ausência de ativação válida. Não inventar fatos nem backdating.

## 7. Resultado do gate e continuação

> **FREE_FIRST_PRIORITY = APPROVED_AS_USER_PREFERENCE**  
> **PREFERRED_CANDIDATE = NEON_FREE**  
> **PREFERRED_OBJECT_STORE = NEON_FREE_OBJECT_STORAGE_CANDIDATE_BETA**  
> **INDEPENDENT_BACKUP = MANDATORY_AND_NOT_CONFIGURED**  
> **CLOUDFLARE_R2_STANDARD_FREE_TIER = OPTIONAL_WITH_BILLING_RISK_NOT_APPROVED**  
> **SUPABASE_FREE = ALTERNATIVE_NOT_SELECTED**  
> **PROVIDER_OWNER_APPROVAL = PENDING**  
> **COST_MAXIMUM_ZERO_GUARANTEE = NOT_ESTABLISHED**  
> **OPERATIONAL_DEPLOYMENT = NOT_AUTHORIZED**  
> **OPERATIONAL_DB_READINESS = NOT_READY**  
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **PHASE_5 = NOT_STARTED**

**Próximo bloco após `Prossiga`:** preparar pacote de autorização técnica do owner e checklist de cadastro/configuração do Neon Free sem segredos; dimensionar e aprovar independent backup antes de qualquer persistência factual. Configuração e eventual conexão serão realizadas somente após consentimento explícito do proprietário.

**Fim do Documento 106**

