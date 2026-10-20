# 135 — Proporcionalidade dos testes e priorização da Fase 4

**OES | 2026-10-20 (America/Recife) | CP179 | modo alto**  
**Classificação:** decisão de planejamento documental, com reservas. **Não certifica infraestrutura, não promove gates e não autoriza escritas persistentes.**

## 1. Origem e decisão

Freshness Gate CP178/main: `e78821cc4f377bb51b8640fda7d9c1cd9b538585`, identical, ahead=0, behind=0. Fonte canônica: template e ponteiro, CP178, Documento 134, STATE.md e CHANGELOG.md; foram ainda considerados Documento 04 (garantia), Documentos 05–06 (protocolo), Política de Migrações 30 e modelo candidato de roles/auditoria da Fase 4.

Após discussão explícita da necessidade de proporcionalidade, o proprietário autorizou neste CP apenas **revisão de prioridades**, não alteração de requisitos de segurança nem qualquer operação em Neon. Os CP175–CP178 estabeleceram, em PostgreSQL 18 descartável, limitações de ownership e `SET/INHERIT`, de event triggers transacionais e de recibos SHA-256 guardados no mesmo runner. Repetir provas equivalentes sem hipótese ou decisão nova oferece utilidade marginal decrescente.

**Deliberação:** priorizar evidência de suficiência **científica e funcional** da Fase 4 e diferir ensaios PG18 redundantes, **sem reduzir nem contornar requisitos já exigidos antes de pilotos/produção**.

## 2. Camadas de trabalho — distinção analítica, não novos gates

| Camada | Objetivo | Situação |
|---|---|---|
| **D0 — desenho e ensaio descartável** | Documentação, revisão metodológica, fluxos, contratos, testes offline e PostgreSQL efêmero com dados artificiais | Foco corrente, dentro do escopo e dos checkpoints autorizados; **não** implica conclusão da Fase 4 |
| **D1 — piloto persistente isolado** | Qualquer recurso persistente Neon, inclusive branch/roles/SQL/migrations com dados sintéticos | **Não autorizado**. Aplicam-se todos os BRGs e condições pertinentes à operação pretendida, revisão, custo, recuperação e aprovação específica |
| **D2 — operação autoritativa** | Automação de atualização, publicação científica, reconciliação/replay, produção ou M3 formal | **Não autorizado**. Exige gates científicos/humanos e operacionais conforme produto, finalidade e risco; Fase 5 não iniciada |

D0/D1/D2 não são estados normativos, não alteram políticas e não autorizam transições automáticas. Se um BRG exige prova antes de determinada escrita, não pode ser deslocado para depois dela por esta matriz.

## 3. Matriz de proporcionalidade

| Tema | Evidência atual | Prioridade D0 e exigência futura |
|---|---|---|
| Migrations, versionamento, provenance e guards | Evidências estruturais/sintéticas já produzidas; pós-condições ainda não aprovadas | Agora: revisar percursos de atualização e lacunas. Antes de persistência: revisão e evidências realmente exigidas pelos BRGs e pela Política 30 |
| Privilégios do proprietário, SET/INHERIT | CP175–CP178 demonstraram rotas de bypass no PG18 descartável | Agora: consolidar modelo de ameaça e critérios verificáveis, sem repetir variações equivalentes. Antes de D1/D2: confirmação de isolamento, elevação e controle do ambiente real |
| Auditoria DDL | Recibos no próprio runner podem perder SQL direto e aceitar adulteração conjunta de JSONL/âncora | Agora: especificar cobertura, domínio de confiança independente, eventos de falha e retenção. Antes da operação correspondente: comprovar auditoria eficaz, não presumir que CI ou hash chain a substituam |
| Ledger, supervisor, fencing e replay | BRG-06/07 bloqueados | Agora: descrever estados de falha e fluxo **manual/assistido sem automatismo autoritativo**. Antes de replay/reconciliação: demonstrar e aprovar os controles operacionais |
| Backup/restore, TLS e segredos | BRG-03/08 pendentes | Agora: estabelecer critérios objetivos de prova. Antes de escrita persistente: atender controles e gates pertinentes; não considerar branch/snapshot prova de restore independente |
| Billing e serviços externos | BRG-09 pendente; exportação de logs não selecionada | Agora: registrar dependências sem assumir plano gratuito. Antes de qualquer ativação: confirmação de recursos/custos pelo titular e autorização específica |
| Materialidade, currentness, atualização, assurance | Modelo conceitual e contratos históricos; ainda faltam evidências humanas e calibrações normativas | **Prioridade imediata:** percurso signal → assessment → decision → currency/versioning/Monitor; casos negativos; requisitos científicos e revisão especializada aplicável |
| B1R1 e M3 | B1R1 expirado sem execução, M3 operacional bloqueado | Não retomar B1R1, não atribuir thresholds/SLA sem base real, não ativar M3 por declaração documental |

## 4. Regra para novo ensaio técnico

Exigir registro explícito de: (1) decisão concreta dependente do teste; (2) hipótese nova e lacuna material; (3) consequência e risco se omitido; (4) oráculo de PASS/FAIL; (5) alternativa de prova menor; (6) custo, persistência e autorização; (7) critério de parada.

Na ausência de benefício decisório novo, marcar `DEFERRED_WITH_BLOCKER_PRESERVED`. Uma ameaça crítica inédita poderá justificar nova prova em checkpoint próprio autorizado. **Diferir não equivale a aprovar.**

## 5. Gates e restrições imutáveis neste CP

- **36 migrations UNREVIEWED**, zero pós-condições de reconciliação aprovadas; flags automáticas seguem desabilitadas.
- Matriz 034–036: **36 requisitos NOT_COLLECTED**. Modelo de roles: **12 controles obrigatórios insatisfeitos operacionalmente**.
- **BRG-03** (privilégios, TLS, segredos e auditoria externa Neon) bloqueado; **BRG-04/05** restritos a comprovantes históricos/sintéticos; **BRG-06** ledger não operacional; **BRG-07** supervisor/fencing/runner não operacional; **BRG-08** restore independente pendente; **BRG-09** conferência de billing pelo titular pendente.
- Nenhuma execução SQL, migration, branch ou role Neon; nenhuma nova CI PostgreSQL, nenhum serviço pago, nenhum processamento de dados científicos reais neste checkpoint.
- B1R1 `EXPIRED_NOT_EXECUTED`; Fase 5 `NOT_STARTED`.
- Governança humana do Documento 04 intacta: A2 é possível para N2 padrão com disclosure quando aplicável, mas não substitui A3 e controles especializados exigidos para N3/N4 formais ou finalidades críticas. IA não representa revisão humana.

## 6. Próximo passo e decisão de parada

O checkpoint seguinte, **somente após novo `Prossiga` e Freshness Gate**, deverá elaborar um **inventário de suficiência científico-funcional da Fase 4**, cobrindo fluxo manual/assistido, dependências de avaliação de materialidade/currentness, casos de falha, revisão humana, lacunas e critérios de eventual encerramento **documental**. Isso não inicia Fase 5, não aprova D1/D2, não libera BRGs e não transforma evidência sintética em segurança operacional.

**STOP — planejamento consolidado, operação não autorizada.**
