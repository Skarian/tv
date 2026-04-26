# Termux Setup

This repo is portable Bash plus a small set of command-line tools. The maintained setup path assumes a Codex agent running in Termux on Android, with the phone on the same network as the TV and Sonos.

## Install Dependencies

From the repo root:

```sh
bash scripts/install-termux
```

The setup script checks for managed commands first and installs only the missing
packages. It intentionally avoids reinstalling baseline Termux tools such as
`bash`, `curl`, and `ca-certificates`.

When it installs packages, it records only those package names in ignored local
state at `.agent/state/termux-installed-packages`. The uninstall script uses
that record so it does not remove tools the user already had before this repo.

The setup script does not install `ca-certificates` directly. Termux's OpenSSL
package depends on `ca-certificates`, and common HTTPS tooling such as `curl`
reaches it through Termux's own package dependency graph.

## Uninstall Dependencies

Preview removal of repo-managed Termux packages:

```sh
bash scripts/uninstall-termux
```

Actually remove them:

```sh
bash scripts/uninstall-termux --yes
```

The uninstall script removes only packages recorded as installed by this repo
and does not run `autoremove`, so package dependencies left behind by Termux
remain installed.

Use a preview first when checking an unfamiliar environment:

```sh
bash scripts/install-termux --dry-run
```

## Managed Dependencies

Installed only when the command is missing:

- `adb`: connects to and controls the NVIDIA Shield.
- `jq`: parses Cinemeta JSON.
- `nc`: probes TCP `5555` while rediscovering the Shield.
- `yt-dlp`: useful for structured YouTube search before launching a result.
- `shellcheck`: script linting.
- `ripgrep`: fast repo search.
- `perl`: millisecond timing for Stremio stream-switch helpers.
- `imagemagick`: `magick` command for Stremio screenshot debugging.

The script assumes base Termux already provides `bash`, `curl`, package
management, core shell utilities, and certificate handling.

Package names are mostly the same as the command names, with these
repo-relevant mappings:

- `adb` comes from `android-tools`.
- `nc` comes from `netcat-openbsd`.
- `yt-dlp` comes from `python-yt-dlp`.
- `rg` comes from `ripgrep`.
- `magick` comes from `imagemagick`.

After installation, the script verifies that managed commands are on `PATH`.
Missing managed commands fail the setup instead of producing a best-effort
warning.

## Local Discovery

Normal commands report what discovery command to run when local config is missing. For first setup, or after one of those errors, use:

```sh
scripts/connect-tv
scripts/connect-sonos
```

These write ignored local config to `.env` and `.tv-serial`. Verify with:

```sh
scripts/remote status
```

Then use dry-runs before touching the TV:

```sh
scripts/play-youtube --dry-run dQw4w9WgXcQ
scripts/play-stremio --dry-run --type movie tt0133093
```

## Related

- [[TV Control]]
- [[Agent Runbook]]
