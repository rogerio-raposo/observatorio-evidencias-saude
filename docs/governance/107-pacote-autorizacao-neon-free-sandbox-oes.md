# 107 — Pacote de autorização para sandbox PostgreSQL Neon Free e prova de backup independente

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 19/10/2026  
**Modo:** alto  
**Status:** **OWNER_AUTHORIZATION_PACKAGE_READY — NEON_FREE_SANDBOX_UNPROVISIONED — BACKUP_GATE_PENDING**  
**Referências:** Documento 104 / CP148; Documento 105 / CP149; Documento 106 / CP150; Documentos de Arquitetura 24, 29, 30 e 38; runbooks 88, 91–93.  
**Escopo estrito:** pacote de decisão e ensaio técnico sintético; sem ativação B1R1, sem novo Epoch, sem dados clínicos identificáveis, sem gasto ou criação de recursos externos.

## 1. Freshness Gate

Em 19/10/2026, o HEAD `main` de entrada era `b6fe5a242e2e4c5f5ae1ee52f5478c629416fb8d`, ponteiro em CP150, sem commits posteriores; STATE e CHANGELOG coerentes. Os testes 44/44 offline e 24/24 integrados referem-se à CI sintética; não comprovam uma instância PostgreSQL operacional persistente.

O owner autorizou apenas **priorizar custo zero** ("se for possível, devemos optar por um serviço gratuito"). Não forneceu decisão específica de contratação, região, acesso, armazenamento de backups ou provisionamento.

## 2. Reconciliação factual das informações sobre Neon

Fontes públicas primárias verificadas em 19/10/2026:
- Neon Free pricing: https://neon.com/pricing — sem cartão, 100 CU-horas por projeto/mês, 1 GB Postgres por projeto, 5 GB de Object Storage (somente onde o produto estiver disponível), período de restauração limitado a 6 horas ou 1 GB de alterações, scale-to-zero aos 5 minutos.
- Neon regions: https://neon.com/docs/introduction/regions — PostgreSQL disponível em `aws-sa-east-1` (São Paulo); **Object Storage não disponível nessa região**; disponível, por exemplo, em `aws-us-east-1` e `aws-us-east-2`.
- Neon GA announcement: https://neon.com/blog/neon-backend-is-ga — lançamento de disponibilidade geral em setembro/2026.
- Neon Object Storage GA: https://neon.com/blog/building-neon-object-storage — aviso de que Object Storage agora é GA.
- Conexões TLS autenticadas: https://neon.com/blog/avoid-mitm-attacks-with-psql-postgres-16 — `sslmode=verify-full` e CA de confiança; cliente psql/libpq compatível pode utilizar `sslrootcert=system`.

**Correção de escopo do Documento 106, sem editá-lo retroativamente:** o rótulo "Object Storage beta" ficou desatualizado após GA de setembro/2026. A disponibilidade segue **dependente da região** e em São Paulo o serviço integrado não está disponível. O Documento 106 permanece histórico, mas seus pressupostos de beta/disponibilidade regional são superados por este Documento 107.

A descrição "Neon Free" é informação de plano publicada, não garantia de adequação, SLA, conformidade LGPD, ausência de suspensão por limite, backup independente ou disponibilidade contratual. Revalidar painel e termos no momento do eventual cadastro.

## 3. Seleção de região e serviços: proposta sem provisionamento

**Sandbox sintético recomendado:**
- fornecedor: **Neon Free**, sem serviço pago e sem cartão;
- projeto proposto: `oes-sandbox` (ou nome disponível equivalente, a ser confirmado pelo owner);
- região **candidata**: `aws-sa-east-1` (São Paulo, Brasil), **não aprovada ainda**; não escolher país/região silenciosamente;
- versão candidata: PostgreSQL 18, para aproximar da CI, sujeita a disponibilidade atual no plano e teste de migrations;
- database de trabalho candidata: `oes_sandbox`, independente da database padrão do provedor;
- conteúdo autorizado quando houver owner approval: **somente testes sintéticos descartáveis** e metadados artificiais sem PHI/dados pessoais clínicos;
- armazenamento integrado Neon Object Storage: **não usar na região São Paulo**, por indisponibilidade publicada;
- executor de source queries: não existe; não autorizar execução factual nesta etapa.

**Alternativa de região apenas mediante nova decisão:** `aws-us-east-1` (EUA, Norte da Virgínia) oferece PostgreSQL e Object Storage no mesmo projeto, mas introduz residência de dados fora do Brasil e ainda **não resolve backup independente**. Não escolher essa região automaticamente para simplificar uso de produtos Neon.

A região de um projeto Neon **não pode ser mudada após a criação**; mudança requer outro projeto e migração, segundo a documentação do fornecedor. O owner deve aprovar explicitamente o destino antes de criar o recurso.

## 4. Fluxo de autorização do proprietário

**Pendente de autorização expressa.** A mensagem genérica `Prossiga` não autoriza: cadastro, termos de serviço, criação de projeto, escolha de região, fornecimento de credenciais, vínculo de cobrança, nem entrada em modo de operação factual.

Formulação sugerida para autorização estrita, se estiver de acordo após examinar a proposta:

> **APPROVED — Neon Free sandbox / Documento 107 / OES / synthetic-only / aws-sa-east-1 / no paid services**

Efeito dessa aprovação, somente se explícita:
1. autoriza **orientar** o cadastro pessoal do owner na Neon e o provisionamento de **um sandbox gratuito** delimitado na região indicada;
2. permite testes técnicos **sintéticos não normativos**, sem dados factuais científicos;
3. não autoriza gastos, upgrade, cartão de crédito, autorização de terceiros, criação de novo Epoch, B1R1 activation, deploy de aplicação, SQL factual nem conexão da CI com o sandbox;
4. não autoriza manipular credenciais no chat ou registrar segredos no repositório.

Se o owner preferir região diferente, object storage integrado ou uso factual, a decisão deve ser reformulada e os controles reavaliados. **Os termos do provedor só podem ser aceitos pelo titular**, com ciência das obrigações correspondentes.

## 5. Checklist manual no painel Neon — somente após aprovação

1. Abrir `https://console.neon.tech/` em sessão pessoal; registrar-se ou entrar no Free sem ativar método de pagamento.
2. Verificar na página de planos a ausência de cobrança, quotas e eventuais mudanças de política; **parar** caso se exija upgrade ou billing.
3. Criar projeto com nome delimitado e **região previamente aprovada**; conferir PostgreSQL 18 no seletor (se indisponível: STOP e registrar divergência).
4. Registrar em manifesto operacional **somente metadados não secretos**: project ID (se política permitir), região, versão PostgreSQL, database, plano Free e data/hora factual; não registrar senha, token, API key ou connection string contendo senha.
5. Usar autenticação protegida; para clientes libpq, exigir `sslmode=verify-full` com trust store adequada, preferencialmente `sslrootcert=system` quando suportado. `sslmode=require` criptografa, mas não garante validação do hostname/certificado; não considerar suficiente.
6. Separar os privilégios operacionais: owner/admin apenas para provisionamento/DDL; leitura para inspeções; operador de escrita somente com escopo aprovado no futuro. Não entregar credencial do ambiente a workflows S5 nem colocar tokens no código.
7. Realizar readout mínimo **sem escrita de dados científicos**: `SELECT current_timestamp, current_database(), current_user, version();` e leitura de `SHOW server_version;` em sessão read-only. Capturar stdout e estado de conexão, sem dados sensíveis.
8. Desconectar, aguardar scale-to-zero permitido, reconectar e comprovar **persistência dos objetos de teste não factuais** por hash e existência (apenas após autorização específica do ensaio de schema).
9. Não executar `database/s5-fixtures.sql`, `database/f4-topi-n2-dcbti-b1r1-authority.sql`, `...corrective-preparation.sql` ou qualquer script de criação de estado factual por simples conveniência.
10. Documentar consumo de bytes/CU-horas e eventual cold-start; não confundir `Free plan` com prontidão para uma janela científica de horário rígido.

## 6. Backup independente — decisão adicional obrigatória

O Documento 105 define backup e **restore testado** como requisito ODB-08. O histórico de restore Neon Free de seis horas e eventuais snapshots **não são backup de longo prazo independente**.

**Opção A — custo financeiro zero em novos serviços, se o owner dispõe do equipamento:**
- guardar periodicamente um arquivo `pg_dump -Fc` encriptado, com hash SHA-256 e manifesto de origem/tempo, em **dois destinos controlados pelo owner**, sendo pelo menos um fora do provedor Neon e um em mídia/local de falha distinto;
- exportar todos os bytes de Artifacts e seus checksums; dump SQL sem snapshots binários **não é backup completo**;
- preservar chaves de decriptação em gerenciador de segredos fora dos backups; testar acesso, integridade e `pg_restore` em **ambiente isolado**, reconciliar FKs/contagens e hashes;
- estabelecer frequência pós-operação e periódica, responsável, retenção e RPO/RTO **antes** de qualquer medição factual. Backups local-only dependem de hardware, conectividade e disciplina humana; não oferecem disponibilidade contínua nem custo operacional literalmente zero.

**Opção B — Cloudflare R2 Free Tier:** pode viabilizar backup separado do Neon, mas requer habilitação de billing e pode gerar cobrança ao exceder a franquia ou conforme termos. **Não aprovada** pela preferência atual de evitar gastos. Exige autorização financeira própria e verificação de políticas de retenção, criptografia, versionamento, limite de gastos e restauração.

**Opção C — outro provedor/serviço institucional:** manter em aberto, caso exista serviço gratuito já contratado por instituição parceira, desde que haja controle legítimo e evidência de backup/restore.

**Condição de STOP:** se o owner não dispuser de destino backup independente verificável, o sandbox poderá ser usado para ensaios **descartáveis**, mas **não** para Measurements factuais.

## 7. Doze controles ODB em 19/10 (estado atual)

| Gate | Critério | Status |
|---|---|---|
| ODB-01 | owner, custos, região, responsabilidades | PENDING |
| ODB-02 | Postgres persistente verificado | NOT_EXECUTED |
| ODB-03 | TLS/roles/segredos e rede | NOT_EXECUTED |
| ODB-04 | classificação e residência de dados | PENDING |
| ODB-05 | migrations versionadas/ledger | NOT_EXECUTED |
| ODB-06 | bootstrap autorizado sem retrofatos | NOT_EXECUTED |
| ODB-07 | Artifacts externos, hash/restore de bytes | NOT_EXECUTED |
| ODB-08 | backup externo e restore provados | BLOCKED |
| ODB-09 | relógios, auditoria, incidentes e quotas | NOT_EXECUTED |
| ODB-10 | operador/executor factual e autorização | NOT_EXECUTED |
| ODB-11 | segregação rígida da CI | DESIGN_ONLY |
| ODB-12 | smoke tests reais sem efeitos factuais | NOT_EXECUTED |

Não há nenhum `PASS` factual de banco persistente nesta data.

## 8. Sequência futura após autorização explícita

1. **Modo alto** — decisão do owner sobre **sandbox Neon Free** e região. A conexão Neon do ChatGPT, se utilizada, requer ação explícita do titular e deve ter escopo controlado; não é pré-condição para documentação do projeto.
2. **Modo médio** — provisionamento pelo titular e teste mínimo de conectividade/read-only; registrar metadados sem segredos e primeiro readout; **novo checkpoint**.
3. **Modo médio** — diagnóstico das migrations 001–036 e implantação *sintética* em ambiente segregado, sem uso de fixtures no futuro banco factual; ledger e reconciliação.
4. **Modo alto** — decisão sobre backup local/offsite, RPO/RTO e armazenamento de Artifacts.
5. **Modo médio** — backup e restore factual dos dados de teste, logs/hashes, teste de limites Free e prova de persistência pós-suspensão.
6. **Modo alto** — gate ODB integral antes de qualquer proposta de **novo** Epoch, schedule ou execution authority.
7. Somente após gate e nova autoridade, eventual observação factual com horários futuros congelados; **não tentar recuperar retroativamente o B1R1**.

## 9. Semântica temporal e limites

B1R1 permanece congelado em `[2026-10-19T08:00-03:00,2026-10-19T09:00-03:00)`. Hora factual consultada durante a preparação: `2026-10-19T08:27:29-03:00`; janela aberta no instante consultado, sem live preflight em banco persistente. Não declarar `EXPIRED_NOT_EXECUTED` antes de 09h00, não retroagir timestamps, nem atribuir zero eventos como leitura operacional quando a instância não existe.

> **NEON_FREE_SANDBOX = NOT_PROVISIONED**  
> **NEON_SANDBOX_OWNER_APPROVAL = PENDING**  
> **REGION_CANDIDATE = aws-sa-east-1 / UNAPPROVED**  
> **NEON_OBJECT_STORAGE_SAO_PAULO = UNAVAILABLE_AS_PUBLISHED**  
> **NEON_OBJECT_STORAGE_GA_STATUS = GA_AS_OF_SEPT_2026**  
> **BACKUP_INDEPENDENT = NOT_CONFIGURED**  
> **OPERATIONAL_DB_READINESS = NOT_READY**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **PHASE_5 = NOT_STARTED**

**Fim do Documento 107**

