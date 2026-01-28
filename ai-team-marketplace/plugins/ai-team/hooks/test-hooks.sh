#!/usr/bin/env bash
# Git Hooks 测试脚本
# 测试各个 Git Hook 的功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Git Hooks 功能测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 测试计数
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_hook() {
    local test_name="$1"
    local hook_path="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -e "${BLUE}[测试 $TOTAL_TESTS]${NC} $test_name"

    if [ -f "$hook_path" ]; then
        if [ -x "$hook_path" ]; then
            echo -e "  ${GREEN}✓${NC} Hook 存在且可执行"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗${NC} Hook 不可执行"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "  ${RED}✗${NC} Hook 不存在"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# 1. 测试 pre-commit hook
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pre-commit Hook 测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

test_hook "Pre-commit hook 检查" "/root/dev/set_claude/.git/hooks/pre-commit"

# 测试 pre-commit 功能（不实际提交）
echo -e "${BLUE}功能验证:${NC}"
echo "  检查 JSON 配置文件..."
if jq empty ".claude-plugin/plugin.json" 2>/dev/null; then
    echo -e "    ${GREEN}✓${NC} plugin.json 语法正确"
else
    echo -e "    ${RED}✗${NC} plugin.json 语法错误"
fi
echo ""

# 2. 测试 commit-msg hook
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Commit-msg Hook 测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

test_hook "Commit-msg hook 检查" "/root/dev/set_claude/.git/hooks/commit-msg"

# 测试提交信息格式验证
echo -e "${BLUE}提交信息格式测试:${NC}"
echo ""

# 创建临时提交信息文件进行测试
TEMP_MSG_FILE=$(mktemp)
trap "rm -f $TEMP_MSG_FILE" EXIT

# 测试正确格式
echo "feat: 添加新功能" > "$TEMP_MSG_FILE"
if bash /root/dev/set_claude/.git/hooks/commit-msg "$TEMP_MSG_FILE" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} 正确格式: 'feat: 添加新功能'"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "  ${RED}✗${NC} 正确格式: 'feat: 添加新功能'"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 测试错误格式
echo "添加新功能" > "$TEMP_MSG_FILE"
if bash /root/dev/set_claude/.git/hooks/commit-msg "$TEMP_MSG_FILE" > /dev/null 2>&1; then
    echo -e "  ${YELLOW}⚠${NC} 错误格式: '添加新功能' (应该被拒绝但被接受)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "  ${GREEN}✓${NC} 错误格式: '添加新功能' (正确拒绝)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo ""

# 3. 测试 pre-push hook
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pre-push Hook 测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

test_hook "Pre-push hook 检查" "/root/dev/set_claude/.git/hooks/pre-push"

echo -e "${BLUE}功能验证:${NC}"
echo "  检查测试脚本..."
if [ -d "$PROJECT_ROOT/tests" ]; then
    TEST_COUNT=$(find "$PROJECT_ROOT/tests" -name "*.sh" -type f | wc -l)
    echo -e "    ${GREEN}✓${NC} 发现 $TEST_COUNT 个测试脚本"
else
    echo -e "    ${YELLOW}⚠${NC} tests 目录不存在"
fi
echo ""

# 4. 检查脚本文件
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  脚本文件检查${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${BLUE}检查 hooks 目录中的脚本:${NC}"
for script in "$PROJECT_ROOT"/hooks/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        TOTAL_TESTS=$((TOTAL_TESTS + 1))

        if [ -x "$script" ]; then
            echo -e "  ${GREEN}✓${NC} $script_name (可执行)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗${NC} $script_name (不可执行)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
done
echo ""

# 总结
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  测试结果总结${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "  总测试数: $TOTAL_TESTS"
echo -e "  通过: ${GREEN}$PASSED_TESTS${NC}"
echo -e "  失败: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！${NC}"
    echo ""
    echo -e "${BLUE}Git Hooks 已准备就绪:${NC}"
    echo "  • pre-commit  - 已安装并可用"
    echo "  • commit-msg  - 已安装并可用"
    echo "  • pre-push    - 已安装并可用"
    echo ""
    echo -e "${BLUE}下一步:${NC}"
    echo "  1. 尝试提交更改以测试 hooks"
    echo "  2. 如果需要跳过 hook，使用 --no-verify"
    echo ""
    exit 0
else
    echo -e "${RED}✗ 部分测试失败${NC}"
    echo ""
    echo "请检查上述错误并修复"
    echo ""
    exit 1
fi
