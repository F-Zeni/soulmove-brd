CREATE TABLE TB_USUARIO (
    usuario_id    INTEGER      GENERATED ALWAYS AS IDENTITY,
    pontos        INTEGER      NOT NULL,
    creditos      NUMERIC(6,2) NOT NULL,
    nome          VARCHAR(150) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    data_cadastro DATE         NOT NULL,
    CONSTRAINT TB_USUARIO_PK
        PRIMARY KEY (usuario_id),
    CONSTRAINT TB_USUARIO_UK
        UNIQUE (email)
);