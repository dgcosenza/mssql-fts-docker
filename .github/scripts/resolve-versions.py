#!/usr/bin/env python3
"""Resolve latest Microsoft SQL Server (2025/2022) + FTS + mssql-tools18 versions and Ubuntu LTS base digests."""
from __future__ import annotations

import gzip
import json
import os
import pathlib
import re
import urllib.request


def version_key(ver: str) -> list[int | str]:
    return [int(p) if p.isdigit() else p for p in re.split(r"([0-9]+)", ver)]


def latest_deb_version(packages_gz_url: str, pkg_name: str) -> str:
    req = urllib.request.Request(packages_gz_url, headers={"User-Agent": "dgcosenza-mssql-fts-ci"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        raw = gzip.decompress(resp.read()).decode("utf-8", errors="replace")
    versions: list[str] = []
    cur_pkg = ""
    for line in raw.splitlines():
        if not line.strip():
            cur_pkg = ""
        elif line.startswith("Package:"):
            cur_pkg = line.split(":", 1)[1].strip()
        elif line.startswith("Version:") and cur_pkg == pkg_name:
            versions.append(line.split(":", 1)[1].strip())
    if not versions:
        raise RuntimeError(f"Package '{pkg_name}' not found at {packages_gz_url}")
    versions.sort(key=version_key)
    return versions[-1]


def hub_digest(tag: str) -> str:
    req = urllib.request.Request(
        f"https://hub.docker.com/v2/repositories/library/ubuntu/tags/{tag}",
        headers={"User-Agent": "dgcosenza-mssql-fts-ci"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return (json.loads(resp.read().decode("utf-8")).get("digest") or "").strip()


def main() -> int:
    v2025_full = os.environ.get("OVERRIDE_2025", "").strip() or latest_deb_version(
        "https://packages.microsoft.com/ubuntu/24.04/mssql-server-2025/dists/noble/main/binary-amd64/Packages.gz",
        "mssql-server-fts",
    )
    v2022_full = os.environ.get("OVERRIDE_2022", "").strip() or latest_deb_version(
        "https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022/dists/jammy/main/binary-amd64/Packages.gz",
        "mssql-server-fts",
    )
    tools18_ver = latest_deb_version(
        "https://packages.microsoft.com/ubuntu/24.04/prod/dists/noble/main/binary-amd64/Packages.gz",
        "mssql-tools18",
    )

    v2025_short = v2025_full.split("-", 1)[0]
    v2022_short = v2022_full.split("-", 1)[0]

    dig_2404 = hub_digest("24.04")
    dig_2204 = hub_digest("22.04")
    base_2404 = f"ubuntu:24.04@{dig_2404}" if dig_2404 else "ubuntu:24.04"
    base_2204 = f"ubuntu:22.04@{dig_2204}" if dig_2204 else "ubuntu:22.04"

    prev: dict = {}
    vpath = pathlib.Path("versions.json")
    if vpath.exists():
        try:
            prev = json.loads(vpath.read_text(encoding="utf-8"))
        except Exception:
            prev = {}
    prev_ver = prev.get("upstream_version", "none")
    changed = "yes" if prev_ver != v2025_short else "no"

    changes = [
        "# Upstream Changes",
        "",
        f"- **SQL Server 2025 + FTS (runtime-fetched):** `{prev_ver}` -> `{v2025_short}` (APT package `{v2025_full}`, Ubuntu 24.04 LTS)",
        f"- **SQL Server 2022 + FTS (runtime-fetched):** `{v2022_short}` (APT package `{v2022_full}`, Ubuntu 22.04 LTS)",
        f"- **mssql-tools18 (runtime-fetched):** `{tools18_ver}`",
        f"- **Primary track version changed:** `{changed}`",
        "- **Proprietary binaries in published image:** `None (0)` — packages are downloaded and GPG-verified at container startup after `ACCEPT_EULA=Y`.",
    ]
    pathlib.Path("upstream-changes.md").write_text("\n".join(changes) + "\n", encoding="utf-8")

    outputs = {
        "mssql_2025_full": v2025_full,
        "mssql_2025_short": v2025_short,
        "mssql_2022_full": v2022_full,
        "mssql_2022_short": v2022_short,
        "mssql_tools18_version": tools18_ver,
        "ubuntu_2404_base": base_2404,
        "ubuntu_2404_digest": dig_2404,
        "ubuntu_2204_base": base_2204,
        "ubuntu_2204_digest": dig_2204,
    }
    gh_out = os.environ.get("GITHUB_OUTPUT")
    if gh_out:
        with open(gh_out, "a", encoding="utf-8") as fh:
            for k, v in outputs.items():
                fh.write(f"{k}={v}\n")
    for k, v in outputs.items():
        print(f"{k}={v}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
