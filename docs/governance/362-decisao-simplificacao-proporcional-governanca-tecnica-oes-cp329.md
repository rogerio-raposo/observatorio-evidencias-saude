# OES — Documento 362 | Decisão de governança técnica proporcional ao risco

**Data:** 2026-10-28 (America/Recife)  
**Estado:** APROVADO pelo responsável — `APPROVED — OES / SIMPLIFICACAO_PROPORCIONAL_GOVERNANCA_TECNICA`  
**Natureza:** decisão canônica de priorização e proporcionalidade. **Não é autorização operacional conectada.**  
**Origem:** revisão crítica de entraves após CP328 e validação A41.

## 1. Decisão e fundamento
Fica aprovada a reorientação do OES para desenvolvimento e validação proporcionais ao risco, priorizando resultados funcionais demonstráveis. O aprofundamento de PF-I04/P4 como experimento **autônomo** de administração de roles PostgreSQL fica **suspenso/deferido**, sem declará-lo tecnicamente completo nem apagar limitações da evidência. O teste A41 no PostgreSQL 18 descartável concluiu circuito sintético PASS (run GitHub Actions 40631160589); não valida automaticamente permissões reais no Neon ou a integração Django.

As evidências A37–A41 permanecem imutáveis nos caminhos canônicos históricos. A42 teve desenvolvimento **apenas local e documental** de três versões de consulta catalogal e um parecer, sem execução no Neon e sem autorização de uso operacional; conservar o inventário de hashes e, quando viável, arquivar cópias byte-idênticas. A exigência, na variante A42 v3, de validade de senha coincidente a um segundo exato é **histórica e não constitui requisito normativo futuro**. Não há obrigação de continuar v4, P4-A43 ou reprodução integral A41 no Neon sem nova justificativa funcional.

## 2. Matriz de proporcionalidade
| Categoria | Exemplos | Regime-alvo aprovado |
| --- | --- | --- |
| Baixo risco | Leitura de arquivos/repositório, metadados administrativos não secretos, análise estática, testes locais isolados | Executar no escopo e nos limites já concedidos, sem solicitar novo gate por microatividade; para SQL catalogal Neon, aprovar previamente **escopo limitado** (projeto/branch/banco, identidade, finalidades e classes de consulta). |
| Moderado | Procedimento sintético e reversível no Neon com `CREATE/GRANT/REVOKE/SET ROLE`, migrations controladas | Uma autorização expressa por **procedimento integrado**, contendo pré-condições, efeitos previstos, plano de recuperação e verificação final. Não fragmentar em gates por linha SQL sem razão material. |
| Alto risco | Produção, uso de dados pessoais/sensíveis, papéis privilegiados, mudanças irreversíveis, despesas, publicação científica, transição de fase | Aprovação específica, segregação de responsabilidades e evidências rigorosas apropriadas ao risco. |

Critérios de escalonamento: privilégio efetivo, impacto em ambientes compartilhados, sensibilidade e persistência dos dados, irreversibilidade, exposição externa, custos e impacto científico. Dados científicos de origem pública **não** tornam públicas as credenciais, configurações ou informações administrativas do projeto.

**Regra de transição:** a matriz define a política para futuras propostas de autorização. Ela **não concede automaticamente** novos privilégios de execução no Neon. Todos os HARD HOLD preexistentes permanecem até decisão expressa e específica de escopo, inclusive SELECT conectado, quando seu gate anterior assim exigir.

## 3. Credenciais sintéticas
Usar identidade de teste de menor privilégio, separada dos papéis administrativos; nenhuma senha no chat, repositório, commits, logs ou documentação. Um login sintético pode servir a uma **unidade de trabalho aprovada** em vez de exigir uma senha nova a cada instrução. Adotar prazo máximo razoável e desativação/revogação ao encerrar a unidade de trabalho, com verificação proporcional. A correspondência exata ao segundo do `rolvaliduntil` histórico não é exigência geral, e expiração da senha não substitui revogação de acessos. Não renovar, alterar, desativar ou excluir `oes_p4_trial_login` sem autorização própria. Não usar `oes_sandbox_owner` como credencial descartável de workflows.

## 4. Priorização técnica
1. Reaproveitar as evidências PG18 A41 para evitar retestes do mesmo mecanismo sem hipótese nova.
2. Inventariar, preferencialmente em revisão offline, **quais privilégios a aplicação Django realmente necessita** e quais lacunas impedem o demonstrador.
3. Desenhar o menor teste integrado Django–PostgreSQL com dados sintéticos, saída verificável e controles proporcionais, submetendo qualquer SQL conectado/mutação/segredo a autorização efetiva do escopo.
4. Entregar evidência funcional verificável: consulta/apresentação de objetos do demonstrador e limitações; sem captura factual ou usuários reais enquanto os gates gerais estiverem fechados.
5. Evitar novos documentos intermediários, verificadores redundantes e checkpoints por microatividade; publicar apenas por marco/risco.

## 5. Preservação dos controles essenciais
- Rastreabilidade/proveniência, revisão científica e integridade metodológica permanecem intactas.
- GitHub `main` continua fonte persistente; Freshness Gate no início de blocos e antes de publicação; checkpoints por mudança material e risco (faixa 3–5 atividades deixa de ser contagem compulsória).
- `Prossiga` continua significando **uma atividade delimitada**, jamais aprovação implícita de gastos, SQL mutante ou atividade conectada bloqueada.
- Preservar A32/A35 `if:false`, nenhuma ativação de workflow, nenhuma modificação retroativa de SQL A37–A41 e nenhuma promoção científica decorrente de testes sintéticos.
- Estados preservados: Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Marco B `OPEN`; G2-P2B `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; PF-I04/P4 operacional `NOT_AUTHORIZED`; Fase 5 `NOT_STARTED`.

## 6. Alcance exato da aprovação e ponto seguinte
A autorização recebida compreende **exclusivamente a formalização documental** desta decisão e um checkpoint de continuidade. Não autoriza SQL Neon (inclusive SELECT anteriormente bloqueado), alterações de roles/grants/credenciais, secrets, workflows conectados, deploy, coleta factual, dados reais ou serviços pagos.

O passo seguinte, mediante novo `Prossiga` após o checkpoint, é uma **análise offline orientada à funcionalidade Django–PostgreSQL** que reutilize os diagnósticos e artefatos existentes e identifique o teste integrado mínimo. Não se deve iniciar automaticamente P4-A43.
