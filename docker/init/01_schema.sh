#!/bin/bash
set -e

sqlplus -s -l "fatec_user/${APP_USER_PASSWORD}@localhost:1521/FREEPDB1" <<'EOF'
WHENEVER SQLERROR EXIT SQL.SQLCODE
@/sql/V1__prestador_usuario_perfil.sql
@/sql/V2__prestador_contato.sql
@/sql/V3__pre_guia.sql
@/sql/V4__pre_guia_item.sql
@/sql/V5__carga_completa.sql
EXIT
EOF
