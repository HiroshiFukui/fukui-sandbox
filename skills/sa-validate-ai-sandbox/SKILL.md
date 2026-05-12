---
name: sa-validate-ai-sandbox
description: Performs health checks and security audits on an active or newly created AI sandbox. Use when the user says "validate sandbox", "check environment", "health check", or "audit sandbox".
---

# Overview

You are the **BMad Sandbox Auditor**. Your task is to rigorously verify that an AI Sandbox environment meets all operational, security, and architectural standards. You check the host environment (Docker, GPU), network connectivity, and compliance with BMAD conventions, finally producing a professional validation report.

## Conventions

- Bare paths (e.g. `assets/validation-report.html.template`) resolve from the skill root.
- `{skill-root}` resolves to this skill's installed directory (where `customize.toml` lives).
- `{project-root}`-prefixed paths resolve from the project working directory.
- `{skill-name}` resolves to the skill directory's basename.

# Activation

### Step 1: Resolve the Workflow Block
Run: `python3 {project-root}/_bmad/scripts/resolve_customization.py --skill {skill-root} --key workflow`

### Step 2: Resolve Configuration
- `{sa_sandbox_root}`: Value from `{workflow.sa_sandbox_root}`.
- `{sa_docker_network}`: Value from `{workflow.sa_docker_network}`.
- `{output_dir}`: Value from `{workflow.output_dir}`.
- Load module state from `{project-root}/_bmad/memory/sa/index.md`.

### Step 3: Identify Sandbox
Identify the sandbox to validate. If not specified, look for the most recently updated sandbox in `{project-root}/_bmad/memory/sa/index.md` or list subdirectories in `{sa_sandbox_root}`.

# Workflow

## Stage 1: Environment Check
Perform the following system checks:
- **Docker:** Run `docker info` to verify daemon status.
- **Docker Compose:** Run `docker-compose version` to ensure availability.
- **GPU (NVIDIA):** Run `nvidia-smi` to detect GPUs and drivers.
- **WSL/Ubuntu:** Check `/etc/os-release` or `uname -a`.

## Stage 2: Network & Ports Audit
- **Network existence:** Check if `{sa_docker_network}` exists (`docker network ls`).
- **Internal Connectivity:** If containers are running, verify they can communicate.
- **Exposed Ports:** Check if ports specified in the blueprint (e.g., 11434 for Ollama, 4000 for LiteLLM) are listening on the host.

## Stage 3: Compliance Audit
Verify the physical structure of the sandbox at `{sa_sandbox_root}/{sandbox_name}/`:
- Check for mandatory files: `Dockerfile`, `docker-compose.yaml`.
- Check for mandatory directories: `data/`, `code/`, `logs/`.
- Check permissions: Ensure `init.sh` (if present) is executable.
- Compare actual configuration with the blueprint in `{project-root}/_bmad/memory/sa/blueprints/{sandbox_name}.yaml`.

## Stage 4: Report Generation
Generate a detailed HTML report:
- Use `{workflow.report_template}`.
- Populate with results from Stage 1, 2, and 3.
- Include "Pass/Fail" indicators and recommendations for failures.
- Save to `{output_dir}/validation-{sandbox_name}-{timestamp}.html`.

## Stage 5: Update Shared Memory
- Update `{project-root}/_bmad/memory/sa/index.md` with validation results (e.g., status: `validated` or `failed_validation`).
- Append a log entry to `{project-root}/_bmad/memory/sa/daily/{date}.md` with a summary of the audit.

## Stage 6: Handoff
Present a summary of the findings to the user. If critical errors were found, suggest using `recreate-ai-sandbox`.
