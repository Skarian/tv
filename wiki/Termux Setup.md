# Termux Setup

This repo is portable Bash plus a small set of command-line tools. The maintained setup path assumes a Dispatch-created assistant workspace in Termux on Android, with the phone on the same network as the TV and Sonos.

## Dispatch Dependency Manifest

Dispatch owns Termux package install/uninstall for assistant workspaces. This repo declares its package needs in:

```text
.dispatch/termux-dependencies.json
```

Dispatch reads that manifest when the assistant is created, installs only missing packages, and tracks package ownership in its backend ledger outside the repo. Pre-existing packages are not removed when the assistant is deleted.

Current manifest packages:

- `android-tools`: provides `adb` for controlling the NVIDIA Shield.
- `imagemagick`: provides `magick` for Stremio screenshot debugging.
- `jq`: parses Cinemeta JSON.
- `netcat-openbsd`: provides `nc` for TCP discovery probes.
- `perl`: provides millisecond timing helpers.
- `python-yt-dlp`: provides `yt-dlp` for YouTube discovery.
- `ripgrep`: provides `rg` for fast repo search.
- `shellcheck`: shell script linting.

The repo intentionally does not declare baseline Termux tools such as `bash`, `curl`, or `ca-certificates`.

## Manual Fallback Scripts

`scripts/install-termux` and `scripts/uninstall-termux` are fallback helpers for running the repo outside Dispatch. They are not the package ownership mechanism for Dispatch-created assistants.

Manual install preview:

```sh
bash scripts/install-termux --dry-run
```

Manual install:

```sh
bash scripts/install-termux
```

Manual uninstall preview:

```sh
bash scripts/uninstall-termux --dry-run
```

Manual uninstall:

```sh
bash scripts/uninstall-termux
```

The manual installer records only packages it installed in ignored local state at `.agent/state/termux-installed-packages`. The manual uninstall script removes only packages in that record and does not run `autoremove`.

Packages are installed one at a time so Termux/dpkg failures identify the exact package that failed. The `apt` stable-CLI warning from Termux is harmless; the important failure line is the named package printed immediately before the error.

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
