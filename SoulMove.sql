CREATE TABLE TB_CONQUISTA (
    conquista_id INTEGER       GENERATED ALWAYS AS IDENTITY,
    pontos       INTEGER       NOT NULL,
    nome         VARCHAR2(150) NOT NULL,
    titulo       VARCHAR2(150) NOT NULL,
    descricao    VARCHAR2(200) NOT NULL,
    CONSTRAINT TB_CONQUISTA_PK
        PRIMARY KEY (conquista_id),
    CONSTRAINT TB_CONQUISTA_PONTOS_CK
        CHECK (pontos >=0)
);

CREATE TABLE TB_USUARIO (
    usuario_id      INTEGER              GENERATED ALWAYS AS IDENTITY,
    titulo_atual    INTEGER,
    pontos          INTEGER              NOT NULL,
    senha           VARCHAR2(100)        NOT NULL,
    nome            VARCHAR2(150)        NOT NULL,
    email           VARCHAR2(150)        NOT NULL,
    data_cadastro   DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_USUARIO_PK
        PRIMARY KEY (usuario_id),
    CONSTRAINT TB_USUARIO_UK
        UNIQUE (email),
    CONSTRAINT TB_USUARIO_PONTOS_CK
        CHECK (pontos >= 0),
    CONSTRAINT TB_USUARIO_TITULO_FK
        FOREIGN KEY (titulo_atual)
        REFERENCES TB_CONQUISTA (conquista_id)
);

CREATE TABLE TB_CARTEIRA (
    carteira_id      INTEGER      GENERATED ALWAYS AS IDENTITY,
    usuario_id       INTEGER      NOT NULL,
    saldo_mobilidade NUMERIC(6,2) NOT NULL,
    CONSTRAINT TB_CARTEIRA_PK
        PRIMARY KEY (carteira_id),
    CONSTRAINT TB_CARTEIRA_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO(usuario_id),
    CONSTRAINT TB_CARTEIRA_USUARIO_UK
        UNIQUE (usuario_id),
    CONSTRAINT TB_CARTEIRO_SALDO_CK
        CHECK (saldo_mobilidade >= 0)
);

CREATE TABLE TB_RECARGA (
    recarga_id       INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id       INTEGER              NOT NULL,
    valor_recarga    NUMERIC(6,2)         NOT NULL,
    codigo_barras    VARCHAR2(100)        NOT NULL,
    status_recarga   VARCHAR2(30)         NOT NULL,
    data_solicitacao DATE DEFAULT SYSDATE NOT NULL,
    data_pagamento   DATE,
    data_credito     DATE,
    CONSTRAINT TB_RECARGA_PK
        PRIMARY KEY (recarga_id),
    CONSTRAINT TB_RECARGA_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_RECARGA_VALOR_CK
        CHECK (valor_recarga BETWEEN 10 and 200),
    CONSTRAINT TB_RECARGA_STATUS_CK
        CHECK (status_recarga IN (
            'pendente',
            'creditado',
            'recusado'
        ))
);

CREATE TABLE TB_PONTOS (
    pontos_id        INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id       INTEGER              NOT NULL,
    pontos_gerados   INTEGER              NOT NULL,
    origem           VARCHAR2(30)         NOT NULL,
    creditos_gerados NUMERIC(6,2)         NOT NULL,
    data_pontuacao   DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_PONTOS_PK
        PRIMARY KEY (pontos_id),
    CONSTRAINT TB_PONTOS_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_PONTOS_CREDITOS_CK
        CHECK (creditos_gerados > 0),
    CONSTRAINT TB_PONTOS_ORIGEM_CK
        CHECK (origem IN (
            'missao',
            'conquista'
        ))
);

CREATE TABLE TB_USUARIO_CONQUISTA (
    usuario_id     INTEGER              NOT NULL,
    conquista_id   INTEGER              NOT NULL,
    data_conquista DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_USUARIO_CONQUISTA_USU_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_USUARIO_CONQUISTA_CON_FK
        FOREIGN KEY (conquista_id)
        REFERENCES TB_CONQUISTA (conquista_id),
    CONSTRAINT TB_USUARIO_CONQUISTA_PK
        PRIMARY KEY (usuario_id, conquista_id)
);

CREATE TABLE TB_VIAGEM (
    viagem_id           INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id          INTEGER              NOT NULL,
    origem              VARCHAR2(250)        NOT NULL,
    destino             VARCHAR2(250)        NOT NULL,
    tipo_veiculo        VARCHAR2(50)         NOT NULL,
    carbono_economizado NUMERIC(6,2)         NOT NULL,
    carbono_emitido     NUMERIC(6,2)         NOT NULL,
    km_percorrido       NUMERIC(6,2)         NOT NULL,
    data_viagem         DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_VIAGEM_PK
        PRIMARY KEY (viagem_id),
    CONSTRAINT TB_VIAGEM_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_VIAGEM_CARB_EMITIDO_CK
        CHECK (carbono_emitido >= 0),
    CONSTRAINT TB_VIAGEM_CARB_ECONOM_CK
        CHECK (carbono_economizado >= 0),
    CONSTRAINT TB_VIAGEM_KM_PERC_CK
        CHECK (km_percorrido > 0),
    CONSTRAINT TB_VIAGEM_TIPO_VEIC_CK
        CHECK (tipo_veiculo IN (
            'carro', 
            'bicicleta', 
            'trem', 
            'moto', 
            'onibus', 
            'metro'
            ))
);

CREATE TABLE TB_MISSAO (
    missao_id     INTEGER       GENERATED ALWAYS AS IDENTITY,
    pontos_missao INTEGER       NOT NULL,
    titulo        VARCHAR2(150) NOT NULL,
    descricao     VARCHAR2(150) NOT NULL,
    tipo_missao   VARCHAR2(30)  NOT NULL,
    CONSTRAINT TB_MISSAO_PK
        PRIMARY KEY (missao_id),
    CONSTRAINT TB_MISSAO_PONTOS_CK
        CHECK (pontos_missao > 0),
    CONSTRAINT TB_MISSAO_TIPO_CK
        CHECK (tipo_missao IN (
            'diaria',
            'semanal',
            'mensal'
        ))
);

CREATE TABLE TB_USUARIO_MISSAO (
    pontuacao_recebida INTEGER              NOT NULL,
    usuario_id         INTEGER              NOT NULL,
    missao_id          INTEGER              NOT NULL,
    status_missao      VARCHAR2(30)         NOT NULL,
    data_cumprimento   DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_USUARIO_MISSAO_PK
        PRIMARY KEY (usuario_id, missao_id),
    CONSTRAINT TB_USUARIO_MISSAO_USU_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_USUARIO_MISSAO_MIS_FK
        FOREIGN KEY (missao_id)
        REFERENCES TB_MISSAO (missao_id),
    CONSTRAINT TB_USUARIO_MISSAO_PONTOS_CK
        CHECK (pontuacao_recebida >= 0),
    CONSTRAINT TB_USUARIO_MISSAO_STATUS_CK
        CHECK (status_missao IN (
            'cancelada',
            'concluida',
            'em andamento'
        ))
);

CREATE TABLE TB_COMPROVANTE (
    comprovante_id   INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id       INTEGER              NOT NULL,
    missao_id        INTEGER              NOT NULL,
    data_envio       DATE DEFAULT SYSDATE NOT NULL,
    data_validacao   DATE,
    status_validacao VARCHAR2(50)         NOT NULL,
    -- Estarei usando o tipo BLOB para armzenar a imagem do comprovante (Ele serve para armazenar dados não estruturados em formato binário )
    arquivo          BLOB                 NOT NULL,
    CONSTRAINT TB_COMPROVANTE_PK
        PRIMARY KEY (comprovante_id),
    CONSTRAINT TB_COMPROVANTE_USU_MIS_FK
        FOREIGN KEY (usuario_id, missao_id)
        REFERENCES TB_USUARIO_MISSAO (usuario_id, missao_id),
    CONSTRAINT TB_COMPROVANTE_USU_MIS_UK
        UNIQUE (usuario_id, missao_id),
    CONSTRAINT TB_COMPROVANTE_STATUS_CK
        CHECK (status_validacao IN (
            'pendente',
            'aprovado',
            'rejeitado'
        ))
);

-- INSERTS

-- TB_CONQUISTA
INSERT INTO TB_CONQUISTA (pontos, nome, titulo, descricao)
VALUES (100, 'Primeira Viagem', 'Viajante Iniciante', 'Realize sua primeira viagem sustentável');

INSERT INTO TB_CONQUISTA (pontos, nome, titulo, descricao)
VALUES (250, 'Eco Guerreiro', 'Eco Guerreiro', 'Economize carbono utilizando transporte sustentável');

INSERT INTO TB_CONQUISTA (pontos, nome, titulo, descricao)
VALUES (500, 'Mestre da Mobilidade', 'Mestre da Mobilidade', 'Acumule 500 pontos através de atividades sustentáveis');
SELECT * FROM TB_CONQUISTA;

-- TB_USUARIO
INSERT INTO TB_USUARIO 
(titulo_atual, pontos, senha, nome, email)
VALUES (4, 100, 'senha123', 'João Silva', 'joao@email.com');

INSERT INTO TB_USUARIO 
(titulo_atual, pontos, senha, nome, email)
VALUES (5, 250, 'senha456', 'Maria Souza', 'maria@email.com');

INSERT INTO TB_USUARIO 
(titulo_atual, pontos, senha, nome, email)
VALUES (NULL, 0, 'senha789', 'Pedro Santos', 'pedro@email.com');
SELECT * FROM TB_USUARIO;

-- TB_CARTEIRA
INSERT INTO TB_CARTEIRA (usuario_id, saldo_mobilidade)
VALUES (6, 50.00);

INSERT INTO TB_CARTEIRA (usuario_id, saldo_mobilidade)
VALUES (7, 120.50);

INSERT INTO TB_CARTEIRA (usuario_id, saldo_mobilidade)
VALUES (8, 0.00);
SELECT * FROM TB_CARTEIRA;

-- TB_RECARGA
INSERT INTO TB_RECARGA
(usuario_id, valor_recarga, codigo_barras, status_recarga)
VALUES (6, 50.00, '84670000000500000000000000000000000000000000', 'pendente');

INSERT INTO TB_RECARGA
(usuario_id, valor_recarga, codigo_barras, status_recarga, data_pagamento, data_credito)
VALUES (7, 100.00, '84670000000100000000000000000000000000000000', 
        'creditado', SYSDATE, SYSDATE);

INSERT INTO TB_RECARGA
(usuario_id, valor_recarga, codigo_barras, status_recarga)
VALUES (8, 200.00, '84670000000200000000000000000000000000000000', 'recusado');
SELECT * FROM TB_RECARGA;

-- TB_PONTOS
INSERT INTO TB_PONTOS
(usuario_id, pontos_gerados, origem, creditos_gerados)
VALUES (6, 100, 'conquista', 10.00);

INSERT INTO TB_PONTOS
(usuario_id, pontos_gerados, origem, creditos_gerados)
VALUES (7, 50, 'missao', 5.00);

INSERT INTO TB_PONTOS
(usuario_id, pontos_gerados, origem, creditos_gerados)
VALUES (8, 250, 'conquista', 25.00);
SELECT * FROM TB_PONTOS;

-- TB_USUARIO_CONQUISTA;
INSERT INTO TB_USUARIO_CONQUISTA
(usuario_id, conquista_id)
VALUES (6, 4);

INSERT INTO TB_USUARIO_CONQUISTA
(usuario_id, conquista_id)
VALUES (7, 5);

INSERT INTO TB_USUARIO_CONQUISTA
(usuario_id, conquista_id)
VALUES (8, 6);
SELECT * FROM TB_USUARIO_CONQUISTA;

-- TB_VIAGEM
INSERT INTO TB_VIAGEM
(usuario_id, origem, destino, tipo_veiculo, carbono_economizado, carbono_emitido, km_percorrido)
VALUES (
    6,
    'Av. Paulista',
    'FIAP Aclimação',
    'metro',
    2.50,
    0.30,
    8.50
);

INSERT INTO TB_VIAGEM
(usuario_id, origem, destino, tipo_veiculo, carbono_economizado, carbono_emitido, km_percorrido)
VALUES (
    7,
    'Centro',
    'Vila Mariana',
    'onibus',
    1.80,
    0.45,
    6.20
);

INSERT INTO TB_VIAGEM
(usuario_id, origem, destino, tipo_veiculo, carbono_economizado, carbono_emitido, km_percorrido)
VALUES (
    8,
    'Santo André',
    'São Paulo',
    'trem',
    4.20,
    0.60,
    15.00
);
SELECT * FROM TB_VIAGEM;

-- TB_MISSAO
INSERT INTO TB_MISSAO
(pontos_missao, titulo, descricao, tipo_missao)
VALUES (
    50,
    'Use o metrô',
    'Realize uma viagem utilizando o metrô',
    'diaria'
);

INSERT INTO TB_MISSAO
(pontos_missao, titulo, descricao, tipo_missao)
VALUES (
    100,
    'Transporte sustentável',
    'Utilize transporte público durante a semana',
    'semanal'
);

INSERT INTO TB_MISSAO
(pontos_missao, titulo, descricao, tipo_missao)
VALUES (
    300,
    'Desafio do mês',
    'Economize carbono durante o mês',
    'mensal'
);
SELECT * FROM TB_MISSAO;

-- TB_USUARIO_MISSAO
INSERT INTO TB_USUARIO_MISSAO
(pontuacao_recebida, usuario_id, missao_id, status_missao)
VALUES (50, 8, 5, 'concluida');

INSERT INTO TB_USUARIO_MISSAO
(pontuacao_recebida, usuario_id, missao_id, status_missao)
VALUES (0, 7, 6, 'em andamento');

INSERT INTO TB_USUARIO_MISSAO
(pontuacao_recebida, usuario_id, missao_id, status_missao)
VALUES (100, 6, 7, 'concluida');
SELECT * FROM TB_USUARIO_MISSAO;

-- TB_COMPROVANTE
INSERT INTO TB_COMPROVANTE
(usuario_id, missao_id, status_validacao, arquivo, data_validacao)
VALUES (
    8,
    5,
    'aprovado',
    EMPTY_BLOB(),
    SYSDATE
);

INSERT INTO TB_COMPROVANTE
(usuario_id, missao_id, status_validacao, arquivo)
VALUES (
    7,
    6,
    'pendente',
    EMPTY_BLOB()
);

INSERT INTO TB_COMPROVANTE
(usuario_id, missao_id, status_validacao, arquivo, data_validacao)
VALUES (
    6,
    7,
    'rejeitado',
    EMPTY_BLOB(),
    SYSDATE
);
SELECT * FROM TB_COMPROVANTE;