# Documento 294 — P3: parecer aprovado e suficiência técnico-demonstrativa restrita

**Data:** 2026-10-25.  
**Natureza:** decisão expressa do responsável após P3-A1, A2 e A3.  
**Estado reconhecido:** `P3_RESTRICTED_TECHNICAL_DEMONSTRATION_SUFFICIENCY_APPROVED`.  
**Escopo:** demonstrador sintético P1/P2 e suas evidências, não o piloto OES operacional ou científico em sentido amplo.

## 1. Deliberação
O responsável aprovou expressamente o parecer P3-A3 ("parecer aprovado"). Reconhece-se como **tecnicamente suficiente apenas para fins demonstrativos restritos** a composição sintética offline de P1 e a página segregada Django de P2, com a rastreabilidade de P3. O resultado **não** demonstra execução operacional integrada ponta a ponta, captura factual autorizada, revisão científica humana, prontidão, produção ou encerramento abrangente do piloto.

## 2. Matriz de rastreabilidade e suficiência
| ID | Capacidade | Evidência canônica | Classificação restrita |
|---|---|---|---|
| P3-R01 | Preparação/proveniência/integridade SHA-256 sintéticas | Doc. 291; P1-A3; CI 40214460778, 107/107 PASS | Comprovada offline |
| P3-R02 | Composição E6 → D1 → referência documental | Doc. 291; código `tools/d2_e5_preservation/p1_synthetic_path_offline.py` | Comprovada offline, associação explícita |
| P3-R03 | Estudo–relatórios sem dupla contagem | Doc. 289; Django documental, fixture `signals.json`; CI 40196984551 | Comprovada no exemplo |
| P3-R04 | Exibição sintética Django segregada e HOLD | Docs. 292–293; `/synthetic-path/`; CI 40217150462 | Comprovada tecnicamente |
| P3-R05 | Chromium, navegação e três viewports | Doc. 293; CI 40217256102 | Workflow `success`, sem auditoria individual de screenshots |
| P3-R06 | Fronteiras de certeza, sem decisão científica | Docs. 291–293 e testes associados | Demonstradas nos cenários controlados |
| P3-R07 | Execução dinâmica P1 via Django | Doc. 292, escolha B | Não demonstrada, excluída do escopo restrito |
| P3-R08 | Persistência e readback PostgreSQL integrados | Docs. 287–288 e 290 | Parcial/não demonstrada como fluxo unificado |
| P3-R09 | Captura factual conectada | Doc. 290 e gates específicos | Bloqueada, não autorizada |
| P3-R10 | Revisão científica externa | Doc. 290 | Diferida; pesquisadores não vinculados |
| P3-R11 | Stack definitiva e autenticação | Docs. 287–288 | Diferida com reavaliação obrigatória |

## 3. Critérios P3-S01 a P3-S06
- **S01:** rastreabilidade entre código, documentos e CI — satisfeita no escopo delimitado;
- **S02:** composição sintética offline mínima — satisfeita;
- **S03:** apresentação Django demonstrativa — satisfeita;
- **S04:** fronteira explícita de não realização de nova avaliação científica — satisfeita documentalmente;
- **S05:** lacunas e requisitos diferidos enumerados — satisfeita inicialmente; inventário completo de stack continua futuro;
- **S06:** separação formal demonstração versus operação — satisfeita para decisão restrita, não readiness.

## 4. Reservas e requisitos diferidos
A página P2 é **estática**, não executa P1-A3 via HTTP. Os dois workflows P2 terminaram `completed/success` sobre o mesmo SHA `3901787f9c6a8d177f236f30310624d4a993a402`; os totais internos de P2 não foram extraídos e as screenshots individuais não foram inspecionadas. Não extrapolar `success` para laudo de segurança, acessibilidade ou ciência.

Requisito de **duas autenticações independentes** diferido pelo Doc. 287 apenas para o piloto inicial; reexaminar durante definição/implantação da stack definitiva, antes de readiness operacional, conforme Doc. 288. Conexão sintética D2-I-C, persistência/readback unificados, controles de produção, credenciais, TLS/ACL e tratamento transacional permanecem sujeitos aos gates aplicáveis. Captura factual só com autorização específica. Revisão científica externa permanece obrigatória no estágio científico pertinente e não foi substituída por testes.

## 5. Alcance do encerramento
**Marco A — suficiência e encerramento técnico restrito do demonstrador P1/P2:** reconhecido pela aprovação do parecer P3; atividade de formalização P3-A4 concluída com este registro.  
**Marco B — encerramento do piloto OES em sentido amplo:** **não decidido nem aprovado**. A avaliação futura das macroatividades deve separar evolução técnica, preparação operacional e validação científica.

Fase 4 segue `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`; piloto amplo ainda aberto. Nenhum serviço pago, implantação, GET factual, SQL conectado, role/grant/credential ou workflow factual autorizado por este ato.

## 6. Próxima etapa
Reavaliar macroatividades remanescentes e definir o próximo marco proporcional do OES sem implementar infraestrutura ou alterar gates automaticamente. Reutilizar evidências existentes, não repetir testes sem motivo verificável.
