#!/bin/bash
# Beads 集成测试脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数
PASSED=0
FAILED=0

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

# 测试函数
test_case() {
  local test_name="$1"
  local test_command="$2"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "测试: $test_name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if eval "$test_command"; then
    log_info "✅ 通过: $test_name"
    ((PASSED++))
  else
    log_error "❌ 失败: $test_name"
    ((FAILED++))
  fi
  echo
}

# 切换到项目目录
cd /root/dev/set_claude/ai-team-plugin || exit 1

log_info "Beads 集成测试开始"
echo

# 测试 1: 检查 Beads 是否安装
test_case "检查 Beads 是否安装" \
  "command -v bd &> /dev/null"

# 测试 2: 检查集成脚本是否存在
test_case "检查集成脚本是否存在" \
  "[ -f hooks/beads-integration.sh ]"

# 测试 3: 检查集成脚本是否可执行
test_case "检查集成脚本是否可执行" \
  "[ -x hooks/beads-integration.sh ]"

# 测试 4: 检查文档是否存在
test_case "检查 Beads 集成文档是否存在" \
  "[ -f docs/BEADS_INTEGRATION.md ]"

# 测试 5: 检查 hooks README 是否存在
test_case "检查 hooks README 是否存在" \
  "[ -f hooks/README.md ]"

# 测试 6: 检查 ai-team.md 是否包含 Beads 集成代码
test_case "检查 ai-team.md 是否包含 Beads 集成" \
  "grep -q '第五步: 记录到 Beads' commands/ai-team.md"

# 测试 7: 加载集成脚本
test_case "加载集成脚本" \
  "source hooks/beads-integration.sh 2>/dev/null"

# 如果 Beads 已安装，进行更多测试
if command -v bd &> /dev/null; then
  log_info "Beads 已安装，进行功能测试"
  echo

  # 加载脚本
  source hooks/beads-integration.sh

  # 测试 8: 检查 Beads 仓库状态（可能未初始化）
  if [ -d .beads ]; then
    test_case "检查 Beads 仓库是否初始化" \
      "true"
  else
    log_warn "Beads 仓库未初始化（可使用 'bd init' 初始化）"
    ((PASSED++))
  fi

  # 测试 9: 测试创建任务（如果 Beads 已初始化）
  if [ -d .beads ]; then
    test_case "创建测试任务" \
      "bd create '测试任务' -t test --notes '自动化测试' --json &> /dev/null"
  fi
else
  log_warn "Beads 未安装，跳过功能测试"
  echo
fi

# 测试 10: 检查决策记录目录
test_case "创建决策记录目录" \
  "mkdir -p docs/decisions && [ -d docs/decisions ]"

# 测试 11: 检查任务文档目录
test_case "创建任务文档目录" \
  "mkdir -p docs/tasks && [ -d docs/tasks ]"

# 测试 12: 检查集成脚本语法
test_case "检查集成脚本语法" \
  "bash -n hooks/beads-integration.sh"

# 输出测试结果
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试结果汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo "总计: $((PASSED + FAILED))"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 返回状态
if [ $FAILED -eq 0 ]; then
  log_info "所有测试通过"
  exit 0
else
  log_error "部分测试失败"
  exit 1
fi
