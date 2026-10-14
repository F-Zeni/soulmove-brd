// Consultar os usuarios cadastrados
SELECT u.usuario_id, u.nome, u.email, u.senha, TO_CHAR(u.data_cadastro, 'DD/MM/YYYY') As data_cadastro
    FROM TB_USUARIO u;
    
// Consultar carteiras e saldos de mobilidade
SELECT u.nome, c.carteira_id, c.saldo_mobilidade
    FROM TB_CARTEIRA c
        INNER JOIN TB_USUARIO u 
        ON u.usuario_id = c.usuario_id
        ORDER BY u.nome;
        
// Consultar tipos de veiculo e seus fatores de emissão
SELECT tv.tipo_veiculo_id, tv.nome, tv.fator_emissao, tv.flag_referencia
    FROM TB_TIPO_VEICULO tv
ORDER BY tv.fator_emissao DESC;

// Consultar viagens com usuario e tipo de veiculo
SELECT u.nome As usuario,
       tv.nome AS tipo_veiculo,
       v.origem,
       v.destino,
       v.km_percorrido,
       v.carbono_emitido,
       v.carbono_economizado,
       TO_CHAR(v.data_viagem, 'DD/MM/YYYY') As data_viagem
       FROM TB_VIAGEM v
         INNER JOIN TB_USUARIO u
                ON u.usuario_id = v.usuario_id
         INNER JOIN TB_TIPO_VEICULO tv
                ON tv.tipo_veiculo_id = v.tipo_veiculo_id
ORDER BY v.data_viagem DESC;

// Impacto ambiental por tipo veiculo
SELECT tv.nome As tipo_veiculo,
       COUNT(v.viagem_id) as qntd_viagens,
       NVL(SUM(v.km_percorrido), 0) AS km_total,
       NVL(SUM(v.carbono_emitido), 0) AS carbono_emitido_total,
       NVL(SUM(v.carbono_economizado), 0) AS carbono_economizado_total
            FROM TB_TIPO_VEICULO tv
            LEFT JOIN TB_VIAGEM v
                ON v.tipo_veiculo_id = tv.tipo_veiculo_id
GROUP BY tv.nome
ORDER BY carbono_economizado_total DESC;

// Carbono economizado por usuário
SELECT u.nome,
       COUNT(v.viagem_id) AS quantidade_viagens,
       NVL(SUM(v.km_percorrido), 0) AS km_total,
       NVL(SUM(v.carbono_economizado), 0) AS carbono_economizado_total
FROM TB_USUARIO u
LEFT JOIN TB_VIAGEM v ON v.usuario_id = u.usuario_id
GROUP BY u.usuario_id, u.nome
ORDER BY carbono_economizado_total DESC;

// Consultar tipos de missão e suas unidades de medida
SELECT tipo_missao_id, nome, descricao, unidade_medida
FROM TB_TIPO_MISSAO
ORDER BY nome;

// Consultar tipos de conquista cadastrados
SELECT tipo_conquista_id, nome, descricao
FROM TB_TIPO_CONQUISTA
ORDER BY nome;

// Consultar conquistas com seus respectivos tipos
SELECT c.conquista_id,
       tc.nome AS tipo_conquista,
       c.nome AS conquista,
       c.titulo,
       c.descricao
FROM TB_CONQUISTA c
JOIN TB_TIPO_CONQUISTA tc ON tc.tipo_conquista_id = c.tipo_conquista_id
ORDER BY tc.nome, c.nome;

// Consultar missões, metas, pontos, prazo e periodicidade
SELECT m.missao_id,
       m.titulo,
       tm.nome AS tipo_missao,
       tm.unidade_medida,
       m.meta_missao,
       m.pontos_missao,
       m.prazo_dias,
       m.periodicidade_dias,
       c.titulo AS titulo_conquista
FROM TB_MISSAO m
JOIN TB_TIPO_MISSAO tm ON tm.tipo_missao_id = m.tipo_missao_id
LEFT JOIN TB_CONQUISTA c ON c.conquista_id = m.conquista_id
ORDER BY m.titulo;

// Execuções de missão por usuário, incluindo progresso e status
SELECT u.nome AS usuario,
       m.titulo AS missao,
       um.status_missao,
       um.progresso_atual,
       m.meta_missao,
       um.pontuacao_recebida,
       TO_CHAR(um.data_inicio, 'DD/MM/YYYY') As data_inicio,
       TO_CHAR(um.data_conclusao, 'DD/MM/YYYY') As data_conclusao
FROM TB_USUARIO_MISSAO um
JOIN TB_USUARIO u ON u.usuario_id = um.usuario_id
JOIN TB_MISSAO m ON m.missao_id = um.missao_id
ORDER BY u.nome, m.titulo;

// Taxa de conclusão por missão
SELECT m.titulo,
       COUNT(um.usuario_missao_id) AS total_execucoes,
       SUM(CASE WHEN um.status_missao = 'concluida' THEN 1 ELSE 0 END) AS execucoes_concluidas,
       ROUND(
           100 * SUM(CASE WHEN um.status_missao = 'concluida' THEN 1 ELSE 0 END)
           / NULLIF(COUNT(um.usuario_missao_id), 0),
           1
       ) AS percentual_conclusao
FROM TB_MISSAO m
LEFT JOIN TB_USUARIO_MISSAO um ON um.missao_id = m.missao_id
GROUP BY m.missao_id, m.titulo
ORDER BY percentual_conclusao DESC NULLS LAST;

-- 13) Comprovantes e seus status de validação
SELECT u.nome AS usuario,
       m.titulo AS missao,
       c.status_validacao,
       c.data_envio,
       c.data_validacao
FROM TB_COMPROVANTE c
JOIN TB_USUARIO_MISSAO um ON um.usuario_missao_id = c.usuario_missao_id
JOIN TB_USUARIO u ON u.usuario_id = um.usuario_id
JOIN TB_MISSAO m ON m.missao_id = um.missao_id
ORDER BY c.data_envio DESC;

-- 14) Comprovantes aguardando validação
SELECT u.nome AS usuario,
       m.titulo AS missao,
       c.data_envio
FROM TB_COMPROVANTE c
JOIN TB_USUARIO_MISSAO um ON um.usuario_missao_id = c.usuario_missao_id
JOIN TB_USUARIO u ON u.usuario_id = um.usuario_id
JOIN TB_MISSAO m ON m.missao_id = um.missao_id
WHERE c.status_validacao = 'pendente'
ORDER BY c.data_envio;

-- 15) Conquistas desbloqueadas, tipo e título escolhido por usuário
SELECT u.nome AS usuario,
       tc.nome AS tipo_conquista,
       c.nome AS conquista,
       c.titulo,
       uc.flag_titulo_atual,
       uc.data_conquista
FROM TB_USUARIO_CONQUISTA uc
JOIN TB_USUARIO u ON u.usuario_id = uc.usuario_id
JOIN TB_CONQUISTA c ON c.conquista_id = uc.conquista_id
JOIN TB_TIPO_CONQUISTA tc ON tc.tipo_conquista_id = c.tipo_conquista_id
ORDER BY u.nome, uc.data_conquista;

-- 16) Resumo do usuário: pontos disponíveis, créditos e título atual
SELECT usuario_id,
       nome,
       email,
       pontos_totais,
       creditos_totais,
       NVL(titulo_atual, 'Sem título') AS titulo_atual
FROM VW_USUARIO_RESUMO
ORDER BY pontos_totais DESC;