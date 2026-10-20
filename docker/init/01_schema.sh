#!/bin/bash
set -Eeuo pipefail

LOG="/tmp/carga-banco.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== INICIO DA CARGA: $(date) ==="

sqlplus -s -l "fatec_user/${APP_USER_PASSWORD}@localhost:1521/FREEPDB1" <<'EOF'
WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT === V1: prestador, usuario e perfil ===
@/sql/V1__prestador_usuario_perfil.sql

PROMPT === V2 ===
@/sql/V2__prestador_contato.sql

PROMPT === V3 ===
@/sql/V3__pre_guia.sql

PROMPT === V4 ===
@/sql/V4__pre_guia_item.sql

PROMPT === V5 ===
@/sql/V5__guia_oficial.sql

PROMPT === V6 ===
@/sql/V6__espelho.sql

PROMPT === V7: carga completa ===
@/sql/V7__carga_completa.sql

PROMPT === V8: catalogo TUSS ===
@/sql/V8__carga_completa_tabela_TUSS.sql

PROMPT === V9: exames ===
@/sql/V9__carga_completa_exames.sql

PROMPT === V10: relacoes exame prestador ===
@/sql/V10__carga_completa_exame_prestador.sql

PROMPT === V11: revisao da lisura ===
@/sql/V11__lisura_revisao.sql

PROMPT === CONFERENCIA EXAME_PRESTADOR ===
SELECT COUNT(*) AS TOTAL_RELACOES FROM EXAME_PRESTADOR;

EXIT SUCCESS
EOF

echo "=== FIM DA CARGA ==="
