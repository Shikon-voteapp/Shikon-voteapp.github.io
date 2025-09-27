const admin = require('firebase-admin');
const fs = require('fs');

// Firebase Admin SDKの初期化
// サービスアカウントキーファイルが必要です
const serviceAccount = require('./serviceAccountKey.json'); // このファイルを用意してください

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://shikonfes-voteapp-default-rtdb.firebaseio.com'
});

const db = admin.database();

async function uploadTestData() {
  try {
    // test.jsonファイルを読み込み
    const testData = JSON.parse(fs.readFileSync('./lib/config/test.json', 'utf8'));
    
    console.log(`読み込んだデータ数: ${Object.keys(testData).length}件`);
    
    // データベースルールを一時的に変更する必要があるかもしれません
    // 現在のルールでは認証が必要で、既存データの上書きは禁止されています
    
    const votesRef = db.ref('votes');
    
    // 各投票データを追加
    for (const [uuid, voteData] of Object.entries(testData)) {
      try {
        // 既存データをチェック
        const existingData = await votesRef.child(uuid).once('value');
        
        if (existingData.exists()) {
          console.log(`UUID ${uuid} は既に存在します。スキップします。`);
          continue;
        }
        
        // データを追加
        await votesRef.child(uuid).set(voteData);
        console.log(`UUID ${uuid} を追加しました。`);
        
        // レート制限を避けるため少し待機
        await new Promise(resolve => setTimeout(resolve, 100));
        
      } catch (error) {
        console.error(`UUID ${uuid} の追加中にエラーが発生しました:`, error.message);
      }
    }
    
    console.log('データのアップロードが完了しました。');
    
  } catch (error) {
    console.error('エラーが発生しました:', error);
  } finally {
    // アプリケーションを終了
    process.exit(0);
  }
}

// スクリプトを実行
uploadTestData();




