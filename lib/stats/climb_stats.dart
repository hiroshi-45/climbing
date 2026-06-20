import '../data/app_database.dart';

/// 月別の完登数。
class MonthlyCount {
  const MonthlyCount(this.year, this.month, this.sends, this.total);
  final int year;
  final int month;
  final int sends;
  final int total;

  String get label => '$year/${month.toString().padLeft(2, '0')}';
}

/// 指標の単位（グレード別・壁別）ごとの成功率。
class RateStat {
  const RateStat(this.label, this.sends, this.total);
  final String label;
  final int sends;
  final int total;

  /// 完登率（0.0〜1.0）。記録ゼロなら0。
  double get rate => total == 0 ? 0 : sends / total;
  int get ratePercent => (rate * 100).round();
}

/// 登攀記録から導出した統計のまとまり。
class ClimbStats {
  const ClimbStats({
    required this.totalClimbs,
    required this.totalSends,
    required this.totalAttempts,
    required this.monthly,
    required this.grades,
    required this.walls,
  });

  final int totalClimbs;
  final int totalSends;
  final int totalAttempts;
  final List<MonthlyCount> monthly; // 古い→新しい順
  final List<RateStat> grades; // 記録数の多い順
  final List<RateStat> walls; // 完登率の低い順（＝苦手な壁が上）

  double get overallSendRate => totalClimbs == 0 ? 0 : totalSends / totalClimbs;
  int get overallSendPercent => (overallSendRate * 100).round();

  static const empty = ClimbStats(
    totalClimbs: 0,
    totalSends: 0,
    totalAttempts: 0,
    monthly: [],
    grades: [],
    walls: [],
  );
}

/// 登攀記録一覧から統計を計算する。
///
/// [now] は月別集計の基準（直近 [monthsBack] ヶ月）に使う。テスト容易性のため注入可能。
ClimbStats computeStats(
  List<Climb> climbs,
  Map<int, WallType> wallTypes, {
  DateTime? now,
  int monthsBack = 6,
}) {
  if (climbs.isEmpty) return ClimbStats.empty;

  final base = now ?? DateTime.now();
  var totalSends = 0;
  var totalAttempts = 0;

  // 直近 monthsBack ヶ月分の枠を用意（記録ゼロの月も0として並べる）
  final monthKeys = <String>[];
  final monthOrder = <String, DateTime>{};
  for (var i = monthsBack - 1; i >= 0; i--) {
    final d = DateTime(base.year, base.month - i);
    final key = '${d.year}-${d.month}';
    monthKeys.add(key);
    monthOrder[key] = d;
  }
  final monthSends = {for (final k in monthKeys) k: 0};
  final monthTotal = {for (final k in monthKeys) k: 0};

  final gradeSends = <String, int>{};
  final gradeTotal = <String, int>{};
  final wallSends = <int, int>{};
  final wallTotal = <int, int>{};

  for (final c in climbs) {
    totalAttempts += c.attempts;
    if (c.isSent) totalSends++;

    final mKey = '${c.date.year}-${c.date.month}';
    if (monthTotal.containsKey(mKey)) {
      monthTotal[mKey] = monthTotal[mKey]! + 1;
      if (c.isSent) monthSends[mKey] = monthSends[mKey]! + 1;
    }

    gradeTotal[c.grade] = (gradeTotal[c.grade] ?? 0) + 1;
    if (c.isSent) gradeSends[c.grade] = (gradeSends[c.grade] ?? 0) + 1;

    final wId = c.wallTypeId;
    if (wId != null) {
      wallTotal[wId] = (wallTotal[wId] ?? 0) + 1;
      if (c.isSent) wallSends[wId] = (wallSends[wId] ?? 0) + 1;
    }
  }

  final monthly = monthKeys.map((k) {
    final d = monthOrder[k]!;
    return MonthlyCount(d.year, d.month, monthSends[k]!, monthTotal[k]!);
  }).toList();

  final grades =
      gradeTotal.keys
          .map((g) => RateStat(g, gradeSends[g] ?? 0, gradeTotal[g]!))
          .toList()
        ..sort((a, b) => b.total.compareTo(a.total));

  final walls =
      wallTotal.keys
          .map(
            (id) => RateStat(
              wallTypes[id]?.name ?? '(削除済み)',
              wallSends[id] ?? 0,
              wallTotal[id]!,
            ),
          )
          .toList()
        ..sort((a, b) => a.rate.compareTo(b.rate)); // 苦手（低い）を上に

  return ClimbStats(
    totalClimbs: climbs.length,
    totalSends: totalSends,
    totalAttempts: totalAttempts,
    monthly: monthly,
    grades: grades,
    walls: walls,
  );
}
