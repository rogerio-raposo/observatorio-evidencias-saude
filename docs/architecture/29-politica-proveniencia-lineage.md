# 29 — Política de Proveniência e Lineage

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — política arquitetural  
**Data:** 3 de outubro de 2026

## 1. Finalidade

Definir como o OES registrará a origem, transformação, decisão e propagação da evidência.

> Uma conclusão relevante deve ser rastreável até a evidência e os processos que a produziram.

---

## 2. Conceitos

### Provenance

Responde:

- de onde veio este dado?
- quem/processo o produziu?
- como foi transformado?
- quando?
- com quais parâmetros?

### Lineage

Responde:

- em quais objetos este dado foi utilizado?
- que sínteses dependem dele?
- que avaliações de certeza dependem dessas sínteses?
- que produtos podem ser afetados?

Provenance e lineage são complementares.

---

## 3. Classes de provenance

### P1 — Source provenance

Origem documental:

- Report;
- página;
- tabela;
- figura;
- seção;
- registro externo.

### P2 — Extraction provenance

Como o dado entrou no OES:

- extrator;
- data;
- método;
- verificação;
- ferramenta.

### P3 — Derivation provenance

Transformações:

- fórmula;
- input;
- parâmetros;
- software;
- versão;
- código.

### P4 — Judgment provenance

Decisões metodológicas:

- elegibilidade;
- risco de viés;
- combinabilidade;
- certeza;
- adjudicação.

### P5 — Artifact provenance

Arquivos:

- origem;
- hash;
- ferramenta;
- versão;
- produtor.

### P6 — Dependency lineage

Relações:

`Report → Result → Synthesis → Certainty → Product`

---

## 4. Unidade física

`provenance.record` aponta para:

- `target_version_uuid`;
- `field_path`;
- fonte/processo;
- valor;
- transformação;
- ator;
- timestamp.

O alvo é uma versão concreta, não apenas a identidade.

---

## 5. Field path

Padrão candidato:

**JSON Pointer-like path** ou path estável equivalente.

Exemplos:

- `/reported_value`;
- `/ci_lower`;
- `/population_descriptor/age`;
- `/result_summary/effect`.

A convenção final deve evitar paths dependentes de posição de array quando a ordem puder mudar.

---

## 6. Localização de fonte

Quando possível registrar:

- Report ID/version;
- página;
- tabela;
- figura;
- seção;
- parágrafo/locator;
- célula;
- URL/fragment;
- timestamp de acesso quando relevante.

Não presumir paginação estável para HTML.

---

## 7. Valor original

Para campos críticos preservar:

- source_value;
- reported_value;
- derived_value, quando houver.

Transformação não substitui valor de origem.

---

## 8. Derivação

Toda transformação material registra:

- entradas;
- fórmula/método;
- parâmetros;
- software;
- software_version;
- código/artifact;
- responsável;
- data.

Reexecução deve ser possível quando os insumos estiverem disponíveis.

---

## 9. Provenance por nível N0–N4

### N0

Provenance agregada pode ser suficiente para exploração.

### N1

Fontes das afirmações materiais e data de corte devem ser rastreáveis.

### N2

Campos críticos de Result, síntese adotada e certeza precisam de provenance explícita.

### N3

Provenance de dados críticos, transformações e julgamentos materiais é obrigatória.

### N4

Provenance granular, verificável e reproduzível para dados/sínteses/julgamentos críticos.

A profundidade pode variar; a rastreabilidade essencial não é opcional.

---

## 10. Imutabilidade

Provenance material não deve ser corrigida por UPDATE destrutivo.

### Correção

Criar novo registro de provenance e preservar o anterior.

A PoC deverá evoluir `provenance.record` para suportar explicitamente:

- `status`;
- `supersedes_provenance_uuid`;
- `invalidated_at`;
- `invalidation_reason`.

Essa é uma alteração requerida antes da conclusão do Gate F2-B.

---

## 11. Artifact hash

Artefatos deverão possuir hash criptográfico.

Uso:

- verificar integridade;
- detectar alteração;
- identificar bytes idênticos;
- sustentar reprodutibilidade.

Hash não substitui identidade conceitual de Artifact.

---

## 12. Dependency lineage

As relações de domínio são a fonte primária:

- ResultSource;
- SynthesisContribution;
- Certainty link;
- Product links.

`provenance.dependency_edge` é uma projeção auxiliar.

Regra:

> dependency_edge deve ser regenerável a partir das relações canônicas.

Não editar manualmente para “corrigir” lineage.

---

## 13. Impact analysis

Evento gatilho:

- Report retratado;
- Result corrigido;
- Study fundido/dividido;
- Synthesis invalidada;
- Certainty alterada.

Processo:

1. identificar versão afetada;
2. atravessar dependências;
3. classificar objetos dependentes;
4. criar tarefa de reavaliação;
5. não alterar conclusão automaticamente;
6. registrar resolução.

---

## 14. Missing provenance

Estados candidatos:

- complete;
- partial;
- unavailable;
- not_applicable;
- legacy_unknown.

Ausência de provenance necessária deve gerar alerta de qualidade, não dado inventado.

---

## 15. IA

Quando IA participar:

registrar, conforme criticidade:

- tipo de uso;
- modelo/sistema;
- versão/configuração quando disponível;
- prompt/instrução material ou referência ao workflow;
- output relevante;
- revisão humana;
- decisão final.

IA não substitui a fonte científica.

---

## 16. Dados inferidos

Toda inferência deve ser marcada:

- reported;
- calculated;
- inferred;
- imputed;
- digitized;
- author_provided;
- machine_extracted.

O estado não deve ser perdido após harmonização.

---

## 17. Provenance de julgamento

Para decisões como Risk of Bias ou Certainty:

registrar:

- framework/versão;
- domínio;
- evidência considerada;
- rationale;
- avaliador;
- verificador;
- adjudicação;
- data.

---

## 18. Provenance de Product

Product version deve permitir recuperar:

- Investigation versions;
- Synthesis versions;
- Certainty versions;
- Applicability version quando houver;
- evidence cutoff;
- artifact renderizado.

---

## 19. Retenção

Provenance vinculada a versão publicada deve ser preservada enquanto o produto histórico permanecer auditável.

Política de retenção física detalhada será definida com governança/infraestrutura.

---

## 20. Requisitos para F2-B

Antes de aprovar o Gate:

1. adicionar supersession a provenance.record;
2. testar correção sem perda histórica;
3. testar lineage canônico;
4. comparar lineage canônico com dependency projection;
5. garantir que projeção divergente seja detectável/regenerável.

---

## 21. Decisão

> Provenance é dado de primeira classe do OES, não log opcional.

A implementação poderá variar, mas deverá preservar essa propriedade.
