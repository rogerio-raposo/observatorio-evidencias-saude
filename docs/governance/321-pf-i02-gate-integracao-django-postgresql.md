# Documento 321 — PF-I02: gate consolidado de integração Django/PostgreSQL Q0→Q1

**Data:** 2026-10-26. **Estado:** proposta de decisão, NÃO autorização. **Base:** CP300, Docs. 311–320.

## Evidência encerrada, não repetir
I01-A: scaffold Django auth/CSRF offline, CI 40257279644 success; **nenhum login real**. I01-B/C: schema Q0-only implantado exclusivamente na branch sintética `br-gentle-hall-b6jaxehf`. D0: T1 Q0, T2 Q1 e cleanup preciso comprovados **sob owner**, sem resíduos (Doc.319). Inventário Doc.320 comprovou que não existe writer de preparação independente utilizável. Nenhum desses marcos homologa um caminho HTTP persistente.

## Objetivo do próximo incremento funcional
Criar/ler Q0 e propor/ler Q1 através de Django, sob preparador humano autenticado e autorizado, PostgreSQL com identidade técnica segregada, estado/versão/auditoria recuperáveis, negação para anônimo e sem E9. Limite inicial: dados **exclusivamente sintéticos**, ambiente restrito de teste; nenhuma pergunta clínica pessoal, usuário real externo ou implantação pública.

## Três autorizações sequenciais, evitando novo ciclo de ensaios paralelos
**W1 — engenharia offline Django, sem banco conectado:** implementar contrato HTTP restrito, serviço Q0/Q1 versionado, proteção de método/CSRF/sessão/permissão, validação de conflito e idempotência mediante mocks, com testes. Sem abrir rotas de escrita utilizáveis com configurações de desenvolvimento inseguras; deny-by-default em execução. Não criar pessoas, grupos ou segredos reais; nenhum Neon/DDL/DML.

**W2 — infraestrutura de identidade e grants mínimos no sandbox:** somente após revisão do código e do SQL exato; identidade PostgreSQL independente e não-owner; privilégios comprovados para `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version`, somente operações/colunas requeridas; negações explícitas em `investigation.investigation`, produtos, E6, DDL e limpeza ampla. Conferir memberships/PUBLIC/schema/funções. Gestão segura de credencial sem divulgação; aprovação independente para role, grants e qualquer componente de autenticação persistente. Não reutilizar `oes_pg_a4_reader`, `oes_e6_capture_login` ou owner como runtime.

**W3 — prova funcional conectada de ponta a ponta:** depois de W1/W2 e autorização separada de DML/ativação, um preparador técnico autorizado em ambiente restrito faz Q0→Q1 via Django, com leitura posterior, integridade, concorrência/idempotência, CSRF, controles negativos, ausência E9 e cleanup/reconciliação; evidência sem publicação de payload. O gate conectado diferido do Doc.285 é obrigatório. Não implantar nem converter automaticamente em prontidão.

## Pendências reais a resolver em W1/W2
- Django atual `DATABASES={}`/backend dummy; auth/sessions não persistidos e a permissão `evidence.prepare_question` é apenas nome de verificação em código, ainda não declaração/criação operativa. Separar banco de auth e dados OES apenas se houver necessidade técnica demonstrada.
- Schema Question não possui por si mecanismo de idempotência/auditoria completa; definir solução pequena, transacional e persistente antes de declarar W3 possível. Evitar um segundo registro de perguntas ou um novo framework.
- Papel de writer mínimo e credencial independente ainda não existem; D0 sob owner não substitui W2.
- `DEBUG=True`, secret estático de desenvolvimento: somente execução offline; não tornar rota acessível externamente enquanto essa fronteira existir.
- Proibir endpoints `Investigation`/E9 em código, testes e privilégios.

## Critérios de aceite objetivos
W1: regressões Django/PF-I01 + não autorização para usuários anônimos/sem permissão, métodos negados, não conexão com banco e rotas de escrita inertes por padrão. W2: ACLs positivas e negativas, identidade independente, TLS e rotação de segredo sem vazamentos. W3: Q0 exata, uma versão corrente, Q1 nova, histórico/auditoria, retry idempotente, conflito rejeitado, cleanup seletivo e zero impacto sobre terceiros. Falha/incerteza de commit = HOLD, nunca replay silencioso.

## Proposta de autorização imediata
**Somente W1**:
`APPROVED — OES / PF-I02-W1 / OFFLINE_DJANGO_Q0_Q1_CODE_AND_TESTS_ONLY / no Neon / no SQL writes / no real users / no grants or credentials / no deploy / E9 blocked / fail closed`

Não inferir autorização W2/W3 do `Prossiga`. Após W1, solicitar W2 com SQL/roles e escopo exatos. Marco B aberto; A3 não realizada; readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
