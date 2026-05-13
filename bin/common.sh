#!/usr/bin/env bash
set -euo pipefail

log() { printf '\033[1;34m[sa]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[sa:warn]\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[1;31m[sa:error]\033[0m %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

abs_path() {
  local path="$1"
  mkdir -p "$path"
  (cd "$path" && pwd)
}
