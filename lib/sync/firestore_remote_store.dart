import 'package:cloud_firestore/cloud_firestore.dart';

import 'remote_store.dart';

/// [RemoteSyncStore] の Cloud Firestore 実装。
///
/// データはユーザー単位に隔離して `/users/{uid}/{collection}/{syncId}` に置く。
/// 同期エンジンは `Map` 内の時刻を `DateTime` で扱うため、Firestore の
/// `Timestamp` との相互変換をこの層で行う。
class FirestoreRemoteStore implements RemoteSyncStore {
  FirestoreRemoteStore({required this.uid, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 同期対象ユーザーの UID（認証済み前提）。
  final String uid;
  final FirebaseFirestore _firestore;

  /// Firestore のバッチ書き込み上限。
  static const _batchLimit = 500;

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection('users').doc(uid).collection(name);

  @override
  Future<void> upsert(
    String collection,
    List<Map<String, Object?>> docs,
  ) async {
    final col = _collection(collection);
    // 500件ごとにバッチを分割してコミットする。
    for (var i = 0; i < docs.length; i += _batchLimit) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(i).take(_batchLimit)) {
        final ref = col.doc(doc['syncId'] as String);
        batch.set(ref, _toFirestore(doc), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  @override
  Future<List<Map<String, Object?>>> fetchSince(
    String collection,
    DateTime? since,
  ) async {
    Query<Map<String, dynamic>> query = _collection(
      collection,
    ).orderBy('updatedAt');
    if (since != null) {
      query = query.where(
        'updatedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(since),
      );
    }
    final snap = await query.get();
    return snap.docs.map((d) => _fromFirestore(d.data())).toList();
  }

  /// DateTime → Timestamp（その他はそのまま）。
  Map<String, Object?> _toFirestore(Map<String, Object?> doc) => {
        for (final e in doc.entries)
          e.key: e.value is DateTime
              ? Timestamp.fromDate(e.value as DateTime)
              : e.value,
      };

  /// Timestamp → DateTime（その他はそのまま）。
  Map<String, Object?> _fromFirestore(Map<String, dynamic> data) => {
        for (final e in data.entries)
          e.key:
              e.value is Timestamp ? (e.value as Timestamp).toDate() : e.value,
      };
}
