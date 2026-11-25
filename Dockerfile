# syntax=docker/dockerfile:1

ARG UBUNTU_BASE=ubuntu:24.04@sha256:562111b88caa79c71391c0c4d3c2114a7d5c35915c20561fd893cb1e07929e6b
FROM ${UBUNTU_BASE} AS runtime

ARG UBUNTU_VERSION=24.04
ARG UBUNTU_CODENAME=noble
ARG MSSQL_MAJOR=2025
ARG MSSQL_TESTED_VERSION=17.0.5065.9-3
ARG IMAGE_CREATED=""
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/mssql-fts-docker"

LABEL org.opencontainers.image.title="Microsoft SQL Server + Full-Text Search Runtime Wrapper (Ubuntu ${UBUNTU_VERSION})" \
      org.opencontainers.image.description="License-compliant zero-binary Ubuntu ${UBUNTU_VERSION} LTS runtime wrapper for Microsoft SQL Server ${MSSQL_MAJOR} Database Engine with Full-Text Search (no Microsoft binaries bundled)." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/mssql-fts" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${MSSQL_TESTED_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      io.github.dgcosenza.mssql-fts.mssql_major="${MSSQL_MAJOR}" \
      io.github.dgcosenza.mssql-fts.ubuntu_version="${UBUNTU_VERSION}" \
      io.github.dgcosenza.mssql-fts.tested_version="${MSSQL_TESTED_VERSION}" \
      io.github.dgcosenza.mssql-fts.proprietary_binaries="none"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade Ubuntu LTS base and install minimal open-source wrapper dependencies only.
# Zero Microsoft proprietary binaries are installed at image build time.
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      tini \
      tzdata \
      util-linux; \
    curl -fsSLo /tmp/microsoft.asc https://packages.microsoft.com/keys/microsoft.asc; \
    FPR="$(gpg --show-keys --with-colons /tmp/microsoft.asc | awk -F: '$1 == "fpr" { print $10; exit }')"; \
    test "${FPR}" = "BC528686B50D79E339D3721CEB3E94ADBE1229CF"; \
    gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg /tmp/microsoft.asc; \
    chmod 0644 /usr/share/keyrings/microsoft-prod.gpg; \
    rm -f /tmp/microsoft.asc; \
    printf 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/%s/mssql-server-%s %s main\n' \
      "${UBUNTU_VERSION}" "${MSSQL_MAJOR}" "${UBUNTU_CODENAME}" \
      > "/etc/apt/sources.list.d/mssql-server-${MSSQL_MAJOR}.list"; \
    printf 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/%s/prod %s main\n' \
      "${UBUNTU_VERSION}" "${UBUNTU_CODENAME}" \
      > /etc/apt/sources.list.d/microsoft-prod.list; \
    useradd --system --uid 10001 --gid 0 --home-dir /var/opt/mssql --shell /bin/bash mssql; \
    install -d -o 10001 -g 0 -m 0770 /var/opt/mssql /var/opt/mssql/data /var/opt/mssql/log /var/opt/mssql/secrets; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 scripts/mssql-fts-entrypoint.sh /usr/local/bin/mssql-fts-entrypoint
COPY --chmod=0755 scripts/mssql-fts-healthcheck.sh /usr/local/bin/mssql-fts-healthcheck

ENV PATH="/opt/mssql/bin:/opt/mssql-tools18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    MSSQL_MAJOR="${MSSQL_MAJOR}" \
    MSSQL_PID="Developer" \
    MSSQL_TCP_PORT="1433" \
    MSSQL_RPC_PORT="135" \
    MSSQL_FTS_CACHE="true" \
    ACCEPT_EULA="" \
    TZ="UTC"

EXPOSE 1433
VOLUME ["/var/opt/mssql"]
WORKDIR /var/opt/mssql
STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/mssql-fts-entrypoint"]
HEALTHCHECK --start-period=4m --interval=30s --timeout=10s --retries=5 CMD ["/usr/local/bin/mssql-fts-healthcheck"]
