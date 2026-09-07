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