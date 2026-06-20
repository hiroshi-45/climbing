import 'package:flutter/material.dart';

/// アプリ全体のビジュアル基盤。
///
/// コンセプトは「夕暮れのクライミング」。オレンジ→ピンク→紫のサンセット
/// グラデーションを主役にしたダークファーストのテーマで、開くたびに気分が
/// 上がる“映える”体験を狙う。色やグラデーションはここに集約し、各画面から
/// `AppPalette` / `AppGradients` 経由で参照する。
class AppPalette {
  AppPalette._();

  // サンセット三色（グラデーションの基点）
  static const sunsetStart = Color(0xFFFF9A3D); // 夕日のオレンジ
  static const sunsetMid = Color(0xFFFF5C7C); // マゼンタピンク
  static const sunsetEnd = Color(0xFF9B5DE5); // トワイライトパープル

  // 背景・サーフェス（深い紫みのある黒）
  static const background = Color(0xFF14111C);
  static const surface = Color(0xFF1F1B2B);
  static const surfaceHigh = Color(0xFF2A2438);
  static const stroke = Color(0xFF393247);

  // 状態色
  static const sent = Color(0xFF34E5A1); // 完登（ミントグリーン）
  static const projecting = Color(0xFFB9B2C9); // 挑戦中（くすんだ白）
  static const gold = Color(0xFFFFC857); // プレミアム

  // テキスト
  static const textHigh = Color(0xFFF4F1FA);
  static const textMid = Color(0xFFB9B2C9);
  static const textLow = Color(0xFF7C7490);
}

/// 使い回すグラデーション群。
class AppGradients {
  AppGradients._();

  /// 主役のサンセット（左上→右下）。
  static const sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppPalette.sunsetStart,
      AppPalette.sunsetMid,
      AppPalette.sunsetEnd,
    ],
  );

  /// ヒーローヘッダー用（縦方向に深く沈むサンセット）。
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8A3D),
      Color(0xFFFF5C7C),
      Color(0xFF7C4DD6),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// 完登セル用のミントグラデーション。
  static const sent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34E5A1), Color(0xFF1FB6C9)],
  );

  /// 背景に薄く敷くアンビエント光。
  static const ambient = RadialGradient(
    center: Alignment(-0.7, -1.1),
    radius: 1.4,
    colors: [Color(0x33FF5C7C), Color(0x000F0C16)],
  );
}

/// アプリのテーマ定義。
ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.sunsetMid,
    onPrimary: Colors.white,
    secondary: AppPalette.sunsetEnd,
    onSecondary: Colors.white,
    tertiary: AppPalette.sent,
    onTertiary: Color(0xFF06241B),
    error: Color(0xFFFF6B6B),
    onError: Colors.white,
    surface: AppPalette.surface,
    onSurface: AppPalette.textHigh,
    surfaceContainerHighest: AppPalette.surfaceHigh,
    onSurfaceVariant: AppPalette.textMid,
    outline: AppPalette.stroke,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppPalette.textHigh,
      displayColor: AppPalette.textHigh,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppPalette.textHigh,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: AppPalette.textHigh),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.stroke,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1626),
      indicatorColor: AppPalette.sunsetMid.withValues(alpha: 0.22),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppPalette.textHigh : AppPalette.textLow,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppPalette.sunsetMid : AppPalette.textLow,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.sunsetMid, width: 2),
      ),
      labelStyle: const TextStyle(color: AppPalette.textMid),
      hintStyle: const TextStyle(color: AppPalette.textLow),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.sunsetMid,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.surfaceHigh,
      contentTextStyle: const TextStyle(color: AppPalette.textHigh),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppPalette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    listTileTheme: const ListTileThemeData(iconColor: AppPalette.textMid),
  );
}
