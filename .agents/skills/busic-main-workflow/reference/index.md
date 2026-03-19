# BuSic 开发子 Skill 索引

本目录包含所有子 skill 的详细说明。

## Skill 列表

| Skill | 文件 | 用途 |
|---|---|---|
| busic-architecture | ../busic-architecture/SKILL.md | 架构与项目结构 |
| busic-coding-conventions | ../busic-coding-conventions/SKILL.md | 代码编码规范 |
| busic-database | ../busic-database/SKILL.md | 数据库操作规范 |
| busic-state-management | ../busic-state-management/SKILL.md | 状态管理规范 |
| busic-ui-development | ../busic-ui-development/SKILL.md | UI层开发规范 |
| busic-testing | ../busic-testing/SKILL.md | 测试规范 |
| busic-skills-maintenance | ../busic-skills-maintenance/SKILL.md | Skills维护规范 |
| busic-git-commit | ../busic-git-commit/SKILL.md | Git提交与版本管理 |

## 使用方式

使用 skill tool 加载子 skill：

```dart
skill({ name: "busic-architecture" })
skill({ name: "busic-database" })
// 等等
```

## Skill 依赖关系

```
busic-main-workflow (主流程)
    │
    ├── busic-architecture (架构基础)
    │       │
    │       └── busic-database (数据层)
    │               │
    │               └── busic-state-management (状态管理)
    │
    ├── busic-ui-development (UI层)
    │       │
    │       └── busic-coding-conventions (编码规范)
    │
    ├── busic-testing (测试)
    │
    ├── busic-git-commit (版本管理)
    │
    └── busic-skills-maintenance (技能维护)
```
