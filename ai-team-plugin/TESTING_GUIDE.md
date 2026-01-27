# 测试指南（修复后）

## ✅ 已修复的问题

1. **plugin.json**: 移除了 `version` 和 `capabilities` 字段
2. **SKILL.md**: 移除了 `version` 字段
3. **commands/*.md**: 移除了 `argument-hint` 和 `model` 字段

## 🔄 重新加载插件

**重要**: 需要重新启动 Claude Code 会话才能加载新的插件配置。

### 方法 1: 重启会话（推荐）
关闭当前会话，重新打开 Claude Code。

### 方法 2: 重新加载配置
在 Claude Code 中触发重新加载。

---

## 🧪 测试步骤

### 测试 1: 验证命令是否识别

在**新的会话**中尝试：

```bash
/ai-team --help
```

**预期**: 命令被识别（不再报 "Unknown skill"）

---

### 测试 2: 测试 assign 命令

```bash
/assign product-manager 调研 Next.js 14
```

**预期**:
- ✅ 命令被识别
- ✅ 读取 `mcp-permissions.json`
- ✅ 显示产品经理的 MCP 配置（playwright）

**关键验证点**:
- 回复中应该包含 "必需 MCP: playwright"
- 回复中应该包含 "必须使用浏览器 MCP"

---

### 测试 3: 测试 UI 设计师

```bash
/assign ui-ux-designer 设计登录页面
```

**预期**:
- ✅ 命令被识别
- ✅ 读取 `mcp-permissions.json`
- ✅ 显示 UI 设计师的 MCP 配置（mastergo-mcp）

**关键验证点**:
- 回复中应该包含 "必需 MCP: mastergo-mcp"
- 回复中应该包含 "必须使用 MasterGo MCP"

---

### 测试 4: 验证智能路由

```bash
# 不使用命令前缀
帮我开发一个登录功能
```

**预期**:
- ✅ 自动触发 `task-dispatcher` 技能
- ✅ 识别"开发"关键词
- ✅ 开始任务分析

---

## 📊 验证 MCP 配置加载

### 手动检查 MCP 配置文件

```bash
cat /root/dev/set_claude/ai-team-plugin/.claude-plugin/mcp-permissions.json | grep -A 5 "product-manager"
```

**预期输出**:
```json
"product-manager": {
  "required_mcps": [
    {
      "name": "playwright",
      "purpose": "联网信息收集和市场调研",
      ...
```

---

## ⚠️ 可能的问题

### 问题 1: 命令仍未识别

**症状**: 仍报 "Unknown skill"

**解决方案**:
1. 确认已重启 Claude Code 会话
2. 检查符号链接: `ls -la /root/.claude/plugins/ai-team`
3. 检查命令文件: `ls /root/dev/set_claude/ai-team-plugin/commands/`

### 问题 2: MCP 工具未安装

**症状**: 回复说 "MCP 工具不可用"

**这是正常的**！关键验证点是：
- ✅ 配置是否被正确读取
- ✅ 提示中是否包含 MCP 使用说明
- ✅ 是否有"必须使用"的提示

MCP 服务器（如 mastergo-mcp）可能需要单独安装，但配置加载逻辑应该是正确的。

---

## 📝 测试报告模板

```
## 测试结果

### 环境
- Claude Code 版本: ___
- 是否重启会话: ✅ / ❌

### 测试 1: 命令识别
- /ai-team --help: ✅ / ❌
- 结果: _______

### 测试 2: 产品经理 MCP
- /assign product-manager ...: ✅ / ❌
- MCP 配置加载: ✅ / ❌
- 包含 "playwright": ✅ / ❌

### 测试 3: UI 设计师 MCP
- /assign ui-ux-designer ...: ✅ / ❌
- MCP 配置加载: ✅ / ❌
- 包含 "mastergo-mcp": ✅ / ❌

### 测试 4: 智能路由
- "帮我开发...": ✅ / ❌
- 自动触发 task-dispatcher: ✅ / ❌

### 总体评估
- 通过: ___/4
- 核心功能状态: ___

### 发现的问题
1. _______
2. _______
```

---

**请重启 Claude Code 会话后再测试！** 🚀
