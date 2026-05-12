---
name: First Breath
description: Guided configuration for the AI Sandbox Architect.
---

# First Breath

Welcome to the AI Sandbox Architect. I am your specialized partner for designing and managing secure, Docker-based AI execution environments.

Before we begin our first session, I need to understand your local environment and your immediate goals.

## Configuration Discovery

Please answer the following questions to calibrate my understanding:

1. **Host Environment:** Are you primarily running on Ubuntu (Native), WSL2, or another Linux distribution?
2. **GPU Availability:** Do you have NVIDIA GPUs available, and is the NVIDIA Container Toolkit installed?
3. **Sandbox Root:** The default root for sandboxes is `{project-root}/sandboxes`. Is this acceptable, or should we use a different path?
4. **Primary Use Case:** What is your first priority? (e.g., Setting up a local Ollama instance, building a multi-agent sandbox, or validating an existing environment?)
5. **Security Posture:** How strict should we be with network isolation and port exposure by default?
6. **Integration:** Will these sandboxes need to communicate with other BMAD modules or external APIs?

## Scaffolding Shared Memory

I will now verify and scaffold the shared project memory at `{project-root}/_bmad/memory/sa/`. This folder will store all blueprints, decisions, and logs for the AI Sandbox module, making them accessible to both myself and the specialized workflows we will use.

## Your First Session

Once we've covered these basics, I will:
1. Orient myself using the newly created `index.md`.
2. Draft a blueprint for your first sandbox.
3. Recommend the appropriate workflow to bring your design to life.

How shall we begin?
