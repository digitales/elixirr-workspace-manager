---
name: elixirr-automation-output-publisher
description: Publish processed automation output files from a writable staging directory into an Elixirr client or project `outputs/automations/` folder. Use when an automation can write only inside a repo or worktree and the result then needs to be copied into a client memory pipeline directory.
---

# Elixirr Automation Output Publisher

Use this skill when an automation produces a processed report in one workspace and that file needs to be copied into an Elixirr `outputs/automations/` directory for later memory refresh.

## Goal

Copy the latest matching processed automation file from a source directory into a destination directory without duplicating or overwriting an existing dated output unnecessarily.

## Inputs

Gather or infer:

- source directory
- destination directory
- filename match rule
- whether to select only the latest matching file or copy all matches
- whether an existing destination file with the same name should cause a skip

Ask a short follow-up only when the source or destination cannot be inferred safely.

## Recommended Directory Pattern

Use this skill with:

- a repo-local staging directory such as `.codex-automation/`
- a client or project output directory such as `outputs/automations/<source-name>/`

Examples:

- source: `/path/to/project/.codex-automation`
- destination: `/path/to/elixirr-workspace/clients/client-name/outputs/automations/automation-name`

## Selection Rules

- Prefer processed markdown files over raw logs or transient files.
- Use a filename glob when the outputs are dated, for example `daily-bug-scan-*.md`.
- Default to copying only the latest matching file unless the user asks for a batch backfill.
- Preserve the original filename in the destination.

## Publish Rules

1. Confirm the source directory exists.
2. Create the destination directory if needed.
3. Find matching source files.
4. Select the latest match by modification time unless a different rule is requested.
5. If the selected filename already exists in the destination, skip without rewriting it.
6. Otherwise copy the file into the destination.
7. Return a short note describing what was copied or why nothing changed.

## Script Usage

Prefer the bundled helper script for deterministic runs:

```bash
python3 scripts/publish_automation_output.py \
  --source-dir /path/to/source \
  --dest-dir /path/to/destination \
  --pattern 'daily-bug-scan-*.md'
```

Optional flags:

- `--copy-all` to copy every matching file instead of only the latest
- `--overwrite` to replace an existing destination file with the same name

## Shared Sync

For a stable multi-repo sync into Elixirr client folders, use:

```bash
python3 scripts/sync_automation_outputs.py \
  --mapping repo-name /path/to/repo/outputs/automations/repo-name /path/to/client/outputs/automations/repo-name
```

Repeat `--mapping` for each repo you want to sync. Each mapping is:

- `NAME SOURCE DESTINATION`

Do not commit client-specific mappings into the skill source or repo automation templates.

Keep real mappings in one of these local-only places instead:

- the installed automation prompt under `<CODEX_HOME>/automations/elixirr-output-sync/automation.toml`
- a private local file passed with `--config /path/to/private-sync-mappings.json`

The preferred automation setup is to include the mappings directly in the local automation prompt or command.

Each shared sync should point its code repository at its own destination subfolder under:

- `clients/<client>/outputs/automations/<repo-name>/`

## Output

The result should be:

- the copied file or files in the destination directory
- a short report stating the source, destination, matched files, and whether anything was skipped
