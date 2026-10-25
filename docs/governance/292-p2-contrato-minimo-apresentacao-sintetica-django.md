# Documento 292 — P2: contrato mínimo da apresentação sintética segregada no Django

**Data:** 2026-10-25.  
**Natureza:** contrato técnico-documental de escopo aprovado; **não** é autorização de implementação nem validação executada.  
**Origem:** P2-A1 análise proporcional, P2-A2 comparação A/B/C e aprovação expressa do responsável em modo médio: "Alternativa B aprovada."

## 1. Decisão e fundamento
Adotar em P2 a **alternativa B: página demonstrativa mínima, separada e somente leitura no Django**, porque a comprovação P1-A3 offline e a apresentação documental existente são tecnicamente suficientes de forma isolada, mas não fornecem uma experiência visual unificada. Não construir a alternativa C (execução dinâmica P1-A3 por view), desproporcional no piloto. Preservar Docs. 287–291; simplificar conforme Doc. 288. A aprovação de B define **escopo**, não libera escrita de código, migrações, deploy ou serviços.

## 2. Fronteiras da apresentação
- A página, se implementada por autorização posterior, ficará em **rota própria adicional**, não modificando `/`, `/signals/NCT01438697/` ou `/signals/NCT07836491/`.
- Exibir ilustração offline determinística do percurso: preparação E6 e SHA-256 → comando/ciclo/sinal D1 → referência documental da fixture **explicitamente escolhida no cenário** → recibo sanitizado; não alegar que a própria view executa esses estágios, que há armazenamento ou readback conectado, nem apresentar exemplo reconstruído como artefato histórico preservado.
- Isolar da fixture científica `applications/oes_web/evidence/fixtures/signals.json`, dos contratos Study–Report e das views/catálogo existentes. Referência NCT não é inferida de payload, observation_id ou signal_id.
- Invariantes para recibo ilustrativo: `status=SYNTHETIC_PATH_VERIFIED_OFFLINE`; `observation_id`, `sha256`, `payload_bytes`, `signal_id`, `documentary_nct` (opcional), `identity_state` (opcional), `evidence_boundary=SYNTHETIC_TECHNICAL_ONLY`, `scientific_decision=NOT_PERFORMED`. Estes nove campos constam do contrato P1-A3; SHA e tamanho devem corresponder ao exemplo sintético identificado, sem exibir bytes brutos.
- Para `documentary_nct` opcional, exigir estado de identidade compatível com resolver documental aprovado: `KNOWN_DOCUMENTED` ou `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`; valores desconhecidos, inconsistentes ou ausência do resolver são HOLD. NCT ausente não cria vínculo presumido.
- Evidenciar a natureza de `fixture/documentary_reference` distinta da evidência técnica do Doc. 291 e Actions 40214460778. Não apresentar interpretação de estudo novo, inclusão, elegibilidade, GRADE ou aprovação científica.

## 3. Critérios de aceite para futura implementação (não executados)
- **P2-AC01:** identificação ostensiva de simulação offline sem execução HTTP, captura factual ou ciência.
- **P2-AC02:** nenhuma exposição de payload bruto, segredos, SQL, stack trace ou exceções internas.
- **P2-AC03:** nenhuma associação automática entre observation_id, signal_id, NCT ou identificadores PG.
- **P2-AC04:** exemplo determinístico identificado, verificável e sem atribuir resultado estático a uma execução histórica que não produziu o artefato.
- **P2-AC05:** campos ausentes ou inválidos, SHA/tamanho incoerentes, estado documental inconsistente ou erro produzem HOLD sanitizado, sem recibo positivo parcial.
- **P2-AC06:** três rotas documentais, fixtures e comportamento Study–Report inalterados; rota adicional requer aprovação de código separada.
- **P2-AC07:** nenhuma conexão Neon/SQL, nenhuma dependência de rede, execução dinâmica P1-A3, workflow factual ou serviço pago.
- **P2-AC08:** testes Django de segurança/segregação, ausência de vazamento, 404/GET-only, renderização e regressão de catálogo/detalhe; se nova página, teste de navegador com layout e teclado proporcional.

A referência HTTP a um SHA não prova persistência. Os resultados P1-A3 registrados (107/107 PASS) e Django (50/50 e 9/9 PASS) são históricos, não novos testes de P2.

## 4. Caminho seguinte e bloqueios
P2-A4: especificação mínima de arquivos/rota, dados de exemplo e matriz de testes **somente para proposta de implementação**, com autorização de código expressa antes de qualquer alteração. Após eventual implementação/teste, P3 avaliará suficiência técnico-funcional, sem homologação científica. A ausência de pesquisadores mantém avaliação especializada diferida. Piloto não encerrado; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`. Captura factual, Neon/roles/grants/credenciais, SQL conectado, workflows bloqueados, implantação e custos continuam não autorizados.
