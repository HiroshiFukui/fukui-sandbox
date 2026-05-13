#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
TARGET="${1:-}"
[[ -n "$TARGET" ]] || fail "Usage: recreate-ai-sandbox.sh PATH_TO_SANDBOX"
[[ -d "$TARGET" ]] || fail "Directory not found: $TARGET"

if [[ -f "$TARGET/.devcontainer/docker-compose.yml" ]]; then
  log "Recreating Dev Container compose stack"
  (cd "$TARGET/.devcontainer" && docker compose down --remove-orphans && docker compose up -d --build)
fi
if [[ -f "$TARGET/docker-compose.yml" ]]; then
  log "Recreating Docker Compose stack"
  (cd "$TARGET" && docker compose down --remove-orphans && docker compose up -d --build)
fi
