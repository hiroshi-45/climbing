import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// 登攀記録をCSVへ書き出し、一時ファイルとして返す。
///
/// Excelで開いても文字化けしないよう UTF-8 BOM を付与する。
Future<File> buildClimbsCsv(
  List<Climb> climbs,
  Map<int, Gym> gyms,
  Map<int, WallType> walls,
) async {
  final dateFmt = DateFormat('yyyy-MM-dd');
  final buf = StringBuffer()..writeln('日付,ジム,グレード,壁,トライ数,完登,メモ');

  for (final c in climbs) {
    final cells = [
      dateFmt.format(c.date),
      gyms[c.gymId]?.name ?? '',
      c.grade,
      c.wallTypeId != null ? (walls[c.wallTypeId]?.name ?? '') : '',
      '${c.attempts}',
      c.isSent ? '完登' : '未完登',
      c.memo ?? '',
    ];
    buf.writeln(cells.map(_csvCell).join(','));
  }

  final dir = await getTemporaryDirectory();
  final file = File(
    p.join(dir.path, 'climb_log_${DateTime.now().millisecondsSinceEpoch}.csv'),
  );
  await file.writeAsString('﻿$buf');
  return file;
}

/// カンマ・引用符・改行を含むセルをCSV仕様でエスケープする。
String _csvCell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
