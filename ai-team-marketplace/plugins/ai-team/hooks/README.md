# Hooks 目录

本目录包含 AI Team Plugin 的 Git hooks 和集成脚本。

## 文件说明

### beads-integration.sh

Beads 任务跟踪集成脚本，提供以下功能：

- `beads_create_task`: 创建新任务
- `beads_update_task`: 更新任务状态
- `beads_record_decision`: 记录决策
- `beads_sync`: 同步到 Git
- `beads_create_report`: 创建任务报告

### 使用方法

```bash
# 加载脚本
source /root/dev/set_claude/ai-team-plugin/hooks/beads-integration.sh

# 使用函数
beads_create_task "任务标题" "任务描述" feature
beads_update_task "task-id" "completed"
beads_record_decision "任务" "决策" "理由"
beads_sync
```

## 计划添加的 Hooks

- [ ] pre-commit-check.sh: 提交前代码质量检查
- [ ] post-commit-notify.sh: 提交后通知
- [ ] pre-push-test.sh: 推送前测试

## 相关文档

- [Beads 集成指南](../docs/BEADS_INTEGRATION.md)
