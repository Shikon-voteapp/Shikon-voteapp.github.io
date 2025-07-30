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
      maintenanceStartHour: json['maintenanceStartHour'] ?? 2,
      maintenanceEndHour: json['maintenanceEndHour'] ?? 3,
    );
  }
}

// データ更新日時
final DateTime dataUpdateDate = DateTime(2025, 7, 31, 16, 42, 0); // 2025年1月15日 12:00

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
    imagePath: 'assets/マジカリップ.png',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'P03',
    name: 'おなごっぽん〜りたーんず〜',
    groupName: '吉良南々帆、野澤美緒、松山優葵乃、横山結香',
    description: '''女子4人組「おなごっぽん」が、パワーアップして1年振りに帰ってくる！
今回の舞台はなんと授業中！？一緒に盛り上がりましょう♡''',
    imagePath: 'assets/おなごっぽん〜りたーんず〜 - nann.PNG',
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
    groupName: '鈴木啓太、萩原大晄、近田洋司、萩原夢都、藤井智寛、鈴木悠一郎、林航大、清水日秀仁、平尾友哉、伊藤大志、稲付翔、音羽真優、賀川湊太、根本優花、山本蒼珠',
    description: '''15人の引退した野球侍、俺らの夏はまだ終わっちゃいない！明治魂！''',
    imagePath: 'assets/MBC.jpeg',
    floor: 4,
    categories: [GroupCategory.Performance],
  ),
  Group(
    id: 'B01',
    name: 'Palette',
    groupName: '清水さくら、張替千鶴、折茂未歩、高梓音、茂野瑠花',
    description: '''マリーゴールド/あいみょん
ケセラセラ/Mrs.GREEN APPLE''',
    imagePath: 'assets/Palette_icon - さくら.jpg',
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
    imagePath: 'assets/youth.PNG',
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
    imagePath: 'assets/暖海世代.jpg',
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
    imagePath: 'assets/マンドリン.jpeg',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S05',
    name: '書道部',
    groupName: '',
    description: '''流行の楽曲をテーマに、一字一字魂を込めた作品を作り上げます。 迫力ある書道パフォーマンスをぜひご覧ください！ # 一筆入魂''',
    imagePath: '',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S06',
    name: '有志演劇部',
    groupName: '',
    description: '''「コメディー」を2本、大会議室にて上演します。是非ご覧になってください！''',
    imagePath: 'assets/有志演劇部イラスト - 瑞穂.PNG',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'S07',
    name: '【公開練習】サッカー部',
    groupName: '',
    description: '''恵まれた環境の下、目標達成に向け日々練習に取り組んでいます。''',
    imagePath: 'assets/サッカー部.jpeg',
    floor: 0,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'G01',
    name: '中学1年生　学年展示',
    groupName: '中学1年',
    description: '''中学1年生の軌跡をご覧ください。''',
    imagePath: 'assets/中１学年展示.jpg',
    floor: 2,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'G02',
    name: '中学2年生　学年展示',
    groupName: '中学2年',
    description: '''わたし達がつくった最高の思い出を是非、味わっていってください！！あなたは久能山東照宮で何をお願いする？''',
    imagePath: 'assets/中2.jpeg',
    floor: 2,
    categories: [GroupCategory.Gakunen],
  ),
  Group(
    id: 'G03',
    name: '中学3年生　学年展示',
    groupName: '中学3年',
    description: '''中学３年生が、明治中学校の「いいところ」や「学校の様子」を、心を込めて紹介します！毎年大好評の体験コーナーにも挑戦してください！中学３年生が笑顔でみなさんをお迎えします！''',
    imagePath: 'assets/中3.jpg',
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
  Group(
    id: 'H03',
    name: '電車でGO！',
    groupName: '鉄道研究部',
    description: '''鉄道模型の体験運転、発車メロディ体験、運転シミュレーターなどができます！ぜひお越しください！''',
    imagePath: 'assets/鉄道研究部.JPG',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H04',
    name: '書の世界、ここに展示中',
    groupName: '書道部',
    description: '''個性溢れる個人作品から歴史感じる共同作品まで！ 書の世界を体感しませんか？ プレゼントも用意してお待ちしています！''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H05',
    name: 'ESSで世界旅行',
    groupName: 'ESS部',
    description: '''文通で届いた世界の人たちからのポストカードを展示！調布市英語マップの展示もあります！''',
    imagePath: 'assets/ESS.jpeg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H06',
    name: '歴研合戦絵巻 ｰ紫紺の的を射貫けｰ',
    groupName: '歴史研究部',
    description: '''源平合戦の真実に迫る！ 歴史研究部による合戦絵巻、ここに展開！「紫紺の的」を射抜くのは誰か――歴史の渦に飛び込み、見届けよ！''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H07',
    name: 'トリック・オア・漫研',
    groupName: '有志漫画研究部',
    description: '''今年のテーマは「ハロウィン」！オリジナルの短編漫画集やイラスト集がゲットできるかも⁉︎''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H08',
    name: 'JRC部＆有志シャプラニール',
    groupName: '',
    description: '''''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H09',
    name: 'いしざんまい！',
    groupName: '地学部',
    description: '''地学部自慢の鉱物や化石をお楽しみください！合宿をまとめたポスターも展示しています！''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H10',
    name: '八十年目の廣島',
    groupName: '地理研究部',
    description: '''80年目の原爆の日である8月6日に調査した広島の様子、春に行った東海道合宿について展示しています。''',
    imagePath: 'assets/地理研究部.jpg',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H11',
    name: '図書班',
    groupName: '',
    description: '''今回のテーマは「スポーツ」本と共に走り抜けよう！！''',
    imagePath: 'assets/図書班.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H12',
    name: '映画部',
    groupName: '',
    description: '''ドキドキワクワクの学生青春物語！自主制作映画を上映中！見に来てね♪''',
    imagePath: '',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H13',
    name: '生物部',
    groupName: '',
    description: '''#ウーパールーパー #食虫植物 #生物観察 #合宿 #顕微鏡 生物部で飼育しているユニークな生き物たちの展示や実験、夏合宿の成果報告などを行います！''',
    imagePath: '',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H14',
    name: '化学部',
    groupName: '',
    description: '''来てくださった方々があっと驚くような実験を行います。スライムの制作体験もできます。''',
    imagePath: 'assets/化学部.jpg',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'H15',
    name: '物理部',
    groupName: '',
    description: '''部員が作成した作品を展示しているので是非見に来てください''',
    imagePath: '',
    floor: 3,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'K01',
    name: 'トロピカル・エスケープ',
    groupName: '高校Ⅱ年B組',
    description: '''僕はモモキー！幻のバナナを探していたら罠にかかっちゃった！？みんなⅡBに僕を助けにきて～！''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K02',
    name: 'みきえちゃんクルーズ',
    groupName: '高校Ⅱ年E組',
    description: '''ただ回るだけじゃない⁉動物にエサをあげる、新感覚クルーズ体験''',
    imagePath: '',
    floor: 0,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K03',
    name: '先生、患者が逃げました',
    groupName: '高校Ⅱ年F組',
    description: '''死んだ患者の呪いが残る廃病院。鍵を探し、無事に脱出できるか...？''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K04',
    name: 'SUPER はらしんご WORLD',
    groupName: '高校Ⅱ年A組＋高校Ⅱ年C組',
    description: '''トロッコに乗ってゲームの世界の中でミニゲームにチャレンジ！あなたを乗せて、私たちが全力で案内します！友達同士でも親子でも1人でも大歓迎！''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K05',
    name: 'Royal MasqueraDe CaGino',
    groupName: '高校Ⅱ年D組＋高校Ⅱ年G組',
    description: '''あなたの元へ一枚の手紙が届きました。それは仮面舞踏会カジノへの招待状だったのです！全ての印を集めると豪華景品を貰えるかも…？今宵あなたを仮面の夜へ誘います。#仮面舞踏会 #カジノ''',
    imagePath: '',
    floor: 1,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K06',
    name: '霊園のサバイバル場',
    groupName: '高校Ⅰ年A組',
    description: '''あなたが吸い込まれたのはゲームの世界。敵は人間…？それとも… スリル満点の没入型サバイバルゲーム！''',
    imagePath: 'assets/ⅠA.jpeg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K07',
    name: 'ご主人様、悲鳴の準備はよろしくて？',
    groupName: '高校Ⅰ年B組',
    description: '''メイドが暗闇から忍び寄り、逃げる客を執拗に追い回す恐怖のお化け屋敷！？君は逃げ切れるか！？''',
    imagePath: 'assets/ⅠB.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K08',
    name: '「高身長じゃ、ダメですか？」',
    groupName: '高校Ⅰ年C組',
    description: '''メイド服を着た高身長ディーラーと勝負しよう！ 勝ったら身長が手に入れられるかも… ？''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K09',
    name: '梶野\'s CASINO',
    groupName: '高校Ⅰ年D組',
    description: '''「梶野」の星からやってきた「カジノ」の申し子たちから勝利を掴み取れ！''',
    imagePath: 'assets/ⅠD.JPG',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K10',
    name: 'ピザの切れ目が命の切れ目',
    groupName: '高校Ⅰ年E組',
    description: '''興味本位で廃墟のピザ屋に来たあなた、けれど入った途端出られなくなくなり。。脱出の鍵はピザ。ちょっと刺激ツヨメ。''',
    imagePath: 'assets/ⅠE.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K11',
    name: 'Kick＆Fight！',
    groupName: '高校Ⅰ年F組',
    description: '''キックで標的を狙い撃て！高ⅠFがお届けする最高にCOOLな夏が始まる！''',
    imagePath: 'assets/ⅠF.jpg',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K12',
    name: 'トロッコ・レーザー・マニア！ｰ無限の彼方へさぁ行くぞｰ',
    groupName: '高校Ⅰ年G組',
    description: '''暗闇の中光る的を狙撃せよ！高ⅠGがお届けする新感覚トロッコアドベンチャー！''',
    imagePath: '',
    floor: 2,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K14',
    name: 'むぅちゃんの落とし物',
    groupName: '高校Ⅲ年C組',
    description: '''君にむぅちゃんのことが救えるのか？生還できるかどうかは、あなた次第。''',
    imagePath: 'assets/ⅢC.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K15',
    name: 'ゴンピン星㊙︎のお茶会',
    groupName: '高校Ⅲ年D組',
    description: '''あなたは、ゴンピン星へと訪れた。楽しいお茶会、陽気な仲間たち。？？？何かがおかしい？？？''',
    imagePath: 'assets/ⅢD.jpeg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K13',
    name: '君たちはどう賭けるか',
    groupName: '高校Ⅲ年A組＋高校Ⅲ年B組',
    description: '''ゲーム？カジノ？…どっちもやっちゃえ！欲ばりさん、ようこそ“運命のアトラクション”へ''',
    imagePath: 'assets/ⅢA.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K16',
    name: 'まっくら投げハウス',
    groupName: '高校Ⅲ年E組',
    description: '''夢の中で枕を武器に化け物退治！目覚ましが鳴る前に現実へ帰還せよ、夢からの脱出劇！''',
    imagePath: 'assets/ⅢE.jpg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K17',
    name: 'ラーメン田中　明大明治本店',
    groupName: '高校Ⅲ年F組',
    description: '''ラーメン屋の弟子となって素材選びから盛り付けまで修行！君の一杯が伝説に！？''',
    imagePath: 'assets/ⅢF.jpeg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  ),
  Group(
    id: 'K18',
    name: '楽シミマ船？Lets号',
    groupName: '高校Ⅲ年G組',
    description: '''ヴァイキングの世界を再現！戦士気分で楽しめる冒険アトラクション！''',
    imagePath: 'assets/ⅢG.jpeg',
    floor: 3,
    categories: [GroupCategory.Moyoshi],
  )
];

// 投票のカテゴリを定義
final List<VoteCategory> voteCategories = [
  VoteCategory(
    id: 'Shikon_award',
    name: '紫紺賞',
    description: 'この文化祭を通じて、最も印象に残った団体を1つ選択してください。',
    shortHelpText: 'ここで選択した団体は、後の賞で選択することはできません。詳細はパンフレットをご覧ください',
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
    shortHelpText: '詳細はパンフレットをご覧ください',
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
