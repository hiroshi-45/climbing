import 'package:flutter_test/flutter_test.dart';

import 'package:climb_log/data/app_database.dart';
import 'package:climb_log/stats/climb_stats.dart';

Climb _climb({
  required DateTime date,
  required String grade,
  int? wallTypeId,
  int attempts = 1,
  bool isSent = false,
}) {
  return Climb(
    id: 0,
    syncId:
        'test-$grade-${date.microsecondsSinceEpoch}-$isSent-$attempts-$wallTypeId',
    updatedAt: date,
    isDeleted: false,
    dirty: true,
    gymId: 1,
    date: date,
    grade: grade,
    wallTypeId: wallTypeId,
    attempts: attempts,
    isSent: isSent,
    photoPath: null,
    memo: null,
    createdAt: date,
  );
}

void main() {
  test('空リストは空統計を返す', () {
    expect(computeStats(const [], const {}).totalClimbs, 0);
    expect(computeStats(const [], const {}).overallSendPercent, 0);
  });

  test('完登数・完登率・総トライを集計する', () {
    final now = DateTime(2026, 6, 20);
    final climbs = [
      _climb(date: now, grade: '二級', attempts: 3, isSent: true),
      _climb(date: now, grade: '二級', attempts: 2, isSent: false),
      _climb(date: now, grade: '初段', attempts: 5, isSent: true),
      _climb(date: now, grade: '初段', attempts: 1, isSent: false),
    ];
    final s = computeStats(climbs, const {}, now: now);

    expect(s.totalClimbs, 4);
    expect(s.totalSends, 2);
    expect(s.totalAttempts, 11);
    expect(s.overallSendPercent, 50);
  });

  test('グレード別の完登率を記録数の多い順で返す', () {
    final now = DateTime(2026, 6, 20);
    final climbs = [
      _climb(date: now, grade: '三級', isSent: true),
      _climb(date: now, grade: '三級', isSent: true),
      _climb(date: now, grade: '三級', isSent: false),
      _climb(date: now, grade: '初段', isSent: false),
    ];
    final s = computeStats(climbs, const {}, now: now);

    expect(s.grades.first.label, '三級'); // 記録数が多い
    expect(s.grades.first.ratePercent, 67); // 2/3
    expect(s.grades[1].label, '初段');
    expect(s.grades[1].ratePercent, 0);
  });

  test('壁別は完登率の低い（苦手な）順に並ぶ', () {
    final now = DateTime(2026, 6, 20);
    final walls = {1: _wall(1, 'スラブ'), 2: _wall(2, '強傾斜')};
    final climbs = [
      _climb(date: now, grade: 'x', wallTypeId: 1, isSent: true),
      _climb(date: now, grade: 'x', wallTypeId: 1, isSent: true), // スラブ100%
      _climb(date: now, grade: 'x', wallTypeId: 2, isSent: false), // 強傾斜0%
      _climb(date: now, grade: 'x', wallTypeId: 2, isSent: false),
    ];
    final s = computeStats(climbs, walls, now: now);

    expect(s.walls.first.label, '強傾斜'); // 苦手が先頭
    expect(s.walls.first.ratePercent, 0);
    expect(s.walls.last.label, 'スラブ');
    expect(s.walls.last.ratePercent, 100);
  });

  test('月別は直近6ヶ月の枠を持ち、記録ゼロ月も0で埋まる', () {
    final now = DateTime(2026, 6, 20);
    final climbs = [
      _climb(date: DateTime(2026, 6, 1), grade: 'x', isSent: true),
      _climb(date: DateTime(2026, 4, 1), grade: 'x', isSent: true),
    ];
    final s = computeStats(climbs, const {}, now: now);

    expect(s.monthly, hasLength(6));
    expect(s.monthly.last.month, 6);
    expect(s.monthly.last.sends, 1);
    final may = s.monthly.firstWhere((m) => m.month == 5);
    expect(may.sends, 0);
  });
}

WallType _wall(int id, String name) => WallType(
      id: id,
      syncId: 'test-wall-$id',
      updatedAt: DateTime(2026),
      isDeleted: false,
      dirty: false,
      name: name,
    );
