# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Maintained by **Daniel G. Cosenza from FNX Labs**.

## [Unreleased]

<!-- changelog:auto -->

## [17.0.5065.9] — 2026-11-26

### Automated Daily Build
- Verified components: 2025 Track Base OS `Ubuntu 24.04 (noble)`, 2025 Track Tested CU (runtime-fetched) `17.0.5065.9-3`, 2022 Track Base OS `Ubuntu 22.04 (jammy)`, 2022 Track Tested CU (runtime-fetched) `16.0.4325.4-2`, Client Tools (runtime-fetched) `mssql-tools18 18.7.1.1-1`, Proprietary Binaries in Published Image `None (0)`.
- Upstream status:
  - **SQL Server 2025 + FTS (runtime-fetched):** `17.0.5065.9` -> `17.0.5065.9` (APT package `17.0.5065.9-3`, Ubuntu 24.04 LTS)
  - **SQL Server 2022 + FTS (runtime-fetched):** `16.0.4325.4` (APT package `16.0.4325.4-2`, Ubuntu 22.04 LTS)
  - **mssql-tools18 (runtime-fetched):** `18.7.1.1-1`
  - **Primary track version changed:** `no`
  - **Proprietary binaries in published image:** `None (0)` — packages are downloaded and GPG-verified at container startup after `ACCEPT_EULA=Y`.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (0 upstream-unfixed).
- Published 2025/latest digest (Docker Hub + GHCR): `dgcosenza/mssql-fts@sha256:ec5f915672b985fb74cf88a46f26084dbfd39d0e99c515bac65c4c47585d2211` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
- Published 2022-latest digest (Docker Hub + GHCR): `dgcosenza/mssql-fts@sha256:a33d7ac7f5cf47c2e2f3b2cdc06eaa8b987ac07c4318bff3a5fb30528ab67636`.
---

## [17.0.5065.9] — 2026-11-25

### Automated Daily Build
- Verified components: 2025 Track Base OS `Ubuntu 24.04 (noble)`, 2025 Track Tested CU (runtime-fetched) `17.0.5065.9-3`, 2022 Track Base OS `Ubuntu 22.04 (jammy)`, 2022 Track Tested CU (runtime-fetched) `16.0.4325.4-2`, Client Tools (runtime-fetched) `mssql-tools18 18.7.1.1-1`, Proprietary Binaries in Published Image `None (0)`.
- Upstream status:
  - **SQL Server 2025 + FTS (runtime-fetched):** `17.0.5065.9` -> `17.0.5065.9` (APT package `17.0.5065.9-3`, Ubuntu 24.04 LTS)
  - **SQL Server 2022 + FTS (runtime-fetched):** `16.0.4325.4` (APT package `16.0.4325.4-2`, Ubuntu 22.04 LTS)
  - **mssql-tools18 (runtime-fetched):** `18.7.1.1-1`
  - **Primary track version changed:** `no`
  - **Proprietary binaries in published image:** `None (0)` — packages are downloaded and GPG-verified at container startup after `ACCEPT_EULA=Y`.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (0 upstream-unfixed).
- Published 2025/latest digest (Docker Hub + GHCR): `dgcosenza/mssql-fts@sha256:3023a6d85e476fbf5aebeebe741680c06f7c4d5d08610b7f2e2b216d05a210b9` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
- Published 2022-latest digest (Docker Hub + GHCR): `dgcosenza/mssql-fts@sha256:612386ade6dedcca5e438b7dbddcda1f56f151c8a0d3713886066a76bb622df6`.
---

---

## [17.0.5065.9] — 2026-11-25

### Changed (Breaking)
- **Transitioned to license-compliant zero-binary runtime-installer wrapper:** Microsoft Software License Terms prohibit third-party public redistribution of proprietary SQL Server binaries. Published images now ship **zero Microsoft binaries**; after the user explicitly sets `ACCEPT_EULA=Y`, the entrypoint fetches GPG-verified `mssql-server`, `mssql-server-fts`, and `mssql-tools18` directly from `packages.microsoft.com` (with optional `.deb` caching under `/var/opt/mssql/.apt-cache`).
- **Upgraded `latest` from SQL Server 2019 (EOL Ubuntu 20.04) to SQL Server 2025 (`2025-latest`, Ubuntu 24.04 LTS):** Microsoft only ever shipped SQL Server 2019 for Ubuntu 20.04 (`focal`), which reached standard EOL in May 2025. Added supported `2025-latest` (`17.0.x`, Ubuntu 24.04 LTS) and `2022-latest` (`16.0.x`, Ubuntu 22.04 LTS) tracks. Historical `15.0.4510.2-20261121` and `15.0.4375.4-20240716` tags remain untouched on Docker Hub for legacy rollback.
- **Corrected Docker Hub description and README:** Clarified that this image runs Microsoft SQL Server **Database Engine** with Full-Text Search (not SQL Server Management Studio / SSMS) and replaced insecure hardcoded password examples with environment/secret-file references.

### Added
- Non-root `mssql` (`UID=10001`, `GID=0`) privilege drop via `setpriv` under `tini` PID 1.
- Built-in leak-free `sqlcmd` (`mssql-tools18`) healthcheck passing credentials exclusively via `SQLCMDPASSWORD` environment variable, plus `MSSQL_SA_PASSWORD_FILE` Docker secret support.
- Automated 7-step daily CI pipeline with Hadolint, Gitleaks, Dive efficiency gate, live Full-Text Search `CONTAINS` smoke tests on both 2025 and 2022 tracks, Syft SPDX/CycloneDX SBOMs, Trivy + Grype hard gates (0 fixable Critical/High), dual-registry publishing (GHCR + Docker Hub), Cosign keyless OIDC signing/attestations, SLSA Build L3 provenance, and signed GitHub Releases.

### Security
- Eliminated EOL Ubuntu 20.04 base OS and removed bundled proprietary binaries from public registry layers; verified 0 fixable Critical/High vulnerabilities in Trivy and Grype.
