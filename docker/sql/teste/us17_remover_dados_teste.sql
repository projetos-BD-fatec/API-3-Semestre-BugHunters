-- =====================================================================
-- REMOVE OS DADOS DE TESTE DA US17
-- =====================================================================
--
-- Apaga SOMENTE o que o us17_dados_teste.sql criou: as guias com codigo
-- GUIA-US17-<n> e tudo que depende delas (historico de status, itens do
-- espelho, espelho, guia oficial, itens da pre-guia e pre-guia).
-- Nao mexe em usuarios, senhas nem perfis.
--
-- COMO RODAR (na pasta do repositorio central, com o container ligado):
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/us17_remover_dados_teste.sql"
-- =====================================================================

SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
    v_total PLS_INTEGER := 0;
BEGIN
    FOR g IN (SELECT ID_GUIA_OFICIAL, SOLICITACAO_ID
                FROM GUIA_OFICIAL
               WHERE CODIGO_GUIA LIKE 'GUIA-US17-%') LOOP

        -- historico da guia e da solicitacao (antes das tabelas que ele
        -- referencia, senao a FK barra o delete)
        DELETE FROM HISTORICO_STATUS WHERE ID_PRE_GUIA = g.SOLICITACAO_ID;

        -- revisoes da Lisura dos itens do espelho
        DELETE FROM LISURA_REVISAO_ITEM
         WHERE ID_ESPELHO_ITEM IN (SELECT i.ID_ESPELHO_ITEM
                                     FROM ESPELHO_ITEM i
                                     JOIN ESPELHO e ON e.ID_ESPELHO = i.ID_ESPELHO
                                    WHERE e.ID_GUIA_OFICIAL = g.ID_GUIA_OFICIAL);

        -- itens do espelho e o espelho
        DELETE FROM ESPELHO_ITEM
         WHERE ID_ESPELHO IN (SELECT ID_ESPELHO FROM ESPELHO WHERE ID_GUIA_OFICIAL = g.ID_GUIA_OFICIAL);
        DELETE FROM ESPELHO WHERE ID_GUIA_OFICIAL = g.ID_GUIA_OFICIAL;

        -- guia oficial, itens da pre-guia e a pre-guia
        DELETE FROM GUIA_OFICIAL WHERE ID_GUIA_OFICIAL = g.ID_GUIA_OFICIAL;
        DELETE FROM PRE_GUIA_ITEM WHERE ID_PRE_GUIA = g.SOLICITACAO_ID;
        DELETE FROM PRE_GUIA WHERE ID_PRE_GUIA = g.SOLICITACAO_ID;

        v_total := v_total + 1;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Guias de teste da US17 removidas: ' || v_total);
END;
/

EXIT
