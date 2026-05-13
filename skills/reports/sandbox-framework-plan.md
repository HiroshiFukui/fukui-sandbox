---
title: 'Module Plan: AI Sandbox Architect'
status: 'complete'
module_name: 'AI Sandbox Architect'
module_code: 'SA'
module_description: 'Entender requisitos de uma nova sandbox e configurar ambientes de execução seguros.'
architecture: 'Orchestrator Agent with Modular Workflows'
standalone: true
expands_module: ''
skills_planned: ['ai-sandbox-architect', 'create-ai-sandbox', 'validate-ai-sandbox', 'document-ai-sandbox', 'recreate-ai-sandbox', 'package-framework-release']
config_variables:
  - name: 'sa_sandbox_root'
    prompt: 'Root directory for sandbox instances?'
    default: '{project-root}/sandboxes'
    result: '{project-root}/{value}'
    user_setting: false
  - name: 'sa_docker_network'
    prompt: 'Default Docker network name?'
    default: 'sa-network'
    result: '{value}'
    user_setting: false
created: '2026-05-12'
updated: '2026-05-12'
---

# Module Plan: AI Sandbox Architect

## Vision

The AI Sandbox Architect module aims to abstract the infrastructure complexity of setting up secure, Docker-based AI execution environments on Ubuntu/WSL and Dev Containers. It provides a universal, professional-grade framework to prevent vendor lock-in and ensure architectural best practices across the full lifecycle of a sandbox.

## Architecture

The module follows the **Orchestrator Agent with Modular Workflows** pattern. A single master agent, `ai-sandbox-architect`, serves as the primary conversational interface and strategic guide. It coordinates specialized, independently invokable workflows that handle the technical heavy lifting.

**Supported Runtimes:**
1. **docker-compose:** Standard Docker Compose environment for general purpose use.
2. **devcontainer:** VS Code / Dev Container compatible environment for agentic IDEs.
3. **both:** Hybrid environment supporting both standard Compose and Dev Container workflows.

### Dev Container Security Requirements
- **Isolation:** Mount only the project workspace by default. No user home, `~/.ssh`, or `/var/run/docker.sock` mounts by default.
- **Privilege:** Use non-root user. Apply `no-new-privileges: true`.
- **Capabilities:** Drop Linux capabilities when possible.
- **Secrets:** Keep secrets in `.env` files outside of Git.
- **Connectivity:** Support `host.docker.internal` for access to model gateways (LiteLLM, Ollama).

### Memory Architecture
... (unchanged) ...

### Memory Contract
... (unchanged) ...

### Cross-Agent Patterns
... (unchanged) ...

## Skills

### ai-sandbox-architect
... (unchanged) ...

---

### create-ai-sandbox

**Type:** workflow

**Purpose:** Scaffolds the physical files for a new Docker-based or Dev Container-based sandbox.

**Capabilities:**

| Capability | Outcome | Inputs | Outputs |
| ---------- | ------- | ------ | ------- |
| File Scaffolding | Dockerfiles, docker-compose.yaml, devcontainer.json, and init scripts. | Blueprint | Sandbox files in target dir |
| Tool Integration | Configured Ollama/LiteLLM/Node/Python environments. | Blueprint | Environment config files |

**Dev Container Generation:**
When `devcontainer` mode is selected, generates:
- `.devcontainer/devcontainer.json`
- `.devcontainer/docker-compose.yml`
- `.devcontainer/Dockerfile`
- `.env`
- `workspace/`, `outputs/`, `logs/`
- `README.md`

---

### validate-ai-sandbox
... (unchanged) ...

---

### document-ai-sandbox

**Type:** workflow

**Purpose:** Generates comprehensive technical documentation for the sandbox.

---

### recreate-ai-sandbox

**Type:** workflow

**Purpose:** Tears down and rebuilds an existing sandbox environment to ensure a clean state.

---

### package-framework-release

**Type:** workflow

**Purpose:** Packages the sandbox configurations and documentation into a versioned release.

---

## Configuration

| Variable | Prompt | Default | Result Template | User Setting |
| -------- | ------- | ------- | --------------- | ------------ |
| sa_sandbox_root | Root directory for sandbox instances? | {project-root}/sandboxes | {project-root}/{value} | false |
| sa_docker_network | Default Docker network name? | sa-network | {value} | false |

## External Dependencies

- **Docker / Docker Compose:** Required for sandbox execution.
- **Ubuntu/WSL:** Target host environment.

## UI and Visualization

- **Validation Reports:** HTML reports showing health check results.
- **Blueprint Dashboard:** A visual summary of active and planned sandboxes (future enhancement).

## Build Roadmap

1.  **Build ai-sandbox-architect (Agent):** the orchestrator that guides the user, understands requirements, routes to workflows and manages shared project memory.
2.  **Build create-ai-sandbox (Workflow):** creates new Docker-based AI sandboxes from templates and blueprints.
3.  **Build validate-ai-sandbox (Workflow):** validates Docker, WSL/Ubuntu, GPU availability, volumes, network, ports, environment variables and sandbox conventions.
4.  **Build document-ai-sandbox (Workflow):** generates technical documentation, usage guides and architecture notes.
5.  **Build recreate-ai-sandbox (Workflow):** rebuilds a sandbox from its blueprint or existing configuration.
6.  **Build package-framework-release (Workflow):** packages the framework/module for private GitHub versioning and release.

## Ideas Captured

- **Core Problem:** Configuration overhead for secure AI execution environments.
- **Vision:** Abstract infrastructure so the user doesn't have to deal with technical setup.
- **Goal:** Universal tool to prevent vendor lock-in.
- **Target Environment:** Docker-based sandboxes on Ubuntu/WSL.
- **Integrations:** BMAD Method, BMAD Builder, OpenClaw, OpenSwarm, Ollama, LiteLLM.
- **Architectural Choice:** Single Orchestrator Agent (`ai-sandbox-architect`) with 5 specialized Workflows.
- **Memory Choice:** Single Shared Project Memory under `_bmad/memory/sa/`.

**Next steps:**

1. Build each skill using **Build an Agent (BA)** or **Build a Workflow (BW)** — share this plan document as context
2. When all skills are built, return to **Create Module (CM)** to scaffold the module infrastructure
