import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_database.dart';
import 'premium/purchase_service.dart';
import 'stats/climb_stats.dart';

/// アプリ全体で共有する単一のDBインスタンス。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final gymsProvider = StreamProvider<List<Gym>>((ref) {
  return ref.watch(databaseProvider).watchGyms();
});

final wallTypesProvider = StreamProvider<List<WallType>>((ref) {
  return ref.watch(databaseProvider).watchWallTypes();
});

final climbsProvider = StreamProvider<List<Climb>>((ref) {
  return ref.watch(databaseProvider).watchClimbs();
});

/// id → ジム の参照用マップ（記録一覧でジム名を引くのに使う）。
final gymMapProvider = Provider<Map<int, Gym>>((ref) {
  final gyms = ref.watch(gymsProvider).value ?? const [];
  return {for (final g in gyms) g.id: g};
});

/// id → 壁種別 の参照用マップ。
final wallTypeMapProvider = Provider<Map<int, WallType>>((ref) {
  final walls = ref.watch(wallTypesProvider).value ?? const [];
  return {for (final w in walls) w.id: w};
});

final allPhotosProvider = StreamProvider<List<ClimbPhoto>>((ref) {
  return ref.watch(databaseProvider).watchAllPhotos();
});

/// climbId → 写真リスト。記録一覧のサムネ表示に使う。
final photosByClimbProvider = Provider<Map<int, List<ClimbPhoto>>>((ref) {
  final photos = ref.watch(allPhotosProvider).value ?? const [];
  final map = <int, List<ClimbPhoto>>{};
  for (final p in photos) {
    map.putIfAbsent(p.climbId, () => []).add(p);
  }
  return map;
});

/// 登攀記録から導出した統計。記録か壁種別が更新されると自動で再計算される。
final climbStatsProvider = Provider<ClimbStats>((ref) {
  final climbs = ref.watch(climbsProvider).value ?? const [];
  final wallMap = ref.watch(wallTypeMapProvider);
  return computeStats(climbs, wallMap);
});

/// プレミアム（課金）権利の有無。RevenueCatの状態を反映する。
final premiumProvider = NotifierProvider<PremiumController, bool>(
  PremiumController.new,
);

class PremiumController extends Notifier<bool> {
  @override
  bool build() {
    _refresh();
    return false;
  }

  Future<void> _refresh() async {
    try {
      final has = await PurchaseService.hasPremium();
      if (has) state = true;
    } catch (_) {
      // 取得失敗時はロックのまま（無料状態）
    }
  }

  /// 購入完了後などに最新の権利状態へ更新する。
  void setPremium(bool value) => state = value;

  Future<bool> restore() async {
    final ok = await PurchaseService.restore();
    state = ok;
    return ok;
  }
}
