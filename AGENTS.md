# PROJECT_NAME - Game Development Workflow

This file is the Codex entry point for the reusable production workflow in this
template. Replace `PROJECT_NAME`, choose your engine, and update the team map
before using it in a new repository.

## Quick Start

- Run `/start` to inspect project state and choose the next work direction.
- Run `/setup-engine` when the engine, language, or technical conventions are
  not configured yet.
- Keep project state in `plan/stage.md` and per-developer state in
  `team/session-state/{identity}/active.md`.

## Local Project Skills

Project-local slash commands live in `.agents/skills/{command}/SKILL.md`.
They are local to this repository and do not need to be installed as global
Codex skills.

When the user sends `/command` or `/command arguments`:

1. Resolve `.agents/skills/{command}/SKILL.md` relative to the repository root.
2. If the file exists, read it and follow its workflow as the active local
   project skill.
3. Treat YAML frontmatter as command metadata and pass the remaining text as
   command arguments.
4. Map any listed `allowed-tools` to the tools available in the current Codex
   session.
5. Prefer local project skills over similarly named global skills.
6. If the file does not exist, say the local project skill was not found.

Examples:

- `/start` loads `.agents/skills/start/SKILL.md`.
- `/setup-engine Unreal Engine 5.6` loads
  `.agents/skills/setup-engine/SKILL.md` with `Unreal Engine 5.6` as arguments.
- `/brainstorm cozy survival` loads `.agents/skills/brainstorm/SKILL.md` with
  `cozy survival` as arguments.

## Project Structure

@.codex/docs/directory-structure.md

## Technical Preferences

@.codex/docs/technical-preferences.md

## Coding Standards

@.codex/docs/coding-standards.md

## Path-Scoped Rules

@.codex/docs/rules-mechanism.md
@.codex/docs/rules-reference.md

## Collaboration Protocol

User-driven collaboration, not autonomous execution.
Every task follows: Question -> Options -> Decision -> Draft -> Approval.

- Agents ask before writing major design or planning files.
- Agents show drafts or summaries before requesting approval.
- Multi-file changes require explicit approval for the full changeset.
- No commits without user instruction.

## Team Memo Protocol

@.codex/docs/team-memo-protocol.md

## Context Management

@.codex/docs/context-management.md

## Language

- Use the team's primary language for collaboration.
- English technical names, API names, and asset names are accepted.

## Agent Process Rules

@.codex/docs/agent-process-rules.md

