---
name: elixirr-raw-meeting-dropzone
description: Watch or batch-process the `raw-meetings/` drop zone under the local Elixirr workspace root, infer client-scoped meeting transcripts, and turn them into structured Elixirr meeting notes with the original raw files archived after success.
---

# Elixirr Raw Meeting Dropzone

Use this skill when the user wants a Codex automation or manual batch pass over raw meeting transcripts dropped into the `raw-meetings/` folder under the local Elixirr workspace root.

## Goal

Treat `raw-meetings/` as a landing zone for unfiled meeting transcripts.

For each unarchived markdown transcript:

1. ensure the drop-zone exists
2. infer the client, meeting name, and meeting date
3. create or update the correctly placed Elixirr meeting note
4. fill the note in the standard `elixirr-meeting-notes` format
5. archive the raw transcript only after the structured note is saved successfully

## Supported Input Shapes

- Root-level files such as:
  `raw-meetings/mastercard-weekly-check-in-2026-05-05.md`
- Client-folder files such as:
  `raw-meetings/mastercard/weekly-check-in-2026-05-05.md`

Only client-level raw folders are in scope here.
Do not treat nested project folders under `raw-meetings/` as a supported source shape.

## Inference Rules

Prefer the helper:

- `elixirr-workspace-manager/scripts/scan-raw-meetings-dropzone.sh`

The helper should be the source of truth for basic routing metadata.

Interpret results this way:

- `client_slug` comes from the parent folder when that folder matches a client under the local Elixirr workspace `clients/` directory
- otherwise, try to match the longest client slug prefix from the filename
- if no client match is found, route the note to `internal`
- `meeting_name` is the remaining filename slug after removing the client prefix and trailing date
- `date` should come from a trailing `YYYY-MM-DD` filename suffix when present
- if no date is present, accept the helper fallback and state that assumption in the response or automation summary

Default to client-wide recurring meetings unless the transcript clearly indicates it is an ad hoc one-off.

## Workflow

1. Run `elixirr-workspace-manager/scripts/scan-raw-meetings-dropzone.sh`.
2. If there are no queued transcripts, report that nothing needs processing.
3. For each queued file:
   - read the transcript
   - use `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh` to create the correctly placed note shell and insert the transcript
   - use `elixirr-meeting-notes` to fill the structured sections in the saved note
4. After the note is saved successfully, archive the raw transcript with:
   `elixirr-workspace-manager/scripts/archive-raw-meeting-transcript.sh <source-file>`
5. Leave the raw file in place if note creation, summarization, or archiving fails

## Output Rules

Create meeting notes using the normal client or internal paths from `elixirr-meeting-notes`.

Expected default destinations:

- matched client:
  `clients/<client>/meetings/recurring/<meeting-name>/YYYY-MM-DD.md`
- unmatched client:
  `internal/meetings/recurring/<meeting-name>/YYYY-MM-DD.md`

Archive processed raw files under:

- `raw-meetings/archive/...`

Preserve client subfolder structure inside the archive when archiving a nested file.

## Relationship To Other Skills

- Use `elixirr-meeting-notes` to draft the structured sections after the transcript is placed
- Use `elixirr-workspace-manager` for the helper scripts and note-shell creation
- Use `elixirr-meeting-writer` only when the user is pasting a transcript directly rather than using the drop zone

## Resources

- Queue helper: `elixirr-workspace-manager/scripts/scan-raw-meetings-dropzone.sh`
- Archive helper: `elixirr-workspace-manager/scripts/archive-raw-meeting-transcript.sh`
- Transcript capture helper: `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh`
- Formatting skill: `elixirr-meeting-notes`
