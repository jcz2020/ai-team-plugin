#!/usr/bin/env bash
# AI Team Plugin Comprehensive Verification Script
# 综合验证脚本 - 检查插件安装、配置和功能完整性

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="$PROJECT_ROOT/.claude-plugin"
AGENT_DIR="$PROJECT_ROOT/agents"
COMMAND_DIR="$PROJECT_ROOT/commands"
SKILL_DIR="$PROJECT_ROOT/skills"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认参数
MODE="full"
OUTPUT_FORMAT="text"
QUIET=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            MODE="quick"
            shift
            ;;
        --full)
            MODE="full"
            shift
            ;;
        --json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        --report)
            OUTPUT_FORMAT="report"
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --quick      快速验证（基础检查）"
            echo "  --full       完整验证（包含详细报告）"
            echo "  --json       输出 JSON 格式"
            echo "  --report     生成 Markdown 报告"
            echo "  --quiet     静默模式（仅输出错误）"
            echo "  --help       显示帮助信息"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            echo "使用 --help 查看帮助"
            exit 1
            ;;
    esac
done

# 统计变量
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_COUNT=0

# 问题列表
ISSUES=()
WARNINGS=()

# 辅助函数
log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}ℹ${NC} $1"
    fi
}

log_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}✓${NC} $1"
    fi
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    ISSUES+=("$1")
}

log_warning() {
    if [ "$QUIET" = false ]; then
        echo -e "${YELLOW}⚠${NC} $1"
    fi
    WARNING_COUNT=$((WARNING_COUNT + 1))
    WARNINGS+=("$1")
}

log_section() {
    if [ "$QUIET" = false ]; then
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}  $1${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
}

check_file() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    local file="$1"
    local description="$2"

    if [ -f "$file" ]; then
        log_success "$description 存在"
        return 0
    else
        log_error "$description 不存在: $file"
        return 1
    fi
}

check_dir() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    local dir="$1"
    local description="$2"

    if [ -d "$dir" ]; then
        log_success "$description 存在"
        return 0
    else
        log_error "$description 不存在: $dir"
        return 1
    fi
}

# 开始验证
if [ "$QUIET" = false ]; then
    log_section "AI Team Plugin 安装验证 ($MODE 模式)"
fi

# ==================== 1. 基础结构检查 ====================
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    log_section "1. 基础结构检查"

    # 检查必需目录
    check_dir "$PLUGIN_DIR" "Plugin 配置目录"
    check_dir "$AGENT_DIR" "角色定义目录"
    check_dir "$COMMAND_DIR" "命令定义目录"
    check_dir "$SKILL_DIR" "技能定义目录"

    # 检查必需文件
    check_file "$PROJECT_ROOT/README.md" "项目说明文件"
    check_file "$PROJECT_ROOT/docs/architecture.md" "架构文档"
fi

# ==================== 2. Plugin 配置检查 ====================
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    log_section "2. Plugin 配置检查"

    # 检查 plugin.json
    if check_file "$PLUGIN_DIR/plugin.json" "Plugin 元数据配置"; then
        if command -v jq &> /dev/null; then
            # 验证 JSON 语法
            if jq empty "$PLUGIN_DIR/plugin.json" 2>/dev/null; then
                log_success "plugin.json JSON 语法正确"

                # 提取关键信息
                PLUGIN_NAME=$(jq -r '.name' "$PLUGIN_DIR/plugin.json")
                PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_DIR/plugin.json")
                PLUGIN_DESC=$(jq -r '.description' "$PLUGIN_DIR/plugin.json")

                if [ "$QUIET" = false ]; then
                    log_info "插件名称: $PLUGIN_NAME"
                    log_info "插件版本: $PLUGIN_VERSION"
                    log_info "插件描述: $PLUGIN_DESC"
                fi

                # 检查必需字段
                if [ -n "$PLUGIN_NAME" ] && [ "$PLUGIN_NAME" != "null" ]; then
                    log_success "插件名称字段有效"
                else
                    log_error "plugin.json 缺少 name 字段"
                fi

                if [ -n "$PLUGIN_VERSION" ] && [ "$PLUGIN_VERSION" != "null" ]; then
                    log_success "插件版本字段有效"
                else
                    log_error "plugin.json 缺少 version 字段"
                fi
            else
                log_error "plugin.json JSON 语法错误"
            fi
        else
            log_warning "jq 未安装，跳过 JSON 语法验证"
        fi
    fi

    # 检查 mcp-permissions.json
    if check_file "$PLUGIN_DIR/mcp-permissions.json" "MCP 权限配置"; then
        if command -v jq &> /dev/null; then
            if jq empty "$PLUGIN_DIR/mcp-permissions.json" 2>/dev/null; then
                log_success "mcp-permissions.json JSON 语法正确"

                # 统计角色数量
                ROLE_COUNT=$(jq '.roles | length' "$PLUGIN_DIR/mcp-permissions.json")
                log_info "已配置角色数量: $ROLE_COUNT"

                # 列出角色
                if [ "$QUIET" = false ] && [ "$MODE" = "full" ]; then
                    log_info "已配置角色列表:"
                    jq -r '.roles | to_entries[] | "  - \(.key): \(.value.display_name)"' "$PLUGIN_DIR/mcp-permissions.json"
                fi
            else
                log_error "mcp-permissions.json JSON 语法错误"
            fi
        fi
    fi

    # 检查 schema 文件
    check_file "$PLUGIN_DIR/mcp-permissions-schema.json" "MCP 权限 Schema 定义"
fi

# ==================== 3. 命令文件检查 ====================
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    log_section "3. 命令文件检查"

    COMMAND_COUNT=0
    if [ -d "$COMMAND_DIR" ]; then
        COMMAND_COUNT=$(find "$COMMAND_DIR" -name "*.md" -type f | wc -l)
        log_success "命令文件数量: $COMMAND_COUNT"

        if [ "$MODE" = "full" ]; then
            for cmd_file in "$COMMAND_DIR"/*.md; do
                if [ -f "$cmd_file" ]; then
                    cmd_name=$(basename "$cmd_file" .md)
                    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

                    # 检查 frontmatter
                    if grep -q "^description:" "$cmd_file"; then
                        log_success "命令 $cmd_name frontmatter 正确"
                    else
                        log_error "命令 $cmd_name 缺少 description 字段"
                    fi
                fi
            done
        fi
    fi

    # 期望的命令文件
    EXPECTED_COMMANDS=("ai-team" "assign")
    for cmd in "${EXPECTED_COMMANDS[@]}"; do
        check_file "$COMMAND_DIR/$cmd.md" "命令文件 $cmd"
    done
fi

# ==================== 4. 技能文件检查 ====================
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    log_section "4. 技能文件检查"

    SKILL_COUNT=0
    if [ -d "$SKILL_DIR" ]; then
        SKILL_COUNT=$(find "$SKILL_DIR" -name "SKILL.md" -type f | wc -l)
        log_success "技能文件数量: $SKILL_COUNT"
    fi

    # 检查 task-dispatcher 技能
    if [ -f "$SKILL_DIR/task-dispatcher/SKILL.md" ]; then
        log_success "智能路由技能存在"

        if [ "$MODE" = "full" ]; then
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            SKILL_LINES=$(wc -l < "$SKILL_DIR/task-dispatcher/SKILL.md")
            log_info "技能文件行数: $SKILL_LINES"

            if [ "$SKILL_LINES" -gt 100 ]; then
                log_success "技能文件内容完整"
            else
                log_warning "技能文件内容较少，可能不完整"
            fi
        fi
    else
        log_error "智能路由技能不存在"
    fi
fi

# ==================== 5. 角色定义文件检查 ====================
if [ "$MODE" = "full" ]; then
    log_section "5. 角色定义文件检查"

    AGENT_COUNT=0
    if [ -d "$AGENT_DIR" ]; then
        AGENT_COUNT=$(find "$AGENT_DIR" -name "*.md" -type f | wc -l)
        log_success "角色定义文件数量: $AGENT_COUNT"

        # 列出所有角色
        if [ "$QUIET" = false ]; then
            log_info "已实现角色列表:"
            find "$AGENT_DIR" -name "*.md" -type f -exec basename {} .md \; | sort | while read -r agent; do
                echo "  - $agent"
            done
        fi

        # 检查角色文件内容
        for agent_file in "$AGENT_DIR"/*.md; do
            if [ -f "$agent_file" ]; then
                agent_name=$(basename "$agent_file" .md)
                TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

                # 检查 frontmatter（更灵活的检查逻辑）
                # 至少需要包含以下字段之一: role, name, display_name
                has_frontmatter=false
                if grep -q "^role:" "$agent_file" || grep -q "^name:" "$agent_file" || grep -q "^display_name:" "$agent_file"; then
                    has_frontmatter=true
                fi

                # 检查是否有 frontmatter 分隔符
                if head -5 "$agent_file" | grep -q "^---"; then
                    has_frontmatter=true
                fi

                if [ "$has_frontmatter" = true ]; then
                    log_success "角色 $agent_name frontmatter 正确"
                else
                    log_error "角色 $agent_name frontmatter 不完整"
                fi

                # 检查 MCP 工具配置
                if grep -q "required_mcps:" "$agent_file" || grep -q "optional_mcps:" "$agent_file"; then
                    log_success "角色 $agent_name 包含 MCP 工具配置"
                else
                    log_warning "角色 $agent_name 未配置 MCP 工具"
                fi
            fi
        done
    fi

    # 对比配置
    if command -v jq &> /dev/null && [ -f "$PLUGIN_DIR/mcp-permissions.json" ]; then
        CONFIGURED_ROLES=$(jq -r '.roles | keys[]' "$PLUGIN_DIR/mcp-permissions.json" | wc -l)
        log_info "配置中定义的角色数量: $CONFIGURED_ROLES"
        log_info "实际实现的角色数量: $AGENT_COUNT"

        if [ "$AGENT_COUNT" -lt "$CONFIGURED_ROLES" ]; then
            MISSING_ROLES=$((CONFIGURED_ROLES - AGENT_COUNT))
            log_warning "有 $MISSING_ROLES 个角色已配置但未实现"
        fi
    fi
fi

# ==================== 6. 文档完整性检查 ====================
if [ "$MODE" = "full" ]; then
    log_section "6. 文档完整性检查"

    DOCS_DIR="$PROJECT_ROOT/docs"

    # 检查核心文档
    check_file "$DOCS_DIR/architecture.md" "架构文档"
    check_file "$DOCS_DIR/STRUCTURE_VALIDATION.md" "结构验证文档"
    check_file "$DOCS_DIR/MCP_PERMISSIONS.md" "MCP 权限说明文档"
    check_file "$DOCS_DIR/INSTALLATION_TEST.md" "安装测试文档"

    # 检查 README
    if [ -f "$PROJECT_ROOT/README.md" ]; then
        README_LINES=$(wc -l < "$PROJECT_ROOT/README.md")
        log_info "README.md 行数: $README_LINES"

        if [ "$README_LINES" -gt 300 ]; then
            log_success "README.md 内容详尽"
        else
            log_warning "README.md 内容较少，建议补充"
        fi

        # 检查关键章节
        README_HAS_INSTALL=$(grep -q "##.*安装" "$PROJECT_ROOT/README.md" && echo "yes" || echo "no")
        README_HAS_USAGE=$(grep -q "##.*使用" "$PROJECT_ROOT/README.md" && echo "yes" || echo "no")
        README_HAS_CONFIG=$(grep -q "##.*配置" "$PROJECT_ROOT/README.md" && echo "yes" || echo "no")

        if [ "$README_HAS_INSTALL" = "yes" ]; then
            log_success "README 包含安装说明"
        else
            log_warning "README 缺少安装说明"
        fi

        if [ "$README_HAS_USAGE" = "yes" ]; then
            log_success "README 包含使用说明"
        else
            log_warning "README 缺少使用说明"
        fi

        if [ "$README_HAS_CONFIG" = "yes" ]; then
            log_success "README 包含配置说明"
        else
            log_warning "README 缺少配置说明"
        fi
    fi
fi

# ==================== 7. 脚本文件检查 ====================
if [ "$MODE" = "full" ]; then
    log_section "7. 脚本文件检查"

    SCRIPTS_DIR="$PROJECT_ROOT/scripts"

    # 检查验证脚本
    if [ -f "$SCRIPTS_DIR/validate-mcp-permissions.sh" ]; then
        log_success "MCP 权限验证脚本存在"

        # 检查可执行权限
        if [ -x "$SCRIPTS_DIR/validate-mcp-permissions.sh" ]; then
            log_success "验证脚本具有执行权限"
        else
            log_warning "验证脚本缺少执行权限，运行: chmod +x $SCRIPTS_DIR/validate-mcp-permissions.sh"
        fi
    else
        log_warning "MCP 权限验证脚本不存在"
    fi

    # 检查本脚本
    if [ -x "$SCRIPTS_DIR/verify-plugin.sh" ]; then
        log_success "综合验证脚本存在并具有执行权限"
    fi
fi

# ==================== 8. 测试文件检查 ====================
if [ "$MODE" = "full" ]; then
    log_section "8. 测试文件检查"

    TESTS_DIR="$PROJECT_ROOT/tests"

    if [ -d "$TESTS_DIR" ]; then
        TEST_COUNT=$(find "$TESTS_DIR" -name "*test*.md" -type f | wc -l)
        log_success "测试文件数量: $TEST_COUNT"

        if [ "$TEST_COUNT" -eq 0 ]; then
            log_warning "没有找到测试文件"
        fi
    else
        log_warning "测试目录不存在"
    fi
fi

# ==================== 9. 安装路径检查 ====================
if [ "$MODE" = "full" ]; then
    log_section "9. 安装路径检查"

    CLAUDE_PLUGIN_DIR="$HOME/.claude/plugins"

    # 检查是否是符号链接
    if [ -L "$CLAUDE_PLUGIN_DIR/ai-team" ]; then
        LINK_TARGET=$(readlink "$CLAUDE_PLUGIN_DIR/ai-team")
        log_success "插件已通过符号链接安装"
        log_info "链接目标: $LINK_TARGET"

        # 检查链接是否有效
        if [ -d "$CLAUDE_PLUGIN_DIR/ai-team" ]; then
            log_success "符号链接有效"
        else
            log_error "符号链接已失效"
        fi
    elif [ -d "$CLAUDE_PLUGIN_DIR/ai-team" ]; then
        log_success "插件已通过复制方式安装"
    else
        log_warning "插件未安装到 Claude 插件目录"
        log_info "安装方法: ln -s $PROJECT_ROOT ~/.claude/plugins/ai-team"
    fi
fi

# ==================== 10. Claude Code 配置检查 ====================
if [ "$MODE" = "full" ]; then
    log_section "10. Claude Code 配置检查"

    SETTINGS_FILE="$HOME/.claude/settings.json"

    if [ -f "$SETTINGS_FILE" ]; then
        if command -v jq &> /dev/null; then
            # 检查插件是否启用
            PLUGIN_ENABLED=$(jq -r '.plugins[]? | select(.name == "ai-team") | .enabled' "$SETTINGS_FILE")

            if [ "$PLUGIN_ENABLED" = "true" ]; then
                log_success "AI Team 插件已在 settings.json 中启用"
            elif [ "$PLUGIN_ENABLED" = "false" ]; then
                log_error "AI Team 插件已被禁用"
            else
                log_warning "AI Team 插件未在 settings.json 中配置"
            fi
        else
            log_warning "jq 未安装，无法检查 settings.json"
        fi
    else
        log_warning "settings.json 不存在，Claude Code 可能未配置"
    fi
fi

# ==================== 输出结果 ====================
if [ "$OUTPUT_FORMAT" = "json" ]; then
    # JSON 输出
    # 生成 issues 数组
    ISSUES_JSON=""
    if [ ${#ISSUES[@]} -gt 0 ]; then
        for issue in "${ISSUES[@]}"; do
            # 转义特殊字符
            issue_escaped=$(echo "$issue" | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
            if [ -n "$ISSUES_JSON" ]; then
                ISSUES_JSON="$ISSUES_JSON, \"$issue_escaped\""
            else
                ISSUES_JSON="\"$issue_escaped\""
            fi
        done
    fi

    # 生成 warnings 数组
    WARNINGS_JSON=""
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        for warning in "${WARNINGS[@]}"; do
            # 转义特殊字符
            warning_escaped=$(echo "$warning" | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
            if [ -n "$WARNINGS_JSON" ]; then
                WARNINGS_JSON="$WARNINGS_JSON, \"$warning_escaped\""
            else
                WARNINGS_JSON="\"$warning_escaped\""
            fi
        done
    fi

    cat <<EOF
{
  "verification_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "mode": "$MODE",
  "total_checks": $TOTAL_CHECKS,
  "passed_checks": $PASSED_CHECKS,
  "failed_checks": $FAILED_CHECKS,
  "warning_count": $WARNING_COUNT,
  "success_rate": $(awk "BEGIN {printf \"%.2f\", ($PASSED_CHECKS/$TOTAL_CHECKS)*100}") ,
  "status": "$([ $FAILED_CHECKS -eq 0 ] && echo "success" || echo "failed")",
  "issues": [${ISSUES_JSON}],
  "warnings": [${WARNINGS_JSON}]
}
EOF

elif [ "$OUTPUT_FORMAT" = "report" ]; then
    # Markdown 报告
    cat <<EOF
# AI Team Plugin 验证报告

**验证时间**: $(date '+%Y-%m-%d %H:%M:%S')
**验证模式**: $MODE
**插件版本**: ${PLUGIN_VERSION:-"unknown"}

## 验证统计

- 总检查项: $TOTAL_CHECKS
- 通过检查: $PASSED_CHECKS
- 失败检查: $FAILED_CHECKS
- 警告数量: $WARNING_COUNT
- 成功率: $(awk "BEGIN {printf \"%.2f\", ($PASSED_CHECKS/$TOTAL_CHECKS)*100}")%

## 验证状态

$([ $FAILED_CHECKS -eq 0 ] && echo "✅ **验证通过**" || echo "❌ **验证失败**")

## 发现的问题

$(if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "无"
else
    for issue in "${ISSUES[@]}"; do
        echo "- ❌ $issue"
    done
fi)

## 警告信息

$(if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo "无"
else
    for warning in "${WARNINGS[@]}"; do
        echo "- ⚠️ $warning"
    done
fi)

## 建议

$(if [ $FAILED_CHECKS -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    echo "✅ 插件安装完整，可以正常使用"
elif [ $FAILED_CHECKS -eq 0 ]; then
    echo "⚠️ 插件基本可用，建议解决警告问题"
else
    echo "❌ 请修复失败项后再使用插件"
fi)

---
**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
EOF

else
    # 文本输出（默认）
    echo ""
    log_section "验证结果汇总"
    echo ""

    if [ "$QUIET" = false ]; then
        echo "总检查项: $TOTAL_CHECKS"
        echo "通过检查: $PASSED_CHECKS"
        echo "失败检查: $FAILED_CHECKS"
        echo "警告数量: $WARNING_COUNT"
        echo "成功率: $(awk "BEGIN {printf \"%.2f\", ($PASSED_CHECKS/$TOTAL_CHECKS)*100}")%"
        echo ""
    fi

    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✅ 验证通过！插件安装完整${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        if [ $WARNING_COUNT -gt 0 ]; then
            echo -e "${YELLOW}发现 $WARNING_COUNT 个警告，建议查看并修复${NC}"
        fi

        echo ""
        echo "下一步:"
        echo "  1. 重启 Claude Code"
        echo "  2. 测试命令: /ai-team --help"
        echo "  3. 查看文档: cat docs/INSTALLATION_TEST.md"
        echo ""

        exit 0
    else
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  ❌ 验证失败，发现 $FAILED_CHECKS 个问题${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        echo "失败项:"
        for issue in "${ISSUES[@]}"; do
            echo -e "  ${RED}✗${NC} $issue"
        done
        echo ""

        if [ $WARNING_COUNT -gt 0 ]; then
            echo "警告项:"
            for warning in "${WARNINGS[@]}"; do
                echo -e "  ${YELLOW}⚠${NC} $warning"
            done
            echo ""
        fi

        echo "建议:"
        echo "  1. 检查插件目录结构"
        echo "  2. 验证配置文件格式"
        echo "  3. 运行: ./scripts/validate-mcp-permissions.sh"
        echo "  4. 查看文档: cat docs/INSTALLATION_TEST.md"
        echo ""

        exit 1
    fi
fi
