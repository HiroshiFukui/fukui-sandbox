# AI Sandbox Architect - v0.2.0
## Release Date: 2026-05-13

### New Features: Dev Container Support & Localized Documentation
- **Native Dev Container Support:** The `sa-create-ai-sandbox` skill now supports generating complete VS Code Dev Container configurations (`.devcontainer/`).
- **Localized Documentation:** Added Portuguese (PT-BR) support to the `sa-document-ai-sandbox` skill with a dedicated template.
- **Improved Scaffolding:** New interactive discovery flow to choose between `docker-compose`, `devcontainer`, or `both`.
- **Enhanced Documentation Templates:** Templates now dynamically adjust usage instructions based on the selected runtime.

### Skills Updated:
- `sa-create-ai-sandbox`: Added Dev Container templates and logic.
- `sa-document-ai-sandbox`: Added Portuguese template and updated logic for multi-runtime documentation.

### Included Skills:
- ai-sandbox-architect
- sa-create-ai-sandbox
- sa-validate-ai-sandbox
- sa-document-ai-sandbox
- sa-recreate-ai-sandbox
- sa-package-framework-release
- sa-setup
