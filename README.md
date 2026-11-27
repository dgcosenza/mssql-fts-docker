# Microsoft SQL Server + Full-Text Search Runtime Wrapper (Ubuntu LTS)

[![Daily MSSQL-FTS wrapper image](https://github.com/dgcosenza/mssql-fts-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/mssql-fts-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/mssql-fts-docker/blob/main/LICENSE)
[![Upstream License: Proprietary (runtime-fetched)](https://img.shields.io/badge/upstream-Proprietary--EULA-orange.svg)](https://www.microsoft.com/licensing/product-terms)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architecture](https://img.shields.io/badge/arch-amd64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/mssql-fts-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/mssql-fts-docker)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/17163/badge)](https://www.bestpractices.dev/projects/17163)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/mssql-fts)](https://hub.docker.com/r/dgcosenza/mssql-fts)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/mssql-fts/latest)](https://hub.docker.com/r/dgcosenza/mssql-fts)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/mssql-fts-docker?label=version)](https://github.com/dgcosenza/mssql-fts-docker/releases)

A hardened, license-compliant **Ubuntu LTS zero-binary runtime-installer wrapper** for **Microsoft SQL Server Database Engine (2025 & 2022) with Full-Text Search (`mssql-server-fts`)** and `mssql-tools18`, featuring `tini` PID 1, GPG-verified startup installation directly from `packages.microsoft.com`, non-root execution (`mssql`, UID `10001`, GID `0`), and a leak-free `sqlcmd` healthcheck — maintained by **Daniel G. Cosenza from FNX Labs**.

*(Note: This image runs the **Microsoft SQL Server Database Engine** with Full-Text Search enabled, not SQL Server Management Studio / SSMS.)*

- **Docker Hub:** [`dgcosenza/mssql-fts`](https://hub.docker.com/r/dgcosenza/mssql-fts)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/mssql-fts`](https://github.com/dgcosenza/mssql-fts-docker/pkgs/container/mssql-fts) (identical signed digest per track)
- **Source Repository:** [`dgcosenza/mssql-fts-docker`](https://github.com/dgcosenza/mssql-fts-docker)
- **Upstream Software:** [Microsoft SQL Server on Linux](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-overview) (`Proprietary` — fetched directly by end users from `packages.microsoft.com` after accepting the EULA, **not** bundled)

> **Licensing & Redistribution Notice:** Microsoft Software License Terms for SQL Server prohibit third-party public redistribution of proprietary SQL Server binaries ("You may not publish the software for others to copy"). **This published image contains zero Microsoft proprietary binaries** (strictly asserted in CI on every build). At container startup, only after the user explicitly sets `ACCEPT_EULA=Y`, the entrypoint verifies Microsoft's pinned GPG signing key (`BC528686B50D79E339D3721CEB3E94ADBE1229CF`), fetches official `mssql-server`, `mssql-server-fts`, and `mssql-tools18` packages directly from `https://packages.microsoft.com`, caches the verified `.deb` files under `/var/opt/mssql/.apt-cache`, drops privileges via `setpriv` to `mssql` (`10001:0`), and launches `/opt/mssql/bin/sqlservr`.

> **Breaking Change Notice (SQL Server 2019 -> 2025 / 2022):** Earlier builds of `dgcosenza/mssql-fts:latest` bundled SQL Server 2019 (`15.0.x`) on Ubuntu 20.04 (`focal`). Ubuntu 20.04 reached standard EOL in May 2025 and Microsoft never published SQL Server 2019 repositories for Ubuntu 22.04 or 24.04. Starting `2026-11-25`, `latest` tracks **SQL Server 2025 (`2025-latest`, Ubuntu 24.04 LTS)** and a separate **`2022-latest` (`16.0.x`, Ubuntu 22.04 LTS)** track is also maintained daily. Historical `15.0.4510.2-20261121` and `15.0.4375.4-20240716` tags remain preserved on Docker Hub for legacy rollback.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| 2025 Track Base OS | `Ubuntu 24.04 (noble)` |
| 2025 Track Tested CU (runtime-fetched) | `17.0.5065.9-3` |
| 2022 Track Base OS | `Ubuntu 22.04 (jammy)` |
| 2022 Track Tested CU (runtime-fetched) | `16.0.4325.4-2` |
| Client Tools (runtime-fetched) | `mssql-tools18 18.7.1.1-1` |
| Proprietary Binaries in Published Image | `None (0)` |
| Architectures | `linux/amd64` |
| Uncompressed size (per track) | `2025: 37.8 MB, 2022: 37.9 MB` |
| Last verified build (UTC) | `2026-11-27` |
| Published digest (`latest` / `2025-latest`) | `dgcosenza/mssql-fts@sha256:dd0d7141162fb847a2e53f999fe85ac53dd7da8376593606efac9d5da2996afd` |
| GHCR mirror (`latest` / `2025-latest`) | `ghcr.io/dgcosenza/mssql-fts@sha256:dd0d7141162fb847a2e53f999fe85ac53dd7da8376593606efac9d5da2996afd` |
| Published digest (`2022-latest`) | `dgcosenza/mssql-fts@sha256:50f58726166e2457d21b918be057ad5e930edc3dce7fd5f9609bbd2100324630` |
| GHCR mirror (`2022-latest`) | `ghcr.io/dgcosenza/mssql-fts@sha256:50f58726166e2457d21b918be057ad5e930edc3dce7fd5f9609bbd2100324630` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (0 upstream-unfixed) |

**Recent upstream status:**
- **SQL Server 2025 + FTS (runtime-fetched):** `17.0.5065.9` -> `17.0.5065.9` (APT package `17.0.5065.9-3`, Ubuntu 24.04 LTS)
- **SQL Server 2022 + FTS (runtime-fetched):** `16.0.4325.4` (APT package `16.0.4325.4-2`, Ubuntu 22.04 LTS)
- **mssql-tools18 (runtime-fetched):** `18.7.1.1-1`
- **Primary track version changed:** `no`
- **Proprietary binaries in published image:** `None (0)` — packages are downloaded and GPG-verified at container startup after `ACCEPT_EULA=Y`.
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical signed OCI digests are published to **Docker Hub** (`dgcosenza/mssql-fts`) and **GHCR** (`ghcr.io/dgcosenza/mssql-fts`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/mssql-fts-docker/releases):

| Tag | Track / Base OS | Policy | Description |
| --- | --- | --- | --- |
| `latest`, `2025-latest`, `2025` | SQL Server 2025 / Ubuntu 24.04 LTS | Moving | Latest verified daily zero-binary wrapper for SQL Server 2025 + FTS. |
| `17.0.x` (e.g. `17.0.5065.9`) | SQL Server 2025 / Ubuntu 24.04 LTS | Moving | Latest verified build smoke-tested against that SQL Server 2025 CU. |
| `17.0.x-<YYYYMMDD>` | SQL Server 2025 / Ubuntu 24.04 LTS | **Immutable** | Date-stamped daily wrapper build for SQL Server 2025. |
| `sha-<short>` | SQL Server 2025 / Ubuntu 24.04 LTS | **Immutable** | Packaging repository Git commit tag. |
| `2022-latest`, `2022` | SQL Server 2022 / Ubuntu 22.04 LTS | Moving | Latest verified daily zero-binary wrapper for SQL Server 2022 + FTS. |
| `16.0.x` (e.g. `16.0.4325.4`) | SQL Server 2022 / Ubuntu 22.04 LTS | Moving | Latest verified build smoke-tested against that SQL Server 2022 CU. |
| `16.0.x-<YYYYMMDD>` | SQL Server 2022 / Ubuntu 22.04 LTS | **Immutable** | Date-stamped daily wrapper build for SQL Server 2022. |
| `15.0.4510.2-20261121`, `15.0.4375.4-20240716` | Legacy SQL Server 2019 / EOL Ubuntu 20.04 | **Frozen / Deprecated** | Preserved historical tags only; no longer updated. |

**Production pinning:** Pin by immutable registry digest rather than a moving tag:

```yaml
image: dgcosenza/mssql-fts:2025-latest@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/mssql-fts:2025-latest@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Reason |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, verified zero proprietary binaries, end-to-end smoke-tested with live `packages.microsoft.com` installation + Full-Text Search `CONTAINS` query, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed. |
| `linux/arm64` | **Not supported upstream** | Microsoft does not publish Linux `arm64` packages for `mssql-server` or `mssql-server-fts` (`packages.microsoft.com` `binary-arm64` indexes are empty). |

---

## Quick Start

### SA Password Complexity Rules

Microsoft SQL Server enforces strict password complexity for the `sa` account. Your `MSSQL_SA_PASSWORD` **must** be at least **8 characters long** and include characters from at least **three** of the following four categories:

- Uppercase letters (`A–Z`)
- Lowercase letters (`a–z`)
- Base-10 digits (`0–9`)
- Non-alphanumeric symbols (e.g. `!`, `@`, `#`, `$`, `%`)

Never hardcode weak passwords in compose files or shell history. Load `MSSQL_SA_PASSWORD` from a protected `.env` file (`chmod 600`) or mount a Docker secret via `MSSQL_SA_PASSWORD_FILE`.

### Docker CLI

```bash
export MSSQL_SA_PASSWORD='<strong-password-from-secret-store>'
docker run -d --name mssql-fts \
  --cap-drop ALL \
  --cap-add SETUID --cap-add SETGID --cap-add CHOWN \
  --cap-add FOWNER --cap-add DAC_OVERRIDE --cap-add SETFCAP --cap-add SYS_PTRACE \
  --security-opt no-new-privileges:true \
  -p 127.0.0.1:1433:1433 \
  -e ACCEPT_EULA=Y \
  -e MSSQL_PID=Developer \
  -e MSSQL_SA_PASSWORD \
  -v mssql_data:/var/opt/mssql \
  dgcosenza/mssql-fts:latest
```

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/mssql-fts-docker/blob/main/docker-compose.example.yml):

```yaml
services:
  mssql-fts:
    image: dgcosenza/mssql-fts:latest
    container_name: mssql-fts
    restart: unless-stopped
    cap_drop:
      - ALL
    cap_add:
      - SETUID
      - SETGID
      - CHOWN
      - FOWNER
      - DAC_OVERRIDE
      - SETFCAP
      - SYS_PTRACE
    security_opt:
      - no-new-privileges:true
    ports:
      - "127.0.0.1:1433:1433"
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_PID: "Developer"
      MSSQL_SA_PASSWORD: "${MSSQL_SA_PASSWORD}"
      MSSQL_FTS_CACHE: "true"
      TZ: "UTC"
    volumes:
      - mssql_data:/var/opt/mssql
    healthcheck:
      test: ["CMD", "/usr/local/bin/mssql-fts-healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 4m

volumes:
  mssql_data:
```

### Verify Full-Text Search

```bash
docker exec -e SQLCMDPASSWORD="${MSSQL_SA_PASSWORD}" mssql-fts \
  /opt/mssql-tools18/bin/sqlcmd -S 127.0.0.1,1433 -U sa -C \
  -Q "SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS IsFullTextInstalled;"
```

Expected output: `1`.

---

## Configuration

### Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `ACCEPT_EULA` | Must be `Y` to accept the Microsoft SQL Server EULA and permit runtime package retrieval | `""` (required) |
| `MSSQL_SA_PASSWORD` | Strong `sa` login password (never commit or use trivial strings) | — (required unless `MSSQL_SA_PASSWORD_FILE` is set) |
| `MSSQL_SA_PASSWORD_FILE` | Path to a mounted secret file containing the `sa` password | — |
| `MSSQL_PID` | SQL Server edition (`Developer`, `Express`, `Evaluation`, `Standard`, `Enterprise`, or product key) | `Developer` |
| `MSSQL_TCP_PORT` | TCP port SQL Server listens on | `1433` |
| `MSSQL_RPC_PORT` | RPC endpoint mapper port | `135` |
| `MSSQL_MEMORY_LIMIT_MB` | Optional SQL Server memory cap in MB (SQL Server requires >= 2048 MB host/container memory) | Upstream default |
| `MSSQL_COLLATION` | Optional server-level collation | Upstream default |
| `MSSQL_AGENT_ENABLED` | Enable SQL Server Agent (`true`/`false`) | `false` |
| `MSSQL_PACKAGE_VERSION` | Optional exact APT version pin for `mssql-server` & `mssql-server-fts` (e.g. `17.0.5065.9-3`) | Latest CU in track |
| `MSSQL_FTS_CACHE` | Cache downloaded GPG-verified `.deb` packages under `/var/opt/mssql/.apt-cache` (`true`/`false`) | `true` |
| `TZ` | Container timezone | `UTC` |

### Volumes, Ports, and Privileges

| Path / Port | Purpose |
| --- | --- |
| `/var/opt/mssql` | Persistent SQL Server databases, logs, secrets, and optional `.apt-cache` (owned by `10001:0`) |
| `1433/tcp` | SQL Server TDS client port (bind to `127.0.0.1` or an internal network; never expose directly to the public internet) |

The entrypoint runs briefly as `root` on first start solely to install GPG-verified `mssql-server`, `mssql-server-fts`, and `mssql-tools18` packages and normalize `/var/opt/mssql` ownership to `10001:0`, then drops privileges via `setpriv` to non-root **`mssql` (`UID=10001`, `GID=0`)** before `exec`ing `/opt/mssql/bin/sqlservr` under `tini`.

---

## Healthcheck

```bash
/usr/local/bin/mssql-fts-healthcheck
```

Runs `/opt/mssql-tools18/bin/sqlcmd -S 127.0.0.1,${MSSQL_TCP_PORT} -U sa -C -l 5 -t 5 -b -h -1 -Q "SET NOCOUNT ON; SELECT 1"`. The SA password is read at runtime from `MSSQL_SA_PASSWORD` (or `MSSQL_SA_PASSWORD_FILE`) and exported solely via `SQLCMDPASSWORD` so credentials never appear in `ps` / `/proc` arguments.

---

## Upgrade and Migration from SQL Server 2019 (`15.0.x`)

1. Take a full native SQL Server backup (`.bak`) of every user database before upgrading major versions. Database format upgrades (2019 -> 2022 or 2025) are one-way.
2. Ensure the container has outbound HTTPS access to `packages.microsoft.com` and Ubuntu archive mirrors on initial startup so GPG-verified packages can be installed and cached in `/var/opt/mssql/.apt-cache`.
3. Choose `dgcosenza/mssql-fts:2022-latest` (SQL Server 2022 on Ubuntu 22.04 LTS) or `dgcosenza/mssql-fts:2025-latest` / `latest` (SQL Server 2025 on Ubuntu 24.04 LTS).
4. Replace any legacy `SA_PASSWORD` with `MSSQL_SA_PASSWORD` (or `MSSQL_SA_PASSWORD_FILE`) sourced from a secure secret store.

---

## Supply-Chain Verification

Every published digest on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/mssql-fts-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/mssql-fts:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/mssql-fts-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/mssql-fts:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/mssql-fts-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/mssql-fts@sha256:<digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/mssql-fts:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and pull request runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across full git history, and **public-content/attribution** checks.
- **Vulnerability scan policy (all severities with a fix):** Every daily build generates **SPDX** and **CycloneDX** SBOMs with **Syft**, scans with **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** scanning the SPDX SBOM (`--only-fixed --fail-on negligible`), and enforces a **Dive** efficiency gate (`>= 95%`).
- **Cryptographic package verification:** Microsoft's public APT signing key is verified at image build time against exact GPG fingerprint `BC528686B50D79E339D3721CEB3E94ADBE1229CF`, and `apt-get` enforces signed `Release` verification at runtime.
- **Upstream runtime note:** Because SQL Server packages are fetched directly from `packages.microsoft.com` at runtime, any vulnerabilities inside Microsoft's closed-source SQL Server binaries (such as Go runtime CVEs inside Microsoft's `launchpadd`/`setnetbr` helpers) are patched automatically as soon as Microsoft publishes updated Cumulative Updates (CUs).
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/mssql-fts-docker/blob/main/SECURITY.md) for responsible disclosure.

---

## Build Locally

```bash
# SQL Server 2025 track (Ubuntu 24.04 LTS, default)
docker buildx build --platform linux/amd64 --load -t dgcosenza/mssql-fts:2025-local .

# SQL Server 2022 track (Ubuntu 22.04 LTS)
docker buildx build --platform linux/amd64 --load \
  --build-arg UBUNTU_BASE=ubuntu:22.04 \
  --build-arg UBUNTU_VERSION=22.04 \
  --build-arg UBUNTU_CODENAME=jammy \
  --build-arg MSSQL_MAJOR=2022 \
  -t dgcosenza/mssql-fts:2022-local .
```

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/mssql-fts-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:39 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; queries `https://packages.microsoft.com` APT metadata for the latest `mssql-server`, `mssql-server-fts`, and `mssql-tools18` CUs across both SQL Server 2025 (`noble`) and SQL Server 2022 (`jammy`) tracks plus the latest `ubuntu:24.04` and `ubuntu:22.04` base digests, emitting `upstream-changes.md`.
2. **No-cache daily rebuild:** Rebuilds both tracks (`2025` and `2022`) on `linux/amd64` with `--no-cache` on schedule and `apt-get -y upgrade`.
3. **Vulnerability fix & hard gate:** Generates **Syft** SPDX + CycloneDX SBOMs per track, computes CVE diffs against `versions.json`, uploads **Trivy** SARIF, and blocks publication on any fixable finding of any severity in **Trivy** or **Grype** (scanning the SPDX SBOM), alongside the **Dive** efficiency gate.
4. **End-to-end live FTS smoke test:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/mssql-fts-docker/blob/main/tests/smoke.sh) on both tracks: verifies zero baked Microsoft binaries, EULA refusal without `ACCEPT_EULA=Y`, live GPG-verified installation from `packages.microsoft.com` with an ephemeral random SA password, non-root `mssql` (`10001`) execution, `mssql-fts-healthcheck`, `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') = 1`, Full-Text Catalog & Index creation + `CONTAINS` query, and negative healthcheck failure.
5. **Dual-registry publish & signing:** Publishes identical OCI digests for both `2025` (`latest`, `2025-latest`, `2025`, `<cu>`, `<cu>-<YYYYMMDD>`, `sha-<short>`) and `2022` (`2022-latest`, `2022`, `<cu>`, `<cu>-<YYYYMMDD>`) to **GHCR** and **Docker Hub**; signs every digest and attaches SPDX/CycloneDX SBOM attestations via **Cosign** keyless OIDC; emits **SLSA Build L3** provenance; and publishes a signed **GitHub Release** with checksums and SBOMs.
6. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` (`[skip ci]`, validated by `public-check.sh`), then syncs the Docker Hub short description and full README overview.
7. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and auto-closes it on the next green run.

---

## Design Decisions

- **Zero-binary runtime-installer wrapper (license compliance):** Microsoft Software License Terms do not permit public third-party redistribution of SQL Server binaries. Keeping the published container image strictly open-source Ubuntu LTS + MIT scripts guarantees full license compliance while letting end users accept `ACCEPT_EULA=Y` and install GPG-verified official Microsoft packages automatically at startup.
- **Ubuntu 24.04 LTS / 22.04 LTS base instead of Debian 13:** Microsoft officially publishes and supports `mssql-server` and `mssql-server-fts` APT repositories only on Ubuntu LTS (not Debian). Using Ubuntu 24.04 LTS (for SQL Server 2025) and Ubuntu 22.04 LTS (for SQL Server 2022) follows Microsoft's official support matrix.
- **`linux/amd64` only:** Microsoft does not publish ARM64 Linux packages for SQL Server Database Engine or Full-Text Search.
- **Dropping SQL Server 2019 (`15.0.x`) from daily builds:** Microsoft never published SQL Server 2019 repositories for Ubuntu 22.04 or 24.04, and Ubuntu 20.04 reached standard EOL in May 2025. Historical `15.0.x` tags remain untouched on Docker Hub while daily security rebuilds focus on supported SQL Server 2025 and 2022 LTS tracks.
- **Multi-stage squashed rootfs (`FROM scratch`):** Eliminates overwritten base-layer `apt-get upgrade` files (`libc6`, `dpkg` metadata), keeping image size minimal and achieving strict Dive efficiency (`>= 95%`, user wasted `<= 5%`).
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Ubuntu LTS security patches via `apt-get`.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, runtime wrapper scripts, healthcheck, CI workflows, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/mssql-fts-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Runtime-fetched upstream software — Microsoft SQL Server & Full-Text Search (`upstream: Proprietary-EULA`):** Proprietary software of Microsoft Corporation governed by the [Microsoft Software License Terms and Product Terms](https://www.microsoft.com/licensing/product-terms). **No Microsoft binaries are included or redistributed in this image**; end users explicitly accept the EULA (`ACCEPT_EULA=Y`) and download official GPG-verified packages directly from `packages.microsoft.com` at container startup.

Full third-party notices are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/mssql-fts-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/mssql-fts-docker/blob/main/CHANGELOG.md).

## Credits

- [Microsoft SQL Server on Linux](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-overview) (fetched directly by end users at runtime)
- [Ubuntu / Canonical](https://ubuntu.com/)

Maintained by **Daniel G. Cosenza from FNX Labs**.
