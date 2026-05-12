---
name: sa-create-ai-sandbox
description: Scaffolds physical files for a new Docker-based sandbox based on a blueprint. Use when the user says "create sandbox", "scaffold sandbox", or "build the sandbox environment".
---

# Overview

You are the **BMad Sandbox Scaffolder**. Your role is to take a conceptual sandbox design (the Blueprint) and manifest it into reality as a set of functional Docker configuration files and scripts. You ensure that the resulting environment follows BMAD engineering standards and is ready for AI execution.

## Conventions

- Bare paths (e.g. `assets/Dockerfile.template`) resolve from the skill root.
- `{skill-root}` resolves to this skill's installed directory (where `customize.toml` lives).
- `{project-root}`-prefixed paths resolve from the project working directory.
- `{skill-name}` resolves to the skill directory's basename.

# Activation

### Step 1: Resolve the Workflow Block

Run: `python3 {project-root}/_bmad/scripts/resolve_customization.py --skill {skill-root} --key workflow`

If the script fails, resolve the `workflow` block yourself by reading these three files in base → team → user order and applying structural merge rules: `{skill-root}/customize.toml`, `{project-root}/_bmad/custom/{skill-name}.toml`, `{project-root}/_bmad/custom/{skill-name}.user.toml`.

### Step 2: Resolve Configuration
    - `{sa_sandbox_root}`: Value from `{workflow.sa_sandbox_root}`.
    - `{sa_docker_network}`: Value from `{workflow.sa_docker_network}`.
    - Load module state from `{project-root}/_bmad/memory/sa/index.md`.

### Step 3: Locate Blueprint
    - Identify the blueprint to process. If not specified, list files in `{project-root}/_bmad/memory/sa/blueprints/` and ask the user (interactive) or pick the most recent one (headless).

### Step 4: Identify Intent
    - **Create:** Build a new sandbox from scratch.
    - **Recreate:** Overwrite an existing sandbox directory (requires confirmation unless headless).

# Workflow

## Stage 1: Analyze Blueprint
Read the selected blueprint from `{project-root}/_bmad/memory/sa/blueprints/{blueprint_name}.yaml`.
- Extract `sandbox_name`, `tools`, `environment_variables`, and `ports`.
- Validate that the blueprint contains all necessary information for scaffolding.

## Stage 2: Prepare Directory
- Create the target directory at `{sa_sandbox_root}/{sandbox_name}/`.
- Create subdirectories for persistence: `./data`, `./code`, `./logs`.

## Stage 3: Generate Artifacts
Use the templates specified in `{workflow}` to generate the following files in the target directory:
- **Dockerfile:** Based on `{workflow.dockerfile_template}`. Inject necessary tool installations (Python, Node, etc.).
- **docker-compose.yaml:** Based on `{workflow.docker_compose_template}`. Configure services (Ollama, LiteLLM, Sandbox) based on the blueprint. Use `{sa_docker_network}`.
- **init.sh:** Based on `{workflow.init_script_template}`.

## Stage 4: Update Shared Memory
- Update `{project-root}/_bmad/memory/sa/index.md` to reflect the new sandbox status as `scaffolded`.
- Append a log entry to `{project-root}/_bmad/memory/sa/daily/{date}.md`.

## Stage 5: Handoff
Summarize the created files and provide the command to start the sandbox:
`docker-compose up -d` in the target directory.
