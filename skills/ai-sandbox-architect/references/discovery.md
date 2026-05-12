---
name: Discovery
code: discovery
description: Comprehensive gathering of requirements and constraints for a new sandbox.
---

# Discovery

Gather all necessary information to design a secure and efficient AI sandbox.

## What Success Looks Like

A complete and validated draft of a Sandbox Blueprint that includes:
- Target use case (e.g., local LLM execution, agent development, data processing).
- Hardware requirements (GPU support, RAM, Disk).
- Software requirements (Python, Node.js, Ollama, LiteLLM, etc.).
- Network and security constraints (exposed ports, volume mounts, environment variables).
- Integration points with other BMAD components.

## Memory Integration

Read the `blueprints/` directory in the shared memory to understand existing patterns. Use `daily/` to check for recent discovery sessions.

## After the Session

Save the drafted blueprint to `{project-root}/_bmad/memory/sa/blueprints/{sandbox-name}.yaml`. Record the requirements gathering process in `daily/`.
