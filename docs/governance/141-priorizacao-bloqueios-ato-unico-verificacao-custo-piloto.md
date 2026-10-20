# 141 — Priorização proporcional de bloqueios e ato único de verificação de custo do piloto P-B

**OES | 20/10/2026 | CP185 | modo médio**  
**Natureza:** avaliação documental e definição de um próximo ato de baixo risco.  
**Resultado:** `NEXT_ACTION_SELECTED_OWNER_BILLING_READ_ONLY_PENDING`, sem operação, decisão de custo, ou promoção de gate.

## 1. Continuidade e evidências

Freshness Gate CP184/main: `c657e6ec1f5d2542ed828d35922046cc52b5d9bf`, identical, zero ahead/behind; template canônico, ponteiro CP184, handoff integral, Docs 135/139/140, STATE e CHANGELOG conferidos. O modo médio é suficiente para esta priorização. O usuário disse `Prossiga`, mas **não aprovou G0-D1–D6**, risco, orçamento nem ações Neon.

O produto P-B preservado é um novo experimento prospectivo **factual persistente** de primeiras medições PubMed e ClinicalTrials.gov, não a reativação da instância temporal B1R1. O sandbox Neon Free tem SELECT histórico, mas não prontidão operacional.

## 2. Escolha de um único ato de menor risco

**Ato candidato único:** pedir ao **titular** uma **conferência humana de leitura, sem alterações**, no próprio painel Neon, das informações referentes ao projeto `oes-sandbox`:

- Plano vigente e se há algum recurso, upgrade ou opção paga ativada.
- Uso/quota de armazenamento, compute e limites exibidos pelo provedor; condições de suspensão, interrupção e estouro de cota.
- Existência ou não de método de pagamento associado, alertas/avisos de consumo e regras de cobrança aplicáveis.
- Data/hora factual da leitura, fontes de tela ou documentos oficiais consultados; registrar apenas um resumo **não sensível**, evitando captura ou divulgação de dados pessoais, credenciais, tokens e informações de cobrança identificáveis.

**Saída proposta:** declaração concisa do titular contendo `plan_verified`, `free_limits_reviewed`, `billing_exposure_reviewed`, `payment_method_presence_relevant_to_budget`, `quota_risk`, `verified_at`, `notes`, com cada campo como **observado/não verificado**. Registrar apenas evidência fornecida voluntariamente e aprovada para publicação no repositório. Não inferir ausência de custo nem inventar números.

**IMPORTANTE:** esta é somente uma recomendação para o **próximo checkpoint**, não ação já realizada. O assistente não abriu painel Neon, não fez query de API/SQL e não alterou configurações. Uma verificação do titular não equivale a **autorizar pagamento, mudar plano, processar dados factuais ou liberar BRG-09**: o gate exige decisão posterior conforme sua política.

## 3. Justificativa da escolha contra alternativas

| Candidato | Benefício decisório imediato | Risco e custo da prova | Decisão CP185 |
|---|---|---|---|
| Conferência read-only de plano/cotas/cobrança pelo titular | Identifica possibilidade real de manter piloto estritamente gratuito e permite avaliar G0-D5 | Baixo; sem SQL, credenciais ou contratação | **SELECIONADO para próximo ato, não executado** |
| Nova rodada PG18/CI de roles ou migrations | Não resolve desconhecimento de custo nem autoridade factual Neon; repetiria provas históricas | Trabalho relevante, pouco benefício adicional agora | DEFERRED_WITH_BLOCKER_PRESERVED |
| Criar branch/role/schema no Neon | Adiantaria técnica sem G0-D1–D6 e provas de backup/segurança | Mutação persistente e quota, não autorizadas | BLOCKED |
| Novo epoch/preflight/primeira query | Aproxima observação empírica, mas readiness ODB/BRG e autoridade ausentes | Pode produzir evidência factual irreversível | BLOCKED |
| Escolher backup externo/provedor pago | Pode ajudar BRG-08, mas demanda custódia, titular, custo e restore | Custo/risco não autorizados | DEFERRED_WITH_BLOCKER_PRESERVED |
| Concluir G0 por `Prossiga` genérico | Nenhum consentimento válido | Fabricaria decisão do titular | PROHIBITED |

Ato selecionado conforme proporcionalidade do Documento 135: decisão concreta `custo zero/risco de quota`; lacuna `BRG-09`; oráculo `informação identificável, datada e atribuída ao owner`; alternativa menos arriscada do que executar SQL; critério de parada se painel exigir contratação/cadastro de cartão/alteração de configuração. Sem resultado factual, continuar `PENDING_OWNER`.

## 4. Checklist textual proposto ao titular (para uso futuro)

```text
OES / CP185 — Neon Free plan and billing verification (READ-ONLY)
Projeto: oes-sandbox (confirmado pelo titular, sem credenciais)
Verificação em: [data e hora local]
Plano atual (observado/não verificado): [...]
Crédito/cartão/pagamento / exposição de cobrança (sem dados pessoais): [...]
Limites Free e uso atual visíveis no painel: [...]
Avisos de suspensão/quotas/upgrade automático: [...]
Alteração de plano/recurso feita? NÃO — confirmação factual pelo titular
Material de evidência publicável: somente resumo não sensível autorizado
Pendências: [...]
Conclusão: VERIFIED_INFORMATION_ONLY / INSUFFICIENT_INFORMATION
Nota: NÃO autoriza gasto, Neon write, G0 approval, novo Epoch ou fontes reais.
```

Nenhuma entrada foi preenchida neste CP. Na futura coleta do titular, não solicitar imagem que exponha dados bancários; preferir valores resumidos e redigidos manualmente. As informações podem mudar e devem ser revalidadas no momento das operações.

## 5. Gates imutáveis e dois eixos do projeto

**Empírico:** BRG-09 ainda PENDING_OWNER. BRG-03/06/07/08 permanecem bloqueados; BRG-04/05 só provas sintéticas históricas. ODB-01–12 não passaram para execução factual. **36 migrations UNREVIEWED**, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles de roles insatisfeitos. B1R1 `EXPIRED_NOT_EXECUTED`, `NEW_EPOCH=NOT_AUTHORIZED`, Neon `SYNTHETIC_ONLY`.

**Científico-funcional:** Documento 138 especificou runbook R0–R8 e AT-01–AT-12 sem qualquer cenário integrado executado e sem revisão científica independente. G1–G6 remanescentes e `PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY` continuam visíveis; M3 bloqueado e Fase 5 não iniciada.

Nenhum ato no Neon, GitHub Actions, PostgreSQL, PubMed ou ClinicalTrials.gov foi executado neste checkpoint. Nenhum serviço pago foi selecionado.

## 6. Retomada

**CP186 candidato, condicionado a novo `Prossiga`:** apresentar ao titular o checklist mínimo de observações de custo/quotas da console Neon e, somente com dados factuais compartilhados, avaliar se G0-D5 pode ser submetido a decisão em modo alto. Se indisponíveis, registrar `INFORMATION_NOT_AVAILABLE`, sem repetir testes ou presumir aprovação.

Não avançar G1, não alterar Neon e não escolher novo epoch sem autoridade específica. Um novo `Prossiga` autoriza **um** checkpoint, não consentimento financeiro.

**STOP.**
