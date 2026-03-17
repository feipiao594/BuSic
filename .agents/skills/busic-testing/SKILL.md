---
name: busic-testing
description: BuSic测试规范。用于编写单元测试和集成测试，包含测试结构、Repository测试模式、验证要求
license: MIT
compatibility: opencode
---

## 测试要求

**每个功能必须实现对应测试。**

测试文件放在 `test/features/<feature_name>/` 目录：

```
test/features/
├── <feature>/domain/models/    # Freezed模型测试
├── <feature>/data/            # Repository测试
├── <feature>/application/    # Notifier测试
└── <feature>/presentation/   # Widget测试
```

## Repository 测试模式

### 基础结构

```dart
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:busic/core/database/app_database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late XxxRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = XxxRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('功能描述', () {
    test('测试用例描述', () async {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### 示例：歌曲备份导出测试

```dart
group('备份导出不含下载路径', () {
  test('有 localPath 的歌曲导出后不含路径字段', () async {
    // Arrange: 插入已下载歌曲
    await db.into(db.songs).insert(
      SongsCompanion.insert(
        bvid: 'BV1backup01',
        cid: 1001,
        originTitle: '已下载歌曲',
        originArtist: '歌手',
        localPath: const Value('/cache/song.m4s'),
        audioQuality: const Value(30280),
      ),
    );

    // Act
    final backup = await syncRepo.exportFullBackup();

    // Assert
    expect(backup.songs, hasLength(1));
    final json = jsonDecode(jsonEncode(backup.toJson()));
    expect(json['songs'][0].containsKey('localPath'), false);
  });
});
```

## 测试组织规范

### Group 命名

```dart
group('备份导出不含下载路径', () { ... });
group('恢复备份不引入无效路径', () { ... });
group('多歌单共享歌曲的备份恢复', () { ... });
```

### Test 命名

使用中文描述测试场景：
- `test('有 localPath 的歌曲导出后 SharedSong 不含路径字段', ...)`
- `test('合并导入的新歌曲 localPath 应为 null', ...)`

### Arrange-Act-Assert

```dart
test('描述', () async {
  // Arrange: 准备数据
  await db.into(db.songs).insert(...);

  // Act: 执行操作
  final result = await repository.doSomething();

  // Assert: 验证结果
  expect(result, expectedValue);
});
```

## 常用测试断言

```dart
expect(value, equals(expected));
expect(value, isNull);
expect(value, isNotNull);
expect(list, hasLength(3));
expect(json.containsKey('key'), false);
expect(() => code, throwsA(isA<Exception>()));
```

## 验证要求

完成任务前必须验证：

```bash
# 1. 静态分析（0 issues）
flutter analyze --no-fatal-infos

# 2. 所有测试通过
flutter test

# 3. 单个测试文件
flutter test test/features/share/data/backup_path_safety_test.dart
```

## 注意事项

1. 使用 `NativeDatabase.memory()` 创建内存数据库
2. 测试结束后调用 `db.close()` 释放资源
3. 设置 `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true`
4. 数据库操作是异步的，使用 `async/await`
5. JSON 序列化测试使用 `jsonDecode(jsonEncode(...))`
