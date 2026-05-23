# Directory Structure

```text
/
├── CLAUDE.md                    # Master configuration
├── .claude/                     # Skills, hooks, docs
│   ├── settings.json            # Team-shared Claude Code settings
│   ├── docs/                    # Reference docs and templates
│   └── skills/                  # Slash command skills
├── art/                         # AI art production pipeline (pre-engine)
│   ├── 01_Illustration/         # AI illustration generation
│   ├── 02_Modeling/             # AI 3D modeling
│   ├── 03_Rigging/              # AI rigging & skinning
│   ├── 04_Animation/            # AI animation generation
│   ├── style-guide/             # Art style guide
│   └── export/                  # UE export staging
├── client/                      # UE5 engine project root (uproject + Source + Content)
│   ├── client.uproject          # UE5 project file
│   ├── Source/                  # Game C++ source code (was src/ in earlier docs)
│   │   └── client/              # Primary game module
│   ├── Content/                 # UE asset packs (.uasset; engine-managed)
│   └── Config/                  # UE config files (DefaultEngine.ini etc.)
├── assets/                      # Source-of-truth game assets (vfx, shaders, data) before UE import
├── design/                      # Game design documents
│   └── gdd/                     # Per-system GDDs
├── docs/                        # Technical documentation
│   ├── architecture/            # Architecture Decision Records (ADRs)
│   └── engine-reference/        # Engine-version pinned reference docs
├── tests/                       # Test suites (UAutomationTest)
├── tools/                       # Build and pipeline tools
├── prototypes/                  # Throwaway prototypes (isolated from client/Source/)
├── plan/                        # Project planning & production management (was production/)
│   ├── stage.md                 # Stage SoT — current stage + sub-phase status
│   ├── stage.txt                # Stage value mirror (single line, for skill reads)
│   ├── sprints/                 # Sprint plans
│   ├── milestones/              # Milestone definitions
│   └── risk-register/           # Risk register entries
└── team/                        # Team collaboration & per-developer state
    ├── handoff/HANDOFF.md       # Shared milestone handoff (git-tracked)
    ├── memo/                    # Cross-developer lightweight async pings (git-tracked)
    │   └── {recipient}/
    │       ├── open/            # /start 自动 surface 这里的 memo
    │       └── closed/          # recipient 处理完 mv 进来；本地审计
    ├── session-state/           # Per-developer session state (git-tracked)
    │   └── {identity}/
    │       ├── active.md        # Living checkpoint
    │       └── *.md             # Custom memory/todo files
    └── session-logs/            # Per-developer audit trail (git-tracked)
        └── {identity}/
            ├── session-log.md
            └── compaction-log.txt
```

Identity is resolved from `git config user.name` via `.claude/team.json`.

## 路径约定要点

- **`client/`** 是 UE5 引擎工程根（含 `.uproject` / `Source/` / `Content/` / `Config/`）。所有 C++ 源码在 `client/Source/`；引擎管理的 `.uasset` 在 `client/Content/`。
- **`assets/`** 仅放尚未经 UE 导入的 source-of-truth 资源（如 source FBX、PNG ref、Excel 配表）。
- **`art/`** 是 AI 美术生产管线工作目录（立绘 / 建模 / 绑定 / 动画），完成后导出到 `client/Content/` 或 `assets/`。
- **`plan/`** 是项目管理工件目录（前身 `production/`）。`stage.md` + `stage.txt` 是 stage SoT；`sprints/` / `milestones/` / `risk-register/` 后续按需创建。
- **`team/memo/`** 是跨开发者轻量 ping 机制 — sender 写到 `{recipient}/open/`，recipient `/start` 时自动 surface；处理完 `git mv` 到 `closed/`。详 `.claude/docs/team-memo-protocol.md`。

Directories 按需 lazy 创建。初始仅 `tools/`、`team/`、`art/`、`.claude/`、`docs/`、`design/`、`client/`、`prototypes/`、`plan/` 存在。

