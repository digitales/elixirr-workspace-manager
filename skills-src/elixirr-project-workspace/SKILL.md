---
name: elixirr-project-workspace
description: Create and maintain an Elixirr project workspace scaffold under an existing client in ~/Documents/elixirr or a user-specified root. Use when the user asks to create a project, initialize project context, add project meetings folders, or prepare outputs and automations folders for a client project.
---

# Elixirr Project Workspace

Use this skill when the user wants a new project scaffold inside an Elixirr client workspace.

## Workflow

1. Confirm the client slug and project slug from the user request.
2. Use `scripts/new-project.sh <client-slug> <project-slug> [root-dir]`.
3. Default the root directory to `~/Documents/elixirr` unless the user specifies another location.
4. After running the script, report the created project path and point the user to `context/index.md` as the project context entrypoint.

## Notes

- The script creates `context/`, `meetings/`, `outputs/`, and `automations/`.
- The script creates `working-memory/`, `manual-exports/`, and communication output folders too.
- Agent-specific outputs live under `outputs/codex`, `outputs/claude`, and `outputs/other-agents`.
- Project-specific meeting notes belong under `projects/<project>/meetings/`.

## Resources

- Script: `scripts/new-project.sh`
- Templates: `templates/`
