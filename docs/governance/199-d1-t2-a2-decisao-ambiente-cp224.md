# Documento 199 — D1-T2-A2: decisão sobre ambiente e limites de P2-C1 (CP224)

**2026-10-21 | DOCUMENTARY_ONLY | ENVIRONMENT_UNDECIDED | P2-C1 NOT_APPROVED | T2-A2 NOT_AUTHORIZED**

## 1. Fundamentação e alcance
Consolida três atividades documentais depois do CP223, sob `Prossiga`: pacote final de decisão P2-C1; revisão das premissas de persistência e isolamento de diretórios; comparação entre ambiente persistente dedicado e ambiente temporário reproduzível. Fontes canônicas: Documentos 197–198 e handoff CP223.

**Não houve aprovação de P2-C1**, escolha final de ambiente ou execução de instalação, driver, SQL, PostgreSQL, Neon, CI, cloud, migrações, dados reais ou custos nestas atividades. O inventário local relatado em conversas anteriores continua sem arquivo bruto de evidência no GitHub; nenhuma comprovação adicional de durabilidade intersessões foi produzida neste checkpoint.

## 2. Alternativas em deliberação
**A — Ambiente local persistente dedicado (preferencial, condicionado):** requer confirmação verificável de acesso entre sessões, isolamento, retenção, permissões, custo incremental zero, versão de sistema/runtime, descarte e possibilidade de reiniciar processos. Não pressupor existência ou acesso do assistente ao computador pessoal do proprietário.

**B — Ambiente temporário e descartável (alternativa válida):** admite testes sintéticos de atomicidade, idempotência e reinício de processos **na mesma sessão**, desde que instalação/reconstrução sejam reprodutíveis e as evidências revisadas sejam persistidas no GitHub. Não declarar persistência de arquivos entre sessões nem comprovação de recuperação entre sessões; `/mnt/data` não oferece durabilidade intersessões demonstrada.

**Nenhuma alternativa foi aprovada/selecionada.** Neon Free permanece excluído.

## 3. Componentes e esquema de preparação propostos
PostgreSQL 17, Psycopg 3, `libpq` compatível e `venv` experimental são **candidatos, não artefatos autorizados**. Identificar distribuição exata, versão, autenticidade, integridade, dependências, licença, mecanismo de isolamento, scripts com efeitos globais, diretórios e permissões antes de solicitar execução. Pacotes Debian podem iniciar serviços/criar cluster em pós-instalação; não presumir método inofensivo.

Caminhos `/mnt/data/oes-t2-a2/components/`, `venv/`, `inventory/` e `logs/` são **candidatos temporários não validados**, jamais locais operacionais aprovados. Não armazenar credenciais em repositório. Relatos anteriores de UID root e filesystem overlay são observações contextuais não substitutivas de evidência verificável.

## 4. Pacote deliberativo P2-C1 — NÃO APROVADO
Antes da eventual autorização, exigir: (i) opção A ou B formalmente escolhida; (ii) contexto técnico e persistência adequadamente verificados; (iii) artefatos e versões exatos, origem e hashes; (iv) caminhos e permissões; (v) procedimento sem efeitos globais ou lista expressa de efeitos a aprovar; (vi) custo incremental zero; (vii) plano seguro de rollback/descarte; (viii) lista taxativa de comandos autorizados e STOP conditions.

**Escopo máximo candidato de P2-C1:** disponibilizar somente componentes e ambiente virtual experimental em caminhos aprovados e verificar presença/versões, sem inicializar serviço ou cluster, criar objetos de banco, conectar ou executar SQL. Se depender de root, instalação global, alteração compartilhada, serviço, rede pública ou custo, STOP e nova decisão.

**Não autorizar implicitamente P2-C2** (servidor/cluster), P3 (adaptador/testes), P4 (parecer de encerramento), Neon ou qualquer promoção científica/operacional.

## 5. Estado científico e técnico preservado
T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` com 36 testes PASS históricos; T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` com 75 PASS históricos conjuntos (39+36); T2-A2 `NOT_AUTHORIZED`. Preservar idempotência de `create_scenario` devolvendo snapshot corrente, `pending` sem segunda avaliação do sinal, classes de exceção documentadas, S1–S6 restritos, sem equivalência SQL View. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`; 36 migrações `UNREVIEWED` e gates inalterados.

## 6. Continuidade
Após novo `Prossiga`, **uma atividade documental**: elaborar matriz de decisão para escolher A ou B, com critérios observáveis e recomendação baseada apenas em evidência disponível. Sem instalações, SQL, preflight operacional não autorizado ou seleção de ambiente por suposição. STOP.
