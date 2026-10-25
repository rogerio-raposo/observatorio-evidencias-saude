# Documento 288 — Regra de escopo do piloto e diferimento de requisitos de produção

**Data:** 2026-10-25. **Origem:** orientação expressa do responsável pelo OES, posterior ao CP283 e Documento 287.

## Deliberação
O piloto deve **priorizar a demonstração de seu objetivo central**, sem tentar antecipar a solução de problemas de arquitetura, autenticação, operação e integração que possam ser tratados de maneira mais simples com a stack completa definida ou em definição. Não desenvolver infraestrutura provisória complexa, contornos específicos do ambiente experimental ou abstrações especulativas apenas para superar limitações temporárias.

## Regra de diferimento controlado
1. Requisitos relevantes **explicitamente excluídos ou diferidos do piloto** não são cancelados nem considerados atendidos. Registrar o requisito, a razão de diferimento e o momento de reavaliação em inventário de decisões e requisitos, a ser consolidado durante a definição ou implantação da stack completa.
2. A **reavaliação obrigatória ocorre quando a stack completa estiver sendo definida ou já estiver definida**, antes da correspondente liberação operacional/produção. Nesse momento determinar necessidade, desenho, implementação, testes e evidências reais no ambiente pertinente.
3. O exemplo atual é a autenticação com duas identidades independentes (Documento 287), anteriormente requerida no Documento 285. A decisão de diferimento permanece, sem estabelecer esse mecanismo como requisito do piloto inicial.
4. Outros requisitos diferidos anteriormente deverão ser identificados **com base nas decisões canônicas efetivas**, sem presumir lista exaustiva nem inventar decisões. Fica instituído o compromisso de inventariá-los na revisão de stack.

## Critério de seleção de trabalho durante o piloto
Antes de qualquer implementação ou gate técnico, perguntar:
- É essencial para demonstrar a hipótese e a cadeia mínima de preservação, integridade e proveniência do piloto?
- A solução depende de uma decisão de stack que ainda não foi tomada?
- É um risco concreto que precisa ser mitigado **agora** ou apenas uma preocupação de produção futura?
- O custo e a complexidade do contorno temporário são proporcionais ao benefício demonstrável?

**Se não for indispensável ao piloto e puder ser resolvido normalmente pela stack definitiva, diferir e registrar; não criar workaround.** Não confundir testes experimentais úteis com validação de prontidão operacional.

## Limites de segurança
Esta regra **não** libera captura factual, exposição de payload, alteração de dados/roles/grants/credenciais, operação conectada, workflows bloqueados ou serviços pagos. Controles mínimos necessários à integridade do próprio experimento e ao seu isolamento devem permanecer. Qualquer diminuição de controle já formalizado exige decisão explícita, com documento substitutivo quando cabível.

## Aplicação imediata a D2-I-C
Reformular o gate com foco na demonstração mínima de preservação e verificação privada de dados sintéticos. Não converter o ensaio em exercício de engenharia de identidades, infraestrutura temporária ou soluções de deploy. Revalidar os requisitos diferidos na etapa de stack completa, e não exigir agora provas desconectadas da finalidade principal do piloto.

## Continuidade
Documento 288 complementa Documento 287 e a decisão de deferimento do Documento 285; **não altera automaticamente os demais gates de segurança vigentes**. O checkpoint CP283 permanece o último handoff publicado, até novo checkpoint.
