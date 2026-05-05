param(
    [string]$OutputDir = "",
    [string]$Name = "elixirr-skills-package"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
$skillsRoot = Split-Path -Parent $scriptDir
$repoRoot = Split-Path -Parent $skillsRoot

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "dist"
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$stagingDir = Join-Path ([System.IO.Path]::GetTempPath()) ("elixirr-skills-package-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

try {
    Copy-Item -Path (Join-Path $repoRoot "README.md") -Destination (Join-Path $stagingDir "README.md")
    Copy-Item -Path (Join-Path $repoRoot "skills") -Destination (Join-Path $stagingDir "skills") -Recurse
    Copy-Item -Path (Join-Path $repoRoot "automations") -Destination (Join-Path $stagingDir "automations") -Recurse

    Get-ChildItem -Path $stagingDir -Recurse -Force -Include ".DS_Store" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $stagingDir -Recurse -Directory -Force | Where-Object { $_.Name -eq "__pycache__" } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    $zipPath = Join-Path $OutputDir ($Name + ".zip")
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }

    Compress-Archive -Path `
        (Join-Path $stagingDir "README.md"), `
        (Join-Path $stagingDir "skills"), `
        (Join-Path $stagingDir "automations") `
        -DestinationPath $zipPath

    Write-Host "Created package: $zipPath"
}
finally {
    if (Test-Path $stagingDir) {
        Remove-Item $stagingDir -Recurse -Force
    }
}
