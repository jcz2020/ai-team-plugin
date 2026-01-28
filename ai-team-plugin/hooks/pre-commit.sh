#!/usr/bin/env bash
# Pre-commit Hook for AI Team Plugin
# 在 Git 提交前执行代码质量和配置检查

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
echo -e "${BLUE}  AI Team Plugin - Pre-commit Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 错误计数
ERRORS=0
WARNINGS=0

# 1. 检查 JSON 配置文件语法
echo -e "${BLUE}[1/6]${NC} 检查 JSON 配置文件..."
JSON_FILES=(
    "$PROJECT_ROOT/.claude-plugin/plugin.json"
    "$PROJECT_ROOT/.claude-plugin/mcp-permissions.json"
)

for json_file in "${JSON_FILES[@]}"; do
    if [ -f "$json_file" ]; then
        if command -v jq &> /dev/null; then
            if jq empty "$json_file" 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} $(basename "$json_file") 语法正确"
            else
                echo -e "  ${RED}✗${NC} $(basename "$json_file") 语法错误"
                jq empty "$json_file"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo -e "  ${YELLOW}⚠${NC} jq 未安装，跳过 JSON 语法检查"
        fi
    fi
done
echo ""

# 2. 检查 Markdown 文件格式
echo -e "${BLUE}[2/6]${NC} 检查关键 Markdown 文件..."

# 检查是否有空 frontmatter
check_frontmatter() {
    local file="$1"
    if grep -q '^[[:space:]]*---' "$file"; then
        # 检查是否有必需的 description 字段
        if ! grep -A 10 '^[[:space:]]*---' "$file" | grep -q 'description:'; then
            echo -e "  ${YELLOW}⚠${NC} $(basename "$file") frontmatter 缺少 description"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# 检查命令文件
if [ -d "$PROJECT_ROOT/commands" ]; then
    for cmd_file in "$PROJECT_ROOT"/commands/*.md; do
        if [ -f "$cmd_file" ]; then
            check_frontmatter "$cmd_file"
            echo -e "  ${GREEN}✓${NC} 检查 $(basename "$cmd_file")"
        fi
    done
fi

# 检查技能文件
if [ -d "$PROJECT_ROOT/skills" ]; then
    find "$PROJECT_ROOT/skills" -name "*.md" -type f | while read -r skill_file; do
        check_frontmatter "$skill_file"
        echo -e "  ${GREEN}✓${NC} 检查 $(basename "$skill_file")"
    done
fi
echo ""

# 3. 检查文件行数限制
echo -e "${BLUE}[3/6]${NC} 检查文件行数限制..."

# 动态语言文件限制: ≤ 200 行
DYNAMIC_PATTERN="(\.md|\.py|\.js|\.ts|\.sh)$"
MAX_LINES_DYNAMIC=200

# 静态语言文件限制: ≤ 250 行
STATIC_PATTERN="(\.java|\.go|\.rs)$"
MAX_LINES_STATIC=250

check_file_lines() {
    local file="$1"
    local max_lines="$2"

    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        if [ "$lines" -gt "$max_lines" ]; then
            echo -e "  ${YELLOW}⚠${NC} $(basename "$file") 超过 ${max_lines} 行 (${lines} 行)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# 检查动态语言文件
find "$PROJECT_ROOT" -type f -regex "$DYNAMIC_PATTERN" ! -path "*/node_modules/*" ! -path "*/.git/*" | while read -r file; do
    check_file_lines "$file" "$MAX_LINES_DYNAMIC"
done

# 检查静态语言文件
find "$PROJECT_ROOT" -type f -regex "$STATIC_PATTERN" ! -path "*/node_modules/*" ! -path "*/.git/*" | while read -r file; do
    check_file_lines "$file" "$MAX_LINES_STATIC"
done

echo -e "  ${GREEN}✓${NC} 文件行数检查完成"
echo ""

# 4. 检查目录结构限制
echo -e "${BLUE}[4/6]${NC} 检查目录结构限制..."

MAX_FILES_PER_DIR=8

check_dir_file_count() {
    local dir="$1"

    if [ -d "$dir" ]; then
        # 排除特定目录
        if [[ "$dir" =~ (node_modules|\.git|\.claude) ]]; then
            return
        fi

        file_count=$(find "$dir" -maxdepth 1 -type f | wc -l)
        if [ "$file_count" -gt "$MAX_FILES_PER_DIR" ]; then
            echo -e "  ${YELLOW}⚠${NC} $dir 包含 $file_count 个文件 (建议 ≤ $MAX_FILES_PER_DIR)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# 检查所有一级子目录
for dir in "$PROJECT_ROOT"/*/; do
    check_dir_file_count "$dir"
done

echo -e "  ${GREEN}✓${NC} 目录结构检查完成"
echo ""

# 5. 运行 MCP 权限验证脚本
echo -e "${BLUE}[5/6]${NC} 验证 MCP 权限配置..."

VALIDATE_SCRIPT="$PROJECT_ROOT/scripts/validate-mcp-permissions.sh"
if [ -f "$VALIDATE_SCRIPT" ]; then
    if bash "$VALIDATE_SCRIPT" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} MCP 权限配置有效"
    else
        echo -e "  ${RED}✗${NC} MCP 权限配置验证失败"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${NC} 验证脚本不存在，跳过"
fi
echo ""

# 6. 检查脚本可执行权限
echo -e "${BLUE}[6/6]${NC} 检查脚本可执行权限..."

SCRIPT_DIRS=(
    "$PROJECT_ROOT/scripts"
    "$PROJECT_ROOT/hooks"
)

for script_dir in "${SCRIPT_DIRS[@]}"; do
    if [ -d "$script_dir" ]; then
        find "$script_dir" -type f -name "*.sh" | while read -r script; do
            if [ -x "$script" ]; then
                echo -e "  ${GREEN}✓${NC} $(basename "$script") 可执行"
            else
                echo -e "  ${YELLOW}⚠${NC} $(basename "$script") 不可执行，正在添加权限..."
                chmod +x "$script"
                if [ $? -eq 0 ]; then
                    echo -e "  ${GREEN}✓${NC} 已添加可执行权限"
                fi
            fi
        done
    fi
done
echo ""

# 总结
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  检查结果${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过！${NC}"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ 发现 $WARNINGS 个警告，但允许提交${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ 发现 $ERRORS 个错误、$WARNINGS 个警告${NC}"
    echo -e "${RED}  请修复错误后再提交${NC}"
    echo ""
    exit 1
fi
