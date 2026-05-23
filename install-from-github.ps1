function Install-WorkflowFromGitHub {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Repo,

        [string] $Ref = "main",

        [string] $ProjectName = "PROJECT_NAME",

        [string] $TargetRoot = (Get-Location).Path,

        [switch] $Force
    )

    $ErrorActionPreference = "Stop"

    $zipUrl = "https://github.com/$Repo/archive/refs/heads/$Ref.zip"
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("workflow-template-" + [System.Guid]::NewGuid().ToString("N"))
    $zipPath = Join-Path $tempRoot "template.zip"
    $extractPath = Join-Path $tempRoot "extract"

    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

        $repoRoot = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
        if (-not $repoRoot) {
            throw "Could not find extracted repository root."
        }

        $items = @(".agents", ".codex", ".claude", "AGENTS.md", "CLAUDE.md")
        foreach ($item in $items) {
            $src = Join-Path $repoRoot.FullName $item
            if (-not (Test-Path -LiteralPath $src)) {
                throw "Template is missing $item."
            }

            $dst = Join-Path $TargetRoot $item
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
            New-Item -ItemType Directory -Force -Path (Join-Path $TargetRoot $dir) | Out-Null
        }

        Get-ChildItem -LiteralPath $TargetRoot -Recurse -File |
            Where-Object { $_.Extension -in ".md", ".json", ".sh", ".py", ".toml" } |
            ForEach-Object {
                $text = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
                $text = $text.Replace("PROJECT_NAME", $ProjectName)
                Set-Content -LiteralPath $_.FullName -Value $text -Encoding UTF8
            }

        Write-Host "Installed workflow template into $TargetRoot"
        Write-Host "Next: edit .codex/team.json, .claude/team.json, and technical-preferences.md."
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
