#!/usr/bin/env bash
# Zero-binary runtime-installer entrypoint for Microsoft SQL Server + Full-Text Search.
# Downloads GPG-verified official Microsoft APT packages only after the end user
# explicitly accepts the Microsoft SQL Server EULA via ACCEPT_EULA=Y, then drops
# privileges via setpriv to non-root mssql (UID 10001, GID 0).
set -euo pipefail

log() {
  printf '[mssql-fts-entrypoint] %s\n' "$*"
}

if [[ "${ACCEPT_EULA:-}" != "Y" && "${ACCEPT_EULA:-}" != "y" ]]; then
  cat >&2 <<'EOF'
ERROR: Microsoft SQL Server EULA not accepted.
This image contains zero proprietary Microsoft binaries. To download and run
Microsoft SQL Server Database Engine, Full-Text Search (mssql-server-fts), and
mssql-tools18 directly from https://packages.microsoft.com, you must explicitly
accept the Microsoft Software License Terms by setting:
  -e ACCEPT_EULA=Y
Review terms at: https://www.microsoft.com/licensing/product-terms
EOF
  exit 1
fi

# Support Docker secret file for SA password without exposing it in process arguments
if [ -z "${MSSQL_SA_PASSWORD:-}" ] && [ -n "${MSSQL_SA_PASSWORD_FILE:-}" ]; then
  if [ ! -r "${MSSQL_SA_PASSWORD_FILE}" ]; then
    log "ERROR: MSSQL_SA_PASSWORD_FILE '${MSSQL_SA_PASSWORD_FILE}' is not readable." >&2
    exit 1
  fi
  MSSQL_SA_PASSWORD="$(tr -d '\r\n' < "${MSSQL_SA_PASSWORD_FILE}")"
  export MSSQL_SA_PASSWORD
fi

need_install=0
if [ ! -x /opt/mssql/bin/sqlservr ] || [ ! -x /opt/mssql-tools18/bin/sqlcmd ]; then
  need_install=1
elif ! dpkg-query -W -f='${Status}' mssql-server-fts 2>/dev/null | grep -q "install ok installed"; then
  need_install=1
fi

if [ "$need_install" -eq 1 ]; then
  if [ "$(id -u)" -ne 0 ]; then
    log "ERROR: Initial startup requires root solely to install GPG-verified Microsoft APT packages before dropping to UID 10001 (mssql)." >&2
    exit 1
  fi

  apt_opts=()
  if [[ "${MSSQL_FTS_CACHE:-true}" != "false" ]]; then
    mkdir -p /var/opt/mssql/.apt-cache/partial
    apt_opts+=(-o "Dir::Cache::archives=/var/opt/mssql/.apt-cache")
  fi

  pkg_server="mssql-server"
  pkg_fts="mssql-server-fts"
  if [ -n "${MSSQL_PACKAGE_VERSION:-}" ]; then
    pkg_server="mssql-server=${MSSQL_PACKAGE_VERSION}"
    pkg_fts="mssql-server-fts=${MSSQL_PACKAGE_VERSION}"
  fi

  log "Fetching GPG-verified official SQL Server ${MSSQL_MAJOR:-2025} + Full-Text Search + mssql-tools18 packages from packages.microsoft.com..."
  export DEBIAN_FRONTEND=noninteractive
  export ACCEPT_EULA=Y
  apt-get update
  apt-get "${apt_opts[@]}" install -y --no-install-recommends \
    "$pkg_server" \
    "$pkg_fts" \
    mssql-tools18
  rm -rf /var/lib/apt/lists/*
  log "Installed versions: $(dpkg-query -W -f='${Package}=${Version} ' mssql-server mssql-server-fts mssql-tools18)"
fi

mkdir -p /var/opt/mssql/data /var/opt/mssql/log /var/opt/mssql/secrets
if [ "$(id -u)" -eq 0 ]; then
  chown -R 10001:0 /var/opt/mssql
  chmod 0770 /var/opt/mssql /var/opt/mssql/data /var/opt/mssql/log /var/opt/mssql/secrets
  log "Dropping privileges to non-root mssql (10001:0) and starting SQL Server..."
  exec setpriv --reuid=10001 --regid=0 --init-groups -- /opt/mssql/bin/sqlservr "$@"
fi

exec /opt/mssql/bin/sqlservr "$@"
