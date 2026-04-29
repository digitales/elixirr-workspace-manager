---
name: elixirr-memory-bootstrap
description: Bootstrap Elixirr project memory from existing history. Use when a client or project already has substantial Slack, Teams, meeting, automation, or document history and the user wants to create an initial `working-memory/current.md` baseline without replaying every raw source in full.
---

# Elixirr Memory Bootstrap

Use this skill when the user is bringing an existing client or project into the Elixirr v2 setup and needs an initial working-memory baseline.

## Goal

Create a useful starting point for:

- `context/`
- `outputs/slack/`
- `outputs/teams/`
- `outputs/automations/`
- `working-memory/current.md`

without requiring the full source history to be copied into working memory.

## Inputs

Gather or infer:

- client slug
- project slug
- the most important historical sources, such as:
  - Slack exports or summaries
  - Teams exports or summaries
  - meeting notes
  - automation outputs
  - project docs or status notes
- the time window to prioritize, if relevant

Ask a short follow-up only when the client, project, or bootstrap scope is unclear.

## Bootstrap Model

Do not treat bootstrap the same as day-to-day refresh.

For bootstrap:

- raw history may be very large
- summarize in chunks
- create intermediate summaries where helpful
- produce one clear current-state baseline

For ongoing refresh:

- work from the latest processed summaries
- keep `working-memory/current.md` current and concise

## Workflow

1. Read the stable project context first.
2. Identify the highest-value historical sources.
3. If the history is large, summarize by period, channel, or topic rather than by full transcript.
4. Extract:
 - current focus
 - active priorities
 - recent meaningful changes
 - open questions
 - risks and blockers
 - next actions
 - important recent signals
5. Create or update:
 - processed historical summaries in `outputs/slack/`, `outputs/teams/`, or `outputs/automations/` when needed
 - `working-memory/current.md` as the live baseline
6. Keep durable truths in `context/` only when they are clearly stable and still relevant.

## Chunking Guidance

When the source history is long, prefer chunking by:

- recent weeks or months
- major incidents
- release cycles
- stakeholder escalation threads
- major workstreams

Avoid replaying every message into working memory.

## Promotion Rules

- move raw source material into `manual-exports/` when needed for recordkeeping
- move summarized historical findings into `outputs/`
- move only the live, still-relevant state into `working-memory/current.md`
- move durable truths into `context/` sparingly

## Output

The result should usually include:

- an initial or refreshed `working-memory/current.md`
- optionally one or more historical summary files in `outputs/`
- a brief note about which time windows or channels were used to create the baseline
