-- No backend os inserts irão usar variavéis, estou pré-determinando antes para usar de exemplo de como funciona as tabelas

-- TB_USUARIO
SELECT * FROM TB_USUARIO;
--
INSERT INTO TB_USUARIO (nome, email, senha)
    VALUES ('João Silva', 'joao@gmail.com', 'teste123');
--
INSERT INTO TB_USUARIO (nome, email, senha)
    VALUES ('Marcelo Gonçalves', 'marcelo@gmail.com', 'senha123');
--
INSERT INTO TB_USUARIO (nome, email, senha)
    VALUES ('Rodrigo Pera', 'rodrigo@gmail.com', 'teste456');

-- TB_CARTEIRA
SELECT * FROM TB_CARTEIRA;
--
INSERT INTO TB_CARTEIRA (usuario_id, saldo_mobilidade)
    VALUES (
        (
        SELECT usuario_id FROM TB_USUARIO WHERE email = 'joao@gmail.com')
        , 0.00
    );
--
INSERT INTO TB_CARTEIRA (usuario_id, saldo_mobilidade)
    VALUES (
        (
        SELECT usuario_id FROM TB_USUARIO WHERE email = 'marcelo@gmail.com')
        , 0.00
    );
--
INSERT INTO TB_CARTEIRA (usuario_id, saldo_mobilidade)
    VALUES (
        (
        SELECT usuario_id FROM TB_USUARIO WHERE email = 'rodrigo@gmail.com')
        , 0.00
    );

-- TB_TIPO_VEICULO
SELECT * FROM TB_TIPO_VEICULO;
--
INSERT INTO TB_TIPO_VEICULO (nome, fator_emissao, flag_referencia)
    VALUES ('carro', 0.1710, 'S');
INSERT INTO TB_TIPO_VEICULO (nome, fator_emissao, flag_referencia)
    VALUES ('moto', 0.1030, 'N');
INSERT INTO TB_TIPO_VEICULO (nome, fator_emissao, flag_referencia)
    VALUES ('onibus', 0.0089, 'N');
INSERT INTO TB_TIPO_VEICULO (nome, fator_emissao, flag_referencia)
    VALUES ('trem', 0.0410, 'N');
INSERT INTO TB_TIPO_VEICULO (nome, fator_emissao, flag_referencia)
    VALUES ('metro', 0.0280, 'N');
INSERT INTO TB_TIPO_VEICULO (nome, fator_emissao, flag_referencia)
    VALUES ('bicicleta', 0.0000, 'N');
-- EXEMPLO DE COMO ATUALIZAR PARA QUE NÃO FIQUE CONFUSO QUANDO FOR IMPLEMENTAR NO SISTEMA 
UPDATE TB_TIPO_VEICULO
    SET flag_referencia = 'N'
    WHERE flag_referencia = 'S';
--
UPDATE TB_TIPO_VEICULO
    SET flag_referencia = 'S'
    WHERE nome = 'trem';

-- TB_VIAGEM
SELECT * FROM TB_VIAGEM;
--
INSERT INTO TB_VIAGEM (usuario_id, 
                       tipo_veiculo_id, 
                       origem, 
                       destino, 
                       km_percorrido, 
                       carbono_emitido, 
                       carbono_economizado)
    SELECT u.usuario_id, tv.tipo_veiculo_id, 'Av. Paulista', 'FIAP Aclimação', 8.50,
           ROUND(8.50 * tv.fator_emissao, 2),
           ROUND(8.50 * GREATEST(ref.fator_emissao - tv.fator_emissao, 0), 2)
    FROM TB_USUARIO u
    JOIN TB_TIPO_VEICULO tv ON tv.nome = 'metro'
    JOIN TB_TIPO_VEICULO ref ON ref.flag_referencia = 'S'
    WHERE u.email = 'joao@gmail.com';
--
INSERT INTO TB_VIAGEM (usuario_id, 
                       tipo_veiculo_id, 
                       origem, 
                       destino, 
                       km_percorrido, 
                       carbono_emitido, 
                       carbono_economizado)
    SELECT u.usuario_id, tv.tipo_veiculo_id, 'Centro', 'Vila Mariana', 6.20,
           ROUND(6.20 * tv.fator_emissao, 2),
           ROUND(6.20 * GREATEST(ref.fator_emissao - tv.fator_emissao, 0), 2)
    FROM TB_USUARIO u
    JOIN TB_TIPO_VEICULO tv ON tv.nome = 'onibus'
    JOIN TB_TIPO_VEICULO ref ON ref.flag_referencia = 'S'
    WHERE u.email = 'marcelo@gmail.com';
--
INSERT INTO TB_VIAGEM (usuario_id, 
                       tipo_veiculo_id, 
                       origem, 
                       destino, 
                       km_percorrido, 
                       carbono_emitido, 
                       carbono_economizado)
    SELECT u.usuario_id, tv.tipo_veiculo_id, 'Mauá', 'Santo André', 10.00,
           ROUND(10.00 * tv.fator_emissao, 2),
           ROUND(10.00 * GREATEST(ref.fator_emissao - tv.fator_emissao, 0), 2)
    FROM TB_USUARIO u
    JOIN TB_TIPO_VEICULO tv ON tv.nome = 'carro'
    JOIN TB_TIPO_VEICULO ref ON ref.flag_referencia = 'S'
    WHERE u.email = 'rodrigo@gmail.com';

-- TB_TIPO_MISSAO
SELECT * FROM TB_TIPO_MISSAO;
--
INSERT INTO TB_TIPO_MISSAO (nome, descricao, unidade_medida)
VALUES ('economia_co2', 'Acompanha a quantidade de CO2 economizada pelo usuário.', 'kg_CO2');
--
INSERT INTO TB_TIPO_MISSAO (nome, descricao, unidade_medida)
VALUES ('quantidade_missoes', 'Acompanha quantas missões relacionadas ao transporte público foram concluídas.', 'missoes');
--
INSERT INTO TB_TIPO_MISSAO (nome, descricao, unidade_medida)
VALUES ('trajeto_longo', 'Acompanha a realização de trajetos longos utilizando transporte público.', 'trajetos');

-- TB_CONQUISTA
SELECT * FROM TB_CONQUISTA;
--
INSERT INTO TB_CONQUISTA (nome, titulo, descricao)
                  VALUES ('Primeira Viagem', 'Viajante Iniciante', 'Realiza sua primeria viagem sustentável');
--
INSERT INTO TB_CONQUISTA (nome, titulo, descricao)
                  VALUES ('Eco Guerreiro', 'Eco Guerreiro', 'Economize carbono utilizando transporte sustentável');
--
INSERT INTO TB_CONQUISTA (nome, titulo, descricao)
                  VALUES ('Mestre da Mobilidade', 'Mestre da Mobilidade', 'Conclua o desafio mensal de mobilidade sustentável');
--
INSERT INTO TB_CONQUISTA (nome, titulo, descricao)
                  VALUES ('Amigo da Mobilidade Urbana', 'Amigo da Mobilidade Urbana', 'Conclua 50 missões relacionadas ao transporte público.');

-- TB_MISSAO
SELECT * FROM TB_MISSAO;
--
-- Economizador de CO2: a meta é economizar 100 kg de CO2 - recompensa de 300 pontos
INSERT INTO TB_MISSAO (tipo_missao_id, conquista_id, titulo, descricao, meta_missao, pontos_missao, periodicidade_dias, prazo_dias)
               VALUES (
                        (SELECT tipo_missao_id FROM TB_TIPO_MISSAO WHERE nome = 'economia_co2'),
                        NULL, -- sem conquista definida ao concluir essa missão
                        'Economizador de CO2',
                        'Economize 100 kg de CO2 utilizando o transporte público.',
                        100,
                        300,
                        NULL, -- sem recorrência definida para esta missão
                        NULL  -- sem prazo limite
);
--
-- Amigo da Mobilidade Urbana: conclua 50 missões - recompensa de 300 pontos e o título
INSERT INTO TB_MISSAO (tipo_missao_id, conquista_id, titulo, descricao, meta_missao, pontos_missao, periodicidade_dias, prazo_dias)
               VALUES (
                        (SELECT tipo_missao_id FROM TB_TIPO_MISSAO WHERE nome = 'quantidade_missoes'),
                        (SELECT conquista_id FROM TB_CONQUISTA WHERE nome = 'Amigo da Mobilidade Urbana'),
                        'Amigo da Mobilidade Urbana',
                        'Conclua 50 missões relacionadas ao transporte público.',
                        50,
                        300,
                        NULL, -- sem recorrência definida para esta missão
                        NULL  -- sem prazo limite
);
--
-- Use o Transporte Público: realizar um trajeto longo dentro de um prazo de 3 dias
INSERT INTO TB_MISSAO (tipo_missao_id, conquista_id, titulo, descricao, meta_missao, pontos_missao, periodicidade_dias, prazo_dias)
               VALUES (
                        (SELECT tipo_missao_id FROM TB_TIPO_MISSAO WHERE nome = 'trajeto_longo'),
                        NULL,
                        'Use o Transporte Público',
                        'Complete um trajeto complexo (longo) utilizando o transporte público.',
                        1,
                        100,
                        7, -- a missao pode ser repetida a cada 7 dias
                        3 -- prazo limite pra concluir
);

-- TB_USUARIO_MISSAO (tabela transacional)
SELECT * FROM TB_USUARIO_MISSAO;
--
-- João: progresso 50/100 kg de CO2 na missão Economizador de CO2
INSERT INTO TB_USUARIO_MISSAO (usuario_id, missao_id, status_missao, pontuacao_recebida, progresso_atual, data_inicio)
    SELECT u.usuario_id, m.missao_id, 'em andamento', 0, 50, SYSDATE - 2
        FROM TB_USUARIO u CROSS JOIN TB_MISSAO m
        WHERE u.email = 'joao@gmail.com' AND m.titulo = 'Economizador de CO2';
--
-- João concluiu um trajeto longo e recebeu 100 pontos
INSERT INTO TB_USUARIO_MISSAO (usuario_id, missao_id, status_missao, pontuacao_recebida, progresso_atual, data_inicio, data_conclusao)
    SELECT u.usuario_id, m.missao_id, 'concluida', m.pontos_missao, m.meta_missao, SYSDATE - 1, SYSDATE
        FROM TB_USUARIO u CROSS JOIN TB_MISSAO m
        WHERE u.email = 'joao@gmail.com' AND m.titulo = 'Use o Transporte Público';
--
-- Marcelo: progresso 10/50 missões na missão Amigo da Mobilidade Urbana
INSERT INTO TB_USUARIO_MISSAO (usuario_id, missao_id, status_missao, pontuacao_recebida, progresso_atual, data_inicio)
    SELECT u.usuario_id, m.missao_id, 'em andamento', 0, 10, SYSDATE - 5
        FROM TB_USUARIO u CROSS JOIN TB_MISSAO m
        WHERE u.email = 'marcelo@gmail.com' AND m.titulo = 'Amigo da Mobilidade Urbana';
--
-- Rodrigo concluiu a missão Amigo da Mobilidade Urbana e desbloqueou o título
INSERT INTO TB_USUARIO_MISSAO (usuario_id, missao_id, status_missao, pontuacao_recebida, progresso_atual, data_inicio, data_conclusao)
    SELECT u.usuario_id, m.missao_id, 'concluida', m.pontos_missao, m.meta_missao, SYSDATE - 10, SYSDATE - 1
        FROM TB_USUARIO u CROSS JOIN TB_MISSAO m
        WHERE u.email = 'rodrigo@gmail.com' AND m.titulo = 'Amigo da Mobilidade Urbana';
--
-- Marcelo está dentro do prazo de 3 dias para concluir um trajeto longo
INSERT INTO TB_USUARIO_MISSAO (usuario_id, missao_id, status_missao, pontuacao_recebida, progresso_atual, data_inicio)
    SELECT u.usuario_id, m.missao_id, 'em andamento', 0, 0, SYSDATE - 1
        FROM TB_USUARIO u CROSS JOIN TB_MISSAO m
        WHERE u.email = 'marcelo@gmail.com' AND m.titulo = 'Use o Transporte Público';

-- TB_COMPROVANTE (ligado a execução da missao)
SELECT * FROM TB_COMPROVANTE;
--
-- João: comprovante aprovado para a missão de trajeto longo concluída
INSERT INTO TB_COMPROVANTE (usuario_missao_id, status_validacao, arquivo, data_validacao)
    SELECT um.usuario_missao_id, 'aprovado', EMPTY_BLOB(), SYSDATE
        FROM TB_USUARIO_MISSAO um
        JOIN TB_USUARIO u ON u.usuario_id = um.usuario_id
        JOIN TB_MISSAO m ON m.missao_id = um.missao_id
    WHERE u.email = 'joao@gmail.com'
    AND m.titulo = 'Use o Transporte Público'
    AND um.status_missao = 'concluida';
--
-- João: comprovante rejeitado para a execução em andamento de Economizador de CO2
INSERT INTO TB_COMPROVANTE (usuario_missao_id, status_validacao, arquivo, data_validacao)
    SELECT um.usuario_missao_id, 'rejeitado', EMPTY_BLOB(), SYSDATE
        FROM TB_USUARIO_MISSAO um
        JOIN TB_USUARIO u ON u.usuario_id = um.usuario_id
        JOIN TB_MISSAO m ON m.missao_id = um.missao_id
    WHERE u.email = 'joao@gmail.com'
    AND m.titulo = 'Economizador de CO2'
    AND um.status_missao = 'em andamento';
--
-- Marcelo: comprovante aguardando validação para Use o Transporte Público
INSERT INTO TB_COMPROVANTE (usuario_missao_id, status_validacao, arquivo)
    SELECT um.usuario_missao_id, 'pendente', EMPTY_BLOB()
        FROM TB_USUARIO_MISSAO um
        JOIN TB_USUARIO u ON u.usuario_id = um.usuario_id
        JOIN TB_MISSAO m ON m.missao_id = um.missao_id
    WHERE u.email = 'marcelo@gmail.com'
    AND m.titulo = 'Use o Transporte Público'
    AND um.status_missao = 'em andamento';

-- TB_USUARIO_CONQUISTA
/*A MISSAO GERA A CONQUISTA: toda missao concluida que tem conquista
vinculada concede essa conquista ao usuario (se ainda nao tiver).*/
-- O usuario pode escolhar qualquer conquista desbloquead como titulo atual
SELECT * FROM TB_USUARIO_CONQUISTA;
--
INSERT INTO TB_USUARIO_CONQUISTA (usuario_id, conquista_id, data_conquista, flag_titulo_atual)
    SELECT um.usuario_id, m.conquista_id, MIN(um.data_conclusao), 'N'
    FROM TB_USUARIO_MISSAO um
    JOIN TB_MISSAO m ON m.missao_id = um.missao_id
    WHERE um.status_missao = 'concluida'
    AND m.conquista_id IS NOT NULL
    AND NOT EXISTS (SELECT 1
                    FROM TB_USUARIO_CONQUISTA uc
                    WHERE uc.usuario_id = um.usuario_id
                    AND uc.conquista_id = m.conquista_id)
GROUP BY um.usuario_id, m.conquista_id;

-- Selecao do titulo atual: o usuario escolhe entre as conquista que ja desbloqueou
-- Nos exemplos, Joao e Rodrigo selecionam um dos titulos entre as conquistas desbloqueadas
UPDATE TB_USUARIO_CONQUISTA uc
    SET flag_titulo_atual = 'S'
    WHERE uc.usuario_id = (SELECT usuario_id FROM TB_USUARIO WHERE email = 'rodrigo@gmail.com')
    AND uc.conquista_id = (SELECT conquista_id FROM TB_CONQUISTA WHERE nome = 'Eco Guerreiro');

UPDATE TB_USUARIO_CONQUISTA uc
SET    flag_titulo_atual = 'S'
WHERE  uc.usuario_id = (SELECT usuario_id FROM TB_USUARIO WHERE email = 'joao@gmail.com')
AND    uc.conquista_id = (SELECT conquista_id FROM TB_CONQUISTA WHERE nome = 'Primeira Viagem');

-- TB_RECARGA
SELECT * FROM TB_RECARGA;
--
-- João: recarga pendente com Pix copia e cola
INSERT INTO TB_RECARGA (usuario_id, valor_recarga, codigo_pix_copia_cola, status_recarga)
                VALUES ((SELECT usuario_id FROM TB_USUARIO WHERE email = 'joao@gmail.com'),
                50.00,
                '00020101021226860014BR.GOV.BCB.PIX2564qrpix.bradesco.com.br/qr/v2/f6aa801a-b805-4b9c-adf7-fa3ee48cacbf520400005303986540510.005802BR5907SPTRANS6009SAO PAULO62070503***630472BA',
                'pendente');
--
-- Rodrigo: recarga paga e creditada
INSERT INTO TB_RECARGA (usuario_id, valor_recarga, codigo_pix_copia_cola, status_recarga, data_pagamento, data_credito)
VALUES ((SELECT usuario_id FROM TB_USUARIO WHERE email = 'rodrigo@gmail.com'),
        100.00,
        '00020101021226860014BR.GOV.BCB.PIX2564qrpix.bradesco.com.br/qr/v2/f6aa801a-b805-4b9c-adf7-fa3ee48cacbf520400005303986540525.505802BR5907SPTRANS6009SAO PAULO62070503***630472BA',
        'creditado', SYSDATE, SYSDATE);
--
-- Marcelo: recarga recusada
INSERT INTO TB_RECARGA (usuario_id, valor_recarga, codigo_pix_copia_cola, status_recarga)
VALUES ((SELECT usuario_id FROM TB_USUARIO WHERE email = 'marcelo@gmail.com'),
        200.00,
        '00020101021226860014BR.GOV.BCB.PIX2564qrpix.bradesco.com.br/qr/v2/f6aa801a-b805-4b9c-adf7-fa3ee48cacbf520400005303986540550.005802BR5907SPTRANS6009SAO PAULO62070503***630472BA',
        'recusado');

-- TB_CONVERSAO_PONTOS
SELECT * FROM TB_CONVERSAO_PONTOS;
--
INSERT INTO TB_CONVERSAO_PONTOS (usuario_id, pontos_convertidos, creditos_gerados)
    SELECT u.usuario_id, 50, 5.00
    FROM TB_USUARIO u
    WHERE u.email = 'joao@gmail.com';

INSERT INTO TB_CONVERSAO_PONTOS (usuario_id, pontos_convertidos, creditos_gerados)
    SELECT u.usuario_id, 100, 10.00
    FROM TB_USUARIO u
    WHERE u.email = 'rodrigo@gmail.com';

-- EXEMPLO DE ATUALIZACAO NA CARTEIRA COM CREDITOS GERADOS PELA CONVERSAO 
-- TEM QUE LEMBRAR QUE OS VALORES DE PONTOS CONVERTIDOS E CREDITOS GERADOS SAO CALCULADOS NO BACKEND, 
-- AQUI É APENAS UMA MANEIRA DE EXEMPLIFICAR O CONTEUDO
SELECT * FROM TB_CARTEIRA;

UPDATE TB_CARTEIRA c
    SET saldo_mobilidade = 5.00
WHERE c.usuario_id = (SELECT usuario_id FROM TB_USUARIO WHERE email = 'joao@gmail.com');
--
UPDATE TB_CARTEIRA c
    SET saldo_mobilidade = saldo_mobilidade + 10.00
WHERE c.usuario_id = (SELECT usuario_id FROM TB_USUARIO WHERE email = 'rodrigo@gmail.com');
--
-- Atualiza a carteira de Rodrigo com a recarga de 100,00 creditada
UPDATE TB_CARTEIRA c
    SET saldo_mobilidade = saldo_mobilidade + 100.00
WHERE c.usuario_id = (SELECT usuario_id FROM TB_USUARIO WHERE email = 'rodrigo@gmail.com');