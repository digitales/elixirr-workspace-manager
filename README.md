# Elixirr Skills Package

This repository is a lean local package for the Elixirr Codex setup.

It now focuses on four things:

- `skills/` for the skill definitions
- `skills/docs/` for the team-facing guide
- `skills/scripts/` for the macOS/Linux and Windows installers
- `automations/` for local automation templates

## Open The Guide

The main internal guide lives at:

- `skills/docs/index.html`

## Install Locally

### macOS / Linux

```bash
bash ./skills/scripts/install.sh
```

### Windows PowerShell

```powershell
pwsh -File .\skills\scripts\install.ps1
```

## Repo Shape

```text
.
├── automations/
├── skills/
│   ├── docs/
│   ├── scripts/
│   └── <skill-name>/
└── README.md
```
