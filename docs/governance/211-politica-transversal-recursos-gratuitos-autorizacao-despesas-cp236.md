# Documento 211 — Política transversal de recursos gratuitos e autorização de despesas (CP236)

**OES | 2026-10-22 | PROJECT_WIDE_FREE_TIER_POLICY_ADOPTED | TECHNICAL_GATES_PRESERVED**

## 1. Decisão e precedência

Após manifestação expressa do proprietário questionando a restrição a três consultas, uma chamada por operação e o caráter exclusivamente P1 da política financeira, e subsequente **`Prossiga` dirigido à formalização da política transversal**, adota-se prospectivamente, para todo o OES, a regra de que **a utilização ordinária de recursos e quotas disponíveis em planos gratuitos de serviços previamente autorizados não exige autorização financeira por chamada, execução, minuto de computação ou unidade consumida**. Esta regra não equivale a aprovação técnica irrestrita, nem autoriza executar etapas ainda sujeitas a aprovação específica.

A política aplica-se a serviços gratuitos previamente autorizados no projeto, como Neon Free e GitHub Actions, observados seus limites, termos, finalidade aprovada e risco efetivo. Não autoriza conexão, cadastro ou ativação de um novo serviço sem avaliação pertinente, nem contorna a governança técnica, científica e de segurança.

Esta norma tem **precedência prospectiva apenas no controle financeiro e na granularidade excessiva de consultas de baixo risco** sobre restrições dos Documentos 208–210. Mantêm-se íntegros os documentos históricos, os demais controles de segurança, gates, BRGs, contratos e os registros de autorização.

## 2. Regras financeiras

1. Permitir consumo ordinário dentro dos limites gratuitos dos serviços já habilitados e do escopo técnico autorizado, **sem autorização por consulta, repetição legítima, execução de CI ou unidade de recurso**.
2. Acompanhar consumo/quotas proporcionalmente, por checkpoint técnico relevante, alerta do provedor ou proximidade material do limite; não exigir certificados de custo zero por requisição GET.
3. Diante de limite gratuito próximo, avaliar reduzir ou adiar atividades, reutilizar evidências e otimizar recursos; diante de limite atingido, interromper atividades afetadas, sem contratar automaticamente.
4. **Exigir autorização expressa e específica do proprietário antes de upgrade, contratação, inclusão de cartão/meio de pagamento, aceitação de cobrança ou serviço pago.** Nenhuma exceção automática, ainda que teste esteja bloqueado.
5. Não presumir que ausência de cartão elimina toda obrigação possível: preservar atenção a avisos contratuais e riscos concretos. Limites anunciados variam; tomar os valores vigentes do provedor e condições de conta como contexto, não como autorização para despesa.
6. Evidências financeiras históricas não precisam ser reconfirmadas a cada consulta quando não houver indício material de mudança; eventuais riscos ou mudanças relevantes exigem nova deliberação.

## 3. Política de consultas e operações técnicas

**Leitura administrativa** em serviço previamente autorizado pode ser realizada e repetida conforme necessidade comprovável da atividade técnica autorizada, respeitando finalidade, minimização de dados, identidade do projeto e rate limits; proibir repetição descontrolada, varredura ampla não justificada, divulgação de segredos e uso de credenciais fora do escopo. A natureza somente leitura e o enquadramento em Free **não dispensam** aprovação técnica que tenha sido expressamente exigida por gate vigente.

**Testes sintéticos** em recursos Free são financeiramente permitidos quando a atividade de teste estiver tecnicamente aprovada e delimitada. SQL, escrita persistente, criação/destruição de objetos, papéis/ACL, alteração de rede, segredos, dados reais, alterações científicas e promoção de gates continuam submetidos aos requisitos técnicos e científicos correspondentes. A política não dá permissão geral de SQL, DDL, DML ou CI em qualquer fase.

**Autorização e execução:** manter decisões separadas para intervenções que introduzam risco substantivo; dispensar pedidos repetidos cujo único fundamento seja consumo gratuito ordinário ou número arbitrário de chamadas. Corrigir propostas pontuais antigas que pretendam transformar `uma chamada por operação` em limite universal. Mesmo em leituras, respeitar critérios de STOP por desvio de alvo, informações sensíveis ou comportamento inesperado.

## 4. Efeito sobre A2-G2/P1 e fases posteriores

A restrição proposta nos Docs 209–210 a **três operações e uma chamada por operação** era uma allowlist pontual conservadora do preflight, **não uma regra geral do OES**. A futura autorização P1 deve ser reavaliada com base em **escopo técnico legítimo, proporcionalidade e segurança**, sem tratar três chamadas ou uma execução como tetos financeiros. Novas consultas de metadados pertinentes exigem justificativa técnica e proteção de informações, não uma autorização financeira autônoma por GET.

**Situação jurídica/técnica deste checkpoint:** A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED` somente arquitetura; **P1 `NOT_AUTHORIZED` até decisão técnica expressa**, P2 `NOT_AUTHORIZED`, A2-G2/E `NOT_AUTHORIZED`, T2-A2 `NOT_AUTHORIZED`. A norma transversal **não constitui a aprovação operacional de P1**: a decisão pontual ainda deve ser formulada, considerando a política, e expressamente aprovada quando exigida pelo escopo atual. P2 e E não são promovidos automaticamente.

## 5. Evidências e preservações

O proprietário relatou para seu Neon Free 1 GB de storage/projeto, até 2 CU, 100 CU-horas mensais/projeto, 10 branches e ausência de cartão. São declarações de contexto operacional e referências de plano, **não verificação administrativa contemporânea da conta**. Proibição de qualquer serviço pago continua absoluta sem aprovação.

N1-E3 comprovou TLS cliente→endpoint Psycopg `verify-full`, mas `pg_stat_ssl.ssl=false` no backend e segurança de segmentos internos não comprovada; `oes_t2a2_runtime` possui privilégios excessivos e não deve ser usado; `oes-sandbox` permanece fora do escopo da prototipação. F01–F07 somente endereçados documentalmente, L1–L4 condicionantes, O-01–O-10 não executados. T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 PASS históricos); T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 PASS históricos). Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrações `UNREVIEWED`. D0 concluída documentalmente → D1 sintético prioritário → D2 factual futuro → governança operacional futura.

**Próximo passo sob `Prossiga`:** revisão documental da proposta de autorização técnica P1 à luz da norma transversal, removendo limites arbitrários de número de consultas sem autorizar execução, SQL, Neon, CI ou outras operações; submeter decisão expressa pertinente. **STOP.**
