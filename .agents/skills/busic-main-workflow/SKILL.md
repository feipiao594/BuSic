---
name: busic-main-workflow
description: BuSic Flutter项目主开发流程。用于功能开发、bug修复、代码重构时使用，包含整体开发步骤与验证要求
license: MIT
compatibility: opencode
---

## 整体开发流程

### 1. 任务分析
1. 确定功能范围和边界条件
2. 确认功能归属的模块位置
3. 复杂功能在 `docs/feat/` 下新建规划文档

### 2. 代码实现
按顺序参考子skill：

```
busic-architecture    → 架构规范
    ↓
busic-database        → 数据层实现
    ↓
busic-state-management → 状态管理
    ↓
busic-ui-development   → UI层开发
    ↓
国际化 (app_en.arb / app_zh.arb)
```

### 3. 代码生成
修改 `@riverpod` / `@freezed` / `@DriftDatabase` 后必须运行：
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. 测试实现
参考 `busic-testing` skill，**每个功能必须实现对应测试**

### 5. 文档维护
**每次开发和重构都必须进行文档维护。**

#### 5.1 文档更新
- 更新 `docs/` 下的相关文档
- 新增功能需在 `docs/feat/` 下添加规划文档
- 重构后需同步更新架构文档

#### 5.2 Skills 维护
- 参考 `busic-skills-maintenance` skill
- 更新现有 skill 内容以反映代码变更
- 必要时创建新 skill
- 删除过时的 skill

### 6. 验证要求

```bash
# 1. 静态分析（0 issues）
flutter analyze --no-fatal-infos

# 2. 所有测试通过
flutter test

# 3. 本地运行验证
# 查看可用设备
flutter devices
# 根据设备ID运行
flutter run -d <device_id> --debug
# 常用平台：windows / linux / macos / android / ios
```

### 相关子Skill

| Skill | 用途 |
|---|---|
| [busic-architecture](./busic-architecture/SKILL.md) | 架构与项目结构 |
| [busic-coding-conventions](./busic-coding-conventions/SKILL.md) | 代码编码规范 |
| [busic-database](./busic-database/SKILL.md) | 数据库操作规范 |
| [busic-state-management](./busic-state-management/SKILL.md) | 状态管理规范 |
| [busic-ui-development](./busic-ui-development/SKILL.md) | UI层开发规范 |
| [busic-testing](./busic-testing/SKILL.md) | 测试规范 |
| [busic-skills-maintenance](./busic-skills-maintenance/SKILL.md) | Skills维护规范 |

### 代码编写时参考

- **命名约定** → `busic-coding-conventions`
- **数据层** → `busic-database`
- **状态层** → `busic-state-management`
- **UI层** → `busic-ui-development`
