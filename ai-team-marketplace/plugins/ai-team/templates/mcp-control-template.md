# MCP 工具使用指令

## 当前角色配置

**角色名称**: {{ROLE_NAME}}
**必需 MCP**: {{REQUIRED_MCPS}}
**可选 MCP**: {{OPTIONAL_MCPS}}
**禁止 MCP**: {{FORBIDDEN_MCPS}}

## MCP 使用规则

### 必需 MCP (必须使用)

{{#each required_mcps}}
- **{{name}}**: {{purpose}}
  - 必须使用工具: {{tools}}
  - 行为: {{fallback_behavior}}
  - 指令: {{instructions}}

**使用示例**:
\`\`\`
{{usage_example}}
\`\`\`

{{/each}}

### 可选 MCP (按需使用)

{{#each optional_mcps}}
- **{{name}}**: {{purpose}}
  - 可用工具: {{tools}}

{{/each}}

### 禁止 MCP (禁止使用)

{{#each forbidden_mcps}}
- ❌ **{{name}}**: 此角色禁止使用

{{/each}}

## 合规检查

在执行任务前，必须确认:
- [ ] 已使用所有必需 MCP
- [ ] 未使用任何禁止 MCP
- [ ] 可选 MCP 使用合理

## 违规处理

如果违反 MCP 规则:
1. **strict_mode=true**: 立即停止并报错
2. **strict_mode=false**: 记录警告但继续执行
