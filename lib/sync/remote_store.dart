/// クラウド側ストレージの抽象。実装は Firestore アダプタ（Phase1後半）や
/// テスト用のインメモリ fake で差し替える。同期エンジン本体はこの I/F のみに依存する。
///
/// ドキュメントは `Map<String, Object?>` で表現し、各レコードは `syncId` で一意。
/// `updatedAt` は `DateTime` で持つ（Firestore 実装側で Timestamp へ変換する）。
abstract class RemoteSyncStore {
  /// [collection] に [docs] を upsert する（キーは各 doc の `syncId`）。
  Future<void> upsert(String collection, List<Map<String, Object?>> docs);

  /// [collection] のうち `updatedAt` が [since] 以降のドキュメントを取得する。
  ///
  /// [since] が null なら全件。境界（同一 updatedAt）での取りこぼしを防ぐため
  /// 「以降（>=）」とし、適用側は LWW で冪等に処理する。
  Future<List<Map<String, Object?>>> fetchSince(
    String collection,
    DateTime? since,
  );
}

/// 同期対象コレクション名。リモートのパス（例: `/users/{uid}/{collection}`）に対応。
class SyncCollections {
  SyncCollections._();
  static const gyms = 'gyms';
  static const wallTypes = 'wallTypes';
  static const climbs = 'climbs';

  /// pull は親→子の順で適用する（Climbs は Gyms / WallTypes を参照するため）。
  static const ordered = [gyms, wallTypes, climbs];
}
