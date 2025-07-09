import 'package:shikon_voteapp/models/group.dart' hide VoteCategory;
import 'package:shikon_voteapp/models/vote_category.dart';

// config/vote_options.dart
/*
=======投票先一覧を設定する設定ファイル=======
*/

// 投票期間設定クラス
class VotingPeriodConfig {
  final DateTime startDate;
  final DateTime endDate;
  final bool maintenanceEnabled;
  final int maintenanceStartHour;
  final int maintenanceEndHour;

  const VotingPeriodConfig({
    required this.startDate,
    required this.endDate,
    this.maintenanceEnabled = true,
    this.maintenanceStartHour = 1,
    this.maintenanceEndHour = 2,
  });

  // 現在時刻が有効期間内かチェック
  bool isWithinVotingPeriod(DateTime dateTime) {
    // メンテナンス時間をチェック
    if (maintenanceEnabled) {
      bool isMaintenanceTime =
          dateTime.hour >= maintenanceStartHour &&
          dateTime.hour < maintenanceEndHour;
      if (isMaintenanceTime) {
        return false; // メンテナンス時間内は常に無効
      }
    }

    return dateTime.isAfter(startDate) && dateTime.isBefore(endDate);
  }

  // 現在の設定を文字列で取得（表示用）
  String getFormattedDateRange() {
    return '${_formatDateTime(startDate)} から ${_formatDateTime(endDate)} まで';
  }

  // 日時のフォーマット
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // JSONシリアライゼーション
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maintenanceEnabled': maintenanceEnabled,
      'maintenanceStartHour': maintenanceStartHour,
      'maintenanceEndHour': maintenanceEndHour,
    };
  }

  factory VotingPeriodConfig.fromJson(Map<String, dynamic> json) {
    return VotingPeriodConfig(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maintenanceEnabled: json['maintenanceEnabled'] ?? true,
      maintenanceStartHour: json['maintenanceStartHour'] ?? 1,
      maintenanceEndHour: json['maintenanceEndHour'] ?? 2,
    );
  }
}

// デフォルトの投票期間設定
final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig(
  startDate: DateTime(2025, 4, 1, 9, 0), // 2025年4月1日 9:00
  endDate: DateTime(2025, 9, 22, 15, 0), // 2025年9月22日 15:00
);

// カテゴリの日本語名
const Map<GroupCategory, String> groupCategoryNames = {
  GroupCategory.Tenji: '教室展示',
  GroupCategory.Moyoshi: '教室催し物',
  GroupCategory.Gakunen: '学年展示',
  GroupCategory.Roten: '露店',
  GroupCategory.Stage: '部活ステージ',
  GroupCategory.Performance: 'パフォーマンス',
  GroupCategory.Band: 'バンド',
  GroupCategory.other: 'その他',
};

// すべての団体のリスト
final List<Group> allGroups = [
  Group(
    id: 'H',
    name: '文化祭準備委員会本部室',
    groupName: 'あ',
    description: '紫紺祭の運営を担う文化祭準備委員会の本部室です。何かお困りのことがあったらこちらまでお越しください。',
    imagePath: 'assets/First/S101.jpg',
    floor: 1,
    categories: [GroupCategory.other],
  ),
  Group(
    id: '01',
    name: '明治藩校歴研館～紫紺に染まれ～',
    groupName: 'あ',
    description: '歴研といえば藩校！明治といえば紫紺！紫紺の藩校で学べ！！',
    imagePath: 'assets/First/S102.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: '02',
    name: '高校山岳部',
    groupName: 'あ',
    description: '山岳部が登った山を紹介します。キャンプの様子やキャンプ飯も必見です！登山用具を試すこともできます。',
    imagePath: 'assets/First/S103.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: '03',
    name: 'いしざんまい！',
    groupName: 'あ',
    description: '地学部自慢の鉱物や化石をお楽しみください！合宿をまとめたポスターも展示しています！',
    imagePath: 'assets/First/S104.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: '04',
    name: '北海道「函館＋江差」',
    groupName: 'あ',
    description: '北海道の函館と江差の街並み景観とまちづくり、伝統的見地奥物の保全について展示しています。地理研クイズも用意しています。',
    imagePath: 'assets/First/S105.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '06',
    name: '料研の森',
    groupName: 'あ',
    description: '研究の発表や作品の展示を行います！魅惑の料理があなたを待ってる・・・！',
    imagePath: 'assets/First/Chori_Room.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '43',
    name: '電車でGO！',
    groupName: 'あ',
    description: '鉄道模型の体験運転、発車メロディ体験、運転シミュレーターなどができます！ぜひお越しください！',
    imagePath: 'assets/First/Technology_Room.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '07',
    name: '書道の衝動',
    groupName: 'あ',
    description: 'たくさんの個性豊かな作品展示をしています！衝動で見に来ないか？！お土産もあるよ',
    imagePath: 'assets/First/Music_Room.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '08',
    name: 'ゲームフェスティバル',
    groupName: 'あ',
    description: '対戦ゲーも音ゲーも！新たなゲームとの出会いがあるかも...！？キミだけの楽しみ方を見つけよう！',
    imagePath: 'assets/First/T101.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '09',
    name: 'Re:KPEX',
    groupName: 'あ',
    description: '天下分け目の大合戦、武器は刀じゃなくて銃！？令和番関ケ原の戦いぜひお越しください！',
    imagePath: 'assets/First/N101.jpg',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '10',
    name: '3Death',
    groupName: 'あ',
    description: '廃校に棲みついた妖怪を退治しろ！他とは違う新しい"お化け探し"･･･今年の肝試しはN棟1階で決まり！',
    imagePath: 'assets/First/N102.jpg',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '11',
    name: '客恋慕',
    groupName: 'あ',
    description: '「私とかくれんぼしよ。」明治1最恐の空間へようこそ。#贈り物あり',
    imagePath: 'assets/First/N103.jpg',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '12',
    name: '僕らの小宇宙戦争',
    groupName: 'あ',
    description: 'トロッコに乗って制限時間内に宇宙人を倒せ！得点をかせいで覇者明治になろう！１',
    imagePath: 'assets/First/N104.jpg',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '13',
    name: 'B女とBスト',
    groupName: 'あ',
    description: '舞台は森の中の館。しかしそこはなんとBストの館だった！バラを集めて無事に脱出することはできるのか！？',
    imagePath: 'assets/First/N105.jpg',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '14',
    name: 'ばんこchanの萌え²きゅん♡',
    groupName: 'あ',
    description: '日々の疲れを癒します！あなたの心に萌え萌えきゅん♡',
    imagePath: 'assets/Second/S201.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '15',
    name: 'vsYUDAI星人',
    groupName: 'あ',
    description: 'YUDAI星から未知の生物がやってきた！ベスト"ショット"を狙って"バズ"らせろ！！',
    imagePath: 'assets/Second/S202.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '16',
    name: '背筋ルーブルブル美術館',
    groupName: 'あ',
    description: 'この美術館から宝を盗み出せるかな？正解のカイトウを導き脱出せよ！怪盗だけにね！',
    imagePath: 'assets/Second/S203.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '17',
    name: '不思議な国のユキ',
    groupName: 'あ',
    description: '物語の世界に入ったような演出や装飾の中で宝探し、射的、クロッケーをポイント制で楽しんでもらう。',
    imagePath: 'assets/Second/S204.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '18',
    name: '班会',
    groupName: 'あ',
    description: '班の活動報告、紹介動画やユニフォーム展示を行います。授業風景動画も放送します。是非見に来てください！',
    imagePath: 'assets/Second/S205.jpg',
    floor: 2,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '20',
    name: '図書班',
    groupName: 'あ',
    description: '今年のテーマは「物語の中に入るなら･･･？！」新たな発見や驚きが待っているかも１',
    imagePath: 'assets/Second/S207.jpg',
    floor: 2,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '22',
    name: "under of ⅡA's",
    groupName: 'あ',
    description: '至る所に潜む怪物を迎え撃て！高ⅡAがお届けする鬼ごっこ×トロッコアドベンチャー！',
    imagePath: 'assets/Second/N201.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '23',
    name: 'CASINO HARASSY',
    groupName: 'あ',
    description: 'ラスベガスなカジノでハラハラドキドキ！？チップの数で豪華景品も！Chase the Chance‼',
    imagePath: 'assets/Second/N202.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '24',
    name: '人形供養',
    groupName: 'あ',
    description: 'なくなった夫婦の霊が愛する人形を探しているのです 帰る時、人のままかはあなた次第、、',
    imagePath: 'assets/Second/N203.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '25',
    name: '日本の果てまでイッテG',
    groupName: 'あ',
    description: 'トロッコで日本一周しながら道中のミニゲームをクリアしよう！ポイント稼いで目指せ1位！',
    imagePath: 'assets/Second/N204.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '26',
    name: 'Bトdeカート',
    groupName: 'あ',
    description: '「廊下を走っちゃいけません」でも俺らは走るで？？「教室で」カートに乗って教室を駆け抜けよう‼',
    imagePath: 'assets/Second/N205.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '30',
    name: '注文の多い舞踏会',
    groupName: 'あ',
    description: 'あなたに招待状が。選ばれた人だけの舞踏会がコーヒーカップで行われるらしい･･･って条件が多すぎる？！',
    imagePath: 'assets/Third/S301.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '31',
    name: '明治の覇者は世界の覇者',
    groupName: 'あ',
    description: 'あなたは世界一になったことがありますか？ここは本当の世界の王者を決める場所。さあ、あなたもEarthの果てまでイッテQ！',
    imagePath: 'assets/Third/S302.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '32',
    name: '変なサーカス',
    groupName: 'あ',
    description: 'ホラーが苦手な方や心臓が弱い方は控えてください。途中退出不可。あらかじめご了承ください。',
    imagePath: 'assets/Third/S303.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '33',
    name: 'The wheel of fotune',
    groupName: 'あ',
    description: 'カジノの本場、ラスベガスを感じさせる雰囲気で、いろいろな賭け事を楽しめます！1度は行かなきゃもったいない！！',
    imagePath: 'assets/Third/S304.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '35',
    name: '脱出ゲーム～天国と地獄～',
    groupName: 'あ',
    description: 'あなたは天使に会えるのか･･･それとも悪魔と会うのか･･･',
    imagePath: 'assets/Third/S306.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '36',
    name: '明大迷路(めいだいめいじ)',
    groupName: 'あ',
    description: '食中毒で死んだ客がクリームソーダの妖精となり追いかけてくる！迷宮にあるクリームソーダを集めゴールしよう！',
    imagePath: 'assets/Third/S307.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
    pamphletPage: 99,
  ),
  Group(
    id: '27',
    name: 'お点前と作法室の見学',
    groupName: 'あ',
    description: '初日21日のみ部員がお点前を披露します。作法室には茶道についての展示もありますので是非お越しください。',
    imagePath: 'assets/Third/Daikaigi.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '28',
    name: 'おとぎの国の漫研',
    groupName: 'あ',
    description: '今年のテーマは「おとぎ話」！オリジナル漫画の短編集やイラスト集がゲットできるかも？！',
    imagePath: 'assets/Third/Tokusho_1_2_3.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '29',
    name: 'Cinema Meiji',
    groupName: 'あ',
    description: '映画部がお送りする本格的な自主製作映画を絶賛公開中！劇場でお待ちしています！',
    imagePath: 'assets/Third/T304.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '37',
    name: '生物部',
    groupName: 'あ',
    description: '生物部で飼育している生物の展示、身近な微生物を顕微鏡で観察、葉っぱを使った実験を行います！',
    imagePath: 'assets/Third/Seibutsu_Experiment.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '38',
    name: 'わくわく！化学実験',
    groupName: 'あ',
    description: '来てくださった方が驚くような実験を行います。スライムの制作実験もできます。',
    imagePath: 'assets/Third/Kagaku_Experiment.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '39',
    name: '物理部',
    groupName: 'あ',
    description: '部員が制作した制作物や、部の備品などを展示しています。一部の展示品は触ることができますので、ぜひ来てください。',
    imagePath: 'assets/Third/Butsuri_Experiment.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
    pamphletPage: 99,
  ),
  Group(
    id: '40',
    name: '中1学年展示',
    groupName: 'あ',
    description: '明治に入学したてのフレッシュな中学1年生の学年展示です！ぜひお越しください！',
    imagePath: 'assets/Third/N301.jpg',
    floor: 3,
    categories: [GroupCategory.Gakunen],
    pamphletPage: 99,
  ),
  Group(
    id: '41',
    name: '中2学年展示',
    groupName: 'あ',
    description: '明治中学校のいいところや、中2学年がどんな学年かを伝えます！体験ブースでは中2の気持ちが味わえます！ぜひお越しください！',
    imagePath: 'assets/Third/N302.jpg',
    floor: 3,
    categories: [GroupCategory.Gakunen],
    pamphletPage: 99,
  ),
  Group(
    id: '42',
    name: '中3学年展示',
    groupName: 'あ',
    description: 'それいけ！ぼくらの集大成 中学三年間の集大成と成長を知ることができる中3最後の学年展示',
    imagePath: 'assets/Third/N303.jpg',
    floor: 3,
    categories: [GroupCategory.Gakunen],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_a',
    name: '面あり！メンチカツバーガー【剣道部】',
    groupName: 'あ',
    description: 'あのまい泉が露店に！一緒に食べて元気100倍で文化祭を楽しみましょう！',
    imagePath: 'assets/Stage/Roten_a.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_b',
    name: 'ソフトなヒレカツサンド【ソフトテニス部】',
    groupName: 'あ',
    description: '大盛り上がりでお腹のすく紫紺祭にぴったりのヒレカツサンド売ってます！ぜひ買いに来てください！',
    imagePath: 'assets/Stage/Roten_b.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_c',
    name: '本日、庭球日。【硬式テニス部】',
    groupName: 'あ',
    description: '文化祭の王道といえばチュロス！！3種類の味を選べるよ！甘いものが食べたくなったら、ぜひ！',
    imagePath: 'assets/Stage/Roten_c.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_d',
    name: 'スキーシューで涼まない？【スキー部】',
    groupName: 'あ',
    description: 'あつーい季節にシューアイスはどう！？1個100円で4種類の味売ってます！！',
    imagePath: 'assets/Stage/Roten_d.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_e',
    name: 'ぷかぷかベーグル【水泳部】',
    groupName: 'あ',
    description: 'プールといえばうきわ！うきわといえばベーグル！！美味しい4種のベーグル売ってます！',
    imagePath: 'assets/Stage/Roten_e.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_f',
    name: 'Badmin Robbins【バドミントン部】',
    groupName: 'あ',
    description: '今年はバドミントン部ではあつ～い夏にピッタリなアイスクリームを販売します！ぜひ買いに来てください！',
    imagePath: 'assets/Stage/Roten_f.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Roten_g',
    name: 'DONUT and FIELD【陸上競技部】',
    groupName: 'あ',
    description: '1つ100円！サクサクドーナツ！売り切れる前にぜひ！',
    imagePath: 'assets/Stage/Roten_g.jpg',
    floor: 3,
    categories: [GroupCategory.Roten],
    pamphletPage: 99,
  ),
  Group(
    id: 'Stage_02',
    name: 'ダンス部',
    groupName: 'あ',
    description: '総勢54人の部員で踊ります！盛り上がること間違いなしです！鵜澤ホールで待っています！',
    imagePath: 'assets/Stage/Stage02.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
    pamphletPage: 99,
  ),
  Group(
    id: 'Stage_05',
    name: '書道部',
    groupName: 'あ',
    description: '総勢30人での大迫力の完璧で究極のパフォーマンス！見ないなんて損だ',
    imagePath: 'assets/Stage/Stage04.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
    pamphletPage: 99,
  ),
  Group(
    id: 'Stage_06',
    name: '有志演劇部',
    groupName: 'あ',
    description: '短編、長編それぞれ1本ずつの「コメディー」を大会議室にて上演します！とくとご覧あれ‼',
    imagePath: 'assets/Stage/Stage06.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
    pamphletPage: 99,
  ),
  Group(
    id: 'Stage_07',
    name: '【公開練習】サッカー部',
    groupName: 'あ',
    description: '恵まれた環境の元、目標達成に向け日々練習に取り組んでいます。',
    imagePath: 'assets/Stage/Stage07.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
    pamphletPage: 99,
  ),
  Group(
    id: 'Stage_08',
    name: '【公開練習】バスケ部',
    groupName: 'あ',
    description: 'チーム一丸となって練習しています。普段の姿を見に来てください。',
    imagePath: 'assets/Stage/Stage08.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
    pamphletPage: 99,
  ),
  Group(
    id: 'Stage_09',
    name: '【公開練習】バレー部',
    groupName: 'あ',
    description: '時代とともに古豪と化した明治。今復活の一途を辿る練習が始まる。この感動を見逃すな！',
    imagePath: 'assets/Stage/Stage09.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
    pamphletPage: 99,
  ),
  Group(
    id: 'Band_01',
    name: 'Soullerfly',
    groupName: 'あ',
    description: '今年結成した高一のガールズバンドです！蝶は魂の象徴、その魂に響く音楽を届けます！',
    imagePath: 'assets/Stage/Band01.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
    pamphletPage: 99,
  ),
  Group(
    id: 'Band_02',
    name: 'HELLOSUNDAY',
    groupName: 'あ',
    description: '男女のツインボーカルが特徴なので、その利点を最大限活かしてバンドメンバーと最高の曲を仕上げたいと思っています！',
    imagePath: 'assets/Stage/Band02.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
    pamphletPage: 99,
  ),
  Group(
    id: 'Band_03',
    name: 'Fleurette',
    groupName: 'あ',
    description: 'バンドが大好きなメンバーで楽しく最高の演奏をします！高1女子バンドの本気をご覧ください！',
    imagePath: 'assets/Stage/Band03.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
    pamphletPage: 99,
  ),
  Group(
    id: 'Band_04',
    name: '&Ronely',
    groupName: 'あ',
    description: '廊下に集いし者たちのバンドです。あの日の憧れは形を変えて走り出す。',
    imagePath: 'assets/Stage/Band04.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
    pamphletPage: 99,
  ),
  Group(
    id: 'Band_05',
    name: 'ぐらふぃてぃ',
    groupName: 'あ',
    description: '高3の4人組によるナイスな演奏で、あなたの心にビブラート。仲良いあの子も気になるあの子もどうせみんな、ウチらの虜。',
    imagePath: 'assets/Stage/Band02.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
    pamphletPage: 99,
  ),
  Group(
    id: 'Performance_A',
    name: 'Kaikamahi Hula',
    groupName: 'あ',
    description: '私たちが踊るフラダンスはハワイで生まれた民族舞踊です。みなさんが知っている曲も踊るので、ぜひ見に来てください。',
    imagePath: 'assets/Stage/Performance01.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
    pamphletPage: 99,
  ),
  Group(
    id: 'Performance_B',
    name: 'MinChO',
    groupName: 'あ',
    description: '流行りの曲に合わせて5人で楽しく踊ります！一緒に盛り上がる準備はできてますかー？！',
    imagePath: 'assets/Stage/Performance02.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
    pamphletPage: 99,
  ),
  Group(
    id: 'Performance_C',
    name: 'おなごっぽん',
    groupName: 'あ',
    description: 'おなごっぽんです！4人の女子(おなご)が踊ります！応援よろしくお願いします♡',
    imagePath: 'assets/Stage/Performance03.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
    pamphletPage: 99,
  ),
  Group(
    id: 'Performance_D',
    name: '#Ⅰf',
    groupName: 'あ',
    description: '5人全員元高ⅠF組！再結集してラスト文化祭楽しむぞ！ダンスなどでみんなに青春、お届けします！',
    imagePath: 'assets/Stage/Performance04.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
    pamphletPage: 99,
  ),
  Group(
    id: 'Performance_E',
    name: 'ボケっとモンスター',
    groupName: 'あ',
    description: 'どこからか現れた謎の4人！このモンスターはボケタイプ？ツッコミタイプ？仮面の下に現れたものは、、？',
    imagePath: 'assets/Stage/Performance05.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
    pamphletPage: 99,
  ),
  Group(
    id: 'S01',
    name: '吹奏楽班',
    groupName: '吹奏楽班',
    description: '吹奏楽班による演奏です。',
    imagePath: 'assets/Stage/Stage01.jpg',
    floor: 1, // 体育館ステージの場所によって調整
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S02',
    name: 'ダンス部',
    groupName: 'ダンス部',
    description: 'ダンス部によるパフォーマンスです。',
    imagePath: 'assets/Stage/Stage02.jpg',
    floor: 1, // 体育館ステージの場所によって調整
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'S03',
    name: 'マンドリン部',
    groupName: 'マンドリン部',
    description: 'マンドリン部による演奏です。',
    imagePath: 'assets/Stage/Stage03.jpg',
    floor: 1, // 体育館ステージの場所によって調整
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S04',
    name: '書道部',
    groupName: '書道部',
    description: '書道部による書道パフォーマンスです。',
    imagePath: 'assets/Stage/Performance01.jpg',
    floor: 1, // 第1体育館
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'S05',
    name: '応援指導班',
    groupName: '応援指導班',
    description: '応援指導班による演舞です。',
    imagePath: 'assets/Stage/Performance02.jpg',
    floor: 1, // 第1体育館
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'R01',
    name: 'PTA',
    groupName: 'PTA',
    description: 'PTAによる出店です。',
    imagePath: 'assets/Stage/Roten_a.jpg',
    floor: 1, // 露店エリア
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 'R02',
    name: '高Ⅲ',
    groupName: '高Ⅲ',
    description: '高校3年生による出店です。',
    imagePath: 'assets/Stage/Roten_b.jpg',
    floor: 1, // 露店エリア
    categories: [GroupCategory.Roten],
  ),
];

// 投票のカテゴリを定義
final List<VoteCategory> voteCategories = [
  VoteCategory(
    id: 'Shikon_award',
    name: '紫紺賞',
    description: 'この文化祭を通じて、最も印象に残った団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where(
              (group) =>
                  group.categories.contains(GroupCategory.Tenji) ||
                  group.categories.contains(GroupCategory.Moyoshi) ||
                  group.categories.contains(GroupCategory.Gakunen) ||
                  group.categories.contains(GroupCategory.Roten) ||
                  group.categories.contains(GroupCategory.Stage),
            )
            .toList(),
    helpUrl: 'assets/help/shikon_help.html',
  ),
  VoteCategory(
    id: 'Tenji',
    name: '教室展示賞',
    description: '教室展示の中で「最後にもう一回行くならこれだ！」と思えるクオリティが最も高かった団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Tenji))
            .toList(),
  ),
  VoteCategory(
    id: 'Gakunen',
    name: '学年展示賞',
    description: '学年展示の中で「最後にもう一回行くならこれだ！」と思えるクオリティが最も高かった団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Gakunen))
            .toList(),
  ),
  VoteCategory(
    id: 'Moyoshi',
    name: '教室催し物賞',
    description: '教室催し物の中で「最後にもう一回行くならこれだ！」と思えるクオリティが最も高かった団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Moyoshi))
            .toList(),
  ),
  VoteCategory(
    id: 'Stage',
    name: '部活ステージ賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がった部活ステージ団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Stage))
            .toList(),
  ),
  VoteCategory(
    id: 'Band',
    name: 'バンド賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がったバンド団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Band))
            .toList(),
    canSkip: true,
  ),
  VoteCategory(
    id: 'Performance',
    name: 'パフォーマンス賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がったパフォーマンス団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where(
              (group) => group.categories.contains(GroupCategory.Performance),
            )
            .toList(),
    canSkip: true,
  ),
  VoteCategory(
    id: 'Roten',
    name: '露店賞',
    description: '露店の装飾が魅力的で接客における笑顔が最も素敵であった団体を1つ選択してください。',
    shortHelpText: '詳細はパンフレットをご覧ください',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Roten))
            .toList(),
    canSkip: true,
  ),
];

// 生徒認証用の情報を追加
final VoteCategory studentVerification = VoteCategory(
  id: 'student_verification',
  name: '投票券情報入力',
  description: '投票券に記載されている番号を入力してください。',
  groups: [],
  helpUrl: 'assets/help/student_verification_help.html',
);
