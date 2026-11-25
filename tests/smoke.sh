#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: $0 <image-ref>}"
CID=""
TMP_DIR=""

cleanup() {
  if [ -n "$CID" ]; then
    docker rm -f "$CID" >/dev/null 2>&1 || true
  fi
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR" || true
  fi
}
trap cleanup EXIT

echo "==> [1/7] Verify zero Microsoft proprietary binaries exist in published image"
docker run --rm --entrypoint bash "$IMAGE" -c '
  set -euo pipefail
  test ! -e /opt/mssql
  test ! -e /opt/mssql-tools18
  test ! -e /opt/mssql-extensibility
  ! dpkg-query -W mssql-server 2>/dev/null
  ! dpkg-query -W mssql-server-fts 2>/dev/null
  test -f /usr/share/keyrings/microsoft-prod.gpg
  id mssql | grep -q "uid=10001"
'
echo "PASS: Zero proprietary Microsoft binaries baked into image."

echo "==> [2/7] Verify EULA refusal negative check"
EULA_OUT="$(docker run --rm "$IMAGE" 2>&1 || true)"
printf '%s\n' "$EULA_OUT" | grep -qi "EULA" || { echo "FAIL: missing EULA refusal message" >&2; exit 1; }
echo "PASS: Container refuses to download or start without ACCEPT_EULA=Y."

echo "==> [3/7] Start container with ACCEPT_EULA=Y and ephemeral random SA password"
TMP_DIR="$(mktemp -d)"
# Generate strong random password meeting SQL Server complexity (upper, lower, digit, symbol)
SA_PW="Aa1!$(openssl rand -hex 12)"

CID="$(docker run -d \
  --cap-drop ALL \
  --cap-add SETUID \
  --cap-add SETGID \
  --cap-add CHOWN \
  --cap-add FOWNER \
  --cap-add DAC_OVERRIDE \
  --cap-add SETFCAP \
  --cap-add SYS_PTRACE \
  --security-opt no-new-privileges:true \
  -e ACCEPT_EULA=Y \
  -e MSSQL_PID=Developer \
  -e MSSQL_SA_PASSWORD="$SA_PW" \
  -v "${TMP_DIR}:/var/opt/mssql" \
  "$IMAGE")"

echo "==> [4/7] Wait for runtime GPG-verified package install + SQL Server healthy (timeout 360s)"
HEALTH=""
for i in $(seq 1 72); do
  STATUS="$(docker inspect --format='{{.State.Status}}' "$CID")"
  if [ "$STATUS" != "running" ]; then
    echo "FAIL: container stopped unexpectedly (status=$STATUS)" >&2
    docker logs "$CID" | tail -n 80 >&2 || true
    exit 1
  fi
  HEALTH="$(docker inspect --format='{{.State.Health.Status}}' "$CID")"
  if [ "$HEALTH" = "healthy" ]; then
    echo "Container healthy after $((i * 5))s."
    break
  fi
  sleep 5
done

if [ "$HEALTH" != "healthy" ]; then
  echo "FAIL: container did not reach healthy state (last=$HEALTH)" >&2
  docker logs "$CID" | tail -n 100 >&2 || true
  exit 1
fi

echo "==> [5/7] Verify non-root mssql (UID 10001) execution and clean healthcheck"
PROCS="$(docker exec "$CID" ps -eo uid=,comm=)"
echo "Running processes:"
printf '%s\n' "$PROCS"
if printf '%s\n' "$PROCS" | awk '$2 ~ /sqlservr/ && $1 != 10001 { found=1 } END { exit !found }'; then
  echo "FAIL: sqlservr is not running as UID 10001!" >&2
  exit 1
fi
printf '%s\n' "$PROCS" | grep -q "sqlservr" || { echo "FAIL: sqlservr process not found" >&2; exit 1; }
docker exec "$CID" /usr/local/bin/mssql-fts-healthcheck
echo "PASS: sqlservr running as UID 10001 and healthcheck succeeded."

echo "==> [6/7] Verify Full-Text Search installed, catalog/index creation, and CONTAINS query"
docker exec -e SQLCMDPASSWORD="$SA_PW" "$CID" /opt/mssql-tools18/bin/sqlcmd \
  -S 127.0.0.1,1433 -U sa -C -b -h -1 \
  -Q "SET NOCOUNT ON; SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled');" \
  | tr -d '[:space:]' | grep -qx "1"
echo "PASS: FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') = 1."

docker exec -e SQLCMDPASSWORD="$SA_PW" "$CID" /opt/mssql-tools18/bin/sqlcmd \
  -S 127.0.0.1,1433 -U sa -C -b -Q "
CREATE DATABASE SmokeFTS;
GO
USE SmokeFTS;
GO
CREATE TABLE dbo.Articles (
    Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Articles PRIMARY KEY,
    Body NVARCHAR(400) NOT NULL
);
CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;
CREATE FULLTEXT INDEX ON dbo.Articles(Body LANGUAGE 1033)
    KEY INDEX PK_Articles
    WITH CHANGE_TRACKING AUTO;
INSERT INTO dbo.Articles (Body) VALUES
    (N'Hardened container wrapper with FullText search enabled'),
    (N'Unrelated sample record without matching keyword');
"

FOUND=""
for _ in $(seq 1 30); do
  FOUND="$(docker exec -e SQLCMDPASSWORD="$SA_PW" "$CID" /opt/mssql-tools18/bin/sqlcmd \
    -S 127.0.0.1,1433 -U sa -C -b -h -1 -d SmokeFTS \
    -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM dbo.Articles WHERE CONTAINS(Body, '\"FullText\"');" \
    | tr -d '[:space:]')"
  if [ "$FOUND" = "1" ]; then
    break
  fi
  sleep 2
done
test "$FOUND" = "1" || { echo "FAIL: Full-Text CONTAINS query returned '${FOUND}' instead of 1" >&2; exit 1; }
echo "PASS: Full-Text catalog, index population, and CONTAINS query verified."

echo "==> [7/7] Verify negative healthcheck on unreachable port"
if docker exec -e MSSQL_TCP_PORT=1499 "$CID" /usr/local/bin/mssql-fts-healthcheck >/dev/null 2>&1; then
  echo "FAIL: negative healthcheck unexpectedly succeeded!" >&2
  exit 1
fi
echo "PASS: Negative healthcheck failed cleanly on closed port."
echo "ALL SMOKE TESTS PASSED."
