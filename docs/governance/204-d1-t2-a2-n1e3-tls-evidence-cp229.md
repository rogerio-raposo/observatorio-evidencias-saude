# Documento 204 — N1-E3: evidências de autenticação e TLS externo (CP229)

**2026-10-22 | CLIENT_TLS_VERIFIED | BACKEND_SSL_FALSE_OBSERVED | T2-A2 NOT_AUTHORIZED**

## Identificadores e limites
Projeto Free `oes-d1-t2-a2-synthetic` (`tiny-pond-20086371`), branch `synthetic-main`, banco `oes_t2a2_synthetic`, role de aplicação `oes_t2a2_app`. Workflow manual `.github/workflows/oes-n1-e3-tls-readonly.yml`; GitHub `main` HEAD de evidência `36f519f795331ffd83d5ef574f3d188b4921f2ea`. Os Secrets de hostname/senha foram preenchidos manualmente, não lidos ou publicados. Papel anterior `oes_t2a2_runtime` permanece inadequado.

## Cinco execuções
| Execução GitHub Actions | Resultado | Evidência delimitada |
| --- | --- | --- |
| [39732456492](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39732456492) | FAIL | Host inválido/pooler rejeitado pela validação |
| [39734959697](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39734959697) | FAIL | Conexão ou consulta não discriminada |
| [39735977591](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39735977591) | FAIL | Classificação TLS_VERIFICATION |
| [39736779486](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39736779486) | FAIL | Após CA explícita, TLS_STATE_MISMATCH no backend |
| [39737616716](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39737616716) | **SUCCESS** | CLIENT_TLS_VERIFIED, identidade e banco confirmados; BACKEND_TLS_OBSERVATION: SSL_FALSE, BACKEND_VERSION_PRESENT=False, BACKEND_CIPHER_PRESENT=False |

## Interpretação
A quinta execução demonstrou conexão Psycopg com `sslmode=verify-full`, certificado-raiz do Ubuntu explicitamente fornecido, autenticação como `oes_t2a2_app`, banco esperado e única consulta de leitura bem-sucedida. A segurança TLS no trecho cliente↔endpoint Neon foi comprovada nos limites do cliente. A sessão observada por `pg_stat_ssl` retornou `ssl=false`, sem versão/cifra; isso é compatível com terminação TLS intermediária, **mas essa topologia e a proteção de segmentos internos não foram confirmadas**. Não transformar observação interna em evidência positiva de TLS end-to-end até o backend.

## Governança
N1-E3: `CLOSED_CLIENT_TLS_ONLY_WITH_BACKEND_OBSERVABILITY_LIMIT`. Não autoriza adaptação T2-A2, privilégios, GRANT/DDL/DML, migrações, conexões adicionais, novo workflow, produção, dados reais, CI para outros fins ou custos. T1 36 PASS históricos; T2-A1 75 PASS históricos. T2-A2 `NOT_AUTHORIZED`, Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`.

Próximo `Prossiga`: uma atividade documental para delimitar a próxima fronteira D1/T2-A2, sem execução nem mudança de gates. STOP.
