import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:climb_log/data/app_database.dart';
import 'package:climb_log/main.dart';
import 'package:climb_log/providers.dart';

void main() {
  testWidgets('空状態でアプリが起動し記録タブが表示される', (tester) async {
    // 実DBを開かずにストリームを差し替え、UIワイヤリングだけを検証する
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymsProvider.overrideWith((ref) => Stream.value(const <Gym>[])),
          climbsProvider.overrideWith((ref) => Stream.value(const <Climb>[])),
          wallTypesProvider.overrideWith(
            (ref) => Stream.value(const <WallType>[]),
          ),
          allPhotosProvider.overrideWith(
            (ref) => Stream.value(const <ClimbPhoto>[]),
          ),
        ],
        child: const ClimbLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登攀記録'), findsOneWidget);
    expect(find.text('記録する'), findsOneWidget);
    expect(find.text('まだ記録がありません'), findsOneWidget);
  });

  test('ジムと登攀記録を保存できる', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final gymId = await db.insertGym(GymsCompanion.insert(name: 'テストジム'));
    await db.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 6, 20),
        grade: '二級',
      ),
    );

    final climbs = await db.watchClimbs().first;
    expect(climbs, hasLength(1));
    expect(climbs.first.grade, '二級');
    expect(climbs.first.isSent, false);

    // デフォルトの壁種別がシードされている
    final walls = await db.watchWallTypes().first;
    expect(walls.map((w) => w.name), contains('スラブ'));
  });

  test('1記録に複数の写真を保存でき、記録削除でカスケード削除される', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final gymId = await db.insertGym(GymsCompanion.insert(name: 'G'));
    final climbId = await db.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 6, 20),
        grade: 'V3',
      ),
    );

    await db.insertClimbPhoto(climbId, '/tmp/a.jpg', 0);
    await db.insertClimbPhoto(climbId, '/tmp/b.jpg', 1);

    final photos = await db.getClimbPhotos(climbId);
    expect(photos.map((p) => p.path), ['/tmp/a.jpg', '/tmp/b.jpg']);

    // 記録を消すと写真行もカスケード削除される
    await db.deleteClimb(climbId);
    expect(await db.getClimbPhotos(climbId), isEmpty);
  });

  test('挿入時に syncId が自動付与され dirty=true になる', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final gymId = await db.insertGym(GymsCompanion.insert(name: 'G'));
    final gym = await db.getGym(gymId);
    expect(gym, isNotNull);
    expect(gym!.syncId, isNotEmpty);
    expect(gym.dirty, isTrue);
    expect(gym.isDeleted, isFalse);
  });

  test('デフォルト壁種別は固定 syncId・dirty=false で seed される', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final walls = await db.watchWallTypes().first;
    final slab = walls.firstWhere((w) => w.name == 'スラブ');
    expect(slab.syncId, 'seed-wall-slab');
    expect(slab.dirty, isFalse); // 標準データは同期 push 対象にしない
  });

  test('削除は論理削除：行は残るがクエリから除外される', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final gymId = await db.insertGym(GymsCompanion.insert(name: 'G'));
    final climbId = await db.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 6, 20),
        grade: 'V3',
      ),
    );

    await db.deleteClimb(climbId);

    // クエリ（isDeleted=false フィルタ）からは消える
    expect(await db.watchClimbs().first, isEmpty);
    expect(await db.getAllClimbs(), isEmpty);

    // だが行自体は tombstone として残り、同期で削除を伝播できる
    final raw = await db.select(db.climbs).get();
    expect(raw, hasLength(1));
    expect(raw.single.isDeleted, isTrue);
    expect(raw.single.dirty, isTrue);
  });

  test('ジム削除は記録・写真へ連鎖的に論理削除される', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final gymId = await db.insertGym(GymsCompanion.insert(name: 'G'));
    final climbId = await db.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 6, 20),
        grade: 'V3',
      ),
    );
    await db.insertClimbPhoto(climbId, '/tmp/a.jpg', 0);

    await db.deleteGym(gymId);

    expect(await db.watchGyms().first, isEmpty);
    expect(await db.watchClimbs().first, isEmpty);
    expect(await db.getClimbPhotos(climbId), isEmpty);

    // 連鎖した行はすべて tombstone（isDeleted=true）になっている
    expect((await db.select(db.climbs).get()).single.isDeleted, isTrue);
    expect((await db.select(db.climbPhotos).get()).single.isDeleted, isTrue);
  });

  test('更新で updatedAt が進み dirty=true が立つ', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final gymId = await db.insertGym(GymsCompanion.insert(name: 'G'));
    final climbId = await db.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 6, 20),
        grade: 'V3',
      ),
    );

    // dirty を落とし updatedAt を過去にしておき、更新で両方が変わることを確認する
    // （Drift は DateTime を秒精度で保存するため、明示的に過去日時を置く）。
    await (db.update(db.climbs)..where((c) => c.id.equals(climbId))).write(
      ClimbsCompanion(dirty: const Value(false), updatedAt: Value(DateTime(2020))),
    );
    final before = (await db.select(db.climbs).get()).single;
    expect(before.dirty, isFalse);

    await db.updateClimb(
      ClimbsCompanion(id: Value(climbId), grade: const Value('V4')),
    );

    final after = (await db.select(db.climbs).get()).single;
    expect(after.grade, 'V4');
    expect(after.dirty, isTrue);
    expect(after.updatedAt.isAfter(before.updatedAt), isTrue);
  });
}
