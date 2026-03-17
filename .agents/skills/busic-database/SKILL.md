---
name: busic-database
description: BuSic数据库操作规范。用于Drift数据库表定义、迁移、Repository实现时参考
license: MIT
compatibility: opencode
---

## 数据库配置

数据库定义在 `lib/core/database/app_database.dart`：

```dart
@DriftDatabase(tables: [Songs, Playlists, PlaylistSongs, DownloadTasks, UserSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
```

- 数据库文件：`documents/busic/busic.db`
- 使用 `LazyDatabase` + `NativeDatabase.createInBackground`
- `schemaVersion` 起始为 1

## 新增表规范

```dart
// lib/core/database/tables/new_table.dart
import 'package:drift/drift.dart';

class NewItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get playlistId => integer().references(Playlists, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get status => integer().withDefault(const Constant(0))();
}
```

### 新增表后操作

1. 在 `AppDatabase` 的 `@DriftDatabase(tables: [...])` 中注册
2. 递增 `schemaVersion`
3. 编写迁移代码
4. 运行 `dart run build_runner build --delete-conflicting-outputs`

## 迁移规范

- **永远不要删除或重命名旧字段**
- 仅通过 `addColumn` 添加新列并设置默认值

```dart
onUpgrade((Migrator m) async {
  if (from < 2) {
    await m.addColumn(songs, songs.newField);
  }
});
```

## Freezed 模型

### 数据类 + JSON 序列化
```dart
@freezed
class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required int songId,
    required String bvid,
    String? coverUrl,
    @Default(0) int quality,
  }) = _AudioTrack;

  factory AudioTrack.fromJson(Map<String, dynamic> json) =>
      _$AudioTrackFromJson(json);
}
```

### 联合类型（状态枚举）
```dart
@freezed
class ParseState with _$ParseState {
  const factory ParseState.idle() = _Idle;
  const factory ParseState.parsing() = _Parsing;
  const factory ParseState.success(BvidInfo info) = _Success;
  const factory ParseState.error(String message) = _Error;
}
```

### 带计算属性的模型
```dart
@freezed
class SongItem with _$SongItem {
  const SongItem._();
  const factory SongItem({ ... }) = _SongItem;

  String get displayTitle => customTitle ?? originTitle;
  bool get isCached => localPath != null;
}
```

## Repository 模式

### 接口定义
```dart
abstract class XxxRepository {
  Future<List<Item>> getAll();
  Future<Item?> getById(int id);
  Future<void> create(Item item);
  Future<void> update(Item item);
  Future<void> delete(int id);
}
```

### 实现类
```dart
class XxxRepositoryImpl implements XxxRepository {
  final AppDatabase _db;
  XxxRepositoryImpl(this._db);

  @override
  Future<List<Item>> getAll() async {
    final rows = await _db.select(_db.items).get();
    return rows.map(_mapToModel).toList();
  }

  Item _mapToModel(ItemRow row) {
    return Item(id: row.id, name: row.name);
  }
}
```

### 关键原则

1. Repository 接口定义在 `data/` 目录
2. Domain 模型和 DB 表是分离的
3. Repository 由 Notifier 在 `build()` 中手动创建
4. 需要 keep-alive 的 Repository 用手动 Provider 管理
