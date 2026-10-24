# Documento 265 — PG-A4-G3: avaliação de aceite proporcional

**OES | 2026-10-24 | Fonte CP272 e Documento 262 | HEAD avaliado `06910d3af6dce4e69b4bd7ab9c67305b4a2bcc71` | G2_B_RELATIONAL_PASS / G3_ASSESSED_WITH_LIMITED_PENDING**

## 1. Evidência verificável
- Workflow Django offline `oes-django-vertical-slice-validation.yml`, [run 40102803355](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40102803355): **32/32 PASS**, incluindo testes simulados de projeção e leitor desativado.
- Workflow conectado manual `oes-pg-a4-connected-smoke.yml`, [run 40104902381](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40104902381): **PASS** inicialização e consulta Django com retorno vazio, identidade `oes_pg_a4_reader` e sessão read-only.
- Workflow conectado manual [run 40110909348](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40110909348), HEAD `06910d3af6dce4e69b4bd7ab9c67305b4a2bcc71`, conclusão **success**: logs confirmaram `PASS PG_A4_DJANGO_CONFIG_PREFLIGHT_NO_CONNECTION` e `PASS PG_A4_G2_B_DJANGO_CONNECTED_THREE_LINKS_ONE_PROVENANCE`. Validou 3 pares N:M, versões e 1 proveniência sintética, sem presumir reconciliação científica. Fixture previamente inserida na branch sintética.
- Usuário declarou ter rotacionado a senha temporária de `oes_pg_a4_reader` e excluído o GitHub Actions secret `OES_PG_A4_PASSWORD` após a última execução. **Não tratar declaração como auditoria independente.** Nenhum segredo copiado aos documentos.

## 2. Matriz G3 segundo Documento 262
| Critério | Evidência | Julgamento |
| --- | --- | --- |
| Configuração opt-in e preservação JSON | Código Django e CI offline de 32 testes | PASS no escopo testado |
| Consulta como papel SELECT restrito | PG-A4-G0 permissões auditadas; G2-A/B autenticação real, `transaction_read_only=on` | PASS limitado; ausência de escrita demonstrada por privilégios e configuração, não teste de tentativa de DML pelo Django |
| Projeção Study–Report N:M e proveniência | Run 40110909348, 3 vínculos exatos, 1 proveniência artificial | PASS |
| Cardinalidade, versões e marcação sintética | Assertivas explícitas do script e SQL de leitura | PASS na fixture limitada |
| Conexão desativada | Teste `test_disabled_by_default` (CI offline) | PASS |
| Conexão indisponível / falha de autenticação | Nenhum teste Django negativo dedicado, retries/timeouts não demonstrados | **PENDENTE** |
| Credencial e rastreabilidade de branch | Branch `br-gentle-hall-b6jaxehf` e endpoint autorizado; secret temporário com declaração de rotação/exclusão | PASS delimitado, sem auditoria independente de remoção |
| Regressões Django existente | 32 testes offline PASS | PASS |
| Descarte/retenção dos dados artificiais | Fixture ainda persistida, usuário não autorizou remoção | **DECISÃO PENDENTE** |

## 3. Decisão técnica proporcional
**Não declarar PG-A4-G3 integralmente PASS ainda**: cenário de indisponibilidade/conexão recusada exigido no Documento 262 continua sem evidência própria. Isso pode ser suprido sem outra credencial temporária, por teste negativo isolado com mock do cursor ou exceção de conexão, preservando a distinção entre falha explícita e retorno vazio. Uma suíte de resiliência operacional ampla seria desproporcional ao piloto sintético.

**Próxima atividade recomendada:** adicionar teste offline dedicado a falha de conexão e comportamento explícito do serviço, executá-lo junto à suíte existente; depois reavaliar G3. O destino da fixture deve ser decidido separadamente: manter por ora, sem limpeza ou reinserção automáticas.

## 4. Limites
Nenhuma migração nova, dados factuais, publicação científica, reconciliação NCT, CI conectada adicional, secrets, produção ou Fase 5 autorizados por esta avaliação. Readiness `NOT_READY`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, D2 `PARTIAL`, E6-G1 `NOT_APPROVED`, migrations ainda `UNREVIEWED`, CP272 vigente. **STOP.**
