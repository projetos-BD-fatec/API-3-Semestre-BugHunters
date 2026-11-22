-- Apaga TODOS os objetos do usuario conectado (fatec_user).
-- Nao mexe em outros usuarios do Oracle. Use antes da carga_completa.sql
-- para recriar o banco do zero.
--
-- Como rodar (cmd, de dentro da pasta docker\sql):
--   sqlplus fatec_user/fatec_user_123@localhost:1521/xepdb1 @teste\limpar_schema.sql
-- (no Docker, troque xepdb1 por FREEPDB1)
SET SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

BEGIN
  FOR m IN (SELECT mview_name FROM user_mviews) LOOP
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW "' || m.mview_name || '"';
  END LOOP;

  FOR t IN (SELECT table_name FROM user_tables WHERE table_name NOT LIKE 'BIN$%') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE';
  END LOOP;

  FOR o IN (SELECT object_name, object_type FROM user_objects
             WHERE object_type IN ('VIEW','SEQUENCE','PROCEDURE','FUNCTION',
                                   'PACKAGE','TYPE','SYNONYM')
               AND object_name NOT LIKE 'ISEQ$$%') LOOP
    EXECUTE IMMEDIATE 'DROP ' || o.object_type || ' "' || o.object_name || '"'
                      || CASE WHEN o.object_type = 'TYPE' THEN ' FORCE' END;
  END LOOP;
END;
/

PURGE RECYCLEBIN;

PROMPT Objetos que sobraram no schema (o certo e 0):
SELECT COUNT(*) AS OBJETOS_RESTANTES FROM user_objects WHERE object_name NOT LIKE 'ISEQ$$%';
EXIT
