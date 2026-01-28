#!/usr/bin/env bash
# Git Hooks 安装脚本
# 将项目中的 Git hooks 安装到 .git/hooks 目录

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

# 查找 Git 仓库根目录
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PROJECT_ROOT")
GIT_HOOKS_DIR="$GIT_ROOT/.git/hooks"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AI Team Plugin - Git Hooks 安装${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查是否在 Git 仓库中
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo -e "${RED}✗ 错误: .git/hooks 目录不存在${NC}"
    echo "  请确保在 Git 仓库根目录运行此脚本"
    exit 1
fi

echo -e "${GREEN}✓${NC} Git 仓库检测成功"
echo ""

# 定义要安装的 hooks
HOOKS=(
    "pre-commit:pre-commit.sh"
    "commit-msg:commit-msg.sh"
    "pre-push:pre-push.sh"
)

# 安装 hooks
echo -e "${BLUE}安装 Git Hooks...${NC}"
echo ""

INSTALLED=0
SKIPPED=0

for hook_config in "${HOOKS[@]}"; do
    IFS=':' read -r hook_name hook_script <<< "$hook_config"
    source_file="$SCRIPT_DIR/$hook_script"
    target_file="$GIT_HOOKS_DIR/$hook_name"

    if [ ! -f "$source_file" ]; then
        echo -e "  ${YELLOW}⚠${NC} $hook_name: 源文件不存在 ($hook_script)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # 备份已存在的 hook
    if [ -f "$target_file" ]; then
        backup_file="${target_file}.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "  ${YELLOW}⚠${NC} $hook_name: 已存在，备份到 $(basename "$backup_file")"
        cp "$target_file" "$backup_file"
    fi

    # 复制 hook 文件
    cp "$source_file" "$target_file"
    chmod +x "$target_file"

    echo -e "  ${GREEN}✓${NC} $hook_name: 安装成功"
    INSTALLED=$((INSTALLED + 1))
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Git Hooks 安装完成！${NC}"
echo ""
echo "  已安装: $INSTALLED 个 hooks"
if [ $SKIPPED -gt 0 ]; then
    echo "  跳过: $SKIPPED 个 hooks"
fi
echo ""
echo "  Hooks 目录: $GIT_HOOKS_DIR"
echo ""
echo -e "${BLUE}已安装的 Hooks:${NC}"
echo "  • pre-commit  - 提交前检查（代码质量、配置验证）"
echo "  • commit-msg  - 提交信息格式验证"
echo "  • pre-push    - 推送前测试"
echo ""
echo -e "${YELLOW}提示:${NC}"
echo "  • 如果需要跳过 hooks，可以使用 --no-verify 参数"
echo "  • 例如: git commit --no-verify -m 'message'"
echo ""
echo -e "${BLUE}========================================${NC}"

exit 0
