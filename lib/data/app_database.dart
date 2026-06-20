import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// ジム。グレード体系（級段 / 色テープ / V）を保持する。
class Gyms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get location => text().nullable()();
  // 'grade'（級/段）, 'color'（色テープ）, 'v'（Vグレード）
  TextColumn get gradeSystem => text().withDefault(const Constant('grade'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 壁の種類マスタ（スラブ / 垂壁 / 強傾斜 / ルーフ など。ユーザー追加可）。
class WallTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

/// 登攀記録。1課題1トライセット分。
class Climbs extends Table {
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
class ClimbPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get climbId =>
      integer().references(Climbs, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Gyms, WallTypes, Climbs, ClimbPhotos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // デフォルトの壁種別をシード
      await batch((b) {
        b.insertAll(wallTypes, const [
          WallTypesCompanion(name: Value('スラブ')),
          WallTypesCompanion(name: Value('垂壁')),
          WallTypesCompanion(name: Value('強傾斜')),
          WallTypesCompanion(name: Value('ルーフ')),
        ]);
      });
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(climbPhotos);
        // 既存の単一写真を新しい写真テーブルへ移行
        final withPhoto = await (select(
          climbs,
        )..where((c) => c.photoPath.isNotNull())).get();
        for (final c in withPhoto) {
          await into(climbPhotos).insert(
            ClimbPhotosCompanion.insert(climbId: c.id, path: c.photoPath!),
          );
        }
      }
    },
    beforeOpen: (details) async {
      // ON DELETE CASCADE を効かせるため外部キー制約を有効化する
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // --- Gyms ---
  Stream<List<Gym>> watchGyms() => (select(
    gyms,
  )..orderBy([(g) => OrderingTerm(expression: g.name)])).watch();

  Future<Gym?> getGym(int id) =>
      (select(gyms)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<int> insertGym(GymsCompanion gym) => into(gyms).insert(gym);

  Future<bool> updateGym(GymsCompanion gym) => update(gyms).replace(gym);

  Future<int> deleteGym(int id) =>
      (delete(gyms)..where((g) => g.id.equals(id))).go();

  // --- WallTypes ---
  Stream<List<WallType>> watchWallTypes() => (select(
    wallTypes,
  )..orderBy([(w) => OrderingTerm(expression: w.id)])).watch();

  Future<int> insertWallType(String name) =>
      into(wallTypes).insert(WallTypesCompanion(name: Value(name)));

  // --- Climbs ---
  Stream<List<Climb>> watchClimbs() =>
      (select(climbs)..orderBy([
            (c) => OrderingTerm(expression: c.date, mode: OrderingMode.desc),
            (c) =>
                OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc),
          ]))
          .watch();

  Future<int> insertClimb(ClimbsCompanion climb) => into(climbs).insert(climb);

  Future<bool> updateClimb(ClimbsCompanion climb) =>
      update(climbs).replace(climb);

  Future<int> deleteClimb(int id) =>
      (delete(climbs)..where((c) => c.id.equals(id))).go();

  // --- ClimbPhotos ---
  /// 全写真を監視（記録一覧のサムネ表示用）。
  Stream<List<ClimbPhoto>> watchAllPhotos() => (select(
    climbPhotos,
  )..orderBy([(p) => OrderingTerm(expression: p.sortOrder)])).watch();

  Future<List<ClimbPhoto>> getClimbPhotos(int climbId) =>
      (select(climbPhotos)
            ..where((p) => p.climbId.equals(climbId))
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
      (delete(climbPhotos)..where((p) => p.id.equals(id))).go();

  /// エクスポート用に全記録を新しい順で取得。
  Future<List<Climb>> getAllClimbs() =>
      (select(climbs)..orderBy([
            (c) => OrderingTerm(expression: c.date, mode: OrderingMode.desc),
          ]))
          .get();
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'climb_log');
}
