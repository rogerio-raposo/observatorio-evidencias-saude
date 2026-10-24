# OES — primeiro vertical slice Django (experimental)

Escopo restrito do Documento 249: interface local **somente leitura**, fixtures documentais, nenhuma atualização científica, nenhum PostgreSQL/Neon/SQL, migração, acesso a PubMed/ClinicalTrials.gov, CI conectada, serviço pago ou produção.

## Execução local após disponibilizar Django 5.2 LTS

Requer Python 3.12 e Django 5.2.x instalado em ambiente virtual isolado.
`python manage.py runserver 127.0.0.1:8000`

Testes quando Django estiver disponível: `python manage.py test evidence.tests`. Não executar `migrate`: este aplicativo não configura banco e não define modelos ORM.

As fixtures são **extratos documentais** dos Docs. 247/248 e **não** reproduzem o JSON da API (não arquivado). O ID NCT01438697 associa Ritterband 2017 e Shaffer 2020 a um mesmo estudo previamente documentado. O ID NCT07836491 permanece sem identidade científica avaliada.

Configurações `DEBUG=True` e chave de desenvolvimento são intencionalmente locais; **não implantar**. Nenhuma garantia operacional/segurança/avaliação científica independente é reivindicada.


## Validação em navegador real (workflow manual)

O workflow .github/workflows/oes-django-real-browser-validation.yml instala Python
3.12, Django e Playwright/Chromium num runner descartável. Executa
python scripts/validate_browser.py a partir de applications/oes_web:
inicia Django somente em 127.0.0.1:8000, carrega CSS via Django, verifica
as três rotas (catálogo, NCT01438697, NCT07836491), as fontes documentais
sem acessá-las remotamente, a navegação, o foco de teclado e os layouts
desktop (1440 px), tablet (810 px) e celular (390 px).
São geradas nove screenshots, um results.json e o django-server.log em
browser-evidence/, disponibilizados como artifact de curta retenção mesmo
em caso de falha.

A instalação e o acionamento são atos separados: o workflow somente executa
com workflow_dispatch manual e autorização específica. Resultado PASS não
equivale a auditoria integral de acessibilidade, de segurança ou científica.
Não executar runserver/DEBUG em produção. Os 30 testes Django existentes
continuam em seu workflow independente.
