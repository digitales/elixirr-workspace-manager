---
name: elixirr-comms-normalizer
description: Normalize raw Slack and Teams communication exports into Elixirr output summaries. Use when the user has pasted markdown exports or Slack JSON exports in `manual-exports/` directories and wants them processed into `outputs/slack/` or `outputs/teams/`, with the original raw files archived so they are not reprocessed.
---

# Elixirr Comms Normalizer

Use this skill when the user wants raw communication material converted into durable Elixirr summaries.

## Goal

Process raw communication files from:

- project `manual-exports/slack/`
- project `manual-exports/teams/`
- client channel `manual-exports/`

and convert them into processed output summaries under:

- `outputs/slack/`
- `outputs/teams/`

After processing a raw file, archive it so the active manual-export directory only contains unprocessed source material.

## Inputs

Gather or infer:

- the workspace root
- the client and project scope, if the run is project-specific
- whether to process one directory or all communication manual-export directories under a client or project

Ask a short follow-up only when the processing scope is unclear.

## Source Rules

Process files found under:

- `manual-exports/slack/`
- `manual-exports/teams/`

Skip:

- any file already under an `archive/` directory
- directories that contain no source files

Supported source shapes:

- pasted markdown or text exports
- Slack JSON export files
- Teams markdown or text exports

## Output Rules

Create processed summaries under:

- project Slack:
  `projects/<project>/outputs/slack/<channel>/YYYY-MM-DD.md`
- project Teams:
  `projects/<project>/outputs/teams/<channel>/YYYY-MM-DD.md`
- client Slack channel:
  `slack/channels/<channel>/outputs/YYYY-MM-DD.md`
- client Teams channel:
  `teams/channels/<channel>/outputs/YYYY-MM-DD.md`

If a date is not obvious from the filename, infer it from file metadata or the conversation content and note that assumption.

## Normalization Workflow

1. Find unarchived files in the target `manual-exports/` directories.
2. Read each file and determine:
 - platform
 - channel
 - date or time window
 - whether it is raw markdown/text or JSON
3. Extract the signal:
 - major topics
 - blockers
 - risks
 - decisions
 - stakeholder asks
 - actions
 - deadlines or dependencies
4. Prefer the bundled helper script:
 - `scripts/normalize_client_exports.py`
 - run it when the user wants a batch pass across many client or project export folders
 - use it as the default path unless the user asks for a bespoke one-off normalization
5. Write a concise processed summary to the correct `outputs/` path.
6. Archive the raw source file after successful processing.

## Script Usage

The skill includes a Python helper for batch normalization:

```bash
python3 scripts/normalize_client_exports.py
```

Optional root override:

```bash
python3 scripts/normalize_client_exports.py --root /path/to/elixirr-workspace
```

The script should:

- scan for unarchived `.json`, `.md`, and `.txt` files under `clients/**/manual-exports/`
- create one processed summary per source file under `outputs/slack/` or `outputs/teams/`
- archive each source file only after the matching output file is written successfully
- skip `.DS_Store` files and anything already inside an `archive/` directory

## Summary Shape

Use a consistent output shape such as:

```md
# Communication Summary

Client:
Project:
Platform:
Channel:
Date:
Source File:

## Summary

## Key Signals

## Risks / Blockers

## Decisions

## Actions

## Stakeholder Requests

## Notes
```

## Archiving Rule

After a file has been processed successfully:

- move it into the sibling `archive/` directory
- keep the filename unchanged unless there is a collision

Use the helper:

- `elixirr-workspace-manager/scripts/archive-manual-export.sh`

Do not archive a source file if processing failed or the output summary was not created.

If the bundled Python helper is used, it should implement the same rule directly and mirror the helper shell script behavior for collisions.

## Relationship To Other Skills

- Use this skill before `elixirr-memory-bootstrap` when history is still raw.
- Use this skill before `elixirr-memory-refresh` when new Slack or Teams exports have not yet been summarized.
- Use `elixirr-memory-bootstrap` for legacy onboarding after historical summaries exist.
- Use `elixirr-memory-refresh` for ongoing updates after processed summaries exist.

## Output

The result should be:

- one processed summary file per raw source file or time window
- archived raw files in the matching `archive/` folder
- a short report of what was processed and where it was saved
