# Documento 225 — OES/D1/T2-A2: SA-08, recibos, idempotência e replay (CP250)

**2026-10-22 | CP250_DOCUMENTARY_ONLY | SA08_OPEN_HIGH | A2-G5_RUNTIME_NOT_AUTHORIZED**

## 1. Autoridade e fontes

Consolidação documental A1–A5 pós-CP249. CP249 inicial: `main` HEAD `32915d230858ac241e09b5fcef3fa4a07625b512`, ponteiro `archive/handoffs/oes/README.md`, Documento 224. Código de referência estático: branch segregada `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, commit fixo `96f16ec908b3f0f28199d841c90da471aa9e0ce1`; hashes e recuperação no Documento 223. A autorização do Documento 218/CP243 restringe A2-G4 a código estático. **Não houve** alteração, importação, compilação ou execução de código Python/Psycopg, testes, CI, SQL/Neon, mudanças de esquema/grants/segredos, dados reais, serviços pagos ou promoção de gates. Os 36 testes T1 e 75 T2-A1 PASS são exclusivamente históricos.

## 2. Atividades A1–A5 pós-CP249

| Etapa | Resultado documental | Limite |
|---|---|---|
| A1 | Triagem SA08-R1 fidelidade semântica de recibos; R2 independência do replay; R3 respostas recuperadas | Contagens e sequências não autenticam resposta e fingerprint |
| A2 | Invariantes I-01–I-07 de requisição, atomicidade, revisão, respostas históricas, criação repetida, replay e JSONB | Não implementadas integralmente nem testadas |
| A3 | Revisão adversarial AV08-01 fingerprint não reconstituível em geral; 02 recibo semanticamente divergente; 03 replay não audita recibos | Eventos não contêm necessariamente payload original completo ou sua representação |
| A4 | Avaliação de mitigação estática proporcional: validações por forma/evento somente parciais; nenhuma alteração de código proposta | Não introduzir verificação que alegue integridade não comprovável |
| A5 | Revisão adversarial da mitigação: AV08-M1 estrutural ≠ semântico; M2 resposta histórica ≠ estado corrente; M3 criação repetida retorna snapshot corrente; M4 forma ≠ identidade de comando; M5–M6 limites de integração e regressão | Manter SA-08 aberta/alta e diferir correções até fronteira probatória definida |

## 3. Matriz das invariantes I-01–I-07

| ID | Invariante contratual | Evidência estrutural existente | Lacuna |
|---|---|---|---|
| I-01 | Requisição e fingerprint T1 | `find_receipt()` confronta fingerprint solicitado | Recibos históricos não guardam payload original para recomputar todos fingerprints |
| I-02 | Um estado, evento e recibo por comando confirmado | `commit()` prepara três escritas na mesma transação | Garantias reais dependem de validação operacional |
| I-03 | Correspondência semântica revisão–evento–resposta | `_validate_loaded()` confere contagem, sequências e revisões | Não demonstra resposta correspondente ao comando/evento |
| I-04 | Repetição dos quatro comandos não-create devolve resposta histórica | Ponte usa `deepcopy(receipt.response)` | JSONB/serialização e integridade do recibo não demonstradas |
| I-05 | Repetição de criação devolve snapshot corrente | Ponte usa estado protegido e `snapshot()` | Não equivale à resposta histórica inicialmente produzida |
| I-06 | Replay reconstrói estado e confronta snapshot | Ponte delega a `SyntheticMonitorService.replay_snapshot()` a partir do estado carregado | Não audita cada recibo/fingerprint; independência entre fontes é limitada |
| I-07 | Fidelidade JSONB de respostas, eventos e estado | Codec normaliza e valida alguns tipos | Precisão, serializer e round-trip permanecem SA-07 abertos |

## 4. Conclusões adversariais e proibições de inferência

`_validate_loaded()` verifica `len(events)==revision`, `len(receipts)==revision`, sequências `1..revision`, revisões dos recibos e igualdade entre `state.events` e a lista `event` carregada. **Isso não prova** fidelidade semântica do recibo, autenticidade do comando que gerou o fingerprint ou completude de auditoria. `find_receipt()` compara o fingerprint do pedido presente, mas não reconstitui historicamente todos os payloads.

A criação repetida é caso especial intencional T1: devolve **snapshot corrente**. Os outros quatro comandos repetidos devolvem a **resposta original** armazenada; comparar tais respostas com o estado corrente, ou exigir que a criação retorne o snapshot inicial, produziria falso positivo ou regressão. A ponte de replay reconstrói via núcleo T1 os eventos armazenados dentro do estado após conferência estrutural com a tabela `event`; isso **não** é auditoria independente de todos os recibos.

Não inferir comando original apenas pelo formato da resposta; não deduzir payload original de um evento quando dados/representações podem ter sido descartados; não alegar correspondência criptográfica/auditoria independente com base em contagem e fingerprint isolado; não autocorrigir dados divergentes. Validações adicionais de forma só podem mitigar casos localmente demonstráveis, não resolver SA-08 global.

## 5. Decisão proporcional A4/A5

**Não alterar o código nesta etapa.** Qualquer futura mitigação deve:
1. delimitar os predicados que são logicamente verificáveis usando o esquema atual;
2. preservar exatamente a distinção entre criação repetida e quatro respostas históricas;
3. manter fingerprint T1, política numérica SA-07 e diferenças de exceções;
4. rejeitar apenas incompatibilidades efetivamente demonstráveis, sem falsos positivos de integridade;
5. respeitar contratos de transação/COMMIT incerto; não presumir rollback;
6. ocorrer somente em branch de trabalho **separada** da branch de preservação, com decisão explícita e validação diferencial quando autorizada.

Não propor automaticamente nova tabela, coluna, migração, grant ou auditoria operacional. Uma revisão documental não equivale a teste PASS.

## 6. Estado, limites e retomada

**SA-08 ABERTA/ALTA**, com SA08-R1/R2/R3 e AV08-01/02/03 pendentes. SA-05 global ABERTA/ALTA (R1/R2/R3 apenas mitigadas estaticamente), SA-02 dependente de SA-05; SA-03 parcial; SA-06 aberta; SA-07 ABERTA/MODERADA (N1/N2/N3); SA-10 aberta; SA-11/12 textualmente mitigadas. A2-G4 sem aceitação técnica e A2-G5/T2-A2 runtime `NOT_AUTHORIZED`. T1 36 PASS e T2-A1 75 PASS históricos; 36 migrações `UNREVIEWED`, Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, D0 encerrado, D1 sintético prioritário, D2 factual diferido.

A cópia técnica está **somente** na branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, no commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`; `main` não contém `prototypes/d1_t2/a2/`. Não editar a branch de preservação nem publicar código por este checkpoint.

**Próxima atividade, após novo `Prossiga`: A1 pós-CP250 — triagem adversarial estritamente estática SA-10**, focada classificação SQLSTATE, contexto/constraint e exceções em retry/pre-COMMIT/COMMIT incerto. Conferir Freshness Gate `main`/branch/ponteiro; nenhum import, compilação, execução, teste, CI, SQL, Neon, driver, grant, dado real ou serviço. SA-06, SA-07, SA-08 e SA-05 global seguem abertas separadamente.

Protocolo CP194: cada `Prossiga` autoriza uma única atividade; checkpoints por risco ou 3–5 atividades; STOP.

**STOP — CP250 apenas documental.**
