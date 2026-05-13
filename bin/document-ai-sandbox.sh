#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
TARGET="${1:-}"
[[ -n "$TARGET" ]] || fail "Usage: document-ai-sandbox.sh PATH_TO_SANDBOX"
[[ -d "$TARGET" ]] || fail "Directory not found: $TARGET"
DOC_DIR="$TARGET/docs"
mkdir -p "$DOC_DIR"
DOC="$DOC_DIR/SANDBOX.md"
{
  echo "# Sandbox Documentation"
  echo
  echo "Path: \`$TARGET\`"
  echo "Generated: $(date -Is)"
  echo
  echo "## Files"
  echo
  find "$TARGET" -maxdepth 3 -type f | sed "s#^$TARGET/##" | sort | sed 's#^#- #'
  echo
  echo "## Usage"
  echo
  if [[ -d "$TARGET/.devcontainer" ]]; then
    echo "Open this folder in an IDE with Dev Container support, such as Google Antigravity or VS Code."
  fi
  if [[ -f "$TARGET/docker-compose.yml" ]]; then
    echo
    echo '```bash'
    echo 'docker compose up -d --build'
    echo '```'
  fi
} > "$DOC"
log "Documentation generated: $DOC"
