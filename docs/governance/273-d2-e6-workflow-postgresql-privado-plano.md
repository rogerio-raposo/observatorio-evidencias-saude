# Documento 273 — Plano mínimo para workflow E6 com persistência privada PostgreSQL

**OES | 2026-10-24 | CP274 | Base 3e2a76c7b7d184ea3025469448da599b7876b25e | PROPOSTA DOCUMENTAL — NÃO AUTORIZA EXECUÇÃO**

## 1. Diagnóstico do código existente

O workflow `.github/workflows/d2-e6-a2-gated-capture.yml` mantém `if: ${{ false }}` e executaria `e6_capture.py --connected`, seguido de `--verify-upload` e `actions/upload-artifact@v4` do pacote contendo `response.raw.json`. **O transporte via artifact é incompatível com a política vigente do Documento 269** (nenhum JSON original disponível publicamente). A CI anterior 39/39 PASS valida somente a arquitetura de artifact, não a persistência PostgreSQL.

O capturador atual já implementa limite 2 MB, GET único, `HOLD` estrutural, preservação de bytes e manifesto com proveniência; é preferível **reutilizar** essas funções e substituir apenas o destino, não duplicar a lógica de captura. A tabela privada `oes_raw_private.source_observation` existe na branch sintética, vazia, conforme Documento 271.

## 2. Fluxo proposto (não implementado)

1. Preflight de versão do código, autorização executiva específica e acesso privado à branch aprovada.
2. Um único GET autorizado, com os limites já definidos; aplicar `HOLD` e validar bytes, tamanho, NCT IDs e proveniência antes de qualquer INSERT.
3. Calcular SHA-256 dos bytes originais; executar INSERT parametrizado com `bytea` e metadados na tabela privada **sob identidade de inserção de menor privilégio**, dentro de transação com `COMMIT` somente após validação.
4. Confirmar integridade e recuperabilidade usando caminho de leitura restrito e autenticado, sem imprimir JSON em logs. Se não puder verificar leitura sem ampliar privilégios indevidamente, falhar fechado e não executar GET até resolver o desenho.
5. Publicar apenas resultado técnico sanitizado: identificador da observação, status, hash, contagem de registros, revisão `GITHUB_SHA` e identificador de execução. Nunca imprimir, versionar ou carregar JSON bruto em artifact público.

**Diferença decisiva:** `--verify-upload` não deve ser reaproveitado semanticamente como autorização para upload; substituir por verificação proporcional **antes e depois da persistência privada**. Nenhum dado bruto no stdout/stderr.

## 3. Dependência bloqueante: identidade operacional

Os papéis `oes_e6_writer` e `oes_e6_verifier` são `NOLOGIN`. Os testes por `SET LOCAL ROLE` passaram com associação temporária **já revogada**, mas isso não constitui credencial de execução do GitHub Actions. A conta proprietária `oes_sandbox_owner` **não deve** ser disponibilizada como credencial da captura, sob pena de anular o isolamento.

Antes de qualquer integração conectada, apresentar decisão específica de autenticação de mínima permissão: conta técnica com LOGIN sem acesso administrativo e concessões restritas aos comandos necessários (ou alternativa autenticada equivalente). Avaliar capacidade do Neon Free, rotação, gestão de segredo mascarado, branch/DB rigidamente fixados, duração de uso, revogação e teste negativo de acesso. **Não criar login/senha/secret nesta fase documental.**

## 4. Testes exigidos antes da primeira consulta factual

- Testes offline com adaptador PostgreSQL simulado: preservação exata do byte stream, SHA calculado, parâmetros SQL, falha transacional, `HOLD`, ausência de payload em output e não execução de upload.
- Testes sintéticos conectados na branch experimental, com identidade mínima efetiva; gravação, recuperação privada e comparação de SHA, rollback, duplicidade, rejeição >2 MB, recusa de SELECT ao writer e INSERT ao verifier. Preservar fixtures PG-A4.
- Confirmação do bloqueio `if: ${{ false }}` durante as alterações e testes. Separar autorização do código sintético, concessão de credenciais, e a autorização executiva **factual** E6-G1.

## 5. Restrições de arquitetura e retenção

A escolha de `bytea` no PostgreSQL é **exclusiva do piloto**. `observation_id`, hash e proveniência devem permanecer independentes do armazenamento físico, permitindo migração futura para object storage privado sem criar abstração prematura. O JSON original deve permanecer privado até validação e encerramento documental do ensaio e deliberação posterior sobre retenção. Não existe prazo universal aprovado.

**Resultado: `PRIVATE_WORKFLOW_DESIGN_PREPARED / MIN_PRIVILEGE_RUNTIME_IDENTITY_PENDING / CODE_CHANGE_NOT_APPROVED / FACTUAL_GET_BLOCKED`.**

**STOP — submeter identidade operacional e implementação sintética para autorização separada.**
