#!/bin/bash
set -e

sqlplus -s -l "fatec_user/${APP_USER_PASSWORD}@localhost:1521/FREEPDB1" <<'EOF'
WHENEVER SQLERROR EXIT SQL.SQLCODE
@/sql/V1__prestador_usuario_perfil.sql
@/sql/prestador_contato.sql
@/sql/pre_guia.sql
@/sql/carga_completa.sql
EXIT
EOF
