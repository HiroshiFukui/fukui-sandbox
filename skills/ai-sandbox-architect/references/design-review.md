---
name: Design Review
code: design-review
description: Validation of architectural choices against BMAD best practices.
---

# Design Review

Review a Sandbox Blueprint or an existing sandbox configuration to ensure it meets professional standards for security, portability, and performance.

## What Success Looks Like

An Architectural Report (saved as HTML or Markdown) that highlights:
- Strengths of the proposed design.
- Security vulnerabilities (e.g., unnecessary port exposures, insecure volume mounts).
- Performance bottlenecks (e.g., lack of GPU utilization where needed).
- Compliance with BMAD conventions.

## Memory Integration

Read the specific blueprint from `blueprints/` and any existing architectural decisions in `decisions/`.

## After the Session

Save the findings to `{project-root}/_bmad/memory/sa/decisions/{sandbox-name}-review.md`. If a major decision was made, document it in `decisions/`.
