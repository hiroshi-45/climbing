import 'package:climb_log/sync/remote_store.dart';

/// テスト用のインメモリ [RemoteSyncStore]。複数の端末（AppDatabase）から
/// 共有して、双方向同期の収束を検証するのに使う。
class FakeRemoteStore implements RemoteSyncStore {
  // collection -> (syncId -> doc)
  final Map<String, Map<String, Map<String, Object?>>> _data = {};

  @override
  Future<void> upsert(
      String collection, List<Map<String, Object?>> docs) async {
    final col = _data.putIfAbsent(collection, () => {});
    for (final d in docs) {
      col[d['syncId'] as String] = Map<String, Object?>.from(d);
    }
  }

  @override
  Future<List<Map<String, Object?>>> fetchSince(
    String collection,
    DateTime? since,
  ) async {
    final col = _data[collection];
    if (col == null) return const [];
    final list = col.values
        // updatedAt >= since（境界の取りこぼし防止。適用側は LWW で冪等）。
        .where(
          (d) => since == null || !(d['updatedAt'] as DateTime).isBefore(since),
        )
        .map((d) => Map<String, Object?>.from(d))
        .toList()
      ..sort(
        (a, b) => (a['updatedAt'] as DateTime).compareTo(
          b['updatedAt'] as DateTime,
        ),
      );
    return list;
  }

  /// 検証用：コレクション内のドキュメント数。
  int count(String collection) => _data[collection]?.length ?? 0;
}
