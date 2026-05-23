---
name: generate-illustration
description: "AI 立绘生成工作流 — 使用 LiblibAI API 从角色描述生成多视角立绘。引导完成配置检查、模型选择、prompt 编写、图片生成、质量审核的完整流程。"
argument-hint: "[角色名] (例: warrior, mage, npc_merchant)"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, mcp__liblib-ai__liblib_validate_config, mcp__liblib-ai__liblib_text2img, mcp__liblib-ai__liblib_img2img, mcp__liblib-ai__liblib_check_status, mcp__liblib-ai__liblib_list_references, mcp__liblib-ai__liblib_list_outputs, mcp__liblib-ai__liblib_approve_image, mcp__liblib-ai__liblib_query_model, mcp__liblib-ai__liblib_archive_failed, mcp__liblib-ai__liblib_clean_outputs, mcp__liblib-ai__liblib_list_prompts, mcp__liblib-ai__liblib_list_workflows, mcp__liblib-ai__liblib_workflow_info, mcp__liblib-ai__liblib_run_workflow
---

# /generate-illustration — AI 立绘生成工作流

## 概述

引导式立绘生成流程，覆盖从 API 配置检查到最终资源入库的完整链路。
对应 `art/` 管线的 **阶段 1: 立绘生成 (01_Illustration)**。

## 工作流

### 阶段 1: 配置验证

1. 调用 `liblib_validate_config` 检查 API 密钥是否可用
2. 如果失败：
   - 提示用户将 `tools/liblib/config.example.json` 复制为 `tools/liblib/config.json`
   - 引导填入 AccessKey 和 SecretKey（从 https://www.liblib.art/apis 获取）
   - 重新验证
3. 如果成功：显示"API 连接正常"，继续下一步

### 阶段 2: ComfyUI 工作流检查（优先）

ComfyUI 工作流是本项目的**默认首选**生成方式，优先级高于内置模型。

1. 调用 `liblib_list_workflows` 检查 `art/01_Illustration/workflows/` 中已配置的工作流
2. **如果有可用工作流：**
   - 展示工作流列表（名称、描述、预估积分）
   - 使用 AskUserQuestion 询问用户：
     - 选择一个工作流使用 → 进入阶段 3A（工作流模式）
     - 不使用工作流，改用内置模型 → 进入阶段 3B（内置模型模式）
3. **如果没有可用工作流（目录为空或只有模板）：**
   - 提示用户："当前没有已配置的 ComfyUI 工作流。"
   - 建议："可以去 LiblibAI 快捷应用（https://www.liblib.art/quickapp）找到合适的工作流，按 `_template.json` 格式配置到 `art/01_Illustration/workflows/` 目录。"
   - 使用 AskUserQuestion 询问：
     - 现在配置一个新工作流（提供 workflowUuid，agent 协助生成配置文件）
     - 跳过，使用内置模型 → 进入阶段 3B

### 阶段 3A: 工作流模式

当用户选择了 ComfyUI 工作流时执行此分支。

1. 调用 `liblib_workflow_info` 展示所选工作流的详细参数（节点列表、必填/可选输入）
2. 收集角色上下文（同阶段 3B 步骤 1-5）
3. 根据工作流节点要求，协作填写各节点参数：
   - IMAGE 类型节点：询问参考图路径（从 references/ 选择或指定本地路径）
   - STRING 类型节点：协作编写提示词
   - 其他类型节点：展示默认值，询问是否修改
4. 展示完整的节点参数草案，请求用户确认
5. 将确认的参数保存到 `art/01_Illustration/prompts/{角色名}.md`（增加工作流信息）
6. 调用 `liblib_run_workflow` 执行工作流
7. 工具内部自动轮询直到完成，返回生成结果
8. → 跳转阶段 6（结果审核）

### 阶段 3B: 内置模型模式（备选）

当没有可用工作流或用户主动选择内置模型时执行此分支。

#### 步骤 1: 角色上下文

1. 解析参数中的角色名（如 `warrior`）
2. 读取 `art/asset-registry.md` 检查该角色是否已有记录
3. 读取 `art/style-guide/` 下的风格规范（如有）
4. 调用 `liblib_list_references` 列出可用参考图
5. 检查 `art/01_Illustration/prompts/` 下是否有该角色的已有 prompt 模板
6. 向用户展示收集到的上下文信息

#### 步骤 2: 生成方式选择

使用 AskUserQuestion 询问用户：

**选择生成模式：**
- 文生图 (text2img) — 纯文字描述生成
- 图生图 (img2img) — 基于参考图 + 文字生成

**选择模型：**
- 星流 Star-3 Alpha — 高质量通用生成，内置模型，简单快速
- F.1 Kontext — 文本+图像编辑，真实感领先（需确认 templateUuid）
- LibDream — 中文理解最强，适合海报类
- 智能算法 IMG-1 — 风格一致性和 Prompt 还原最强
- 自定义模型 — 自由选择 LoRA/ControlNet，需提供 checkpoint ID

如果选择自定义模型，额外询问：
- checkpoint versionUuid（从 liblib.art 网站复制）
- 是否添加 LoRA（模型 ID + 权重）

#### 步骤 3: Prompt 工程

1. 如果已有该角色的 prompt 文件（`art/01_Illustration/prompts/{角色名}.md`），读取并展示
2. 使用 AskUserQuestion 确认是否复用/修改已有 prompt，或从头编写
3. 协作构建 prompt：
   - **正面提示词** (prompt): 角色外貌、服装、姿势、风格关键词
   - **负面提示词** (negative_prompt): 常见瑕疵排除词
   - **技术参数**: 分辨率（宽高或 aspect_ratio）、采样步数、生成张数
4. 展示完整参数草案，请求用户确认
5. 将确认的 prompt 保存到 `art/01_Illustration/prompts/{角色名}.md`：

```markdown
# {角色名} 立绘 Prompt

## 基础信息
- 模型: {选用模型}
- 日期: {当前日期}

## 正面视角 (front)
- Prompt: {prompt}
- Negative: {negative_prompt}
- 参数: {width}x{height}, steps={steps}, seed={seed}

## 侧面视角 (side)
（后续补充）

## 背面视角 (back)
（后续补充）
```

#### 步骤 4: 图片生成

1. 根据选择调用对应 MCP 工具：
   - 文生图: `liblib_text2img`
   - 图生图: `liblib_img2img`（本地参考图会自动上传）
2. 工具内部会自动轮询直到完成，返回：
   - 生成的图片文件路径（在 `art/01_Illustration/output/` 下）
   - 消耗积分和剩余积分
3. 告知用户生成结果

### 阶段 6: 结果审核

1. 调用 `liblib_list_outputs` 展示生成的图片列表
2. 提示用户在文件管理器中查看图片质量
3. 使用 AskUserQuestion 让用户选择：
   - 通过 — 调用 `liblib_approve_image` 将图片移入 `approved/`
   - 重新生成 — 返回阶段 4 调整 prompt 后重试
   - 调整参数重试 — 修改 steps/seed/模型等参数后重试
   - 放弃 — 保留在 output/ 中不处理
4. 如果有多张图片，逐一确认或批量操作

### 阶段 7: 资源注册

1. 读取 `art/asset-registry.md`
2. 询问用户是否更新资源注册表
3. 如同意，在注册表中添加/更新该角色的记录：
   - 角色名、立绘状态（已完成）、使用工具（LiblibAI + 模型名）
4. 写入文件

### 阶段 8: 下一步建议

根据完成情况提供建议：
- "立绘已通过审核。下一步可以进行 **3D 建模** (02_Modeling 阶段)"
- 如果需要更多视角："是否继续生成 侧面/背面 视角的立绘？"
- 如果需要其他角色："是否为另一个角色生成立绘？"

## 注意事项

- 所有 prompt 必须使用英文（API 要求）
- 每次生图前都确认参数，避免浪费积分
- 生图 QPS 限制 1 次/秒，并发上限 5 任务
- 生成的图片 URL 有效期 7 天，请及时下载（MCP 工具会自动下载）
- 遵循项目协作协议：每一步都征求用户确认后再执行

