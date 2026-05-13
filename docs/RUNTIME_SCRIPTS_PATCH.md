# Runtime Scripts Patch for SA Framework

This patch adds a shell runtime layer to the BMAD-generated SA Framework.

The current framework is a BMAD module made of skills. These scripts add direct terminal commands for creating, validating, recreating and documenting sandboxes without requiring a BMAD executor.

## Install

From the root of `sa-framework-v0.2.0`:

```bash
cp -R /path/to/patch/bin .
cp -R /path/to/patch/blueprints .
chmod +x bin/*.sh
```

## Create a Dev Container sandbox

```bash
./bin/create-ai-sandbox.sh \
  --name sandbox-antigravity \
  --runtime devcontainer \
  --stack node-python \
  --security agent-safe
```

## Validate

```bash
./bin/validate-ai-sandbox.sh "$HOME/ai-sandboxes-runtime/sandbox-antigravity"
```

## Recreate

```bash
./bin/recreate-ai-sandbox.sh "$HOME/ai-sandboxes-runtime/sandbox-antigravity"
```

## Document

```bash
./bin/document-ai-sandbox.sh "$HOME/ai-sandboxes-runtime/sandbox-antigravity"
```
