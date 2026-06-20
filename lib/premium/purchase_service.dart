import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat（課金）まわりの薄いラッパ。
///
/// APIキーは秘匿情報なのでソースに直書きせず、ビルド時に
/// `--dart-define=RC_IOS_KEY=... --dart-define=RC_ANDROID_KEY=...`
/// で注入する。キー未設定ならアプリは課金無効（全機能ロック）状態で動作する。
class PurchaseService {
  PurchaseService._();

  /// RevenueCat の「Entitlement」識別子。ダッシュボード側と一致させる。
  static const entitlementId = 'premium';

  static const _iosKey = String.fromEnvironment('RC_IOS_KEY');
  static const _androidKey = String.fromEnvironment('RC_ANDROID_KEY');

  static String get _platformKey =>
      Platform.isIOS ? _iosKey : (Platform.isAndroid ? _androidKey : '');

  /// 有効なAPIキーが設定済みか。
  static bool get isConfigured => _platformKey.isNotEmpty;

  /// アプリ起動時に一度だけ呼ぶ。キー未設定なら何もしない。
  static Future<void> configure() async {
    if (!isConfigured) return;
    await Purchases.setLogLevel(LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(_platformKey));
  }

  /// 現在プレミアム権利を持っているか問い合わせる。
  static Future<bool> hasPremium() async {
    if (!isConfigured) return false;
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(entitlementId);
  }

  /// 販売中のプラン（パッケージ）一覧。未設定/未取得なら空。
  static Future<List<Package>> fetchPackages() async {
    if (!isConfigured) return const [];
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? const [];
  }

  /// 指定パッケージを購入し、購入後のプレミアム権利状態を返す。
  static Future<bool> purchase(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo.entitlements.active.containsKey(entitlementId);
  }

  /// 機種変更などで購入を復元する。
  static Future<bool> restore() async {
    if (!isConfigured) return false;
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(entitlementId);
  }
}
