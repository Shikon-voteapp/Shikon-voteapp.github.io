# 紫紺祭投票アプリ 仕様書

## 概要

紫紺祭投票アプリは、明治大学附属中野中学校・高等学校の文化祭「紫紺祭」における投票システムを提供するFlutter Webアプリケーションです。学生が各展示・催し物に対して投票を行い、リアルタイムで結果を確認できるシステムです。

## 基本情報

- **アプリ名**: 紫紺祭投票アプリ
- **バージョン**: 28.0.1+32
- **開発フレームワーク**: Flutter (Web)
- **データベース**: Firebase Firestore
- **認証**: Firebase Authentication
- **デプロイ**: GitHub Pages

## システム構成

### アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Web   │────│   Firebase      │────│   GitHub Pages  │
│   Application   │    │   Backend       │    │   Hosting       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 主要コンポーネント

1. **フロントエンド**: Flutter Webアプリケーション
2. **バックエンド**: Firebase (Firestore, Authentication)
3. **ホスティング**: GitHub Pages
4. **管理ツール**: 設定エディター（Python）

## 機能仕様

### 1. 認証・認可機能

#### 学生認証
- **QRコードスキャン**: 学生証のQRコードをスキャンして認証
- **手動入力**: 学生番号とパスワードによる認証
- **セッション管理**: 認証状態の永続化

#### 管理者認証
- **Google認証**: Googleアカウントによる管理者認証
- **権限管理**: 管理者のみが投票結果の確認・管理が可能

### 2. 投票機能

#### 投票カテゴリ
1. **教室展示団体** (Tenji)
2. **教室催し物団体** (Moyoshi)
3. **学年展示** (Gakunen)
4. **露店** (Roten)
5. **部活ステージ・公開練習** (Stage)
6. **パフォーマンス** (Performance)
7. **バンド** (Band)
8. **その他** (Other)

#### 投票プロセス
1. **カテゴリ選択**: 投票対象のカテゴリを選択
2. **団体選択**: カテゴリ内の団体から1つを選択
3. **確認画面**: 選択内容の確認
4. **投票実行**: 投票データの送信
5. **完了画面**: 投票完了の通知

#### 投票制限
- **期間制限**: 設定された投票期間内のみ投票可能
- **メンテナンス時間**: 毎日1:00-2:00はメンテナンス時間として投票停止
- **重複投票防止**: 同一学生による重複投票を防止
- **カテゴリ別投票**: 各カテゴリで1つずつ投票可能

### 3. 表示機能

#### 投票画面
- **グリッド表示**: 団体をグリッド形式で表示
- **リスト表示**: 団体をリスト形式で表示
- **フィルタリング**: 階層別フィルタリング機能
- **検索機能**: 団体名・説明文での検索

#### 結果表示
- **リアルタイム更新**: 投票結果のリアルタイム表示
- **グラフ表示**: 投票結果の視覚化
- **ランキング**: 得票数順のランキング表示

### 4. 管理機能

#### 投票設定管理
- **投票期間設定**: 投票開始・終了日時の設定
- **メンテナンス時間設定**: メンテナンス時間の設定
- **団体情報管理**: 団体の追加・編集・削除
- **カテゴリ管理**: 投票カテゴリの管理

#### データ管理
- **投票データエクスポート**: CSV/Excel形式でのデータ出力
- **バックアップ**: データのバックアップ機能
- **ログ管理**: 投票ログの確認

## データモデル

### 1. 学生 (Student)

```dart
class Student {
  final String id;           // 学生ID
  final String name;         // 氏名
  final String grade;        // 学年
  final String class_;       // クラス
  final String qrCode;       // QRコード
}
```

### 2. 団体 (Group)

```dart
class Group {
  final String id;                    // 団体ID
  final String name;                  // 展示タイトル
  final String groupName;             // 団体名
  final String description;           // 説明
  final String imagePath;             // 画像パス
  final int floor;                    // 階層
  final int? pamphletPage;            // パンフレットページ
  final List<GroupCategory> categories; // カテゴリリスト
}
```

### 3. 投票カテゴリ (VoteCategory)

```dart
class VoteCategory {
  final String id;                    // カテゴリID
  final String name;                  // カテゴリ名
  final String description;           // 説明
  final List<Group> groups;           // 対象団体リスト
  final List<GroupCategory>? eligibleCategories; // 対象カテゴリ
  final bool canSkip;                 // スキップ可能フラグ
  final String? shortHelpText;        // ヘルプテキスト
}
```

### 4. 投票 (Vote)

```dart
class Vote {
  final String uuid;                  // 投票者UUID
  final Map<String, String> selections; // カテゴリID -> 団体ID
  final DateTime timestamp;           // 投票日時
}
```

## 技術仕様

### フロントエンド

#### 使用技術
- **Flutter**: 3.7.2以上
- **Dart**: 3.7.2以上
- **flutter_neumorphic_plus**: UIデザイン
- **flutter_screenutil**: レスポンシブデザイン
- **provider**: 状態管理

#### 主要パッケージ
```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.12.1
  cloud_firestore: ^5.6.5
  firebase_data_connect: ^0.1.0
  mobile_scanner: any
  fl_chart: ^0.70.2
  flutter_neumorphic_plus: ^3.3.0
  flutter_screenutil: ^5.9.3
  provider: ^6.0.5
```

### バックエンド

#### Firebase設定
- **Firestore**: 投票データの保存
- **Authentication**: 認証管理
- **Data Connect**: データベース接続
- **Hosting**: 静的ファイルのホスティング

#### セキュリティルール
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 投票データの読み書き制限
    match /votes/{voteId} {
      allow read, write: if request.auth != null;
    }
    
    // 学生データの読み取り制限
    match /students/{studentId} {
      allow read: if request.auth != null;
    }
  }
}
```

### デプロイメント

#### ビルドプロセス
1. **バージョン管理**: PowerShellスクリプトによる自動バージョン管理
2. **Flutterビルド**: `flutter build web`によるWebアプリビルド
3. **デプロイ**: GitHub Pagesへの自動デプロイ

#### バージョン管理
- **形式**: Major.Minor.Patch.Build
- **自動更新**: ビルドスクリプトによる自動更新
- **コミット**: バージョン番号を含む自動コミット

## 画面仕様

### 1. スプラッシュ画面
- アプリ起動時の初期画面
- バージョン情報の表示
- 初期化処理の進行状況表示

### 2. 認証画面
- QRコードスキャン機能
- 手動入力フォーム
- エラーメッセージ表示

### 3. 投票画面
- カテゴリ選択
- 団体一覧表示
- フィルタリング機能
- 検索機能

### 4. 確認画面
- 選択内容の確認
- 投票実行ボタン
- 編集機能

### 5. 完了画面
- 投票完了の通知
- 結果確認へのリンク

### 6. 管理画面
- 投票結果の表示
- データエクスポート
- 設定変更

## セキュリティ仕様

### 認証・認可
- **多要素認証**: QRコード + パスワード
- **セッション管理**: 安全なセッション管理
- **権限分離**: 学生・管理者の権限分離

### データ保護
- **暗号化**: 通信データの暗号化
- **バックアップ**: 定期的なデータバックアップ
- **ログ管理**: 操作ログの記録

### 投票の整合性
- **重複防止**: 同一学生の重複投票防止
- **期間制限**: 投票期間外の投票防止
- **データ検証**: 投票データの整合性チェック

## パフォーマンス仕様

### レスポンス時間
- **画面遷移**: 1秒以内
- **データ読み込み**: 3秒以内
- **投票実行**: 5秒以内

### 同時接続数
- **最大同時接続**: 1000ユーザー
- **投票処理**: 100投票/分

### データ容量
- **画像ファイル**: 最大2MB
- **投票データ**: 無制限（Firestore制限内）

## 運用仕様

### メンテナンス
- **定期メンテナンス**: 毎日1:00-2:00
- **緊急メンテナンス**: 必要に応じて実施
- **バックアップ**: 毎日自動バックアップ

### 監視
- **エラーログ**: 自動エラーログ収集
- **パフォーマンス監視**: レスポンス時間監視
- **使用状況監視**: アクセス数・投票数監視

### サポート
- **ヘルプ機能**: アプリ内ヘルプ
- **FAQ**: よくある質問
- **問い合わせ**: 管理者への問い合わせ機能

## 今後の拡張予定

### 機能拡張
- **リアルタイム通知**: 投票結果のプッシュ通知
- **SNS連携**: Twitter/Facebook連携
- **多言語対応**: 英語・中国語対応

### 技術改善
- **PWA対応**: プログレッシブWebアプリ化
- **オフライン対応**: オフライン投票機能
- **AI分析**: 投票パターンの分析

## 関連ドキュメント

- [インストールガイド](installation.md)
- [API仕様書](api-examples.md)
- [運用マニュアル](getting-started.md)
- [トラブルシューティング](markdown-examples.md)

---

**最終更新日**: 2025年1月27日  
**バージョン**: 28.0.1+32  
**作成者**: 紫紺祭投票アプリ開発チーム
