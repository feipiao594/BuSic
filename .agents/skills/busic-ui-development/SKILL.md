---
name: busic-ui-development
description: BuSic UI层开发规范。用于Screen和Widget开发，包含Widget模式、响应式布局、主题系统、国际化
license: MIT
compatibility: opencode
---

## Widget 编写模式

### 基类选择

| 场景 | 基类 |
|---|---|
| 纯展示 + 读取 Provider | `ConsumerWidget` |
| 需要 State 生命周期 | `ConsumerStatefulWidget` |
| 不需要 Provider | `StatelessWidget` |

### 页面模板

```dart
class XxxScreen extends ConsumerWidget {
  const XxxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xxxNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.xxxTitle),
      ),
      body: state.when(
        data: (data) => _buildContent(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, XxxData data) {
    // ...
  }
}
```

### 私有内部 Widget

```dart
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) { ... }
}
```

## 响应式布局

### ResponsiveScaffold

- **桌面端**（宽度 ≥ 840px）：左侧 `NavigationRail`
- **移动端**（宽度 < 840px）：底部 `NavigationBar`

### 平台判断

```dart
// Context 扩展
if (context.isDesktop) { ... }

// PlatformUtils
if (PlatformUtils.isDesktop) { ... }
```

## 主题系统

### 使用主题

```dart
// 使用 context 扩展
final theme = context.theme;
final colors = context.colorScheme;
final textTheme = context.textTheme;
```

### 主题模式

支持三种 `ThemeMode`：system / light / dark

## 国际化 (i18n)

### 添加翻译

1. 在 `lib/l10n/app_en.arb` 添加英文键值
2. 在 `lib/l10n/app_zh.arb` 添加中文翻译
3. 运行 `flutter gen-l10n`

```json
// app_en.arb
{
  "newFeatureTitle": "New Feature",
  "@newFeatureTitle": { "description": "Title for new feature" }
}

// app_zh.arb
{
  "newFeatureTitle": "新功能"
}
```

### 使用翻译

```dart
Text(context.l10n.searchTitle)
```

### 规范

- 所有用户可见文本必须使用 i18n
- 英文 ARB 是模板文件
- 翻译键使用 camelCase

## 通用弹窗

```dart
// 确认弹窗
final confirmed = await CommonDialogs.showConfirmDialog(context, ...);

// 输入弹窗
final input = await CommonDialogs.showInputDialog(context, ...);

// 错误弹窗
CommonDialogs.showErrorDialog(context, ...);
```

## SnackBar 提示

```dart
context.showSnackBar('操作成功');
```

## 导航

```dart
context.go('/search');
context.push('/playlists/$id');
context.go(AppRoutes.search);
```

## 图片处理

```dart
// 优先级：本地 → 网络 → 占位
if (localCoverPath != null) {
  Image.file(File(localCoverPath));
} else if (coverUrl != null) {
  CachedNetworkImage(imageUrl: coverUrl);
} else {
  GradientPlaceholder();
}
```

## 路由注册

在 `lib/core/router/app_router.dart` 中添加：
- Shell 内嵌路由：加到 `StatefulShellBranch` 的 `routes`
- 独立路由：加到 `StatefulShellRoute` 同级
- 路由常量定义在 `AppRoutes` 抽象类
