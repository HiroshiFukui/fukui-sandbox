#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

ROOT="${SA_SANDBOX_ROOT:-$HOME/ai-sandboxes-runtime}"
NAME=""
RUNTIME="devcontainer"
STACK="node-python"
SECURITY="agent-safe"
MODEL="none"
FORCE="false"
DOCKER_SOCKET="false"
SSH_MOUNT="false"

usage() {
  cat <<USAGE
Usage:
  create-ai-sandbox.sh --name NAME [options]

Options:
  --runtime devcontainer|docker-compose|both   Default: devcontainer
  --stack ubuntu|node|python|node-python       Default: node-python
  --security relaxed|restricted|agent-safe     Default: agent-safe
  --model none|env|litellm|ollama|gemini|openai-compatible
  --root PATH                                  Default: \$SA_SANDBOX_ROOT or ~/ai-sandboxes-runtime
  --docker-socket                             Mount /var/run/docker.sock (off by default)
  --ssh-mount                                 Mount ~/.ssh read-only (off by default)
  --force                                     Overwrite existing sandbox directory
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --runtime) RUNTIME="${2:-}"; shift 2 ;;
    --stack) STACK="${2:-}"; shift 2 ;;
    --security) SECURITY="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --root) ROOT="${2:-}"; shift 2 ;;
    --docker-socket) DOCKER_SOCKET="true"; shift ;;
    --ssh-mount) SSH_MOUNT="true"; shift ;;
    --force) FORCE="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done

[[ -n "$NAME" ]] || { usage; fail "--name is required"; }
[[ "$RUNTIME" =~ ^(devcontainer|docker-compose|both)$ ]] || fail "Invalid runtime: $RUNTIME"
[[ "$STACK" =~ ^(ubuntu|node|python|node-python)$ ]] || fail "Invalid stack: $STACK"
[[ "$SECURITY" =~ ^(relaxed|restricted|agent-safe)$ ]] || fail "Invalid security profile: $SECURITY"

TARGET="$ROOT/$NAME"
if [[ -e "$TARGET" && "$FORCE" != "true" ]]; then
  fail "Sandbox already exists: $TARGET. Use --force to overwrite."
fi
if [[ -e "$TARGET" && "$FORCE" == "true" ]]; then
  warn "Removing existing sandbox: $TARGET"
  rm -rf "$TARGET"
fi

mkdir -p "$TARGET/workspace" "$TARGET/outputs" "$TARGET/logs" "$TARGET/blueprints" "$TARGET/docs"

case "$STACK" in
  ubuntu) BASE_IMAGE="ubuntu:24.04"; INSTALL_NODE="false"; INSTALL_PYTHON="true" ;;
  node) BASE_IMAGE="node:22-bookworm"; INSTALL_NODE="true"; INSTALL_PYTHON="false" ;;
  python) BASE_IMAGE="python:3.12-bookworm"; INSTALL_NODE="false"; INSTALL_PYTHON="true" ;;
  node-python) BASE_IMAGE="node:22-bookworm"; INSTALL_NODE="true"; INSTALL_PYTHON="true" ;;
esac

cat > "$TARGET/blueprints/$NAME.yaml" <<YAML
name: $NAME
runtime: $RUNTIME
stack: $STACK
security_profile: $SECURITY
model_access: $MODEL
features:
  docker_socket: $DOCKER_SOCKET
  ssh_mount: $SSH_MOUNT
  host_gateway: true
paths:
  workspace: ./workspace
  outputs: ./outputs
  logs: ./logs
YAML

cat > "$TARGET/.env.example" <<ENV
# Copy to .env and fill only what this sandbox needs.
SANDBOX_NAME=$NAME
SANDBOX_RUNTIME=$RUNTIME
SANDBOX_STACK=$STACK

# Model providers / gateways
GEMINI_API_KEY=
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
OPENAI_BASE_URL=http://host.docker.internal:4000/v1
OLLAMA_BASE_URL=http://host.docker.internal:11434
LITELLM_BASE_URL=http://host.docker.internal:4000
ENV
cp "$TARGET/.env.example" "$TARGET/.env"

cat > "$TARGET/.gitignore" <<'EOF_GIT'
.env
logs/
outputs/
workspace/.cache/
**/.gemini/
**/.config/
**/.ssh/
EOF_GIT

write_devcontainer() {
  mkdir -p "$TARGET/.devcontainer"
  cat > "$TARGET/.devcontainer/devcontainer.json" <<JSON
{
  "name": "$NAME",
  "dockerComposeFile": "docker-compose.yml",
  "service": "workspace",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  "remoteUser": "dev",
  "postCreateCommand": "git --version && node --version 2>/dev/null || true && python3 --version 2>/dev/null || true"
}
JSON

  cat > "$TARGET/.devcontainer/Dockerfile" <<DOCKERFILE
FROM $BASE_IMAGE

ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
    build-essential \
    jq \
    yq \
    ripgrep \
    fd-find \
    vim \
    nano \
    less \
    procps \
    lsof \
    iproute2 \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

WORKDIR /workspace
USER dev

ENV NPM_CONFIG_PREFIX=/home/dev/.npm-global
ENV PATH=/home/dev/.npm-global/bin:/home/dev/.local/bin:$PATH

RUN mkdir -p /home/dev/.npm-global /home/dev/.local/bin

CMD ["sleep", "infinity"]
DOCKERFILE

  local extra_volumes=""
  [[ "$DOCKER_SOCKET" == "true" ]] && extra_volumes+=$'\n      - /var/run/docker.sock:/var/run/docker.sock'
  [[ "$SSH_MOUNT" == "true" ]] && extra_volumes+=$'\n      - ${HOME}/.ssh:/home/dev/.ssh:ro'

  local security_block=""
  if [[ "$SECURITY" == "agent-safe" || "$SECURITY" == "restricted" ]]; then
    security_block=$'\n    cap_drop:\n      - NET_RAW\n    security_opt:\n      - no-new-privileges:true'
  fi

  cat > "$TARGET/.devcontainer/docker-compose.yml" <<YAML
services:
  workspace:
    build:
      context: .
      dockerfile: Dockerfile
    working_dir: /workspace
    volumes:
      - ../workspace:/workspace:rw
      - ../outputs:/outputs:rw
      - ../logs:/logs:rw$extra_volumes
    env_file:
      - ../.env
    command: sleep infinity
    user: dev$security_block
    extra_hosts:
      - "host.docker.internal:host-gateway"
YAML
}

write_docker_compose() {
  cat > "$TARGET/Dockerfile" <<DOCKERFILE
FROM $BASE_IMAGE
ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates bash sudo unzip build-essential python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev
WORKDIR /workspace
USER dev
CMD ["sleep", "infinity"]
DOCKERFILE

  local security_block=""
  if [[ "$SECURITY" == "agent-safe" || "$SECURITY" == "restricted" ]]; then
    security_block=$'\n    cap_drop:\n      - ALL\n    security_opt:\n      - no-new-privileges:true'
  fi

  cat > "$TARGET/docker-compose.yml" <<YAML
services:
  workspace:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${NAME}-workspace
    working_dir: /workspace
    volumes:
      - ./workspace:/workspace:rw
      - ./outputs:/outputs:rw
      - ./logs:/logs:rw
    env_file:
      - .env
    command: sleep infinity
    user: dev$security_block
    extra_hosts:
      - "host.docker.internal:host-gateway"
YAML
}

[[ "$RUNTIME" == "devcontainer" || "$RUNTIME" == "both" ]] && write_devcontainer
[[ "$RUNTIME" == "docker-compose" || "$RUNTIME" == "both" ]] && write_docker_compose

cat > "$TARGET/README.md" <<README
# $NAME

Generated by AI Sandbox Framework runtime scripts.

## Runtime

- Runtime: $RUNTIME
- Stack: $STACK
- Security profile: $SECURITY
- Model access: $MODEL

## Dev Container

Open this folder in Google Antigravity, VS Code, Cursor, or another IDE that supports Dev Containers.

The agent should work only inside \`/workspace\` by default.

## Docker Compose

\`\`\`bash
docker compose up -d --build
\`\`\`

## Validate

\`\`\`bash
../../bin/validate-ai-sandbox.sh "$TARGET"
\`\`\`
README

log "Created sandbox: $TARGET"
log "Blueprint: $TARGET/blueprints/$NAME.yaml"
