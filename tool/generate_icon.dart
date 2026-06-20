import 'dart:io';

import 'package:image/image.dart' as img;

/// アプリアイコン（1024x1024）をプログラムで生成する。
///
/// 実行: `dart run tool/generate_icon.dart`
/// → assets/icon/icon.png を出力し、flutter_launcher_icons で各OSへ展開する。
void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // 背景（ブランドグリーン #2E7D32）
  img.fill(image, color: img.ColorRgb8(0x2E, 0x7D, 0x32));

  // 太陽（淡い黄色の円）
  _fillCircle(image, cx: 730, cy: 320, r: 110,
      color: img.ColorRgb8(0xFF, 0xF1, 0x76));

  // 2つの山（白）— ボルダリング/クライミングを象徴
  _fillTriangle(image, apexX: 380, apexY: 300, baseY: 760, halfWidth: 300,
      color: img.ColorRgb8(0xFF, 0xFF, 0xFF));
  _fillTriangle(image, apexX: 660, apexY: 420, baseY: 760, halfWidth: 260,
      color: img.ColorRgb8(0xE8, 0xF5, 0xE9));

  final dir = Directory('assets/icon')..createSync(recursive: true);
  final out = File('${dir.path}/icon.png');
  out.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote ${out.path}');
}

void _fillTriangle(
  img.Image image, {
  required int apexX,
  required int apexY,
  required int baseY,
  required int halfWidth,
  required img.Color color,
}) {
  final height = baseY - apexY;
  for (var y = apexY; y <= baseY; y++) {
    final t = (y - apexY) / height;
    final spread = (t * halfWidth).round();
    for (var x = apexX - spread; x <= apexX + spread; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        image.setPixelRgb(x, y, color.r, color.g, color.b);
      }
    }
  }
}

void _fillCircle(
  img.Image image, {
  required int cx,
  required int cy,
  required int r,
  required img.Color color,
}) {
  for (var y = cy - r; y <= cy + r; y++) {
    for (var x = cx - r; x <= cx + r; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= r * r &&
          x >= 0 &&
          x < image.width &&
          y >= 0 &&
          y < image.height) {
        image.setPixelRgb(x, y, color.r, color.g, color.b);
      }
    }
  }
}
