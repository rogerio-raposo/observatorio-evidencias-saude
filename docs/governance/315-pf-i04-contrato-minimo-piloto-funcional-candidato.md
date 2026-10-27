# PF-I04 — Contrato mínimo candidato do piloto funcional Django

**Data:** 2026-10-27. **Natureza:** especificação para aceite posterior; não autoriza implementação, SQL, implantação ou operação conectada.

## 1. Propósito e ator
Permitir que um **preparador administrativo autenticado e autorizado** registre Q0, proponha Q1, prepare Q2 e um Routing Record **preliminares**, e consulte o histórico e os estados das perguntas sob sua responsabilidade. A hipótese de uso abrange dados sintéticos/administrativos preparatórios; não representa revisão científica.

## 2. Percurso permitido
1. Autenticação pelo Django Auth em ambiente controlado ainda a definir. Negar sessão ausente, usuário inativo, falta de permissão e acesso a perguntas de outro responsável. Django staff/superuser isoladamente não substitui autorização funcional.
2. Q0: registrar texto original imutável, ID, autor, data, versão e recibo; falhas não criam registro parcial.
3. Q1: propor texto normalizado com justificativa, versão esperada e preservação do Q0; colisões e replay seguem contrato transacional existente, sem retry automático após resultado incerto.
4. Q2: produzir formulação operacional e dimensões metodológicas identificadas nos templates; **não** tratar projeção offline atual como comando persistente já pronto.
5. Routing Record: propor classificação, N0–N4, M0–M3 e justificativa; não converter proposta em autorização de investigação.
6. Consulta: mostrar apenas histórico autorizado, autoria, versões, estados e pendências, com origem/proveniência explicitadas.

## 3. Estados e limites
- Preparação: `PREPARATORY_ONLY` ou proposta equivalente claramente rotulada; revisão científica `NOT_PERFORMED`; admissibilidade `NOT_DECIDED`; investigação `NOT_OPENED`; E9 `BLOCKED`.
- Nenhum GET factual, ingestão, publicação de produto científico, E9, abertura de investigação ou acesso público de escrita.
- Não presumir que Q2/roteamento já têm schema, API ou persistência transacional.

## 4. Pré-condições para implementar um primeiro fluxo funcional
- **PF-05:** escolher mecanismo real de usuário/sessão/roles do Django, permissão explícita e escopo por pergunta; registrar criação/revogação administrativa dos usuários.
- **PF-06:** mapear versões, recibos, autoria e Q2/roteamento a armazenamento durável existente ou justificar diferença mínima; definir atomicidade, read-after-write, idempotência, tratamento HOLD, auditoria e recuperação; verificar privilégios mínimos sem usar owner.
- **PF-08:** selecionar execução privada, SSL/TLS, credenciais protegidas, segredo Django não fixo, `DEBUG=False`, hosts/CSRF seguros, isolamento e custos; `settings.py` atual é **somente desenvolvimento**.
- **PF-09:** designar responsável operacional, acesso administrativo, backup/restauração apropriados, diagnóstico de falhas, rollback e incidentes antes do uso.
- Conforme Docs. 287–288, duas identidades independentes são **diferidas** no piloto, não exigidas; isso não dispensa permissões mínimas, integridade e controles transacionais.

## 5. Aceite candidato mensurável
- Preparador autorizado consegue registrar Q0, propor Q1, Q2 e routing com trilha por identidade/versão, consulta posterior e histórico imutável; usuário sem permissão ou fora do escopo não consegue ler/alterar.
- Repetição do mesmo comando não duplica dados; colisão, versão obsoleta, backend indisponível e falha transacional produzem HOLD/fail closed; read-after-write só após commit comprovado.
- Configuração segura em ambiente privado e documentação de titularidade/falhas disponíveis; testes de interface, negativos e transacionais proporcionais.
- E9 e avaliação científica permanecem bloqueados; evidência técnica não é autorização científica.
- Evidências serão necessárias **no ambiente relevante**. Os 201 testes PF-I03 comprovam apenas composição offline, não estes critérios operacionais.

## 6. Sequenciamento recomendado
**PF-I04-A1 (somente desenho):** verificar modelo concreto de usuário/sessão e persistência mínima Django/PostgreSQL, inclusive lacuna real de Q2/roteamento, e submeter contrato técnico-funcional a aceite específico. **PF-I04-A2 e seguintes:** somente após aprovações separadas, implementar uma fatia vertical integrada de uso, sem criar infraestrutura paralela.

## 7. Governança
Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; CP314 canônico. Nenhuma mudança de gates. Referências: Docs. 287, 288, 298, 300, `templates/question-record.md`, `templates/routing-record.md` e encerramento PF-I03 registrado no `STATE.md`.
