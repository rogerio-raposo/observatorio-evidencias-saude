# Documento 286 — D2-I-A: contrato mínimo de integração de leitura sintética Django

**Data:** 2026-10-25. **Base:** CP281. **Natureza:** especificação técnica, sem autorização de implantação, conexão, DML, mudança de papel, habilitação de workflow ou GET factual.

## Evidência de partida
- `applications/oes_web/evidence/services.py` fornece `list_signals()` / `get_signal(nct)` por fixture JSON, projetando `Signal` via `domain.from_record`.
- `views.py` é somente GET e depende de contratos `Signal`/apresentação.
- `synthetic_pg_reader.py` retorna `SyntheticStudyReportLink` com UUIDs Study/Report/version, relation type e proveniência opcional, usando alias `oes_synthetic_reader`, leitura SQL parametrizada sem atualização.
- A projeção PG-A4 **não expõe NCT nem comprova correspondência** com os `Signal.nct` documentais. Portanto, não permite substituir diretamente o catálogo ou vincular registros da fixture sem uma regra de conciliação aprovada.
- Django atual usa `DEBUG=True`, chave somente de desenvolvimento e `DATABASES={}` por padrão; não está pronto para deploy. PG-A4 é habilitação experimental separada.
- CP280: autenticação Python independente inconclusiva; CP281: gate conectado diferido ao piloto integrado, obrigatório antes de operação factual.

## Contrato mínimo proposto — incremento A (somente especificação)
1. **Não alterar os contratos públicos existentes:** `list_signals()` e `get_signal(nct)` continuam fornecendo sinais documentais da fixture como fonte padrão; interfaces, rotas e identidade científica não mudam.
2. **Fonte PostgreSQL separada e opt-in:** manter o leitor PG-A4 interno como serviço de metadados sintéticos, selecionável apenas por configuração explícita em ambiente de teste; sem fallback silencioso entre fonte PG e fixture na mesma operação.
3. **Modelo de saída próprio:** manter `SyntheticStudyReportLink` com UUIDs e rótulo `SYNTHETIC_TECHNICAL_ONLY`. Não converter esse registro em `Signal` nem em vínculo por NCT sem uma crosswalk verificável, autorizada e testada.
4. **Limite de apresentação:** primeira integração poderá expor somente projeção técnica segregada ou teste de serviço; não misturar proveniência sintética com proveniência documental e não criar rota pública por padrão.
5. **Fail closed:** habilitação ausente → fonte PG indisponível explicitamente, preservando catálogo fixture; erro SQL, ACL, conexão ou dado malformado → HOLD sanitizado, sem leitura factual alternativa, sem payload, log de SQL sensível ou credenciais.
6. **Segurança:** apenas SELECT no leitor limitado a Study–Report/provenance de fixture; sem `oes_raw_private.source_observation`, sem escrita, migração, GET externo, revisão científica, atualização de produto ou readiness operacional.
7. **Testes offline antes do conectado:** fixtures continuam entregando os mesmos sinais e códigos GET/404; PG opt-in desabilitado não abre conexão; mocks testam projeção UUID/provenance, falha/HOLD, ausência de mistura de identidades e não regressão de rendering.
8. **Gate conectado posterior:** autorização separada quando integrado ao piloto, com autenticação própria e privilégio mínimo, TLS, evidência sanitizada e cleanup conforme Documento 285. Nenhuma credencial nova nesta etapa.

## Aceite documental
A arquitetura evita um erro de integração: **vínculo Study/Report sintético por UUID não é identidade de ensaio NCT**. Portanto, o primeiro incremento demonstra reutilização controlada do leitor e preservação do catálogo, não conciliação científica nem prontidão de banco. A integração de escrita/roundtrip D2-I-B e o gate conectado D2-I-C permanecem pendentes e não autorizados.

## Próxima atividade proposta
Projetar testes de contrato e um adaptador mínimo de seleção de fonte para uso **offline e opt-in**, sem modificar comportamento padrão das páginas; pedir aprovação explícita antes de alterar a aplicação Django.
