# Third-Party Notices

This container image packaging repository is maintained by **Daniel G. Cosenza from FNX Labs** under the MIT License (see `LICENSE`).

## Published Container Image Contents

The published container image contains **only** open-source base operating system components and MIT-licensed wrapper scripts — **zero proprietary Microsoft binaries are bundled or redistributed**:

1. **Ubuntu LTS Base System & Packages** (`ubuntu:24.04` for SQL Server 2025 track; `ubuntu:22.04` for SQL Server 2022 track; packages: `ca-certificates`, `curl`, `gnupg`, `tini`, `tzdata`, `util-linux`)
   - Upstream: https://ubuntu.com/
   - Licenses: Respective free and open-source licenses documented in `/usr/share/doc/*/copyright` inside the image.

2. **Microsoft APT Repository Signing Key (`microsoft-prod.gpg`)**
   - Public OpenPGP key fingerprint `BC528686B50D79E339D3721CEB3E94ADBE1229CF` published by Microsoft Corporation at `https://packages.microsoft.com/keys/microsoft.asc` solely for cryptographic verification of end-user APT downloads.

## Runtime-Fetched Upstream Software (NOT Bundled)

When an end user explicitly sets `ACCEPT_EULA=Y`, the container downloads and installs the following proprietary Microsoft packages directly from `https://packages.microsoft.com`:

- **Microsoft SQL Server Database Engine (`mssql-server`)**, **SQL Server Full-Text Search (`mssql-server-fts`)**, **Microsoft ODBC Driver 18 (`msodbcsql18`)**, and **SQL Server Command-Line Tools (`mssql-tools18`)**
  - Vendor: Microsoft Corporation
  - License: Proprietary — governed by the [Microsoft Software License Terms and Microsoft Product Terms](https://www.microsoft.com/licensing/product-terms).
