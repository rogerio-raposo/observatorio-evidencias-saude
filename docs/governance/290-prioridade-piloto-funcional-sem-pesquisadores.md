# Documento 290 — Prioridade funcional do piloto sem pesquisadores vinculados

**Data:** 2026-10-25  
**Natureza:** decisão de priorização e delimitação documental, não autorização de operações conectadas.

## 1. Restrição presente

O OES **não dispõe atualmente de pesquisadores vinculados ao projeto** para avaliação científica independente ou teste externo especializado. Essa situação não bloqueia a continuidade de engenharia, modelagem funcional, testes sintéticos, rastreabilidade e apresentação documental. Tampouco autoriza substituir revisão especializada por validação técnica automatizada.

A avaliação externa por pesquisadores permanece **pendente e diferida até haver participantes apropriados**. Não supor prazo nem tratar essa etapa como encerrada.

## 2. Objetivo institucional preservado

O OES pretende identificar, avaliar criticamente, sintetizar, atualizar e comunicar evidências em saúde com transparência e rastreabilidade. O **piloto técnico** não deve se confundir com execução científica autônoma de todas essas etapas. Mantém-se o princípio metodologia antes da automação e as fronteiras de autoridade e de certeza previstas nas políticas canônicas.

## 3. Reavaliação das macroatividades

| Capacidade | Evidência atual | Prioridade |
|---|---|---|
| Catálogo, detalhe e limites documentais | Django encerrado restritamente, Documento 289, 50/50 Django e 9/9 Chromium PASS | Mantida/concluída restritamente |
| Identidade Study–Report sem dupla contagem | Fixtures e contratos Django documentados | Reutilizar, sem alegações novas |
| Proveniência, SHA-256 e preservação sintética | E6 offline 99/99 PASS | P1, compor |
| Identificação/conciliação e triagem preliminar | Contratos e exemplos parciais, não end-to-end demonstrado | P1, mapear e integrar o necessário |
| Visualização do percurso completo | Django documental ainda não consome fluxo ponta a ponta | P2, após P1 |
| Comprovação integrada automatizada | Componentes isolados validados; integração total não comprovada | P3, critérios de suficiência |
| Captura factual conectada | Autorizações e gates específicos ausentes para novo fluxo | Bloqueada |
| Avaliação crítica/síntese/alteração de conclusão | Metodologia existente, sem validação científica externa atual | Diferida, não automatizar autoridade |
| Stack definitiva, autenticação e operação | Requisitos pendentes e decisão de stack futura | Diferir de modo controlado conforme Docs. 287–288 |

## 4. Ordem dos incrementos

- **P1 — Integração sintética controlada:** mapear interfaces existentes e produzir a menor composição offline de um registro sintético de origem → preservação/proveniência → identidade/conciliação documental explicitamente sustentada → sinal/triagem *preliminar* → resultado rastreável. **Primeira atividade: inventário de interfaces/contratos existentes**, sem escrever código antes do desenho proporcional. Não unir automaticamente observation_id PG-A4 com NCT nem inventar relação científica.
- **P2 — Apresentação integrada:** somente após P1, expor no Django percurso demonstrativo devidamente tipificado e com fronteiras de certeza explícitas; manter fixtures atuais e rotas salvo autorização separada.
- **P3 — Suficiência técnico-funcional:** testes automatizados, evidências reprodutíveis e mapa de lacunas/diferimentos; sem declarar prontidão operacional nem aceitação científica humana.

## 5. Guarda e limites

Documento 289 permanece encerramento exclusivamente restrito do Django documental. D2-I-C conectado permanece não demonstrado; lacuna ACL constatada em preflight Neon; não criar usuários/grants/workflows temporários por conveniência. Os Documentos 287/288 prevalecem para diferimento controlado. Nenhum factual GET, SQL conectado/escrita, mudanças Neon, credenciais, pagamentos, workflow habilitado, divulgação externa ou alteração automática de produto científico foi autorizado por este ato.

Fase 4 continua `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`; piloto integrado ainda aberto.

## 6. Próxima atividade

Executar inventário técnico-documental das interfaces já disponíveis entre E6, contratos sintéticos, domínio e serviços Django. Entregar mapa de composição mínima P1 com riscos e critérios de aceite, sem novas operações externas.
