---
name: elixirr-memory-refresh
description: Refresh Elixirr working memory from recent meetings, automation outputs, Slack summaries, Teams summaries, and relevant manual exports. Use when the user wants a client-level or project-level `working-memory/current.md` updated to reflect the latest promoted signals.
---

# Elixirr Memory Refresh

Use this skill when the user wants live client-level or project-level memory refreshed from recent signals.

## Inputs

Gather or infer:

- client slug
- project slug when project-scoped
- target working-memory file, usually `working-memory/current.md`
- the most relevant recent sources from:
  - meetings
  - automation outputs
  - Slack summaries
  - Teams summaries
  - manual exports only when they contain signal not yet summarized

Ask a short follow-up only when the client or project scope cannot be inferred safely.

## Promotion Model

Work from the outside in:

- `manual-exports/` = raw source material, ideally normalized before refresh
- `outputs/slack/`, `outputs/teams/`, and `outputs/automations/` = processed summaries
- `meetings/` = structured records of discussion and decisions
- `working-memory/current.md` = promoted live state
- `context/` = durable truth that should change rarely

Only promote items that still matter now.

## Workflow

1. Read `context/index.md` and the current `working-memory/current.md`.
2. If recent Slack or Teams material is still raw in `manual-exports/`, prefer `elixirr-comms-normalizer` first so processed summaries exist in `outputs/slack/` or `outputs/teams/`.
3. Review the latest relevant processed source files.
4. Only fall back to raw `manual-exports/` when a needed signal has not yet been normalized.
5. Identify what should be promoted into:
 - `Current Focus`
 - `Active Priorities`
 - `Recent Changes`
 - `Open Questions`
 - `Risks / Blockers`
 - `Next Actions`
 - `Latest Signals`
 - `Source Notes`
6. Rewrite `working-memory/current.md` so it reflects the current state, not the entire history.
7. Preserve durable decisions in `context/decisions.md` only when the user asks or when that move is clearly warranted.

For client-level scope:

- use `clients/<client>/working-memory/current.md`
- use client meetings, client automation outputs, and client channel summaries

For project-level scope:

- use `clients/<client>/projects/<project>/working-memory/current.md`
- use project meetings, project automation outputs, and project communication summaries

## Promotion Rules

- Standup summaries usually update `Recent Changes`, `Next Actions`, `Risks / Blockers`.
- Bug scans usually update `Risks / Blockers`, `Latest Signals`.
- Issue triage usually updates `Active Priorities`, `Open Questions`, `Next Actions`.
- Weekly summaries usually update `Current Focus`, `Active Priorities`, `Recent Changes`.
- Slack and Teams summaries usually update `Latest Signals`, `Open Questions`, and sometimes `Risks / Blockers`.
- Meeting notes usually update `Recent Changes`, `Next Actions`, and confirmed decisions or blockers.

## Writing Rules

- Keep the file concise and current.
- Remove stale priorities when they are no longer active.
- Prefer concrete wording over generic summaries.
- Do not copy large chunks of raw transcript or chat export into working memory.
- Use `Source Notes` to reference where the latest signal came from.

## Relationship To Other Skills

- Use `elixirr-comms-normalizer` first when new Slack or Teams material is still raw.
- Use `elixirr-memory-bootstrap` when the task is creating an initial baseline from substantial history.
- Use this skill for ongoing updates after processed summaries already exist.

## Output

The result should be an updated `working-memory/current.md` file.
