# Elixirr Skills Source

This folder is the git-tracked source of truth for the Elixirr Codex skills.

Installed runtime copies live in `~/.codex/skills/`, but the versions in this folder are the ones to edit, review, and commit.

## Changes So Far

The Elixirr skill set has been extended from a basic client/project scaffold into a broader operational workspace model.

Current capabilities added so far:

- top-level Elixirr workspace initialization
- client scaffolding with reusable client context
- project scaffolding with context, meetings, outputs, and automations folders
- project `working-memory/` scaffolding for live operational memory
- client Slack scaffolding with `channel-map.md`
- client Teams scaffolding with `channel-map.md`
- project output folders for `automations/`, `slack/`, and `teams/`
- project `manual-exports/` folders for raw Slack and Teams exports
- client channel workspaces with `context.md`, `manual-exports/`, and `outputs/`
- meeting note scaffolding with a shared standard note format
- transcript capture helpers for creating a meeting note and inserting transcript content
- end-to-end meeting writing skill for turning pasted transcripts into finished saved notes
- recurring automation output shells for standups, bug scans, triage, progression maps, and weekly summaries
- working-memory refresh skill for promoting important signals into live project memory
- working-memory bootstrap skill for bringing legacy project history into the v2 model
- follow-up communication skill for Slack, Teams, email, and task-list outputs

The current operating model is:

- `context/` = durable reference truth
- `working-memory/` = live operational state
- `meetings/` = structured meeting records
- `outputs/` = processed automation or communication summaries
- `manual-exports/` = raw copied/exported source material

Installed runtime skill copies have also been refreshed in `~/.codex/skills/` so the working scaffold matches the git-tracked source in this folder.

## Recommended Next Steps

- add a memory-refresh skill that updates `working-memory/current.md` from meetings, automation outputs, Slack summaries, and Teams summaries
- add client-level `manual-exports/` support under `clients/<client>/slack/channels/<channel>/` and `clients/<client>/teams/channels/<channel>/`
- add templates or helpers for recurring automation outputs such as standup summaries, bug scans, and weekly engineering summaries
- add communication follow-up skills that turn meeting notes into Slack messages, Teams messages, emails, or task lists
- add promotion rules so important signals can move cleanly from raw exports to processed outputs and then into working memory

## Purpose

These skills support an Elixirr workspace structure organized around:

- `shared/` for reusable prompts, templates, and reference material
- `clients/<client>/context/` for client-wide context
- `clients/<client>/slack/` for channel mappings and client-level Slack outputs
- `clients/<client>/teams/` for channel mappings and client-level Teams outputs
- `clients/<client>/meetings/` for client-wide meetings
- `clients/<client>/projects/<project>/context/` for project-specific context
- `clients/<client>/projects/<project>/working-memory/` for live project memory
- `clients/<client>/projects/<project>/outputs/` for generated outputs by agent
- `clients/<client>/projects/<project>/outputs/communications/` for drafted follow-up messages and task outputs
- `clients/<client>/projects/<project>/manual-exports/` for copied or exported raw source material
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
- creating a client Slack map at `slack/channel-map.md`
- creating a client Teams map at `teams/channel-map.md`
- preparing client-wide `meetings/` and `projects/` folders

Key script:

- `elixirr-client-workspace/scripts/new-client.sh`

### `elixirr-project-workspace`

Use this to create a new project inside a client.

Primary use cases:

- creating project `context/`, `meetings/`, `outputs/`, and `automations/`
- creating project `working-memory/` files
- creating `outputs/automations/` and `outputs/slack/`
- creating `outputs/teams/`
- creating `manual-exports/slack/` and `manual-exports/teams/`
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
- creating working-memory, Slack, Teams, and manual-export scaffolding as part of client/project setup
- creating client channel workspaces with manual exports and processed outputs
- creating recurring automation output shells from templates

Key scripts:

- `elixirr-workspace-manager/scripts/init-elixirr.sh`
- `elixirr-workspace-manager/scripts/new-client.sh`
- `elixirr-workspace-manager/scripts/new-project.sh`
- `elixirr-workspace-manager/scripts/create-channel-workspace.sh`
- `elixirr-workspace-manager/scripts/create-automation-output.sh`
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
- acting as the main "paste transcript here" skill for meeting capture

This skill works especially well after `elixirr-workspace-manager` has created the meeting note shell or captured the transcript.

Follow-up question behavior:

- yes, this skill should ask short follow-up questions when filing details are missing
- typical examples are client, whether the meeting is client-wide or project-specific, project name, or meeting date
- it should avoid long questionnaires and only ask what is needed to save the note correctly

### `elixirr-memory-refresh`

Use this to refresh `working-memory/current.md` from the latest project signals.

Primary use cases:

- promoting important signals from meetings into live working memory
- rolling up automation outputs into current project state
- incorporating relevant Slack and Teams summaries
- using manual exports only when they contain signal not yet summarized elsewhere

### `elixirr-memory-bootstrap`

Use this to create an initial working-memory baseline for an existing project with substantial history.

Primary use cases:

- bringing an older client or project into the Elixirr v2 structure
- condensing long Slack or Teams history into a usable baseline
- producing historical summary files before creating `working-memory/current.md`
- creating a current-state snapshot without replaying every raw message

### `elixirr-follow-up-comms`

Use this to turn a meeting note into an outbound communication or task artifact.

Primary use cases:

- drafting a Slack follow-up from a meeting note
- drafting a Teams follow-up from a meeting note
- drafting an email recap from a meeting note
- turning a meeting note into a task list

## Meeting Paths

The skills use these standard destinations:

- Client recurring meeting:
  `clients/<client>/meetings/recurring/<meeting-name>/YYYY-MM-DD.md`
- Client ad hoc meeting:
  `clients/<client>/meetings/ad-hoc/YYYY-MM-DD-<meeting-topic>.md`
- Project meeting:
  `clients/<client>/projects/<project>/meetings/<meeting-name>/YYYY-MM-DD.md`

## Working Memory

Projects now include:

- `working-memory/current.md`
- `working-memory/backlog.md`
- `working-memory/risks.md`
- `working-memory/timeline.md`

Recommended role of each file:

- `current.md` = live project state and what matters now
- `backlog.md` = open actions, deferred items, waiting items
- `risks.md` = active risks, blockers, mitigations
- `timeline.md` = recent milestones and upcoming dates

Recommended agent loading order:

1. `context/index.md`
2. `working-memory/current.md`
3. latest relevant meeting note
4. latest relevant automation output
5. latest relevant Slack or Teams summary

## Slack

Clients now include:

- `slack/channel-map.md`
- `slack/channels/`

Projects now include:

- `outputs/slack/`

Recommended use:

- keep channel routing in `clients/<client>/slack/channel-map.md`
- use `create-channel-workspace.sh` to create `context.md`, `manual-exports/`, and `outputs/` for individual client channels
- store copied or exported raw Slack material under `projects/<project>/manual-exports/slack/`
- store client-level Slack summaries under `clients/<client>/slack/channels/<channel>/outputs/`
- store project-relevant Slack summaries under `projects/<project>/outputs/slack/<channel>/`
- promote important Slack signals into `working-memory/current.md`

Example `channel-map.md` shape:

```md
# Slack Channel Map

- `#dezeen-engineering` -> client: dezeen, project: dezeen-com
- `#dezeen-editorial-tech` -> client: dezeen, client-level
```

## Automation Outputs

Recommended automation output locations:

- `outputs/automations/standup-summary/YYYY-MM-DD.md`
- `outputs/automations/daily-bug-scan/YYYY-MM-DD.md`
- `outputs/automations/issue-triage/YYYY-MM-DD.md`
- `outputs/automations/skill-progression-map/YYYY-Www.md`
- `outputs/automations/weekly-engineering-summary/YYYY-Www.md`

Recommended promotion rules:

- standup summaries update `Recent Changes`, `Next Actions`, `Risks / Blockers`
- bug scans update `Risks / Blockers`, `Latest Signals`
- issue triage updates `Active Priorities`, `Open Questions`, `Next Actions`
- weekly summaries refresh `Current Focus`, `Active Priorities`, `Recent Changes`
- Slack monitors update `Latest Signals`, `Open Questions`, and `Risks / Blockers`
- Teams monitors update `Latest Signals`, `Open Questions`, and `Risks / Blockers`

Template helpers now exist for:

- `standup-summary`
- `daily-bug-scan`
- `issue-triage`
- `skill-progression-map`
- `weekly-engineering-summary`

## Teams

Clients now include:

- `teams/channel-map.md`
- `teams/channels/`

Projects now include:

- `outputs/teams/`

Recommended use:

- keep Teams routing in `clients/<client>/teams/channel-map.md`
- use `create-channel-workspace.sh` to create `context.md`, `manual-exports/`, and `outputs/` for individual client channels
- store copied or exported raw Teams material under `projects/<project>/manual-exports/teams/`
- store client-level Teams summaries under `clients/<client>/teams/channels/<channel>/outputs/`
- store project-relevant Teams summaries under `projects/<project>/outputs/teams/<channel>/`
- promote important Teams signals into `working-memory/current.md`

Example `teams/channel-map.md` shape:

```md
# Teams Channel Map

- `Engineering/Platform` -> client: dezeen, project: dezeen-com
- `Editorial/General` -> client: dezeen, client-level
```

## Manual Exports

Use `manual-exports/` for raw material copied out of Slack, Teams, or other systems before it has been summarized or normalized.

Recommended locations:

- project Slack export:
  `clients/<client>/projects/<project>/manual-exports/slack/YYYY-MM-DD-<channel>.md`
- project Teams export:
  `clients/<client>/projects/<project>/manual-exports/teams/YYYY-MM-DD-<channel>.md`
- client Slack channel export:
  `clients/<client>/slack/channels/<channel>/manual-exports/YYYY-MM-DD.md`
- client Teams channel export:
  `clients/<client>/teams/channels/<channel>/manual-exports/YYYY-MM-DD.md`

Manual export templates:

- Slack:
  `elixirr-workspace-manager/templates/slack-manual-export.md`
- Teams:
  `elixirr-workspace-manager/templates/teams-manual-export.md`

Recommended rule:

- `manual-exports/` = raw copied/exported source material
- `outputs/slack/` and `outputs/teams/` = processed daily summaries or monitor outputs
- `working-memory/current.md` = promoted signals that matter now

Suggested manual capture flow:

1. copy the relevant Slack or Teams conversation
2. paste it into the matching manual export template
3. save it under the correct `manual-exports/` folder
4. create or update a processed summary under `outputs/slack/` or `outputs/teams/`
5. use `elixirr-memory-refresh` to promote the important signals into `working-memory/current.md`

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

For memory refresh:

1. Review the latest meetings, automation outputs, and communication summaries.
2. Use `elixirr-memory-refresh` to update `working-memory/current.md`.
3. Promote only the signals that still matter now.

For legacy project onboarding:

1. scaffold the client and project into the v2 structure
2. place large historical source material into `manual-exports/` or reuse existing notes
3. use `elixirr-memory-bootstrap` to create one or more historical summaries and an initial `working-memory/current.md`
4. then switch to `elixirr-memory-refresh` for normal ongoing updates

For follow-up communication:

1. Start from a saved meeting note.
2. Use `elixirr-follow-up-comms` to draft a Slack message, Teams message, email, or task list.
3. Save the output under `outputs/communications/` if needed.

## Git Workflow

Recommended source-of-truth model:

- edit skills here under `skills-src/`
- commit these files to git
- copy updated skill folders into `~/.codex/skills/` when you want to refresh the installed versions

That keeps the versioned source separate from the runtime installation.
