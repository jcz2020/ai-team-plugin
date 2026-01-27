# 🔧 问题诊断与解决

## 🐛 **发现的问题**

命令 `/ai-team` 和 `/assign` 未被识别，报错 "Unknown skill"。

## 🔍 **根本原因**

**符号链接不完整**: 使用 `ln -s` 创建符号链接时，隐藏目录 `.claude-plugin/` 没有被正确链接。

```bash
# 之前的做法（有问题）
ln -s /root/dev/set_claude/ai-team-plugin /root/.claude/plugins/ai-team
# 问题：.claude-plugin/ 目录缺失
```

## ✅ **解决方案**

**直接复制插件文件**，而不是使用符号链接：

```bash
# 复制所有文件
cp -r /root/dev/set_claude/ai-team-plugin/* /root/.claude/plugins/ai-team/

# 单独复制隐藏目录
cp -r /root/dev/set_claude/ai-team-plugin/.claude-plugin /root/.claude/plugins/ai-team/
```

## 📊 **验证步骤**

### 1. 确认文件存在

```bash
# 检查命令文件
ls /root/.claude/plugins/ai-team/commands/
# 应该看到: ai-team.md, assign.md

# 检查插件配置
ls /root/.claude/plugins/ai-team/.claude-plugin/
# 应该看到: plugin.json, mcp-permissions.json

# 检查技能文件
ls /root/.claude/plugins/ai-team/skills/task-dispatcher/
# 应该看到: SKILL.md
```

### 2. 确认 settings.json

```bash
cat /root/.claude/settings.json | grep ai-team
# 应该看到: "ai-team": true
```

### 3. 测试命令

在**新的 Claude Code 会话**中测试：

```bash
/ai-team --help
```

**预期**: 命令被识别（不再报 "Unknown skill"）

---

## 🎯 **当前状态**

✅ **已完成的修复**:
1. Plugin 格式符合官方规范
2. Plugin 在 settings.json 中已启用
3. 所有文件已复制到正确位置
4. .claude-plugin 目录完整

✅ **文件清单**:
- `/root/.claude/plugins/ai-team/.claude-plugin/plugin.json`
- `/root/.claude/plugins/ai-team/.claude-plugin/mcp-permissions.json`
- `/root/.claude/plugins/ai-team/commands/ai-team.md`
- `/root/.claude/plugins/ai-team/commands/assign.md`
- `/root/.claude/plugins/ai-team/skills/task-dispatcher/SKILL.md`
- `/root/.claude/plugins/ai-team/agents/product-manager.md`
- `/root/.claude/plugins/ai-team/agents/ui-ux-designer.md`

---

## 🚀 **下一步**

**请完全重启 Claude Code**，然后测试：

```bash
# 测试 1
/ai-team --help

# 测试 2
/assign product-manager 调研 Vue 3

# 测试 3
/assign ui-ux-designer 设计登录页面
```

---

## 📝 **如果仍然失败**

如果重启后命令仍未识别，请提供：

1. Claude Code 版本
2. 错误信息的完整截图
3. 以下命令的输出：
```bash
ls -la /root/.claude/plugins/ai-team/commands/
cat /root/.claude/settings.json | grep -A 2 -B 2 ai-team
```

---

**提交记录**: `a1b990f` - 复制插件文件到 plugins 目录
