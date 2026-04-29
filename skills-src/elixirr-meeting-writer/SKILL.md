---
name: elixirr-meeting-writer
description: Turn a meeting transcript or rough notes into a finished Elixirr meeting note. Use when the user wants a transcript stored in the correct client or project meeting folder and also wants the note drafted with Summary, Decisions, Action Items, Risks / Blockers, References, and Transcript sections.
---

# Elixirr Meeting Writer

Use this skill when the user wants an end-to-end meeting note from transcript to finished file.

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

Default to `recurring` for named series like standups, weekly check-ins, or leadership meetings.
Default to `ad-hoc` for one-off meetings without a standing series.
Default to `project` when a project slug is provided.

## Workflow

1. Determine the meeting scope and target path.
2. If needed, use `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh` to create the note and place the transcript.
3. Read the transcript carefully and draft the note in the standard Elixirr structure.
4. Update the note file so all structured sections are filled in and the transcript remains at the end.
5. If the evidence for a decision or owner is weak, keep it tentative or leave it in `Risks / Blockers`.

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

## Resources

- Companion helper: `elixirr-workspace-manager/scripts/capture-meeting-transcript.sh`
- Related skill: `elixirr-meeting-notes`
