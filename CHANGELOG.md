# Changelog

Este arquivo registra mudanças metodológicas consolidadas no Observatório de Evidências em Saúde — OES.

Durante a fase de concepção, os documentos são vivos e o histórico Git preserva alterações intermediárias. Entradas neste changelog correspondem a marcos ou decisões consolidadas relevantes.

## 2026-10-03 — Inicialização do repositório

### Adicionado

- Repositório definido como fonte canônica do projeto.
- README com visão geral, fluxo metodológico e arquitetura documental prevista.
- Documento 00 — Concepção.
- Documento 01 — Escopo Científico e Taxonomia das Perguntas.
- Documento 02 — Arquitetura de Níveis de Investigação e Produtos.
- Documento 03 — Entrada, Triagem e Roteamento Metodológico.
- Documento 10 — Busca e Recuperação de Evidências.

### Decisões estruturais registradas

- Metodologia antes da automação.
- Pergunta científica precede busca definitiva.
- Ausência de pirâmide universal de evidência.
- Risco de viés e certeza do corpo de evidências são processos distintos.
- Profundidade N0–N4 e manutenção M0–M3 são dimensões independentes.
- Ficha de Evidência é candidata à unidade persistente central.
- Roteamento inicial baseado em regras e justificativa, sem score numérico.
- Estudo e publicação serão entidades distintas.
- Busca científica deverá ser auditável e proporcional ao nível de investigação.
- IA será ferramenta de apoio, não fonte de evidência.


## 2026-10-03 — Mecanismo formal de continuidade

### Adicionado

- Template canônico de abertura e continuidade.
- Arquitetura `snapshot + pointer` para checkpoints.
- Ponteiro operacional único em `archive/handoffs/oes/README.md`.
- Checkpoint inaugural `CP01`.
- Freshness Gate obrigatório antes de retomadas.
- Diagnóstico de Continuidade obrigatório.
- Separação entre `STATE.md` (painel vivo) e checkpoints (snapshots imutáveis).

### Regra operacional

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

Checkpoints são artefatos operacionais e não normativos. A documentação canônica vigente prevalece em caso de conflito.


## 2026-10-03 — Documento 11: Elegibilidade, Triagem e Seleção

### Adicionado

- `docs/methodology/11-elegibilidade-triagem-selecao.md`.
- `templates/screening-record.md`.

### Decisões metodológicas

- critérios de elegibilidade pré-especificados para investigações formais;
- separação entre registro, relatório/publicação e estudo;
- triagem inicial orientada à sensibilidade;
- dúvida em título/resumo favorece avanço para texto completo;
- relatório não recuperado não equivale a estudo excluído;
- ausência de dado utilizável não implica inelegibilidade;
- motivos de exclusão de texto completo devem ser explícitos;
- múltiplos relatórios devem ser vinculados a um Study ID;
- N4 exige dois revisores independentes para decisão final por texto completo;
- N3 pode utilizar triagem abreviada calibrada e declarada;
- IA pode priorizar e assistir, mas não recebe autorização geral para exclusão silenciosa em N2–N4;
- PRISMA é referência para rastreabilidade do fluxo de seleção.

### Próxima etapa

- Documento 12 — Avaliação de Risco de Viés e Qualidade Metodológica.
