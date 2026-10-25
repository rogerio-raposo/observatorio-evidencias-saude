# Documento 300 — M2-A7: transição do demonstrador ao piloto técnico-funcional

**Data:** 2026-10-25. **Natureza:** decisão de prioridade aprovada pelo responsável na conversa; delimitação de planejamento, **sem autorização de implementação, deploy ou operação conectada**.
**Base:** Docs. 294, 297–299 e CP294.

## 1. Decisão de direção
Encerrar a ampliação rotineira do **ciclo de demonstrações técnicas isoladas**, já considerado suficiente no alcance restrito aprovado em P3. Isso **não** encerra o Marco B, não homologa integração operacional ou aceitação científica e não apaga pendências. Novos ensaios isolados devem requerer lacuna/risco concretamente demonstrado.

A prioridade passa a ser um **piloto técnico-funcional mínimo e integrado**, com casos de uso reais de usuário sobre dados históricos ou preparatórios, separando capacidades técnicas de decisões científicas. Marco B continua aberto enquanto seus critérios não forem atendidos e avaliados explicitamente.

## 2. Escopo inicial proposto — sujeito a aceite de contrato antes de codificação
- **Consulta:** localizar e ler produtos históricos N2 identificados e versionados, com perguntas, data de corte, proveniência, certeza, limitações e assurance expressos.
- **Preparação:** registrar Q0 e propostas Q1/Q2 e routing preliminar, preservando versões e autoria administrativa autorizada; **nenhuma abertura E9**.
- **Navegação documental:** consultar ligações existentes Q→I→P sem presumir relações ou disparar síntese/captura.
- **Acompanhamento:** estados explícitos de preparação e revisão, sem representar aprovação científica inexistente.

Exclusões: pesquisas factuais automatizadas, ingestão de dados novos, avaliações científicas automáticas, revisão independente A3, novas conclusões ou mudança da Ficha publicada, workflow factual habilitado, atualização científica automática, implantação pública e serviços pagos.

## 3. Critérios de aceite candidatos para o piloto (não comprovados)
PF-01 consulta N2 com identidade/versão e atributos de transparência;
PF-02 registro versionado Q0/Q1/Q2 sem perda de original;
PF-03 roteamento preliminar e limites visíveis, sem E9;
PF-04 navegação explícita Q→I→P apenas para vínculos registrados;
PF-05 controles de autenticação/autorização apropriados à função e segregação, com acesso negado por padrão;
PF-06 persistência transacional, leitura após escrita, erros e auditoria verificáveis;
PF-07 testes de interface, API/fluxo, negativos e regressão proporcionais;
PF-08 ambiente de execução definido, configuração e segurança revisadas;
PF-09 documentação de limitações, ownership operacional e procedimento de falhas;
PF-10 avaliação formal de alcance técnico versus validação científica — **A3 permanece dependência externa**, não fingir cumprimento.

Uma demonstração offline pode satisfazer subconjuntos, mas não PF-05–PF-09 operacionais. Critérios serão refinados antes de execução.

## 4. Estratégia de arquitetura
**Preferir reuso**, sujeito a inventário e decisão posterior: Django existente para camada web; PostgreSQL/Neon existente para persistência quando autorizações e controles forem viáveis; GitHub Actions para testes isolados. Evitar seleção antecipada de nova stack. Decidir requisitos de autenticação, autorização, duas autenticações independentes conforme Docs. 287–288, modelo de permissões, TLS/ACL, credenciais, transações, backup/recuperação, deploy e custo antes da primeira operação pertinente. Neon Free não significa autorização para SQL conectado ou infraestrutura adicional.

## 5. Gates para início do desenvolvimento
(1) inventário gap de fluxos e componentes atuais;
(2) contrato de usuário, dados e acessos explicitamente aceito;
(3) plano mínimo de persistência e segurança, com bloqueio E9 testável;
(4) autorização proporcional e específica para mutações técnicas;
(5) CI controlada, sem serviços pagos nem acesso factual externo;
(6) reavaliação de prontidão antes de implantação, sem inferir GO a partir de testes unitários.

## 6. Tratamento do Marco B
Não encerrá-lo hoje. Recomenda-se reinterpretá-lo, **mediante decisão formal separada**, como marco de piloto técnico-funcional integrado com dependências científicas diferidas nomeadas. A presente concordância aprova a prioridade de transição e este planejamento, não automaticamente alteração retroativa de definição canônica de Marco B ou declaração de sucesso.

## 7. Próxima atividade
Inventário curto e verificável das rotas Django, modelos/persistência e serviços existentes frente a PF-01–PF-10; apresentar uma única proposta de primeiro incremento com arquivos candidatos, critérios e gates, sem implementar até autorização. Não repetir toda a auditoria histórica.

## 8. Invariantes
Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; Marco B aberto; E9 NO-GO; pesquisadores não vinculados, A3 não realizada. Sem GET factual, SQL/Neon conectado, concessão de roles/grants, credenciais, workflows operacionais, publicação externa, implantação nem serviços pagos.
