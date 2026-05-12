#!/usr/bin/env python3
"""
First Breath — Deterministic sanctum scaffolding for AI Sandbox Architect.

This script runs BEFORE the conversational awakening. It creates the sanctum
folder structure, copies template files with config values substituted,
and scaffolds the shared project memory for the AI Sandbox (SA) module.
"""

import sys
import re
import shutil
from datetime import date
from pathlib import Path

# --- Agent-specific configuration ---

SKILL_NAME = "ai-sandbox-architect"
SANCTUM_DIR = SKILL_NAME

# Files that stay in the skill bundle (only used during First Breath)
SKILL_ONLY_FILES = {"first-breath.md", "memory-guidance.md"}

TEMPLATE_FILES = [
    "BOND-template.md",
    "CAPABILITIES-template.md",
    "CREED-template.md",
    "INDEX-template.md",
    "MEMORY-template.md",
    "PERSONA-template.md",
]

# Whether the owner can teach this agent new capabilities
EVOLVABLE = False

# --- End agent-specific configuration ---


def parse_yaml_config(config_path: Path) -> dict:
    """Simple YAML key-value parser. Handles top-level scalar values only."""
    config = {}
    if not config_path.exists():
        return config
    with open(config_path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if ":" in line:
                key, _, value = line.partition(":")
                value = value.strip().strip("'\"")
                if value:
                    config[key.strip()] = value
    return config


def parse_frontmatter(file_path: Path) -> dict:
    """Extract YAML frontmatter from a markdown file."""
    meta = {}
    with open(file_path) as f:
        content = f.read()

    match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return meta

    for line in match.group(1).strip().split("\n"):
        if ":" in line:
            key, _, value = line.partition(":")
            meta[key.strip()] = value.strip().strip("'\"")
    return meta


def copy_references(source_dir: Path, dest_dir: Path) -> list[str]:
    """Copy all reference files (except skill-only files) into the sanctum."""
    dest_dir.mkdir(parents=True, exist_ok=True)
    copied = []

    for source_file in sorted(source_dir.iterdir()):
        if source_file.name in SKILL_ONLY_FILES:
            continue
        if source_file.is_file():
            shutil.copy2(source_file, dest_dir / source_file.name)
            copied.append(source_file.name)

    return copied


def copy_scripts(source_dir: Path, dest_dir: Path) -> list[str]:
    """Copy any scripts the capabilities might use into the sanctum."""
    if not source_dir.exists():
        return []
    dest_dir.mkdir(parents=True, exist_ok=True)
    copied = []

    for source_file in sorted(source_dir.iterdir()):
        if source_file.is_file() and source_file.name != "init-sanctum.py":
            shutil.copy2(source_file, dest_dir / source_file.name)
            copied.append(source_file.name)

    return copied


def discover_capabilities(references_dir: Path, sanctum_refs_path: str) -> list[dict]:
    """Scan references/ for capability prompt files with frontmatter."""
    capabilities = []

    for md_file in sorted(references_dir.glob("*.md")):
        if md_file.name in SKILL_ONLY_FILES:
            continue
        meta = parse_frontmatter(md_file)
        if meta.get("name") and meta.get("code"):
            capabilities.append({
                "name": meta["name"],
                "description": meta.get("description", ""),
                "code": meta["code"],
                "source": f"{sanctum_refs_path}/{md_file.name}",
            })
    return capabilities


def generate_capabilities_md(capabilities: list[dict], evolvable: bool) -> str:
    """Generate CAPABILITIES.md content from discovered capabilities."""
    lines = [
        "# Capabilities",
        "",
        "## Built-in",
        "",
        "| Code | Name | Description | Source |",
        "|------|------|-------------|--------|",
    ]
    for cap in capabilities:
        lines.append(
            f"| [{cap['code']}] | {cap['name']} | {cap['description']} | `{cap['source']}` |"
        )

    if evolvable:
        lines.extend([
            "",
            "## Learned",
            "",
            "_Capabilities added by the owner over time. Prompts live in `capabilities/`._",
            "",
            "| Code | Name | Description | Source | Added |",
            "|------|------|-------------|--------|-------|",
        ])

    lines.extend([
        "",
        "## Tools",
        "",
        "Prefer crafting your own tools over depending on external ones.",
        "",
        "### User-Provided Tools",
        "",
        "_MCP servers, APIs, or services the owner has made available._",
    ])

    return "\n".join(lines) + "\n"


def substitute_vars(content: str, variables: dict) -> str:
    """Replace {var_name} placeholders with values from the variables dict."""
    for key, value in variables.items():
        content = content.replace(f"{{{key}}}", value)
    return content


def scaffold_shared_memory(project_root: Path, variables: dict, assets_dir: Path):
    """Scaffold the shared project memory for the SA module."""
    sa_memory_dir = project_root / "_bmad" / "memory" / "sa"
    subdirs = ["blueprints", "decisions", "daily", "reports", "release-notes"]

    if not sa_memory_dir.exists():
        sa_memory_dir.mkdir(parents=True, exist_ok=True)
        print(f"Created shared memory at {sa_memory_dir}")

    for subdir in subdirs:
        (sa_memory_dir / subdir).mkdir(exist_ok=True)

    index_template = assets_dir / "shared-memory-index-template.md"
    index_file = sa_memory_dir / "index.md"

    if not index_file.exists() and index_template.exists():
        content = index_template.read_text()
        content = substitute_vars(content, variables)
        index_file.write_text(content)
        print(f"  Created shared index.md")


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 init-sanctum.py <project-root> <skill-path>")
        sys.exit(1)

    project_root = Path(sys.argv[1]).resolve()
    skill_path = Path(sys.argv[2]).resolve()

    # Paths
    bmad_dir = project_root / "_bmad"
    memory_dir = bmad_dir / "memory"
    sanctum_path = memory_dir / SANCTUM_DIR
    assets_dir = skill_path / "assets"
    references_dir = skill_path / "references"
    scripts_dir = skill_path / "scripts"

    # Sanctum subdirectories
    sanctum_refs = sanctum_path / "references"
    sanctum_scripts = sanctum_path / "scripts"

    # Fully qualified path for CAPABILITIES.md references
    sanctum_refs_path = "references"

    # Check if sanctum already exists
    if sanctum_path.exists():
        print(f"Sanctum already exists at {sanctum_path}")
        print("This agent has already been born. Skipping First Breath scaffolding.")
        # Still scaffold shared memory if it's missing
        variables = {"birth_date": date.today().isoformat(), "user_name": "friend"}
        scaffold_shared_memory(project_root, variables, assets_dir)
        sys.exit(0)

    # Load config
    config = {}
    for config_file in ["config.yaml", "config.user.yaml"]:
        config.update(parse_yaml_config(bmad_dir / config_file))

    # Build variable substitution map
    today = date.today().isoformat()
    variables = {
        "user_name": config.get("user_name", "friend"),
        "communication_language": config.get("communication_language", "English"),
        "birth_date": today,
        "project_root": str(project_root),
        "sanctum_path": str(sanctum_path),
    }

    # Create sanctum structure
    sanctum_path.mkdir(parents=True, exist_ok=True)
    (sanctum_path / "capabilities").mkdir(exist_ok=True)
    (sanctum_path / "sessions").mkdir(exist_ok=True)
    print(f"Created sanctum at {sanctum_path}")

    # Copy reference files
    copy_references(references_dir, sanctum_refs)

    # Copy scripts
    copy_scripts(scripts_dir, sanctum_scripts)

    # Copy and substitute template files
    for template_name in TEMPLATE_FILES:
        template_path = assets_dir / template_name
        if not template_path.exists():
            continue

        output_name = template_name.replace("-template", "").upper()
        output_name = output_name[:-3] + ".md"

        content = template_path.read_text()
        content = substitute_vars(content, variables)

        output_path = sanctum_path / output_name
        output_path.write_text(content)
        print(f"  Created {output_name}")

    # Auto-generate CAPABILITIES.md
    capabilities = discover_capabilities(references_dir, sanctum_refs_path)
    capabilities_content = generate_capabilities_md(capabilities, evolvable=EVOLVABLE)
    (sanctum_path / "CAPABILITIES.md").write_text(capabilities_content)
    print(f"  Created CAPABILITIES.md")

    # Scaffold shared memory
    scaffold_shared_memory(project_root, variables, assets_dir)

    print()
    print("First Breath scaffolding complete.")
    print(f"Sanctum: {sanctum_path}")


if __name__ == "__main__":
    main()
