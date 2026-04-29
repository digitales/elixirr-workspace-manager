---
name: elixirr-memory-refresh
description: Refresh a project's Elixirr working memory from recent meetings, automation outputs, Slack summaries, Teams summaries, and relevant manual exports. Use when the user wants `working-memory/current.md` updated to reflect the latest project state and promoted signals.
---

# Elixirr Memory Refresh

Use this skill when the user wants live project memory refreshed from recent project signals.

## Inputs

Gather or infer:

- client slug
- project slug
- target working-memory file, usually `working-memory/current.md`
- the most relevant recent sources from:
  - meetings
  - automation outputs
  - Slack summaries
  - Teams summaries
  - manual exports when they contain signal not yet summarized

Ask a short follow-up only when the client or project cannot be inferred safely.

## Promotion Model

Work from the outside in:

- `manual-exports/` = raw source material
- `outputs/slack/`, `outputs/teams/`, and `outputs/automations/` = processed summaries
- `meetings/` = structured records of discussion and decisions
- `working-memory/current.md` = promoted live state
- `context/` = durable truth that should change rarely

Only promote items that still matter now.

## Workflow

1. Read `context/index.md` and the current `working-memory/current.md`.
2. Review the latest relevant source files.
3. Identify what should be promoted into:
 - `Current Focus`
 - `Active Priorities`
 - `Recent Changes`
 - `Open Questions`
 - `Risks / Blockers`
 - `Next Actions`
 - `Latest Signals`
 - `Source Notes`
4. Rewrite `working-memory/current.md` so it reflects the current state, not the entire history.
5. Preserve durable decisions in `context/decisions.md` only when the user asks or when that move is clearly warranted.

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

## Output

The result should be an updated `working-memory/current.md` file.
