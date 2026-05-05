param(
    [string[]]$Skill = @(),
    [string[]]$Automation = @(),
    [switch]$SkillsOnly,
    [switch]$AutomationsOnly,
    [string]$CodexHome = "",
    [switch]$DryRun,
    [switch]$List
)

$ErrorActionPreference = "Stop"

function Write-Usage {
    @"
Install Elixirr skills and automations into the local Codex home.

Usage:
  pwsh -File .\skills\scripts\install.ps1 [options]

Options:
  -Skill NAME              Install one skill. Can be repeated.
  -Automation NAME         Install one automation. Can be repeated.
  -SkillsOnly              Install skills only.
  -AutomationsOnly         Install automations only.
  -CodexHome PATH          Override the Codex home directory. Default: ~/.codex
  -DryRun                  Show planned actions without changing anything.
  -List                    List discovered skills and automations, then exit.

Examples:
  pwsh -File .\skills\scripts\install.ps1
  pwsh -File .\skills\scripts\install.ps1 -DryRun
  pwsh -File .\skills\scripts\install.ps1 -Skill elixirr-memory-refresh
  pwsh -File .\skills\scripts\install.ps1 -AutomationsOnly -Automation elixirr-output-sync
"@
}

function Write-Log {
    param([string]$Message)
    Write-Host $Message
}

function Fail {
    param([string]$Message)
    throw $Message
}

function Invoke-Step {
    param(
        [string]$Description,
        [scriptblock]$Action
    )

    if ($DryRun) {
        Write-Host "[dry-run] $Description"
    }
    else {
        & $Action
    }
}

function Get-SkillsRoot {
    $scriptDir = Split-Path -Parent $PSCommandPath
    return Split-Path -Parent $scriptDir
}

function Get-DefaultCodexHome {
    if ($env:USERPROFILE) {
        return Join-Path $env:USERPROFILE ".codex"
    }
    return Join-Path $HOME ".codex"
}

function Get-AvailableSkills {
    param([string]$Root)

    Get-ChildItem -Path $Root -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
        Sort-Object Name |
        Select-Object -ExpandProperty Name
}

function Resolve-AutomationsRoot {
    param([string]$Root)

    $candidates = @(
        (Join-Path $Root "automations"),
        (Join-Path (Split-Path -Parent $Root) "automations")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate -PathType Container) {
            return $candidate
        }
    }

    return $null
}

function Get-AvailableAutomations {
    param([string]$Root)

    Get-ChildItem -Path $Root -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "automation.toml") } |
        Sort-Object Name |
        Select-Object -ExpandProperty Name
}

function Install-Skill {
    param(
        [string]$SkillsRoot,
        [string]$SkillName,
        [string]$TargetCodexHome
    )

    $sourceDir = Join-Path $SkillsRoot $SkillName
    $destRoot = Join-Path $TargetCodexHome "skills"
    $destDir = Join-Path $destRoot $SkillName

    if (-not (Test-Path $sourceDir -PathType Container)) {
        Fail "Skill source not found: $sourceDir"
    }

    Write-Log "Installing skill: $SkillName"
    Invoke-Step "Create $destRoot" { New-Item -ItemType Directory -Path $destRoot -Force | Out-Null }
    Invoke-Step "Remove $destDir" {
        if (Test-Path $destDir) {
            Remove-Item -Path $destDir -Recurse -Force
        }
    }
    Invoke-Step "Copy $sourceDir -> $destDir" { Copy-Item -Path $sourceDir -Destination $destDir -Recurse }
}

function Install-Automation {
    param(
        [string]$AutomationsRoot,
        [string]$AutomationName,
        [string]$TargetCodexHome
    )

    $sourceDir = Join-Path $AutomationsRoot $AutomationName
    $sourceFile = Join-Path $sourceDir "automation.toml"
    $destDir = Join-Path (Join-Path $TargetCodexHome "automations") $AutomationName
    $destFile = Join-Path $destDir "automation.toml"

    if (-not (Test-Path $sourceFile -PathType Leaf)) {
        Fail "Automation source not found: $sourceFile"
    }

    Write-Log "Installing automation: $AutomationName"
    Invoke-Step "Create $destDir" { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Invoke-Step "Copy $sourceFile -> $destFile" { Copy-Item -Path $sourceFile -Destination $destFile -Force }
}

if ($SkillsOnly -and $AutomationsOnly) {
    Fail "-SkillsOnly and -AutomationsOnly cannot be used together"
}

$skillsRoot = Get-SkillsRoot
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Get-DefaultCodexHome
}

$availableSkills = @(Get-AvailableSkills -Root $skillsRoot)
if ($availableSkills.Count -eq 0) {
    Fail "No skills were discovered under $skillsRoot"
}

$automationsRoot = Resolve-AutomationsRoot -Root $skillsRoot
$availableAutomations = @()
if ($automationsRoot) {
    $availableAutomations = @(Get-AvailableAutomations -Root $automationsRoot)
}

if ($List) {
    Write-Log "Skills:"
    $availableSkills | ForEach-Object { Write-Host "  - $_" }
    if ($availableAutomations.Count -gt 0) {
        Write-Host ""
        Write-Log "Automations:"
        $availableAutomations | ForEach-Object { Write-Host "  - $_" }
    }
    exit 0
}

$hasExplicitSelection = ($Skill.Count -gt 0 -or $Automation.Count -gt 0)
$skillsToInstall = @()
$automationsToInstall = @()

if (-not $AutomationsOnly) {
    if ($Skill.Count -gt 0) {
        foreach ($skillName in $Skill) {
            if ($availableSkills -notcontains $skillName) {
                Fail "Unknown skill: $skillName"
            }
            $skillsToInstall += $skillName
        }
    }
    elseif (-not $hasExplicitSelection) {
        $skillsToInstall = $availableSkills
    }
}

if (-not $SkillsOnly) {
    if ($Automation.Count -gt 0) {
        if (-not $automationsRoot) {
            Fail "No automations directory was discovered"
        }
        foreach ($automationName in $Automation) {
            if ($availableAutomations -notcontains $automationName) {
                Fail "Unknown automation: $automationName"
            }
            $automationsToInstall += $automationName
        }
    }
    elseif (-not $hasExplicitSelection -and $availableAutomations.Count -gt 0) {
        $automationsToInstall = $availableAutomations
    }
}

if ($skillsToInstall.Count -eq 0 -and $automationsToInstall.Count -eq 0) {
    Fail "Nothing to install"
}

Write-Log "Codex home: $CodexHome"
Write-Log "Skills root: $skillsRoot"
if ($automationsRoot) {
    Write-Log "Automations root: $automationsRoot"
}
Write-Host ""

foreach ($skillName in $skillsToInstall) {
    Install-Skill -SkillsRoot $skillsRoot -SkillName $skillName -TargetCodexHome $CodexHome
}

foreach ($automationName in $automationsToInstall) {
    Install-Automation -AutomationsRoot $automationsRoot -AutomationName $automationName -TargetCodexHome $CodexHome
}

Write-Host ""
Write-Log "Install complete."
