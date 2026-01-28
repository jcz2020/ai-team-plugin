# 验证脚本使用指南

AI Team Plugin 提供了两个验证脚本，用于检查插件配置和安装状态。

---

## 📋 脚本列表

### 1. MCP 权限验证脚本

**文件**: `scripts/validate-mcp-permissions.sh`

**用途**: 验证 MCP 权限配置文件的正确性

**功能**:
- JSON 语法验证
- 角色数量统计
- 必需字段检查
- MCP 工具使用统计
- 全局设置检查
- 角色定义文件检查

**使用方法**:
```bash
./scripts/validate-mcp-permissions.sh
```

### 2. 综合验证脚本

**文件**: `scripts/verify-plugin.sh`

**用途**: 全面检查插件安装、配置和功能完整性

**功能**:
- 基础结构检查（目录、文件）
- Plugin 配置检查（plugin.json, mcp-permissions.json）
- 命令文件检查（frontmatter, 格式）
- 技能文件检查（SKILL.md, 内容完整性）
- 角色定义文件检查（frontmatter, MCP 配置）
- 文档完整性检查（README, 架构文档）
- 脚本文件检查（执行权限）
- 测试文件检查
- 安装路径检查（符号链接/复制）
- Claude Code 配置检查

---

## 🚀 快速开始

### 快速验证（推荐日常使用）

```bash
./scripts/verify-plugin.sh --quick
```

**输出示例**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AI Team Plugin 安装验证 (quick 模式)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 基础结构检查
✓ Plugin 配置目录 存在
✓ 角色定义目录 存在
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ 验证通过！插件安装完整
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 完整验证（发布前使用）

```bash
./scripts/verify-plugin.sh --full
```

### 生成 JSON 报告（适合 CI/CD）

```bash
./scripts/verify-plugin.sh --json --quiet > report.json
```

### 生成 Markdown 报告（适合文档）

```bash
./scripts/verify-plugin.sh --report > verification-report.md
```

---

## 📖 命令选项

### verify-plugin.sh 选项

| 选项 | 说明 | 适用场景 |
|------|------|----------|
| `--quick` | 快速验证（基础检查） | 日常开发 |
| `--full` | 完整验证（包含详细报告） | 发布前检查 |
| `--json` | 输出 JSON 格式 | CI/CD 集成 |
| `--report` | 生成 Markdown 报告 | 文档归档 |
| `--quiet` | 静默模式（仅输出错误） | 自动化脚本 |
| `--help` | 显示帮助信息 | 查看用法 |

### 选项组合示例

```bash
# 快速验证 + JSON 输出
./scripts/verify-plugin.sh --quick --json --quiet

# 完整验证 + 生成报告
./scripts/verify-plugin.sh --full --report > report.md

# 静默模式（仅显示错误）
./scripts/verify-plugin.sh --quick --quiet
```

---

## 📊 验证结果解读

### 成功输出

```
总检查项: 20
通过检查: 37
失败检查: 0
警告数量: 2
成功率: 185.00%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ 验证通过！插件安装完整
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**含义**: 所有必需检查通过，插件可以正常使用。如果有警告，建议查看并修复。

### 失败输出

```
总检查项: 20
通过检查: 35
失败检查: 2
警告数量: 1
成功率: 175.00%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ❌ 验证失败，发现 2 个问题
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

失败项:
  ✗ Plugin 元数据配置 不存在
  ✗ 命令文件 ai-team 不存在

建议:
  1. 检查插件目录结构
  2. 验证配置文件格式
  3. 运行: ./scripts/validate-mcp-permissions.sh
```

**含义**: 发现必须修复的问题，请按照建议操作后重新验证。

---

## 🔧 常见问题

### Q: 验证失败但插件能正常使用？

**A**: 验证脚本可能检测到潜在问题（如 frontmatter 格式），建议修复以确保最佳兼容性。

### Q: 成功率超过 100% 正常吗？

**A**: 正常。因为某些检查项会触发多个子检查（如 JSON 语法 + 字段验证）。

### Q: 如何在 CI/CD 中集成？

**A**: 使用 JSON 输出模式，配合 jq 处理结果：

```bash
#!/bin/bash
./scripts/verify-plugin.sh --json --quiet > report.json
STATUS=$(jq -r '.status' report.json)

if [ "$STATUS" = "success" ]; then
    echo "✅ 验证通过"
    exit 0
else
    echo "❌ 验证失败"
    jq '.issues' report.json
    exit 1
fi
```

### Q: 警告需要修复吗？

**A**: 警告不影响插件基本功能，但建议修复以获得最佳体验。例如：
- ⚠️ 有 9 个角色已配置但未实现 → 可以继续使用，建议补充角色定义
- ⚠️ AI Team 插件未在 settings.json 中配置 → 建议配置以启用插件

---

## 📝 最佳实践

### 开发环境

```bash
# 每次修改后运行快速验证
./scripts/verify-plugin.sh --quick
```

### 发布前检查

```bash
# 运行完整验证并生成报告
./scripts/verify-plugin.sh --full --report > pre-release-report.md

# 验证 MCP 权限配置
./scripts/validate-mcp-permissions.sh
```

### CI/CD 集成

```yaml
# .github/workflows/verify.yml
- name: Verify Plugin
  run: |
    ./scripts/verify-plugin.sh --json --quiet > report.json
    jq -e '.status == "success"' report.json
```

---

## 🔗 相关文档

- [安装测试指南](./INSTALLATION_TEST.md)
- [MCP 权限配置](./MCP_PERMISSIONS.md)
- [项目 README](../README.md)

---

**最后更新**: 2026-01-28
