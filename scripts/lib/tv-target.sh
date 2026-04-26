#!/usr/bin/env bash

repo_root_for_tv_target="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
tv_serial_file="$repo_root_for_tv_target/.tv-serial"

# shellcheck source=scripts/lib/local-env.sh
source "$repo_root_for_tv_target/scripts/lib/local-env.sh"
load_local_env

tv_serial() {
  if [[ -n "${TV_ADB_SERIAL:-}" ]]; then
    printf '%s\n' "$TV_ADB_SERIAL"
    return
  fi

  if [[ -f "$tv_serial_file" ]]; then
    local saved_serial
    saved_serial="$(sed -n '1p' "$tv_serial_file")"
    if [[ -n "$saved_serial" ]]; then
      printf '%s\n' "$saved_serial"
      return
    fi
  fi
}

require_tv_serial() {
  local serial
  serial="$(tv_serial)"
  if [[ -z "$serial" ]]; then
    cat >&2 <<'EOF'
error: TV target is not configured

Run:
  scripts/connect-tv

That discovers the Shield and writes ignored local config to .env and .tv-serial.
EOF
    return 69
  fi

  printf '%s\n' "$serial"
}
