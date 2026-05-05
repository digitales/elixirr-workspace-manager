---
name: elixirr-client-workspace
description: Create and maintain an Elixirr client workspace scaffold under the default local workspace root or a user-specified root. Use when the user asks to create a new client folder, initialize client context, set up client-wide meetings folders, or scaffold client structures for future automation and agent outputs.
---

# Elixirr Client Workspace

Use this skill when the user wants a new client scaffold in the Elixirr workspace.

## Workflow

1. Confirm the client slug from the user request.
2. Use `scripts/new-client.sh <client-slug> [root-dir]`.
3. Default the root directory to the local Elixirr workspace root unless the user specifies another location.
4. After running the script, report the created client path and point the user to `context/index.md` as the context entrypoint.

## Notes

- The script is idempotent for existing files: it creates missing folders and only fills in missing template files.
- Client-wide recurring meetings belong under `clients/<client>/meetings/recurring/`.
- Client-wide ad hoc meetings belong under `clients/<client>/meetings/ad-hoc/`.
- Client-wide live memory should live under `clients/<client>/working-memory/`.
- Client-wide automation outputs should live under `clients/<client>/outputs/automations/`.
- Client communication routing belongs under `clients/<client>/slack/` and `clients/<client>/teams/`.
- Individual client communication channels should have `context.md`, `manual-exports/`, and `outputs/`.

## Resources

- Script: `scripts/new-client.sh`
- Templates: `templates/`
