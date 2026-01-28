#!/usr/bin/env bash
# Pre-push Hook for AI Team Plugin
# 在 Git 推送前执行测试和验证

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AI Team Plugin - Pre-push Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 错误计数
ERRORS=0

# 1. 运行所有测试脚本
echo -e "${BLUE}[1/3]${NC} 运行测试脚本..."

TESTS_DIR="$PROJECT_ROOT/tests"
if [ -d "$TESTS_DIR" ]; then
    for test_script in "$TESTS_DIR"/*.sh; do
        if [ -f "$test_script" ]; then
            echo -e "  运行: $(basename "$test_script")"
            if bash "$test_script" > /dev/null 2>&1; then
                echo -e "    ${GREEN}✓${NC} 通过"
            else
                echo -e "    ${RED}✗${NC} 失败"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done
else
    echo -e "  ${YELLOW}⚠${NC} tests 目录不存在，跳过测试"
fi
echo ""

# 2. 验证插件结构
echo -e "${BLUE}[2/3]${NC} 验证插件结构..."

VERIFY_SCRIPT="$PROJECT_ROOT/scripts/verify-plugin.sh"
if [ -f "$VERIFY_SCRIPT" ]; then
    echo -e "  运行: verify-plugin.sh"
    if bash "$VERIFY_SCRIPT" > /dev/null 2>&1; then
        echo -e "    ${GREEN}✓${NC} 插件结构验证通过"
    else
        echo -e "    ${RED}✗${NC} 插件结构验证失败"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${NC} 验证脚本不存在，跳过"
fi
echo ""

# 3. 检查未提交的更改
echo -e "${BLUE}[3/3]${NC} 检查 Git 状态..."

cd "$PROJECT_ROOT"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "  ${YELLOW}⚠${NC} 存在未提交的更改:"
    git status --short
    echo ""
    echo "  建议先提交这些更改再推送"
    echo ""
else
    echo -e "  ${GREEN}✓${NC} 工作区干净"
fi
echo ""

# 总结
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  推送前检查结果${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过，可以推送！${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ 发现 $ERRORS 个错误${NC}"
    echo -e "${RED}  请修复错误后再推送${NC}"
    echo ""
    exit 1
fi
