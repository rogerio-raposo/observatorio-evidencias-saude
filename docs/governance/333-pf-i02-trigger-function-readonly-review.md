# Documento 333 — PF-I02: revisão READ ONLY da função do trigger

Data: 2026-10-26. Referência: CP302 e Documento 332. Freshness Gate: main idêntico a 0b78b8f35a4154c5194a72b141f18e71fe13b326.

Ambiente: Neon weathered-boat-65779510, branch br-gentle-hall-b6jaxehf, database oes_sandbox. Transação READ ONLY confirmada.

Função core.assert_entity_type(): propriedade oes_sandbox_owner, LANGUAGE plpgsql, SECURITY INVOKER (prosecdef=false), proconfig null e ACL null. Definição inspecionada: SELECT e.entity_type FROM core.entity e WHERE e.entity_uuid = NEW.entity_uuid; compara com TG_ARGV[0] e retorna NEW ou erro. Nome de tabela qualificado; não contém SQL dinâmico. O search_path da sessão inspecionada era "$user", public; função não define search_path próprio. Schemas core e investigation sem PUBLIC USAGE ou CREATE. Schema public possui USAGE público e não CREATE público. Consulta precedente confirmou EXECUTE efetivo por PUBLIC nessa função.

Avaliação: não foi identificada elevação por SECURITY DEFINER ou resolução não qualificada da tabela core.entity. A função depende dos privilégios de leitura do chamador em core.entity; o futuro writer necessitará direito apropriado, limitado e verificado. EXECUTE por PUBLIC não demonstra isoladamente capacidade de consultar ou modificar dados, e não justifica REVOKE automático. Não foi executado teste conectado sob writer independente, pois tal identidade ainda não existe.

Estado: TRIGGER_FUNCTION_READ_ONLY_REVIEW_COMPLETE. W2a provisionamento permanece HOLD até decisão explícita sobre política de leitura, privilégios efectivos e identidade independente. Nenhuma alteração SQL, GRANT, REVOKE, papel, Django, E9 ou custo pago. Marco B aberto, readiness NOT_READY.
