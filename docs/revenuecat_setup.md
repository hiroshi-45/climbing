# RevenueCat / アプリ内課金 セットアップ手順

プレミアム（統計・写真無制限・CSVエクスポート）の課金を有効化する手順。
コード側は実装済みで、**あなたのストア／RevenueCatアカウントでの設定とAPIキーの注入**だけが残っています。

## 全体像

```
App Store Connect / Google Play で課金プロダクトを作成
        ↓
RevenueCat ダッシュボードでアプリ登録・Entitlement / Offering を設定
        ↓
APIキーを取得し、ビルド時に --dart-define で注入
```

コード側の前提（変更不要）:
- Entitlement 識別子: `premium`（`lib/premium/purchase_service.dart` の `entitlementId`）
- APIキーは `RC_IOS_KEY` / `RC_ANDROID_KEY` という dart-define 名で読み込む

## 1. ストアで課金プロダクトを作成

### App Store Connect（iOS）
1. Apple Developer Program（年 $99）に加入
2. App Store Connect でアプリを作成（Bundle ID: `com.maruno.climbLog`）
3. 「App内課金」または「サブスクリプション」を作成
   - 例（サブスク）: Product ID `climb_premium_monthly`、月額 ¥300〜500
   - 例（買い切り）: 非消耗型 `climb_premium_lifetime`
4. 税務・銀行情報（有料App契約）を完了させる

### Google Play Console（Android）
1. Google Play デベロッパー登録（初回 $25）
2. アプリを作成（applicationId: `com.maruno.climb_log`）
3. 「定期購入」または「アプリ内アイテム」を作成（同様のProduct ID）

## 2. RevenueCat の設定
1. https://app.revenuecat.com でプロジェクト作成
2. iOS / Android アプリをそれぞれ登録（App Store Connect の共有シークレット、Google のサービスアカウントJSONを設定）
3. **Entitlement** を作成し、識別子を `premium` にする
4. 上で作ったストアの **Product** を RevenueCat に登録し、`premium` entitlement に紐付け
5. **Offering**（`default`）を作成し、Package にプロダクトを追加
6. **API Keys** から各プラットフォームの公開SDKキーを取得
   - iOS: `appl_xxxxxxxx`
   - Android: `goog_xxxxxxxx`

## 3. アプリにキーを注入して実行 / ビルド

### 開発実行
```bash
flutter run \
  --dart-define=RC_IOS_KEY=appl_xxxxxxxx \
  --dart-define=RC_ANDROID_KEY=goog_xxxxxxxx
```

### リリースビルド
```bash
# Android（App Bundle）
flutter build appbundle --release \
  --dart-define=RC_IOS_KEY=appl_xxxxxxxx \
  --dart-define=RC_ANDROID_KEY=goog_xxxxxxxx

# iOS
flutter build ipa --release \
  --dart-define=RC_IOS_KEY=appl_xxxxxxxx \
  --dart-define=RC_ANDROID_KEY=goog_xxxxxxxx
```

> キーをファイルで管理したい場合は `--dart-define-from-file=env.json` も使えます（env.json は .gitignore 済み）。

## 4. 動作確認
- キー注入後にアプリを起動 → 統計タブ →「プレミアムを見る」でペイウォールにプランが表示される
- iOS は Sandbox テスター、Android はライセンステスターで購入テスト
- 購入後、統計・写真無制限・CSVエクスポートが解放されることを確認

## 補足: キー未設定時の挙動
- APIキーが無い場合、アプリはクラッシュせず**全プレミアム機能がロックされた状態**で動作します。
- デバッグビルドのペイウォールには「（開発用）プレミアムをプレビュー」ボタンが出て、課金なしで画面確認ができます（リリースビルドでは非表示）。
