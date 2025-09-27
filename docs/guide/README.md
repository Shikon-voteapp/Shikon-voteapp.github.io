# 紫紺祭投票アプリガイド

このディレクトリには、紫紺祭投票アプリの使用方法ガイドがVitePressで構築されています。

## 開発環境での実行

```bash
# 依存関係のインストール
npm install

# 開発サーバーの起動
npm run docs:dev

# 本番用ビルド
npm run docs:build

# ビルド結果のプレビュー
npm run docs:preview
```

## デプロイ

このガイドはGitHub Pagesで自動デプロイされます。

- リポジトリの設定で「Pages」セクションから「GitHub Actions」を選択
- `main`ブランチにプッシュすると自動的にデプロイされます
- デプロイ先: `https://shikon-voteapp.github.io/guide/`

## ファイル構成

- `.vitepress/config.ts` - VitePressの設定ファイル
- `.github/workflows/deploy.yml` - GitHub Actionsのデプロイワークフロー
- `package.json` - プロジェクトの依存関係とスクリプト
- `*.md` - 各ページのMarkdownファイル

## 注意事項

- `base: '/guide/'`が設定されているため、GitHub Pagesでは`/guide/`パスでアクセスされます
- 画像ファイルは`img/`ディレクトリに配置してください
- 新しいページを追加する場合は、`config.ts`のsidebarに追加してください
