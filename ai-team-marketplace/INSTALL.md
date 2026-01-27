# 🚀 AI Team Plugin 安装指南

## ✅ 正确的插件结构

已按照 Claude Code 官方规范创建 marketplace 结构：

```
ai-team-marketplace/
├── .claude-plugin/
│   └── marketplace.json      ✅ 市场配置
├── plugins/
│   └── ai-team/
│       ├── .claude-plugin/
│       │   └── plugin.json   ✅ 插件配置
│       ├── commands/         ✅ 命令 (ai-team.md, assign.md)
│       ├── skills/           ✅ 技能 (task-dispatcher/)
│       └── agents/           ✅ 角色 (product-manager.md, ui-ux-designer.md)
└── README.md
```

---

## 📦 安装步骤

### 方法 1: 使用本地 marketplace（推荐）

```bash
# 1. 添加本地市场
/plugin marketplace add /root/dev/set_claude/ai-team-marketplace

# 2. 安装插件
/plugin install ai-team

# 3. 验证安装
/plugin list | grep ai-team
```

### 方法 2: 通过 Git 仓库（如果推送到了 GitHub）

```bash
# 1. 添加市场
/plugin marketplace add https://github.com/your-username/ai-team-marketplace

# 2. 安装插件
/plugin install ai-team
```

---

## 🧪 测试命令

安装成功后，在新会话中测试：

```bash
# 测试 1: 主命令
/ai-team --help

# 测试 2: 分配任务
/assign product-manager 调研 Next.js 14

# 测试 3: UI 设计师
/assign ui-ux-designer 设计登录页面
```

---

## 🔍 验证安装

```bash
# 检查插件是否在缓存目录
ls ~/.claude/plugins/cache/ai-team-marketplace/ai-team/1.0.0/

# 应该看到以下目录：
# - commands/
# - skills/
# - agents/
# - .claude-plugin/
```

---

## ⚠️ 如果命令仍不被识别

### 检查 1: 确认插件已安装

```bash
/plugin list
```

**预期输出**: 应该看到 `ai-team`

### 检查 2: 查看插件详情

```bash
/plugin info ai-team
```

### 检查 3: 查看错误日志

如果有错误信息，请提供完整输出。

---

## 📝 关键改进

与之前的错误做法相比：

| 之前（错误） | 现在（正确） |
|------------|-------------|
| ❌ 直接在 `/root/.claude/plugins/` | ✅ 通过 marketplace 安装 |
| ❌ 符号链接 | ✅ `/plugin marketplace add` |
| ❌ 复制文件 | ✅ `/plugin install` |
| ❌ 在 settings.json 启用 | ✅ 插件管理器自动处理 |

---

## 🎯 下一步

1. **执行安装命令**
2. **重启 Claude Code**
3. **测试命令**
4. **反馈结果**

---

**Sources:**
- [从零开发 Claude Code 插件：完整实战指南](https://www.80aj.com/2026/01/12/claude-code-plugin-guide/)
- [Claude Code Plugins 深度指南](https://xiaolaiwo.com/archives/1473.html)
- [Claude Code 插件参考手册](http://www.runoob.com/claude-code/claude-code-plugin-ref.html)
