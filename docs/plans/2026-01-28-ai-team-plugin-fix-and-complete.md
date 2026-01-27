# AI Team Plugin 修复与优化实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**目标:** 修复 AI Team Plugin 的结构问题，使其符合 Claude Code 官方规范，并完成剩余的 8 个角色实现

**架构:** 采用三层架构 - Marketplace（分发层）+ Plugin（功能层）+ Roles（执行层），遵循官方 marketplace 结构规范

**Tech Stack:** Claude Code Plugin System, Markdown, JSON, Bash scripts, Git hooks

---

## 📋 当前状态分析

### ✅ 已完成（7/22 任务）
1. ✅ Plugin 基础结构
2. ✅ MCP 权限控制系统
3. ✅ 核心命令（ai-team.md, assign.md）
4. ✅ 智能路由技能
5. ✅ 两个核心角色（产品经理、UI 设计师）

### ❌ 发现的问题
根据官方文档分析，之前的实现存在以下**根本性错误**：

1. **目录结构错误**
   - ❌ 缺少 `marketplace.json` 配置
   - ❌ 直接放置在 `/root/.claude/plugins/` 而非通过 marketplace
   - ❌ 缺少正确的 marketplace 结构

2. **配置文件格式问题**
   - ❌ plugin.json 包含不支持的字段（capabilities）
   - ❌ SKILL.md 包不支持的字段（version）
   - ❌ commands 包含不支持的 frontmatter

3. **安装方式错误**
   - ❌ 使用符号链接
   - ❌ 直接复制文件
   - ❌ 在 settings.json 手动启用
   - ✅ **正确**: 使用 `/plugin marketplace add` 和 `/plugin install`

### 🎯 正确的实现方式（根据官方文档）

**Marketplace 结构**:
```
ai-team-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # 必需
├── plugins/
│   └── ai-team/
│       ├── .claude-plugin/
│       │   └── plugin.json   # 必需
│       ├── commands/
│       │   ├── ai-team.md
│       │   └── assign.md
│       ├── skills/
│       │   └── task-dispatcher/
│       │       └── SKILL.md
│       ├── agents/
│       │   ├── product-manager.md
│       │   └── ui-ux-designer.md
│       └── templates/
│           └── mcp-control-template.md
```

**安装方式**:
```bash
/plugin marketplace add /root/dev/set_claude/ai-team-marketplace
/plugin install ai-team
```

---

## 📊 任务分解

### 阶段 1: 修复 Plugin 结构（紧急）

#### Task 1: 修复 Marketplace 配置

**Files:**
- Modify: `ai-team-marketplace/.claude-plugin/marketplace.json`

**Step 1: 验证 marketplace.json 格式**

Run: `cat /root/dev/set_claude/ai-team-marketplace/.claude-plugin/marketplace.json | jq .`

Expected: Valid JSON with required fields (name, owner, metadata, plugins)

**Step 2: 检查插件版本一致性**

Run: ```bash
grep -A 5 '"plugins"' /root/dev/set_claude/ai-team-marketplace/.claude-plugin/marketplace.json | grep '"version"'
```

Expected: All versions should be "1.0.0" and consistent

**Step 3: Commit**

```bash
git add ai-team-marketplace/.claude-plugin/marketplace.json
git commit -m "fix: ensure marketplace.json version consistency"
```

---

#### Task 2: 验证 Plugin 配置

**Files:**
- Verify: `ai-team-marketplace/plugins/ai-team/.claude-plugin/plugin.json`

**Step 1: 验证 plugin.json 格式**

Run: `cat /root/dev/set_claude/ai-team-marketplace/plugins/ai-team/.claude-plugin/plugin.json | jq .`

Expected: Valid JSON without unsupported fields

**Step 2: 检查关键字段**

Required fields: `name`, `version`, `description`, `author`

**Step 3: Remove unsupported fields if any**

If found, remove: `capabilities`, `license` (if not in official spec)

**Step 4: Commit**

```bash
git add ai-team-marketplace/plugins/ai-team/.claude-plugin/plugin.json
git commit -m "fix: remove unsupported fields from plugin.json"
```

---

#### Task 3: 修复命令文件 frontmatter

**Files:**
- Modify: `ai-team-marketplace/plugins/ai-team/commands/ai-team.md`
- Modify: `ai-team-marketplace/plugins/ai-team/commands/assign.md`

**Step 1: 验证当前 frontmatter**

Run: ```bash
head -5 ai-team-marketplace/plugins/ai-team/commands/ai-team.md
```

**Step 2: 移除不支持的 frontmatter 字段**

According to official docs, only `description` and `allowed-tools` are supported.

Remove: `argument-hint`, `model`

**Step 3: 确保用命令式语气**

Check if commands use imperative mood ("立即执行..." instead of "本命令用于...")

**Step 4: Commit**

```bash
git add ai-team-marketplace/plugins/ai-team/commands/
git commit -m "fix: remove unsupported frontmatter from commands"
```

---

#### Task 4: 修复技能文件 frontmatter

**Files:**
- Modify: `ai-team-marketplace/plugins/ai-team/skills/task-dispatcher/SKILL.md`

**Step 1: 验证当前 frontmatter**

Run: ```bash
head -5 ai-team-marketplace/plugins/ai-team/skills/task-dispatcher/SKILL.md
```

**Step 2: 移除不支持的字段**

Remove: `version`

**Step 3: 验证必需字段**

Required: `name`, `description`

**Step 4: Commit**

```bash
git add ai-team-marketplace/plugins/ai-team/skills/task-dispatcher/SKILL.md
git commit -m "fix: remove unsupported version from skill"
```

---

### 阶段 2: 测试 Marketplace 安装

#### Task 5: 验证 Marketplace 结构

**Files:**
- Create: `/root/dev/set_claude/ai-team-marketplace/README.md`

**Step 1: 创建 README**

```markdown
# AI Team Marketplace

AI 专业团队插件市场，提供对话式智能调度和 MCP 工具控制功能。

## 安装

```bash
/plugin marketplace add /root/dev/set_claude/ai-team-marketplace
/plugin install ai-team
```

## 包含插件

- **ai-team**: AI 专业团队核心插件
```

**Step 2: 验证目录结构**

Run: ```bash
find /root/dev/set_claude/ai-team-marketplace -type f -name "*.json" | sort
```

Expected:
```
.ai-team-marketplace/.claude-plugin/marketplace.json
ai-team-marketplace/plugins/ai-team/.claude-plugin/plugin.json
```

**Step 3: Commit**

```bash
git add /root/dev/set_claude/ai-team-marketplace/README.md
git commit -m "docs: add marketplace README"
```

---

#### Task 6: 测试插件安装

**Step 1: 尝试添加 marketplace**

Run in Claude Code:
```
/plugin marketplace add /root/dev/set_claude/ai-team-marketplace
```

**Expected**: Marketplace added successfully

**Step 2: 尝试安装插件**

Run:
```
/plugin install ai-team
```

**Expected**: Plugin installed to `~/.claude/plugins/cache/ai-team-marketplace/ai-team/1.0.0/`

**Step 3: 验证安装**

Run:
```bash
ls ~/.claude/plugins/cache/ai-team-marketplace/ai-team/1.0.0/commands/
```

Expected: Should see `ai-team.md` and `assign.md`

**Step 4: 如果成功，提交记录**

```bash
git add /root/dev/set_claude/ai-team-marketplace/INSTALL.md
git commit -m "docs: record installation success"
```

---

### 阶段 3: 命令测试与验证

#### Task 7: 测试基础命令识别

**Step 1: 在新会话中测试**

Run in Claude Code:
```
/ai-team --help
```

**Expected**: Command is recognized (no "Unknown skill" error)

**Step 2: 测试 assign 命令**

Run:
```
/assign product-manager 测试
```

**Expected**: Command is recognized

**Step 3: 验证输出**

Check if:
- ✅ MCP 配置被加载
- ✅ 提示中包含 "必需 MCP: playwright"
- ✅ 提示中包含 "必须使用浏览器 MCP"

**Step 4: 记录测试结果**

Create: `docs/plans/test-results.md`

Document:
- 命令是否被识别
- MCP 配置是否加载
- 任何错误信息

---

### 阶段 4: 实现剩余角色 (Task 8-15)

#### Task 8: 实现架构师角色

**Files:**
- Create: `ai-team-marketplace/plugins/ai-team/agents/architect.md`

**Step 1: 编写架构师 agent 定义**

```markdown
---
name: architect
description: 系统架构师，负责技术选型、系统设计、性能规划
model: inherit
color: blue
---

# 架构师 Subagent

你是专业的系统架构师，负责技术架构设计和规划。

## 核心职责

1. **技术选型**
   - 评估技术方案的可行性
   - 对比不同技术栈的优劣
   - 考虑团队技能和项目需求

2. **系统设计**
   - 定义系统架构
   - 设计模块边界和接口
   - 规划技术演进路径

3. **性能规划**
   - 识别性能瓶颈
   - 设计缓存策略
   - 规划扩展方案

## 工作流程

### 阶段 1: 需求分析

理解产品需求，识别技术约束。

### 阶段 2: 架构设计

**输出**:
```markdown
## 架构设计文档

### 技术选型
- 框架: ...
- 数据库: ...
- 缓存: ...

### 系统架构
- 分层架构
- 模块划分
- 接口定义

### 性能考虑
- 预期QPS
- 缓存策略
- 扩展方案
```
```

**Step 3: Commit**

```bash
git add ai-team-marketplace/plugins/ai-team/agents/architect.md
git commit -m "feat: add architect agent"
```

---

#### Task 9: 实现开发工程师角色

**Files:**
- Create: `ai-team-marketplace/plugins/ai-team/agents/developer.md`

**Step 1: 编写开发工程师 agent 定义**

```markdown
---
name: developer
description: 开发工程师，负责代码实现、功能开发、Bug 修复
model: inherit
color: green
---

# 开发工程师 Subagent

你是专业的开发工程师，负责实现代码功能。

## 核心职责

1. **代码实现**
   - 遵循 TDD 原则
   - 编写单元测试
   - 代码文档

2. **Bug 修复**
   - 定位问题根因
   - 修复缺陷
   - 添加回归测试

## 代码规范

- 函数长度: ≤ 50 行
- 文件长度: ≤ 200 行
- 遵循 CLAUDE.md 规范

## 工作流程

### 1. 理解需求
读取任务描述，理解功能需求。

### 2. 编写测试 (TDD)
```bash
# 先写测试
pytest tests/test_feature.py

# 确保测试失败
```

### 3. 实现功能
编写最简代码使测试通过。

### 4. 代码审查
- 自查代码质量
- 遵循规范

### 5. 提交代码
```bash
git add .
git commit -m "feat: implement feature"
```

## 防护机制

- **目标确认**: 复述任务
- **进度同步**: 每步报告
- **偏离检测**: 超时停止
```

**Step 2: Commit**

```bash
git add ai-team-marketplace/plugins/ai-team/agents/developer.md
git commit -m "feat: add developer agent"
```

---

#### Task 10-15: 实现其他角色

重复类似流程创建：

**Task 10**: 测试工程师
- File: `ai-team-marketplace/plugins/ai-team/agents/tester.md`
- 职责: 测试策略、自动化测试、质量保障

**Task 11**: 代码审查员
- File: `ai-team-marketplace/plugins/ai-team/agents/code-reviewer.md`
- 职责: 规范检查、坏味道检测

**Task 12**: 前端专家
- File: `ai-team-marketplace/plugins/ai-team/agents/frontend-expert.md`
- 职责: 前端实现、交互开发、性能优化

**Task 13**: 后端专家
- File: `ai-team-marketplace/plugins/ai-team/agents/backend-expert.md`
- 职责: API 设计、业务逻辑、数据处理

**Task 14**: 数据库专家
- File: `ai-team-marketplace/plugins/ai-team/agents/database-expert.md`
- 职责: 数据建模、查询优化

**Task 15: 安全专家
- File: `ai-team-marketplace/plugins/ai-team/agents/security-expert.md`
- 职责: 安全审查、漏洞检测

**Task 16: DevOps 工程师
- File: `ai-team-marketplace/plugins/ai-team/agents/devops-engineer.md`
- 职责: CI/CD、部署自动化

---

### 阶段 5: 集成与优化 (Task 16-17)

#### Task 17: 集成 Beads 任务跟踪

**Files:**
- Modify: `ai-team-marketplace/plugins/ai-team/commands/ai-team.md`
- Create: `ai-team-marketplace/plugins/ai-team/hooks/beads-integration.sh`

**Step 1: 在 ai-team.md 中添加 Beads 集成代码**

在命令文件末尾添加 Beads 调用逻辑。

**Step 2: 创建 Beads 集成脚本**

```bash
#!/bin/bash
# Beads 任务集成脚本
beads_create_task() {
  bd create "$1" -t feature --notes "$2" --json
}

beads_complete_task() {
  bd close "$1" --reason "Completed"
}
```

**Step 3: Commit**

```bash
git add ai-team-marketplace/plugins/ai-team/
git commit -m "feat: integrate beads task tracking"
```

---

#### Task 18: 配置 Git Hooks

**Files:**
- Create: `ai-team-marketplace/plugins/ai-team/hooks/pre-commit-check.sh`
- Create: `ai-team-marketplace/plugins/ai-team/hooks/hooks.json`

**Step 1: 创建 pre-commit hook**

```bash
#!/bin/bash
echo "🔍 运行代码质量检查..."

# 检查文件行数
find . -name "*.js" -o -name "*.ts" -o -name "*.py" | while read file; do
  lines=$(wc -l < "$file")
  if [ "$lines" -gt 200 ]; then
    echo "⚠️  警告: $file 超过 200 行 ($lines 行)"
  fi
done
```

**Step 2: 配置 hooks.json**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-check.sh $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

**Step 3: 提交**

```bash
git add ai-team-marketplace/plugins/ai-team/hooks/
git commit -m "feat: add git hooks for automation"
```

---

### 阶段 6: 测试与发布 (Task 19-22)

#### Task 19: 端到端测试

**Step 1: 创建测试场景文档**

Create: `ai-team-marketplace/tests/e2e-test-scenarios.md`

**Step 2: 执行测试**

Test:
1. 简单任务: `/assign developer 修复登录bug`
2. 复杂任务: `/ai-team 开发用户权限管理`
3. UI 设计: `/assign ui-ux-designer 设计页面

**Step 3: 记录结果**

Document test results and any issues.

**Step 4: Commit**

```bash
git add ai-team-marketplace/tests/
git commit -m "test: add e2e test scenarios and results"
```

---

#### Task 20: 性能优化与文档完善

**Step 1: 重构超长文件**

Target: `ai-team.md` (429 lines → 拆分为模块化子命令)

**Step 2: 优化 MCP 配置加载**

缓存机制，避免重复读取。

**Step 3: 完善文档**

- API 文档
- 用户指南
- 开发者指南

**Step 4: Commit**

```bash
git add ai-team-marketplace/docs/
git commit -m "docs: complete documentation"
```

---

#### Task 21: 最终测试

**Step 1: 全面测试**

所有角色、所有命令、所有工作流。

**Step 2: 性能测试**

- 命令响应时间
- MCP 加载速度
- 内存占用

**Step 3: 安全测试**

- MCP 权限隔离
- 输入验证
- 防止注入攻击

**Step 4: Commit**

```bash
git add .
git commit -m "test: final testing complete"
```

---

#### Task 22: 发布准备

**Step 1: 更新版本号**

修改 `marketplace.json` 和 `plugin.json` 到 `1.0.1` (如果需要)

**Step 2: 打包发布**

```bash
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

**Step 3: 创建 Release Notes**

Create: `RELEASE_NOTES.md`

**Step 4: Commit**

```bash
git add RELEASE_NOTES.md
git commit -m "chore: prepare v1.0.0 release"
```

---

## 🔑 关键改进

### 1. 符合官方规范
- ✅ 正确的 Marketplace 结构
- ✅ 符合规范的配置文件格式
- ✅ 正确的安装方式

### 2. 完整的角色体系
- ✅ 11 个专业角色全覆盖
- ✅ 每个 role 有明确的职责边界
- ✅ MCP 工具细粒度控制

### 3. 质量保障
- ✅ TDD 开发
- ✅ 双阶段审查
- ✅ Git hooks 自动化
- ✅ 端到端测试

### 4. 文档完善
- ✅ 安装指南
- ✅ API 文档
- ✅ 测试文档
- ✅ 架构文档

---

## 📊 验收标准

### 功能完整性
- ✅ 所有 11 个角色实现
- ✅ MCP 权限控制工作正常
- ✅ 命令可被识别
- ✅ 技能自动触发

### 代码质量
- ✅ 测试覆盖率 ≥ 80%
- ✅ 所有文件符合行数规范
- ✅ 无架构坏味道

### 性能指标
- ✅ 简单任务响应 < 5 秒
- ✅ 复杂任务响应 < 2 分钟
- ✅ MCP 加载 < 1 秒

---

## 🚀 执行建议

建议使用 **Subagent-Driven 方式**执行此计划，因为：

1. **任务独立**: 大部分角色实现相互独立
2. **需要频繁审查**: 每个角色定义都需要质量检查
3. **快速迭代**: Fresh subagent per task = 高质量

或者使用 **Parallel Session** 方式，因为：
1. 计划已完整编写
2. 可以批次执行
3. 有检查点

---

**Sources:**
- [从零开发 Claude Code 插件：完整实战指南](https://www.80aj.com/2026/01/12/claude-code-plugin-guide/)
- [Claude Code Plugins 深度指南](https://xiaolaiwo.com/archives/1473.html)
- [Claude Code 插件参考手册](http://www.runoob.com/claude-code/claude-code-plugin-ref.html)
