---
name: busic-skills-maintenance
description: BuSic Skills维护规范。用于维护和更新skills时参考，包含skill创建、更新、删除规范与OpenCode skill格式
license: MIT
compatibility: opencode
---

## Skill 存放位置

OpenCode 按以下顺序搜索 skill：

| 位置 | 说明 |
|---|---|
| `.opencode/skills/<name>/SKILL.md` | 项目级 |
| `.claude/skills/<name>/SKILL.md` | Claude兼容 |
| `.agents/skills/<name>/SKILL.md` | Agent兼容（推荐） |
| `~/.config/opencode/skills/` | 全局级 |
| `~/.claude/skills/` | 全局Claude级 |
| `~/.agents/skills/` | 全局Agent级 |

**本项目使用：`.agents/skills/`**

## Skill 目录结构

```
.agents/skills/
└── <skill_name>/
    └── SKILL.md
```

- 目录名与 skill 名必须一致
- 文件名必须为 `SKILL.md`（全大写）

## Skill 命名规范

- 1-64 个字符
- 小写字母 + 数字，单个连字符分隔
- 不能以 `-` 开头或结尾
- 不能有连续 `--`

```regex
^[a-z0-9]+(-[a-z0-9]+)*$
```

**正确示例：**
- `busic-main-workflow`
- `busic-database`
- `busic-ui-development`

## Frontmatter 规范

每个 SKILL.md 必须以 YAML frontmatter 开头：

```yaml
---
name: <skill_name>
description: <描述>。用于<使用场景>时参考，包含<包含内容>
license: MIT
compatibility: opencode
metadata:
  <key>: <value>
---
```

### 必填字段

| 字段 | 说明 |
|---|---|
| `name` | skill 名称 |
| `description` | 1-1024 字符，格式：功能描述。用于xxx时参考，包含xxx |

### 可选字段

| 字段 | 说明 |
|---|---|
| `license` | 开源许可证 |
| `compatibility` | 兼容性标识 |
| `metadata` | 键值对元数据 |

## Skill 拆分原则

### 主流程 Skill
- `busic-main-workflow`：描述整体开发步骤

### 子 Skill
按职责拆分：
- `busic-architecture`：架构规范
- `busic-coding-conventions`：编码规范
- `busic-database`：数据库规范
- `busic-state-management`：状态管理规范
- `busic-ui-development`：UI开发规范
- `busic-testing`：测试规范
- `busic-skills-maintenance`：本规范

### 拆分时机

1. **内容过长**：单一 skill 超过 500 行时考虑拆分
2. **职责独立**：某部分内容可独立复用时拆分为子 skill
3. **频繁变更**：某部分内容经常更新时单独维护

## Skill 更新时机

**每次开发和重构都必须同步更新相关 skill：**

1. 代码实现变更了架构 → 更新 `busic-architecture`
2. 新增编码约定 → 更新 `busic-coding-conventions`
3. 数据库表结构变化 → 更新 `busic-database`
4. 状态管理方式变化 → 更新 `busic-state-management`
5. UI 组件模式变化 → 更新 `busic-ui-development`
6. 测试模式变化 → 更新 `busic-testing`

## Skill 创建流程

### 1. 确定用途
- 明确 skill 解决的问题
- 确定使用场景

### 2. 命名
- 遵循命名规范
- 名称应简洁表达功能

### 3. 编写内容
- 参考现有 skill 格式
- 包含使用场景说明

### 4. 验证
```bash
# 检查目录结构
ls -la .agents/skills/<skill_name>/

# 检查 frontmatter
head -10 .agents/skills/<skill_name>/SKILL.md

# 验证格式
# 1. name 与目录名一致
# 2. description 符合格式
# 3. 文件名为 SKILL.md
```

## Skill 删除流程

当 skill 过时时：

1. **确认无引用**：检查其他 skill 是否引用该 skill
2. **删除目录**：
   ```bash
   rm -rf .agents/skills/<obsolete_skill>/
   ```
3. **更新引用**：如有引用，通知相关维护者

## Skill 维护检查清单

- [ ] 新增功能后评估是否需要新 skill
- [ ] 重构后同步更新相关 skill
- [ ] 删除代码后检查并删除对应 skill
- [ ] 定期审查 skill 内容准确性
- [ ] 确保 skill 命名符合规范
- [ ] 确保 description 格式正确
