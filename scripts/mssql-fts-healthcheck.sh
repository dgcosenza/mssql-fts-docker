#!/usr/bin/env bash
# Healthcheck for SQL Server + Full-Text Search using mssql-tools18 sqlcmd.
# Reads the SA password from environment or secret file at runtime and passes it
# exclusively via SQLCMDPASSWORD (never on command-line arguments).
set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
[ -x "$SQLCMD" ] || exit 1

PW="${MSSQL_SA_PASSWORD:-${SA_PASSWORD:-}}"
if [ -z "$PW" ] && [ -n "${MSSQL_SA_PASSWORD_FILE:-}" ] && [ -r "${MSSQL_SA_PASSWORD_FILE}" ]; then
  PW="$(tr -d '\r\n' < "${MSSQL_SA_PASSWORD_FILE}")"
fi
[ -n "$PW" ] || exit 1

PORT="${MSSQL_TCP_PORT:-1433}"
export SQLCMDPASSWORD="$PW"

"$SQLCMD" \
  -S "127.0.0.1,${PORT}" \
  -U sa \
  -C \
  -l 5 \
  -t 5 \
  -b \
  -h -1 \
  -Q "SET NOCOUNT ON; SELECT 1" >/dev/null
