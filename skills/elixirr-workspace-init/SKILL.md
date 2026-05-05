---
name: elixirr-workspace-init
description: Initialize the top-level Elixirr workspace under the default local workspace root or a user-specified root. Use when the user asks to set up the overall Elixirr directory structure with shared, clients, and internal sections before creating client or project scaffolds.
---

# Elixirr Workspace Init

Use this skill when the user wants the top-level Elixirr workspace created.

## Workflow

1. Use `scripts/init-elixirr.sh [root-dir]`.
2. Default the root directory to the local Elixirr workspace root unless the user specifies another location.
3. After running the script, report the initialized path and remind the user they can then create clients and projects.

## Resources

- Script: `scripts/init-elixirr.sh`
