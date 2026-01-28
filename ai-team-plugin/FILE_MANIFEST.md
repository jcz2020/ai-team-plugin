# AI Team Plugin - 文件清单

本文档列出了 AI Team Plugin 项目的所有重要文件及其用途。

## 📁 项目结构

```
ai-team-plugin/
├── .claude-plugin/              # Plugin 配置目录
│   ├── plugin.json              # Plugin 元数据配置
│   ├── mcp-permissions.json     # MCP 工具权限配置 ⭐ NEW
│   └── mcp-permissions-schema.json # MCP 权限配置 Schema ⭐ NEW
├── agents/                      # 专业角色定义
│   ├── product-manager.md       # 产品经理
│   └── ui-ux-designer.md        # UI/UX 设计师
├── commands/                    # 命令定义
│   ├── ai-team.md              # AI 团队协作命令
│   └── assign.md               # 任务分配命令
├── skills/                      # 技能定义
│   └── task-dispatcher/
│       └── SKILL.md            # 智能路由技能
├── scripts/                     # 工具脚本
│   ├── validate-mcp-permissions.sh # MCP 权限验证脚本 ⭐ NEW
│   └── verify-plugin.sh        # 综合验证脚本 ⭐ NEW
├── docs/                        # 文档
│   ├── architecture.md         # 架构文档
│   ├── MCP_PERMISSIONS.md      # MCP 权限配置说明 ⭐ NEW
│   ├── MCP_PERMISSIONS_SUMMARY.md # MCP 权限配置总结 ⭐ NEW
│   ├── STRUCTURE_VALIDATION.md # 结构验证文档
│   ├── INSTALLATION_TEST.md    # 安装测试指南 ⭐ NEW
│   └── plans/                  # 实现计划
├── hooks/                       # Git Hooks 和集成脚本
│   ├── beads-integration.sh     # Beads 任务跟踪集成 ⭐ NEW
│   └── README.md                # Hooks 说明文档 ⭐ NEW
├── tests/                       # 测试文件
│   └── test-beads-integration.sh # Beads 集成测试 ⭐ NEW
├── README.md                    # 项目说明
└── FILE_MANIFEST.md             # 本文件
```

## 📄 文件说明

### Plugin 配置文件

#### `/root/dev/set_claude/ai-team-plugin/.claude-plugin/plugin.json`
- **用途**: Plugin 元数据配置
- **大小**: 226 字节
- **内容**: Plugin 名称、版本、描述、作者信息

#### `/root/dev/set_claude/ai-team-plugin/.claude-plugin/mcp-permissions.json` ⭐ NEW
- **用途**: MCP 工具权限配置
- **大小**: 13 KB
- **内容**: 11 个角色的 MCP 工具权限配置
- **特点**:
  - 细粒度权限控制（必需/可选/禁止）
  - 全局安全规则
  - MCP 工具注册表（9 个工具）
  - 权限分级（read/write/admin）

#### `/root/dev/set_claude/ai-team-plugin/.claude-plugin/mcp-permissions-schema.json` ⭐ NEW
- **用途**: MCP 权限配置的 JSON Schema 定义
- **大小**: 5.7 KB
- **内容**: 定义 mcp-permissions.json 的结构和验证规则
- **特点**:
  - 完整的类型定义
  - 字段约束和默认值
  - 枚举值验证

### 脚本文件

#### `/root/dev/set_claude/ai-team-plugin/scripts/validate-mcp-permissions.sh` ⭐ NEW
- **用途**: MCP 权限配置验证脚本
- **大小**: 4.9 KB
- **功能**:
  - JSON 语法验证
  - 角色数量统计
  - 必需字段检查
  - MCP 工具使用统计
  - 全局设置检查
  - 角色定义文件检查

#### `/root/dev/set_claude/ai-team-plugin/scripts/verify-plugin.sh` ⭐ NEW
- **用途**: 综合验证脚本 - 检查插件安装、配置和功能完整性
- **大小**: 18.5 KB
- **功能**:
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
- **输出格式**:
  - 文本（默认）- 彩色输出，易于阅读
  - JSON（--json）- 机器可读，适合 CI/CD
  - Markdown（--report）- 生成报告文档
- **运行模式**:
  - --quick - 快速验证（基础检查）
  - --full - 完整验证（包含详细报告）
  - --quiet - 静默模式（仅输出错误）

### 文档文件

#### `/root/dev/set_claude/ai-team-plugin/docs/MCP_PERMISSIONS.md` ⭐ NEW
- **用途**: MCP 权限配置详细说明
- **大小**: 1.9 KB
- **内容**:
  - 配置文件概述
  - 文件结构说明
  - 角色权限配置详解
  - MCP 工具注册表说明
  - 验证工具使用方法

#### `/root/dev/set_claude/ai-team-plugin/docs/MCP_PERMISSIONS_SUMMARY.md` ⭐ NEW
- **用途**: MCP 权限配置完成报告
- **大小**: 7.1 KB
- **内容**:
  - 配置概览
  - 11 个角色详细配置
  - MCP 工具统计
  - 安全规则列表
  - 权限分级说明
  - 验证结果

### 其他文档

#### `/root/dev/set_claude/ai-team-plugin/docs/architecture.md`
- **用途**: 项目架构文档
- **大小**: 2.0 KB
- **内容**: 系统架构、工作流程、技术栈

#### `/root/dev/set_claude/ai-team-plugin/docs/STRUCTURE_VALIDATION.md`
- **用途**: Plugin 结构验证文档
- **大小**: 4.5 KB
- **内容**: Plugin 目录结构、文件格式要求

#### `/root/dev/set_claude/ai-team-plugin/docs/INSTALLATION_TEST.md` ⭐ NEW
- **用途**: 插件安装测试指南
- **大小**: 15.2 KB
- **内容**:
  - 前置要求（系统要求、Claude Code 配置）
  - 安装方法（符号链接、复制、Git Clone）
  - 安装验证（快速验证、完整验证、手动验证）
  - 功能测试（5个测试用例）
  - 故障排除（5个常见问题及解决方案）
  - 测试报告（模板和自动化生成）
  - 持续监控（自动化测试脚本、健康检查）
  - 最佳实践（开发环境、生产环境、团队协作）
  - 附录（验证脚本选项、测试检查清单、常用命令）

#### `/root/dev/set_claude/ai-team-plugin/docs/BEADS_INTEGRATION.md` ⭐ NEW
- **用途**: Beads 任务跟踪集成指南
- **大小**: 7.8 KB
- **内容**:
  - Beads 系统概述和安装指南
  - 集成功能说明（任务创建、状态跟踪、决策记录、Git 同步）
  - 集成脚本使用方法
  - 配置选项和最佳实践
  - 故障排除指南
  - 完整工作流示例

## 📊 统计信息

### 配置文件
- Plugin 配置: 1 个
- MCP 权限配置: 1 个
- Schema 定义: 1 个

### 脚本文件
- 验证脚本: 2 个
- 集成脚本: 1 个 (beads-integration.sh) ⭐ NEW

### 文档文件
- 架构文档: 1 个
- MCP 权限文档: 2 个
- 验证文档: 2 个
- 集成文档: 2 个 (BEADS_INTEGRATION.md, hooks/README.md) ⭐ NEW

### 角色定义
- 已实现: 2 个（产品经理、UI/UX 设计师）
- 已配置权限: 11 个
- 待实现: 9 个

### MCP 工具
- 已注册: 9 个
- 分类:
  - automation: 1 个
  - documentation: 1 个
  - search: 1 个
  - design: 1 个
  - vision: 2 个
  - scraping: 1 个
  - development: 1 个
  - security: 1 个

## 🎯 下一步工作

1. ⏳ 为剩余 9 个角色创建详细的角色定义文件
2. ⏳ 实现智能路由系统的权限检查逻辑
3. ✅ 集成 Beads 任务跟踪系统
4. ⏳ 实现运行时 MCP 工具权限验证
5. ⏳ 编写单元测试和集成测试

## 📝 变更历史

### 2026-01-28
- ✅ 创建 `mcp-permissions.json` - 为 11 个角色配置 MCP 权限
- ✅ 创建 `mcp-permissions-schema.json` - JSON Schema 定义
- ✅ 创建 `validate-mcp-permissions.sh` - MCP 权限验证脚本
- ✅ 创建 `verify-plugin.sh` - 综合验证脚本（18.5 KB）
- ✅ 创建 `docs/MCP_PERMISSIONS.md` - 配置说明文档
- ✅ 创建 `docs/MCP_PERMISSIONS_SUMMARY.md` - 配置完成报告
- ✅ 创建 `docs/INSTALLATION_TEST.md` - 安装测试指南（15.2 KB）
- ✅ 创建 `docs/BEADS_INTEGRATION.md` - Beads 集成指南（7.8 KB） ⭐ NEW
- ✅ 创建 `hooks/beads-integration.sh` - Beads 集成脚本（3.1 KB） ⭐ NEW
- ✅ 创建 `hooks/README.md` - Hooks 说明文档 ⭐ NEW
- ✅ 创建 `tests/test-beads-integration.sh` - Beads 集成测试 ⭐ NEW
- ✅ 创建 `FILE_MANIFEST.md` - 本文件

---

**文档版本**: 1.0.0
**最后更新**: 2026-01-28
