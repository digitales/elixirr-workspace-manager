# Elixirr Skills Package

This repository is maintained as a lean downloadable package for the Elixirr Codex setup.

It now focuses on four things:

- `skills/` for the skill definitions
- `skills/docs/` for the team-facing guide
- `skills/scripts/` for the macOS/Linux and Windows installers
- `automations/` for local automation templates

## Open The Guide

The main internal guide lives at:

- `skills/docs/index.html`

After downloading and extracting the package, open that file locally in a browser.

## Download The Package

Recommended user path:

1. Go to GitHub Releases.
2. Download the latest `elixirr-skills-package-...zip` asset.
3. Extract it anywhere locally.
4. Open the extracted folder and run the installer for your platform.

## Install Locally

1. Download the package zip.
2. Extract it anywhere locally.
3. Open a terminal in the extracted folder.
4. Run the installer for your platform.

### macOS / Linux

```bash
cd /path/to/extracted-package
bash ./skills/scripts/install.sh
```

### Windows PowerShell

```powershell
cd C:\path\to\extracted-package
pwsh -File .\skills\scripts\install.ps1
```

## Build A Zip

### macOS / Linux

```bash
bash ./skills/scripts/package.sh
```

### Windows PowerShell

```powershell
pwsh -File .\skills\scripts\package.ps1
```

The zip will be written to `dist/` and will contain only:

- `README.md`
- `skills/`
- `automations/`

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
