/*
Grande parte desses SELECT são usados na nossa API em Java, então os id's são apenas de exmeplo que existem no DML, mas na API são substituidos por '?' já que não pré-selecionamos os id's antes,
então se um SELECT estiver vazio é por causa disso.
*/

/* Consultar os usuarios cadastrados */
SELECT u.usuario_id, u.nome, u.email, TO_CHAR(u.data_cadastro, 'DD/MM/YYYY') As data_cadastro
    FROM TB_USUARIO u;
    
/* Consultar carteiras e saldos de mobilidade */
SELECT u.nome, c.carteira_id, c.saldo_mobilidade
    FROM TB_CARTEIRA c
        INNER JOIN TB_USUARIO u 
        ON u.usuario_id = c.usuario_id
        ORDER BY u.nome;
        
/* Consultar tipos de veiculo e seus fatores de emissão */
SELECT tv.tipo_veiculo_id, tv.nome, tv.fator_emissao, tv.flag_referencia
    FROM TB_TIPO_VEICULO tv
ORDER BY tv.fator_emissao DESC;

/* Consultar viagens com usuario e tipo de veiculo */
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

/* Impacto ambiental por tipo veiculo */
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

/* Carbono economizado por usuário */
SELECT u.nome,
       COUNT(v.viagem_id) AS quantidade_viagens,
       NVL(SUM(v.km_percorrido), 0) AS km_total,
       NVL(SUM(v.carbono_economizado), 0) AS carbono_economizado_total
FROM TB_USUARIO u
LEFT JOIN TB_VIAGEM v ON v.usuario_id = u.usuario_id
GROUP BY u.usuario_id, u.nome
ORDER BY carbono_economizado_total DESC;

/* Consultar tipos de missão e suas unidades de medida */
SELECT tipo_missao_id, nome, descricao, unidade_medida
    FROM TB_TIPO_MISSAO
ORDER BY nome;

/* Consultar tipos de conquista cadastrados */
SELECT tipo_conquista_id, nome, unidade_medida, descricao
    FROM TB_TIPO_CONQUISTA
ORDER BY nome;

/* Consultar conquistas com seus respectivos tipos */
SELECT c.conquista_id,
       tc.nome AS tipo_conquista,
       c.nome AS conquista,
       c.titulo,
       c.descricao
    FROM TB_CONQUISTA c
        JOIN TB_TIPO_CONQUISTA tc 
            ON tc.tipo_conquista_id = c.tipo_conquista_id
ORDER BY tc.nome, c.nome;

/* Consultar missões, metas, pontos, prazo e periodicidade */
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
        JOIN TB_TIPO_MISSAO tm 
            ON tm.tipo_missao_id = m.tipo_missao_id
        LEFT JOIN TB_CONQUISTA c
            ON c.conquista_id = m.conquista_id
ORDER BY m.titulo;

/* Execuções de missão por usuário, incluindo progresso e status */
SELECT u.nome AS usuario,
       m.titulo AS missao,
       um.status_missao,
       um.progresso_atual,
       m.meta_missao,
       um.pontuacao_recebida,
       TO_CHAR(um.data_inicio, 'DD/MM/YYYY') As data_inicio,
       TO_CHAR(um.data_conclusao, 'DD/MM/YYYY') As data_conclusao
    FROM TB_USUARIO_MISSAO um
        JOIN TB_USUARIO u 
            ON u.usuario_id = um.usuario_id
        JOIN TB_MISSAO m 
            ON m.missao_id = um.missao_id
ORDER BY u.nome, m.titulo;

/* Comprovantes e seus status de validação */
SELECT u.nome AS usuario,
       m.titulo AS missao,
       c.status_validacao,
       c.data_envio,
       c.data_validacao
    FROM TB_COMPROVANTE c
        JOIN TB_USUARIO_MISSAO um 
            ON um.usuario_missao_id = c.usuario_missao_id
        JOIN TB_USUARIO u 
            ON u.usuario_id = um.usuario_id
        JOIN TB_MISSAO m 
            ON m.missao_id = um.missao_id
ORDER BY c.data_envio DESC;

-- Comprovantes aguardando validação
SELECT u.nome AS usuario,
       m.titulo AS missao,
       c.data_envio
    FROM TB_COMPROVANTE c
        JOIN TB_USUARIO_MISSAO um 
            ON um.usuario_missao_id = c.usuario_missao_id
        JOIN TB_USUARIO u 
            ON u.usuario_id = um.usuario_id
        JOIN TB_MISSAO m 
            ON m.missao_id = um.missao_id
    WHERE c.status_validacao = 'pendente'
ORDER BY c.data_envio;

-- Conquistas desbloqueadas, tipo e título escolhido por usuário
SELECT u.nome AS usuario,
       tc.nome AS tipo_conquista,
       c.nome AS conquista,
       c.titulo,
       uc.flag_titulo_atual,
       uc.data_conquista
    FROM TB_USUARIO_CONQUISTA uc
        JOIN TB_USUARIO u 
            ON u.usuario_id = uc.usuario_id
        JOIN TB_CONQUISTA c 
            ON c.conquista_id = uc.conquista_id
        JOIN TB_TIPO_CONQUISTA tc 
            ON tc.tipo_conquista_id = c.tipo_conquista_id
ORDER BY u.nome, uc.data_conquista;

-- Resumo do usuário: pontos disponíveis, créditos e título atual
SELECT usuario_id,
       nome,
       email,
       pontos_totais,
       creditos_totais,
       NVL(titulo_atual, 'Sem título') AS titulo_atual
    FROM VW_USUARIO_RESUMO
ORDER BY pontos_totais DESC;

/* Busca uma conquista pelo ID, incluindo os dados de seu tipo. */
SELECT c.conquista_id, c.pontos, c.nome, c.titulo, c.descricao, c.meta,
       t.tipo_conquista_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida
    FROM TB_CONQUISTA c
        INNER JOIN TB_TIPO_CONQUISTA t 
            ON t.tipo_conquista_id = c.tipo_conquista_id
    WHERE c.conquista_id = 3;

/* Lista todas as conquistas com os dados de seus tipos. */
SELECT c.conquista_id, c.pontos, c.nome, c.titulo, c.descricao, c.meta,
       t.tipo_conquista_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida
    FROM TB_CONQUISTA c
        INNER JOIN TB_TIPO_CONQUISTA t 
            ON t.tipo_conquista_id = c.tipo_conquista_id
ORDER BY c.nome;

/* Lista conquistas desbloqueadas pelo usuário informado. */
SELECT c.conquista_id, c.pontos, c.nome, c.titulo, c.descricao, c.meta,
       t.tipo_conquista_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida
    FROM TB_CONQUISTA c
        INNER JOIN TB_TIPO_CONQUISTA t 
            ON t.tipo_conquista_id = c.tipo_conquista_id
    WHERE c.conquista_id IN (
        SELECT uc.conquista_id
            FROM TB_USUARIO_CONQUISTA uc
        WHERE uc.usuario_id = 3
)
ORDER BY c.nome;

/* Lista conquistas ainda não desbloqueadas pelo usuário informado. */
SELECT c.conquista_id, c.pontos, c.nome, c.titulo, c.descricao, c.meta,
       t.tipo_conquista_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida
    FROM TB_CONQUISTA c
        INNER JOIN TB_TIPO_CONQUISTA t 
            ON t.tipo_conquista_id = c.tipo_conquista_id
    WHERE c.conquista_id NOT IN (
        SELECT uc.conquista_id
            FROM TB_USUARIO_CONQUISTA uc
        WHERE uc.usuario_id = 3
)
ORDER BY c.nome;

/* Busca uma missão pelo ID com seu tipo e unidade de medida. */
SELECT m.missao_id, m.pontos_missao, m.titulo, m.descricao,
       m.meta_missao, m.periodicidade_dias, m.prazo_dias, m.imagem_missao_id,
       t.tipo_missao_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida AS tipo_unidade_medida
    FROM TB_MISSAO m
        INNER JOIN TB_TIPO_MISSAO t 
        ON t.tipo_missao_id = m.tipo_missao_id
    WHERE m.missao_id = 3;

/* Lista todas as missões com tipo, unidade, prazo, periodicidade e conquista associada. */
SELECT m.missao_id, m.pontos_missao, m.titulo, m.descricao,
       m.meta_missao, m.periodicidade_dias, m.prazo_dias, m.imagem_missao_id,
       t.tipo_missao_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida AS tipo_unidade_medida,
       c.titulo AS titulo_conquista
    FROM TB_MISSAO m
        INNER JOIN TB_TIPO_MISSAO t 
        ON t.tipo_missao_id = m.tipo_missao_id
    LEFT JOIN TB_CONQUISTA c 
        ON c.conquista_id = m.conquista_id
ORDER BY m.titulo;

/* Lista missões pendentes ou em andamento para um usuário específico. */
SELECT m.missao_id, m.pontos_missao, m.titulo, m.descricao,
       m.meta_missao, m.periodicidade_dias, m.prazo_dias, m.imagem_missao_id,
       t.tipo_missao_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida AS tipo_unidade_medida
    FROM TB_USUARIO u
        INNER JOIN TB_USUARIO_MISSAO um 
            ON um.usuario_id = u.usuario_id
        INNER JOIN TB_MISSAO m 
            ON m.missao_id = um.missao_id
        INNER JOIN TB_TIPO_MISSAO t 
            ON t.tipo_missao_id = m.tipo_missao_id
    WHERE um.status_missao IN ('pendente', 'em andamento')
        AND u.usuario_id = 3
ORDER BY m.titulo;

/* Lista as missões concluídas pelo usuário informado. */
SELECT m.missao_id, m.pontos_missao, m.titulo, m.descricao,
       m.meta_missao, m.periodicidade_dias, m.prazo_dias, m.imagem_missao_id,
       t.tipo_missao_id, t.nome AS tipo_nome,
       t.descricao AS tipo_descricao, t.unidade_medida AS tipo_unidade_medida
    FROM TB_MISSAO m
        INNER JOIN TB_TIPO_MISSAO t 
            ON t.tipo_missao_id = m.tipo_missao_id
    INNER JOIN TB_USUARIO_MISSAO um 
        ON um.missao_id = m.missao_id
    WHERE um.usuario_id = 3
        AND um.status_missao = 'concluida'
ORDER BY m.titulo;

/* Busca um tipo de missão pelo nome exato. */
SELECT tipo_missao_id, nome, descricao, unidade_medida
    FROM TB_TIPO_MISSAO
    WHERE nome = 'economia_co2';

/* Lista os tipos de missão cadastrados. */
SELECT tipo_missao_id, nome, descricao, unidade_medida
    FROM TB_TIPO_MISSAO
ORDER BY nome;

/* Verifica a existência de um tipo de missão pelo nome.
   Na API, a ausência de linhas pode ser tratada como false. */
SELECT tipo_missao_id
    FROM TB_TIPO_MISSAO
WHERE nome = 'economia_co2';

/* Busca o usuário por ID com carteira, título selecionado e resumo de pontos. */
SELECT u.usuario_id, u.nome, u.email, u.senha, u.data_cadastro,
       vw.pontos_totais AS pontos,
       c.conquista_id, c.nome AS conquista_nome, c.titulo AS conquista_titulo,
       c.descricao AS conquista_descricao, c.pontos AS conquista_pontos,
       uc.data_conquista AS conquista_data,
       ca.carteira_id, ca.saldo_mobilidade
    FROM TB_USUARIO u
        LEFT JOIN TB_CARTEIRA ca 
            ON ca.usuario_id = u.usuario_id
        LEFT JOIN TB_USUARIO_CONQUISTA uc
            ON uc.usuario_id = u.usuario_id AND uc.flag_titulo_atual = 'S'
        LEFT JOIN TB_CONQUISTA c 
            ON c.conquista_id = uc.conquista_id
        LEFT JOIN VW_USUARIO_RESUMO vw 
            ON vw.usuario_id = u.usuario_id
    WHERE u.usuario_id = 3;

/* Busca o usuário por e-mail com carteira, título selecionado e resumo de pontos. */
SELECT u.usuario_id, u.nome, u.email, u.senha, u.data_cadastro,
       vw.pontos_totais AS pontos,
       c.conquista_id, c.nome AS conquista_nome, c.titulo AS conquista_titulo,
       c.descricao AS conquista_descricao, c.pontos AS conquista_pontos,
       uc.data_conquista AS conquista_data,
       ca.carteira_id, ca.saldo_mobilidade
    FROM TB_USUARIO u
        LEFT JOIN TB_CARTEIRA ca 
            ON ca.usuario_id = u.usuario_id
        LEFT JOIN TB_USUARIO_CONQUISTA uc
            ON uc.usuario_id = u.usuario_id AND uc.flag_titulo_atual = 'S'
        LEFT JOIN TB_CONQUISTA c 
            ON c.conquista_id = uc.conquista_id
        LEFT JOIN VW_USUARIO_RESUMO vw 
            ON vw.usuario_id = u.usuario_id
WHERE u.email = 'marcelo@gmail.com';

/* Consulta o histórico agregado do usuário.
   VW_USUARIO_HISTORICO deve existir e conter as colunas usadas abaixo. */
SELECT kg_CO2, trajetos, missoes
    FROM VW_USUARIO_HISTORICO
WHERE usuario_id = 3;

/* Consulta o histórico de viagens de um usuário, com os dados do tipo de transporte. */
SELECT v.viagem_id, v.data_viagem, v.origem, v.destino,
       tv.nome AS tipo_veiculo, v.km_percorrido,
       v.carbono_economizado, v.carbono_emitido,
       u.usuario_id, u.nome AS usuario_nome, u.email AS usuario_email,
       u.data_cadastro AS usuario_data_cadastro
    FROM TB_VIAGEM v
        INNER JOIN TB_USUARIO u 
            ON u.usuario_id = v.usuario_id
        INNER JOIN TB_TIPO_VEICULO tv 
            ON tv.tipo_veiculo_id = v.tipo_veiculo_id
    WHERE v.usuario_id = 3
ORDER BY v.data_viagem DESC;

/* Busca uma viagem pelo ID, com os dados do usuário e do tipo de transporte. */
SELECT v.viagem_id, v.data_viagem, v.origem, v.destino,
       tv.nome AS tipo_veiculo, v.km_percorrido,
       v.carbono_economizado, v.carbono_emitido,
       u.usuario_id, u.nome AS usuario_nome, u.email AS usuario_email,
       u.data_cadastro AS usuario_data_cadastro
    FROM TB_VIAGEM v
        INNER JOIN TB_USUARIO u 
            ON u.usuario_id = v.usuario_id
        INNER JOIN TB_TIPO_VEICULO tv 
            ON tv.tipo_veiculo_id = v.tipo_veiculo_id
    WHERE v.viagem_id = 3;

/* Busca o conteúdo binário e o tipo MIME de uma imagem de missão. */
SELECT dados_imagem, tipo_mime
    FROM TB_IMAGEM_MISSAO
WHERE imagem_missao_id = 1;