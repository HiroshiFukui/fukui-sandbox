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

The AI Sandbox Architect module aims to abstract the infrastructure complexity of setting up secure, Docker-based AI execution environments on Ubuntu/WSL. It provides a universal, professional-grade framework to prevent vendor lock-in and ensure architectural best practices across the full lifecycle of a sandbox.

## Architecture

The module follows the **Orchestrator Agent with Modular Workflows** pattern. A single master agent, `ai-sandbox-architect`, serves as the primary conversational interface and strategic guide. It coordinates five specialized, independently invokable workflows that handle the technical heavy lifting.

**Rationale:**
- **Cohesion:** One conversational partner provides a unified experience and maintains the design "vision."
- **Modularity:** Workflows are self-contained and can be run directly for repetitive tasks without conversation.
- **Guidance:** The Architect analyzes state and recommends the appropriate workflow (e.g., "I see the blueprint exists but is not validated. Shall we run the validation workflow?").

### Memory Architecture

The module utilizes **Single Shared Project Memory**. It avoids personal agent memory to ensure all state, decisions, and history are transparent and accessible to both the Architect and the Workflows.

**Folder Structure:**
`{project-root}/_bmad/memory/sa/`
- `index.md`: Current status of all sandboxes and recent activity.
- `blueprints/`: JSON/YAML definitions of planned sandboxes.
- `decisions/`: Markdown files documenting architectural choices and environmental constraints.
- `daily/`: Chronological logs of all module actions.

### Memory Contract

| Filename | Purpose | Readers | Writers |
| -------- | ------- | ------- | ------- |
| `index.md` | Orientation and state tracking | Architect, All Workflows | Architect, All Workflows |
| `blueprints/*.yaml` | Sandbox definitions | Architect, All Workflows | Architect, Create/Recreate |
| `reports/validation-*.md` | Quality and health checks | Architect | Validate Workflow |
| `release-notes/*.md` | Versioning and change logs | Architect | Package Workflow |

### Cross-Agent Patterns

- **Orchestrator Role:** The Architect reads the `index.md` and `blueprints/` on activation to orient itself.
- **Workflow Handoff:** The Architect prepares the necessary context (e.g., pointing to a specific blueprint) and recommends the user invoke the relevant workflow.
- **State Loopback:** Workflows update the shared memory folder and `index.md` upon completion, which the Architect picks up in the next turn.

## Skills

### ai-sandbox-architect

**Type:** agent

**Persona:** A senior systems architect and DevOps expert. Professional, precise, and visionary. Thinks in terms of security, portability, and professional standards.

**Core Outcome:** The user has a clear, documented path to a functional and secure AI sandbox that follows the BMAD method.

**The Non-Negotiable:** Must ensure that all architectural decisions are documented and grounded in the user's technical constraints (Ubuntu/WSL/Docker).

**Capabilities:**

| Capability | Outcome | Inputs | Outputs |
| ---------- | ------- | ------ | ------- |
| Discovery | Comprehensive list of requirements and constraints. | User dialogue | Sandbox Blueprint (Draft) |
| Strategic Guidance | Recommendation on next steps based on system state. | Shared Memory (index) | User advice / Workflow trigger |
| Design Review | Validation of architectural choices against best practices. | Blueprint | Architectural Report (HTML) |

**Memory:** Reads `{project-root}/_bmad/memory/sa/index.md` and `blueprints/` on activation. Writes to `decisions/` and `daily/`.

**Init Responsibility:** Scaffolds the shared memory directory structure if it doesn't exist.

**Activation Modes:** Interactive.

**Tool Dependencies:** None (Conversational/Strategic).

**Design Notes:** Focuses on the "Why" and "What". Leaves the "How" to the workflows.

---

### create-ai-sandbox

**Type:** workflow

**Purpose:** Scaffolds the physical files for a new Docker-based sandbox.

**Capabilities:**

| Capability | Outcome | Inputs | Outputs |
| ---------- | ------- | ------ | ------- |
| File Scaffolding | Dockerfiles, docker-compose.yaml, and init scripts. | Blueprint | Sandbox files in target dir |
| Tool Integration | Configured Ollama/LiteLLM/Node/Python environments. | Blueprint | Environment config files |

---

### validate-ai-sandbox

**Type:** workflow

**Purpose:** Runs health checks and security audits on a running sandbox.

**Capabilities:**

| Capability | Outcome | Inputs | Outputs |
| ---------- | ------- | ------ | ------- |
| Environment Check | Validation of Docker, WSL, GPU, and Network. | Runtime State | Validation Report (HTML) |
| Compliance Audit | Verification of BMAD conventions and security. | Blueprint / Files | Security Scorecard |

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
