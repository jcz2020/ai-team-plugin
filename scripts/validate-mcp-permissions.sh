#!/usr/bin/env bash
# MCP Permissions Configuration Validation Script
# 验证 mcp-permissions.json 配置文件的正确性

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERMISSIONS_FILE="$PROJECT_ROOT/.claude-plugin/mcp-permissions.json"
SCHEMA_FILE="$PROJECT_ROOT/.claude-plugin/mcp-permissions-schema.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  MCP Permissions Configuration Validator"
echo "=========================================="
echo ""

# 检查文件是否存在
if [ ! -f "$PERMISSIONS_FILE" ]; then
    echo -e "${RED}✗ 错误: 配置文件不存在${NC}"
    echo "  路径: $PERMISSIONS_FILE"
    exit 1
fi

if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}✗ 错误: Schema 文件不存在${NC}"
    echo "  路径: $SCHEMA_FILE"
    exit 1
fi

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ 警告: jq 未安装，跳过语法验证${NC}"
    echo "  安装方法: apt-get install jq 或 brew install jq"
    echo ""
else
    echo -e "${GREEN}✓ jq 已安装${NC}"
    echo ""

    # 验证 JSON 语法
    echo "1. 验证 JSON 语法..."
    if jq empty "$PERMISSIONS_FILE" 2>/dev/null; then
        echo -e "   ${GREEN}✓ JSON 语法正确${NC}"
    else
        echo -e "   ${RED}✗ JSON 语法错误${NC}"
        jq empty "$PERMISSIONS_FILE"
        exit 1
    fi
    echo ""

    # 提取角色数量
    echo "2. 统计配置信息..."
    ROLE_COUNT=$(jq '.roles | length' "$PERMISSIONS_FILE")
    echo "   - 配置角色数量: $ROLE_COUNT"
    echo "   - 配置版本: $(jq -r '.version' "$PERMISSIONS_FILE")"
    echo ""

    # 列出所有角色
    echo "3. 已配置的角色列表:"
    jq -r '.roles | to_entries[] | "   - \(.key): \(.value.display_name)"' "$PERMISSIONS_FILE"
    echo ""

    # 检查必需字段
    echo "4. 检查必需字段..."
    MISSING_FIELDS=0

    # 使用 jq 的 to_entries 来正确处理带连字符的键
    while IFS='|' read -r role_key display_name; do
        if [ "$display_name" = "null" ] || [ -z "$display_name" ]; then
            echo -e "   ${RED}✗ 角色 '$role_key' 缺少 display_name${NC}"
            MISSING_FIELDS=$((MISSING_FIELDS + 1))
        fi
    done < <(jq -r '.roles | to_entries[] | "\(.key)|\(.value.display_name // "null")"' "$PERMISSIONS_FILE")

    if [ $MISSING_FIELDS -eq 0 ]; then
        echo -e "   ${GREEN}✓ 所有角色必需字段完整${NC}"
    else
        echo -e "   ${RED}✗ 发现 $MISSING_FIELDS 个缺失字段${NC}"
        exit 1
    fi
    echo ""

    # 统计 MCP 工具使用情况
    echo "5. MCP 工具使用统计:"

    # 必需 MCP 工具
    REQUIRED_MCPS=$(jq -r '[.roles | to_entries[] | select(.value.required_mcps | length > 0) |
           "\(.key): \(.value.required_mcps | length) 个必需工具"] | join("\n")' "$PERMISSIONS_FILE")

    if [ -n "$REQUIRED_MCPS" ]; then
        echo "   必需 MCP 工具:"
        echo "$REQUIRED_MCPS" | sed 's/^/     - /'
    else
        echo "   必需 MCP 工具: 无"
    fi
    echo ""

    # 可选 MCP 工具
    OPTIONAL_MCPS=$(jq -r '[.roles | to_entries[] | select(.value.optional_mcps | length > 0) |
           "\(.key): \(.value.optional_mcps | length) 个可选工具"] | join("\n")' "$PERMISSIONS_FILE")

    if [ -n "$OPTIONAL_MCPS" ]; then
        echo "   可选 MCP 工具:"
        echo "$OPTIONAL_MCPS" | sed 's/^/     - /'
    else
        echo "   可选 MCP 工具: 无"
    fi
    echo ""

    # 检查全局设置
    echo "6. 检查全局设置..."
    STRICT_MODE=$(jq -r '.global_settings.strict_mode' "$PERMISSIONS_FILE")
    AUDIT_LOG=$(jq -r '.global_settings.audit_log' "$PERMISSIONS_FILE")
    echo "   - 严格模式: $STRICT_MODE"
    echo "   - 审计日志: $AUDIT_LOG"
    echo ""
fi

# 检查角色定义文件
echo "7. 检查角色定义文件..."
AGENT_DIR="$PROJECT_ROOT/agents"
if [ -d "$AGENT_DIR" ]; then
    AGENT_COUNT=$(find "$AGENT_DIR" -name "*.md" -type f | wc -l)
    echo "   - 角色定义文件数量: $AGENT_COUNT"

    echo ""
    echo "   角色定义文件列表:"
    find "$AGENT_DIR" -name "*.md" -type f -exec basename {} \; | sort | while read -r file; do
        echo "     - $file"
    done
else
    echo -e "   ${YELLOW}⚠ 警告: agents 目录不存在${NC}"
fi
echo ""

# 最终总结
echo "=========================================="
if [ $MISSING_FIELDS -eq 0 ]; then
    echo -e "${GREEN}✓ 验证通过！${NC}"
    echo ""
    echo "配置文件路径: $PERMISSIONS_FILE"
    echo "Schema 文件路径: $SCHEMA_FILE"
    echo "已配置角色数量: ${ROLE_COUNT:-0}"
    echo "角色定义文件数量: ${AGENT_COUNT:-0}"
else
    echo -e "${RED}✗ 验证失败${NC}"
    exit 1
fi
echo "=========================================="
