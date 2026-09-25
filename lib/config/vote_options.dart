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
  final int maintenanceStartMinute;
  final int maintenanceEndHour;
  final int maintenanceEndMinute;

  const VotingPeriodConfig({
    required this.startDate,
    required this.endDate,
    this.maintenanceEnabled = true,
    this.maintenanceStartHour = 1,
    this.maintenanceStartMinute = 0,
    this.maintenanceEndHour = 2,
    this.maintenanceEndMinute = 0,
  });

  // 現在時刻が有効期間内かチェック
  bool isWithinVotingPeriod(DateTime dateTime) {
    // メンテナンス時間をチェック
    if (maintenanceEnabled) {
      // 現在時刻を分単位で計算
      int currentTimeInMinutes = dateTime.hour * 60 + dateTime.minute;
      int maintenanceStartInMinutes =
          maintenanceStartHour * 60 + maintenanceStartMinute;
      int maintenanceEndInMinutes =
          maintenanceEndHour * 60 + maintenanceEndMinute;

      bool isMaintenanceTime =
          currentTimeInMinutes >= maintenanceStartInMinutes &&
          currentTimeInMinutes < maintenanceEndInMinutes;
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
      'maintenanceStartMinute': maintenanceStartMinute,
      'maintenanceEndHour': maintenanceEndHour,
      'maintenanceEndMinute': maintenanceEndMinute,
    };
  }

  factory VotingPeriodConfig.fromJson(Map<String, dynamic> json) {
    return VotingPeriodConfig(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maintenanceEnabled: json['maintenanceEnabled'] ?? true,
      maintenanceStartHour: json['maintenanceStartHour'] ?? 2,
      maintenanceStartMinute: json['maintenanceStartMinute'] ?? 45,
      maintenanceEndHour: json['maintenanceEndHour'] ?? 3,
      maintenanceEndMinute: json['maintenanceEndMinute'] ?? 0,
    );
  }
}

// データ更新日時
final DateTime dataUpdateDate = DateTime(2026, 9, 26, 4, 35, 0); // 2025年1月15日 12:00
// デフォルトの投票期間設定
final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig(
  startDate: DateTime(2026, 9, 26, 9, 0), // 2026年9月26日 9:00
  endDate: DateTime(2026, 9, 27, 15, 0), // 2026年9月27日 15:00
  maintenanceEnabled: true,
  maintenanceStartHour: 2,
  maintenanceEndHour: 3,
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
    id: 'kateika1',
    name: '料理研究部',
    groupName: '料理研究部',
    description: '''レッツクッキング！''',
    imagePath: 'assets/料理研究.jpeg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 's101',
    name: '歴史研究部',
    groupName: '歴史研究部',
    description: '''歴研昔話　～元太郎の巻～''',
    imagePath: 'assets/歴史研究部.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 's102',
    name: '地学部',
    groupName: '地学部',
    description: '''地学部の活動、のぞいてみませんか？''',
    imagePath: 'assets/地学部.png',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 's103',
    name: 'ESS部',
    groupName: 'ESS部',
    description: '''ボーディングスクールって何？　～ハリポタ風味～''',
    imagePath: 'assets/ESS.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 's104',
    name: '高校山岳部',
    groupName: '高校山岳部',
    description: '''山岳部の活動、のぞいてみませんか？''',
    imagePath: 'assets/高校山岳部.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 't101',
    name: '地理研究部',
    groupName: '地理研究部',
    description: '''今年は北海道へ！　あの○〇を展示！''',
    imagePath: 'assets/地理研究部.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'syodo1',
    name: '書道部',
    groupName: '書道部',
    description: '''書道は動だ！''',
    imagePath: 'assets/書道部２.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'n103',
    name: '中学１年生学年展示',
    groupName: '中学１年生',
    description: '''中学１年生の展示をします''',
    imagePath: 'assets/中１.jpg',
    floor: 1,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'n104',
    name: '中学２年生学年展示',
    groupName: '中学２年生',
    description: '''中学２年生の展示をします''',
    imagePath: 'assets/中２.jpg',
    floor: 1,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'n105',
    name: '中学３年生学年展示',
    groupName: '中学３年生',
    description: '''中学３年生の展示をします''',
    imagePath: 'assets/中３.jpg',
    floor: 1,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: '2tai1',
    name: '鉄道研究部',
    groupName: '鉄道研究部',
    description: '''鉄道模型の体験運転と発車メロディー体験ができます！　ぜひお越しください！''',
    imagePath: 'assets/鉄道研究部.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 's201',
    name: 'AIRing',
    groupName: '高１A',
    description: '''時空を超えたすばらしい空の旅へご招待！''',
    imagePath: 'assets/1a.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's202',
    name: 'メイドさんと一緒に運試ししよ？',
    groupName: '高１B',
    description: '''運と閃きで勝利を目指せ特別な会場へようこそ！''',
    imagePath: 'assets/1b.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's203',
    name: 'MMB（メイジモンスターバトル）',
    groupName: '高１C',
    description: '''めざせメイモンますたー''',
    imagePath: 'assets/1c.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's204',
    name: '集まれ　明明保育園',
    groupName: '高１D',
    description: '''大人も子どもも遊んじゃえ！''',
    imagePath: 'assets/1d.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's205',
    name: 'ナットウウォーズ',
    groupName: '高１E',
    description: '''目指せ！　宇宙一の納豆巻き専門店！！''',
    imagePath: 'assets/1e.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's206',
    name: '藤波ラーメン道場',
    groupName: '高１F',
    description: '''注文通りのラーメンを作って豪華景品をゲットしよう！''',
    imagePath: 'assets/1f.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's207',
    name: '人間パックマン',
    groupName: '高１G',
    description: '''画面を飛び出せ！　キミが主役の人間パックマン''',
    imagePath: 'assets/1g.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 't201',
    name: '有志漫画研究会',
    groupName: '有志漫画研究会',
    description: '''今年のテーマは『ミステリー』！　教室では部員のイラストを展示しています！部員のオリジナル漫画集やイラスト集がもらえるかも⁉''',
    imagePath: 'assets/漫画研究部.jpg',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 't202',
    name: 'JRC部＆有志シャプラニール',
    groupName: 'JRC部＆有志シャプラニール',
    description: '''フェアトレード商品や東北支援商品を販売しています。今年はウガンダチョコレートもあります！''',
    imagePath: 'assets/JRC部＆有志シャプラニール.jpg',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'n2011',
    name: 'シュートで31！',
    groupName: '女子フットサル',
    description: '''大人気のサーティーワン売ってます‼''',
    imagePath: 'assets/女子フットサル.jpg',
    floor: 2,
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 'n2012',
    name: '面 de アノー',
    groupName: '剣道部',
    description: '''面くらううまさ！''',
    imagePath: 'assets/剣道部.jpg',
    floor: 2,
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 'n2021',
    name: 'チュロスマッシュ',
    groupName: 'ソフトテニス部',
    description: '''ソフテニ部員が皆さんに愛を込めてチュロスを販売します♡''',
    imagePath: 'assets/ソフトテニス部.jpg',
    floor: 2,
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 'n2022',
    name: 'シューアイス天国',
    groupName: 'スキー部',
    description: '''スキーシューでひんやり涼しく！''',
    imagePath: 'assets/スキー部.jpg',
    floor: 2,
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 'n2031',
    name: 'おむすび処卓球部',
    groupName: '卓球部',
    description: '''おむすびコロリン？あまりの美味しさにあなたもコロリン？...　楽しい文化祭！　昼ご飯はぜひ片手におむすび！''',
    imagePath: 'assets/卓球部.jpg',
    floor: 2,
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 'n2032',
    name: '水上チョコバナナ',
    groupName: '水泳部',
    description: '''ここでしか食べられないチョコバナナを300円で売ってます‼　ぜひ食べに来てください‼''',
    imagePath: 'assets/水泳部.jpg',
    floor: 2,
    categories: [GroupCategory.Roten],
  ),
  Group(
    id: 's301',
    name: 'ジンミィジョーンズ',
    groupName: '高ⅡA',
    description: '''生徒の度重なる悪事でA組の守り神がお怒りだ！　手がかりを探して怒りを鎮めよう！！''',
    imagePath: 'assets/2a.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's302',
    name: 'エイリアン過ぎて滅　～え、いるやん～',
    groupName: '高ⅡB',
    description: '''３つのミッションを制覇して、宇宙を救え！　平和を守って景品をゲット！''',
    imagePath: 'assets/2b.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's303',
    name: '脱出中',
    groupName: '高ⅡC',
    description: '''脱出ゲーム　先生に監禁''',
    imagePath: 'assets/2c.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's304',
    name: '縁日で”あなた”の人生延日？',
    groupName: '高ⅡD',
    description: '''勝負を決めるのは、年齢じゃない。必要なのは、少しの運と挑戦する勇気”あなた”の挑戦待ってます''',
    imagePath: 'assets/2d.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's205',
    name: '冥慈総合病院',
    groupName: '高ⅡE',
    description: '''ここは廃病院になった冥慈総合病院。ここで亡くなった入院患者の亡霊が見まだ病院内にいるという。あなたは無事に帰って来られるか・・・''',
    imagePath: 'assets/2e.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's306',
    name: 'HOTEL No.13',
    groupName: '高ⅡF',
    description: '''深夜０時になると、何処にもなかったはずの13号室が姿を現す。　あなたたちは、このホテルに残された呪いを終わらせるために派遣された調査隊。無事に脱出できるか、それとも、このホテルの新たな宿泊客となるか・・・。''',
    imagePath: 'assets/2f.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 's307',
    name: '戦慄病棟G　～呪われた病院～',
    groupName: '高ⅡG',
    description: '''奇妙な病院の中に隠された秘密を探し出す''',
    imagePath: 'assets/2g.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 't30123',
    name: '班会・図書班',
    groupName: '班会・図書班',
    description: '''学内唯一の「班による合同展示」！''',
    imagePath: 'assets/班会＆図書館.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 't304',
    name: '映画部',
    groupName: '映画部',
    description: '''自主製作映画を上映しています　ぜひ見に来てください！''',
    imagePath: 'assets/映画部.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'seibu1',
    name: '生物部',
    groupName: '生物部',
    description: '''生物部で飼育しているユニークな生き物たちの展示や顕微鏡での観察、夏合宿の成果報告などを行います！''',
    imagePath: 'assets/生物部.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'kagak1',
    name: '化学部',
    groupName: '化学部',
    description: '''来てくださった方々がアッと驚くような実験を行います！スライムの体験もできるのでぜひ来てください！''',
    imagePath: 'assets/化学部.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'butur1',
    name: '物理部',
    groupName: '物理部',
    description: '''部員が作成した作品を展示しているのでぜひ見に来てください！''',
    imagePath: 'assets/物理部.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'saho1',
    name: '有志茶道部',
    groupName: '有志茶道部',
    description: '''土曜日のみの展示です''',
    imagePath: 'assets/有志茶道部.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'n301',
    name: 'PROJECT Z　ー感染まで４分ー',
    groupName: '高ⅢAB',
    description: '''ゾンビ研究所の研究は失敗し研究員はゾンビになった。彼らを人間に戻すには封印されたワクチンが必要だ。謎を解き、暗号を探せ！''',
    imagePath: 'assets/3ab.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'n302',
    name: 'アリスインジェンガーランド',
    groupName: '高ⅢC',
    description: '''小さくなったあなたを待つ巨大タワー。ジェンガの戦いに勝ち、元の姿に戻るクッキーを手にするのは誰だ！''',
    imagePath: 'assets/3c.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'n303',
    name: 'D鳴村',
    groupName: '高ⅢD',
    description: '''人と、人ならざる者が住まうD鳴村。そこにある百鬼高校、通称「百校」（ももこう）では、とうに廃れた今も誰かの足音が響き続けているらしい・・・''',
    imagePath: 'assets/3d.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'n304',
    name: '人狂絞場',
    groupName: '高ⅢE',
    description: '''あなたは異常なぬいぐるみ工場にやってきた。無事に帰って来られるかな？狂って来場♫''',
    imagePath: 'assets/3e.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'n305',
    name: 'F1-COASTER',
    groupName: '高ⅢF',
    description: '''手作りのスリルを体感せよ！''',
    imagePath: 'assets/3f.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'n306',
    name: '慎吾回るンゴ　～夜露紫煌★ティータイム～',
    groupName: '高ⅢG',
    description: '''夜露紫煌（よろしく）★回ればみんなダチ！　昭和レトロなコーヒーカップ！　Ⅲ年G組で待ってるよ！レッツYTT！''',
    imagePath: 'assets/3g.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'n307',
    name: 'ゲーム横丁H組店',
    groupName: '高ⅢH',
    description: '''ゲームセンターで遊び尽くそう！　みんなの挑戦待ってるよ！''',
    imagePath: 'assets/3h.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'uzawa3',
    name: 'マンドリン部',
    groupName: 'マンドリン部',
    description: '''感銘を与える演奏''',
    imagePath: 'assets/マンドリン部.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'ititai2',
    name: '書道部',
    groupName: '書道部',
    description: '''書道は動だ！''',
    imagePath: 'assets/書道部.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'pafo1',
    name: 'おなごっぽん　～ざ・ふぁいなる～',
    groupName: 'おなごっぽん　～ざ・ふぁいなる～',
    description: '''ラスト紫紺祭、おなごらしさ全開！３年間の集大成、最後まで可愛く楽しく弾けます！''',
    imagePath: 'assets/pafo4.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'pafo2',
    name: '愛 FIVE',
    groupName: '愛 FIVE',
    description: '''５人でデビューして、みなさんに愛とパワーをお届けします''',
    imagePath: 'assets/pafo5.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'pafo3',
    name: 'pixy',
    groupName: 'pixy',
    description: '''盛り上がる曲沢山！　ぜひ歌って楽しんでください！''',
    imagePath: 'assets/pafo3.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'pafo4',
    name: 'ILL-SaiRent',
    groupName: 'ILL-SaiRent',
    description: '''ただただダンス愛の強い２人で結成しました。それぞれのスタイルで私たちらしく踊ります！沢山声出して名前呼んで盛り上げて楽しんでください！''',
    imagePath: 'assets/pafo2.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'pafo5',
    name: 'mbc-9人の野球侍',
    groupName: 'mbc-9人の野球侍',
    description: '''高校野球を引退した私たちが、最後にもう一度みんなで盛り上がれるステージを作ります。野球部として過ごした時間の集大成として、それぞれのスタイルで私たちらしく踊ります。''',
    imagePath: 'assets/pafo1.jpg',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'band1',
    name: '暖海世代',
    groupName: '暖海世代',
    description: '''ずうっといっしょ！/キタニタツヤ
会心の一撃/RADWIMPS
お気に召すまま/Eve
ソラニン/ASIAN KUNG-FU GENERATION''',
    imagePath: 'assets/band3.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'band2',
    name: 'ふるーれっと',
    groupName: 'ふるーれっと',
    description: '''明日も/SHISHAMO
栞/クリープハイプ
Wherever you are/ONE OK ROCK''',
    imagePath: 'assets/band6.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'band3',
    name: 'PentGram',
    groupName: 'PentGram',
    description: '''飛行艇/King Gnu
さよならエレジー/菅田将暉
栞/クリープハイプ''',
    imagePath: 'assets/band2.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'band4',
    name: 'Jupiter',
    groupName: 'Jupiter',
    description: '''一途/King Gnu
ピースサイン/米津玄師
天体観測/BUNP OF CHICKEN''',
    imagePath: 'assets/band4.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'band5',
    name: 'にぼし',
    groupName: 'にぼし',
    description: '''恋する/SHISHAMO
君はロックを聴かない/あいみょん
花火/aiko''',
    imagePath: 'assets/band5.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'band6',
    name: 'MISCH-MASCH',
    groupName: 'MISCH-MASCH',
    description: '''踊り子/Vaundy
丸の内サディスティック/椎名林檎
シンデレラボーイ/Saucy Dog''',
    imagePath: 'assets/band7.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'band7',
    name: 'HELLO.SUNDAY',
    groupName: 'HELLO.SUNDAY',
    description: '''新宝島/サカナクション
アイノカタチ/MISIA
会心の一撃/YOASOBI''',
    imagePath: 'assets/band1.jpg',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'uzawa4',
    name: 'ダンス部',
    groupName: 'ダンス部',
    description: '''MDC17thがつくり上げる、総勢59人の一度きりのステージ。ぜひ会場でご覧ください。''',
    imagePath: 'assets/ダンス部.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
  )
];

// 投票のカテゴリを定義
final List<VoteCategory> voteCategories = [
  VoteCategory(
    id: 'Shikon_award',
    name: '紫紺賞',
    description: 'この文化祭を通じて、最も印象に残った団体を1つ選択してください。',
    shortHelpText:
        'ここで選択した団体は、他の賞でも選択できます（重複可）。詳細はパンフレットをご覧ください。\nまた、応援指導班、吹奏楽班は受賞を辞退しているため、選択することはできません。',
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
    canSkip: true,
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
    canSkip: true,
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
    canSkip: true,
  ),
  VoteCategory(
    id: 'Stage',
    name: '部活ステージ賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がった部活ステージ団体を1つ選択してください。',
    shortHelpText: '応援指導班、吹奏楽班は受賞を辞退しているため、選択することはできません。詳細はパンフレットをご覧ください。',
    groups:
        allGroups
            .where((group) => group.categories.contains(GroupCategory.Stage))
            .toList(),
    canSkip: true,
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
];

// 生徒認証用の情報を追加
final VoteCategory studentVerification = VoteCategory(
  id: 'student_verification',
  name: '投票券情報入力',
  description: '投票券に記載されている番号を入力してください。',
  groups: [],
  helpUrl: 'assets/help/student_verification_help.html',
);
