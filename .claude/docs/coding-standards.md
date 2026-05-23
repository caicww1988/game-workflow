# Coding Standards

- All game code must include doc comments on public APIs
- Architecture decisions should be documented as ADRs in `docs/architecture/` **incrementally during UE5 development** — not blocking on ADR before coding. Each system should have an ADR backfilled by the time it's marked stable.
- Gameplay values must be data-driven (external config), never hardcoded
- All public methods must be unit-testable (dependency injection over singletons)
- Commits must reference the relevant design document or task ID
- **Verification-driven development**: Write tests first when adding gameplay systems.
  For UI changes, verify with screenshots. Compare expected output to actual output
  before marking work complete. Every implementation should have a way to prove it works.

## Agent 编码行为准则

以下原则适用于所有 agent（主 agent、subagent、skill）在编写或修改代码时。

### 1. 编码前先思考

- 明确陈述你的假设。不确定时，问，不要猜。
- 存在多种理解时，列出选项，不要默默选一个。
- 存在更简单的方案时，主动提出。该 push back 时 push back。
- 遇到不清楚的地方，停下来说明困惑点，向用户确认。

### 2. 最小化实现

- 不实现未被要求的功能。
- 不为一次性代码创建抽象。
- 不添加未被要求的"灵活性"或"可配置性"。
- 不为不可能发生的场景添加错误处理。
- 200 行能用 50 行解决的，重写。

### 3. 手术式修改

编辑现有代码时：
- 不"顺手改进"相邻的代码、注释或格式。
- 不重构没有坏的东西。
- 匹配现有代码风格，即使你会用不同方式写。
- 发现无关的死代码，提一句即可，不要删除。

清理规则：
- 你的修改导致的孤立 import/变量/函数 → 删除。
- 修改前就存在的死代码 → 不动，除非被要求。

检验标准：diff 中每一行变更都应能直接追溯到用户的请求。

### 4. 目标驱动执行

将指令转化为可验证目标：
- "加验证" → 先写非法输入测试，再让测试通过
- "修 bug" → 先写复现测试，再让测试通过
- "重构 X" → 确保重构前后测试都通过

多步骤任务使用验证计划：
1. [步骤] → 验证: [检查方式]
2. [步骤] → 验证: [检查方式]

# Design Document Standards

- All design docs use Markdown
- Each mechanic has a dedicated document in `design/gdd/`
- Documents must include these 8 required sections:
  1. **Overview** -- one-paragraph summary
  2. **Player Fantasy** -- intended feeling and experience
  3. **Detailed Rules** -- unambiguous mechanics
  4. **Formulas** -- all math defined with variables
  5. **Edge Cases** -- unusual situations handled
  6. **Dependencies** -- other systems listed
  7. **Tuning Knobs** -- configurable values identified
  8. **Acceptance Criteria** -- testable success conditions
- Balance values must link to their source formula or rationale

