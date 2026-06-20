import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

/// 同期対応テーブルが共通で持つカラム群。
///
/// - [syncId]   : 端末をまたいで一意な同期キー（int の自動採番PKは端末間で
///                衝突するため、クラウド上の文書キーにはこちらを使う）。
/// - [updatedAt]: 最終更新時刻。競合は Last-Write-Wins で解決する。
/// - [isDeleted]: 論理削除。物理削除は他端末へ伝播できないため tombstone 化する。
/// - [dirty]    : ローカル未同期フラグ。Phase1 の push 対象判定に使う。
mixin _SyncColumns on Table {
  TextColumn get syncId => text().unique().clientDefault(_uuid.v4)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
}

/// ジム。グレード体系（級段 / 色テープ / V）を保持する。
class Gyms extends Table with _SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get location => text().nullable()();
  // 'grade'（級/段）, 'color'（色テープ）, 'v'（Vグレード）
  TextColumn get gradeSystem => text().withDefault(const Constant('grade'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 壁の種類マスタ（スラブ / 垂壁 / 強傾斜 / ルーフ など。ユーザー追加可）。
class WallTypes extends Table with _SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

/// 登攀記録。1課題1トライセット分。
class Climbs extends Table with _SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gymId =>
      integer().references(Gyms, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  // グレード文字列（体系に依存させず柔軟に保持: "二級", "赤", "V4" など）
  TextColumn get grade => text().withLength(min: 1, max: 20)();
  IntColumn get wallTypeId => integer().nullable().references(
    WallTypes,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get attempts => integer().withDefault(const Constant(1))();
  BoolColumn get isSent => boolean().withDefault(const Constant(false))();
  // 後方互換のため残置（v2以降は ClimbPhotos を使用）。
  TextColumn get photoPath => text().nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 登攀記録に添付する写真（1記録に複数枚。無料は1枚、プレミアムは無制限）。
class ClimbPhotos extends Table with _SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get climbId =>
      integer().references(Climbs, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// デフォルト壁種別。端末間で重複登録されないよう syncId を固定する
/// （別端末でも同じ syncId で seed されるため、同期時に同一行として扱える）。
const _defaultWallTypes = <(String, String)>[
  ('seed-wall-slab', 'スラブ'),
  ('seed-wall-vertical', '垂壁'),
  ('seed-wall-overhang', '強傾斜'),
  ('seed-wall-roof', 'ルーフ'),
];

@DriftDatabase(tables: [Gyms, WallTypes, Climbs, ClimbPhotos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedWallTypes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        // 同期対応スキーマへ移行。旧データは破棄して作り直す（ユーザー許諾済み）。
        for (final t in allTables) {
          await customStatement('DROP TABLE IF EXISTS ${t.actualTableName}');
        }
        await m.createAll();
        await _seedWallTypes();
      }
    },
    beforeOpen: (details) async {
      // ON DELETE CASCADE を効かせるため外部キー制約を有効化する
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// デフォルト壁種別を投入する。固定 syncId・dirty=false で、標準データとして扱う。
  Future<void> _seedWallTypes() async {
    await batch((b) {
      b.insertAll(wallTypes, [
        for (final (sid, name) in _defaultWallTypes)
          WallTypesCompanion.insert(
            name: name,
            syncId: Value(sid),
            dirty: const Value(false),
          ),
      ]);
    });
  }

  // --- Gyms ---
  Stream<List<Gym>> watchGyms() =>
      (select(gyms)
            ..where((g) => g.isDeleted.equals(false))
            ..orderBy([(g) => OrderingTerm(expression: g.name)]))
          .watch();

  Future<Gym?> getGym(int id) => (select(
    gyms,
  )..where((g) => g.id.equals(id) & g.isDeleted.equals(false))).getSingleOrNull();

  Future<int> insertGym(GymsCompanion gym) => into(gyms).insert(gym);

  Future<bool> updateGym(GymsCompanion gym) async {
    final n = await (update(gyms)..where((g) => g.id.equals(gym.id.value)))
        .write(
          gym.copyWith(updatedAt: Value(DateTime.now()), dirty: const Value(true)),
        );
    return n > 0;
  }

  /// ジムを論理削除し、ひも付く登攀記録と写真も連鎖的に論理削除する。
  Future<int> deleteGym(int id) async {
    final now = DateTime.now();
    final climbIds = (await (select(
      climbs,
    )..where((c) => c.gymId.equals(id))).get()).map((c) => c.id).toList();
    if (climbIds.isNotEmpty) {
      await (update(climbPhotos)..where((p) => p.climbId.isIn(climbIds)))
          .write(_photoTombstone(now));
      await (update(climbs)..where((c) => c.gymId.equals(id)))
          .write(_climbTombstone(now));
    }
    return (update(gyms)..where((g) => g.id.equals(id))).write(_gymTombstone(now));
  }

  // --- WallTypes ---
  Stream<List<WallType>> watchWallTypes() =>
      (select(wallTypes)
            ..where((w) => w.isDeleted.equals(false))
            ..orderBy([(w) => OrderingTerm(expression: w.id)]))
          .watch();

  Future<int> insertWallType(String name) =>
      into(wallTypes).insert(WallTypesCompanion(name: Value(name)));

  // --- Climbs ---
  Stream<List<Climb>> watchClimbs() =>
      (select(climbs)
            ..where((c) => c.isDeleted.equals(false))
            ..orderBy([
              (c) => OrderingTerm(expression: c.date, mode: OrderingMode.desc),
              (c) =>
                  OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<int> insertClimb(ClimbsCompanion climb) => into(climbs).insert(climb);

  Future<bool> updateClimb(ClimbsCompanion climb) async {
    final n = await (update(climbs)..where((c) => c.id.equals(climb.id.value)))
        .write(
          climb.copyWith(
            updatedAt: Value(DateTime.now()),
            dirty: const Value(true),
          ),
        );
    return n > 0;
  }

  /// 登攀記録を論理削除し、添付写真も連鎖的に論理削除する。
  Future<int> deleteClimb(int id) async {
    final now = DateTime.now();
    await (update(climbPhotos)..where((p) => p.climbId.equals(id)))
        .write(_photoTombstone(now));
    return (update(climbs)..where((c) => c.id.equals(id)))
        .write(_climbTombstone(now));
  }

  // --- ClimbPhotos ---
  /// 全写真を監視（記録一覧のサムネ表示用）。
  Stream<List<ClimbPhoto>> watchAllPhotos() =>
      (select(climbPhotos)
            ..where((p) => p.isDeleted.equals(false))
            ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
          .watch();

  Future<List<ClimbPhoto>> getClimbPhotos(int climbId) =>
      (select(climbPhotos)
            ..where((p) => p.climbId.equals(climbId) & p.isDeleted.equals(false))
            ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
          .get();

  Future<int> insertClimbPhoto(int climbId, String path, int sortOrder) =>
      into(climbPhotos).insert(
        ClimbPhotosCompanion.insert(
          climbId: climbId,
          path: path,
          sortOrder: Value(sortOrder),
        ),
      );

  Future<int> deleteClimbPhoto(int id) =>
      (update(climbPhotos)..where((p) => p.id.equals(id)))
          .write(_photoTombstone(DateTime.now()));

  /// エクスポート用に全記録を新しい順で取得。
  Future<List<Climb>> getAllClimbs() =>
      (select(climbs)
            ..where((c) => c.isDeleted.equals(false))
            ..orderBy([
              (c) => OrderingTerm(expression: c.date, mode: OrderingMode.desc),
            ]))
          .get();
}

// 論理削除用の Companion（write() に渡して使う）。テーブルごとに型が異なる。
GymsCompanion _gymTombstone(DateTime now) => GymsCompanion(
  isDeleted: const Value(true),
  dirty: const Value(true),
  updatedAt: Value(now),
);

ClimbsCompanion _climbTombstone(DateTime now) => ClimbsCompanion(
  isDeleted: const Value(true),
  dirty: const Value(true),
  updatedAt: Value(now),
);

ClimbPhotosCompanion _photoTombstone(DateTime now) => ClimbPhotosCompanion(
  isDeleted: const Value(true),
  dirty: const Value(true),
  updatedAt: Value(now),
);

QueryExecutor _openConnection() {
  return driftDatabase(name: 'climb_log');
}
