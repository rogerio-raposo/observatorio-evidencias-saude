# OES — Handoffs de Continuidade

**Status:** artefato operacional  
**Finalidade:** servir como **único ponteiro operacional** para a retomada do desenvolvimento do Observatório de Evidências em Saúde — OES.

## Arquitetura de continuidade

`Template canônico → README/pointer → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade → retomada controlada`

## Checkpoint vigente

**CP01 — 2026-10-03**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-03_CP01.md`

Checkpoint anterior:

**nenhum — checkpoint inaugural**

Status:

> vigente para continuidade operacional, sujeito ao Freshness Gate.

## Template canônico

Utilizar:

`archive/continuity/OES_Template_Abertura_Continuidade.md`

em **Modo Continuidade**.

## Procedimento de retomada

1. consultar este `README.md` para identificar o checkpoint vigente;
2. consultar o template canônico;
3. ler integralmente o checkpoint indicado;
4. aplicar o Freshness Gate contra a branch `main`;
5. consultar `STATE.md` e documentos canônicos materialmente relacionados;
6. apresentar o Diagnóstico de Continuidade;
7. se não houver alteração material, retomar exatamente do **Ponto exato de retomada**;
8. se houver alteração material, registrar a divergência e ajustar o ponto de retomada conforme a documentação canônica.

## Prompt operacional de retomada

> Consulte no repositório `rogerio-raposo/observatorio-evidencias-saude` o arquivo `archive/continuity/OES_Template_Abertura_Continuidade.md` e utilize-o em **Modo Continuidade**. Consulte `archive/handoffs/oes/README.md` para identificar o checkpoint vigente e leia integralmente o handoff indicado. Aplique o Freshness Gate contra a branch `main`, apresente primeiro o Diagnóstico de Continuidade e, se não houver alteração material, retome do **Ponto exato de retomada** registrado no checkpoint vigente.

## Política de checkpoint

- checkpoints são snapshots autônomos e imutáveis;
- todo novo CP referencia o anterior;
- checkpoints antigos permanecem preservados;
- este README é o único ponteiro para o checkpoint vigente;
- somente este README contém o prompt operacional de retomada;
- correções materiais geram novo CP;
- handoffs são operacionais e não normativos;
- Freshness Gate e Diagnóstico de Continuidade são obrigatórios;
- documentação canônica vigente prevalece sobre o checkpoint em caso de conflito.

## Histórico

- **CP01 — 2026-10-03:** checkpoint inaugural. Consolida a criação do repositório, os documentos 00–03 e 10, os templates operacionais iniciais e registra como ponto de retomada o documento 11 — Elegibilidade, Triagem e Seleção.
