# リリース準備チェックリスト（Climb Log）

## アプリ設定
- [x] アプリ名: Climb Log（`CFBundleDisplayName` / Android `label`）
- [x] アプリアイコン生成（`assets/icon/icon.png` → `dart run flutter_launcher_icons`）
- [x] カメラ / 写真ライブラリの利用目的（iOS `Info.plist`）
- [ ] バージョン更新（`pubspec.yaml` の `version: 1.0.0+1`）
- [ ] Android `applicationId` / iOS Bundle ID の最終確認（`com.maruno.climb_log` / `com.maruno.climbLog`）

## 課金
- [ ] RevenueCat とストアの課金設定（`docs/revenuecat_setup.md` 参照）
- [ ] APIキーを `--dart-define` で注入してリリースビルド

## ストア掲載物
- [ ] ストア説明文（`docs/store_listing.md`）
- [ ] スクリーンショット（`docs/screenshots/` を元に各サイズへ書き出し・フレーム付け）
- [ ] プライバシーポリシーを公開しURLを登録（`docs/privacy_policy.md`）
- [ ] データセーフティ / App Privacy の申告（端末内保存・課金のみ）

## 署名・ビルド
### Android
- [ ] アップロード鍵（keystore）作成
- [ ] `android/key.properties` と `build.gradle` の署名設定
- [ ] `flutter build appbundle --release --dart-define=...`

### iOS
- [ ] Apple Developer Program 加入
- [ ] 証明書 / プロビジョニングプロファイル
- [ ] `flutter build ipa --release --dart-define=...`

## 動作確認
- [x] `flutter analyze` クリーン
- [x] `flutter test` パス
- [ ] 実機での通し確認（記録→統計→課金→エクスポート）

## ビルドコマンド早見表
```bash
# Android リリース
flutter build appbundle --release \
  --dart-define=RC_IOS_KEY=appl_xxx --dart-define=RC_ANDROID_KEY=goog_xxx

# iOS リリース
flutter build ipa --release \
  --dart-define=RC_IOS_KEY=appl_xxx --dart-define=RC_ANDROID_KEY=goog_xxx
```
