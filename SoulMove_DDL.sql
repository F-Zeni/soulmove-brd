CREATE TABLE TB_USUARIO (
    usuario_id    INTEGER              GENERATED ALWAYS AS IDENTITY,
    nome          VARCHAR2(150)        NOT NULL,
    email         VARCHAR2(150)        NOT NULL,
    senha         VARCHAR2(100)        NOT NULL, 
    tipo_usuario  VARCHAR2(20)         DEFAULT 'comum' NOT NULL,
    data_cadastro DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_USUARIO_PK
        PRIMARY KEY (usuario_id),
    CONSTRAINT TB_USUARIO_EMAIL_UK
        UNIQUE (email),
    CONSTRAINT TB_USUARIO_TIPO_USU_CK
        CHECK (tipo_usuario IN ('comum', 'admin'))
);

CREATE TABLE TB_CARTEIRA (
    carteira_id      INTEGER      GENERATED ALWAYS AS IDENTITY,
    usuario_id       INTEGER      NOT NULL,
    saldo_mobilidade NUMBER(6,2)  DEFAULT 0 NOT NULL,
    CONSTRAINT TB_CARTEIRA_PK
        PRIMARY KEY (carteira_id),
    CONSTRAINT TB_CARTEIRA_USUARIO_UK
        UNIQUE (usuario_id),
    CONSTRAINT TB_CARTEIRA_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_CARTEIRA_SALDO_CK
        CHECK (saldo_mobilidade >= 0)
);

CREATE TABLE TB_TIPO_VEICULO (
    tipo_veiculo_id   INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome              VARCHAR2(50)  NOT NULL,
    fator_emissao     NUMBER(10,6)  NOT NULL,
    flag_referencia   CHAR(1)       DEFAULT 'N' NOT NULL,
    CONSTRAINT TB_TIPO_VEICULO_PK
        PRIMARY KEY (tipo_veiculo_id),
    CONSTRAINT TB_TIPO_VEICULO_NOME_UK
        UNIQUE (nome),
    CONSTRAINT TB_TIPO_VEICULO_FATOR_CK
        CHECK (fator_emissao >= 0),
    CONSTRAINT TB_TIPO_VEICULO_REF_CK
        CHECK (flag_referencia IN ('S', 'N'))
);
-- Garante que exista no máximo UM veículo de referência
CREATE UNIQUE INDEX TB_TIPO_VEICULO_REF_UIX
    ON TB_TIPO_VEICULO (CASE WHEN flag_referencia = 'S' THEN 1 END);

CREATE TABLE TB_VIAGEM (
    viagem_id           INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id          INTEGER              NOT NULL,
    tipo_veiculo_id     INTEGER              NOT NULL,
    origem              VARCHAR2(250)        NOT NULL,
    destino             VARCHAR2(250)        NOT NULL,
    km_percorrido       NUMERIC(6,2)         NOT NULL,
    carbono_emitido     NUMERIC(6,2)         NOT NULL,
    carbono_economizado NUMERIC(6,2)         NOT NULL,
    data_viagem         DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_VIAGEM_PK
        PRIMARY KEY (viagem_id),
    CONSTRAINT TB_VIAGEM_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_VIAGEM_TIPO_VEIC_FK
        FOREIGN KEY (tipo_veiculo_id)
        REFERENCES TB_TIPO_VEICULO (tipo_veiculo_id),
    CONSTRAINT TB_VIAGEM_KM_PERC_CK
        CHECK (km_percorrido > 0),
    CONSTRAINT TB_VIAGEM_CARB_EMITIDO_CK
        CHECK (carbono_emitido >= 0),
    CONSTRAINT TB_VIAGEM_CARB_ECONOM_CK
        CHECK (carbono_economizado >= 0)
);

/* O tipo representa COMO o progresso é medido, não representa o prazo.
O prazo e a meta ficam em TB_MISSAO, e o progresso individual em TB_USUARIO_MISSAO.*/
CREATE TABLE TB_TIPO_MISSAO (
    tipo_missao_id     INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome               VARCHAR2(30)  NOT NULL,
    descricao          VARCHAR2(150) NOT NULL,
    unidade_medida     VARCHAR2(30)  NOT NULL,
    CONSTRAINT TB_TIPO_MISSAO_PK
        PRIMARY KEY (tipo_missao_id),
    CONSTRAINT TB_TIPO_MISSAO_NOME_UK
        UNIQUE (nome)
);

CREATE TABLE TB_TIPO_CONQUISTA (
    tipo_conquista_id   INTEGER GENERATED ALWAYS AS IDENTITY,
    nome                VARCHAR2(150) NOT NULL,
    unidade_medida      VARCHAR2(100) NOT NULL,
    descricao           VARCHAR2(150) NOT NULL,
    CONSTRAINT TB_TIPO_CONQUISTA_PK
        PRIMARY KEY (tipo_conquista_id),
    CONSTRAINT TB_TIPO_CONQUISTA_UK
        UNIQUE (nome)
);

CREATE TABLE TB_CONQUISTA (
    conquista_id        INTEGER       GENERATED ALWAYS AS IDENTITY,
    tipo_conquista_id   INTEGER       NOT NULL,
    meta                NUMERIC (6,2) NOT NULL,
    nome                VARCHAR2(150) NOT NULL,
    titulo              VARCHAR2(150) NOT NULL,
    descricao           VARCHAR2(200) NOT NULL,
    pontos              INTEGER       NOT NULL,
    CONSTRAINT TB_CONQUISTA_PK
        PRIMARY KEY (conquista_id),
    CONSTRAINT TB_CONQUISTA_NOME_UK
        UNIQUE (nome),
    CONSTRAINT TB_CONQUISTA_TIPO_FK
        FOREIGN KEY (tipo_conquista_id)
        REFERENCES tb_tipo_conquista (tipo_conquista_id),
    CONSTRAINT TB_CONQUISTA_PONTOS_CK
        CHECK(pontos > 0)
);

CREATE TABLE TB_IMAGEM_MISSAO (
    imagem_missao_id INTEGER      GENERATED ALWAYS AS IDENTITY,
    dados_imagem     BLOB         NOT NULL,
    tipo_mime        VARCHAR2(50) NOT NULL,
    CONSTRAINT TB_IMAGEM_MISSAO_PK
        PRIMARY KEY (imagem_missao_id)
);

CREATE TABLE TB_MISSAO (
    missao_id          INTEGER       GENERATED ALWAYS AS IDENTITY,
    tipo_missao_id     INTEGER       NOT NULL,
    imagem_missao_id   INTEGER,
    conquista_id       INTEGER,
    titulo             VARCHAR2(150) NOT NULL,
    descricao          VARCHAR2(150) NOT NULL,
    meta_missao        NUMBER(10,2)  NOT NULL,
    pontos_missao      INTEGER       NOT NULL,
    periodicidade_dias INTEGER,
    prazo_dias         INTEGER,
    CONSTRAINT TB_MISSAO_PK
        PRIMARY KEY (missao_id),
    CONSTRAINT TB_MISSAO_TITULO_UK
        UNIQUE (titulo),
    CONSTRAINT TB_MISSAO_TIPO_FK
        FOREIGN KEY (tipo_missao_id)
        REFERENCES TB_TIPO_MISSAO (tipo_missao_id),
    CONSTRAINT TB_MISSAO_IMAGEM_FK
        FOREIGN KEY (imagem_missao_id)
        REFERENCES tb_imagem_missao (imagem_missao_id),
    CONSTRAINT TB_MISSAO_CONQUISTA_FK
        FOREIGN KEY (conquista_id)
        REFERENCES TB_CONQUISTA (conquista_id),
    CONSTRAINT TB_MISSAO_META_CK
        CHECK (meta_missao > 0),
    CONSTRAINT TB_MISSAO_PONTOS_CK
        CHECK (pontos_missao > 0),
    CONSTRAINT TB_MISSAO_PERIOD_CK
        CHECK (periodicidade_dias IS NULL OR periodicidade_dias IN (1, 7, 30)),
    CONSTRAINT TB_MISSAO_PRAZO_CK
        CHECK (prazo_dias IS NULL OR prazo_dias > 0)
);

CREATE TABLE TB_USUARIO_MISSAO (
    usuario_missao_id  INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id         INTEGER              NOT NULL,
    missao_id          INTEGER              NOT NULL,
    status_missao      VARCHAR2(30)         DEFAULT 'pendente' NOT NULL,
    pontuacao_recebida INTEGER              DEFAULT 0 NOT NULL,
    progresso_atual    NUMBER(10,2)         DEFAULT 0 NOT NULL,
    data_inicio        DATE,
    data_conclusao     DATE,
    CONSTRAINT TB_USUARIO_MISSAO_PK
        PRIMARY KEY (usuario_missao_id),
    CONSTRAINT TB_USUARIO_MISSAO_USU_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_USUARIO_MISSAO_MIS_FK
        FOREIGN KEY (missao_id)
        REFERENCES TB_MISSAO (missao_id),
    CONSTRAINT TB_USUARIO_MISSAO_PONTOS_CK
        CHECK (pontuacao_recebida >= 0),
    CONSTRAINT TB_USUARIO_MISSAO_PROGRESSO_CK
        CHECK (progresso_atual >= 0),
    CONSTRAINT TB_USUARIO_MISSAO_STATUS_CK
        CHECK (status_missao IN ('pendente', 'cancelada', 'concluida', 'em andamento')),
    CONSTRAINT TB_USUARIO_MISSAO_CONCL_CK
        CHECK (status_missao <> 'concluida' OR data_conclusao IS NOT NULL),
    CONSTRAINT TB_USUARIO_MISSAO_DATA_INICIO_CK
        CHECK (status_missao IN ('pendente', 'cancelada') OR data_inicio IS NOT NULL),
    CONSTRAINT TB_USUARIO_MISSAO_DATAS_CK
        CHECK (data_conclusao IS NULL OR data_inicio IS NULL OR data_conclusao >= data_inicio)
);

CREATE TABLE TB_COMPROVANTE (
    comprovante_id    INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_missao_id INTEGER              NOT NULL,
    data_envio        DATE DEFAULT SYSDATE NOT NULL,
    data_validacao    DATE,
    status_validacao  VARCHAR2(50)         NOT NULL,
    -- BLOB: armazena a imagem do comprovante (dado não estruturado em formato binário)
    arquivo           BLOB                 NOT NULL,
    CONSTRAINT TB_COMPROVANTE_PK
        PRIMARY KEY (comprovante_id),
    CONSTRAINT TB_COMPROVANTE_USU_MIS_UK
        UNIQUE (usuario_missao_id),
    CONSTRAINT TB_COMPROVANTE_USU_MIS_FK
        FOREIGN KEY (usuario_missao_id)
        REFERENCES TB_USUARIO_MISSAO (usuario_missao_id),
    CONSTRAINT TB_COMPROVANTE_STATUS_CK
        CHECK (status_validacao IN ('pendente', 'aprovado', 'rejeitado')),
    CONSTRAINT TB_COMPROVANTE_VALID_CK
        CHECK (status_validacao = 'pendente' OR data_validacao IS NOT NULL)
);

CREATE TABLE TB_USUARIO_CONQUISTA (
    usuario_id          INTEGER              NOT NULL,
    conquista_id        INTEGER              NOT NULL,
    data_conquista      DATE DEFAULT SYSDATE NOT NULL,
    pontuacao_recebida  INTEGER              DEFAULT 0 NOT NULL,
    flag_titulo_atual   CHAR(1) DEFAULT 'N'  NOT NULL,
    CONSTRAINT TB_USUARIO_CONQUISTA_PK
        PRIMARY KEY (usuario_id, conquista_id),
    CONSTRAINT TB_USUARIO_CONQUISTA_USU_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_USUARIO_CONQUISTA_CON_FK
        FOREIGN KEY (conquista_id)
        REFERENCES TB_CONQUISTA (conquista_id),
    CONSTRAINT TB_USUARIO_CONQUISTA_TITULO_CK
        CHECK (flag_titulo_atual IN ('S', 'N'))
);

CREATE UNIQUE INDEX TB_USUARIO_CONQUISTA_TITULO_UIX
    ON TB_USUARIO_CONQUISTA (
        usuario_id,
        CASE WHEN flag_titulo_atual = 'S' THEN 'S' END
    );

CREATE TABLE TB_RECARGA (
    recarga_id             INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id             INTEGER              NOT NULL,
    valor_recarga          NUMERIC(6,2)         NOT NULL,
    codigo_pix_copia_cola  VARCHAR2(500)        NOT NULL,
    status_recarga         VARCHAR2(30)         NOT NULL,
    data_solicitacao       DATE DEFAULT SYSDATE NOT NULL,
    data_pagamento         DATE,
    data_credito           DATE,
    CONSTRAINT TB_RECARGA_PK
        PRIMARY KEY (recarga_id),
    CONSTRAINT TB_RECARGA_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_RECARGA_VALOR_CK
        CHECK (valor_recarga BETWEEN 10 AND 200),
    CONSTRAINT TB_RECARGA_STATUS_CK
        CHECK (status_recarga IN ('pendente', 'creditado', 'recusado')),
    CONSTRAINT TB_RECARGA_DATAS_CK
        CHECK (status_recarga <> 'creditado'
               OR (data_pagamento IS NOT NULL AND data_credito IS NOT NULL))
);

CREATE TABLE TB_CONVERSAO_PONTOS (
    conversao_id       INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id         INTEGER              NOT NULL,
    pontos_convertidos INTEGER              NOT NULL,
    creditos_gerados   NUMERIC(6,2)         NOT NULL,
    data_conversao     DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_CONVERSAO_PONTOS_PK
        PRIMARY KEY (conversao_id),
    CONSTRAINT TB_CONVERSAO_PONTOS_USU_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_CONVERSAO_PONTOS_PONTOS_CK
        CHECK (pontos_convertidos > 0),
    CONSTRAINT TB_CONVERSAO_PONTOS_CREDITOS_CK
        CHECK (creditos_gerados > 0)
);

-- Tabela de resumo do usuario / Serve mais para vermos se está tudo certo / FOI DIFICIL ENTENDER COMO FAZER ISSO --

CREATE OR REPLACE VIEW VW_USUARIO_RESUMO AS
SELECT u.usuario_id,
       u.nome,
       u.email,
       GREATEST(
           (NVL(m.pontos_missoes, 0) + NVL(ac.pontos_conquistas, 0)) - NVL(c.pontos_convertidos, 0), 
           0
       ) AS pontos_totais,
       NVL(c.creditos_totais, 0) AS creditos_totais,
       t.titulo AS titulo_atual
FROM   TB_USUARIO u
LEFT JOIN (
        -- Soma de todos os pontos de missões concluídas
        SELECT usuario_id,
               SUM(pontuacao_recebida) AS pontos_missoes
        FROM   TB_USUARIO_MISSAO
        WHERE  status_missao = 'concluida'
        GROUP BY usuario_id
      ) m ON m.usuario_id = u.usuario_id
LEFT JOIN (
        -- Soma de TODOS os pontos de conquistas desbloqueadas (independente do título estar ativo ou não)
        SELECT usuario_id,
               SUM(pontuacao_recebida) AS pontos_conquistas
        FROM   TB_USUARIO_CONQUISTA
        GROUP BY usuario_id
      ) ac ON ac.usuario_id = u.usuario_id
LEFT JOIN (
        -- Soma das conversões já realizadas pelo usuário
        SELECT usuario_id,
               SUM(pontos_convertidos) AS pontos_convertidos,
               SUM(creditos_gerados) AS creditos_totais
        FROM   TB_CONVERSAO_PONTOS
        GROUP BY usuario_id
      ) c ON c.usuario_id = u.usuario_id
LEFT JOIN (
        -- Busca exclusivamente o nome do título que está marcado como atual ('S')
        SELECT uc.usuario_id, c2.titulo
        FROM   TB_USUARIO_CONQUISTA uc
        JOIN   TB_CONQUISTA c2 ON c2.conquista_id = uc.conquista_id
        WHERE  uc.flag_titulo_atual = 'S'
      ) t ON t.usuario_id = u.usuario_id;

CREATE OR REPLACE VIEW VW_USUARIO_HISTORICO AS 
SELECT 
    u.usuario_id,
    SUM(v.carbono_economizado) AS kg_CO2,
    SUM(
        CASE
            WHEN v.km_percorrido > 10 THEN 1
            ELSE 0
        END)
    AS trajetos,
    COUNT(um.usuario_id) AS missoes
FROM tb_usuario u
LEFT JOIN tb_viagem v ON v.usuario_id = u.usuario_id
LEFT JOIN tb_usuario_missao um ON um.usuario_id = u.usuario_id
GROUP BY u.usuario_id;


-- =========================================================
-- COMENTARIOS
-- =========================================================

-- TB_USUARIO
COMMENT ON TABLE TB_USUARIO IS
'Cadastro dos usuários da SoulMove, contendo informações de identificação, autenticação e tipo de acesso.';

COMMENT ON COLUMN TB_USUARIO.usuario_id IS
'Identificador único do usuário, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_USUARIO.nome IS
'Nome completo do usuário cadastrado na plataforma.';

COMMENT ON COLUMN TB_USUARIO.email IS
'Endereço de e-mail único do usuário, utilizado para identificação e acesso à plataforma.';

COMMENT ON COLUMN TB_USUARIO.senha IS
'Senha de autenticação do usuário, armazenada como hash criptográfico.';

COMMENT ON COLUMN TB_USUARIO.tipo_usuario IS
'Perfil de acesso do usuário. Os valores permitidos são comum e admin. O valor padrão é comum.';

COMMENT ON COLUMN TB_USUARIO.data_cadastro IS
'Data de cadastro do usuário. Assume a data atual quando não informada.';


-- TB_CARTEIRA
COMMENT ON TABLE TB_CARTEIRA IS
'Carteira de mobilidade responsável por armazenar os créditos disponíveis de cada usuário. Cada usuário pode possuir apenas uma carteira.';

COMMENT ON COLUMN TB_CARTEIRA.carteira_id IS
'Identificador único da carteira, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_CARTEIRA.usuario_id IS
'Identificador do usuário proprietário da carteira. É chave estrangeira para TB_USUARIO e possui restrição de unicidade.';

COMMENT ON COLUMN TB_CARTEIRA.saldo_mobilidade IS
'Saldo de créditos de mobilidade disponível na carteira, expresso em reais. O valor padrão é zero e não pode ser negativo.';


-- TB_TIPO_VEICULO
COMMENT ON TABLE TB_TIPO_VEICULO IS
'Catálogo dos meios de transporte utilizados no cálculo das emissões e da economia de carbono das viagens.';

COMMENT ON COLUMN TB_TIPO_VEICULO.tipo_veiculo_id IS
'Identificador único do tipo de veículo, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_TIPO_VEICULO.nome IS
'Nome único do tipo de veículo ou modalidade de transporte.';

COMMENT ON COLUMN TB_TIPO_VEICULO.fator_emissao IS
'Fator de emissão de carbono por passageiro-quilômetro, utilizado nos cálculos de emissão e economia de carbono. Não pode ser negativo.';

COMMENT ON COLUMN TB_TIPO_VEICULO.flag_referencia IS
'Indica se o meio de transporte é utilizado como referência para o cálculo do carbono economizado. S significa sim e N significa não. O índice único permite no máximo um registro marcado como referência.';


-- TB_VIAGEM
COMMENT ON TABLE TB_VIAGEM IS
'Registro das viagens realizadas pelos usuários, contendo informações sobre deslocamento, transporte utilizado e impacto ambiental.';

COMMENT ON COLUMN TB_VIAGEM.viagem_id IS
'Identificador único da viagem, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_VIAGEM.usuario_id IS
'Identificador do usuário que realizou a viagem. É chave estrangeira para TB_USUARIO.';

COMMENT ON COLUMN TB_VIAGEM.tipo_veiculo_id IS
'Identificador do meio de transporte utilizado na viagem. É chave estrangeira para TB_TIPO_VEICULO.';

COMMENT ON COLUMN TB_VIAGEM.origem IS
'Local de origem do deslocamento realizado pelo usuário.';

COMMENT ON COLUMN TB_VIAGEM.destino IS
'Local de destino do deslocamento realizado pelo usuário.';

COMMENT ON COLUMN TB_VIAGEM.km_percorrido IS
'Distância percorrida pelo usuário na viagem, expressa em quilômetros. Deve ser maior que zero.';

COMMENT ON COLUMN TB_VIAGEM.carbono_emitido IS
'Quantidade de carbono emitida durante a viagem, expressa em quilogramas de CO2 equivalente.';

COMMENT ON COLUMN TB_VIAGEM.carbono_economizado IS
'Quantidade de carbono economizada em comparação com o meio de transporte definido como referência.';

COMMENT ON COLUMN TB_VIAGEM.data_viagem IS
'Data em que a viagem foi realizada. Assume a data atual quando não informada.';


-- TB_TIPO_MISSAO
COMMENT ON TABLE TB_TIPO_MISSAO IS
'Catálogo dos tipos de missão, definindo como o progresso dos objetivos será medido e acompanhado.';

COMMENT ON COLUMN TB_TIPO_MISSAO.tipo_missao_id IS
'Identificador único do tipo de missão, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_TIPO_MISSAO.nome IS
'Nome único utilizado para identificar e classificar o tipo de missão.';

COMMENT ON COLUMN TB_TIPO_MISSAO.descricao IS
'Descrição da finalidade e das características do tipo de missão.';

COMMENT ON COLUMN TB_TIPO_MISSAO.unidade_medida IS
'Unidade utilizada para medir o progresso da missão, como quilômetros, quilogramas de CO2 equivalente ou quantidade de trajetos.';


-- TB_TIPO_CONQUISTA
COMMENT ON TABLE TB_TIPO_CONQUISTA IS
'Catálogo responsável por classificar as conquistas de acordo com suas unidades de medida e critérios de avaliação.';

COMMENT ON COLUMN TB_TIPO_CONQUISTA.tipo_conquista_id IS
'Identificador único do tipo de conquista, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_TIPO_CONQUISTA.nome IS
'Nome único utilizado para identificar e classificar o tipo de conquista.';

COMMENT ON COLUMN TB_TIPO_CONQUISTA.unidade_medida IS
'Unidade utilizada para avaliar a meta de uma conquista, como quilômetros percorridos, pontos acumulados ou quantidade de viagens.';

COMMENT ON COLUMN TB_TIPO_CONQUISTA.descricao IS
'Descrição da finalidade e dos critérios gerais do tipo de conquista.';


-- TB_CONQUISTA
COMMENT ON TABLE TB_CONQUISTA IS
'Catálogo de conquistas disponíveis na SoulMove, contendo metas, pontuações, descrições e títulos que podem ser desbloqueados pelos usuários.';

COMMENT ON COLUMN TB_CONQUISTA.conquista_id IS
'Identificador único da conquista, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_CONQUISTA.tipo_conquista_id IS
'Identificador do tipo de conquista ao qual o registro pertence. É chave estrangeira para TB_TIPO_CONQUISTA.';

COMMENT ON COLUMN TB_CONQUISTA.meta IS
'Valor que deve ser alcançado para desbloquear a conquista, interpretado conforme a unidade de medida definida em TB_TIPO_CONQUISTA.';

COMMENT ON COLUMN TB_CONQUISTA.nome IS
'Nome único utilizado para identificar a conquista no sistema.';

COMMENT ON COLUMN TB_CONQUISTA.titulo IS
'Título que pode ser selecionado pelo usuário após desbloquear a conquista.';

COMMENT ON COLUMN TB_CONQUISTA.descricao IS
'Descrição das condições necessárias para desbloquear a conquista.';

COMMENT ON COLUMN TB_CONQUISTA.pontos IS
'Quantidade de pontos concedida pela conquista. Deve ser maior que zero.';


-- TB_IMAGEM_MISSAO
COMMENT ON TABLE TB_IMAGEM_MISSAO IS
'Armazena os arquivos de imagem que podem ser associados às missões por meio de seus identificadores.';

COMMENT ON COLUMN TB_IMAGEM_MISSAO.imagem_missao_id IS
'Identificador único da imagem, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_IMAGEM_MISSAO.dados_imagem IS
'Conteúdo binário do arquivo de imagem, armazenado no formato BLOB.';

COMMENT ON COLUMN TB_IMAGEM_MISSAO.tipo_mime IS
'Identificação do formato do arquivo de imagem, como image/png ou image/jpeg.';


-- TB_MISSAO
COMMENT ON TABLE TB_MISSAO IS
'Catálogo de missões de mobilidade sustentável, contendo objetivos, metas, pontuação, periodicidade, prazo e referências opcionais a imagens e conquistas.';

COMMENT ON COLUMN TB_MISSAO.missao_id IS
'Identificador único da missão, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_MISSAO.tipo_missao_id IS
'Identificador do tipo de missão, responsável por definir a unidade de medida utilizada no acompanhamento do objetivo. É chave estrangeira para TB_TIPO_MISSAO.';

COMMENT ON COLUMN TB_MISSAO.imagem_missao_id IS
'Identificador da imagem associada à missão. É uma chave estrangeira opcional para TB_IMAGEM_MISSAO.';

COMMENT ON COLUMN TB_MISSAO.conquista_id IS
'Identificador da conquista relacionada à missão. É uma chave estrangeira opcional para TB_CONQUISTA.';

COMMENT ON COLUMN TB_MISSAO.titulo IS
'Título único utilizado para identificar e apresentar a missão ao usuário.';

COMMENT ON COLUMN TB_MISSAO.descricao IS
'Descrição das atividades e condições necessárias para concluir a missão.';

COMMENT ON COLUMN TB_MISSAO.meta_missao IS
'Valor que deve ser alcançado para concluir a missão, interpretado conforme a unidade de medida de TB_TIPO_MISSAO. Deve ser maior que zero.';

COMMENT ON COLUMN TB_MISSAO.pontos_missao IS
'Quantidade de pontos concedida pela conclusão da missão. Deve ser maior que zero.';

COMMENT ON COLUMN TB_MISSAO.periodicidade_dias IS
'Intervalo em dias para a missão voltar a ficar disponível. Os valores permitidos são 1 para diária, 7 para semanal e 30 para mensal. NULL indica ausência de periodicidade configurada.';

COMMENT ON COLUMN TB_MISSAO.prazo_dias IS
'Quantidade de dias disponíveis para concluir a missão. Deve ser maior que zero quando informada. NULL indica ausência de prazo configurado.';


-- TB_USUARIO_MISSAO
COMMENT ON TABLE TB_USUARIO_MISSAO IS
'Tabela transacional que registra as execuções das missões pelos usuários, armazenando o progresso individual, status, datas e pontuação recebida.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.usuario_missao_id IS
'Identificador único da execução da missão, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.usuario_id IS
'Identificador do usuário responsável pela execução da missão. É chave estrangeira para TB_USUARIO.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.missao_id IS
'Identificador da missão executada pelo usuário. É chave estrangeira para TB_MISSAO.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.status_missao IS
'Situação atual da execução da missão. Os valores permitidos são pendente, em andamento, concluida e cancelada. O valor padrão é pendente.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.pontuacao_recebida IS
'Quantidade de pontos efetivamente recebidos pelo usuário pela conclusão da missão. O valor padrão é zero e não pode ser negativo.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.progresso_atual IS
'Valor atual do progresso individual do usuário em relação à meta da missão, conforme a unidade de medida definida em TB_TIPO_MISSAO.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.data_inicio IS
'Data em que o usuário iniciou a execução da missão. Deve ser informada para missões em andamento ou concluídas.';

COMMENT ON COLUMN TB_USUARIO_MISSAO.data_conclusao IS
'Data em que o usuário concluiu a missão. É obrigatória quando o status é concluida e não pode ser anterior à data de início.';


-- TB_COMPROVANTE
COMMENT ON TABLE TB_COMPROVANTE IS
'Armazena os comprovantes enviados pelos usuários para validação das execuções de missões. Cada execução pode possuir no máximo um comprovante.';

COMMENT ON COLUMN TB_COMPROVANTE.comprovante_id IS
'Identificador único do comprovante, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_COMPROVANTE.usuario_missao_id IS
'Identificador da execução da missão à qual o comprovante pertence. É chave estrangeira única para TB_USUARIO_MISSAO.';

COMMENT ON COLUMN TB_COMPROVANTE.data_envio IS
'Data em que o usuário enviou o comprovante. Assume a data atual quando não informada.';

COMMENT ON COLUMN TB_COMPROVANTE.data_validacao IS
'Data em que o comprovante foi aprovado ou rejeitado. É obrigatória quando o status não é pendente.';

COMMENT ON COLUMN TB_COMPROVANTE.status_validacao IS
'Situação da validação do comprovante. Os valores permitidos são pendente, aprovado e rejeitado.';

COMMENT ON COLUMN TB_COMPROVANTE.arquivo IS
'Arquivo enviado pelo usuário como comprovante da execução da missão, armazenado em formato binário BLOB.';


-- TB_USUARIO_CONQUISTA
COMMENT ON TABLE TB_USUARIO_CONQUISTA IS
'Tabela associativa que registra as conquistas desbloqueadas pelos usuários, incluindo data de obtenção, pontuação recebida e seleção do título atual.';

COMMENT ON COLUMN TB_USUARIO_CONQUISTA.usuario_id IS
'Identificador do usuário que desbloqueou a conquista. Parte da chave primária composta e chave estrangeira para TB_USUARIO.';

COMMENT ON COLUMN TB_USUARIO_CONQUISTA.conquista_id IS
'Identificador da conquista desbloqueada pelo usuário. Parte da chave primária composta e chave estrangeira para TB_CONQUISTA.';

COMMENT ON COLUMN TB_USUARIO_CONQUISTA.data_conquista IS
'Data em que o usuário desbloqueou a conquista. Assume a data atual quando não informada.';

COMMENT ON COLUMN TB_USUARIO_CONQUISTA.pontuacao_recebida IS
'Quantidade de pontos recebidos pelo usuário ao desbloquear a conquista. O valor padrão é zero.';

COMMENT ON COLUMN TB_USUARIO_CONQUISTA.flag_titulo_atual IS
'Indica se a conquista foi selecionada pelo usuário como seu título atual. S significa sim e N significa não. O índice único permite no máximo um título atual por usuário.';


-- TB_RECARGA
COMMENT ON TABLE TB_RECARGA IS
'Registra as solicitações de recarga de créditos de mobilidade dos usuários, incluindo valores, informações de pagamento, status e datas de processamento.';

COMMENT ON COLUMN TB_RECARGA.recarga_id IS
'Identificador único da recarga, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_RECARGA.usuario_id IS
'Identificador do usuário que solicitou a recarga. É chave estrangeira para TB_USUARIO.';

COMMENT ON COLUMN TB_RECARGA.valor_recarga IS
'Valor da recarga em reais. Deve estar entre R$ 10,00 e R$ 200,00, inclusive.';

COMMENT ON COLUMN TB_RECARGA.codigo_pix_copia_cola IS
'Código Pix no formato copia e cola utilizado para realizar o pagamento da recarga.';

COMMENT ON COLUMN TB_RECARGA.status_recarga IS
'Situação atual da solicitação de recarga. Os valores permitidos são pendente, creditado e recusado.';

COMMENT ON COLUMN TB_RECARGA.data_solicitacao IS
'Data em que a solicitação de recarga foi registrada. Assume a data atual quando não informada.';

COMMENT ON COLUMN TB_RECARGA.data_pagamento IS
'Data em que o pagamento da recarga foi confirmado. Deve ser informada quando a recarga estiver creditada.';

COMMENT ON COLUMN TB_RECARGA.data_credito IS
'Data em que os créditos da recarga foram disponibilizados ao usuário. Deve ser informada quando a recarga estiver creditada.';


-- TB_CONVERSAO_PONTOS
COMMENT ON TABLE TB_CONVERSAO_PONTOS IS
'Histórico das operações de conversão dos pontos acumulados pelos usuários em créditos de mobilidade.';

COMMENT ON COLUMN TB_CONVERSAO_PONTOS.conversao_id IS
'Identificador único da conversão, gerado automaticamente e utilizado como chave primária.';

COMMENT ON COLUMN TB_CONVERSAO_PONTOS.usuario_id IS
'Identificador do usuário que realizou a conversão. É chave estrangeira para TB_USUARIO.';

COMMENT ON COLUMN TB_CONVERSAO_PONTOS.pontos_convertidos IS
'Quantidade de pontos utilizada na conversão. Deve ser maior que zero.';

COMMENT ON COLUMN TB_CONVERSAO_PONTOS.creditos_gerados IS
'Valor em reais dos créditos de mobilidade gerados pela conversão. Deve ser maior que zero.';

COMMENT ON COLUMN TB_CONVERSAO_PONTOS.data_conversao IS
'Data em que a conversão de pontos foi registrada. Assume a data atual quando não informada.';


-- VW_USUARIO_RESUMO
COMMENT ON TABLE VW_USUARIO_RESUMO IS
'Visão consolidada dos usuários, apresentando seus pontos disponíveis, créditos gerados por conversões e título atual selecionado.';

COMMENT ON COLUMN VW_USUARIO_RESUMO.usuario_id IS
'Identificador único do usuário, originado de TB_USUARIO.';

COMMENT ON COLUMN VW_USUARIO_RESUMO.nome IS
'Nome do usuário, originado de TB_USUARIO.';

COMMENT ON COLUMN VW_USUARIO_RESUMO.email IS
'E-mail do usuário, originado de TB_USUARIO.';

COMMENT ON COLUMN VW_USUARIO_RESUMO.pontos_totais IS
'Saldo de pontos calculado pela soma das pontuações de missões concluídas e conquistas desbloqueadas, descontando os pontos convertidos. O resultado mínimo é zero.';

COMMENT ON COLUMN VW_USUARIO_RESUMO.creditos_totais IS
'Total de créditos em reais gerados pelas conversões de pontos do usuário. Retorna zero quando não existem conversões registradas.';

COMMENT ON COLUMN VW_USUARIO_RESUMO.titulo_atual IS
'Título da conquista selecionada pelo usuário como atual. Pode ser NULL quando nenhum título estiver selecionado.';


-- VW_USUARIO_HISTORICO
COMMENT ON TABLE VW_USUARIO_HISTORICO IS
'Visão que reúne informações históricas dos usuários relacionadas à economia de carbono, quantidade de trajetos acima de dez quilômetros e registros de execução de missões.';

COMMENT ON COLUMN VW_USUARIO_HISTORICO.usuario_id IS
'Identificador único do usuário, originado de TB_USUARIO.';

COMMENT ON COLUMN VW_USUARIO_HISTORICO.kg_CO2 IS
'Soma do carbono economizado nas viagens do usuário, expressa em quilogramas de CO2 equivalente.';

COMMENT ON COLUMN VW_USUARIO_HISTORICO.trajetos IS
'Quantidade de trajetos registrados com distância superior a dez quilômetros.';

COMMENT ON COLUMN VW_USUARIO_HISTORICO.missoes IS
'Quantidade de registros de execução de missões associados ao usuário.';

COMMIT;