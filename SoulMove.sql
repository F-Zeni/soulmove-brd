CREATE TABLE TB_USUARIO (
    usuario_id    INTEGER      GENERATED ALWAYS AS IDENTITY,
    pontos        INTEGER      NOT NULL,
    creditos      NUMERIC(6,2) NOT NULL,
    nome          VARCHAR2(150) NOT NULL,
    email         VARCHAR2(150) NOT NULL,
    data_cadastro DATE         NOT NULL,
    CONSTRAINT TB_USUARIO_PK
        PRIMARY KEY (usuario_id),
    CONSTRAINT TB_USUARIO_UK
        UNIQUE (email),
    CONSTRAINT TB_USUARIO_PONTOS_CK
        CHECK (pontos >= 0),
    CONSTRAINT TB_USUARIO_CREDITOS_CK
        CHECK (creditos >= 0)
);

CREATE TABLE TB_PONTOS (
    pontos_id        INTEGER      GENERATED ALWAYS AS IDENTITY,
    usuario_id       INTEGER      NOT NULL,
    origem           VARCHAR2(30) NOT NULL,
    creditos_gerados NUMERIC(6,2) NOT NULL,
    data_pontuacao   DATE         NOT NULL,
    CONSTRAINT TB_PONTOS_PK
        PRIMARY KEY (pontos_id),
    CONSTRAINT TB_PONTOS_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_PONTOS_CREDITOS_CK
        CHECK (creditos_gerados > 0)
);

CREATE TABLE TB_CONQUISTA (
    conquista_id INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome         VARCHAR2(150) NOT NULL,
    descricao    VARCHAR2(200) NOT NULL,
    CONSTRAINT TB_CONQUISTA_PK
        PRIMARY KEY (conquista_id)
);

CREATE TABLE TB_USUARIO_CONQUISTA (
    usuario_id     INTEGER NOT NULL,
    conquista_id   INTEGER NOT NULL,
    data_conquista DATE    NOT NULL,
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
    viagem_id           INTEGER       GENERATED ALWAYS AS IDENTITY,
    usuario_id          INTEGER       NOT NULL,
    origem              VARCHAR2(250) NOT NULL,
    destino             VARCHAR2(250) NOT NULL,
    tipo_veiculo        VARCHAR2(50)  NOT NULL,
    carbono_economizado NUMERIC(6,2)  NOT NULL,
    carbono_emitido     NUMERIC(6,2)  NOT NULL,
    km_percorrido        NUMERIC(4,3)  NOT NULL,
    data_viagem         DATE          NOT NULL,
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
    pontuacao_recebida INTEGER      NOT NULL,
    usuario_id         INTEGER      NOT NULL,
    missao_id          INTEGER      NOT NULL,
    viagem_id          INTEGER,
    status_missao      VARCHAR2(30) NOT NULL,
    data_cumprimento   DATE         NOT NULL,
    CONSTRAINT TB_USUARIO_MISSAO_PK
        PRIMARY KEY (usuario_id, missao_id),
    CONSTRAINT TB_USUARIO_MISSAO_USU_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_USUARIO_MISSAO_VIA_FK
        FOREIGN KEY (viagem_id)
        REFERENCES TB_VIAGEM (viagem_id),
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
    comprovante_id INTEGER GENERATED ALWAYS AS IDENTITY,
    usuario_id INTEGER NOT NULL,
    missao_id INTEGER NOT NULL,
    data_validacao DATE NOT NULL,
    data_envio DATE NOT NULL,
    status_validacao VARCHAR2(50) NOT NULL,
    -- Estarei usando o tipo BLOB para armzenar a imagem do comprovante (Ele serve para armazenar dados não estruturados em formato binário )
    arquivo BLOB NOT NULL,
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