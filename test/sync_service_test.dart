import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:climb_log/data/app_database.dart';
import 'package:climb_log/sync/remote_store.dart';
import 'package:climb_log/sync/sync_service.dart';

import 'support/fake_remote_store.dart';

// 端末をまたぐ秒精度の競合を避けるため、テストでは updatedAt を明示的に与える。
final t1 = DateTime(2026, 1, 1, 0, 0, 1);
final t2 = DateTime(2026, 1, 1, 0, 0, 2);
final t3 = DateTime(2026, 1, 1, 0, 0, 3);

AppDatabase _newDb() => AppDatabase.forTesting(NativeDatabase.memory());

Future<int> _addGym(
  AppDatabase db, {
  required String syncId,
  required String name,
  required DateTime at,
}) {
  return db.insertGym(
    GymsCompanion.insert(name: name, syncId: Value(syncId), updatedAt: Value(at)),
  );
}

Future<int> _addClimb(
  AppDatabase db, {
  required String syncId,
  required int gymId,
  required String grade,
  required DateTime at,
  int? wallTypeId,
}) {
  return db.insertClimb(
    ClimbsCompanion.insert(
      gymId: gymId,
      date: DateTime(2026, 1, 1),
      grade: grade,
      syncId: Value(syncId),
      wallTypeId: Value(wallTypeId),
      updatedAt: Value(at),
    ),
  );
}

void main() {
  // 2端末を模すため意図的に複数 DB を開く。Drift の警告を抑止する。
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('push→別端末 pull で記録が複製される（FK は syncId 経由で解決）', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await _addGym(a, syncId: 'g1', name: '渋谷ジム', at: t1);
    await _addClimb(a, syncId: 'c1', gymId: gymId, grade: 'V3', at: t1);

    await SyncService(a, remote).sync();
    await SyncService(b, remote).sync();

    final climbs = await b.watchClimbs().first;
    expect(climbs, hasLength(1));
    expect(climbs.single.grade, 'V3');

    final gyms = await b.watchGyms().first;
    expect(gyms.single.name, '渋谷ジム');
    // B 側でも FK が正しくローカル int に解決されている
    expect(climbs.single.gymId, gyms.single.id);
  });

  test('編集は Last-Write-Wins で新しい方が勝つ', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await _addGym(a, syncId: 'g1', name: 'G', at: t1);
    await _addClimb(a, syncId: 'c1', gymId: gymId, grade: 'V3', at: t1);
    await SyncService(a, remote).sync();
    await SyncService(b, remote).sync();

    // B が後で編集（t2 > t1）
    await (b.update(b.climbs)..where((c) => c.syncId.equals('c1'))).write(
      ClimbsCompanion(grade: const Value('V4'), updatedAt: Value(t2), dirty: const Value(true)),
    );
    await SyncService(b, remote).sync();

    // A が取り込むと、より新しい B の編集で上書きされる
    await SyncService(a, remote).sync();
    final aClimb = (await a.watchClimbs().first).single;
    expect(aClimb.grade, 'V4');
  });

  test('古い編集は新しいローカルを上書きしない（LWW）', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await _addGym(a, syncId: 'g1', name: 'G', at: t1);
    await _addClimb(a, syncId: 'c1', gymId: gymId, grade: 'V3', at: t1);
    await SyncService(a, remote).sync();
    await SyncService(b, remote).sync();

    // A をより新しく編集（t3）してからリモートへ
    await (a.update(a.climbs)..where((c) => c.syncId.equals('c1'))).write(
      ClimbsCompanion(grade: const Value('A-new'), updatedAt: Value(t3), dirty: const Value(true)),
    );
    await SyncService(a, remote).sync();

    // B が古い編集（t2）をしていた場合、push 後に A が pull しても上書きされない
    await (b.update(b.climbs)..where((c) => c.syncId.equals('c1'))).write(
      ClimbsCompanion(grade: const Value('B-old'), updatedAt: Value(t2), dirty: const Value(true)),
    );
    await SyncService(b, remote).sync(); // push(t2) は remote の t3 を上書きしない…
    await SyncService(a, remote).sync();

    // A は自分の新しい値を保持
    expect((await a.watchClimbs().first).single.grade, 'A-new');
  });

  test('削除は tombstone として伝播し、別端末でも消える', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await _addGym(a, syncId: 'g1', name: 'G', at: t1);
    await _addClimb(a, syncId: 'c1', gymId: gymId, grade: 'V3', at: t1);
    await SyncService(a, remote).sync();
    await SyncService(b, remote).sync();
    expect(await b.watchClimbs().first, hasLength(1));

    // A が削除（論理削除, t3）
    await (a.update(a.climbs)..where((c) => c.syncId.equals('c1'))).write(
      ClimbsCompanion(isDeleted: const Value(true), updatedAt: Value(t3), dirty: const Value(true)),
    );
    await SyncService(a, remote).sync();
    await SyncService(b, remote).sync();

    // B の一覧から消える（行は tombstone として残る）
    expect(await b.watchClimbs().first, isEmpty);
    final raw = await b.select(b.climbs).get();
    expect(raw.single.isDeleted, isTrue);
  });

  test('カスタム壁種別が同期され、参照する記録の FK が解決される', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await _addGym(a, syncId: 'g1', name: 'G', at: t1);
    final wallId = await a.insertWallType('カチ壁');
    await _addClimb(
      a,
      syncId: 'c1',
      gymId: gymId,
      grade: 'V3',
      at: t1,
      wallTypeId: wallId,
    );

    await SyncService(a, remote).sync();
    await SyncService(b, remote).sync();

    final bWall = (await b.watchWallTypes().first).firstWhere(
      (w) => w.name == 'カチ壁',
    );
    final bClimb = (await b.watchClimbs().first).single;
    expect(bClimb.wallTypeId, bWall.id);
  });

  test('デフォルト壁種別（dirty=false）は push されない', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    addTearDown(a.close);

    await _addGym(a, syncId: 'g1', name: 'G', at: t1);
    await SyncService(a, remote).sync();

    // seed 済みの標準壁種別は同期対象外
    expect(remote.count(SyncCollections.wallTypes), 0);
    expect(remote.count(SyncCollections.gyms), 1);
  });

  test('pull は冪等：複数回 sync しても重複しない', () async {
    final remote = FakeRemoteStore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await _addGym(a, syncId: 'g1', name: 'G', at: t1);
    await _addClimb(a, syncId: 'c1', gymId: gymId, grade: 'V3', at: t1);
    await SyncService(a, remote).sync();

    await SyncService(b, remote).sync();
    await SyncService(b, remote).sync();
    await SyncService(b, remote).sync();

    expect(await b.watchClimbs().first, hasLength(1));
    expect(await b.watchGyms().first, hasLength(1));
  });
}
