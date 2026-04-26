#!/usr/bin/env bash

repo_root_for_local_env="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
local_env_file="$repo_root_for_local_env/.env"

load_local_env() {
  [[ -f "$local_env_file" ]] || return 0

  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" && "$line" != \#* ]] || continue
    [[ "$line" == *=* ]] || continue

    key="${line%%=*}"
    value="${line#*=}"

    case "$key" in
      TV_ADB_SERIAL|TV_SCAN_PREFIX|SONOS_HOST|SONOS_PORT|SONOS_VOLUME_STEP)
        if [[ -z "${!key:-}" ]]; then
          export "$key=$value"
        fi
        ;;
    esac
  done < "$local_env_file"
}

local_env_key_allowed() {
  case "$1" in
    TV_ADB_SERIAL|TV_SCAN_PREFIX|SONOS_HOST|SONOS_PORT|SONOS_VOLUME_STEP)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

set_local_env() {
  local key="$1"
  local value="$2"

  if ! local_env_key_allowed "$key"; then
    echo "error: unsupported local env key: $key" >&2
    return 64
  fi

  touch "$local_env_file"

  local temp_file found=0 line current_key
  temp_file="$(mktemp "${local_env_file}.tmp.XXXXXX")"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *=* ]]; then
      current_key="${line%%=*}"
      if [[ "$current_key" == "$key" ]]; then
        printf '%s=%s\n' "$key" "$value" >> "$temp_file"
        found=1
        continue
      fi
    fi
    printf '%s\n' "$line" >> "$temp_file"
  done < "$local_env_file"

  if (( ! found )); then
    printf '%s=%s\n' "$key" "$value" >> "$temp_file"
  fi

  mv "$temp_file" "$local_env_file"
}
