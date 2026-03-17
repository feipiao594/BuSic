---
name: busic-state-management
description: BuSic状态管理规范。用于Riverpod Notifier开发，包含Provider分类、编写规范、依赖注入、AutoDispose陷阱
license: MIT
compatibility: opencode
---

## Provider 分类

### 注解式 Notifier（主要模式）

```dart
// 异步 Notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    return await _loadSession();
  }
}

// 同步 Notifier
@riverpod
class PlayerNotifier extends _$PlayerNotifier {
  @override
  PlayerState build() {
    return PlayerState.initial();
  }
}

// Family Provider（参数化）
@riverpod
class PlaylistDetailNotifier extends _$PlaylistDetailNotifier {
  @override
  Future<List<SongItem>> build(int playlistId) async {
    return await _repository.getSongs(playlistId);
  }
}
```

### 手动 Provider（特殊场景）

```dart
// 全局单例
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('应通过 override 注入');
});

// 需要 keep-alive 的仓库
final downloadRepositoryProvider = Provider<DownloadRepositoryImpl>((ref) {
  final db = ref.watch(databaseProvider);
  return DownloadRepositoryImpl(db);
});
```

## Notifier 编写规范

### 结构模板

```dart
@riverpod
class XxxNotifier extends _$XxxNotifier {
  late final XxxRepository _repository;

  @override
  Future<XxxState> build() async {
    final db = ref.watch(databaseProvider);
    _repository = XxxRepositoryImpl(db);
    return await _repository.loadInitialData();
  }

  Future<void> doSomething() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.doSomething();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

### 状态更新方式

```dart
// 异步 Notifier
state = const AsyncValue.loading();
state = AsyncValue.data(newData);
state = AsyncValue.error(e, st);

// 同步 Notifier
state = state.copyWith(isPlaying: true);

// 联合类型状态
state = ParseState.parsing();
state = ParseState.success(result);
```

## 在 UI 中使用 Provider

### Widget 基类选择

```dart
// 纯展示 + 读取 Provider
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xxxNotifierProvider);
    // ...
  }
}

// 需要 State 生命周期
class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}
```

### watch vs read 规则

```dart
// build() 中用 watch
final state = ref.watch(playerNotifierProvider);

// 回调/事件中用 read
onPressed: () => ref.read(playerNotifierProvider.notifier).play(),
```

## 依赖注入

```dart
// main.dart
void main() async {
  final database = AppDatabase();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const App(),
    ),
  );
}
```

## AutoDispose 生命周期陷阱

### 问题场景

对话框关闭后执行回调时，notifier 可能已被 AutoDispose 回收。

### 解决方案

**方案 A：使用 `ref.keepAlive()`**

```dart
Future<void> doSomething() async {
  final link = ref.keepAlive();
  try {
    state = SomeState.loading();
    final result = await _repo.fetchData();
    state = SomeState.success(result);
  } catch (e) {
    state = SomeState.error('失败: $e');
  } finally {
    link.close();
  }
}
```

**方案 B：通过 Navigator.pop() 返回数据**

```dart
final result = await showDialog<(String, List<Item>)>(
  context: context,
  builder: (_) => SelectionDialog(...),
);
if (result == null) return;
final freshNotifier = ref.read(someNotifierProvider.notifier);
await freshNotifier.doSomething(result);
```

### 关键规则

1. 所有修改 state 的异步方法必须使用 `ref.keepAlive()`
2. `state = ...` 必须放在 try 块内部
3. 跨对话框使用 notifier 前，用 `ref.read()` 重新获取
