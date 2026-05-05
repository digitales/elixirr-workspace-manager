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
- For a new client communication channel workspace, use `scripts/create-channel-workspace.sh --client <client-slug> --platform slack|teams --channel <channel-name> [--root <root-dir>]`
- For a new recurring automation output shell, use `scripts/create-automation-output.sh --client <client-slug> --project <project-slug> --automation <automation-name> --date <YYYY-MM-DD|YYYY-Www> [--root <root-dir>]`
- For a new meeting note shell, use `scripts/create-meeting-note.sh --client <client-slug> --meeting <meeting-name> --date YYYY-MM-DD [--project <project-slug>] [--scope recurring|adhoc|project] [--root <root-dir>]`
- For a note plus transcript capture in one step, use `scripts/capture-meeting-transcript.sh --client <client-slug> --meeting <meeting-name> --date YYYY-MM-DD [--project <project-slug>] [--scope recurring|adhoc|project] [--root <root-dir>] [--transcript-file <path>]`
- For archiving a processed raw communication export, use `scripts/archive-manual-export.sh <manual-export-file>`
- For raw meeting drop-zone discovery, use `scripts/scan-raw-meetings-dropzone.sh [--root <root-dir>] [--dropzone <raw-meetings-dir>]`
- For archiving a processed raw meeting transcript, use `scripts/archive-raw-meeting-transcript.sh <source-file> [--root <root-dir>] [--dropzone <raw-meetings-dir>]`

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

For raw meeting drop-zone support:

1. Use `scan-raw-meetings-dropzone.sh` to ensure `~/Documents/elixirr/raw-meetings` exists and to list unarchived markdown transcripts.
2. Treat files in `raw-meetings/<client>/` as client-wide meeting sources.
3. For root-level files, infer the client from the longest matching client slug in `clients/`.
4. Route unmatched files to `internal/meetings/`.
5. After successful note creation and summarization, archive the raw file with `archive-raw-meeting-transcript.sh`.

For channel setup:

1. Use `create-channel-workspace.sh` when a client Slack or Teams channel needs a durable home.
2. The helper creates `context.md`, `manual-exports/`, and `outputs/` under the client channel path.

For recurring automation outputs:

1. Use `create-automation-output.sh` when a project needs a dated shell for a known automation.
2. The helper selects the best matching template for standups, bug scans, issue triage, progression maps, and weekly summaries.

## Structure Rules

- Client-wide context lives under `clients/<client>/context/`
- Client-wide working memory lives under `clients/<client>/working-memory/`
- Client-wide automation outputs live under `clients/<client>/outputs/automations/`
- Client-wide Slack mappings and channel outputs live under `clients/<client>/slack/`
- Client-wide Teams mappings and channel outputs live under `clients/<client>/teams/`
- Client channel raw exports should usually live under `clients/<client>/slack/channels/<channel>/manual-exports/` or `clients/<client>/teams/channels/<channel>/manual-exports/`
- Processed raw communication exports should be moved into the sibling `archive/` folder so they are not reprocessed
- Raw meeting transcripts should arrive in `raw-meetings/` and move into `raw-meetings/archive/` only after successful note creation
- Client-wide meetings live under `clients/<client>/meetings/`
- Project-specific context lives under `clients/<client>/projects/<project>/context/`
- Project working memory lives under `clients/<client>/projects/<project>/working-memory/`
- Project outputs live under `clients/<client>/projects/<project>/outputs/`
- Manual source exports should usually live under `clients/<client>/projects/<project>/manual-exports/`
- Agent-specific outputs live under `outputs/codex`, `outputs/claude`, and `outputs/other-agents`
- Automation outputs should usually live under `outputs/automations/<automation-name>/`
- Project Slack summaries should usually live under `outputs/slack/<channel-name>/`
- Project Teams summaries should usually live under `outputs/teams/<channel-name>/`
- Project automation templates should usually be created under `outputs/automations/<automation-name>/`
- Meeting templates in this skill should match the structure used by `elixirr-meeting-notes`:
  `Summary`, `Decisions`, `Action Items`, `Risks / Blockers`, `References`, and `Transcript`

## Resources

- Scripts: `scripts/`
- Templates: `templates/`
