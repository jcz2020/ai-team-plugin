# Beads 任务跟踪集成指南

## 概述

AI Team Plugin 已集成 Beads 任务跟踪系统，可自动记录任务进度、决策历史和工作成果。

## Beads 简介

Beads 是一个 Git-backed 的任务跟踪系统，具有以下特性：
- 任务存储在 Git 仓库中
- 支持任务依赖关系
- 自动同步到远程仓库
- 跨会话持久化任务状态

## 安装 Beads

```bash
# 使用 npm 安装
npm install -g @beads/cli

# 或访问官网
# https://github.com/user/beads
```

## 初始化 Beads

```bash
# 在项目根目录初始化
cd /root/dev/set_claude/ai-team-plugin
bd init

# 配置远程仓库（可选）
bd remote add origin <your-git-repo>
```

## 集成功能

### 1. 自动任务创建

当用户执行 `/ai-team` 命令时，系统会自动创建 Beads 任务：

```bash
bd create "完成: 用户请求的任务" -t feature --notes "任务详情..."
```

### 2. 任务状态跟踪

系统会在每个阶段更新任务状态：

```bash
# 开始任务
bd start <task-id>

# 完成任务
bd close <task-id> --reason "Completed"

# 阻塞任务
bd block <task-id> --notes "阻塞原因"
```

### 3. 决策记录

所有关键决策自动记录到 `docs/decisions/YYYY-MM-DD.md`：

```markdown
# 决策记录 - 2026-01-28

## 任务: 开发用户权限管理功能

### 关键决策
- **决策**: 使用 RBAC 权限模型
- **理由**: 成熟方案，易于扩展
- **时间**: 2026-01-28 10:30:00
```

### 4. Git 同步

所有更改自动同步到 Git：

```bash
bd sync
```

## 集成脚本

### 位置
`/root/dev/set_claude/ai-team-plugin/hooks/beads-integration.sh`

### 使用方法

```bash
# 加载脚本
source /root/dev/set_claude/ai-team-plugin/hooks/beads-integration.sh

# 创建任务
beads_create_task "开发新功能" "功能详情..." feature

# 更新任务状态
beads_update_task "task-id" "completed"

# 记录决策
beads_record_decision "任务标题" "决策内容" "决策理由"

# 同步到 Git
beads_sync
```

## 在 ai-team.md 中的集成

命令文件 `/root/dev/set_claude/ai-team-plugin/commands/ai-team.md` 已包含 Beads 集成逻辑：

### 第五步: 记录到 Beads

```markdown
## 第五步: 记录到 Beads

如果项目使用 Beads 进行任务跟踪，自动记录:

1. 创建任务完成记录
2. 记录决策到 docs/decisions/
3. 同步到 Git
```

## 配置选项

### 启用/禁用 Beads

编辑 `ai-team.md`，修改第五步：

```markdown
## 第五步: 记录到 Beads

```bash
# 检查 Beads 是否安装
if ! command -v bd &> /dev/null; then
  echo "⚠️  Beads 未安装，跳过任务记录"
  exit 0
fi

# 继续执行 Beads 集成...
```

### 任务类型

支持的任务类型：
- `feature`: 新功能
- `bugfix`: Bug 修复
- `refactor`: 重构
- `docs`: 文档
- `test`: 测试
- `chore`: 杂项

## 最佳实践

### 1. 任务命名规范

```bash
# 好的任务名
bd create "feat: 实现用户登录功能" -t feature
bd create "fix: 修复登录页面样式问题" -t bugfix

# 避免使用
bd create "做点什么" -t feature
```

### 2. 决策记录规范

每个决策应包含：
- **决策内容**: 具体做了什么决定
- **决策理由**: 为什么做这个决定
- **影响范围**: 会影响哪些模块
- **备选方案**: 考虑过哪些其他方案

### 3. 文件组织

```
ai-team-plugin/
├── docs/
│   ├── decisions/          # 决策记录
│   │   └── 2026-01-28.md
│   ├── tasks/              # 任务文档
│   │   └── 20260128.md
│   └── reviews/            # 审查报告
│       └── 20260128.md
└── .beads/                 # Beads 数据（Git 跟踪）
```

## 故障排除

### 问题 1: bd 命令未找到

**解决方案**:
```bash
# 安装 Beads
npm install -g @beads/cli

# 验证安装
bd --version
```

### 问题 2: Beads 仓库未初始化

**解决方案**:
```bash
# 初始化 Beads
cd /root/dev/set_claude/ai-team-plugin
bd init
```

### 问题 3: Git 同步失败

**解决方案**:
```bash
# 配置远程仓库
bd remote add origin <your-repo-url>

# 手动同步
git push
```

## 示例工作流

### 完整示例

```bash
# 1. 用户执行命令
/ai-team 开发用户权限管理功能

# 2. AI Team 自动执行
#    - 产品经理分析需求
#    - 创建 Beads 任务
#    - 架构师设计系统
#    - 记录技术选型决策
#    - 开发工程师实现
#    - 代码审查员审查
#    - 测试工程师测试
#    - 产品经理验收
#    - 更新任务状态为 completed
#    - 同步到 Git

# 3. 查看任务状态
bd list

# 4. 查看决策记录
cat docs/decisions/2026-01-28.md
```

## 相关文档

- [Beads 官方文档](https://github.com/user/beads)
- [AI Team Plugin 架构文档](/root/dev/set_claude/ai-team-plugin/docs/architecture.md)
- [MCP 权限配置](/root/dev/set_claude/ai-team-plugin/docs/MCP_PERMISSIONS.md)

## 贡献

如果你有改进建议，请提交 Issue 或 Pull Request。
