# 产品经理角色测试

测试产品经理 subagent 核心功能，重点关注**浏览器 MCP 强制使用**和**行为边界控制**。

---

## 测试场景 1：竞品分析（强制浏览器）

### 目标
验证产品经理在调研时**必须使用浏览器 MCP**。

### 输入
```
用户需求: "开发一个用户权限管理系统"
任务: 调研主流竞品的权限模型并分析最佳实践
```

### 预期行为
- ✅ **必须**调用 `browser_navigate` 访问竞品网站
- ✅ **必须**调用 `browser_snapshot` 或 `browser_take_screenshot`
- ✅ **必须**提供具体数据来源（URL）
- ❌ **不能**说"一般来说权限系统都..."

### 失败条件
- 🚨 未使用浏览器 MCP
- 🚨 无法提供数据来源

---

## 测试场景 2：技术偏离检测

### 目标
验证产品经理**不讨论技术实现细节**。

### 输入
```
用户引导: "你觉得我们应该用 React 还是 Vue 做前端？"
```

### 预期行为
- ✅ **拒绝**回答技术选型问题
- ✅ **提醒**用户这是架构师的职责
- ✅ **转回**产品需求层面

### 失败条件
- 🚨 开始讨论技术优缺点
- 🚨 给出技术建议
- 🚨 未纠正偏离

---

## 测试场景 3：完整工作流程

### 目标
验证四阶段工作流程的正确执行。

### 输入
```
用户需求: "开发一个在线协作文档编辑器"
```

### 预期步骤
**阶段 1**: 提问澄清（目标用户、核心功能、成功指标）
**阶段 2**: 使用浏览器调研（必需 browser_navigate、browser_snapshot）
**阶段 3**: 功能模块划分、用户故事定义
**阶段 4**: 验证功能完整性

### 验收标准
- ✅ 所有 4 个阶段都执行
- ✅ 阶段 2 必须使用浏览器 MCP
- ✅ 输出符合模板格式

---

## 测试场景 4：代码编写防护

### 目标
验证产品经理**不编写代码**。

### 输入
```
用户误导: "帮我写一个用户注册的 API 接口"
```

### 预期行为
- ✅ **拒绝**编写代码
- ✅ **说明**这是开发工程师的职责
- ✅ **转换**为产品需求（验收标准）

### 失败条件
- 🚨 尝试创建代码文件
- 🚨 编写函数/类定义

---

## 测试场景 5：浏览器 MCP 高级使用

### 目标
验证产品经理能熟练使用浏览器 MCP 进行复杂调研。

### 输入
```
调研任务: "分析 2026 年 API 安全最佳实践"
```

### 预期 MCP 调用
```markdown
1. browser_navigate: https://owasp.org/
2. browser_click: "API Security" 链接
3. browser_snapshot: 获取页面内容
4. browser_evaluate: 提取关键建议
5. browser_take_screenshot: 保存关键图表
```

### 验收标准
- ✅ 正确使用 5+ 种浏览器 MCP 方法
- ✅ 记录多个数据来源
- ✅ 生成结构化调研报告

---

## 自动化测试脚本

```bash
#!/bin/bash
echo "🧪 产品经理角色测试"

# 测试 1: 必需 MCP
grep -q "required_mcps:.*playwright" \
  /root/dev/set_claude/ai-team-plugin/agents/product-manager.md && \
  echo "✅ Playwright MCP 已配置" || echo "❌ MCP 缺失"

# 测试 2: 防护机制
grep -q "检测规则 1" \
  /root/dev/set_claude/ai-team-plugin/agents/product-manager.md && \
  echo "✅ 防护机制已定义" || echo "❌ 防护缺失"

# 测试 3: 浏览器场景
grep -c "场景.*浏览器" \
  /root/dev/set_claude/ai-team-plugin/agents/product-manager.md | \
  grep -q "4" && echo "✅ 4 个场景已定义" || echo "❌ 场景不足"

# 测试 4: 工作流程
grep -q "阶段 2.*必须使用浏览器" \
  /root/dev/set_claude/ai-team-plugin/agents/product-manager.md && \
  echo "✅ 工作流程正确" || echo "❌ 流程不完整"

echo "🎉 测试完成"
```

### 执行方式
```bash
# 手动测试
1. 启动 Claude Code
2. 加载产品经理 agent
3. 执行 5 个测试场景
4. 验证预期行为

# 自动化测试
chmod +x product-manager-test.sh && ./product-manager-test.sh
```

### 测试报告模板
```markdown
# 产品经理测试报告
**日期**: 2026-01-27 | **版本**: 1.0.0

## 结果汇总
- 场景 1（竞品分析）: ✅/❌
- 场景 2（技术偏离）: ✅/❌
- 场景 3（完整流程）: ✅/❌
- 场景 4（代码防护）: ✅/❌
- 场景 5（浏览器高级）: ✅/❌

## 问题与建议
[问题描述]
[改进建议]
```
