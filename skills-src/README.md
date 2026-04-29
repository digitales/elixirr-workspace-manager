# Elixirr Skills Source

This folder is the git-tracked source of truth for the Elixirr Codex skills.

Installed runtime copies live in `~/.codex/skills/`, but the versions in this folder are the ones to edit, review, and commit.

## Purpose

These skills support an Elixirr workspace structure organized around:

- `shared/` for reusable prompts, templates, and reference material
- `clients/<client>/context/` for client-wide context
- `clients/<client>/meetings/` for client-wide meetings
- `clients/<client>/projects/<project>/context/` for project-specific context
- `clients/<client>/projects/<project>/outputs/` for generated outputs by agent
- `internal/` for non-client work

## Skills

### `elixirr-workspace-init`

Use this to create the top-level Elixirr workspace.

Primary use cases:

- first-time setup of `~/Documents/elixirr`
- creating `shared/`, `clients/`, and `internal/`
- bootstrapping the folder structure before any clients or projects exist

Key script:

- `elixirr-workspace-init/scripts/init-elixirr.sh`

### `elixirr-client-workspace`

Use this to create a new client scaffold.

Primary use cases:

- creating a new client folder
- creating client context files such as `index.md`, `people.md`, and `preferences.md`
- preparing client-wide `meetings/` and `projects/` folders

Key script:

- `elixirr-client-workspace/scripts/new-client.sh`

### `elixirr-project-workspace`

Use this to create a new project inside a client.

Primary use cases:

- creating project `context/`, `meetings/`, `outputs/`, and `automations/`
- starting a new delivery stream inside an existing client
- creating project-level files such as `project.md`, `decisions.md`, and `sources.md`

Key script:

- `elixirr-project-workspace/scripts/new-project.sh`

### `elixirr-workspace-manager`

Use this as the main operational skill for workspace scaffolding and meeting note setup.

Primary use cases:

- initializing the top-level workspace
- creating a new client or project
- creating an empty meeting note in the right location
- capturing a transcript into the right meeting note file

Key scripts:

- `elixirr-workspace-manager/scripts/init-elixirr.sh`
- `elixirr-workspace-manager/scripts/new-client.sh`
- `elixirr-workspace-manager/scripts/new-project.sh`
- `elixirr-workspace-manager/scripts/create-meeting-note.sh`
- `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh`

### `elixirr-meeting-notes`

Use this for structured meeting-note formatting and updates.

Primary use cases:

- taking a transcript or rough notes and turning them into the Elixirr meeting-note format
- updating an existing note without changing the workspace structure
- keeping the note aligned to the shared meeting template

Typical output sections:

- `Summary`
- `Decisions`
- `Action Items`
- `Risks / Blockers`
- `References`
- `Transcript`

### `elixirr-meeting-writer`

Use this for the end-to-end workflow from transcript to finished note.

Primary use cases:

- saving a transcript into the correct client or project meeting path
- drafting the structured meeting sections from the transcript
- producing a finished note file rather than only a chat summary

This skill works especially well after `elixirr-workspace-manager` has created the meeting note shell or captured the transcript.

## Meeting Paths

The skills use these standard destinations:

- Client recurring meeting:
  `clients/<client>/meetings/recurring/<meeting-name>/YYYY-MM-DD.md`
- Client ad hoc meeting:
  `clients/<client>/meetings/ad-hoc/YYYY-MM-DD-<meeting-topic>.md`
- Project meeting:
  `clients/<client>/projects/<project>/meetings/<meeting-name>/YYYY-MM-DD.md`

## Shared Meeting Format

The meeting-oriented skills are aligned around this structure:

```md
# Meeting

Client:
Project:
Meeting:
Date:
Attendees:
Tags:

## Summary

## Decisions

## Action Items

## Risks / Blockers

## References

## Transcript
```

## Recommended Workflow

For general workspace setup:

1. Run the workspace init flow.
2. Create a client.
3. Create one or more projects inside that client.

For meeting capture:

1. Create the meeting note shell with `create-meeting-note.sh`, or use `capture-meeting-transcript.sh` if you already have a transcript.
2. Use `elixirr-meeting-writer` when you want a finished note drafted from the transcript.
3. Use `elixirr-meeting-notes` for lighter formatting or updates to an existing note.

## Git Workflow

Recommended source-of-truth model:

- edit skills here under `skills-src/`
- commit these files to git
- copy updated skill folders into `~/.codex/skills/` when you want to refresh the installed versions

That keeps the versioned source separate from the runtime installation.
