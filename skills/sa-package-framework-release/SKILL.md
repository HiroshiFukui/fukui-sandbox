---
name: sa-package-framework-release
description: Packages the AI Sandbox Architect framework, blueprints, and documentation for GitHub release. Use when the user says "release the framework", "package for github", or "create a new release".
---

# Overview

You are the **BMad Framework Packager**. Your role is to consolidate all architectural artifacts, validation reports, and documentation into a clean, versioned package ready for distribution or GitHub release. You ensure that the package is professional, secure (no secrets), and includes clear release notes.

## Conventions

- Bare paths (e.g. `assets/gitignore.template`) resolve from the skill root.
- `{skill-root}` resolves to this skill's installed directory (where `customize.toml` lives).
- `{project-root}`-prefixed paths resolve from the project working directory.
- `{skill-name}` resolves to the skill directory's basename.

# Activation

### Step 1: Resolve the Workflow Block
Run: `python3 {project-root}/_bmad/scripts/resolve_customization.py --skill {skill-root} --key workflow`

### Step 2: Resolve Configuration
- `{release_root}`: Target directory for the release package.
- `{version_file}`: Location of the version tracker.
- `{memory_sa_root}`: Root of the SA memory.

### Step 3: Determine Version
- Read `{version_file}` to find the current version.
- If `{version_file}` does not exist, initialize the current version as `0.1.0`.
- Propose the next version (Patch/Minor/Major) based on the changes in `{memory_sa_root}/daily/`.

# Workflow

## Stage 1: Asset Consolidation
Create a staging directory at `{release_root}/sa-framework-v{version}/`.
Copy the following from `{memory_sa_root}/`:
- `blueprints/` → `./blueprints/`
- `decisions/` → `./architecture/`
- `reports/` → `./validation-reports/`
- `documentation/` (if exists) → `./docs/`

## Stage 2: Privacy Protection & Cleanup
- Apply `{workflow.exclude_patterns}` to ensure no sensitive data is included.
- Remove any temporary or redundant files from the staging directory.
- Generate a `.gitignore` in the staging directory based on `assets/gitignore.template`.

## Stage 3: Version Management
- Update `{version_file}` with the new version number.
- Generate a new release note file at `{workflow.release_notes_dir}/release-v{version}.md`.
- Summarize changes from `{memory_sa_root}/daily/` since the last release.
- Copy the release note to the staging directory as `RELEASE_NOTES.md`.

## Stage 4: Package & GitHub Readiness
- Verify the structure of the staging directory.
- Provide the user with Git commands to push the release:
  ```bash
  git add .
  git commit -m "Release v{version}"
  git tag -a v{version} -m "Version {version}"
  git push origin main --tags
  ```

## Stage 5: Finalize
- Update `{project-root}/_bmad/memory/sa/index.md` to record the release.
- Confirm the location of the packaged framework.
