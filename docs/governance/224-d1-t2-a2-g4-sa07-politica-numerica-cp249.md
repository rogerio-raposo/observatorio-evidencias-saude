# Documento 224 — OES D1/T2-A2: SA-07 e política numérica JSONB (CP249)

**2026-10-22 | DOCUMENTARY_CHECKPOINT_STATIC_ONLY | A2-G5/T2-A2_RUNTIME_NOT_AUTHORIZED**

## Autoridade e evidência

Este documento consolida A1–A5 pós-CP248 e a atividade A6 exclusivamente documental. Ponto de partida: `main` HEAD `62417b8c3387005499a2025e97d3dad3f5b3fb7b` e CP248. Código de referência **não validado**: commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`, branch `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`, seis arquivos A2-G4 preservados conforme Documento 223/CP248. Autoridade de código estático limitada pelo Documento 218/CP243. Sem publicação técnica em `main`, importação, compilação, execução, testes, CI, Psycopg instalado, SQL, Neon, DDL/DML, migrações, grants, acesso a dados reais ou custos. T1 36 e T2-A1 75 PASS são históricos, não reexecutados.

## Consolidação A1–A5 pós-CP248

| Atividade | Registro documental | Limite explícito |
|---|---|---|
| A1 | Triagem adversarial SA07-N1 finitude/faixa; N2 precisão e round-trip; N3 serializer Psycopg | `parse_constant` rejeita constantes não finitas, mas não comprova compatibilidade integral com JSONB |
| A2 | Inventário dos cinco comandos T1: `create_scenario` não declara parâmetros numéricos; `start_cycle`, `register_signal`, `record_assessment`, `close_cycle` declaram `cycle_no: int` | Anotações de tipo não equivalem a validação em execução |
| A3 | Revisão adversarial dos valores `True`, `1`, `1.0`, inteiros extremos e floats não finitos | Igualdade Python pode divergir de identidade JSON e fingerprint |
| A4 | Política candidata: preservar semântica T1, fingerprint e tipos; evitar coerções silenciosas; distinguir domínio, idempotência e persistência | Não é nova regra implementada nem validação de equivalência |
| A5 | Revisão adversarial: ordem de validações, erros, cleanup, serialização, replay | “Antes de escritas” não significa “antes de qualquer SQL”; `encoded(payload)` pode falhar antes do codec |

## Decisão delimitada para SA-07

**Preservar exatamente o fingerprint** `SHA-256(encoded(payload).encode("utf-8"))` com codificação T1 (`json.dumps(...,sort_keys=True,ensure_ascii=False,separators=(',', ':'))`), **não** derivar fingerprint da representação PostgreSQL JSONB. Distinções entre `True`, `1`, `1.0` não devem ser apagadas: comparações de domínio podem tratar os valores como iguais, mas os bytes codificados e fingerprints podem divergir.

Não converter automaticamente booleanos em inteiros, floats em inteiros, nem arredondar valores extremos para caber em JSONB. Uma validação estrita `type(cycle_no) is int` seria uma alteração potencial da semântica histórica T1 e depende de decisão futura separada. O domínio dos cinco comandos não autoriza representar arbitrariamente todo tipo Python admitido por `Receipt.response: Any` de T2-A1.

O codec preservado faz `json.loads(encoded(value), parse_constant=_reject_constant)` e valida NUL/surrogates em strings; isso **não comprova** toda a faixa `numeric` do PostgreSQL, precisão decimal, configuração de serialização Psycopg, round-trip nem equivalência de replay. `psycopg_jsonb()` devolve `Jsonb(normalized)` e não fixa independentemente um serializador. SA07-N1/N2/N3 continuam abertos. Rejeição de incompatibilidades **antes de escritas** pode ocorrer depois de leituras SQL/obtenção de conexão. Falhas de fingerprint ocorrem antes da fronteira JSONB, e exceções históricas não devem ser automaticamente reclassificadas como `JsonbCompatibilityError`. Uma rejeição com transação aberta não equivale a rollback confirmado.

## Matriz adversarial consolidada AV-01–AV-08

| Controle | Condição de aceite futuro |
|---|---|
| AV-01 — T1/encoded | Preservar código e semântica do domínio |
| AV-02 — `bool/int/float` | Não forçar igualdade representacional |
| AV-03 — Idempotência | Fingerprint do payload original T1 |
| AV-04 — Extremos/precisão | Definir e provar faixa, comportamento e round-trip |
| AV-05 — Não finitos | Não gravar em JSONB dados incompatíveis; classificar adequadamente |
| AV-06 — Ordenação | Distinguir leitura prévia de escrita e falhas pré-transação |
| AV-07 — Exceções/rollback | Não mascarar erros históricos nem presumir rollback/close |
| AV-08 — Psycopg/replay | Separar configuração serializadora e igualdade observável de confirmação operacional |

A política permanece **somente candidata e documental**, sem edição de nenhum módulo e sem teste diferencial. Uma futura intervenção técnica requer branch de trabalho separada; preservar intocada a branch de recuperação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated`. Não há autorização para executar testes A2-G5.

## Estado de gates e riscos

**SA-07 ABERTA/MODERADA**, incluindo N1, N2 e N3. SA-05 GLOBAL ABERTA/ALTA com R1/R2/R3 mitigadas apenas textualmente; SA-02 condicionada a SA-05; SA-03 parcialmente mitigada; SA-06, SA-08, SA-10 abertas; SA-11/12 mitigadas estaticamente. A2-G4 não aceita tecnicamente e A2-G5/T2-A2 runtime `NOT_AUTHORIZED`. 36 migrações `UNREVIEWED`, Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`. D0 encerrado, D1 sintético prioritário, D2 factual diferido.

## Retomada

**A1 pós-CP249 — triagem adversarial estática SA-08**, fidelidade de recibos e semântica de replay dos cinco comandos T1, ponte e repositório, a partir do commit `96f16ec908b3f0f28199d841c90da471aa9e0ce1`. Conferir Freshness Gate de `main`, ponteiro CP249 e branch preservada; não executar, importar, compilar nem alterar código, nem acessar Psycopg, CI, SQL, Neon, grants, dados reais ou serviços. SA-07/SA-10/SA-06 continuam abertas para atividades independentes.

Protocolo CP194: cada `Prossiga` autoriza uma atividade; checkpoint 3–5 atividades ou por risco; STOP.

**STOP — CP249 documental.**
