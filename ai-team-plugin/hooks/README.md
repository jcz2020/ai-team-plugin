# Hooks 目录

本目录包含 AI Team Plugin 的 Git hooks 和集成脚本。

## 文件说明

### Git Hooks

#### 1. pre-commit.sh
提交前检查脚本，确保代码质量和配置正确。

**检查项目**:
- JSON 配置文件语法验证（plugin.json, mcp-permissions.json）
- Markdown 文件 frontmatter 格式检查
- 文件行数限制检查（动态语言 ≤200 行，静态语言 ≤250 行）
- 目录结构限制检查（单层目录 ≤8 个文件）
- MCP 权限配置验证
- 脚本可执行权限检查

#### 2. commit-msg.sh
提交信息格式验证脚本，确保提交信息符合规范。

**验证规则**:
- 标题长度 ≤72 字符
- 格式: `<type>: <subject>`
- 允许的类型: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert
- 标题和正文之间应有空行
- 正文每行 ≤80 字符
- 标题不应以句号结尾
- 标题应使用小写字母（专有名词除外）

**示例**:
```
feat: 实现产品经理角色
fix: 修复 MCP 权限验证问题
docs: 更新 README 使用指南
refactor: 重构命令文件结构
```

#### 3. pre-push.sh
推送前测试脚本，确保代码可以安全推送。

**检查项目**:
- 运行所有测试脚本
- 验证插件结构
- 检查未提交的更改

#### 4. install-hooks.sh
Git Hooks 安装脚本，一键安装所有 hooks。

### 集成脚本

#### beads-integration.sh
Beads 任务跟踪集成脚本，提供以下功能：

- `beads_create_task`: 创建新任务
- `beads_update_task`: 更新任务状态
- `beads_record_decision`: 记录决策
- `beads_sync`: 同步到 Git
- `beads_create_report`: 创建任务报告

---

## 安装方法

### 自动安装（推荐）

```bash
# 在项目根目录运行
cd /root/dev/set_claude/ai-team-plugin
bash hooks/install-hooks.sh
```

安装脚本会自动：
1. 检测 Git 仓库
2. 备份已存在的 hooks
3. 复制新的 hooks 到 `.git/hooks/`
4. 设置可执行权限

### 手动安装

```bash
# 复制 hooks 到 .git/hooks/
cp hooks/pre-commit.sh .git/hooks/pre-commit
cp hooks/commit-msg.sh .git/hooks/commit-msg
cp hooks/pre-push.sh .git/hooks/pre-push

# 设置可执行权限
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/pre-push
```

---

## 使用方法

### Git Hooks

Git hooks 会在相应的 Git 操作时自动执行：

```bash
# 自动触发 pre-commit hook
git commit -m "feat: 添加新功能"

# 自动触发 commit-msg hook
git commit -m "fix: 修复 bug"

# 自动触发 pre-push hook
git push origin main
```

### 跳过 Hooks

如果需要临时跳过 hooks，可以使用 `--no-verify` 参数：

```bash
# 跳过 pre-commit hook
git commit --no-verify -m "message"

# 跳过 pre-push hook
git push --no-verify origin main
```

**注意**: 不建议频繁跳过 hooks，除非你有充分的理由。

### Beads 集成脚本

```bash
# 加载脚本
source hooks/beads-integration.sh

# 使用函数
beads_create_task "任务标题" "任务描述" feature
beads_update_task "task-id" "completed"
beads_record_decision "任务" "决策" "理由"
beads_sync
```

---

## 配置规范

### 文件行数限制

根据项目规范，严格遵守以下限制：

- **动态语言** (Python, JavaScript, TypeScript, Markdown, Shell): 单文件 ≤ 200 行
- **静态语言** (Java, Go, Rust): 单文件 ≤ 250 行

超出限制时，pre-commit hook 会发出警告，建议进行文件拆分。

### 目录结构限制

- 单层文件夹内文件数 ≤ 8 个
- 超出时必须创建多层子文件夹进行归类

### 提交信息格式

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>: <subject>

<body>

<footer>
```

**类型说明**:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响代码含义）
- `refactor`: 重构（既不是新功能也不是修复）
- `test`: 添加测试
- `chore`: 构建过程或辅助工具的变动
- `perf`: 性能优化
- `ci`: CI 配置文件和脚本的变动
- `build`: 影响构建系统或外部依赖的更改
- `revert`: 回退先前的提交

---

## 故障排查

### Hook 未执行

1. 检查 hook 是否有可执行权限：
   ```bash
   ls -la .git/hooks/
   ```

2. 确认 hook 文件存在：
   ```bash
   ls -la .git/hooks/pre-commit
   ls -la .git/hooks/commit-msg
   ls -la .git/hooks/pre-push
   ```

3. 重新安装 hooks：
   ```bash
   bash hooks/install-hooks.sh
   ```

### Hook 执行失败

1. 查看 Git 错误信息
2. 手动运行 hook 脚本进行调试：
   ```bash
   bash .git/hooks/pre-commit
   ```
3. 检查依赖工具是否安装（jq, bash 等）

### 跳过特定检查

如果需要临时跳过某个 hook：

```bash
# 跳过 pre-commit
git commit --no-verify -m "message"

# 跳过 commit-msg
git commit --no-verify -m "message"

# 跳过 pre-push
git push --no-verify origin main
```

---

## 自定义 Hooks

你可以根据项目需求修改这些 hooks：

1. 编辑 `hooks/` 目录下的相应脚本
2. 重新运行安装脚本：
   ```bash
   bash hooks/install-hooks.sh
   ```

或者直接编辑 `.git/hooks/` 中的文件（注意：直接修改的文件不会被 Git 跟踪）。

---

## 相关文档

- [Beads 集成指南](../docs/BEADS_INTEGRATION.md)
- [MCP 权限配置](../docs/MCP_PERMISSIONS.md)
- [项目架构文档](../docs/architecture.md)
- [代码规范](../README.md#代码规范)
