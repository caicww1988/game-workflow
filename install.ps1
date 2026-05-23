param(
    [Parameter(Mandatory = $true)]
    [string] $TargetRoot,

    [string] $ProjectName = "PROJECT_NAME",

    [switch] $Force
)

$ErrorActionPreference = "Stop"

$templateRoot = $PSScriptRoot
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$target = Resolve-Path -LiteralPath $TargetRoot -ErrorAction SilentlyContinue
if (-not $target) {
    New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    $target = Resolve-Path -LiteralPath $TargetRoot
}

$items = @(".agents", ".codex", ".claude", "AGENTS.md", "CLAUDE.md")
foreach ($item in $items) {
    $src = Join-Path $templateRoot $item
    $dst = Join-Path $target $item
    if ((Test-Path -LiteralPath $dst) -and -not $Force) {
        throw "Target already has $item. Re-run with -Force to overwrite workflow files."
    }
    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
}

$skeletonDirs = @(
    "art",
    "assets",
    "design/gdd",
    "docs/architecture",
    "plan/sprints",
    "plan/milestones",
    "plan/risk-register",
    "prototypes",
    "team/memo",
    "team/session-state",
    "team/session-logs",
    "tools"
)

foreach ($dir in $skeletonDirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $target $dir) | Out-Null
}

Get-ChildItem -LiteralPath $target -Recurse -File |
    Where-Object { $_.Extension -in ".md", ".json", ".sh", ".py", ".toml" } |
    ForEach-Object {
        $text = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
        $text = $text.Replace("PROJECT_NAME", $ProjectName)
        [System.IO.File]::WriteAllText($_.FullName, $text, $utf8NoBom)
    }

Write-Host "Installed workflow template into $target"
Write-Host "Next: edit .codex/team.json, .claude/team.json, and technical-preferences.md."
