-- Aponta TODAS as guias oficiais e pre-guias para os arquivos padrao de
-- teste que ficam no repositorio do backend:
--   uploads/guias/guia_padrao.pdf
--   uploads/pre-guias/encaminhamento_padrao.png
-- Assim o "baixar guia" e o "ver encaminhamento" funcionam em qualquer PC.
-- Rode de novo depois de criar guias ou pre-guias novas no teste.
--
-- Como rodar (cmd, de dentro da pasta docker\sql):
--   sqlplus fatec_user/fatec_user_123@localhost:1521/xepdb1 @teste\anexos_padrao_teste.sql
-- (no Docker, troque xepdb1 por FREEPDB1)
WHENEVER SQLERROR EXIT SQL.SQLCODE

UPDATE GUIA_OFICIAL
   SET NOME_ARQUIVO    = 'guia_padrao.pdf',
       CAMINHO_ARQUIVO = 'uploads/guias/guia_padrao.pdf';

UPDATE PRE_GUIA
   SET NM_ANEXO = 'encaminhamento_padrao.png';

COMMIT;

PROMPT Anexos padrao aplicados em todas as guias e pre-guias.
EXIT
