#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

TARGET="${1:-}"
[[ -n "$TARGET" ]] || fail "Usage: validate-ai-sandbox.sh PATH_TO_SANDBOX"
[[ -d "$TARGET" ]] || fail "Directory not found: $TARGET"

REPORT_DIR="$TARGET/reports"
mkdir -p "$REPORT_DIR"
REPORT="$REPORT_DIR/validation-$(date +%Y%m%d-%H%M%S).md"
STATUS=0

check_file() {
  local file="$1"; local label="$2"
  if [[ -f "$TARGET/$file" ]]; then echo "- ✅ $label: \`$file\`" >> "$REPORT"; else echo "- ❌ $label missing: \`$file\`" >> "$REPORT"; STATUS=1; fi
}
check_dir() {
  local dir="$1"; local label="$2"
  if [[ -d "$TARGET/$dir" ]]; then echo "- ✅ $label: \`$dir\`" >> "$REPORT"; else echo "- ❌ $label missing: \`$dir\`" >> "$REPORT"; STATUS=1; fi
}

{
  echo "# AI Sandbox Validation Report"
  echo
  echo "Sandbox: \`$TARGET\`"
  echo "Date: $(date -Is)"
  echo
  echo "## Structure"
} > "$REPORT"

check_dir "workspace" "Workspace directory"
check_dir "outputs" "Outputs directory"
check_dir "logs" "Logs directory"
check_file ".env.example" "Environment example"
check_file "README.md" "README"

if [[ -d "$TARGET/.devcontainer" ]]; then
  echo >> "$REPORT"; echo "## Dev Container" >> "$REPORT"
  check_file ".devcontainer/devcontainer.json" "Dev Container config"
  check_file ".devcontainer/docker-compose.yml" "Dev Container Compose"
  check_file ".devcontainer/Dockerfile" "Dev Container Dockerfile"

  if grep -q '"remoteUser"[[:space:]]*:[[:space:]]*"root"' "$TARGET/.devcontainer/devcontainer.json" 2>/dev/null; then
    echo "- ❌ remoteUser is root" >> "$REPORT"; STATUS=1
  else
    echo "- ✅ remoteUser is not root or not explicitly root" >> "$REPORT"
  fi
  if grep -q '/var/run/docker.sock' "$TARGET/.devcontainer/docker-compose.yml" 2>/dev/null; then
    echo "- ⚠️ Docker socket is mounted. Review whether this is really needed." >> "$REPORT"
  else
    echo "- ✅ Docker socket is not mounted" >> "$REPORT"
  fi
  if grep -q '\.ssh' "$TARGET/.devcontainer/docker-compose.yml" 2>/dev/null; then
    echo "- ⚠️ SSH directory is mounted. Review whether this is really needed." >> "$REPORT"
  else
    echo "- ✅ SSH directory is not mounted" >> "$REPORT"
  fi
  if grep -q 'no-new-privileges:true' "$TARGET/.devcontainer/docker-compose.yml" 2>/dev/null; then
    echo "- ✅ no-new-privileges enabled" >> "$REPORT"
  else
    echo "- ⚠️ no-new-privileges not found" >> "$REPORT"
  fi
fi

if [[ -f "$TARGET/docker-compose.yml" ]]; then
  echo >> "$REPORT"; echo "## Docker Compose" >> "$REPORT"
  check_file "docker-compose.yml" "Docker Compose config"
  check_file "Dockerfile" "Dockerfile"
fi

log "Validation report: $REPORT"
exit "$STATUS"
