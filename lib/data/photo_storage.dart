import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 撮影/選択した画像をアプリ専用ディレクトリへコピーし、保存先パスを返す。
Future<String> savePhoto(String sourcePath) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final photosDir = Directory(p.join(docsDir.path, 'photos'));
  if (!await photosDir.exists()) {
    await photosDir.create(recursive: true);
  }
  final ext = p.extension(sourcePath);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
  final dest = p.join(photosDir.path, fileName);
  await File(sourcePath).copy(dest);
  return dest;
}

/// 不要になった写真ファイルを削除（存在しなくてもエラーにしない）。
Future<void> deletePhoto(String? path) async {
  if (path == null) return;
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}
