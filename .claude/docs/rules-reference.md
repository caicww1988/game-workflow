# Path-Scoped Rules — Reference Index

`.claude/rules/` 下的规则在编辑匹配 path 的文件时**自动注入** agent context：

- **SessionStart hook**: session 启动时全量加载所有 rules 内容（首次编辑兜底）
- **PostToolUse hook**: 每次 Edit / Write / MultiEdit 后按 `paths:` glob 匹配重新注入命中 rule（session-level marker 防重复）

机制原理见 [rules-mechanism.md](rules-mechanism.md)。

---

## Active Rules

| Rule | Path Pattern | Enforces |
|------|--------------|----------|
| [`design-docs.md`](../rules/design-docs.md) | `design/gdd/**` | 8-section GDD 强制结构 / 公式格式 / Edge cases 显式 / 双向依赖 / 可测试 AC / 增量编写 |
| [`gameplay-code.md`](../rules/gameplay-code.md) | `client/Source/**` | 数据驱动数值 / DeltaSeconds / UI 隔离 / Interface + DI / Subsystem 替代 singleton / 注释引 GDD |
| [`ai-code.md`](../rules/ai-code.md) | `client/Source/**/AI/**` 🪧 | AI tick 预算 / DataAsset 参数 / Visual Logger / telegraph / Behavior Tree 优先 / 状态转换 log |
| [`ui-code.md`](../rules/ui-code.md) | `client/Source/**/UI/**` 🪧 | display only / 本地化 FText / 键鼠+手柄 Common UI / 动画可 skip / 色盲模式 / 多分辨率测试 |
| [`test-standards.md`](../rules/test-standards.md) | `tests/**` 🪧 | `Test_[System]_[Scenario]_[Result]` 命名 / Arrange-Act-Assert / 隔离 / Mock / regression test |
| [`prototype-code.md`](../rules/prototype-code.md) | `prototypes/**` | Relaxed standards / 必须 README（hypothesis / 运行方式 / status / findings） / 不混生产 |

🪧 = path 当前对应目录不存在（占位），等首次相关代码 land 时自动激活；若实际目录命名不同可 patch rule 文件 `paths:` 字段。

---

## 删除 / 不引入历史

| Rule | 状态 | 原因 |
|------|------|------|
| `narrative.md` | 可选 | 叙事规则是否需要独立文件取决于项目类型；也可由系统 GDD 承载 |
| `data-files.md` | 可选 | 数据文件格式、校验方式、来源链路应由目标项目自行决定 |
| `engine-code.md` | 可选 | 只有目标团队会修改引擎或框架底层代码时再启用 |
| `network-code.md` | 可选 | 单机项目可不启用；多人项目应补充同步、预测、回滚与安全规则 |
| `shader-code.md` | 可选 | 有 shader / material 源码工作流时再启用 |

---

## 加新 rule / 修改

见 [rules-mechanism.md](rules-mechanism.md) § "加新 rule 的步骤"。

简要：

1. 写 `.claude/rules/{name}.md`，frontmatter 含 `paths:` glob 列表
2. 在本文件 (`rules-reference.md`) "Active Rules" 表追加一行
3. 下个 session 自动生效；hooks 无需改

---

## 修订历史

| Date | Change | Reason |
|------|--------|--------|
| 2026-05-22 | 初稿 | P30 从上游模板补 5 个 rules + 拆出索引文档 |

