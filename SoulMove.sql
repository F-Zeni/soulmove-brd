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
        UNIQUE (email)
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
        REFERENCES TB_USUARIO (usuario_id)
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
        REFERENCES TB_CONQUISTA (conquista_id)
);

CREATE TABLE TB_VIAGEM (
    viagem_id           INTEGER       GENERATED ALWAYS AS IDENTITY,
    usuario_id          INTEGER       NOT NULL,
    origem              VARCHAR2(250) NOT NULL,
    destino             VARCHAR2(250) NOT NULL,
    tipo_veiculo        VARCHAR2(50)  NOT NULL,
    carbono_economizado NUMERIC(6,2)  NOT NULL,
    carbono_emitido     NUMERIC(6,2)  NOT NULL,
    km_percorrio        NUMERIC(4,3)  NOT NULL,
    data_viagem         DATE          NOT NULL,
    CONSTRAINT TB_VIAGEM_PK
        PRIMARY KEY (viagem_id),
    CONSTRAINT TB_VIAGEM_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id)
);