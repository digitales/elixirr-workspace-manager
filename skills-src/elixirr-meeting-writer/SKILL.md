---
name: elixirr-meeting-writer
description: Turn a meeting transcript or rough notes into a finished Elixirr meeting note. Use when the user wants a transcript stored in the correct client or project meeting folder and also wants the note drafted with Summary, Decisions, Action Items, Risks / Blockers, References, and Transcript sections.
---

# Elixirr Meeting Writer

Use this skill when the user wants an end-to-end meeting note from transcript to finished file.

This skill should behave like a paste-driven workflow:

- the user pastes the transcript into the agent
- the skill determines where the note belongs
- the skill creates or updates the note file directly
- the skill writes the structured sections and preserves the transcript
- the result should be a saved note, not only a conversational summary

## Required Inputs

Gather or infer:

- client slug
- whether the meeting is client-wide or project-specific
- project slug if project-specific
- meeting name or series
- meeting date
- transcript or rough notes

If one of these is missing, make the smallest reasonable assumption and state it in the response.

If a missing input would create a meaningful filing risk, ask a short follow-up question before writing the file.

Examples:

- "Which client is this for?"
- "Is this client-wide or for a specific project?"
- "What project should I file this under?"
- "What date should I use for this meeting?"

Prefer at most one or two concise follow-up questions. Only ask when the missing detail cannot be inferred safely from the transcript or recent context.

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
Default to `project` when a project slug is provided.
Treat `client: internal` as the special internal workspace, not as a client folder under `clients/`.

## Workflow

1. Determine the meeting scope and target path.
2. If client, project, or meeting date is unclear and cannot be inferred safely, ask a short follow-up question before filing the note.
3. If needed, use `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh` to create the note and place the transcript.
4. Read the transcript carefully and draft the note in the standard Elixirr structure.
5. Update the note file directly so all structured sections are filled in and the transcript remains at the end.
6. If the evidence for a decision or owner is weak, keep it tentative or leave it in `Risks / Blockers`.

## Standard Note Format

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

## Writing Rules

- `Summary` should be short, concrete, and oriented around why the meeting mattered.
- `Decisions` should contain only things that were actually agreed.
- `Action Items` should use one line per action and include an owner when supported by the transcript.
- `Risks / Blockers` should capture unresolved questions, disagreements, dependencies, and constraints.
- `References` should include any named documents, links, systems, or follow-up artifacts mentioned in the transcript.
- `Transcript` should preserve the raw transcript with only light cleanup.

## Output Expectations

The result should be a saved note file, not just a chat summary.

In the response:

- report the saved path
- mention any assumptions made
- call out missing owners or unresolved ambiguity if relevant

If a follow-up question was needed, ask it before writing. Once the needed filing detail is known, complete the note-writing workflow end to end.

## Resources

- Companion helper: `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh`
- Related skill: `elixirr-meeting-notes`
