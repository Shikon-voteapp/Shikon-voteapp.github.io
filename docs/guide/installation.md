---
prev: 
    text: 紫紺祭投票アプリとは？
    link: about
next:
  text: 環境構築
  link: installation
---
# 環境構築

## 必要なものを用意する
紫紺祭投票アプリの設定を行うには、以下の要件を満たしたデバイス等が必要です。
- 64ビットバージョンの Windows 10 または Windows 11 を搭載したパソコン
<!-- Container with Custom Title -->
::: tip ヒント
高校Ⅰ年次に購入する学習用ノートPCで正常に動作することを確認しています。
5GB 以上の空き容量が必要です。
:::
- Google 認証システムがインストールされたスマートフォン
- Google 認証システム用の QR コードが記された紙
<!-- Container with Custom Title -->
::: warning 注意
引継ぎ時に渡されていない場合は、担当教員の先生に相談するか、[このメールアドレス](mailto:mamouna.inori@outlook.jp)まで連絡をしてください。
:::
## 必要な知識
### Windows の基本・応用操作
このチュートリアルでは、Windows 11 を使用します。設定やエクスプローラーの開き方、エクスプローラー画面各部の名称をご存じない場合は、まず検索エンジンを使って最低限の操作方法を勉強されることをおすすめします。

## はじめに
文化祭準備委員会　総務部門ないしはそれに類する部門の部門長・副部門長を引き受けてくださり、ありがとうございます。 2025 年度文化祭準備委員会　総務部門長の小川です。
紫紺祭では 2025 年度より、教室展示等の各賞を決定する際に生徒・来校者双方へ行われる投票を円滑に運営するため、電子システムによる集計を開発・導入しました。このチュートリアルでは、本システムを各年度用に日程や投票先をカスタムする際に必要となる進め方・知識を解説しています。ぜひ、最後まで目を通していただき、円滑な投票運営へお役立てください。
また、本チュートリアルを読んだうえで質問等がある場合には、[このメールアドレス](mailto:mamouna.inori@outlook.jp)まで連絡をしてください。
<!-- Container with Custom Title -->
::: warning 注意
紫紺祭関連であることがわからない場合、迷惑メールとして読み捨てる場合がありますのでご注意ください。
:::

## 開発者モードの有効化
1. Windows の設定を開き、左側のメニューから``システム``を選択します。
2. その中から、``開発者向け``を選択します。
3. ``開発者モード``を有効にします。
4. 下にスクロールし、 ``PowerShell`` の項目をクリックして展開、``署名せずに実行するローカル PowerShell スクリプトを許可するように、実行ポリシーを変更します。リモートスクリプトには署名が必要です。``を有効にします。

![開発者モード](/img/DevMode.png "Dev Mode Setting")

## Git のインストール・設定
### Git のインストール
1. [Git のダウンロードページ](https://git-scm.com/downloads)にアクセスし、右側にある`` Download for Windows ``をクリックします。
2. 次のページに飛ぶので、本文の一番上にある`` Click here to download ``をクリックします。
3. ``Git-(バージョン名)-64-bit.exe`` がダウンロードされるので、それをダブルクリックして起動します。
![GitInstaller](/img/GitInstaller.png "Git Installer")
4. このような画面が表示されたら、画面右下の ``Next`` を連打して、インストールを完了させてください。特に途中で設定を変更する必要はありません。
### Git の初期設定
1. タスクバーのWindowsロゴ(4つの窓が並んだアイコン)を右クリックし、``ターミナル(管理者)``をクリックします。
2. ターミナルのウィンドウが表示されるので、以下の2行を入力・コピペし、<kbd>Enter</kbd>を押して実行します。
``` bash
git config --global user.email Meiji.hs.vote@gmail.com
git config --global user.name ShikonFes_Sohmu
```
以上で、Git の初期設定は完了です。(Gitからの出力はありません。)
## Flutter SDKのインストール
1. [Flutter SDKのダウンロードページ](https://docs.flutter.dev/get-started/install/windows/web)にアクセスし、 **Install the Flutter SDK** の見出しの項にある「 Download and install 」を押します。
![FlutterWebPage](/img/FlutterWebPage.png "Flutter Web Page")
2. その下にある青いボタン「flutter_windows_(バージョン名)-stable.zip」を押し、 Zip ファイルをダウンロードします。
3. ダウンロードした Zip ファイルを開き、中にある「``flutter``」フォルダを``C:\``以下にコピーします。
::: tip ヒント
エクスプローラー上部の「ダウンロード > flutter_windows_3.35.4-stable」が書かれているところに、``C:\``と入力すると、``C:\``に飛ぶことができるので、そこに展開した``Flutter``フォルダを貼り付けるとよいです。
:::
