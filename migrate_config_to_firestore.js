/**
 * migrate_config_to_firestore.js
 * 
 * 既存の vote_options.dart の設定データと assets/ 内の画像を
 * Firestore / Cloud Storage に移行・アップロードするための管理者用スクリプト。
 * 
 * 使い方:
 *   1. serviceAccountKey.json をプロジェクトルートに配置
 *   2. npm install firebase-admin
 *   3. node migrate_config_to_firestore.js [--overwrite]
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// サービスアカウントの確認
const serviceAccountPath = './serviceAccountKey.json';
if (!fs.existsSync(serviceAccountPath)) {
  console.error('エラー: serviceAccountKey.json が見つかりません。');
  console.error('Firebase Console -> プロジェクトの設定 -> サービスアカウント から秘密鍵を生成し、ルートに配置してください。');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'shikonfes-voteapp.firebasestorage.app'
});

const firestore = admin.firestore();
const bucket = admin.storage().bucket();

const overwrite = process.argv.includes('--overwrite');

async function migrate() {
  console.log('=== 設定データ & 画像の移行スクリプト ===');
  console.log(`モード: ${overwrite ? '上書きモード (--overwrite)' : '新規のみ追加モード (スキップ優先)'}`);

  // 1. 投票期間設定の投入
  console.log('\n[1/3] 投票期間設定 (app_config/voting_period) の確認...');
  const periodRef = firestore.collection('app_config').doc('voting_period');
  const periodSnap = await periodRef.get();
  if (!periodSnap.exists || overwrite) {
    const defaultPeriod = {
      startDate: admin.firestore.Timestamp.fromDate(new Date('2025-08-30T09:00:00+09:00')),
      endDate: admin.firestore.Timestamp.fromDate(new Date('2025-08-31T15:00:00+09:00')),
      maintenanceEnabled: true,
      maintenanceStartHour: 1,
      maintenanceStartMinute: 0,
      maintenanceEndHour: 2,
      maintenanceEndMinute: 0,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    await periodRef.set(defaultPeriod);
    console.log('✓ 投票期間設定を保存しました。');
  } else {
    console.log('ℹ 投票期間設定は既に存在するためスキップしました。');
  }

  // 2. 団体データ & 画像アップロード
  console.log('\n[2/3] 団体データ & 画像の移行...');
  // ※ vote_options.dart から抽出した定義リスト
  const groupsToMigrate = [
    {
      id: '001',
      name: '吹奏楽部記念演奏',
      groupName: '吹奏楽部',
      description: '大講堂での吹奏楽部による記念演奏会です。迫力あるサウンドをお楽しみください。',
      imagePath: 'assets/wind_orchestra.jpg',
      floor: 1,
      categories: ['Stage']
    },
    {
      id: '002',
      name: '軽音楽部ライブ',
      groupName: '軽音楽部',
      description: '体育館ステージにて熱いライブパフォーマンスをお届けします！',
      imagePath: 'assets/light_music.jpg',
      floor: 1,
      categories: ['Stage', 'Band']
    },
    {
      id: '201',
      name: '古典文学の世界',
      groupName: '文芸部',
      description: '古典文学を現代風にアレンジした参加型展示です。',
      imagePath: 'assets/literature.jpg',
      floor: 2,
      categories: ['Tenji']
    },
    {
      id: '202',
      name: '未来の都市模型展',
      groupName: '建築研究同好会',
      description: '段ボールやアクリルを使った巨大未来都市ジオラマ。',
      imagePath: 'assets/architecture.jpg',
      floor: 2,
      categories: ['Tenji']
    },
    {
      id: '301',
      name: 'お化け屋敷「旧校舎の怪」',
      groupName: '2年C組',
      description: '恐怖の仕掛けがいっぱいの本格的お化け屋敷。あなたは無事に生還できるか！？',
      imagePath: 'assets/haunted_house.jpg',
      floor: 3,
      categories: ['Moyoshi']
    },
    {
      id: '302',
      name: '縁日ゲームスタジアム',
      groupName: '1年B組',
      description: '射的や輪投げ、スーパーボールすくいなど楽しい縁日アトラクション！',
      imagePath: 'assets/festival_games.jpg',
      floor: 3,
      categories: ['Moyoshi']
    },
    {
      id: '401',
      name: '高校生活メモリアル展',
      groupName: '3学年学年団',
      description: '高校生活3年間の軌跡と卒業に向けた展示企画。',
      imagePath: 'assets/memorial.jpg',
      floor: 4,
      categories: ['Gakunen']
    }
  ];

  let uploadedImages = 0;
  let groupsSaved = 0;

  for (let i = 0; i < groupsToMigrate.length; i++) {
    const group = groupsToMigrate[i];
    const groupRef = firestore.collection('groups').doc(group.id);
    const docSnap = await groupRef.get();

    let storageImagePath = group.imagePath;

    // ローカル画像が存在すれば Cloud Storage にアップロード
    if (fs.existsSync(group.imagePath)) {
      try {
        const ext = path.extname(group.imagePath) || '.jpg';
        const destination = `groups/${group.id}/image${ext}`;
        await bucket.upload(group.imagePath, {
          destination: destination,
          metadata: {
            contentType: ext === '.png' ? 'image/png' : 'image/jpeg'
          }
        });
        storageImagePath = destination;
        uploadedImages++;
        console.log(`  [画像UP] ${group.imagePath} -> ${destination}`);
      } catch (err) {
        console.warn(`  [警告] 画像 ${group.imagePath} のアップロード失敗:`, err.message);
      }
    }

    if (!docSnap.exists || overwrite) {
      await groupRef.set({
        name: group.name,
        groupName: group.groupName,
        description: group.description,
        imagePath: storageImagePath,
        floor: group.floor,
        categories: group.categories,
        order: i,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      groupsSaved++;
      console.log(`  [団体保存] ${group.name} (ID: ${group.id})`);
    } else {
      console.log(`  [団体スキップ] ID: ${group.id} は既に存在します`);
    }
  }

  // 3. 賞設定の移行
  console.log('\n[3/3] 賞設定の移行...');
  const categoriesToMigrate = [
    {
      id: 'grand_prize',
      name: '志魂大賞',
      description: '今年度の文化祭で最も優秀・印象に残った企画に投票してください。',
      shortHelpText: '全団体が対象です。',
      canSkip: false,
      groupIds: ['001', '002', '201', '202', '301', '302', '401']
    },
    {
      id: 'stage_prize',
      name: 'ステージ部門賞',
      description: 'ステージ発表・演奏・パフォーマンスで最も感動した企画を選んでください。',
      shortHelpText: '部活・バンド等のステージ企画が対象です。',
      canSkip: true,
      groupIds: ['001', '002']
    },
    {
      id: 'exhibition_prize',
      name: '展示・催し物部門賞',
      description: '教室展示や体験型アトラクションで最も楽しかった企画を選んでください。',
      shortHelpText: '教室企画・催し物が対象です。',
      canSkip: false,
      groupIds: ['201', '202', '301', '302', '401']
    }
  ];

  let categoriesSaved = 0;
  for (let i = 0; i < categoriesToMigrate.length; i++) {
    const cat = categoriesToMigrate[i];
    const catRef = firestore.collection('vote_categories').doc(cat.id);
    const catSnap = await catRef.get();

    if (!catSnap.exists || overwrite) {
      await catRef.set({
        name: cat.name,
        description: cat.description,
        shortHelpText: cat.shortHelpText || '',
        helpUrl: '',
        canSkip: cat.canSkip,
        groupIds: cat.groupIds,
        order: i,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      categoriesSaved++;
      console.log(`  [賞保存] ${cat.name} (ID: ${cat.id})`);
    } else {
      console.log(`  [賞スキップ] ID: ${cat.id} は既に存在します`);
    }
  }

  console.log('\n=== 移行完了 ===');
  console.log(`- 団体保存数: ${groupsSaved} 件`);
  console.log(`- 画像アップロード数: ${uploadedImages} 件`);
  console.log(`- 賞保存数: ${categoriesSaved} 件`);
  console.log('すべての移行処理が正常に終了しました。');
}

migrate()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('致命的エラー:', err);
    process.exit(1);
  });
