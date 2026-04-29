---
name: elixirr-workspace-manager
description: Manage an Elixirr workspace under ~/Documents/elixirr or a user-specified root. Use when the user asks to initialize the top-level Elixirr structure, create a new client workspace, or create a new project workspace inside a client. This skill owns the full scaffold workflow and includes all supporting bash scripts and templates.
---

# Elixirr Workspace Manager

Use this skill when the user wants to create or extend the Elixirr directory structure.

## Choose The Right Script

- For top-level setup, use `scripts/init-elixirr.sh [root-dir]`
- For a new client, use `scripts/new-client.sh <client-slug> [root-dir]`
- For a new project, use `scripts/new-project.sh <client-slug> <project-slug> [root-dir]`
- For a new meeting note shell, use `scripts/create-meeting-note.sh --client <client-slug> --meeting <meeting-name> --date YYYY-MM-DD [--project <project-slug>] [--scope recurring|adhoc|project] [--root <root-dir>]`
- For a note plus transcript capture in one step, use `scripts/capture-meeting-transcript.sh --client <client-slug> --meeting <meeting-name> --date YYYY-MM-DD [--project <project-slug>] [--scope recurring|adhoc|project] [--root <root-dir>] [--transcript-file <path>]`

Default the root directory to `~/Documents/elixirr` unless the user specifies another location.

## Workflow

1. Identify whether the user wants `init`, `client`, or `project` scaffolding.
2. Extract the needed slug values from the request.
3. Run the matching script.
4. Report the created path.
5. Point the user to the nearest `context/index.md` file as the context entrypoint.

For meeting-note setup:

1. Determine whether the note is client-wide recurring, client-wide ad hoc, or project-specific.
2. Use `create-meeting-note.sh` to create the correctly placed note file from the shared template.
3. Then use `elixirr-meeting-notes` to fill in the note from the transcript if the user supplied one.

For combined transcript capture:

1. Use `capture-meeting-transcript.sh` when the user already has the transcript content.
2. The helper creates the note if needed and writes the transcript into the `## Transcript` section.
3. Then use `elixirr-meeting-notes` to summarize and complete the structured sections if requested.

## Structure Rules

- Client-wide context lives under `clients/<client>/context/`
- Client-wide meetings live under `clients/<client>/meetings/`
- Project-specific context lives under `clients/<client>/projects/<project>/context/`
- Project outputs live under `clients/<client>/projects/<project>/outputs/`
- Agent-specific outputs live under `outputs/codex`, `outputs/claude`, and `outputs/other-agents`
- Meeting templates in this skill should match the structure used by `elixirr-meeting-notes`:
  `Summary`, `Decisions`, `Action Items`, `Risks / Blockers`, `References`, and `Transcript`

## Resources

- Scripts: `scripts/`
- Templates: `templates/`
