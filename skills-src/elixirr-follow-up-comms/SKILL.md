---
name: elixirr-follow-up-comms
description: Turn Elixirr meeting notes into outbound follow-up communications or task lists. Use when the user wants a meeting note converted into a Slack message, Teams message, email draft, or action/task list while preserving the meeting's decisions, actions, and open questions.
---

# Elixirr Follow-Up Comms

Use this skill when the user wants a saved meeting note turned into a communication artifact or task-oriented output.

## Inputs

Gather or infer:

- the source meeting note path
- the desired output format:
  - Slack message
  - Teams message
  - email
  - task list
- the intended audience
- whether the output should be concise, formal, or action-oriented

Ask a short follow-up only when the output format or audience is unclear.

## Workflow

1. Read the meeting note.
2. Extract the meeting purpose, decisions, actions, blockers, and unresolved questions.
3. Choose the right output shape:
 - Slack or Teams: concise, scannable, action-led
 - email: slightly fuller narrative with clear asks
 - task list: explicit owners, actions, and due dates when known
4. Draft the output.
5. If the user wants it stored, save it under the project in `outputs/communications/`.

## Recommended Storage

- Slack drafts:
  `projects/<project>/outputs/communications/slack/YYYY-MM-DD-<topic>.md`
- Teams drafts:
  `projects/<project>/outputs/communications/teams/YYYY-MM-DD-<topic>.md`
- email drafts:
  `projects/<project>/outputs/communications/email/YYYY-MM-DD-<topic>.md`
- task lists:
  `projects/<project>/outputs/communications/tasks/YYYY-MM-DD-<topic>.md`

## Writing Rules

- Keep Slack and Teams drafts short and easy to scan.
- Keep email drafts clear, courteous, and explicit about decisions and asks.
- Keep task lists concrete and owner-based where evidence exists.
- Do not invent commitments, deadlines, or owners that are not supported by the note.

## Output

Default output is the drafted communication in chat.

If the user asks for it to be saved, write it into the recommended project path.
