---
name: busic-architecture
description: BuSic项目架构规范。用于数据层、状态层、UI层开发时参考，包含整体架构、Feature模块结构、层间依赖规则
license: MIT
compatibility: opencode
---

## 整体架构

```
lib/
├── main.dart              # 入口：初始化数据库、media_kit、窗口服务
├── app.dart               # MaterialApp.router 配置
├── core/                  # 全局基础设施（与业务无关）
├── features/              # 业务功能模块（核心代码）
├── shared/                # 跨模块共享组件
└── l10n/                  # 国际化资源
```

## Core 层（核心基建）

| 目录 | 职责 | 关键类 |
|---|---|---|
| `api/` | Bilibili API 底层封装 | `BiliDio`, `WbiSign` |
| `database/` | Drift 数据库初始化 + 表定义 | `AppDatabase` |
| `router/` | GoRouter 全局路由表 | `appRouterProvider`, `AppRoutes` |
| `theme/` | Material 3 主题 + 响应式断点 | `AppTheme` |
| `utils/` | 工具集 | `AppLogger`, `Formatters`, `PlatformUtils` |
| `window/` | 桌面窗口管理 | `WindowService` |

## Feature 层（四层架构）

```
features/<feature_name>/
├── domain/models/     # Freezed 数据模型
├── data/              # Repository 接口 + 实现
├── application/       # Riverpod Notifier
└── presentation/     # UI (Screen + Widgets)
```

### 现有 Feature

| 模块 | 功能 |
|---|---|
| `auth/` | 扫码登录、Cookie管理 |
| `player/` | 播放控制、队列管理 |
| `playlist/` | 歌单 CRUD |
| `search_and_parse/` | BV号解析、搜索 |
| `download/` | 下载任务队列 |
| `settings/` | 用户偏好 |

## 层间依赖规则

```
Presentation → Application → Data → Core
```

### 严格规则

1. **Presentation 层**只通过 Riverpod provider 与 Application 层交互，禁止直接调用 Repository
2. **Application 层** 持有 Repository 实例，负责编排业务逻辑
3. **Data 层** 实现 Repository 抽象接口
4. **Domain 层** 是纯数据模型，不包含业务逻辑
5. **Feature 之间**通过 Riverpod provider 互相引用，不直接导入对方 Data/Domain 层
6. **Core 层**可以被任何层使用

## 新增 Feature 模板

```
lib/features/<new_feature>/
├── domain/models/<model_name>.dart     # @freezed
├── data/<feature>_repository.dart      # 抽象接口
├── data/<feature>_repository_impl.dart # 实现
├── application/<feature>_notifier.dart # @riverpod
└── presentation/
    ├── <feature>_screen.dart
    └── widgets/<widget_name>.dart
```
