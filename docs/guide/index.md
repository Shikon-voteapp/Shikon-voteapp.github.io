---
# https://vitepress.dev/reference/default-theme-home-page
layout: home
title: 紫紺祭投票アプリ

hero:
  name: "紫紺祭投票アプリ"
  tagline: Shikon Fes Vote App Guide
  actions:
    - theme: brand
      text: Get Started！
      link: /about
    - theme: alt
      text: GitHub Repository
      link: https://github.com/Shikon-voteapp/Shikon-voteapp.github.io

features:
  - title: 単一コードベースでマルチプラットフォーム
    details: Flutter製。Web/PWA配信に加え、ElectronでWindows配布も可能。サービスワーカーでオフライン動作に対応
  - title: Firebase連携による安全なリアルタイム集計
    details: Firestore＋セキュリティルール／インデックスを備え、リアルタイム書き込み・集計を安全に実現。ホスティングとキャッシュ最適化で高速応答。
  - title: 運用しやすい設計とツール群
    details: models/services/screens/widgetsの分離構成、設定の外部化、PowerShell/Nodeスクリプトでビルド・デプロイ自動化。投票項目エディタやJSON→Excel変換ツールで運用負荷を削減。

prev: false
next:
  text: 事前準備
  link: installation
---
