# AI Team Plugin 测试套件

本目录包含 AI Team Plugin 的完整测试套件，用于验证插件的功能、配置和集成。

---

## 📁 测试文件结构

```
tests/
├── command-recognition-test.md      # 命令识别测试指南（详细）
├── product-manager-test.md          # 产品经理角色测试
├── test-command-recognition.sh      # 自动化验证脚本
├── COMMAND_RECOGNITION_TEST_RESULTS.md  # 测试结果报告
└── README.md                         # 本文件
```

---

## 🧪 测试类型

### 1. 命令识别测试

**目标**: 验证 AI Team Plugin 的命令能够被 Claude Code 正确识别和执行

**测试范围**:
- 基础命令识别 (`/ai-team`, `/assign`)
- 参数解析（单参数、多参数、特殊字符）
- MCP 配置加载（必需、可选、禁止）
- 错误处理（无效角色、MCP 不可用）

**测试方式**:
- 自动化脚本验证文件结构和配置
- 手动测试实际命令识别

**详细文档**: [command-recognition-test.md](command-recognition-test.md)

---

### 2. 角色行为测试

**目标**: 验证各个专业角色 subagent 的行为符合预期

**当前实现**:
- ✅ 产品经理测试（product-manager-test.md）

**测试重点**:
- MCP 工具使用强制要求
- 角色边界控制（不越界）
- 完整工作流程执行
- 错误和偏离处理

**详细文档**: [product-manager-test.md](product-manager-test.md)

---

## 🚀 快速开始

### 自动化验证

```bash
# 进入项目目录
cd /root/dev/set_claude/ai-team-plugin

# 执行自动化验证脚本
./tests/test-command-recognition.sh
```

**预期输出**:
```
🧪 AI Team Plugin 命令识别测试
================================

阶段 1: 文件结构检查
--------------------------------
测试: Marketplace 配置文件存在 ... ✅ 通过
...

阶段 6: 内容质量检查
--------------------------------
...

================================
测试汇总
================================
通过: 31
失败: 0
跳过: 1
总计: 32

🎉 所有测试通过！
```

---

### 手动命令测试

在自动化测试通过后，进行实际命令测试：

**前置条件**:
1. 确保 marketplace 已添加
2. 确保插件已安装
3. 重启 Claude Code

**测试步骤**:

1. **测试基础命令识别**
```
/ai-team --help
```

预期: 命令被识别，显示帮助信息或执行流程

2. **测试参数解析**
```
/assign product-manager 调研 AI 编码工具市场
```

预期:
- 命令被识别
- 角色名: `product-manager`
- 任务描述: `调研 AI 编码工具市场`
- MCP 配置被加载

3. **验证 MCP 配置**
```
在 subagent prompt 中检查:
- 必需 MCP: playwright
- 可选 MCP: context7
- 禁止 MCP: Write, Edit
```

---

## 📊 测试结果

### 最新测试结果

**测试日期**: 2026-01-28
**测试版本**: 1.0.0
**通过率**: 96.9% (31/32)
**状态**: ✅ 通过

详细结果: [COMMAND_RECOGNITION_TEST_RESULTS.md](COMMAND_RECOGNITION_TEST_RESULTS.md)

---

## 🔧 故障排除

### 常见问题

#### 问题 1: 命令未被识别

**症状**: 执行命令时出现 "Unknown skill" 错误

**解决方案**:
```bash
# 1. 检查插件是否已安装
ls ~/.claude/plugins/cache/ai-team-marketplace/ai-team/1.0.0/

# 2. 如果不存在，重新安装
/plugin marketplace add /root/dev/set_claude/ai-team-marketplace
/plugin install ai-team

# 3. 重启 Claude Code
```

---

#### 问题 2: 自动化测试失败

**症状**: `test-command-recognition.sh` 报错

**解决方案**:
```bash
# 检查文件路径
cat tests/test-command-recognition.sh | grep PROJECT_ROOT

# 确保在正确的目录
cd /root/dev/set_claude/ai-team-plugin

# 检查文件权限
chmod +x tests/test-command-recognition.sh
```

---

#### 问题 3: MCP 配置未加载

**症状**: Subagent 未收到 MCP 权限信息

**解决方案**:
```bash
# 验证 mcp-permissions.json 存在且格式正确
cat ai-team-marketplace/plugins/ai-team/.claude-plugin/mcp-permissions.json | jq .

# 检查角色名称是否匹配
cat ai-team-marketplace/plugins/ai-team/.claude-plugin/mcp-permissions.json | jq '.roles | keys'
```

---

## 📝 添加新测试

### 创建新的角色测试

1. 创建测试文件: `tests/<role-name>-test.md`
2. 使用以下模板:

```markdown
# <角色名称>角色测试

测试 <角色名称> subagent 核心功能。

---

## 测试场景 1: <场景名称>

### 目标
<描述测试目标>

### 输入
```
<测试输入>
```

### 预期行为
- ✅ <预期行为 1>
- ✅ <预期行为 2>

### 失败条件
- 🚨 <失败条件 1>

---

## 测试场景 2: ...
```

3. 更新本 README.md，添加新测试的说明

---

## 📚 相关文档

- [命令识别测试指南](command-recognition-test.md)
- [产品经理角色测试](product-manager-test.md)
- [测试结果报告](COMMAND_RECOGNITION_TEST_RESULTS.md)
- [MCP 权限配置文档](../docs/MCP_PERMISSIONS.md)
- [完整实现计划](../../docs/plans/2026-01-28-ai-team-plugin-fix-and-complete.md)

---

## 🤝 贡献指南

测试是保证插件质量的重要环节。欢迎贡献新的测试用例！

**贡献步骤**:
1. Fork 项目
2. 创建测试分支: `git checkout -b test/<test-name>`
3. 编写测试用例
4. 运行测试确保通过
5. 提交 PR

**测试编写规范**:
- 每个测试场景应包含: 目标、输入、预期行为、失败条件
- 使用 ✅ 表示预期行为，❌ 表示错误条件
- 提供清晰的验收标准
- 包含自动化测试脚本（如果适用）

---

**最后更新**: 2026-01-28
**维护者**: AI Team Plugin 开发团队
