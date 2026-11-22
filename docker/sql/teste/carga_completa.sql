-- Carga completa do banco (V1 a V16), na mesma ordem do docker/init/01_schema.sh.
-- Ao criar uma nova V*.sql, inclua-a aqui tambem.
--
-- Como rodar (cmd, de dentro da pasta docker\sql):
--   set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
--   sqlplus fatec_user/fatec_user_123@localhost:1521/xepdb1 @teste\carga_completa.sql
-- (no Docker, troque xepdb1 por FREEPDB1)
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT FAILURE

PROMPT === V1__prestador_usuario_perfil.sql ===
@V1__prestador_usuario_perfil.sql

PROMPT === V2__prestador_contato.sql ===
@V2__prestador_contato.sql

PROMPT === V3__pre_guia.sql ===
@V3__pre_guia.sql

PROMPT === V4__pre_guia_item.sql ===
@V4__pre_guia_item.sql

PROMPT === V5__guia_oficial.sql ===
@V5__guia_oficial.sql

PROMPT === V6__espelho.sql ===
@V6__espelho.sql

PROMPT === V7__carga_completa.sql ===
@V7__carga_completa.sql

PROMPT === V8__carga_completa_tabela_TUSS.sql ===
@V8__carga_completa_tabela_TUSS.sql

PROMPT === V9__carga_completa_exames.sql ===
@V9__carga_completa_exames.sql

PROMPT === V10__carga_completa_exame_prestador.sql ===
@V10__carga_completa_exame_prestador.sql

PROMPT === V11__lisura_revisao.sql ===
@V11__lisura_revisao.sql

PROMPT === V12__espelho_envio_em_lote.sql ===
@V12__espelho_envio_em_lote.sql

PROMPT === V13__historico_status.sql ===
@V13__historico_status.sql

PROMPT === V14__liquidacao_valores.sql ===
@V14__liquidacao_valores.sql

PROMPT === V15__guia_vencimento_assinatura.sql ===
@V15__guia_vencimento_assinatura.sql

PROMPT === V16__fluxo_fusex.sql ===
@V16__fluxo_fusex.sql

COMMIT;
PROMPT === CARGA V1 A V16 CONCLUIDA ===
EXIT
