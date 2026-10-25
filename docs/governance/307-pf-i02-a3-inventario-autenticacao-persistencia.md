# Documento 307 — PF-I02-A3: inventário de autenticação e persistência para Q0→Q1

**Data:** 2026-10-25. **Natureza:** diagnóstico técnico read-only e recomendação de sequenciamento; sem autorização para código, SQL, grants, contas, serviços ou deploy. **Base:** CP297, Doc. 306.

## Verificações no repositório
- `applications/oes_web/config/settings.py`: `INSTALLED_APPS=['django.contrib.staticfiles','evidence']`, sem `django.contrib.auth`/sessions; middleware apenas CommonMiddleware; `DATABASES={}` normalmente; `DEBUG=True` e secret de desenvolvimento. O caminho PG-A4 opcional, `oes_synthetic_reader`, força `default_transaction_read_only=on`, sem autorização de escrita.
- `evidence/urls.py` e `services.py`: consultas documentais GET/fixtures e N2 offline; nenhuma rota Q0/Q1 ou identidade operacional autorizada.
- `database/poc-s1.sql`: `core.entity` e `core.entity_version` têm `created_by`, versão numérica, vínculo de supersessão e unicidade; `investigation.question_version` oferece `original_text`, `normalized_text` e contexto, mas não provê por si só identidade Django, admissão E2, Q2, aprovação nem transações HTTP auditadas.
- `prototypes/d1_t2/a1/repository.py`: repository e Unit of Work in-memory com revisão/conflito para ensaio isolado; não equivale a armazenamento durável ou múltiplos processos.
- `.github/workflows/d2-e6-g2-i1-authentication-disabled.yml`: preflight de autenticação experimental permanece hard-disabled; não deve ser confundido com login de usuário Django. O roundtrip sintético E6 usa sessões injetadas e não autoriza escrita Question.

## Parecer de reutilização
1. **Reutilizar** Django existente como camada HTTP, `core.entity/version` e `investigation.question/version` como base conceitual do domínio e PostgreSQL como destino arquitetural, mediante revisão formal de schema e papéis.
2. **Não reutilizar como produção** PG-A4 (somente leitura), workflow de autenticação técnica E6, Unit of Work em memória ou segredos de desenvolvimento para escrita preparatória.
3. A fronteira de autorização humana, vínculo ator→ação→versão, transação consistente e recuperação após falha **ainda precisa ser implementada e comprovada**. A simples presença de colunas `created_by` não constitui trilha confiável.

## Primeiro incremento funcional recomendado
`PF-I02-I01`: Q0→Q1 para **um preparador autorizado**, sem Q2, routing, Investigation, E9 ou captura factual:
- criar Q0 exatamente como recebido, ID único, timestamp e autor autenticado;
- propor Q1 como nova versão lógica sem alterar Q0;
- leitura controlada e histórico com justificativa;
- negar escrita a leitor/anônimo, falhar fechado e impedir E9;
- validar revisão concorrente e atomicidade antes de conectar um banco real.
Não construir múltiplos repositórios alternativos, interface fictícia ou automação científica.

## Gates concretos e ordem recomendada
**G1 — Identidade/aplicação:** escolher autenticação Django real e configuração segura; papel mínimo de preparador separado do leitor; CSRF, sessão, política de acesso e audit trail. Definir ambiente local restrito versus hospedagem; `DEBUG=True` não serve para deployment.
**G2 — Dados:** mapear mudanças mínimas necessárias no esquema Question/version para garantir Q0/Q1, autoria, imutabilidade, idempotência, concorrência e rollback; explicitar migrações/ownership sem executá-las.
**G3 — Conexão e autorização:** revisar usuário DB de escrita com permissões mínimas, credenciais separadas, SSL e segredo seguro; não aproveitar a identidade sintética E6 nem elevar PG-A4.
**G4 — Execução aprovada separadamente:** só após aprovação dos gates implementar primeiro caminho transacional + testes de sucesso/falha e regressões PF-I01. Sem E9 em rotas ou SQL.

## Decisão proposta ao responsável
Adotar **Django + PostgreSQL, com autenticação de usuário antes de qualquer POST persistente**, como direção de PF-I02-I01; manter desenho e verificações em modo documental até autorização específica dos gates de segurança e dados. Evitar novo piloto exclusivamente em memória: não fecharia a lacuna de persistência real identificada no Doc. 306.

Marco B aberto; E9 NO-GO; A3 ausente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
