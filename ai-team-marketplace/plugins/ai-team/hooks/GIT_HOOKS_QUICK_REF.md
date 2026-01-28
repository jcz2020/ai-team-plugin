# Git Hooks 快速参考

## 概述

AI Team Plugin 配置了自动化 Git Hooks，确保代码质量和提交规范。

## 已安装的 Hooks

| Hook | 触发时机 | 功能 |
|------|---------|------|
| **pre-commit** | `git commit` 执行前 | 代码质量和配置检查 |
| **commit-msg** | 提交信息创建后 | 提交信息格式验证 |
| **pre-push** | `git push` 执行前 | 测试和结构验证 |

## 快速使用

### 正常使用（自动触发）

```bash
# 提交更改 - 自动运行 pre-commit 和 commit-msg
git add .
git commit -m "feat: 实现新功能"

# 推送到远程 - 自动运行 pre-push
git push origin main
```

### 跳过 Hooks（不推荐）

```bash
# 跳过 pre-commit
git commit --no-verify -m "fix: 临时修复"

# 跳过 pre-push
git push --no-verify origin main
```

## 提交信息格式规范

### 标准格式

```
<type>: <subject>
```

### 类型（type）

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 实现产品经理角色` |
| `fix` | 修复 bug | `fix: 修复 MCP 权限验证` |
| `docs` | 文档更新 | `docs: 更新 README` |
| `style` | 代码格式 | `style: 格式化代码` |
| `refactor` | 重构 | `refactor: 重构命令结构` |
| `test` | 测试 | `test: 添加单元测试` |
| `chore` | 构建/工具 | `chore: 更新依赖` |
| `perf` | 性能优化 | `perf: 优化加载速度` |
| `ci` | CI 配置 | `ci: 更新 GitHub Actions` |
| `build` | 构建系统 | `build: 更新 webpack 配置` |
| `revert` | 回退提交 | `revert: 回退 feat-xxx` |

### 格式要求

- 标题长度：≤ 72 字符
- 使用小写字母（专有名词除外）
- 不以句号结尾
- 使用命令式语气（"添加"而非"添加了"）
- 标题和正文之间用空行分隔
- 正文每行 ≤ 80 字符

### 示例

#### 好的提交信息

```bash
# 简单提交
git commit -m "feat: 实现产品经理角色"

# 详细提交
git commit -m "feat: 实现 MCP 权限控制系统

- 添加 mcp-permissions.json 配置文件
- 实现三层权限验证机制
- 添加权限控制模板

Closes #123"
```

#### 不好的提交信息

```bash
# 缺少类型
git commit -m "添加新功能"

# 类型错误
git commit -m "feature: 添加新功能"

# 太长（超过72字符）
git commit -m "feat: 实现了一个非常复杂的功能模块，包含了很多子功能和详细的实现细节"

# 以句号结尾
git commit -m "feat: 添加新功能."
```

## Pre-commit 检查项

### 1. JSON 配置验证

检查文件：
- `.claude-plugin/plugin.json`
- `.claude-plugin/mcp-permissions.json`

验证内容：JSON 语法正确性

### 2. Markdown Frontmatter 验证

检查文件：
- `commands/*.md`
- `skills/**/*.md`

验证内容：
- 必须包含 `description` 字段
- 不包含不支持的字段

### 3. 文件行数限制

| 语言类型 | 限制 |
|---------|------|
| 动态语言（.md, .py, .js, .ts, .sh） | ≤ 200 行 |
| 静态语言（.java, .go, .rs） | ≤ 250 行 |

**注意**: 超出限制会发出警告，但不会阻止提交

### 4. 目录结构限制

- 单层目录文件数：≤ 8 个
- 超出时会警告，建议创建子目录分类

### 5. MCP 权限配置验证

运行 `scripts/validate-mcp-permissions.sh` 验证配置

### 6. 脚本可执行权限

自动为 `scripts/` 和 `hooks/` 目录中的 `.sh` 文件添加可执行权限

## Pre-push 检查项

### 1. 运行测试脚本

自动运行 `tests/` 目录中的所有测试脚本

### 2. 验证插件结构

运行 `scripts/verify-plugin.sh` 验证插件结构

### 3. 检查 Git 状态

提示未提交的更改，建议先提交再推送

## 常见问题

### Q: Hook 执行失败怎么办？

```bash
# 1. 查看错误信息（会显示具体哪个检查失败）

# 2. 手动运行 hook 进行调试
bash .git/hooks/pre-commit

# 3. 修复问题后重试
git commit -m "feat: 添加新功能"
```

### Q: 如何临时禁用某个 hook？

```bash
# 重命名 hook 文件
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# 使用后恢复
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

### Q: 如何自定义 hook 规则？

```bash
# 1. 编辑 hooks/ 目录中的脚本
vim hooks/pre-commit.sh

# 2. 重新安装
bash hooks/install-hooks.sh
```

### Q: Hooks 为什么不执行？

检查清单：

```bash
# 1. 确认 hook 可执行
ls -la .git/hooks/pre-commit
# 应该显示 -rwxr-xr-x

# 2. 确认没有跳过
# 不要使用 --no-verify

# 3. 重新安装
bash hooks/install-hooks.sh
```

## 管理命令

### 安装 Hooks

```bash
bash hooks/install-hooks.sh
```

### 测试 Hooks

```bash
bash hooks/test-hooks.sh
```

### 查看 Hooks

```bash
ls -la .git/hooks/
```

### 卸载 Hooks

```bash
rm .git/hooks/pre-commit
rm .git/hooks/commit-msg
rm .git/hooks/pre-push
```

## 最佳实践

1. **不要频繁跳过 hooks**: 只在真正需要时使用 `--no-verify`
2. **修复警告**: 即使允许提交，也应尽快修复警告
3. **遵循提交规范**: 良好的提交信息有助于代码审查和历史追踪
4. **定期测试**: 使用 `test-hooks.sh` 确保 hooks 正常工作
5. **团队协作**: 确保所有团队成员都安装了相同的 hooks

## 相关文档

- [Hooks 详细文档](./README.md)
- [项目架构](../docs/architecture.md)
- [代码规范](../README.md#代码规范)
- [Conventional Commits](https://www.conventionalcommits.org/)
