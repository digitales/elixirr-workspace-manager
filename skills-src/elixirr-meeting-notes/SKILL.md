---
name: elixirr-meeting-notes
description: Create or update Elixirr meeting notes from a meeting transcript or rough notes. Use when the user provides a transcript and wants it turned into structured meeting notes in the Elixirr client/project folder format, including summary, decisions, action items, risks, references, and a preserved transcript section.
---

# Elixirr Meeting Notes

Use this skill when the user wants a transcript or rough notes turned into a durable meeting note in the Elixirr workspace.

## Required Inputs

Gather or infer:

- client slug
- whether the meeting is client-wide or project-specific
- project slug if project-specific
- meeting name or series
- meeting date
- transcript or rough notes

If one of these is missing, make the smallest reasonable assumption and state it in the response.

## Destination Rules

- Client-wide recurring meetings:
  `clients/<client>/meetings/recurring/<meeting-name>/YYYY-MM-DD.md`
- Client-wide ad hoc meetings:
  `clients/<client>/meetings/ad-hoc/YYYY-MM-DD-<meeting-topic>.md`
- Project meetings:
  `clients/<client>/projects/<project>/meetings/<meeting-name>/YYYY-MM-DD.md`
- Internal recurring meetings:
  `internal/meetings/recurring/<meeting-name>/YYYY-MM-DD.md`
- Internal ad hoc meetings:
  `internal/meetings/ad-hoc/YYYY-MM-DD-<meeting-topic>.md`
- Internal project meetings:
  `internal/projects/<project>/meetings/<meeting-name>/YYYY-MM-DD.md`

Default to `recurring` for named series like standups, weekly check-ins, or leadership meetings.
Default to `ad-hoc` for one-off meetings without a standing series.
Default to `general` as the project meeting folder when no better meeting series name is provided.
Treat `client: internal` as the special internal workspace, not as a client folder under `clients/`.

## Workflow

1. Determine the correct meeting scope and target path.
2. If the note file does not exist yet, prefer creating it with `elixirr-workspace-manager/scripts/create-meeting-note.sh`.
3. If the user provides a raw transcript and wants a one-step bootstrap, prefer `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh`.
4. Write or update the note using the standard Elixirr meeting structure.
5. Preserve the transcript in a final `## Transcript` section unless the user asks for a cleaner summary-only note.
6. If a note for the same meeting date already exists, update it rather than creating a duplicate.

## Standard Note Format

Use this structure:

```md
# Meeting

Client: <client>
Project: <project or none>
Meeting: <meeting name>
Date: YYYY-MM-DD
Attendees:
Tags:

## Summary

## Decisions

## Action Items

## Risks / Blockers

## References

## Transcript
```

This should match the starter meeting templates used by `elixirr-workspace-manager`.

## Writing Rules

- Keep `## Summary` concise and decision-oriented.
- Only place confirmed decisions under `## Decisions`.
- Put unresolved items under `## Risks / Blockers` or mention them in `## Summary`.
- Include owners in `## Action Items` when the transcript supports them.
- Preserve the raw transcript with light cleanup only; do not rewrite it into something materially different.

## Resources

- Template: `templates/meeting-note.md`
- Companion helper: `elixirr-workspace-manager/scripts/create-meeting-note.sh`
- Combined helper: `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh`
