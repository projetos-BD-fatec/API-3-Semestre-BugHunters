-- =====================================================================
-- DADOS DE TESTE DO ACOMPANHAMENTO DO FLUXO (US17 / SCRUM-65 e SCRUM-66)
-- =====================================================================
--
-- PARA QUE SERVE
--   Cria tres guias paradas em etapas diferentes do fluxo, COM o historico
--   de status de cada uma. Sem isso a tela de acompanhamento fica vazia:
--   chegar a esses estados pelo fluxo normal exige passar por quatro
--   logins diferentes (beneficiario, FUSEx, OCS e Lisura).
--
--   As guias criadas aqui tambem exercitam a correcao da
--   CK_GUIA_OFICIAL_STATUS: a guia C e gravada como LISURA_APROVADA, que
--   o banco recusava antes do V12.
--
--   >>> NAO roda automaticamente (nao esta no 01_schema.sh).         <<<
--   >>> Use so em banco de desenvolvimento/teste, nunca em producao. <<<
--
-- PRE-REQUISITO
--   Banco com V1 a V12 carregados (o V12 cria a HISTORICO_STATUS e as
--   colunas de liquidacao).
--
-- COMO RODAR (na pasta do repositorio central, com o container ligado --
-- a pasta docker/sql fica montada em /sql):
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/us17_dados_teste.sql"
--
--   Pode rodar mais de uma vez: cada execucao cria tres guias novas.
--
-- O QUE ELE FAZ
--   1. Define a senha de admin@fusex.test como "senha123" e garante que
--      ele tenha o perfil FUSEX. O seed do V7 nao cria nenhum usuario com
--      esse perfil, e o acompanhamento e restrito a FUSEX e ADMIN.
--   2. Cria tres guias GUIA-US17-<n>:
--
--      | Guia | Parada em   | Status da guia   | Timeline  |
--      |------|-------------|------------------|-----------|
--      | A    | Emissao     | ATIVA            | 2 de 6    |
--      | B    | Faturamento | UTILIZADA        | 4 de 6    |
--      | C    | Lisura      | LISURA_APROVADA  | 5 de 6    |
--
--   3. Grava o historico de cada uma, com datas espalhadas no passado
--      para a linha do tempo nao sair toda no mesmo dia.
--
-- COMO TESTAR DEPOIS DE RODAR (backend na 8080 e frontend no Live Server)
--   1. Login (aba "Sou usuario"): admin@fusex.test / senha123
--   2. Abra pages/fusex/acompanhamento.html
--
--   Checklist:
--   [ ] as tres guias aparecem, cada uma com a etapa certa no selo
--   [ ] filtro "Lisura" deixa so a guia C; "Emissao" deixa so a A
--   [ ] busca por codigo e por nome do beneficiario filtra a lista
--   [ ] "Ver fluxo" na guia A: 2 etapas concluidas com data, 4 em cinza
--   [ ] "Ver fluxo" na guia B: 4 concluidas, "Etapa atual" no Faturamento
--   [ ] "Ver fluxo" na guia C: 5 concluidas e o botao "Registrar liquidacao"
--   [ ] clicar em "Registrar liquidacao" na guia C: a 6a etapa fecha, o
--       botao some e a lista passa a mostrar a guia em Liquidacao
--   [ ] nas guias que ja existiam antes do V12, a data das etapas de
--       Realizacao e Lisura aparece com o selo "estimada"
--   [ ] beneficiario comum (joao.silva@militar.test) recebe 403 em
--       /acompanhamento e nao enxerga a tela
--
-- COMO REMOVER
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/us17_remover_dados_teste.sql"
-- =====================================================================

SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
    v_hoje      DATE := TRUNC(SYSDATE);
    v_fusex     NUMBER;
    v_usuario   NUMBER;
    v_prestador NUMBER;
    v_guia_a    NUMBER;
    v_guia_b    NUMBER;
    v_guia_c    NUMBER;
    v_pre_a     NUMBER;
    v_pre_b     NUMBER;
    v_pre_c     NUMBER;

    -- Grava um evento da trilha com data no passado.
    -- REGISTRADO_EM tem DEFAULT SYSTIMESTAMP, entao precisa ser informado
    -- explicitamente para a linha do tempo nao sair toda em "hoje".
    PROCEDURE evento(p_pre_guia  NUMBER,
                     p_guia      NUMBER,
                     p_etapa     VARCHAR2,
                     p_anterior  VARCHAR2,
                     p_novo      VARCHAR2,
                     p_usuario   NUMBER,
                     p_texto     VARCHAR2,
                     p_dias_atras NUMBER) IS
    BEGIN
        INSERT INTO HISTORICO_STATUS
            (ID_PRE_GUIA, ID_GUIA_OFICIAL, ETAPA, STATUS_ANTERIOR, STATUS_NOVO,
             ID_USUARIO, OBSERVACAO, REGISTRADO_EM)
        VALUES
            (p_pre_guia, p_guia, p_etapa, p_anterior, p_novo,
             p_usuario, p_texto, CAST(v_hoje - p_dias_atras AS TIMESTAMP) + INTERVAL '10' HOUR);
    END;

    -- Cria pre-guia + guia oficial e devolve os dois ids.
    PROCEDURE criar_guia(p_status_guia VARCHAR2,
                         p_sufixo      VARCHAR2,
                         p_pre_guia    OUT NUMBER,
                         p_guia        OUT NUMBER) IS
    BEGIN
        INSERT INTO PRE_GUIA (ID_USUARIO, NM_ANEXO, STATUS)
        VALUES (v_usuario, 'teste-us17.png', 'AUTORIZADA')
        RETURNING ID_PRE_GUIA INTO p_pre_guia;

        INSERT INTO GUIA_OFICIAL
            (SOLICITACAO_ID, CODIGO_GUIA, NOME_ARQUIVO, CAMINHO_ARQUIVO, STATUS)
        VALUES
            (p_pre_guia, 'GUIA-US17-' || p_sufixo || p_pre_guia,
             'teste-us17.pdf', 'uploads/guias/teste-us17.pdf', p_status_guia)
        RETURNING ID_GUIA_OFICIAL INTO p_guia;
    END;

    -- Espelho enviado, com dois itens, para a guia ficar coerente com
    -- as etapas de faturamento e Lisura.
    PROCEDURE criar_espelho_enviado(p_guia NUMBER, p_dias_atras NUMBER) IS
        v_espelho NUMBER;
    BEGIN
        INSERT INTO ESPELHO (ID_GUIA_OFICIAL, ID_PRESTADOR, STATUS, ATUALIZADO_EM, ENVIADO_EM)
        VALUES (p_guia, v_prestador, 'ENVIADO',
                CAST(v_hoje - p_dias_atras AS TIMESTAMP),
                CAST(v_hoje - p_dias_atras AS TIMESTAMP))
        RETURNING ID_ESPELHO INTO v_espelho;

        FOR r IN (SELECT e.COD_TUSS, ep.VALOR_CONTRATUAL
                    FROM EXAME_PRESTADOR ep
                    JOIN EXAME e ON e.ID_EXAME = ep.ID_EXAME
                   WHERE ep.ID_PRESTADOR = v_prestador
                     AND ep.STATUS = 'ATIVO'
                   ORDER BY e.ID_EXAME
                   FETCH FIRST 2 ROWS ONLY) LOOP

            INSERT INTO ESPELHO_ITEM
                (ID_ESPELHO, COD_TUSS, DT_REALIZACAO, QUANTIDADE, VALOR_UNITARIO)
            VALUES
                (v_espelho, r.COD_TUSS, v_hoje - p_dias_atras - 2, 1, r.VALOR_CONTRATUAL);
        END LOOP;
    END;

BEGIN
    -- -----------------------------------------------------------------
    -- 1. Usuario do FUSEx
    -- -----------------------------------------------------------------
    UPDATE USUARIO
       SET DS_SENHA_HASH = '$2a$10$O92AsuVxibC/OiLrSsUyW.XzoeLHyVwUi4E4oY2TDZYiKzCKAEQfu',
           FL_ATIVO = 'S'
     WHERE LOWER(DS_EMAIL) = 'admin@fusex.test';

    SELECT MIN(ID_USUARIO) INTO v_fusex
      FROM USUARIO
     WHERE LOWER(DS_EMAIL) = 'admin@fusex.test';

    -- O seed nao cria ninguem com perfil FUSEX; sem isso so da para
    -- entrar no acompanhamento pelo ADMIN.
    INSERT INTO USUARIO_PERFIL (ID_USUARIO, CD_PERFIL)
    SELECT v_fusex, 'FUSEX' FROM DUAL
     WHERE NOT EXISTS (SELECT 1 FROM USUARIO_PERFIL
                        WHERE ID_USUARIO = v_fusex AND CD_PERFIL = 'FUSEX');

    -- -----------------------------------------------------------------
    -- 2. Beneficiario e OCS
    -- -----------------------------------------------------------------
    SELECT MIN(ID_USUARIO) INTO v_usuario
      FROM USUARIO
     WHERE LOWER(DS_EMAIL) = 'joao.silva@militar.test';

    IF v_usuario IS NULL THEN
        SELECT MIN(u.ID_USUARIO) INTO v_usuario
          FROM USUARIO u
         WHERE u.ID_PRESTADOR IS NULL
           AND NOT EXISTS (SELECT 1 FROM USUARIO_PERFIL p WHERE p.ID_USUARIO = u.ID_USUARIO);
    END IF;

    SELECT MIN(ID_PRESTADOR) INTO v_prestador
      FROM EXAME_PRESTADOR
     WHERE STATUS = 'ATIVO';

    -- -----------------------------------------------------------------
    -- 3. Guia A - parada na emissao (2 de 6)
    -- -----------------------------------------------------------------
    criar_guia('ATIVA', 'A', v_pre_a, v_guia_a);

    evento(v_pre_a, NULL,     'SOLICITACAO', NULL,         'EM_ANALISE', v_usuario,
           'Solicitacao aberta pelo beneficiario.', 20);
    evento(v_pre_a, v_guia_a, 'EMISSAO',     NULL,         'ATIVA',      v_fusex,
           'Guia oficial emitida pelo FUSEx.', 18);

    -- -----------------------------------------------------------------
    -- 4. Guia B - parada no faturamento (4 de 6)
    -- -----------------------------------------------------------------
    criar_guia('UTILIZADA', 'B', v_pre_b, v_guia_b);
    criar_espelho_enviado(v_guia_b, 5);

    evento(v_pre_b, NULL,     'SOLICITACAO', NULL,         'EM_ANALISE', v_usuario,
           'Solicitacao aberta pelo beneficiario.', 15);
    evento(v_pre_b, v_guia_b, 'EMISSAO',     NULL,         'ATIVA',      v_fusex,
           'Guia oficial emitida pelo FUSEx.', 13);
    evento(v_pre_b, v_guia_b, 'REALIZACAO',  'ATIVA',      'UTILIZADA',  NULL,
           'Procedimentos realizados pelo prestador.', 8);
    evento(v_pre_b, v_guia_b, 'FATURAMENTO', 'RASCUNHO',   'ENVIADO',    NULL,
           'Espelho enviado pela OCS.', 5);

    -- -----------------------------------------------------------------
    -- 5. Guia C - aprovada pela Lisura, pronta para liquidar (5 de 6)
    --    Depende do V12: LISURA_APROVADA era recusado pela CHECK antiga.
    -- -----------------------------------------------------------------
    criar_guia('LISURA_APROVADA', 'C', v_pre_c, v_guia_c);
    criar_espelho_enviado(v_guia_c, 18);

    evento(v_pre_c, NULL,     'SOLICITACAO', NULL,         'EM_ANALISE',      v_usuario,
           'Solicitacao aberta pelo beneficiario.', 30);
    evento(v_pre_c, v_guia_c, 'EMISSAO',     NULL,         'ATIVA',           v_fusex,
           'Guia oficial emitida pelo FUSEx.', 28);
    evento(v_pre_c, v_guia_c, 'REALIZACAO',  'ATIVA',      'UTILIZADA',       NULL,
           'Procedimentos realizados pelo prestador.', 22);
    evento(v_pre_c, v_guia_c, 'FATURAMENTO', 'RASCUNHO',   'ENVIADO',         NULL,
           'Espelho enviado pela OCS.', 18);
    evento(v_pre_c, v_guia_c, 'LISURA',      'UTILIZADA',  'LISURA_APROVADA', v_fusex,
           'Valores conferidos e aprovados para pagamento.', 12);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE(' Dados de teste da US17 criados.');
    DBMS_OUTPUT.PUT_LINE('   Guia A (Emissao)     id=' || v_guia_a);
    DBMS_OUTPUT.PUT_LINE('   Guia B (Faturamento) id=' || v_guia_b);
    DBMS_OUTPUT.PUT_LINE('   Guia C (Lisura)      id=' || v_guia_c || '  <- da para liquidar');
    DBMS_OUTPUT.PUT_LINE(' Login: admin@fusex.test / senha123');
    DBMS_OUTPUT.PUT_LINE(' Abra:  pages/fusex/acompanhamento.html');
    DBMS_OUTPUT.PUT_LINE('==================================================');
END;
/

EXIT
