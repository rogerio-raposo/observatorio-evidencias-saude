# Documento 198 — D1-T2-A2: decisão escalonada e preparação P2-C1 (CP223)

**OES | 2026-10-21 | CONSOLIDAÇÃO DOCUMENTAL | P2-C1 NOT_APPROVED | T2-A2 NOT_AUTHORIZED**

## 1. Contexto e distinção de autoridade
Base: CP222 / Documento 197. Consolidam-se quatro atividades após CP222: (1) pacote deliberativo P1–P4 e minuta P1; (2) planejamento P2 e recomendação de P2-A; (3) inspeção complementar P2-A relatada na conversa; (4) seleção documental P2-B e preparação da minuta P2-C1. As aprovações do proprietário para **P1 e P2-A restringem-se a inspeção não invasiva somente leitura**, sem autorizar P2-C1, instalação, SQL, execução PostgreSQL ou implementação T2-A2. A elaboração P2-B/P2-C foi autorizada apenas como documentação por `Prossiga`.

**Rastreabilidade de evidência:** os resultados de inventário local informados na conversa (Debian 13, Python 3.13.5, `pg_config`/`libpq` 17.11, servidor e driver não encontrados) **não estão acompanhados aqui de logs brutos, transcrições verificáveis dos comandos ou artefato técnico persistido**. São observações relatadas, **não prova independente** de disponibilidade/ausência de software. Antes de qualquer decisão de instalação, repetir preflight controlado no ambiente realmente selecionado e registrar saída dos comandos, versão e contexto, sem segredos. Esta formalização não reexecutou preflight.

## 2. Estratégia P1–P4
- **P1, autorizado historicamente:** inspeção local somente leitura; não concede autorização operacional.
- **P2, pendente de implementação:** identificar e preparar dependências concretas sob atos separados. **P2-A** inspeção de leitura foi autorizada; **P2-B** seleção meramente documental; **P2-C1** minuta não aprovada; **P2-C2** futura inicialização de cluster ainda não autorizada.
- **P3:** adaptação e testes transacionais PostgreSQL sintéticos dependem de aprovação expressa posterior.
- **P4:** avaliação técnica e eventual encerramento também exigem decisão posterior; PASS experimental não promove gates.

## 3. Seleção técnica candidata
PostgreSQL **17** e **Psycopg 3** são **candidatos**, não versões aprovadas para instalação, escolhidos para minimizar componentes e preservar compatibilidade com a biblioteca cliente relatada em P2-A. Confirmar versões suportadas, disponibilidade do binário/driver, integridade da origem e instalação isolada no preflight novo. A presença de `libpq` não comprova servidor PostgreSQL disponível.

Preferir binários/instalação isolados com diretórios exclusivamente experimentais e sem serviço permanente. **Pacotes Debian convencionais podem executar scripts de manutenção ou criar serviços/clusters**, portanto não presumir instalação isenta de efeitos globais. Contêiner, SQLAlchemy e APIs não integram o mínimo; Neon Free e outros ambientes externos excluídos.

## 4. Fronteira de autorização sugerida — não aprovada
### P2-C1: preparação de componentes, sem início do servidor
Escopo proposto: inventariar pacotes e diretórios existentes; identificar origem/versão/integridade dos binários PostgreSQL e driver; disponibilizar **apenas depois de aprovação expressa** componentes em local experimental reversível; isolar dependências Python; conferir binários sem criar cluster, conectar, iniciar servidor ou executar SQL.

**STOP imediato** se houver necessidade de root/efeitos globais, modificações compartilhadas, custo, serviço automático, falta de isolamento ou instalação não previamente descrita. Uma permissão genérica para P2-C1 não inclui passos privilegiados: exigir mecanismo e caminhos concretos na decisão.

### P2-C2: inicialização experimental — não aprovada
Futura criação/inicialização de cluster, usuário, database, schemas ou qualquer SQL exige aprovação específica separada com controle de diretórios, permissões, acesso local, rollback/descarte e proteção de segredos.

### P3/P4 — não aprovados
Execução do adaptador, transações, testes, CI, implantação e encerramento técnico não decorrem das autorizações de inspeção e documentação.

## 5. Critérios financeiros, de segurança e descarte
Custo incremental zero demonstrado; sem contratação, cartão, upgrade ou recurso cloud pago. Proibidos Neon, fontes factuais, dados reais, migrations canônicas, alteração de `prototypes/d1/` e `prototypes/d1_t2/a1/`, gates e estados científicos. Manter semânticas históricas de `create_scenario`, `pending` e `RepositoryConflict`/`DomainError`. Segredos não devem aparecer em logs, GitHub ou conversa.

Antes de qualquer instalação, especificar inventário inicial, objetos/criações exatos, diretórios e usuários, processos envolvidos, isolamento de rede, mecanismo seguro de limpeza e verificação de ausência de efeitos compartilhados.

## 6. Minuta P2-C1 — PROPOSTA, NÃO APROVADA
`APPROVED — OES / D1-T2-A2 / LOCAL_COMPONENT_PREPARATION_ONLY / Autorizar apenas após preflight revalidado e aprovação concreta de origem, versão, caminhos, dependências e método de isolamento a disponibilização reversível de binários PostgreSQL locais e driver Python em ambiente experimental separado, sem iniciar servidor, criar cluster/database/role/schema, conectar ao banco ou executar SQL; sem alterações globais ou privilégios não aprovados, dados factuais, Neon, cloud, CI, serviços pagos, migrations canônicas, alterações T1/T2-A1 ou promoção de gates; parar diante de qualquer requisito fora do escopo e solicitar nova autorização.`

**Não há aprovação expressa desta minuta.** Nenhum `Prossiga` genérico autoriza sua execução.

## 7. Próxima atividade
Após CP223, revisar plano concreto de distribuição isolada, origem/versões, riscos de scripts de instalação e plano de descarte; preparar pacote P2-C1 para decisão expressa do proprietário, mantendo todas as operações bloqueadas. Somente leitura documental, sem instalação, SQL/Neon/CI. STOP.
