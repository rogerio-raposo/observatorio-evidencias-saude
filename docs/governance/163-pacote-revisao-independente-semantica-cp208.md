# 163 — Pacote de encaminhamento para revisão independente SEM-01–SEM-06 (CP208)

**OES | 2026-10-20 | Fase 4 | modo médio | DRAFT_ONLY**
**Autoridade:** `PREPARE_G1_DOCUMENTARY_ONLY`. Nenhum novo gate, parecer, deliberação ou autorização.

## 1. Proveniência e escopo
Consolida três atividades pós-CP207: A1 estrutura do pacote documental para revisão independente; A2 correspondência com governança preexistente; A3 inventário de lacunas. Base: Documentos 159, 161, 162, `STATE.md` e ponteiro CP207; fontes técnicas 033c–035 referenciadas no Documento 162. Freshness Gate inicial: `main` idêntica a CP207 `f75d383770f02e3e767a46b9a9a5b29b181eddf8`. Não foi realizada auditoria exaustiva de todo o acervo histórico.

## 2. Índice do pacote futuro
| Parte | Elementos | Condição atual |
|---|---|---|
| I — Contexto | objetivo, fase e autoridade documental | disponível parcialmente |
| II — Contratos | SEM-01–SEM-06, alternativas e perguntas | organizado no Documento 162 |
| III — Fundamentação | fontes 033c–035 e riscos de concorrência | disponível para exame documental, sem testes |
| IV — Avaliação | critérios, instrumentos de parecer e independência | estrutura proposta; sem pareceres |
| V — Deliberação | competência, registro decisório e autorização separada | não executada, governança pendente |

A revisão científico-metodológica é especialmente relevante para SEM-01–04 e para SEM-05/06 se houver impacto científico; a revisão técnica é proposta para SEM-01–06. A instância competente precisa ser confirmada pela governança, não criada por este documento.

## 3. Alinhamento com controles canônicos
PR-01 escopo remete a SEM e AUT-01; PR-02 fontes a rastreabilidade/AUT-03; PR-03 neutralidade preserva alternativas não escolhidas; PR-04 competências depende dos papéis autorizados; PR-05 parecer rastreável reutiliza critérios de evidência/AUT-07; PR-06 autoridade permanece subordinado a AUT-08 e às aprovações canônicas. PR-01–PR-06 e AUT-01–AUT-08 **não** instituem portas paralelas nem promovem BRG. Revisão independente não substitui deliberação e deliberação contratual não autoriza automaticamente implantação.

## 4. Inventário de lacunas REV — auxiliar, não normativo
| ID | Lacuna | Estado de preparação |
|---|---|---|
| REV-01 | identificação de revisores | NOT_COLLECTED |
| REV-02 | competência comprovada | NOT_COLLECTED |
| REV-03 | independência e conflitos de interesse | NOT_COLLECTED |
| REV-04 | competência formal deliberativa | PENDING_GOVERNANCE |
| REV-05 | baseline fechada do pacote efetivamente submetido | TO_PREPARE |
| REV-06 | formulário de parecer definitivo | PROPOSED |
| REV-07 | suficiência de critérios por especialidade | PARTIAL |
| REV-08 | procedimento de tratamento de recomendações | TO_SPECIFY |
| REV-09 | decisão e eventual autorização posterior | NOT_PERFORMED |

Esses rótulos são auxiliares, não estados oficiais do catálogo ou de gates. Não inventar nomes, vínculos, credenciais, declarações, datas, pareceres ou decisões.

## 5. Campos candidatos de parecer
`contract_id`, `review_domain`, `reviewer_role`, `reviewed_baseline`, `assessment`, `identified_risks`, `required_changes`, `supporting_references`, `review_date`, `independence_declaration`. O resultado deve indicar o alcance efetivo da revisão e ressalvas, evitando equiparar ausência de objeção a aprovação integral. Nenhum campo factual foi preenchido.

## 6. Fronteira de responsabilidade
- Preparação documental: delimitar pacote, índices, evidências e perfis, nos limites autorizados.
- Revisão independente futura: qualificação de pessoas reais, independência e pareceres assinados/fundamentados.
- Deliberação futura: decisão expressa pela autoridade canônica competente, sem delegação implícita a pareceristas.
- Operação futura: autorização adicional específica após gates, revisão técnica e condições de segurança.

## 7. Critérios mínimos de encaminhamento para revisão
Identidade inequívoca dos objetos; baseline verificável; alternativas neutras; escopo e perfil de revisão; formulário rastreável; procedimento de encaminhamento à autoridade competente. Satisfazer esses itens significa apenas preparação documental, nunca `READY` operacional.

## 8. Bloqueios e retomada
36 migrations `UNREVIEWED`; 0 pós-condições aprovadas; 36 requisitos 034–036 `NOT_COLLECTED`; 12 controles de papéis pendentes; BRG-03/06/07/08 `BLOCKED`, 04/05 históricos, 09 parcial; B1R1 `EXPIRED_NOT_EXECUTED`, M3 bloqueado; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. Nenhum SQL, Neon, CI, execução, fonte científica factual, epoch ou serviço pago.

**Próximo Prossiga:** nova A1, revisar somente suficiência e proporcionalidade do pacote de revisão especializada SEM-01–06 diante das dependências científico-funcionais já mapeadas; evitar convite ou parecer presumido. Modo médio; alto antes de decisão substantiva. STOP.
