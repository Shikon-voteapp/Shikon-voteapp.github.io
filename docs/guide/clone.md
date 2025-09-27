---
prev: 
    text: 環境構築
    link: installation
next:
  text: 各年度向けのカスタマイズ
  link: change-config
---
# ソースコードのクローン
本項では、設定をカスタマイズするために必要なソースコードのクローンを行います。
::: warning 注意
これから行う操作は、OneDriveの管理下にあるディレクトリ(デスクトップやドキュメント等)では絶対に行わないでください。
:::
1. スタート右クリックから、``ターミナル(管理者)``を選択します。
2. ターミナルウィンドウが表示されるので、以下のコードを入力し、Enterを押して実行します。
```bash
git clone "https://github.com/Shikon-voteapp/Shikon-voteapp.github.io.git"
```
3. ``Updating files: 100% (9317/9317), done.``(細かい数値は変わる可能性があります)と表示されるまで待ちます。
4. ``done.``が表示されたら、次に以下のコードを順番に入力し、Enterを押して実行します。(一行ずつ行ってください。)
```bash
npm install -g firebase-tools
firebase login
```
5. Webブラウザが起動し、Googleアカウントでのログインを求められるため、以下のメールアドレス・パスワードでログイン。二段階認証のコードは、引継ぎ資料を参照のこと。それ以降は、画面の指示に従って進めてください。
メールアドレス：``Meiji.hs.vote@gmail.com``
パスワード：``Me!$!_sohmu``
6. Googleアカウントの設定が終わったら、次に以下のコードを順番に入力し、Enterを押して実行します。(一行ずつ行ってください。)
```bash
cd shikon-voteapp.github.io
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
```
7. 最後のコマンドの実行中に、以下のような質問がされます。それぞれの質問に、キーボードの``y``または``n``で回答を入力する必要があるので、以下の通りに実行してください。

``? You have an existing `firebase.json` file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing `firebase.json` file to configure your project? `` が表示されたら、``y``を入力。

以上で、ソースコードのクローンは完了です。
