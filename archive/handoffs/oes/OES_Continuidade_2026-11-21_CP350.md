# OES — CP350 | Continuidade após encerramento técnico M3-C

**Data:** 2026-11-21 (America/Recife). **Origem documental:** branch de revisão `review/oes-m3c-closure-cp350-20261121`; verificar integração por meio do [PR #49](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/49).  
**Fonte canônica:** `main`, SHA de base `6029b39a71f7aa1cce1af6e137a34a5fde686ef7`, a reconfirmar com Freshness Gate na retomada.  
**Registro detalhado:** [Encerramento M3-C](../../../docs/governance/OES_M3C_ENCERRAMENTO_TECNICO_2026-11-21.md). 

## Marco técnico

M3-C privada sintética teve execução **SUCCESS / PERSISTED / Q0_RECORDS** em 21/11/2026: login Django do preparador, autorização funcional GET, uma única gravação Q0, recibo, cinco registros vinculados, D3 e consulta GET posterior por referência. Registros `OES-M3C-20261118-R01` / `OES-M3C-20261118-Q01`, commit observado no Neon em `2026-11-21T13:30:16.169Z`; contagens científicas 6/6/2/2/2 antes e 7/7/3/3/3 depois (entity/entity_version/question/question_version/receipt). A confirmação direta de banco foi limitada aos objetos e invariantes da tentativa, não a toda a base.

A reautenticação resolveu erro de autorização da primeira consulta GET; causa precisa não demonstrada. Exceção `OES_CODESPACES_CSRF_LOCALHOST_ORIGIN=1` do PR #48 usada somente no experimento Codespaces Private, com risco de origem reescrita explicitamente aceito. Após a consulta, o operador confirmou logout, Gunicorn encerrado e ambos os terminais em `RELEASE_MODE=HOLD`, `CSRF_LOCALHOST_ORIGIN=0`. Ausência universal de listeners/revogação administrativa não atestada no encerramento.

## Recuperação e custódia

Neon: projeto `weathered-boat-65779510`; origem `br-gentle-hall-b6jaxehf`, `oes_sandbox`; branch de segurança `br-silent-dream-b6mvn50u` (cópia anterior à senha redefinida e à tentativa Q0). **Preservar** branch e registros, sem restauração, descarte ou repetição de submissão; backup restaurável, RPO e RTO não garantidos. Registro de senha/hash não faz parte do checkpoint.

## Governança e próximos passos

**Gates:** Marco B OPEN; Q0 geral HARD HOLD; Q1 conectado HOLD; E9 NO-GO; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED. O êxito M3-C não é homologação de produção nem resultado científico.

**Forma de trabalho:** [Documento 362](../../../docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md), [Estratégia ChatGPT–Codex–GitHub](../../../docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md), [AGENTS.md](../../../AGENTS.md). ChatGPT coordena/revisa/documenta; Codex desenvolve/testa sob despacho, GitHub main é canônico. Não introduzir microgates, não repetir preflights já conclusivos; contraditório técnico fundamentado e Freshness Gate obrigatórios.

**Próxima atividade recomendada:** reavaliar macroatividades funcionais do piloto, sobretudo demonstração de perfis de acesso, sem reviver o problema de ingresso Codespaces. Não alterar infraestrutura ou grants apenas para demonstrar perfis sem motivação.

## Retomada em nova conversa

1. Ler `archive/handoffs/oes/README.md`, este CP350, o registro de encerramento M3-C, Documento 362, estratégia e `AGENTS.md`.
2. Aplicar Freshness Gate à `main` e conferir a integração do PR #49 e o estado da branch documental `review/oes-m3c-closure-cp350-20261121`.
3. Preservar todos os gates, a branch de segurança e a ausência de nova submissão Q0; decidir prioridades funcionais após persistência.
