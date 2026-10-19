# 105 — Gate arquitetural do banco operacional persistente do OES

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 19/10/2026  
**Modo:** alto  
**Status:** **ARCHITECTURE_APPROVED_WITH_CONDITIONS — PERSISTENT_OPERATIONAL_POSTGRES_CANDIDATE — PROVIDER_UNSELECTED — DEPLOYMENT_NOT_AUTHORIZED**  
**Dependências:** Documento 104/CP148, arquitetura OES-H1 (Documento de Arquitetura 24), promoção OES-P1 (Documento de Arquitetura 38), política de migrações (Documento de Arquitetura 30), proveniência (Documento de Arquitetura 29), Documentos 88 e 91–93, migrations 033–036.

## 1. Freshness Gate e objeto da decisão

Branch `main`, HEAD de entrada `d92a426fcdecfc3392244f8625631d26486a9c09`; ponteiro README, STATE, CHANGELOG e CP148 coerentes, sem commits posteriores ao CP148. A CI 252 validou 44/44 testes sintéticos offline e 24/24 testes integrados, mas utiliza PostgreSQL 18 temporário como serviço do GitHub Actions; **não** cria uma base factual persistente. O usuário declarou que não há PostgreSQL operacional persistente. Esta decisão cobre arquitetura de implantação para um **piloto operacional não normativo**, e não a seleção da stack definitiva de produção.

## 2. Decisão

**Aprovar como arquitetura de referência condicional:** `OES-H1` com **um PostgreSQL gerenciado e persistente como única fonte relacional factual**, **armazenamento durável de objetos** para bytes dos Artifacts e snapshots, e **executor operacional identificado** para operações futuras autorizadas. Manter `CI/synthetic` separado da base `operational/factual`.

A escolha de *PostgreSQL gerenciado* decorre do baseline SQL e da necessidade de transações, constraints, trigger guards, UUID/JSONB e restore. **Não** se está escolhendo fornecedor, produto pago, região, conta, credenciais ou execução. A alternativa autogerida não é a primeira escolha para este piloto: exige manutenção de sistema, patches, segurança, backups e restauração pelo próprio operador.

Arquitetura de fronteiras:

1. **GitHub:** código, migrations, documentação normativa/operacional versionada, referências a contratos congelados e logs de CI; não é o banco operacional.
2. **CI isolada:** Postgres efêmero, fixtures artificiais, regressões, reconstrução; não recebe credenciais write da base factual.
3. **Banco persistente:** transações, modelo OES-P1, autoridades, epochs, opportunities, MeasurementEvents, Resolutions, metadados de Artifacts, migration ledger; única fonte de verdade estruturada.
4. **Object storage durável:** snapshots de request/response, identifier sets, arquivos, logs, capturas e hashes; chaves/URIs imutáveis ou versionadas, acesso controlado, verificação de checksum. A tabela `artifact.artifact` existente traz `storage_key`, `content_hash`, `hash_algorithm`, `source_uri`; o ponteiro não equivale à existência do objeto.
5. **Executor operacional autenticado:** acesso somente após authority/preflight/Opportunity gate, captura tempo factual, executa request autorizado, preserva bytes e associa metadados em transação. **Não existe ainda**; um relógio do ChatGPT, lembretes ou uma run GitHub Actions não substituem esse executor. Não automatizar source queries neste gate.
6. **Backups independentes:** snapshots/backup do banco, proteção dos objetos, restauração ensaiada e trilha de auditoria. Backups não podem existir só na mesma instância que protegem.

## 3. Comparação de alternativas para diligência do fornecedor

| Candidato | Vantagens | Pontos de verificação eliminatórios | Estado |
|---|---|---|---|
| **Neon** (Launch/Scale conforme controles) | PostgreSQL gerenciado, computação por uso e possibilidade de escala a zero, snapshots/restore conforme plano | Confirmar plano com backups agendados, retenção, restore testável, conexão segura, limitações de rede privada (conforme plano) e início confiável antes de janela curta | SHORTLIST, não escolhido |
| **Supabase Pro ou superior** | PostgreSQL gerenciado e object storage integrável; Pro anuncia backup diário e retenção de 7 dias | Confirmar localidade, conectividade protegida, permissões, segregação, restauração, custos de PITR e política de pausing do plano | SHORTLIST, não escolhido |
| **AWS RDS PostgreSQL** | Serviço maduro com backups/retenção configuráveis, snapshots e controles de VPC | Comprovar custos totais, rede, capacidade de administração AWS, backups e operação do object storage | SHORTLIST, não escolhido |
| **VM/contêiner autogerido** | Controle direto | Backup/patching/segurança/restore e responsabilidade integral do operador; risco operacional adicional | NÃO PREFERIDO para piloto |

Fontes públicas consultadas em 19/10/2026:
- Neon, pricing: https://neon.com/pricing — Free 1 GB/projeto, história de restauração limitada; Launch sob consumo, com recursos variáveis conforme plano. Valor ilustrativo indicado para carga intermitente de 1 GB: cerca de US$ 15/mês; **não é cotação** para o OES.
- Supabase, pricing: https://supabase.com/pricing — Pro a partir de US$ 25/mês com backups diários de 7 dias; Free pausa após inatividade e não inclui backup automático. PITR é custo adicional.
- Supabase, backups: https://supabase.com/docs/guides/platform/backups .
- AWS, RDS PostgreSQL pricing: https://aws.amazon.com/pt/rds/postgresql/pricing/ — cobrança por capacidade, armazenamento, backups e rede segundo configuração/região.
- AWS, backup retention: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.BackupRetention.html — retenção configurável, limites conforme implantação.

**Política de custo:** orçamento, moeda, impostos, região, tamanho esperado e capacidade de pagamento não foram fornecidos nem aprovados. Não assumir benefício de free tier como garantia de disponibilidade, durabilidade, controle de acesso ou backup; exigir estimativa total verificável antes de provisionar. Preferir solução reversível que preserve export SQL padrão e formatos abertos.

## 4. Gate de implantação e aceite técnico — eliminatório

A infraestrutura somente poderá ser considerada **OPERATIONAL_DATABASE_READY** quando **todas** as condições abaixo tiverem evidência factual:

| Código | Controle obrigatório | Prova requerida |
|---|---|---|
| ODB-01 | Dono, provedor, região, orçamento/teto e responsáveis aprovados | Decisão explícita do owner, inventário de serviço, escopo financeiro |
| ODB-02 | Banco PostgreSQL persistente independente de CI | Endpoint/ID de instância durável, read-only pós-reconexão, diferença inequívoca do DB de teste |
| ODB-03 | Segurança e minimização | TLS, identidade de operador, segredos fora do Git, permissões mínimas, proteção de rede compatível com o plano e threat model |
| ODB-04 | Dados e conformidade | Inventário de categorias de dados, política LGPD quando aplicável, retenção, região/residência e trilha de acesso |
| ODB-05 | Migrações | Baseline `database/poc-s1.sql`, ordem explícita de 002–036, ledger de hashes/identidade, provas de idempotência quando aplicável, sem fixtures de CI por padrão |
| ODB-06 | Bootstrap e semântica histórica | Materialização de entidades de referência/authority apenas sob decisão específica; B1/B1R1 **não** recebem execução retrospectiva |
| ODB-07 | Object storage e linkage | Upload/download factual, integridade SHA-256, URI/key, permissions, snapshots preservados separadamente de CI |
| ODB-08 | Backup e recuperação | Backup automático e retenção aprovados; **teste de restauração em ambiente segregado**, reconciliação de counts, Artifacts e hashes; RPO/RTO definidos e aprovados, sem números inventados |
| ODB-09 | Observabilidade e continuidade | Clock UTC e America/Recife confiáveis, logs de execução sem segredos, rastreabilidade de operador, alertas de disponibilidade/custo, plano de incidente |
| ODB-10 | Executor e autorização | Fluxo manual/verificável de autorização → live preflight real → evidence Artifact → transação → readout, com timeout, idempotência e bloqueio de execução prematura |
| ODB-11 | Separação de ambientes | CI sem write credentials sobre banco factual; nenhuma fixture ou `rebuild` destrutivo encaminhado à instância operacional |
| ODB-12 | Ensaio de ponta a ponta | Smoke tests e readouts **não normativos** no ambiente operacional com transações que não fabricam evento científico, seguidos de conferência de zero efeitos indevidos |

Uma decisão de arquitetura ou uma CI verde **não comprova** ODB-01–12. A execução real de `maintenance.temporal_activation_preflight` num banco persistente é obrigatória para cada ativação futura.

## 5. Sequência de implementação proposta (não autorizada)

**F0 — Seleção formal:** colher decisão explícita sobre provedor, plano, região, responsáveis, orçamento, perfil de dados e RPO/RTO; demonstrar custo total e risco de lock-in.  
**F1 — Provisionamento segregado:** instância e object storage, identidades, rede/TLS, segredos, auditoria, controle de acesso e reserva financeira; sem dados experimentais factuais.  
**F2 — Baseline/migrations:** criar schema via execução controlada e auditada; migration ledger, hashes, resolução de incompatibilidades; não executar `s5-fixtures.sql` ou scripts de cases reais por conveniência.  
**F3 — Bootstrap explícito:** autorizar materialização de dados estruturais de referência e congelamentos históricos com status **declaradamente não executado**; sem simular uma Opportunity real; validar design freeze com especial cuidado, pois timestamps `created_at` históricos no SQL de teste não são por si um deploy factual original.  
**F4 — Durabilidade:** Artifacts de teste delimitado, backup/restore de banco e objetos, reconciliação da cadeia de provas.  
**F5 — Executor/preflight:** definir operador, isolamento das credenciais, preflight read-only no ambiente real, registro de logs e política de falha fechada, sem source query antecipada.  
**F6 — Novo experimento:** somente em **modo alto**, após readiness operacional e decisão owner, propor novo Epoch/cronograma, realizar novo freeze/authority e executar nas janelas futuras autorizadas.

## 6. B1R1 e a janela de 19/10

B1R1 mantém intervalo congelado `[2026-10-19T08:00-03:00, 2026-10-19T09:00-03:00)`. Em 19/10, às **08:14:15 America/Recife**, a janela estava aberta na consulta do relógio, mas não existia base operacional para o preflight; **não ativar** sem infraestrutura e live PASS. Este documento não declara expiração antes das 09:00. Após as 09:00, sem ativação válida, a classificação `EXPIRED_NOT_EXECUTED` requer confirmação factual temporal, conforme Documento 91. Não alterar nem retroagir o B1R1 para recuperar a janela.

## 7. Decisão do gate e limites

> **PERSISTENT_OPERATIONAL_DB_ARCHITECTURE = APPROVED_WITH_CONDITIONS**  
> **PREFERRED_CLASS = MANAGED_POSTGRES_PLUS_OBJECT_STORAGE**  
> **PROVIDER_PLAN_REGION_BUDGET = PENDING_OWNER_DECISION**  
> **OPERATIONAL_DEPLOYMENT = NOT_AUTHORIZED**  
> **OPERATIONAL_DB_READINESS = NOT_READY**  
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**  
> **PHASE_5 = NOT_STARTED**

A implantação exige nova aprovação explícita. Manter OES-H1 e OES-P1; não criar nova migration, alterar frozen artifacts ou implementar cliente de rede por implicação desta decisão.

**Próximo bloco autorizado apenas após `Prossiga`:** pacote de seleção do fornecedor e plano de implantação controlada, mantendo a decisão de contratação/provisionamento reservada ao proprietário do projeto.

**Fim do Documento 105**

