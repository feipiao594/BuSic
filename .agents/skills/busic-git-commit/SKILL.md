---
name: busic-git-commit
description: BuSic Git提交与版本管理规范。用于代码提交时参考，包含约定式提交格式、版本号规范与Git工作流
license: MIT
compatibility: opencode
---

## 约定式提交

### 提交信息格式

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Type 类型

| Type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构（既不是新功能也不是修复） |
| `test` | 测试相关 |
| `chore` | 构建过程或辅助工具变动 |

### Scope 范围

可选，表示提交影响的模块：

```
feat(auth): 添加扫码登录
fix(player): 修复播放暂停后进度条不更新
docs(readme): 更新构建指南
refactor(database): 优化歌曲查询逻辑
```

### 提交示例

```
feat(playlist): 添加歌单排序功能

- 支持按名称/创建时间/歌曲数量排序
- 排序结果持久化到数据库

Closes #123
```

```
fix(download): 修复高音质下载失败的问题

使用正确的音质ID 30280 替换原来的 30216
```

```
chore: 更新依赖版本
```

## 版本号规范

采用 **semver** 格式：`major.minor.patch+build`

| 段 | 含义 | 何时递增 |
|----|------|----------|
| `major` | 不兼容的重大变更 | 破坏性升级 |
| `minor` | 新增功能（向后兼容） | 功能版本 |
| `patch` | Bug 修复 | 热修复 |
| `build` | 构建序号 | 每次打包 |

**示例：** `0.3.4+10`

## Tag 规范

- Tag 命名：`v<major>.<minor>.<patch>`
- **不含 build 号**

```
pubspec.yaml: version: 0.3.4+10
Git tag:    v0.3.4
```

## Git 工作流

### 分支策略

```
main (生产分支)
  ↑
develop (开发分支)
  ↑
feature/xxx (功能分支)
  ↑
bugfix/xxx (修复分支)
  ↑
refactor/xxx (重构分支)
```

### 分支命名

```
feature/add-playlist-export
fix/download-crash
refactor/player-notifier
docs/update-api-doc
```

### 提交流程

1. **创建分支**
   ```bash
   git checkout -b feature/add-playlist-export
   ```

2. **开发并提交**
   ```bash
   git add .
   git commit -m "feat(playlist): 添加歌单导出功能"
   ```

3. **推送分支**
   ```bash
   git push -u origin feature/add-playlist-export
   ```

4. **创建 Pull Request**

5. **合并后删除分支**
   ```bash
   git checkout main
   git pull
   git branch -d feature/add-playlist-export
   ```

## 发布流程

### 1. 准备发布

```bash
# 确保在 develop 分支
git checkout develop
git pull origin develop

# 更新版本号（修改 pubspec.yaml）
# version: 0.4.0+1
```

### 2. 合并到 main

```bash
git checkout main
git merge develop
```

### 3. 打标签

```bash
git tag v0.4.0
git push origin main --tags
```

### 4. 回到开发分支

```bash
git checkout develop
```

## CI/CD 触发

```
推送 v* tag
  └─► CI (ci.yml)      — flutter analyze + flutter test
        └─► Release    — 构建全平台产物 + 发布 GitHub Release
```

## 常用命令

```bash
# 查看提交历史
git log --oneline -10

# 撤销上次提交（保留修改）
git reset --soft HEAD~1

# 撤销上次提交（不保留修改）
git reset --hard HEAD~1

# 查看分支
git branch -a

# 删除远程分支
git push origin --delete <branch>

# 标签相关
git tag                    # 列出标签
git tag -d v0.3.0          # 删除本地标签
git push origin :refs/tags/v0.3.0  # 删除远程标签
```

## 注意事项

1. **提交前运行分析**
   ```bash
   flutter analyze --no-fatal-infos
   ```

2. **提交前运行测试**
   ```bash
   flutter test
   ```

3. **有意义提交信息**：描述做了什么，而非做了什么修改

4. **小而频繁的提交**：每个提交应该只包含一个逻辑变更

5. **不要提交敏感信息**：如密钥、密码、凭据
