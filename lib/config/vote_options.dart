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
  maintenanceEnabled: true,
  maintenanceStartHour: 1,
  maintenanceEndHour: 2,
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
    id: 'P01',
    name: 'Pixy',
    groupName: '柳下理宇、相田千青、河田萌音、梅田彩夏、山口未結',
    description: '''雨のち、きらめき
pixyの魔法の世界へようこそ。''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'P02',
    name: 'マジカリップ',
    groupName: '杉山瑚都、土井晴佳、藤原こころ、宇佐美慶人、田中東、近藤璃空',
    description: '''鵜沢ホールで、とびきりのトキメキをお届けします！そこのあなたにも、キラキラの魔法を♡''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'P03',
    name: 'おなごっぽん〜りたーんず〜',
    groupName: '吉良南々帆、野澤美緒、松山優葵乃、横山結香',
    description: '''女子4人組「おなごっぽん」が、パワーアップして1年振りに帰ってくる！
今回の舞台はなんと授業中！？一緒に盛り上がりましょう♡''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'P04',
    name: '6我夢Chu',
    groupName: '鈴木美優、山田結月、山岸咲結、西出茉央、高崎羽彩、土谷怜奈',
    description: '''6我夢chu!です！初めてのパフォですが頑張ります！
私達に夢中になってください♡''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'P05',
    name: 'MBC-15人の野球侍-',
    groupName:
        '鈴木啓太、萩原大晄、近田洋司、萩原夢都、藤井智寛、鈴木悠一郎、林航大、清水日秀仁、平尾友哉、伊藤大志、稲付翔、音羽真優、賀川湊太、根本優花、山本蒼珠',
    description: '''15人の引退した野球侍、俺らの夏はまだ終わっちゃいない！明治魂！''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'B01',
    name: 'Palette',
    groupName: '清水さくら、張替千鶴、折茂未歩、高梓音、茂野瑠花',
    description: '''マリーゴールド/あいみょん
ケセラセラ/Mrs.GREEN APPLE''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'B02',
    name: 'みたらし',
    groupName: '粟井雪野、石井彩葉、小池瞳子、横屋美空、秋元桃、堀野梓',
    description: '''飛行艇/King Gnu
more than words/羊文学
タッチ/岩崎良美''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'B03',
    name: 'youth',
    groupName: '木下珠里、山本蒼珠、原志織、飯島美月、山口果歩',
    description: '''キミがいれば/伊織
Lovers/sumika
明日も/SHISHAMO
君はロックを聞かない/あいみょん''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'B04',
    name: 'PapiFleur',
    groupName: '西川桃寧、池上あさひ、望月柚依、堀田沙希、岡野谷百香',
    description: '''ノーダウト/Official髭男dism
shape of you/Ed Sheeran
カブトムシ/aiko''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'B05',
    name: 'Jupiter',
    groupName: '丸山諒大、片山瑛輝、岡野悠人、匹田碧人',
    description: '''欲望に満ちた青年団/ONE OK LOCK
シルエット/KANA-BOON''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'B06',
    name: '暖海世代',
    groupName: '峯田羚、長縄和征、明石昇、鈴木晴也',
    description: '''言って。/ ヨルシカ
わかってないよ/Wurts
オドループ/FREDERIC''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'B07',
    name: 'HELLO.SUNDAY',
    groupName: '小倉功大、清水莉瑚、小山栄人、吉田壮樹、萩ノ谷泰成',
    description: '''君と夏フェス/SHISHAMO
勿忘/Awesome City Club
キミシダイ列車/ONE OK ROCK''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'S03',
    name: 'ダンス部',
    groupName: '',
    description: '''#朝イチごめん 総勢58人の部員で踊ります！ 一度きりのステージ！是非一緒に盛り上がりましょう♪''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S04',
    name: 'マンドリン部',
    groupName: '',
    description: '''楽しいポップス曲もマンドリンならではの音色で演奏します！おなじみの曲も、少し特別に聴こえるはず。
#イタリア産まれの弦楽器''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S05',
    name: '書道部',
    groupName: '',
    description:
        '''流行の楽曲をテーマに、一字一字魂を込めた作品を作り上げます。 迫力ある書道パフォーマンスをぜひご覧ください！ # 一筆入魂''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S06',
    name: '有志演劇部',
    groupName: '',
    description: '''「コメディー」を2本、大会議室にて上演します。是非ご覧になってください！''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S07',
    name: '【公開練習】サッカー部',
    groupName: '',
    description: '''恵まれた環境の下、目標達成に向け日々練習に取り組んでいます。''',
    imagePath: '',
    floor: 0,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'G01',
    name: '中学1年生　学年展示',
    groupName: '中1学年',
    description: '''中学1年生の軌跡をご覧ください。''',
    imagePath: '中１学年展示.jpg',
    floor: 2,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'G02',
    name: '中学2年生　学年展示',
    groupName: '中2学年',
    description: '''わたし達がつくった最高の思い出を是非、味わっていってください！！あなたは久能山東照宮で何をお願いする？''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'G03',
    name: '中学3年生　学年展示',
    groupName: '中3学年',
    description:
        '''中学３年生が、明治中学校の「いいところ」や「学校の様子」を、心を込めて紹介します！毎年大好評の体験コーナーにも挑戦してください！中学３年生が笑顔でみなさんをお迎えします！''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'H01',
    name: '次は終点、美術室',
    groupName: '美術部',
    description: '''夜空に瞬く星を眺めれば、銀河鉄道があなたを連れて行ってくれる''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H02',
    name: '有志料理研究部',
    groupName: '',
    description: '''レッツ　ワールドクッキング！''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Tenji],
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
