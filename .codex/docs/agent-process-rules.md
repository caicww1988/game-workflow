# Agent Process Rules

通用 agent 行为规则。AGENTS.md @ 引入，适用所有 main agent / subagent / skill。

---

## R1 Verify-before-label

**Rule**: 向用户呈现选项（AskUserQuestion option label / Plan 阶段 recap / 任务描述）前，必须先 Read 目标文件 header + Status，验证当前真实状态。不直抄以下来源 vocabulary 作为 work label:

- `team/session-state/{identity}/active.md` 的 "下一步" 条目
- ADR 章节标题（描述原始决策时刻，常相对 pre-pivot baseline）
- GDD 头部 Status 字段单独（不读 body 时易误判）

**Why**: 这三类来源是 *intent snapshot*，不是 *current state*。会随 intermediate commit 与 review pass 失效，但不主动更新。

- `active.md "下一步"` 在 session start 时写，commit 之间不刷新
- ADR 标题 vocabulary 描述 "决策内容"（如 "招募引擎重写"），P3 反向 patch Applied 后该词已 stale
- Status `In Design (Provisional — 待 X 后冻结)` 模式下，trigger X 满足后 status word 不自动更新

**通用例子**: `/start` flow 如果直接照抄 `active.md` 里的旧 "下一步" 或旧 ADR 标题，可能把已经完成 review 的小修误标成大规模重写。呈现给用户前，必须先读目标文件当前 header、Status、Review History。

**How to apply**:

1. AskUserQuestion 准备 option 前，对每个 system label 执行:
   ```
   Read [target-file]:1-30                  # header + Status
   Grep "Status|Review History|design-review" [target-file]   # 验证 status word 时效
   ```
2. 若 Status 含 "Provisional — 待 X 后冻结" 模式，主动 grep X 是否已满足，避免把 "待冻结" 当 "未起草"
3. option label 必须可追溯至 *verified file state*，不可纯凭 session-state notes 或 ADR vocabulary
4. 若 label 与文件状态冲突（如 active.md 说 "重写" 但 GDD APPROVED），在 option description 注 stale 警告或先 fix vocabulary 再呈现

---

## R2 Language preference: Chinese

**Rule**: 默认中文回应所有 user-facing 文本。

**适用**:
- 主对话回应（含 caveman mode 叠加 = 中文 caveman）
- AskUserQuestion 的 question + option label + description
- 任务计划 / Phase 命名 / 状态汇报
- TaskCreate subject + description

**例外（保持英文 / 原文）**:
- Code (C++/Blueprint identifier / 注释中已有英文模式按既有风格)
- Git commit message / PR title / body（项目惯例 — 见 `git log` 历史均英文）
- 技术名词：类名、枚举值、API 签名、UE 内置概念（`UWorldSubsystem` / `FInstancedStruct` / `Lumen` 等）
- 引用文件路径 / GDD 章节命名按既有 codebase 命名匹配（中文则中文，英文则英文）
- Error message / log 原文不翻译

**Caveman mode 协同**: caveman = 压缩规则；中文 = 语言。两者叠加 → 中文 caveman:
- ✅ "句号删；fragments OK；技术词精确"
- ❌ 不要 caveman 化技术名词或文件路径

---

## R3 Path-scoped rules awareness

**Rule**: 编辑 `.codex/rules/*.md` frontmatter `paths:` 匹配的文件时，对应规则会通过 SessionStart hook + PostToolUse hook 自动注入 agent context。Agent 必须按注入的 rules 校验所有 Edit/Write 操作，不能假装没看到。

**Why**: rules 是 path-scoped 强约束（如 `design/gdd/**` 必须 8 section / 双向依赖 / 可测试 AC）。SessionStart 全量加载 + PostToolUse 按 path 注入是 PROJECT_NAME 自定义 convention 而非 Codex 官方机制，agent 看到 system reminder 中 "Active Rule:" / "Path-Scoped Rules" 段时应视同 AGENTS.md @ 引入的指令对待。

**How to apply**:

1. session 启动时若 system reminder 含 `=== Path-Scoped Rules ===` 段，**完整读完**所有列出的 rule 文件
2. Edit `.codex/rules/*.md` `paths:` 匹配的文件后，若 tool result 含 `additionalContext` 注入新 rule，**立即按新 rule 校验本次和后续 Edit**
3. 如对 rule 有歧义或与其他指令冲突，明示问用户哪条优先，不要自行判断
4. 当前 rules 索引见 `.codex/docs/rules-reference.md`；机制原理 + 加新 rule 流程见 `.codex/docs/rules-mechanism.md`

---

## 修订历史

| Date | Change | Reason |
|------|--------|--------|
| 2026-05-18 | 初稿 R1 + R2 | 从项目实践中抽象 verify-before-label 与语言偏好规则 |
| 2026-05-22 | 加 R3 path-scoped rules awareness | P29 激活 rules 机制 — 让 agent 知道注入内容应视同 AGENTS.md 指令 |

