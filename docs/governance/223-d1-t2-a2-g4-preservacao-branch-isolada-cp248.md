# Documento 223 — OES/D1/T2-A2: preservação segregada do código A2-G4 em branch Git (CP248)

**2026-10-22 | CP248 DOCUMENTAL DE CONTINUIDADE | PRESERVATION_BRANCH_VERIFIED_SOURCE_NOT_VALIDATED | A2-G5/T2-A2 OPERATION NOT_AUTHORIZED**

## 1. Decisão e motivo do checkpoint extraordinário

O proprietário aprovou expressamente criar **uma branch isolada como solução permanente de preservação do código-fonte experimental** de D1/T2-A2, evitando dependência do armazenamento temporário de uma conversa. Esta decisão **não** aprova publicação em `main`, merge, execução, teste, API, driver, banco, Neon, grants, custos nem promoção do estado A2-G4.

Após a criação da branch de preservação, este CP248 **exclusivamente documental e antecipado por risco de continuidade**, registra no repositório canônico o local de recuperação e as provas limitadas de integridade, sem alterar qualquer arquivo-fonte técnico. O CP247 (Documento 222) permanece o registro histórico da revisão SA-05; o CP248 atualiza somente o ponto de recuperação. O progresso sobre SA-07 **ainda não foi iniciado**. Justificativa para checkpoint antecipado: a publicação segura de uma cópia segregada modifica materialmente o risco de perda de trabalhos anteriores e precisa ser encontrada sem depender de memória de conversa.

## 2. Identidade imutável da cópia preservada

Repositório: `rogerio-raposo/observatorio-evidencias-saude`.

- **Branch isolada:** `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`
- **Commit de preservação:** `96f16ec908b3f0f28199d841c90da471aa9e0ce1`
- **Commit canônico de origem (`main`, CP247):** `7f3b25aa5563455a98e01c7c358118dfe9c38546`
- **Diretório que existe somente na branch:** `prototypes/d1_t2/a2/`
- Link da branch: `https://github.com/rogerio-raposo/observatorio-evidencias-saude/tree/preservation/oes-d1-t2-a2-g4-cp247-unvalidated`
- Link do commit: `https://github.com/rogerio-raposo/observatorio-evidencias-saude/commit/96f16ec908b3f0f28199d841c90da471aa9e0ce1`

Verificações factuais efetuadas antes da publicação: `main` mantinha `7f3b25aa5563455a98e01c7c358118dfe9c38546` e ponteiro CP247; branch existente; comparação `96f16ec908b3f0f28199d841c90da471aa9e0ce1...preservation/oes-d1-t2-a2-g4-cp247-unvalidated` retornou `identical`; a branch adiciona exatamente um commit a partir de CP247; o commit tem CP247 como único ancestral direto; diff de `main` para a cópia contém **apenas seis arquivos adicionados** e nenhum arquivo de T1, T2-A1, governança ou CI modificado. A árvore Git da preservação apresenta seis objetos blob que correspondem aos identificadores abaixo. Ao retomar, repetir Freshness Gate e a comparação da branch: os resultados deste documento são uma fotografia verificável, não uma garantia de imutabilidade futura da ref.

## 3. Manifesto de recuperação por objetos Git

Os seis arquivos foram transferidos preservando exatamente os bytes da cópia preparada. Cada blob SHA foi confrontado com o identificador Git calculado sobre a cópia local; os seis coincidiram. **Este identificador Git é prova de igualdade de conteúdo daquela cópia, não um teste de comportamento.**

| Caminho relativo a `prototypes/d1_t2/a2/` | Blob Git SHA-1 | Bytes |
|---|---|---:|
| `README.md` | `dbd64cc3255390e95372d6a4e73fa652b500e0d6` | 98402 |
| `__init__.py` | `d75953b52a13903126430f9fc8c6ace2490684b0` | 313 |
| `bridge.py` | `6a95be7cca7aa93876218f53767d75859f31fd97` | 9362 |
| `codec.py` | `e07a28e43e42268b62553872a3170fb90240d037` | 2285 |
| `errors.py` | `4d9558b6aaf06aba94b2c3a94342967347966715` | 5225 |
| `repository.py` | `e08f71489bbe5e4bcd3598abc45682d32d1380fe` | 28708 |

Os hashes SHA-256 anteriormente calculados do staging permanecem no **Documento 222/CP247**. Não converter esses hashes em alegação de qualidade ou validação; são apenas inventários independentes. Na recuperação, preferir o commit imutável `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, verificar o hash e o estado da branch. Mesmo que a branch venha a receber alterações, o commit identificado representa a versão preservada.

## 4. Isolamento operacional e limites

**`main` não contém `prototypes/d1_t2/a2/` e não recebeu o commit do adaptador.** A branch de preservação está um commit à frente de CP247 e não é a branch de desenvolvimento/implantação do OES. Não abrir PR, realizar merge, cherry-pick ou deploy automaticamente. O nome `unvalidated` é obrigatório para esta cópia e não é declaração de aceitação técnica.

- A2-G4: somente código estático aprovado (Documento 218/CP243), **ainda não aceito nem promovido**.
- A2-G5 e execução operacional de T2-A2: `NOT_AUTHORIZED`.
- Nenhum import, compilação ou execução de módulo Python; nenhuma instalação de Psycopg; nenhum teste/CI, SQL, Neon, segredos, DDL/DML, grant, banco, API ou custo.
- Psycopg `3.3.6`: **referência estática de API**. Cópia de preservação não valida dependências, role, TLS, isolamento, durabilidade ou idempotência.
- Branch ref não foi protegida contra exclusão ou atualização por uma regra específica. Proteção de branch, se necessária, requer uma decisão de governança separada; não presumir proteção apenas por existir no GitHub.

## 5. Situação técnica preservada de CP247

SA05-R1/R2/R3 foram mitigadas estaticamente; SA-05 global permanece **ABERTA/ALTA** porque a fábrica nominal não comprova conexão nova/exclusiva, papel, banco, TLS nem comportamento real. SA-02 depende de SA-05; SA-03 parcialmente mitigada; SA-06, SA-07, SA-08 e SA-10 abertas; SA-11/12 mitigadas apenas por inspeção estática. **A preservação do código não altera nenhum desses estados nem converte uma inspeção textual em teste PASS.**

T1 (36 PASS históricos) e T2-A1 (75 PASS históricos, incluindo os 36 de T1) mantidos; A2-G2/E somente estrutural, A2-G3 grants mínimos históricos, F01–F07 documentais, L1–L4 e O-01–O-10 pendentes, 36 migrações `UNREVIEWED`, Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. D0 encerrado, D1 sintético prioritário, D2 factual diferido e governança operacional completa posterior.

## 6. Recuperação e ponto de retomada

Recuperação entre conversas: ler ponteiro canônico em `main`; conferir CP248 e Documento 223; confirmar HEAD e comparação com o commit da branch; ler os seis arquivos em `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, conferir os blobs Git do manifesto e, se pertinente, hashes SHA-256 contra Documento 222. **Não presumir** que o staging local continue disponível; a branch substitui essa dependência.

**Próxima atividade sob novo `Prossiga`: A1 pós-CP248 — triagem adversarial estritamente estática SA-07 (codec/JSONB numérico)**, com fonte recuperável na branch e sem importar/compilar/executar o código. Avaliar limites de precisão/range, codificação T1, JSONB e salvaguardas documentais; se surgir correção de código, atividade seguinte em branch de trabalho deliberada, sem modificar a cópia de preservação nem `main` automaticamente. SA-08, SA-10, SA-06 e SA-05 global continuam pendentes.

Protocolo CP194: um `Prossiga` autoriza uma atividade interna; checkpoint por risco ou normalmente após 3–5 atividades, Freshness Gate inicial/pré-commit, atualizações de progresso, STOP.

**STOP — CP248 documental; preservação confirmada, código não aceito ou executado.**
