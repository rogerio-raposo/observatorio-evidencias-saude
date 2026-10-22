# Documento 218 — D1/T2-A2: decisão expressa A2-G4, implementação estática exclusivamente (CP243)

**OES | 2026-10-22 | A2-G4_STATIC_CODE_ONLY_APPROVED_NOT_STARTED | A2-G5/T2-A2 OPERATION NOT_AUTHORIZED**

## 1. Origem e alcance da aprovação

O proprietário declarou na conversa de continuidade, após apresentação da minuta ajustada de AF-03: **“Modo médio. Aprovada”**. Depois solicitou **“Prossiga”**. A decisão aprova estritamente o ato proposto na fórmula:

`APPROVED — OES / D1-T2-A2 / A2-G4 / ISOLATED_POSTGRESQL_ADAPTER_CODE_ONLY / PSYCOPG_3_3_6_STATIC_REFERENCE`.

A autorização abrange **somente criação, revisão estática e publicação controlada do código-fonte experimental**, sob os Documentos 216 (CP241) e 217 (CP242) e a proposta AF-03 apresentada e aceita. **Este checkpoint registra a aprovação, não executa a implementação.** Aprovação de escrita não concede execução, teste ou acesso Neon.

O Freshness Gate desta publicação partiu de `main` HEAD `2b06d2812d534e78979e9cc18d6a909383b4d40e` e ponteiro CP242, `identical`. O próximo passo só poderá ocorrer depois de novo `Prossiga` e Freshness Gate.

## 2. Dependência — decisão AF-03

Referência estritamente **estática de API**: `psycopg==3.3.6`, distribuição de referência `psycopg` (sem extras). Nenhuma instalação, import operacional ou escolha de distribuição binária foi autorizada. A distribuição realmente executável, biblioteca cliente/libpq, TLS, ambiente, configuração, versão efetivamente instalada e credenciais continuam dependentes de **deliberação separada antes da execução**. Não inserir dependência global, lockfile ou configuração de instalação nesta etapa.

## 3. Lista técnica fechada de arquivos a criar — nenhuma criação neste checkpoint

Único diretório candidato `prototypes/d1_t2/a2/`, exatamente:
1. `__init__.py`: pacote, import sem efeitos;
2. `repository.py`: PostgreSQL e UoW transacional;
3. `bridge.py`: cinco comandos sintéticos e replay/snapshot;
4. `errors.py`: distinção de erro de infraestrutura e `CommitOutcomeUnknown`;
5. `codec.py`: fingerprint e adaptação JSONB;
6. `README.md`: documentação e limites de validação.

**Nenhum outro arquivo técnico**, sem alteração em `prototypes/d1/` ou `prototypes/d1_t2/a1/`. Registros estritamente documentais de governança são separados do limite dos seis arquivos técnicos e dependem do processo de checkpoint.

## 4. Contratos de aceitação obrigatórios

- Núcleo de domínio importado canonicamente de `prototypes.d1.monitor`, sem novas cópias e sem `sys.path` dinâmico; mapear explicitamente a semântica de `DomainError` e `RepositoryConflict`, sem prometer identidade de classes importadas sob nomes divergentes.
- Preservar cinco comandos, payload/fingerprint SHA-256 de `encoded(payload)`, criação repetida retorna **snapshot corrente** sob transação, outros comandos repetidos retornam resposta originalmente armazenada, e request divergente não altera dados.
- Unit of Work com commit **explicitamente** solicitado; saída de contexto sem `uow.commit()` reverte trabalho pendente; proibir commit implícito na saída normal do contexto Psycopg. Preparar atomia de cenário+evento+recibo e revisão/sequência.
- Leitura protegida dentro da mesma transação/UoW. `READ COMMITTED`+lock antes de dependências para escrita existente, colisão de criação tratada por transação revertida e nova transação, `REPEATABLE READ READ ONLY` como hipótese de replay/snapshot. Não declarar concorrência provada.
- `CommitOutcomeUnknown(RuntimeError)` como contrato interno candidato; classificar falhas por estágio, não transformar automaticamente toda desconexão em resultado incerto; sem retry automático por padrão e sem retry cego de COMMIT indeterminado.
- SQL parametrizada, schema explicitamente qualificado, adaptação JSONB explícita, `NULL` SQL distinto de `null` JSON; sem aceitar irrestritamente `Any` de Python.
- Sem conexão, import operacional ou execução em import/construtor; sem segredos e DSNs; sem promessa de segurança de produção.
- Inspeção exclusivamente estática e diff de arquivos, sem rodar imports, compilação, testes ou ferramentas que executem o adaptador. Não declarar PASS dos oráculos sem execução.

## 5. Exclusões expressas

**Não autorizar** instalação de Psycopg ou qualquer driver/dependência, executar Python do adaptador, importação operacional, CI, testes T1/T2-A1/T2-A2, PostgreSQL SQL, conexões Neon, persistência de fixtures, alteração de schema/tabelas/DDL/migrations/roles/ACL/GRANTs, descarte administrativo, serviços pagos, operações em `oes-sandbox`, dados reais, factual search, API pública, deployment ou promoção de gates. Papéis `oes_t2a2_runtime` e `oes_t2a2_owner` proibidos como runtime; `oes_t2a2_app` somente candidato de menor privilégio para **etapa futura aprovada**.

As permissões e a estrutura já documentadas nos CP239/CP240 permanecem inalteradas. Os limites TLS anteriormente registrados permanecem.

## 6. Limites de conclusão e evidências

O estado atual é `A2-G4_STATIC_CODE_ONLY_APPROVED_NOT_STARTED`. Após futura implementação estritamente autorizada e inspeção/commit verificados, o **máximo** será `STATIC_SOURCE_IMPLEMENTED_NOT_EXECUTION_VALIDATED`. Isso não é A2-G5, não significa adaptador funcional, idempotência durável provada, segurança validada ou replay testado.

F01–F07 apenas endereçados documentalmente; RA-01–RA-10, AA-01–AA-09 e AF-01–AF-05 seguem com evidência operacional pendente onde aplicável; L1–L4 e O-01–O-10 não executados. T1 36 PASS e T2-A1 75 PASS apenas **históricos**. Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`.

## 7. Próxima atividade e STOP

**Somente após novo `Prossiga`:** iniciar uma única atividade interna de implementação estática delimitada, começando pelo contrato `errors.py`/`codec.py` e fundamentos de importação conforme Documento 217, sem instalação, import, execução, teste, SQL, CI ou Neon. Preservar Freshness Gate no início, checkpoint normalmente após 3–5 atividades ou por risco, e reportar status `NÃO PERSISTIDO` até efetiva publicação. **STOP.**
