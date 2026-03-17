---
name: busic-coding-conventions
description: BuSic代码编码规范。用于代码编写时参考，包含命名约定、文件规范、导入顺序、代码风格
license: MIT
compatibility: opencode
---

## 命名约定

| 类型 | 约定 | 示例 |
|---|---|---|
| Notifier 类 | `XxxNotifier` | `AuthNotifier`, `PlayerNotifier` |
| Repository 接口 | `XxxRepository` | `AuthRepository` |
| Repository 实现 | `XxxRepositoryImpl` | `AuthRepositoryImpl` |
| Domain 模型 | PascalCase 名词 | `SongItem`, `AudioTrack` |
| Screen (页面) | `XxxScreen` | `LoginScreen` |
| 可复用 Widget | 描述性名词 | `SongTile`, `PlaylistTile` |
| 私有内部 Widget | `_XxxWidget` | `_DesktopTitleBar` |
| 工具类 | `XxxUtils` | `PlatformUtils`, `Formatters` |
| Provider (codegen) | 自动生成 `xxxProvider` | `authNotifierProvider` |
| 枚举 | PascalCase + camelCase值 | `PlayMode.repeatAll` |
| 常量 | camelCase | `desktopBreakpoint` |
| 私有成员 | `_camelCase` | `_isPlaying` |

## 文件命名

- 使用 **snake_case**：`audio_track.dart`, `player_notifier.dart`
- 与类名一一对应：`AudioTrack` → `audio_track.dart`
- 每个文件一个主要公开类

## 导入顺序

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. 第三方包
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 4. 项目内（相对路径）
import '../../core/api/bili_dio.dart';
import '../domain/models/user.dart';

// 5. Part 指令
part 'auth_notifier.g.dart';
```

- 项目内文件只用相对路径，不用 `package:busic/`
- 各组之间空一行

## 代码风格

### 字符串
```dart
// 使用单引号
final name = 'BuSic';
```

### const 优先
```dart
const SizedBox(height: 8);
const EdgeInsets.all(16);

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
}
```

### 日志
```dart
// 使用 AppLogger
AppLogger.info('播放开始', tag: 'Player');
AppLogger.error('下载失败', tag: 'Download', error: e);

// 禁止 print
```

### Widget 子属性
```dart
// child/children 放最后
Container(
  padding: const EdgeInsets.all(16),
  color: Colors.blue,
  child: const Text('Hello'),
);
```

## 错误处理模式

```dart
// 网络请求
Future<void> fetchData() async {
  try {
    final result = await repository.getData();
    state = SuccessState(result);
  } catch (e) {
    AppLogger.error('获取数据失败', tag: 'Feature', error: e);
    state = ErrorState('获取失败: $e');
  }
}

// UI 层错误展示
ref.watch(asyncProvider).when(
  data: (data) => DataWidget(data),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorWidget(e.toString()),
);
```

## 注释规范

```dart
/// 解析 BV 号并获取视频信息
///
/// [input] 可以是完整 URL 或纯 BV 号
Future<BvidInfo> parseVideo(String input) async { ... }
```
