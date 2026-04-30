# Elixirr Automation Spec

This document defines the recommended automation pattern for keeping Elixirr project working memory up to date.

## Goal

Create a consistent event pipeline where:

- raw communications are normalized first
- processed signals are stored in project outputs
- project working memory is refreshed from processed sources

## Core Rule

Do not refresh working memory directly from `manual-exports/`.

Always use this sequence:

1. raw source enters `manual-exports/`
2. `elixirr-comms-normalizer` processes it into `outputs/slack/` or `outputs/teams/`
3. `elixirr-memory-refresh` updates `working-memory/current.md`

## Trigger Directories

### Raw communication triggers

These should trigger `elixirr-comms-normalizer`:

- `clients/<client>/projects/<project>/manual-exports/slack/`
- `clients/<client>/projects/<project>/manual-exports/teams/`
- `clients/<client>/slack/channels/<channel>/manual-exports/`
- `clients/<client>/teams/channels/<channel>/manual-exports/`

Exclude:

- any `archive/` directory

### Processed signal triggers

These should trigger `elixirr-memory-refresh`:

- `clients/<client>/projects/<project>/meetings/`
- `clients/<client>/projects/<project>/outputs/automations/`
- `clients/<client>/projects/<project>/outputs/slack/`
- `clients/<client>/projects/<project>/outputs/teams/`

## Automation Roles

### 1. Raw Comms Normalizer

Purpose:

- detect new raw Slack or Teams files
- normalize them into processed summaries
- archive the raw files after successful processing

Skill:

- `elixirr-comms-normalizer`

Input:

- one project-level or client-channel-level `manual-exports/` directory

Output:

- processed summary in `outputs/slack/` or `outputs/teams/`
- raw source moved into `archive/`

### 2. Working Memory Refresh

Purpose:

- update `working-memory/current.md` from the latest processed project signals

Skill:

- `elixirr-memory-refresh`

Input:

- latest meeting notes
- latest automation outputs
- latest processed Slack summaries
- latest processed Teams summaries

Output:

- updated `working-memory/current.md`

## Event Pipelines

### Raw Slack or Teams export

```text
manual-exports/slack or manual-exports/teams
-> elixirr-comms-normalizer
-> outputs/slack or outputs/teams
-> elixirr-memory-refresh
-> working-memory/current.md
```

### Meeting note

```text
meetings/
-> elixirr-memory-refresh
-> working-memory/current.md
```

### Automation output

```text
outputs/automations/
-> elixirr-memory-refresh
-> working-memory/current.md
```

## Recommended Debounce Rules

To avoid repeated refreshes when several files arrive close together:

- debounce memory refresh by 1 to 5 minutes
- normalize raw communications immediately or on a short delay
- run one refresh after normalization completes

## Recommended Scope

Use project scope by default:

- one project’s `manual-exports/`
- one project’s `meetings/`
- one project’s `outputs/`

Use client-level channel scope only for:

- client-wide Slack channels
- client-wide Teams channels

## Recommended Output Conventions

### Raw source

- `manual-exports/slack/YYYY-MM-DD-<channel>.md`
- `manual-exports/slack/YYYY-MM-export.json`
- `manual-exports/teams/YYYY-MM-DD-<channel>.md`

### Processed summaries

- `outputs/slack/<channel>/YYYY-MM-DD.md`
- `outputs/teams/<channel>/YYYY-MM-DD.md`
- `outputs/automations/<automation-name>/YYYY-MM-DD.md`
- `outputs/automations/<automation-name>/YYYY-Www.md`

### Working memory

- `working-memory/current.md`

## Promotion Rules

Promote only current, meaningful signals:

- blockers
- risks
- changed priorities
- stakeholder asks
- decisions
- unresolved questions
- next actions

Do not promote:

- routine chat noise
- long raw transcripts
- stale historical items that no longer matter

## Recommended Order For Legacy Projects

1. scaffold the project into v2
2. place raw Slack or Teams history in `manual-exports/`
3. run `elixirr-comms-normalizer`
4. run `elixirr-memory-bootstrap`
5. switch to `elixirr-memory-refresh` for ongoing updates
