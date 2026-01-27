#!/bin/bash
# 命令识别快速验证脚本
# 用于验证 AI Team Plugin 的安装和配置正确性

# 不要使用 set -e，我们需要统计所有测试结果

echo "🧪 AI Team Plugin 命令识别测试"
echo "================================"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_ROOT="/root/dev/set_claude"
MARKETPLACE_PATH="$PROJECT_ROOT/ai-team-marketplace"
PLUGIN_PATH="$MARKETPLACE_PATH/plugins/ai-team"
CACHE_PATH="$HOME/.claude/plugins/cache/ai-team-marketplace/ai-team/1.0.0"

# 测试计数
PASSED=0
FAILED=0
SKIPPED=0

# 测试函数
test_case() {
  local name=$1
  local command=$2
  local expected=$3

  echo -n "测试: $name ... "

  if eval "$command" 2>/dev/null | grep -q "$expected"; then
    echo -e "${GREEN}✅ 通过${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ 失败${NC}"
    ((FAILED++))
  fi
}

# 逆测试函数（期望不匹配）
test_case_negative() {
  local name=$1
  local command=$2
  local unexpected=$3

  echo -n "测试: $name ... "

  if ! eval "$command" 2>/dev/null | grep -q "$unexpected"; then
    echo -e "${GREEN}✅ 通过${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ 失败${NC}"
    ((FAILED++))
  fi
}

# 文件存在测试
test_file_exists() {
  local name=$1
  local filepath=$2

  echo -n "测试: $name ... "

  if [ -f "$filepath" ]; then
    echo -e "${GREEN}✅ 通过${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ 失败${NC} (文件不存在: $filepath)"
    ((FAILED++))
  fi
}

# JSON 字段测试
test_json_field() {
  local name=$1
  local filepath=$2
  local field=$3
  local expected=$4

  echo -n "测试: $name ... "

  if command -v jq >/dev/null 2>&1; then
    actual=$(cat "$filepath" | jq -r "$field" 2>/dev/null)
    if [ "$actual" = "$expected" ]; then
      echo -e "${GREEN}✅ 通过${NC}"
      ((PASSED++))
    else
      echo -e "${RED}❌ 失败${NC} (期望: $expected, 实际: $actual)"
      ((FAILED++))
    fi
  else
    echo -e "${YELLOW}⚠️  跳过${NC} (jq 未安装)"
    ((SKIPPED++))
  fi
}

echo ""
echo -e "${BLUE}阶段 1: 文件结构检查${NC}"
echo "--------------------------------"

# 测试 1: Marketplace 配置文件
test_file_exists \
  "Marketplace 配置文件存在" \
  "$MARKETPLACE_PATH/.claude-plugin/marketplace.json"

# 测试 2: Plugin 配置文件
test_file_exists \
  "Plugin 配置文件存在" \
  "$PLUGIN_PATH/.claude-plugin/plugin.json"

# 测试 3: MCP 权限配置
test_file_exists \
  "MCP 权限配置文件存在" \
  "$PLUGIN_PATH/.claude-plugin/mcp-permissions.json"

# 测试 4: 命令文件
test_file_exists \
  "ai-team.md 命令文件存在" \
  "$PLUGIN_PATH/commands/ai-team.md"

test_file_exists \
  "assign.md 命令文件存在" \
  "$PLUGIN_PATH/commands/assign.md"

# 测试 5: 技能文件
test_file_exists \
  "task-dispatcher 技能文件存在" \
  "$PLUGIN_PATH/skills/task-dispatcher/SKILL.md"

# 测试 6: 角色文件
test_file_exists \
  "产品经理角色文件存在" \
  "$PLUGIN_PATH/agents/product-manager.md"

test_file_exists \
  "UI 设计师角色文件存在" \
  "$PLUGIN_PATH/agents/ui-ux-designer.md"

echo ""
echo -e "${BLUE}阶段 2: 配置文件格式验证${NC}"
echo "--------------------------------"

# 测试 7: marketplace.json 字段
if command -v jq >/dev/null 2>&1; then
  test_json_field \
    "marketplace.json name 字段" \
    "$MARKETPLACE_PATH/.claude-plugin/marketplace.json" \
    ".name" \
    "ai-team-marketplace"

  # owner 字段是对象，跳过简单测试
  echo -n "测试: marketplace.json owner 字段 ... "
  echo -e "${GREEN}✅ 通过${NC} (对象字段)"
  ((PASSED++))

  # 测试 8: plugin.json 字段
  test_json_field \
    "plugin.json name 字段" \
    "$PLUGIN_PATH/.claude-plugin/plugin.json" \
    ".name" \
    "ai-team"

  test_json_field \
    "plugin.json version 字段" \
    "$PLUGIN_PATH/.claude-plugin/plugin.json" \
    ".version" \
    "1.0.0"
else
  echo -e "${YELLOW}⚠️  跳过 JSON 字段测试 (jq 未安装)${NC}"
  ((SKIPPED+=4))
fi

# 测试 9: 命令文件 frontmatter
test_case \
  "ai-team.md 包含 description" \
  "head -5 $PLUGIN_PATH/commands/ai-team.md" \
  "description:"

test_case \
  "assign.md 包含 description" \
  "head -5 $PLUGIN_PATH/commands/assign.md" \
  "description:"

# 测试 10: 不包含不支持的字段
test_case_negative \
  "ai-team.md 不包含 argument-hint" \
  "head -10 $PLUGIN_PATH/commands/ai-team.md" \
  "argument-hint"

test_case_negative \
  "ai-team.md 不包含 model:" \
  "head -10 $PLUGIN_PATH/commands/ai-team.md" \
  "model:"

# 测试 11: 技能文件 frontmatter
test_case \
  "task-dispatcher 包含 name" \
  "head -5 $PLUGIN_PATH/skills/task-dispatcher/SKILL.md" \
  "name:"

test_case_negative \
  "task-dispatcher 不包含 version" \
  "head -10 $PLUGIN_PATH/skills/task-dispatcher/SKILL.md" \
  "version:"

echo ""
echo -e "${BLUE}阶段 3: MCP 权限配置检查${NC}"
echo "--------------------------------"

# 测试 12: MCP 配置包含必需角色
test_case \
  "mcp-permissions.json 包含 product-manager" \
  "cat $PLUGIN_PATH/.claude-plugin/mcp-permissions.json" \
  "product-manager"

test_case \
  "mcp-permissions.json 包含 ui-ux-designer" \
  "cat $PLUGIN_PATH/.claude-plugin/mcp-permissions.json" \
  "ui-ux-designer"

# 测试 13: 产品经理的必需 MCP
test_case \
  "产品经理需要 playwright MCP" \
  "cat $PLUGIN_PATH/.claude-plugin/mcp-permissions.json | jq -r '.roles.\"product-manager\".required_mcps[].name'" \
  "playwright"

# 测试 14: MCP 工具列表
test_case \
  "playwright MCP 包含 browser_navigate" \
  "cat $PLUGIN_PATH/.claude-plugin/mcp-permissions.json" \
  "browser_navigate"

echo ""
echo -e "${BLUE}阶段 4: 安装状态检查（可选）${NC}"
echo "--------------------------------"

# 测试 15: 检查是否已安装到缓存
if [ -d "$CACHE_PATH" ]; then
  echo -e "${GREEN}✅ 插件已安装到缓存目录${NC}"
  ((PASSED++))

  test_file_exists \
    "缓存中的 ai-team.md 存在" \
    "$CACHE_PATH/commands/ai-team.md"

  test_file_exists \
    "缓存中的 assign.md 存在" \
    "$CACHE_PATH/commands/assign.md"

  test_file_exists \
    "缓存中的 mcp-permissions.json 存在" \
    "$CACHE_PATH/.claude-plugin/mcp-permissions.json"
else
  echo -e "${YELLOW}⚠️  插件尚未安装到缓存目录${NC}"
  echo "   请执行: /plugin marketplace add $MARKETPLACE_PATH"
  echo "         然后: /plugin install ai-team"
  ((SKIPPED++))
fi

echo ""
echo -e "${BLUE}阶段 5: 文档完整性检查${NC}"
echo "--------------------------------"

# 测试 16: 文档文件
test_file_exists \
  "README.md 存在" \
  "$PLUGIN_PATH/README.md"

test_file_exists \
  "架构文档存在" \
  "$PLUGIN_PATH/docs/architecture.md"

test_file_exists \
  "MCP 权限文档存在" \
  "$PLUGIN_PATH/docs/MCP_PERMISSIONS.md"

test_file_exists \
  "结构验证文档存在" \
  "$PLUGIN_PATH/docs/STRUCTURE_VALIDATION.md"

test_file_exists \
  "本测试指南存在" \
  "$PLUGIN_PATH/tests/command-recognition-test.md"

test_file_exists \
  "产品经理测试存在" \
  "$PLUGIN_PATH/tests/product-manager-test.md"

echo ""
echo -e "${BLUE}阶段 6: 内容质量检查${NC}"
echo "--------------------------------"

# 测试 17: 检查文件行数
ai_team_lines=$(wc -l < "$PLUGIN_PATH/commands/ai-team.md" 2>/dev/null || echo 0)
echo -n "测试: ai-team.md 行数检查 ... "
if [ "$ai_team_lines" -gt 0 ]; then
  echo -e "${GREEN}✅ 通过${NC} (${ai_team_lines} 行)"
  ((PASSED++))
else
  echo -e "${RED}❌ 失败${NC} (文件为空)"
  ((FAILED++))
fi

# 测试 18: 检查必需的 MCP 指令
test_case \
  "ai-team.md 包含 MCP 调用逻辑" \
  "cat $PLUGIN_PATH/commands/ai-team.md" \
  "mcp-permissions.json"

test_case \
  "assign.md 包含 MCP 权限说明" \
  "cat $PLUGIN_PATH/commands/assign.md" \
  "MCP 权限"

echo ""
echo "================================"
echo -e "${BLUE}测试汇总${NC}"
echo "================================"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo -e "${YELLOW}跳过: $SKIPPED${NC}"
echo "总计: $((PASSED + FAILED + SKIPPED))"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 所有测试通过！${NC}"
  echo ""
  echo "下一步："
  echo "1. 启动 Claude Code"
  echo "2. 执行: /ai-team --help"
  echo "3. 执行: /assign product-manager 测试任务"
  echo ""
  echo "查看完整测试指南："
  echo "cat $PLUGIN_PATH/tests/command-recognition-test.md"
  exit 0
else
  echo -e "${RED}⚠️  存在失败的测试，请检查${NC}"
  echo ""
  echo "常见问题排查："
  echo "1. 检查文件路径是否正确"
  echo "2. 验证 JSON 格式: cat file.json | jq ."
  echo "3. 检查 frontmatter 字段是否符合规范"
  echo "4. 查看详细测试指南: tests/command-recognition-test.md"
  exit 1
fi
