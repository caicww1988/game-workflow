# Reusable Game Production Workflow Template

This folder extracts the workflow layer from the source project without carrying
over project-specific content, code, assets, design docs, or session history.

## What Is Included

- `.agents/skills/`: reusable slash-command style workflows.
- `.codex/`: Codex agents, rules, hooks, docs, templates, and team identity map.
- `.claude/`: Claude Code mirror of the same workflow.
- `AGENTS.md` and `CLAUDE.md`: generic entry points for new projects.
- `install.ps1`: copies the workflow into another repository.

## What Was Intentionally Excluded

- Game source code, engine assets, art references, and screenshots.
- Current project GDDs, stage files, sprint files, ADRs, and risk registers.
- Session logs, local active state, and real team account details.
- Hard-coded absolute paths from the source machine.

## Install From A Local Copy

From this template folder:

```powershell
.\install.ps1 -TargetRoot "D:\path\to\new-project" -ProjectName "MyGame"
```

Then edit these files in the target project:

- `.codex/team.json` and `.claude/team.json`: replace placeholder git users and
  emails with the new team.
- `.codex/docs/technical-preferences.md` and
  `.claude/docs/technical-preferences.md`: choose engine, language, budgets, and
  test framework.
- `.codex/rules/*.md` and `.claude/rules/*.md`: adjust `paths:` frontmatter to
  match the new repository layout.
- `AGENTS.md` and `CLAUDE.md`: replace `PROJECT_NAME` if the installer did not
  already do it.

## Suggested New-Project Skeleton

```text
art/
assets/
design/gdd/
docs/architecture/
plan/sprints/
plan/milestones/
plan/risk-register/
prototypes/
team/memo/
team/session-state/
team/session-logs/
tools/
```

The workflow is lazy by design: create only the folders your new project needs.

## Install Directly From GitHub

After this template is pushed to GitHub, install it into the current directory
with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/OWNER/REPO/main/install-from-github.ps1 | iex; Install-WorkflowFromGitHub -Repo OWNER/REPO -ProjectName MyGame"
```

Replace:

- `OWNER/REPO` with your GitHub repository, for example `your-name/game-workflow-template`.
- `MyGame` with the target project's display name.

By default the installer writes into the current directory. Add `-Force` only if
you intentionally want to overwrite existing `.agents`, `.codex`, `.claude`,
`AGENTS.md`, or `CLAUDE.md`.

