# 04 — Governança de Garantia Metodológica, Aprovação e Revisão

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** Governança transversal  
**Status:** documento canônico inicial  
**Data:** 4 de outubro de 2026  
**Motivação:** adequar o OES à realidade operacional de projeto com um único humano não especialista, sem simular revisão científica independente.

---

# 1. Problema de governança

O OES foi inicialmente desenhado supondo que produtos N2–N4 poderiam receber revisão humana qualificada antes da publicação.

Essa premissa não é válida para a configuração atual do projeto:

- há apenas um humano diretamente envolvido;
- esse humano é o proprietário/governante do projeto;
- ele não possui formação especializada em revisão sistemática, ROBIS, RoB 2, GRADE ou bioestatística;
- portanto, não deve ser classificado nem utilizado como revisor metodológico especializado.

Regra central:

> **presença humana não equivale a revisão científica especializada.**

O OES não deverá criar um requisito formal que só possa ser satisfeito por uma aprovação nominal sem competência correspondente.

---

# 2. Princípio de não simulação

O OES não poderá:

- registrar o proprietário como methodological reviewer sem que ele possua essa qualificação;
- converter aprovação editorial/governamental em validação científica;
- registrar review independente quando não houver independência real;
- apresentar verificação por IA como peer review;
- apresentar segunda passagem da mesma arquitetura de IA como revisão humana;
- preencher qualificações fictícias para satisfazer publication gate;
- omitir a ausência de revisão especializada independente.

Quando expertise qualificada não estiver disponível:

> **a limitação deverá ser representada explicitamente como propriedade do processo de garantia.**

---

# 3. Três funções distintas

## 3.1 Verificação metodológica assistida por IA

Finalidade:

- revisar adversarialmente a análise inicial;
- procurar erros, inconsistências e extrapolações;
- verificar rastreabilidade de julgamentos;
- comparar evidência, appraisal, síntese, certainty e conclusão;
- testar explicações alternativas;
- verificar aderência aos instrumentos metodológicos;
- registrar pontos não resolvidos.

Características:

- é uma segunda passagem metodológica documentada;
- deve ser separada da geração inicial;
- não é independente no sentido de peer review;
- não é revisão humana;
- não autoriza alegação de expert review.

Código conceitual:

`ai_methodological_verification`

Decisões:

- `passed`;
- `revise`;
- `failed`.

---

## 3.2 Aprovação de governança do proprietário

Finalidade:

permitir que o proprietário confirme apenas aspectos compatíveis com sua função.

O proprietário poderá avaliar:

- se a pergunta corresponde ao objetivo pretendido;
- se o produto é compreensível;
- se limitações estão visíveis;
- se incerteza está comunicada;
- se o produto declara corretamente o uso de IA;
- se ausência de revisão especializada está explícita;
- se o produto não apresenta recomendação normativa não autorizada;
- se o produto está adequado para publicação dentro do escopo do OES.

O proprietário **não será solicitado a confirmar tecnicamente**:

- ROBIS;
- RoB 2;
- ROBINS-I/E;
- QUADAS;
- GRADE/CERQual;
- escolha de modelo meta-analítico;
- interpretação bioestatística especializada.

Código conceitual:

`owner_governance_approval`

Decisões:

- `approved`;
- `revise`;
- `rejected`.

---

## 3.3 Revisão especializada independente

Finalidade:

obter avaliação técnica por profissional qualificado que não seja o agente responsável pela análise inicial.

Código conceitual:

`expert_independent_review`

Características:

- opcional para publicação padrão N2 do OES;
- obrigatória quando a política do nível/produto ou finalidade externa exigir;
- deve registrar qualificação e conflitos de interesse;
- eleva o nível de garantia, mas não substitui rastreabilidade.

Decisões:

- `approved`;
- `revise`;
- `rejected`.

---

# 4. Níveis de garantia

O OES utilizará níveis de garantia separados do nível metodológico N0–N4.

## A0 — unverified

Situação:

- produto em elaboração;
- sem verificação metodológica concluída.

Não publicável como produto final.

## A1 — ai_methodological_reviewed

Requisitos:

- verificação metodológica assistida por IA concluída com `passed`;
- nenhuma verificação metodológica ativa em `revise` ou `failed`.

Não implica aprovação do proprietário.

## A2 — owner_approved

Requisitos:

- A1;
- aprovação de governança ativa do proprietário;
- nenhuma decisão ativa de owner `revise` ou `rejected`.

Interpretação:

> produto aprovado para publicação dentro do OES segundo processo metodológico assistido por IA e governança do proprietário, **sem revisão especializada independente**, salvo se A3 também estiver presente.

## A3 — expert_independent_reviewed

Requisitos:

- A2;
- revisão especializada independente ativa com `approved`;
- ausência de revisão especializada ativa `revise` ou `rejected`.

Interpretação:

> produto com revisão especializada independente registrada.

---

# 5. Relação entre N0–N4 e A0–A3

Profundidade metodológica e garantia são eixos diferentes.

| Nível metodológico | Garantia mínima para publicação padrão OES | Observação |
|---|---|---|
| N0 | A1 ou A2 conforme persistência/uso | não reivindica appraisal formal completo |
| N1 | A2 para produto persistente | expert review opcional |
| N2 | **A2** | ausência de expert review deve ser explícita |
| N3 | **A3** para produto formal | sem especialista, permanecer draft/experimental |
| N4 | **A3 + requisitos específicos de múltiplos revisores do protocolo** | owner não substitui avaliadores qualificados |

Regra:

> **o novo modelo não reduz os padrões de N3/N4.**

Ele apenas impede que o OES simule um especialista inexistente em N2.

---

# 6. Regra para produtos de alta criticidade

Mesmo em N2, A2 pode ser insuficiente quando o produto for destinado a:

- decisão clínica individual de alto risco;
- diretriz;
- política pública;
- incorporação de tecnologia;
- regulação;
- decisão institucional com potencial importante de dano;
- publicação científica que exija peer review metodológico independente.

Nesses casos:

> exigir A3 ou elevar o nível metodológico.

---

# 7. Verificação metodológica por IA — requisito de separação

A verificação metodológica deverá ser executada como etapa distinta da análise inicial.

Deverá:

1. receber a pergunta e protocolo;
2. receber o corpo de evidências e fontes;
3. receber os julgamentos iniciais;
4. procurar contraexemplos e inconsistências;
5. revisar cada julgamento material;
6. registrar concordâncias e discordâncias;
7. produzir decisão `passed`, `revise` ou `failed`;
8. deixar rastreável o modelo/versão/data quando disponível.

Não deverá ser descrita como “independente” apenas por ocorrer em uma nova execução.

---

# 8. Owner approval — escopo

A aprovação do proprietário é de:

> **governança, escopo e comunicação.**

Não de:

> **competência metodológica especializada.**

O formulário do proprietário deverá usar perguntas compreensíveis sem exigir treinamento em epidemiologia clínica.

Exemplos:

- A pergunta analisada é a pergunta que você pretendia responder?
- A conclusão é compreensível?
- As limitações estão visíveis?
- Está claro que existe incerteza?
- Está claro que não houve expert review?
- O texto evita prescrição/recomendação não autorizada?
- Você autoriza que este produto seja publicado dentro do OES sob esse nível de garantia?

---

# 9. Expert review opcional

A ausência de A3 não deverá impedir uma Ficha N2 padrão quando A2 estiver satisfeita.

Entretanto a saída deverá declarar:

> **Revisão especializada independente: não realizada.**

Quando A3 existir:

- nome/identificador do revisor;
- função/qualificação;
- independência;
- conflito de interesse;
- decisão;
- data;

deverão ser rastreáveis.

---

# 10. Transparência na saída

Toda Ficha publicada deverá expor o nível de garantia.

Para A2 sem A3, linguagem mínima:

> **Verificação metodológica:** processo OES assistido por IA.  
> **Aprovação de governança:** realizada pelo proprietário do projeto.  
> **Revisão especializada independente:** não realizada.

Essa informação não deverá ficar escondida apenas na auditoria técnica.

---

# 11. Modelo de dados

A estrutura recomendada é distinta de `product.review_record`.

Criar:

`product.assurance_record`

porque:

- AI verification não é human review;
- owner approval não é expert review;
- misturar as três funções em uma tabela chamada review_record obscureceria a natureza da garantia.

`product.review_record` continuará disponível para revisão especializada/humana detalhada e para compatibilidade histórica.

---

# 12. Publication gate N2

Para Ficha N2 padrão, o gate deverá exigir:

1. verificação metodológica AI ativa em `passed`;
2. owner governance approval ativa em `approved`;
3. nenhuma AI verification ativa em `revise` ou `failed`;
4. nenhuma owner approval ativa em `revise` ou `rejected`;
5. se existir expert review ativa:
   - `rejected` ou `revise` bloqueia;
   - `approved` eleva assurance para A3;
6. demais invariantes científicas já existentes;
7. publication_date apenas quando o conteúdo final estiver fechado.

O gate não exigirá A3 para N2 padrão.

---

# 13. Assurance level derivado

Não armazenar manualmente A0–A3 como verdade independente.

Derivar:

- A0 — requisitos de A1 ausentes;
- A1 — AI verification passed;
- A2 — A1 + owner approved;
- A3 — A2 + expert approved.

Isso reduz inconsistência entre rótulo e registros.

---

# 14. Caso Real 01

A regra anterior:

> revisão humana qualificada obrigatória antes da publicação

é substituída, para o Caso Real 01 N2, por:

1. verificação metodológica adversarial assistida por IA;
2. owner governance approval;
3. disclosure explícito de ausência de expert review;
4. expert review opcional.

O Documento 59 passa a ser:

> **pacote de revisão especializada independente opcional**

e não formulário destinado ao proprietário.

---

# 15. Limite de autonomia

A mudança não autoriza IA a:

- esconder incerteza;
- inventar dados;
- ignorar instrumentos;
- declarar consenso inexistente;
- promover N3/N4 sem requisitos correspondentes;
- produzir recomendação clínica individual;
- classificar sua própria revisão como independente.

---

# 16. Futuro

Se o projeto passar a contar com revisores qualificados:

- A3 poderá tornar-se rotina;
- testes de concordância IA × especialistas poderão ser executados;
- regras de autonomia poderão ser recalibradas com evidência empírica;
- requisitos de N3/N4 poderão ser operacionalizados integralmente.

---

# 17. Decisões consolidadas

1. humano não especialista não será tratado como revisor metodológico;
2. AI methodological verification, owner approval e expert review são funções distintas;
3. N2 padrão poderá ser publicado em A2;
4. A2 deverá declarar ausência de expert review quando aplicável;
5. N3/N4 mantêm requisitos especializados;
6. owner approval não valida ROBIS/RoB 2/GRADE;
7. expert review é opcional em N2 padrão e obrigatório quando criticidade/finalidade exigir;
8. assurance level será derivado;
9. publication gate será atualizado;
10. Caso Real 01 será reprocessado segundo esta governança antes de qualquer publicação.

---

**Regra central:** o OES deverá ser rigoroso também ao descrever os limites do próprio processo de garantia.
