# Agent Process Rules

通用 agent 行为规则。CLAUDE.md @ 引入，适用所有 main agent / subagent / skill。

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

**Rule**: 编辑 `.claude/rules/*.md` frontmatter `paths:` 匹配的文件时，对应规则会通过 SessionStart hook + PostToolUse hook 自动注入 agent context。Agent 必须按注入的 rules 校验所有 Edit/Write 操作，不能假装没看到。

**Why**: rules 是 path-scoped 强约束（如 `design/gdd/**` 必须 8 section / 双向依赖 / 可测试 AC）。SessionStart 全量加载 + PostToolUse 按 path 注入是 PROJECT_NAME 自定义 convention 而非 Claude Code 官方机制，agent 看到 system reminder 中 "Active Rule:" / "Path-Scoped Rules" 段时应视同 CLAUDE.md @ 引入的指令对待。

**How to apply**:

1. session 启动时若 system reminder 含 `=== Path-Scoped Rules ===` 段，**完整读完**所有列出的 rule 文件
2. Edit `.claude/rules/*.md` `paths:` 匹配的文件后，若 tool result 含 `additionalContext` 注入新 rule，**立即按新 rule 校验本次和后续 Edit**
3. 如对 rule 有歧义或与其他指令冲突，明示问用户哪条优先，不要自行判断
4. 当前 rules 索引见 `.claude/docs/rules-reference.md`；机制原理 + 加新 rule 流程见 `.claude/docs/rules-mechanism.md`

---

## R4 Subagent invocation pattern

**Rule**: 当前项目有 7 个 subagent 定义（`.claude/agents/`），但 Claude Code 平台默认**不自动 spawn subagent**。要实际启用，开发者必须在 prompt 中显式命名 agent type 或显式说 "use a subagent"。主 agent 不会基于任务内容自主推断。

**Why**: 平台层 Agent tool description 明文 "Do not spawn agents unless the user asks"；项目层 CLAUDE.md "User-driven collaboration" 协议同向加固。agent description 字段的 "Use this agent for X" 是给主 agent **选择哪个 agent** 的参考（当用户决定 spawn 时），不是触发条件。

**Available subagents**（`.claude/agents/*.md`）:

| Agent | 何时显式调用 |
|---|---|
| `game-designer` | 核心循环 / 系统拆解 / 战斗 / 经济顶层框架问题 |
| `systems-designer` | 子系统数值公式 / 进阶曲线 / 交互矩阵详细推导 |
| `economy-designer` | 商人 sink/faucet / 掉落表 / 经济曲线校准 |
| `narrative-director` | 故事架构 / 角色背景 / 对话策略 |
| `level-designer` | 关卡布局 / encounter pacing / 空间叙事 |
| `illustrator` | AI 立绘生产管线 |
| `modeler` | AI 图生 3D 管线 |

**推荐 prompt 模板**（直接 copy-paste）:

```
spawn systems-designer subagent: 跑 design/gdd/combat-formulas.md
3 对位算例（warrior vs warrior / warrior vs mage / mage vs assassin）× Lv1/Lv5/Lv10
= 9 算例，识别 dmg > 50% target HP 的失衡点，结果写入 GDD 末尾 ## Audit Log section。
```

```
spawn economy-designer subagent: audit design/gdd/economy.md
4 商人 sink，重现 P3 (2026-05-16) F1 audit 数据 758G + 6.79 item/floor，
解释 diff（如有），结果写入 GDD 末尾 ## Audit Log section。
```

**How to apply**:

1. 任务计划阶段，**主 agent 必须在选项呈现时提示 "此任务适合 subagent，推荐 prompt: ..."** — 不能假设用户知道触发机制
2. 当用户在 sprint plan / task spec 看到 "agent 兜底" / "用 X agent" 字样时，那只是 **意图标注**，要实际启动需在 session 内显式命名
3. 显式命名后主 agent **不再自处理**，转用 Agent tool 启动 subagent；subagent 完成后主 agent 汇总结果给用户审批
4. session-log 应记录 subagent invocation 痕迹（如 "P31 spawn systems-designer @ combat-formulas audit"）

---

## 修订历史

| Date | Change | Reason |
|------|--------|--------|
| 2026-05-18 | 初稿 R1 + R2 | 从项目实践中抽象 verify-before-label 与语言偏好规则 |
| 2026-05-22 | 加 R3 path-scoped rules awareness | P29 激活 rules 机制 — 让 agent 知道注入内容应视同 CLAUDE.md 指令 |
| 2026-05-23 | 加 R4 subagent invocation pattern | review 发现 specialist subagent 未被显式触发，固化触发协议 + prompt 模板 |

