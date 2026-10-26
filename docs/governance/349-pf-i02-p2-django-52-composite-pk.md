# Documento 349 — PF-I02/P2 — Compatibilidade Django 5.2 e PK composta do ledger
**Data:** 2026-10-26. **Base:** CP310, Docs.347–348; `applications/oes_web/requirements.txt` (`Django>=5.2,<5.3`, `psycopg[binary]>=3.2,<4`); workflow `oes-django-vertical-slice-validation.yml` (Python 3.12, instalação por requirements). Estudo estático; sem modelos criados, sem `makemigrations`, sem DB/Neon.

## Resultado
Django 5.2 possui `models.CompositePrimaryKey` (lançado nessa versão), que pode representar a PK `(actor_id,request_id)` do ledger sem adicionar coluna artificial. O requirements define intervalo 5.2.x, não uma versão patch exata: não presumir pin reproduzível de patch. Fonte oficial: https://docs.djangoproject.com/en/5.2/topics/composite-primary-key/ e https://docs.djangoproject.com/en/5.2/releases/5.2/.

Limitações da versão 5.2: `ForeignKey` convencional não representa FK que referencia uma PK composta; `ForeignObject` é API interna sem criação automática de constraints e requer cautela; alterações de PK após criar tabela não são suportadas pelo sistema de migrações; Admin de modelos com PK composta ainda não é suportado. As FKs compostas existentes no banco devem permanecer como constraints PostgreSQL, não serem duplicadas nem enfraquecidas no ORM.

## Implementação mínima preferida — decisão
1. Manter Django 5.2.x; **nenhum upgrade** motivado apenas pela PK do ledger.
2. Mapear as cinco tabelas com `Meta.managed=False`, sem gerar/aplicar migrações nem inventar PK substituta. Em `OesQuestionCommandReceipt`, `pk=models.CompositePrimaryKey('actor_id','request_id')` com campos declarados correspondentes.
3. Adotar `db_table` com schema PostgreSQL adequadamente identificado/escapado; a montagem SQL e o registro dos modelos devem ser provados em testes offline específicos de ORM antes de habilitar qualquer writer.
4. Não cadastrar ledger em Django Admin; não supor que modelo unmanaged reproduza automaticamente trigger, índice parcial ou FK composta.
5. Antes de código ORM, confirmar no ambiente de CI o patch Django instalado e a renderização de SQL sem DB conectado, incluindo referências entre schemas. A conexão existente `oes_synthetic_reader` é exclusivamente READ ONLY; `DATABASES={}` no modo padrão.
6. O protótipo SQL offline mantém status experimental histórico; reutilizar requisitos/142 testes como referência funcional, evitando duas implementações permanentes em paralelo.
7. O futuro G2 deverá avaliar o caminho mais simples via ORM com fronteira `transaction.atomic`; exige autorização própria. Nenhuma escrita conectada por esta decisão.

## Critério de aceite do próximo incremento
Criar pequeno conjunto de models **unmanaged offline** e testes de metadados/compilação SQL somente após definir nomes de campos e FKs compostas, manter checks/CI já existentes sem acesso ao banco. Não converter `managed=False` em autorização de escrita.

**Estado:** `DJANGO_52_COMPOSITE_PK_SUPPORTED_WITH_LIMITATIONS / MINIMAL_ORM_MAPPING_FEASIBLE / G2_NO_GO`. Marco B aberto, CP310 vigente, Fase 5 NOT_STARTED, readiness NOT_READY, E9 NO-GO.
