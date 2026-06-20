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
}
