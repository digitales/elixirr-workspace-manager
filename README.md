# Elixirr Workspace Scaffold

This folder contains small scripts and templates for creating an `elixirr` workspace that is organized by client and project.

## Scripts

- `scripts/init-elixirr.sh`: create the top-level workspace structure
- `scripts/new-client.sh <client-slug> [root-dir]`: create a new client scaffold
- `scripts/new-project.sh <client-slug> <project-slug> [root-dir]`: create a new project scaffold

## Recommended Structure

```text
~/Documents/elixirr/
  shared/
  clients/
    <client-name>/
      context/
      meetings/
      projects/
  internal/
```

## Example Usage

```bash
chmod +x scripts/*.sh
./scripts/init-elixirr.sh
./scripts/new-client.sh acme
./scripts/new-project.sh acme website-redesign
```

## Context Loading Order

1. `clients/<client>/context/index.md`
2. `clients/<client>/projects/<project>/context/index.md` when relevant
3. recent meeting notes when relevant

## Skills

Yes, a Codex skill can be created to call these scripts. A good pattern is:

- the skill asks for a client slug and optional project slug
- it runs the matching scaffold script
- it returns the created paths and reminds the user where to add context
