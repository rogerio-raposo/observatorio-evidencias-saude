# CP349 — OES | Continuidade proporcional após decisões P1/P2, Django único e HTTPS Codespaces

**Data:** 2026-11-17 (America/Recife).  
**Natureza:** checkpoint documental de continuidade; não é liberação científica ou operacional.  
**Antecessor:** [CP348](OES_Continuidade_2026-11-08_CP348.md), preservado integralmente como evidência histórica do primeiro Q0 sintético persistente.  
**Base de preparação:** `main` em `8e60491f9c99bd8ee48cbeafa26d6efb0354cb8b` (squash do [PR #42](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/42)); verificar novamente o HEAD remoto em toda retomada.

## 1. Fontes canônicas obrigatórias e ordem de retomada

1. Conferir `main` remota e `STATE.md` pelo Freshness Gate; comparar o HEAD com a base deste checkpoint.
2. Ler [ponteiro dos handoffs](README.md) e este CP349; consultar [CP348](OES_Continuidade_2026-11-08_CP348.md) apenas para os fatos históricos que fundamenta.
3. Aplicar **[Documento 362 — simplificação e governança proporcional](../../../docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md)**.
4. Aplicar **[Estratégia ChatGPT–Codex–GitHub](../../../docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md)**, inclusive §2.1 (Contraditório Técnico Fundamentado).
5. Aplicar **[AGENTS.md — autonomia operacional do Codex](../../../AGENTS.md)**, que não altera as permissões técnicas da ferramenta.
6. Para Q0/P2 e ingresso HTTPS, consultar [contrato P2 v2](../../../docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md) e [decisão arquitetural HTTPS](../../../docs/governance/OES_CODESPACES_HTTPS_ARCHITECTURAL_DECISION_DRAFT.md).

**Prevalência:** Documento 362 e estratégia estabelecem proporcionalidade e divisão de responsabilidades; este checkpoint não os altera. Atualizações posteriores na `main` devem ser reconciliadas antes de executar ações.

## 2. Marcos incorporados desde CP348

| Marco | Evidência integrada / alcance |
| --- | --- |
| P1 — simplificação e núcleo transacional | [PR #37](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/37), offline; cinco INSERTs, transação/locks, D3 e ausência de retry preservados; corrigido problema de callback pós-COMMIT após contraditório. |
| P2 — contrato operacional único | [PR #38](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/38), offline; matriz de aceite, lacunas conectadas explícitas, sem homologação. |
| Django único | [PR #39](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/39); sessão/Auth nativos e aliases `default`, `oes_q0_writer`, `oes_synthetic_reader`, com credenciais distintas no mesmo processo restrito. Não ressuscitar A/B de dois processos. |
| Preparação Codespaces | [PR #40](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/40); devcontainer, Gunicorn em `127.0.0.1:8000`, perfil privado e testes offline. Codespaces foi utilizado em experimentos posteriores, sem equivaler a aceite operacional. |
| Autonomia do Codex | [PR #41](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/41); `AGENTS.md` com uma autorização por escopo delimitado, não por comando. |
| Decisão HTTPS | [PR #42](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/42); aprovado **desenho**, não homologação: fronteira Codespaces `Private` supervisionada inclui custódia de processos locais; `trusted_proxy` é preferido somente após comprovação da proveniência dos cabeçalhos; manter `Host` convencional e `USE_X_FORWARDED_HOST=False`. |

**Evidências HTTPS fora da main:** [matriz sanitizada de 14 requisições](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/24b629477a866b34d1504c7681d0e4da91ec3fe3/evidence/runtime/codespaces/https-followup/header-matrix-900s/RELATORIO.md) (respostas HTTP 200 e cabeçalho `X-Forwarded-Proto=https` recebido) e [revisão de topologia](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/b99e6ddd62c320ac8c28a364985f160ddb4236e7/docs/governance/OES_CODESPACES_HTTPS_TOPOLOGY_REVIEW_DRAFT.md). Não demonstram sanitização garantida pelo ingresso, proteção contra acesso direto, esquema/host efetivo no Django ou CSRF real.

**Diagnóstico de ambiente fora da main:** [relatório sanitizado do sandbox Codex](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/e0f4a3e0138ca7e33bee89ce6b3335fef8324fb3/evidence/runtime/codespaces/codex-sandbox/OES_CODEX_DIAGNOSTICO_APROVACOES.md). Codex CLI `0.169.0`; sandbox `workspace-write` e aprovações sob demanda; `bwrap` falha na criação de user namespace até para `true`; teste `unshare` no terminal também falhou segundo responsável. Kernel reporta `unprivileged_userns_clone=1`, `max_user_namespaces=31741`; processo reporta Seccomp modo 2, um filtro. Hipótese de bloqueio pelo isolamento do contêiner/execução, **sem causa administrativa exata confirmada**. Teste pontual Landlock legado falhou porque o executor exige Bubblewrap para isolar sockets do app-server. Nenhuma correção do sistema foi aplicada.

## 3. Diretrizes de trabalho vigentes — não constituem novo procedimento

- **ChatGPT:** coordena prioridades/escopos, produz continuidade documental diretamente quando puder, revisa independentemente diffs e evidências, podendo publicar branch/PR e fazer merge **quando expressamente autorizado**, após as verificações aplicáveis.
- **Codex:** implementa, testa offline e produz evidências; pode publicar na branch isolada se o despacho abranger preparação + testes + push. **Não é intermediário obrigatório** para documentos de governança ou checkpoint.
- **GitHub:** `main` é fonte canônica; branch local/isolada e conversa não equivalem a integração.
- **Responsável:** aprova efeitos e escopos. Publicação e merge podem ser autorizados juntos **expressamente**, mantendo revisão independente, SHA, proteções e STOP entre eles. `Prossiga` não amplia permissões.
- **Proporcionalidade (Documento 362):** não recriar microgates, verificadores, arquitetura paralela, testes rituais ou checkpoints por contagem; reusar evidências e priorizar avanço funcional verificável.
- **Contraditório técnico (§2.1):** críticas do ChatGPT não são ordens; Codex pode contestar fundamentadamente; classificar achados e corrigir apenas o material procedente, dentro de uma rodada proporcional.
- **Condição conhecida do Codex CLI:** o responsável decidiu **prosseguir com as aprovações pontuais adicionais** apesar da falha de sandbox; preservar `workspace-write`, aprovação sob demanda e isolamento, sem `Full Access`, bypass ou alteração insegura do host. Reabrir o diagnóstico apenas diante de fato novo ou bloqueio impeditivo.

## 4. Invariantes e limites de evidência

- **Marco B OPEN; Q0 geral HARD HOLD; Q1 conectado HOLD; E9 NO-GO; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED.**
- `_require_release()` continua HOLD incondicional; HTTP mutante Q0 423; sem retry automático; P1, D3, identidades e critérios de aceite P2 preservados.
- CP348 permanece o primeiro `PERSISTED/Q0_RECORDS` sintético no fluxo canônico, **uma tentativa histórica, não autorização reutilizável**. Não presumir prova de todos os cenários PostgreSQL, autorização exactly-once ou revisão científica com pesquisadores reais.
- Nenhuma decisão posterior concede nova execução conectada Neon/PostgreSQL, SQL/roles/grants, credenciais, workflow operacional, deploy, custo, dados reais, escrita Q0 ou transição de fase. A decisão HTTPS é documental; `trusted_proxy` não foi ativado.
- Diferenciar rigorosamente relatório local Codex, testes offline, CI GitHub, evidência sintética conectada e homologação operacional.

## 5. Próxima atividade objetiva

**Cobertura offline consolidada de HTTPS, `Host` e CSRF no Django**, conforme a decisão arquitetural integrada no PR #42, sem ativação conectada: verificar seleção `trusted_proxy` em contexto sintético, `is_secure()` e redirects, `get_host()` e host inesperado, `USE_X_FORWARDED_HOST=False`, origem/CSRF, cookies seguros e permanência de bloqueios HTTP 423. Reutilizar configurações, testes e componentes existentes. Um despacho ao Codex deve abranger implementação, regressão offline e publicação em branch de revisão, sem autorizar merge ou execução conectada implicitamente.

## 6. Prompt mínimo de retomada (referências obrigatórias)

> Retomar OES a partir do CP349. Aplicar Freshness Gate na `main` remota, ler `STATE.md`, `archive/handoffs/oes/README.md` e `archive/handoffs/oes/OES_Continuidade_2026-11-17_CP349.md`. **Ler e aplicar expressamente os três documentos canônicos de trabalho:** (1) `docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md` (proporcionalidade), (2) `docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md` (responsabilidades, publicação, contraditório) e (3) `AGENTS.md` (autonomia Codex). Consultar contrato P2 v2 e decisão HTTPS do PR #42. Preservar todos os gates e limites. Não reabrir diagnóstico do sandbox sem fato novo. Prioridade: testes offline consolidados de HTTPS/Host/CSRF; não iniciar operações conectadas. Coordenar continuidade diretamente pelo ChatGPT quando suficiente, sem Codex obrigatório para documentação. Registrar decisões materiais apenas, sem microgates.
