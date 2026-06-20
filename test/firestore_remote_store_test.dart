import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:climb_log/data/app_database.dart';
import 'package:climb_log/sync/firestore_remote_store.dart';
import 'package:climb_log/sync/remote_store.dart';
import 'package:climb_log/sync/sync_service.dart';

AppDatabase _newDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('FirestoreRemoteStore 経由で2端末が同期し、時刻型も保たれる', () async {
    final firestore = FakeFirebaseFirestore();
    const uid = 'user-1'; // 同一ユーザーの2端末
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final at = DateTime(2026, 3, 1, 9, 30);
    final gymId = await a.insertGym(
      GymsCompanion.insert(
        name: '新宿ジム',
        syncId: const Value('g1'),
        updatedAt: Value(at),
      ),
    );
    await a.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 3, 1),
        grade: 'V5',
        syncId: const Value('c1'),
        updatedAt: Value(at),
      ),
    );

    await SyncService(
      a,
      FirestoreRemoteStore(uid: uid, firestore: firestore),
    ).sync();
    await SyncService(
      b,
      FirestoreRemoteStore(uid: uid, firestore: firestore),
    ).sync();

    final bClimb = (await b.watchClimbs().first).single;
    final bGym = (await b.watchGyms().first).single;
    expect(bGym.name, '新宿ジム');
    expect(bClimb.grade, 'V5');
    expect(bClimb.gymId, bGym.id); // FK が解決されている
    // DateTime ↔ Timestamp の往復で日付が保たれる
    expect(bClimb.date, DateTime(2026, 3, 1));

    // ユーザー隔離パスに保存されている
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection(SyncCollections.gyms)
        .doc('g1')
        .get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['updatedAt'], isA<Timestamp>());
  });

  test('別ユーザーのデータは取り込まれない（パス隔離）', () async {
    final firestore = FakeFirebaseFirestore();
    final a = _newDb();
    final b = _newDb();
    addTearDown(a.close);
    addTearDown(b.close);

    final gymId = await a.insertGym(
      GymsCompanion.insert(
        name: 'A専用',
        syncId: const Value('g1'),
        updatedAt: Value(DateTime(2026, 1, 1)),
      ),
    );
    await a.insertClimb(
      ClimbsCompanion.insert(
        gymId: gymId,
        date: DateTime(2026, 1, 1),
        grade: 'V2',
        syncId: const Value('c1'),
        updatedAt: Value(DateTime(2026, 1, 1)),
      ),
    );

    await SyncService(
      a,
      FirestoreRemoteStore(uid: 'user-A', firestore: firestore),
    ).sync();
    // 別ユーザーで pull しても何も入らない
    await SyncService(
      b,
      FirestoreRemoteStore(uid: 'user-B', firestore: firestore),
    ).sync();

    expect(await b.watchClimbs().first, isEmpty);
    expect(await b.watchGyms().first, isEmpty);
  });
}
