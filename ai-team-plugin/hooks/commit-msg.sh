#!/usr/bin/env bash
# Commit-msg Hook for AI Team Plugin
# 验证 Git 提交信息格式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AI Team Plugin - Commit Message Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 提交信息格式规范
# 格式: <type>: <subject>
# 类型: feat, fix, docs, style, refactor, test, chore

# 1. 检查提交信息长度
echo -e "${BLUE}[1/4]${NC} 检查提交信息长度..."

# 提取第一行作为标题
FIRST_LINE=$(echo "$COMMIT_MSG" | head -n 1)
TITLE_LENGTH=${#FIRST_LINE}

if [ $TITLE_LENGTH -eq 0 ]; then
    echo -e "${RED}✗ 提交信息为空${NC}"
    exit 1
fi

if [ $TITLE_LENGTH -gt 72 ]; then
    echo -e "${YELLOW}⚠ 标题超过 72 字符 (${TITLE_LENGTH} 字符)${NC}"
    echo "  建议保持标题简洁，详细说明放在正文中"
    echo ""
fi

echo -e "  ${GREEN}✓${NC} 标题长度: ${TITLE_LENGTH} 字符"
echo ""

# 2. 检查提交信息格式
echo -e "${BLUE}[2/4]${NC} 检查提交信息格式..."

# 允许的提交类型
ALLOWED_TYPES=(
    "feat"
    "fix"
    "docs"
    "style"
    "refactor"
    "test"
    "chore"
    "perf"
    "ci"
    "build"
    "revert"
)

# 检查是否符合格式: <type>: <subject>
if [[ ! "$FIRST_LINE" =~ ^([a-z]+):[[:space:]]+.+ ]]; then
    echo -e "${YELLOW}⚠ 提交信息不符合规范格式${NC}"
    echo "  期望格式: <type>: <subject>"
    echo "  示例: feat: 实现产品经理角色"
    echo "  示例: fix: 修复 MCP 权限验证问题"
    echo ""
    echo "  当前提交信息: $FIRST_LINE"
    echo ""
    echo "  是否继续提交? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # 提取提交类型
    COMMIT_TYPE=$(echo "$FIRST_LINE" | sed 's/:.*//')

    # 检查类型是否在允许列表中
    if [[ ! " ${ALLOWED_TYPES[@]} " =~ " ${COMMIT_TYPE} " ]]; then
        echo -e "${YELLOW}⚠ 未知的提交类型: '${COMMIT_TYPE}'${NC}"
        echo "  允许的类型: ${ALLOWED_TYPES[*]}"
        echo ""
    else
        echo -e "  ${GREEN}✓${NC} 提交类型: ${COMMIT_TYPE}"
    fi
fi
echo ""

# 3. 检查提交信息内容
echo -e "${BLUE}[3/4]${NC} 检查提交信息内容..."

# 检查是否包含空行分隔标题和正文
if [ $(echo "$COMMIT_MSG" | wc -l) -gt 1 ]; then
    SECOND_LINE=$(echo "$COMMIT_MSG" | sed -n '2p')
    if [ -n "$SECOND_LINE" ]; then
        echo -e "${YELLOW}⚠ 标题和正文之间应该有空行${NC}"
        echo ""
    fi
fi

# 检查正文每行长度
BODY_LINES=$(echo "$COMMIT_MSG" | tail -n +2)
MAX_BODY_LINE_LENGTH=80

while IFS= read -r line; do
    LINE_LENGTH=${#line}
    if [ $LINE_LENGTH -gt $MAX_BODY_LINE_LENGTH ]; then
        echo -e "${YELLOW}⚠ 正文行超过 ${MAX_BODY_LINE_LENGTH} 字符 (${LINE_LENGTH} 字符)${NC}"
        break
    fi
done <<< "$BODY_LINES"

echo -e "  ${GREEN}✓${NC} 提交信息内容检查完成"
echo ""

# 4. 检查常见问题
echo -e "${BLUE}[4/4]${NC} 检查常见问题..."

# 检查是否以句号结尾
if [[ "$FIRST_LINE" =~ \.$ ]]; then
    echo -e "${YELLOW}⚠ 标题不应以句号结尾${NC}"
    echo ""
fi

# 检查是否包含大写字母（首字母除外）
SUBJECT=$(echo "$FIRST_LINE" | sed 's/^[^:]*: //')
if [[ "$SUBJECT" =~ ^[A-Z] ]]; then
    echo -e "${YELLOW}⚠ 标题应使用小写字母（专有名词除外）${NC}"
    echo ""
fi

echo -e "  ${GREEN}✓${NC} 常见问题检查完成"
echo ""

# 总结
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ 提交信息验证通过！${NC}"
echo ""
echo "  提交信息: $FIRST_LINE"
echo ""
echo -e "${BLUE}========================================${NC}"

exit 0
