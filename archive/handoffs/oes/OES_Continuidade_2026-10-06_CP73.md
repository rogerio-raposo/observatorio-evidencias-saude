# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP73  
**Checkpoint anterior:** CP72  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Especificação Científica e Funcional inicial do Monitor de Evidências

## 1. Marco

> **MONITOR DE EVIDÊNCIAS — ESPECIFICAÇÃO CIENTÍFICA E FUNCIONAL INICIAL CONCLUÍDA.**

Documento:

`docs/products/165-especificacao-monitor-evidencias.md`

O Monitor foi definido como produto/processo de manutenção M2/M3, não como novo nível de profundidade.

## 2. Decisões congeladas

- Monitor não é N5;
- opera somente em M2/M3;
- deve possuir alvo científico rastreável;
- Monitoring Cycle é distinto de ProductVersion científica;
- ausência de mudança material não cria automaticamente nova ProductVersion;
- `product.currency_state` deve ser reutilizado para currentness;
- mudança científica material continua ocorrendo por versionamento do alvo;
- Monitor não altera conclusão silenciosamente;
- Monitor e Alerta de Evidência permanecem distintos;
- assurance do alvo não valida automaticamente cada ciclo;
- IA não pode fabricar execução de busca, evidência ou verificação humana;
- thresholds temporais/quantitativos gerais permanecem reservados à Fase 4;
- nenhuma migration está autorizada antes da revisão arquitetural.

## 3. Relação com OES-P1

Estruturas existentes que deverão ser reutilizadas quando possível:

- `investigation.investigation_version.maintenance_level`;
- Question/Investigation;
- Search e provenance;
- Product/ProductVersion;
- `product.currency_state`;
- `product.version_change_class`.

A especificação não congelou ainda:

- Product type físico;
- modelagem de Monitoring Cycle;
- vínculo formal Monitor → alvo;
- representação de referências detectadas antes de inclusão;
- vínculo Monitor → futuro Alerta;
- assurance próprio do processo de Monitor.

## 4. Fronteira Fase 3 × Fase 4

Fase 3:

- define produto;
- semântica;
- arquitetura;
- contrato de dados;
- projeção/renderização;
- validação técnica.

Fase 4 permanece responsável por:

- protocolo transversal de atualização;
- gatilhos temporais;
- thresholds quantitativos;
- cadências padrão;
- regras gerais de escalonamento.

## 5. Próxima etapa

> **Executar revisão de coerência científica e arquitetural do Monitor de Evidências contra OES-P1, Product/Investigation, Search, provenance, currency_state, version_change_class e a fronteira Fase 3 × Fase 4.**

Somente depois:

> **definir o Contrato de Dados v0.1 do Monitor de Evidências.**

## 6. Protocolo anti-interrupção

Na retomada:

1. executar Freshness Gate;
2. não repetir operações sem verificar persistência;
3. ler Documento 165;
4. preservar a separação Monitor × atualização científica × Alerta;
5. não criar migration antes da revisão arquitetural;
6. atualizar STATE/CHANGELOG/pointer em novo marco.

**Fim do CP73**
