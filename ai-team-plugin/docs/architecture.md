# AI Team Plugin 架构文档

## 概述

AI Team Plugin 是一个对话式智能调度系统，通过协调多个专业 subagent 实现协作开发。

## 核心组件

### 1. Task Dispatcher（任务调度器）
- 接收用户需求
- 分析任务类型和复杂度
- 分配给合适的专业角色
- 协调多个 subagent 协作

### 2. Agents（专业角色）
- 产品经理：需求分析、功能规划
- 架构师：系统设计、技术选型
- 开发工程师：功能实现
- 测试工程师：质量保证
- 代码审查员：代码质量把控
- UI/UX 设计师：界面设计
- 前端/后端专家：专业领域实现
- 数据库专家：数据层设计
- 安全专家：安全审计
- DevOps 工程师：部署运维

### 3. MCP 工具控制
- 细粒度权限控制
- 每个角色可配置必需/可选/禁止的 MCP 工具
- 确保工具使用的安全性和专业性

### 4. Beads 集成
- 任务跟踪
- 进度管理
- 问题记录

### 5. Git Hooks
- 自动化代码审查
- 自动测试触发
- 提交规范化

## 三层防护机制

1. **权限层**：MCP 工具访问控制
2. **审查层**：代码审查员把关
3. **测试层**：自动化测试覆盖

## 目录结构

```
ai-team-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin 配置
├── commands/                # 命令定义
├── skills/                  # 技能定义
├── task-dispatcher/        # 任务调度器
├── agents/                 # 专业角色定义
├── templates/              # 模板文件
├── hooks/                  # Git hooks
├── docs/                   # 文档
│   ├── architecture.md     # 架构文档
│   └── plans/              # 实现计划
└── README.md               # 项目说明
```

## 工作流程

1. 用户通过 `/ai-team` 命令提交需求
2. Task Dispatcher 分析需求
3. 分配给合适的专业角色
4. Subagent 执行具体任务
5. 代码审查员审查
6. 测试工程师测试
7. 合并到主分支
