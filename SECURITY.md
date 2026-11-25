# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily builds of the active tracks (`latest` / `2025-latest` on Ubuntu 24.04 LTS, and `2022-latest` on Ubuntu 22.04 LTS) receive daily security rebuilds. Immutable date-stamped tags (`<cu-version>-YYYYMMDD`) are frozen for reproducibility. Historical SQL Server 2019 (`15.0.x`) tags built on EOL Ubuntu 20.04 are no longer updated.

## Vulnerability Scanning & Gates

- **Preflight:** Hadolint (blocking on warning+), Gitleaks full-history secret scanning, and public-content/attribution checks run on every push and pull request.
- **Trivy** (OS + libraries): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on any fixable `CRITICAL` or `HIGH` finding.
- **Grype** (scanning Syft SPDX SBOM): **blocking hard gate** (`--only-fixed --fail-on high`); table report retained for 90 days.
- **SBOM & Provenance:** SPDX-JSON and CycloneDX-JSON SBOMs per track attached as Cosign keyless OIDC attestations alongside SLSA Build L3 provenance.
- **Runtime Integrity & Secret Hygiene:** Microsoft APT signing key is verified at build time against pinned GPG fingerprint `BC528686B50D79E339D3721CEB3E94ADBE1229CF`. The built-in healthcheck reads `MSSQL_SA_PASSWORD` (or `MSSQL_SA_PASSWORD_FILE`) at runtime and passes it exclusively via `SQLCMDPASSWORD` environment variable, never via process arguments.

## Reporting a Vulnerability

**Do not open a public issue** for security vulnerabilities.

Report privately through GitHub Security Advisories: open the repository's **Security** tab or submit a private advisory directly at [dgcosenza/mssql-fts-docker Security Advisories](https://github.com/dgcosenza/mssql-fts-docker/security/advisories/new).

For upstream Microsoft SQL Server vulnerabilities, follow the [Microsoft Security Response Center (MSRC)](https://msrc.microsoft.com/).
