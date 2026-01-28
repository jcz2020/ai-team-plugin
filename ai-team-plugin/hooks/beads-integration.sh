#!/bin/bash
# Beads 任务集成脚本
# 用于 AI Team Plugin 的任务跟踪和记录

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Beads 是否安装
check_beads() {
  if ! command -v bd &> /dev/null; then
    log_error "Beads (bd) 未安装"
    log_info "请访问 https://github.com/user/beads 安装 Beads"
    return 1
  fi
  return 0
}

# 创建任务
beads_create_task() {
  local title="$1"
  local notes="$2"
  local task_type="${3:-feature}"  # 默认为 feature 类型

  if ! check_beads; then
    return 1
  fi

  log_info "创建 Beads 任务: $title"

  # 使用 bd create 命令创建任务
  if bd create "$title" -t "$task_type" --notes "$notes" --json 2>/dev/null; then
    log_info "任务创建成功"
    return 0
  else
    log_warn "任务创建失败（可能未初始化 Beads 仓库）"
    return 1
  fi
}

# 更新任务状态
beads_update_task() {
  local task_id="$1"
  local status="$2"
  local notes="${3:-}"

  if ! check_beads; then
    return 1
  fi

  log_info "更新任务 $task_id 状态为: $status"

  case "$status" in
    "completed"|"closed"|"done")
      bd close "$task_id" --reason "Completed" 2>/dev/null
      ;;
    "in_progress"|"progress")
      bd start "$task_id" 2>/dev/null
      ;;
    "blocked"|"pending")
      bd block "$task_id" --notes "$notes" 2>/dev/null
      ;;
    *)
      log_warn "未知状态: $status"
      return 1
      ;;
  esac
}

# 记录决策
beads_record_decision() {
  local task_title="$1"
  local decision="$2"
  local reason="$3"
  local date_str=$(date +%Y-%m-%d)

  if ! check_beads; then
    return 1
  fi

  # 确保决策记录目录存在
  mkdir -p docs/decisions

  local decision_file="docs/decisions/${date_str}.md"

  # 写入决策记录
  cat >> "$decision_file" <<EOF
# 决策记录 - $date_str

## 任务: $task_title

### 关键决策
- **决策**: $decision
- **理由**: $reason
- **时间**: $(date '+%Y-%m-%d %H:%M:%S')

EOF

  log_info "决策记录已保存到: $decision_file"
}

# 同步到 Git
beads_sync() {
  if ! check_beads; then
    return 1
  fi

  log_info "同步 Beads 到 Git..."

  if bd sync 2>/dev/null; then
    log_info "Beads 同步成功"
    return 0
  else
    log_warn "Beads 同步失败（可能没有远程仓库）"
    return 1
  fi
}

# 创建任务完成报告
beads_create_report() {
  local task_title="$1"
  local report_file="$2"
  local date_str=$(date +%Y%m%d)

  if ! check_beads; then
    return 1
  fi

  # 确保任务文档目录存在
  mkdir -p docs/tasks

  local task_file="docs/tasks/${date_str}.md"

  # 如果有报告文件，复制到任务文档
  if [ -f "$report_file" ]; then
    cp "$report_file" "$task_file"
    log_info "任务报告已保存到: $task_file"
  fi
}

# 导出函数以便其他脚本使用
export -f check_beads
export -f beads_create_task
export -f beads_update_task
export -f beads_record_decision
export -f beads_sync
export -f beads_create_report
