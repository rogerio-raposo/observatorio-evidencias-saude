# OES — CP284 / Checkpoint preventivo após D2-I-C offline 99/99 PASS

**Data:** 2026-10-25. **Anterior:** CP283. **HEAD de evidência:** `ab37802c0811cc393797fc7db36347e60469d780`. **Motivo:** prevenir perdas e retrabalho caso a conversa atinja limite; esta conversa permanece aberta.

## Situação já verificada
1. D2-I-A: leitor sintético interno Django com opt-in, catálogo fixture padrão, sem crosswalk UUID/NCT. GitHub Actions [40190923646](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40190923646), 39/39 PASS. Encerrado tecnicamente apenas offline.
2. D2-I-B: Django usa orquestrador E6 verdadeiro com conexões de teste simuladas; CI [40192039182](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40192039182), 50/50 PASS, quatro testes de composição. Encerrado tecnicamente apenas offline para modelo histórico de duas identidades.
3. D2-I-C: **piloto simplificado de uma identidade** pela decisão Documento 287. Novo teste `tools/d2_e5_preservation/tests/test_d2_i_c_single_identity_offline.py`, commit `ab37802c0811cc393797fc7db36347e60469d780`, reutiliza `prepare_observation`, `persist_observation`, `read_private_observation`, `verify_private_readback` com um objeto de conexão DB-API simulado. Actions [40194548767](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40194548767), job `121172463971`, HEAD exato `ab37802c0811cc393797fc7db36347e60469d780`, **99/99 PASS, zero falhas ou erros**, quatro novos testes PASS (integridade, falha de escrita, leitura adulterada após commit, falha na leitura após commit). **Sem SQL conectado**.

## Decisões canônicas e prioridade
- Documento 285 originalmente exigia autenticação independente conectada; **Documento 287 retira essa exigência do piloto inicial** (requisito diferido, não abandonado). Restantes controles mínimos proporcionais permanecem.
- **Documento 288:** foco no objetivo principal do piloto, não gastar esforço criando contornos para problemas que serão resolvidos ao definir a stack completa. Todos os requisitos relevantes diferidos devem ser inventariados e reavaliados obrigatoriamente na etapa de definição da stack, antes de prontidão operacional.
- Não projetar novo framework/infraestrutura transitória, nem adaptar todo o Django só para um teste pontual. Reutilizar funções E6 existentes.

## Restrições e limites
- CP283 anterior permanece imutável; CP284 atualiza ponteiro e estado. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, `NOT_READY`, Fase 5 `NOT_STARTED`.
- Workflows factuais e G2-I1 hard-disabled; **sem factual GET**, publicação de raw JSON, mudança em papéis/concessões/credenciais, Neon escrito ou conectado sem autorização específica, serviços pagos, deploy.
- Resultados de testes offline **não comprovam** autenticação TLS, persistência PostgreSQL conectada, isolamento de produção ou cleanup conectado.
- Os adaptadores existentes de duas identidades não devem ser alterados retroativamente; o teste single-identity não os modifica.

## Ponto exato de retomada
**D2-I-C: delimitar as pré-condições mínimas para um ensaio sintético PostgreSQL conectado com uma identidade autorizada**, verificando viabilidade, privilégios necessários para INSERT/SELECT, mecanismo de cleanup sem elevação administrativa indiscriminada, TLS, integridade e trilha de evidência. **Somente planejamento ou leituras administrativas expressamente autorizadas**; não conectar/escrever/alterar roles/grants/credenciais ou habilitar workflows sem aprovação específica. Evitar soluções transitórias e reduzir a um ensaio mínimo proporcional. Depois propor autorização delimitada.

## Acordo de trabalho
Um `Prossiga` = uma atividade; checkpoints a cada 3–5 atividades, ou antecipados por risco, decisão ou transição; Freshness Gate no início e antes de publicar; mensagens de progresso. Repositório `rogerio-raposo/observatorio-evidencias-saude`, branch `main`, ponteiro `archive/handoffs/oes/README.md`; template `archive/continuity/OES_Template_Abertura_Continuidade.md`, STATE/CHANGELOG e documentos 285/286/287/288. Modo médio salvo orientação do responsável. Não deduzir estado apenas de memória.
