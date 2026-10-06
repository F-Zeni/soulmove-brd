CREATE TABLE TB_USUARIO (
    usuario_id    INTEGER              GENERATED ALWAYS AS IDENTITY,
    nome          VARCHAR2(150)        NOT NULL,
    email         VARCHAR2(150)        NOT NULL,
    senha         VARCHAR2(100)        NOT NULL,
    data_cadastro DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT TB_USUARIO_PK
        PRIMARY KEY (usuario_id),
    CONSTRAINT TB_USUARIO_EMAIL_UK
        UNIQUE (email)
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
    ON TB_TIPO_VEICULO (CASE WHEN flag_referencia = 'S' THEN 'S' END);

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

CREATE TABLE TB_TIPO_MISSAO (
    tipo_missao_id     INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome               VARCHAR2(30)  NOT NULL,
    descricao          VARCHAR2(150) NOT NULL,
    periodicidade_dias INTEGER       NOT NULL,
    CONSTRAINT TB_TIPO_MISSAO_PK
        PRIMARY KEY (tipo_missao_id),
    CONSTRAINT TB_TIPO_MISSAO_NOME_UK
        UNIQUE (nome),
    CONSTRAINT TB_TIPO_MISSAO_PERIOD_CK
        CHECK (periodicidade_dias > 0)
);

CREATE TABLE TB_CONQUISTA (
    conquista_id INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome         VARCHAR2(150) NOT NULL,
    titulo       VARCHAR2(150) NOT NULL,
    descricao    VARCHAR2(200) NOT NULL,
    CONSTRAINT TB_CONQUISTA_PK
        PRIMARY KEY (conquista_id),
    CONSTRAINT TB_CONQUISTA_NOME_UK
        UNIQUE (nome)
);

CREATE TABLE TB_MISSAO (
    missao_id      INTEGER       GENERATED ALWAYS AS IDENTITY,
    tipo_missao_id INTEGER       NOT NULL,
    conquista_id   INTEGER,
    titulo         VARCHAR2(150) NOT NULL,
    descricao      VARCHAR2(150) NOT NULL,
    pontos_missao  INTEGER       NOT NULL,
    CONSTRAINT TB_MISSAO_PK
        PRIMARY KEY (missao_id),
    CONSTRAINT TB_MISSAO_TITULO_UK
        UNIQUE (titulo),
    CONSTRAINT TB_MISSAO_TIPO_FK
        FOREIGN KEY (tipo_missao_id)
        REFERENCES TB_TIPO_MISSAO (tipo_missao_id),
    CONSTRAINT TB_MISSAO_CONQUISTA_FK
        FOREIGN KEY (conquista_id)
        REFERENCES TB_CONQUISTA (conquista_id),
    CONSTRAINT TB_MISSAO_PONTOS_CK
        CHECK (pontos_missao > 0)
);

CREATE TABLE TB_USUARIO_MISSAO (
    usuario_missao_id  INTEGER              GENERATED ALWAYS AS IDENTITY,
    usuario_id         INTEGER              NOT NULL,
    missao_id          INTEGER              NOT NULL,
    status_missao      VARCHAR2(30)         DEFAULT 'pendente' NOT NULL,
    pontuacao_recebida INTEGER              DEFAULT 0 NOT NULL,
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
    usuario_id      INTEGER              NOT NULL,
    conquista_id    INTEGER              NOT NULL,
    data_conquista  DATE DEFAULT SYSDATE NOT NULL,
    flag_titulo_atual CHAR(1) DEFAULT 'N' NOT NULL,
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
       GREATEST(NVL(m.pontos_missoes, 0) - NVL(c.pontos_convertidos, 0), 0) AS pontos_totais,
       NVL(c.creditos_totais, 0) AS creditos_totais,
       t.titulo AS titulo_atual
FROM   TB_USUARIO u
LEFT JOIN (
        SELECT usuario_id,
               SUM(pontuacao_recebida) AS pontos_missoes
        FROM   TB_USUARIO_MISSAO
        WHERE  status_missao = 'concluida'
        GROUP BY usuario_id
      ) m ON m.usuario_id = u.usuario_id
LEFT JOIN (
        SELECT usuario_id,
               SUM(pontos_convertidos) AS pontos_convertidos,
               SUM(creditos_gerados) AS creditos_totais
        FROM   TB_CONVERSAO_PONTOS
        GROUP BY usuario_id
      ) c ON c.usuario_id = u.usuario_id
LEFT JOIN (
        SELECT uc.usuario_id, c2.titulo
        FROM   TB_USUARIO_CONQUISTA uc
        JOIN   TB_CONQUISTA c2 ON c2.conquista_id = uc.conquista_id
        WHERE  uc.flag_titulo_atual = 'S'
      ) t ON t.usuario_id = u.usuario_id;

-- COMENTARIOS

-- TB_USUARIO
COMMENT ON TABLE  TB_USUARIO IS 'Usuários cadastrados na SoulMove. Os pontos disponíveis são derivados pelas missões e conversões; o título atual é escolhido entre as conquistas desbloqueadas.';
COMMENT ON COLUMN TB_USUARIO.usuario_id    IS 'Identificador único do usuário (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_USUARIO.nome          IS 'Nome completo do usuário.';
COMMENT ON COLUMN TB_USUARIO.email         IS 'E-mail do usuário, único no sistema, usado para login.';
COMMENT ON COLUMN TB_USUARIO.senha         IS 'Senha do usuário. Deve ser armazenada como hash, nunca em texto puro.';
COMMENT ON COLUMN TB_USUARIO.data_cadastro IS 'Data em que o usuário se cadastrou. Padrão: data atual.';
-- TB_CARTEIRA
COMMENT ON TABLE  TB_CARTEIRA IS 'Carteira de mobilidade do usuário (relação 1 para 1 com TB_USUARIO), identificada por uma chave própria.';
COMMENT ON COLUMN TB_CARTEIRA.carteira_id      IS 'Identificador único da carteira (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_CARTEIRA.usuario_id       IS 'Usuário dono da carteira. Único no cadastro de carteiras e chave estrangeira para TB_USUARIO.';
COMMENT ON COLUMN TB_CARTEIRA.saldo_mobilidade IS 'Saldo atual de créditos de mobilidade em reais (R$). Nunca negativo.';

-- TB_TIPO_VEICULO
COMMENT ON TABLE  TB_TIPO_VEICULO IS 'Catálogo de tipos de veículo/modal de transporte com o fator de emissão de carbono usado no cálculo do RN05 (carbono emitido e economizado das viagens).';
COMMENT ON COLUMN TB_TIPO_VEICULO.tipo_veiculo_id IS 'Identificador único do tipo de veículo (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_TIPO_VEICULO.nome            IS 'Nome do tipo de veículo. Valores: carro, bicicleta, trem, moto, onibus, metro.';
COMMENT ON COLUMN TB_TIPO_VEICULO.fator_emissao   IS 'Fator de emissão em kg de CO2 equivalente por passageiro-km. O valor é cadastrado por tipo de veículo e utilizado pelo backend nos cálculos de carbono das viagens. Zero representa veículo/modal sem emissão direta no modelo.';
COMMENT ON COLUMN TB_TIPO_VEICULO.flag_referencia   IS 'Indica se é o veículo de referência para calcular o carbono economizado: S = sim, N = não. Apenas um registro pode ser S.';

-- TB_VIAGEM
COMMENT ON TABLE  TB_VIAGEM IS 'Viagens realizadas pelos usuários, com distância percorrida e carbono emitido/economizado calculados a partir do tipo de veículo.';
COMMENT ON COLUMN TB_VIAGEM.viagem_id           IS 'Identificador único da viagem (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_VIAGEM.usuario_id          IS 'Usuário que realizou a viagem. Chave estrangeira para TB_USUARIO.';
COMMENT ON COLUMN TB_VIAGEM.tipo_veiculo_id     IS 'Tipo de veículo usado na viagem. Chave estrangeira para TB_TIPO_VEICULO.';
COMMENT ON COLUMN TB_VIAGEM.origem              IS 'Local de origem da viagem.';
COMMENT ON COLUMN TB_VIAGEM.destino             IS 'Local de destino da viagem.';
COMMENT ON COLUMN TB_VIAGEM.km_percorrido       IS 'Distância percorrida em quilômetros. Maior que zero.';
COMMENT ON COLUMN TB_VIAGEM.carbono_emitido     IS 'Carbono emitido na viagem em kg de CO2 (km_percorrido x fator_emissao do veículo), gravado no momento da viagem.';
COMMENT ON COLUMN TB_VIAGEM.carbono_economizado IS 'Carbono economizado em kg de CO2 em relação ao veículo de referência, gravado no momento da viagem. Nunca negativo.';
COMMENT ON COLUMN TB_VIAGEM.data_viagem         IS 'Data em que a viagem foi realizada. Padrão: data atual.';

-- TB_TIPO_MISSAO
COMMENT ON TABLE  TB_TIPO_MISSAO IS 'Catálogo dos tipos de missão da gamificação, classificados pela ciclo em que podem ser cumpridas.';
COMMENT ON COLUMN TB_TIPO_MISSAO.tipo_missao_id     IS 'Identificador único do tipo de missão (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_TIPO_MISSAO.nome               IS 'Nome do tipo de missão. Valores: diaria, semanal, mensal.';
COMMENT ON COLUMN TB_TIPO_MISSAO.descricao          IS 'Descrição do tipo de missão e de como a ciclo funciona.';
COMMENT ON COLUMN TB_TIPO_MISSAO.periodicidade_dias IS 'Quantidade de dias de duração/janela da missão (ex: 1 = diária, 7 = semanal, 30 = mensal).';

-- TB_CONQUISTA
COMMENT ON TABLE  TB_CONQUISTA IS 'Catálogo de conquistas (títulos) que o usuário pode desbloquear ao concluir missões.';
COMMENT ON COLUMN TB_CONQUISTA.conquista_id IS 'Identificador único da conquista (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_CONQUISTA.nome         IS 'Nome interno e único da conquista.';
COMMENT ON COLUMN TB_CONQUISTA.titulo       IS 'Título exibido ao usuário quando a conquista é desbloqueada.';
COMMENT ON COLUMN TB_CONQUISTA.descricao    IS 'Descrição de como a conquista é obtida.';

-- TB_MISSAO
COMMENT ON TABLE  TB_MISSAO IS 'Catálogo de missões de mobilidade sustentável. Ao ser concluída, a missão gera pontos e, opcionalmente, uma conquista para o usuário.';
COMMENT ON COLUMN TB_MISSAO.missao_id      IS 'Identificador único da missão (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_MISSAO.tipo_missao_id IS 'Tipo da missão (diária, semanal ou mensal). Chave estrangeira para TB_TIPO_MISSAO.';
COMMENT ON COLUMN TB_MISSAO.conquista_id   IS 'Conquista concedida ao usuário quando conclui a missão. Opcional; chave estrangeira para TB_CONQUISTA.';
COMMENT ON COLUMN TB_MISSAO.titulo         IS 'Título único da missão exibido ao usuário.';
COMMENT ON COLUMN TB_MISSAO.descricao      IS 'Descrição do que o usuário precisa fazer para cumprir a missão.';
COMMENT ON COLUMN TB_MISSAO.pontos_missao  IS 'Quantidade de pontos concedidos ao usuário ao concluir a missão. Deve ser maior que zero.';

-- TB_USUARIO_CONQUISTA
COMMENT ON TABLE  TB_USUARIO_CONQUISTA IS 'Tabela associativa entre usuários e conquistas: registra quais conquistas cada usuário desbloqueou e qual delas está escolhida como título atual.';
COMMENT ON COLUMN TB_USUARIO_CONQUISTA.usuario_id      IS 'Usuário que desbloqueou a conquista. Parte da chave primária composta e chave estrangeira para TB_USUARIO.';
COMMENT ON COLUMN TB_USUARIO_CONQUISTA.conquista_id    IS 'Conquista desbloqueada. Parte da chave primária composta e chave estrangeira para TB_CONQUISTA.';
COMMENT ON COLUMN TB_USUARIO_CONQUISTA.data_conquista  IS 'Data em que a conquista foi desbloqueada. Padrão: data atual.';
COMMENT ON COLUMN TB_USUARIO_CONQUISTA.flag_titulo_atual IS 'Indica se esta conquista está selecionada como título atual do usuário: S = sim, N = não. Apenas uma conquista por usuário pode ser S.';

-- TB_RECARGA
COMMENT ON TABLE  TB_RECARGA IS 'Solicitações de recarga de crédito na carteira de mobilidade, pagas por boleto/código de barras.';
COMMENT ON COLUMN TB_RECARGA.recarga_id       IS 'Identificador único da recarga (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_RECARGA.usuario_id       IS 'Usuário que solicitou a recarga. Chave estrangeira para TB_USUARIO.';
COMMENT ON COLUMN TB_RECARGA.valor_recarga    IS 'Valor da recarga em reais (R$). Entre 10 e 200.';
COMMENT ON COLUMN TB_RECARGA.codigo_barras    IS 'Código de barras gerado para pagamento da recarga.';
COMMENT ON COLUMN TB_RECARGA.status_recarga   IS 'Situação da recarga. Valores: pendente, creditado, recusado.';
COMMENT ON COLUMN TB_RECARGA.data_solicitacao IS 'Data em que a recarga foi solicitada. Padrão: data atual.';
COMMENT ON COLUMN TB_RECARGA.data_pagamento   IS 'Data em que o pagamento foi confirmado. Nulo enquanto não pago.';
COMMENT ON COLUMN TB_RECARGA.data_credito     IS 'Data em que o valor foi creditado na carteira. Nulo enquanto não creditado.';

-- TB_CONVERSAO_PONTOS
COMMENT ON TABLE  TB_CONVERSAO_PONTOS IS 'Registro das conversões de pontos acumulados pelos usuários em créditos de mobilidade.';
COMMENT ON COLUMN TB_CONVERSAO_PONTOS.conversao_id       IS 'Identificador único da conversão (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_CONVERSAO_PONTOS.usuario_id         IS 'Usuário que realizou a conversão. Chave estrangeira para TB_USUARIO.';
COMMENT ON COLUMN TB_CONVERSAO_PONTOS.pontos_convertidos IS 'Quantidade de pontos convertidos pelo usuário. A funcionalidade do aplicativo converte o saldo de pontos disponível.';
COMMENT ON COLUMN TB_CONVERSAO_PONTOS.creditos_gerados   IS 'Valor em créditos de mobilidade em reais (R$) gerado pela conversão dos pontos.';
COMMENT ON COLUMN TB_CONVERSAO_PONTOS.data_conversao     IS 'Data em que a conversão de pontos foi realizada. Padrão: data atual.';
-- TB_USUARIO_MISSAO
COMMENT ON TABLE  TB_USUARIO_MISSAO IS 'Tabela transacional do SoulMove: cada linha representa uma execução de missão por um usuário. Quando concluída, registra os pontos recebidos. Uma mesma missão pode ser repetida em períodos diferentes.';
COMMENT ON COLUMN TB_USUARIO_MISSAO.usuario_missao_id  IS 'Identificador único da execução da missão (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_USUARIO_MISSAO.usuario_id         IS 'Usuário que executa a missão. Chave estrangeira para TB_USUARIO.';
COMMENT ON COLUMN TB_USUARIO_MISSAO.missao_id          IS 'Missão executada. Chave estrangeira para TB_MISSAO.';
COMMENT ON COLUMN TB_USUARIO_MISSAO.status_missao      IS 'Situação da execução. Valores: pendente, em andamento, concluida ou cancelada.';
COMMENT ON COLUMN TB_USUARIO_MISSAO.pontuacao_recebida IS 'Pontos efetivamente recebidos pelo usuário. Zero enquanto a missão não é concluída.';
COMMENT ON COLUMN TB_USUARIO_MISSAO.data_inicio        IS 'Data em que o usuário iniciou a missão. Nula enquanto a execução estiver pendente.';
COMMENT ON COLUMN TB_USUARIO_MISSAO.data_conclusao     IS 'Data de conclusão da missão. Obrigatória quando status_missao = concluida.';

-- TB_COMPROVANTE
COMMENT ON TABLE  TB_COMPROVANTE IS 'Comprovantes (imagens) enviados pelos usuários para validar a conclusão de uma de missão. Tem no máximo um comprovante por execução.';
COMMENT ON COLUMN TB_COMPROVANTE.comprovante_id    IS 'Identificador único do comprovante (chave primária gerada automaticamente).';
COMMENT ON COLUMN TB_COMPROVANTE.usuario_missao_id IS 'Execução de missão que o comprovante valida. Único: um comprovante por execução. Chave estrangeira para TB_USUARIO_MISSAO.';
COMMENT ON COLUMN TB_COMPROVANTE.data_envio      IS 'Data em que o comprovante foi enviado. Padrão: data atual.';
COMMENT ON COLUMN TB_COMPROVANTE.data_validacao  IS 'Data em que o comprovante foi validado. Nulo enquanto pendente.';
COMMENT ON COLUMN TB_COMPROVANTE.status_validacao IS 'Situação da validação. Valores: pendente, aprovado, rejeitado.';
COMMENT ON COLUMN TB_COMPROVANTE.arquivo         IS 'Imagem do comprovante armazenada em formato binário (BLOB).';

-- VW_USUARIO_RESUMO
COMMENT ON TABLE  VW_USUARIO_RESUMO IS 'Visão com o resumo de cada usuário: pontos ainda disponíveis após conversões, créditos gerados pelas conversões e o título atualmente escolhido pelo usuário entre as conquistas desbloqueadas.';
COMMENT ON COLUMN VW_USUARIO_RESUMO.usuario_id      IS 'Identificador do usuário.';
COMMENT ON COLUMN VW_USUARIO_RESUMO.nome            IS 'Nome do usuário.';
COMMENT ON COLUMN VW_USUARIO_RESUMO.email           IS 'E-mail do usuário.';
COMMENT ON COLUMN VW_USUARIO_RESUMO.pontos_totais   IS 'Saldo atual de pontos: pontos de missões concluídas menos os pontos já convertidos.';
COMMENT ON COLUMN VW_USUARIO_RESUMO.creditos_totais IS 'Soma dos créditos (R$) gerados nas conversões de pontos.';
COMMENT ON COLUMN VW_USUARIO_RESUMO.titulo_atual    IS 'Título atualmente escolhido pelo usuário entre as conquistas desbloqueadas. Nulo se ainda não houver título selecionado.';