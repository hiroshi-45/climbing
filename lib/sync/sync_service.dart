import 'package:drift/drift.dart' show Value;

import '../data/app_database.dart';
import 'remote_store.dart';

/// ローカル（Drift）とクラウド（[RemoteSyncStore]）の双方向差分同期。
///
/// 設計:
/// - ローカルが正。クラウドはミラー。無料層は本サービスを起動しない。
/// - 競合は Last-Write-Wins（`updatedAt` 比較。同値はローカル優先）。
/// - 削除は tombstone（`isDeleted=true`）で伝播する。
/// - 端末をまたぐ参照は `syncId` で行い、pull 時にローカル int FK へ解決する。
/// - 写真（ClimbPhotos）は Phase1 では同期対象外（ファイル実体を伴うため Phase2）。
class SyncService {
  SyncService(this._db, this._remote);

  final AppDatabase _db;
  final RemoteSyncStore _remote;

  /// push（ローカル変更の送信）→ pull（リモート変更の取り込み）の順で1巡する。
  Future<void> sync() async {
    await _push();
    await _pull();
  }

  // ===================== push =====================

  Future<void> _push() async {
    await _pushGyms();
    await _pushWallTypes();
    await _pushClimbs();
  }

  Future<void> _pushGyms() async {
    final dirty = await _db.dirtyGyms();
    if (dirty.isEmpty) return;
    await _remote.upsert(SyncCollections.gyms, dirty.map(_gymToDoc).toList());
    for (final g in dirty) {
      await _db.markGymSynced(g.syncId, g.updatedAt);
    }
  }

  Future<void> _pushWallTypes() async {
    final dirty = await _db.dirtyWallTypes();
    if (dirty.isEmpty) return;
    await _remote.upsert(
      SyncCollections.wallTypes,
      dirty.map(_wallTypeToDoc).toList(),
    );
    for (final w in dirty) {
      await _db.markWallTypeSynced(w.syncId, w.updatedAt);
    }
  }

  Future<void> _pushClimbs() async {
    final dirty = await _db.dirtyClimbs();
    if (dirty.isEmpty) return;
    // FK（gymId / wallTypeId）→ syncId へ変換するためのマップ（論理削除も含む）。
    final gymSyncId = {for (final g in await _db.allGymsRaw()) g.id: g.syncId};
    final wallSyncId = {
      for (final w in await _db.allWallTypesRaw()) w.id: w.syncId,
    };
    final docs =
        dirty.map((c) => _climbToDoc(c, gymSyncId, wallSyncId)).toList();
    await _remote.upsert(SyncCollections.climbs, docs);
    for (final c in dirty) {
      await _db.markClimbSynced(c.syncId, c.updatedAt);
    }
  }

  // ===================== pull =====================

  Future<void> _pull() async {
    await _pullCollection(SyncCollections.gyms, _applyGym);
    await _pullCollection(SyncCollections.wallTypes, _applyWallType);
    await _pullCollection(SyncCollections.climbs, _applyClimb);
  }

  Future<void> _pullCollection(
    String collection,
    Future<void> Function(Map<String, Object?>) apply,
  ) async {
    final since = await _db.getSyncCursor(collection);
    final docs = await _remote.fetchSince(collection, since);
    if (docs.isEmpty) return;

    var maxSeen = since;
    for (final doc in docs) {
      await apply(doc);
      final u = doc['updatedAt'] as DateTime;
      if (maxSeen == null || u.isAfter(maxSeen)) maxSeen = u;
    }
    if (maxSeen != null) await _db.setSyncCursor(collection, maxSeen);
  }

  Future<void> _applyGym(Map<String, Object?> doc) async {
    final syncId = doc['syncId'] as String;
    final remoteUpdated = doc['updatedAt'] as DateTime;
    final local = await _db.gymBySyncId(syncId);
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.upsertGymFromRemote(
      GymsCompanion(
        syncId: Value(syncId),
        name: Value(doc['name'] as String),
        location: Value(doc['location'] as String?),
        gradeSystem: Value(doc['gradeSystem'] as String),
        createdAt: Value(doc['createdAt'] as DateTime),
        updatedAt: Value(remoteUpdated),
        isDeleted: Value(doc['isDeleted'] as bool),
        dirty: const Value(false),
      ),
    );
  }

  Future<void> _applyWallType(Map<String, Object?> doc) async {
    final syncId = doc['syncId'] as String;
    final remoteUpdated = doc['updatedAt'] as DateTime;
    final local = await _db.wallTypeBySyncId(syncId);
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.upsertWallTypeFromRemote(
      WallTypesCompanion(
        syncId: Value(syncId),
        name: Value(doc['name'] as String),
        updatedAt: Value(remoteUpdated),
        isDeleted: Value(doc['isDeleted'] as bool),
        dirty: const Value(false),
      ),
    );
  }

  Future<void> _applyClimb(Map<String, Object?> doc) async {
    final syncId = doc['syncId'] as String;
    final remoteUpdated = doc['updatedAt'] as DateTime;

    // 親（ジム）を syncId からローカル int へ解決。未取得なら今回はスキップし、
    // 次回同期で親が揃ってから取り込む。
    final gym = await _db.gymBySyncId(doc['gymSyncId'] as String);
    if (gym == null) return;

    int? wallTypeId;
    final wallSyncId = doc['wallTypeSyncId'] as String?;
    if (wallSyncId != null) {
      wallTypeId = (await _db.wallTypeBySyncId(wallSyncId))?.id;
    }

    final local = await _db.climbBySyncId(syncId);
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.upsertClimbFromRemote(
      ClimbsCompanion(
        syncId: Value(syncId),
        gymId: Value(gym.id),
        date: Value(doc['date'] as DateTime),
        grade: Value(doc['grade'] as String),
        wallTypeId: Value(wallTypeId),
        attempts: Value(doc['attempts'] as int),
        isSent: Value(doc['isSent'] as bool),
        memo: Value(doc['memo'] as String?),
        createdAt: Value(doc['createdAt'] as DateTime),
        updatedAt: Value(remoteUpdated),
        isDeleted: Value(doc['isDeleted'] as bool),
        dirty: const Value(false),
      ),
    );
  }

  // ===================== シリアライズ =====================

  Map<String, Object?> _gymToDoc(Gym g) => {
        'syncId': g.syncId,
        'name': g.name,
        'location': g.location,
        'gradeSystem': g.gradeSystem,
        'createdAt': g.createdAt,
        'updatedAt': g.updatedAt,
        'isDeleted': g.isDeleted,
      };

  Map<String, Object?> _wallTypeToDoc(WallType w) => {
        'syncId': w.syncId,
        'name': w.name,
        'updatedAt': w.updatedAt,
        'isDeleted': w.isDeleted,
      };

  Map<String, Object?> _climbToDoc(
    Climb c,
    Map<int, String> gymSyncId,
    Map<int, String> wallSyncId,
  ) =>
      {
        'syncId': c.syncId,
        'gymSyncId': gymSyncId[c.gymId],
        'wallTypeSyncId':
            c.wallTypeId == null ? null : wallSyncId[c.wallTypeId],
        'date': c.date,
        'grade': c.grade,
        'attempts': c.attempts,
        'isSent': c.isSent,
        'memo': c.memo,
        'createdAt': c.createdAt,
        'updatedAt': c.updatedAt,
        'isDeleted': c.isDeleted,
      };
}
