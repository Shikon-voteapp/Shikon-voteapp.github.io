import 'package:shikon_voteapp/models/group.dart';

// config/vote_options.dart
/*
=======投票先一覧を設定する設定ファイル=======
VoteCategory(),を一つの投票カテゴリとして設定されています。
VoteCategoryのパラメータ
- id: '',　→投票カテゴリのID。他のカテゴリと被らない名前を用いてください。
- name: '', →投票カテゴリの名前。ここで設定した名前が投票画面に表示されます。
- description: '', →投票カテゴリの説明。こちらも投票画面に表示されます。\nを用いて改行できます。
groups: []以下はこのカテゴリに含める団体を書く。Group(),で一つのまとまり。
- id: '', →投票先のID。　2025年では教室番号を指定しています。
- name: '', →投票先の名前。　ここで設定した名前が投票画面に表示されます。
- description: '', →投票先の説明。　あまり長いものにしないことを推奨します。\mを用いて改行できます。
- imagePath: '', →投票先の画像。画像パスを変えるときは、assets/以下に配置した上でここに相対パスを入力、pubspec.yamlに追記したうえでflutter pub getを刷る必要があるため、パス自体の変更は非推奨。同じ教室番号は同じ名前の画像ファイルで差し替え。100MB未満、jpgファイル。
- floor: <int>, →その団体が属するフロアを「半角数字で」入力。ステージ団体は4を指定。
詳しくは、メール【mamouna.inori@outlook.jp】まで。
不要な教室は、/*と*/で挟むことでコメントアウトできます。
*/
final List<VoteCategory> voteCategories = [
  VoteCategory(
    id: 'Shikon_award', // システム内部で使用するID
    name: '紫紺賞', // 表示名
    description: 'この文化祭を通じて、最も印象に残った団体を1つ選択してください。', // 説明文
    groups: [
      //ここからステージ団体
      Group(
        id: '01',
        name: 'ステージ団体A',
        description: '',
        imagePath: 'assets/Stage/Stage01.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '02',
        name: 'ステージ団体B',
        description: '',
        imagePath: 'assets/Stage/Stage02.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '03',
        name: 'ステージ団体C',
        description: '',
        imagePath: 'assets/Stage/Stage03.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '04',
        name: 'ステージ団体D',
        description: '',
        imagePath: 'assets/Stage/Stage04.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '05',
        name: 'ステージ団体E',
        description: '',
        imagePath: 'assets/Stage/Stage05.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '06',
        name: 'ステージ団体F',
        description: '',
        imagePath: 'assets/Stage/Stage06.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '07',
        name: 'ステージ団体G',
        description: '',
        imagePath: 'assets/Stage/Stage07.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '08',
        name: 'ステージ団体H',
        description: '',
        imagePath: 'assets/Stage/Stage08.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      /*
      Group(
        id: '09',
        name: 'バンドA',
        description: '',
        imagePath: 'assets/Stage/Band01.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '10',
        name: 'バンドB',
        description: '',
        imagePath: 'assets/Stage/Band02.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '11',
        name: 'バンドC',
        description: '',
        imagePath: 'assets/Stage/Band03.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '12',
        name: 'バンドD',
        description: '',
        imagePath: 'assets/Stage/Band04.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '13',
        name: 'バンドE',
        description: '',
        imagePath: 'assets/Stage/Band05.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '14',
        name: 'バンドF',
        description: '',
        imagePath: 'assets/Stage/Band06.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '15',
        name: 'パフォA',
        description: '',
        imagePath: 'assets/Stage/Performance01.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '16',
        name: 'パフォB',
        description: '',
        imagePath: 'assets/Stage/Performance02.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '17',
        name: 'パフォC',
        description: '',
        imagePath: 'assets/Stage/Performance03.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '16',
        name: 'パフォD',
        description: '',
        imagePath: 'assets/Stage/Performance04.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '17',
        name: 'パフォE',
        description: '',
        imagePath: 'assets/Stage/Performance05.jpg', // 画像パス
        floor: 4, // フロア番号
      ),*/
      //ここまでステージ団体
      //ここから1階フロア
      Group(
        id: 'S101',
        name: 'S101教室',
        description: 'S棟1階 S101教室',
        imagePath: 'assets/First/S101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S102',
        name: 'S102教室',
        description: 'S棟1階 S102教室',
        imagePath: 'assets/First/S102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S103',
        name: 'S103教室',
        description: 'S棟1階 S103教室',
        imagePath: 'assets/First/S103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S104',
        name: 'S104教室',
        description: 'S棟1階 S104教室',
        imagePath: 'assets/First/S104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S101',
        name: 'S105教室',
        description: 'S棟1階 S105教室',
        imagePath: 'assets/First/S105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N101',
        name: 'N101教室',
        description: 'N棟1階 N101教室',
        imagePath: 'assets/First/N101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N102',
        name: 'N102教室',
        description: 'N棟1階 N102教室',
        imagePath: 'assets/First/N102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N103',
        name: 'N103教室',
        description: 'N棟1階 N103教室',
        imagePath: 'assets/First/N103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N104',
        name: 'N104教室',
        description: 'N棟1階 N104教室',
        imagePath: 'assets/First/N104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N105',
        name: 'N105教室',
        description: 'N棟1階 N105教室',
        imagePath: 'assets/First/N105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'T101',
        name: 'T101教室',
        description: 'N棟1階 T101教室(特別教室1)',
        imagePath: 'assets/First/T101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'T102',
        name: 'T102教室',
        description: 'N棟1階 T102教室(特別教室2)',
        imagePath: 'assets/First/T102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Music_Room',
        name: '音楽室',
        description: 'S棟1階 音楽室',
        imagePath: 'assets/First/Music_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Technology_Room',
        name: '技術室',
        description: 'S棟1階 技術室',
        imagePath: 'assets/First/Technology_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Art_Room_1',
        name: '美術室1',
        description: 'S棟1階 美術室1',
        imagePath: 'assets/First/Art_Room_1.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Art_Room_2',
        name: '美術室2',
        description: 'S棟1階 美術室2',
        imagePath: 'assets/First/Art_Room_2.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Hifuku_Room',
        name: '家庭科被服室',
        description: 'S棟1階 家庭科被服室',
        imagePath: 'assets/First/Hifuku_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Chori_Room',
        name: '家庭科調理室',
        description: 'S棟1階 家庭科調理室',
        imagePath: 'assets/First/Chori_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      //ここまで1階フロア
      //ここから2階フロア
      Group(
        id: 'S201',
        name: 'S201教室',
        description: 'S棟2階 S201教室',
        imagePath: 'assets/Second/S201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S202',
        name: 'S202教室',
        description: 'S棟2階 S202教室',
        imagePath: 'assets/Second/S202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S203',
        name: 'S203教室',
        description: 'S棟2階 S203教室',
        imagePath: 'assets/Second/S203.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S204',
        name: 'S204教室',
        description: 'S棟2階 S204教室',
        imagePath: 'assets/Second/S204.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S205',
        name: 'S205教室',
        description: 'S棟2階 S205教室',
        imagePath: 'assets/Second/S205.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S206',
        name: 'S206教室',
        description: 'S棟2階 S206教室',
        imagePath: 'assets/Second/S206.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S207',
        name: 'S207教室',
        description: 'S棟2階 S207教室',
        imagePath: 'assets/Second/S207.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N201',
        name: 'N201教室',
        description: 'N棟2階 S201教室',
        imagePath: 'assets/Second/N201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N202',
        name: 'N202教室',
        description: 'N棟2階 S202教室',
        imagePath: 'assets/Second/N202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N203',
        name: 'N203教室',
        description: 'N棟2階 S203教室',
        imagePath: 'assets/Second/N203.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N204',
        name: 'N204教室',
        description: 'N棟2階 S204教室',
        imagePath: 'assets/Second/N204.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N205',
        name: 'N205教室',
        description: 'N棟2階 S205教室',
        imagePath: 'assets/Second/N205.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'T201',
        name: 'T201教室',
        description: 'S棟2階 T201教室(特別教室3)',
        imagePath: 'assets/Second/T201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'T202',
        name: 'T202教室',
        description: 'N棟2階 T202教室(特別教室4)',
        imagePath: 'assets/Second/T202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'Computer_Room_1',
        name: 'コンピュータ教室1',
        description: 'S棟2階 コンピュータ教室1',
        imagePath: 'assets/Second/Computer_Room_1.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'Computer_Room_2',
        name: 'コンピュータ教室2',
        description: 'S棟2階 コンピュータ教室2',
        imagePath: 'assets/Second/Computer_Room_2.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'CALL_1',
        name: 'CALL教室1',
        description: 'S棟2階 CALL教室1',
        imagePath: 'assets/Second/CALL_1.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'CALL_2',
        name: 'CALL教室2',
        description: 'S棟2階 CALL教室2',
        imagePath: 'assets/Second/CALL_2.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'lib',
        name: '図書館',
        description: '2階 図書館',
        imagePath: 'assets/Second/lib.jpg',
        floor: 2,
      ),
      //ここまで2階フロア
      //ここから3階フロア
      Group(
        id: 'S301',
        name: 'S301教室',
        description: 'S棟3階 S301教室',
        imagePath: 'assets/Third/S301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S302',
        name: 'S302教室',
        description: 'S棟3階 S302教室',
        imagePath: 'assets/Third/S302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S303',
        name: 'S303教室',
        description: 'S棟3階 S303教室',
        imagePath: 'assets/Third/S303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S303',
        name: 'S303教室',
        description: 'S棟3階 S303教室',
        imagePath: 'assets/Third/S303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S304',
        name: 'S304教室',
        description: 'S棟3階 S304教室',
        imagePath: 'assets/Third/S304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S305',
        name: 'S305教室',
        description: 'S棟3階 S305教室',
        imagePath: 'assets/Third/S305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S306',
        name: 'S306教室',
        description: 'S棟3階 S306教室',
        imagePath: 'assets/Third/S306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S307',
        name: 'S307教室',
        description: 'S棟3階 S307教室',
        imagePath: 'assets/Third/S307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N301',
        name: 'N301教室',
        description: 'N棟3階 N301教室',
        imagePath: 'assets/Third/N301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N302',
        name: 'N302教室',
        description: 'N棟3階 N302教室',
        imagePath: 'assets/Third/N302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N303',
        name: 'N303教室',
        description: 'N棟3階 N303教室',
        imagePath: 'assets/Third/N303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N304',
        name: 'N304教室',
        description: 'N棟3階 N304教室',
        imagePath: 'assets/Third/N304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N305',
        name: 'N305教室',
        description: 'N棟3階 N305教室',
        imagePath: 'assets/Third/N305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N306',
        name: 'N306教室',
        description: 'N棟3階 N306教室',
        imagePath: 'assets/Third/N306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N307',
        name: 'N307教室',
        description: 'N棟3階 N307教室',
        imagePath: 'assets/Third/N307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      //特小1～3を別々に扱うコード
      /*Group(
        id: 'T301',
        name: 'T301教室',
        description: 'S棟3階 T301教室(特別小教室1)',
        imagePath: 'assets/Third/T301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T302',
        name: 'T302教室',
        description: 'S棟3階 T302教室(特別小教室2)',
        imagePath: 'assets/Third/T302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T303',
        name: 'T303教室',
        description: 'S棟3階 T303教室(特別小教室3)',
        imagePath: 'assets/Third/T303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      */
      //特小1～3をまとめて扱うコード
      Group(
        id: 'Tokusho_1_2_3',
        name: 'T301・T302・T303教室',
        description: 'S棟3階 T301教室(特別小教室1)\nS棟3階 T302教室(特別小教室2)\nS棟3階(特別小教室3)',
        imagePath: 'assets/Third/Tokusho_1_2_3.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T304',
        name: 'T304教室',
        description: 'S棟3階 T304教室(特別教室5)',
        imagePath: 'assets/Third/T304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Tokusho_4_5',
        name: 'T305・T306教室',
        description: 'N棟3階 T305教室(特別小教室4)\nN棟3階 T306教室(特別小教室5)',
        imagePath: 'assets/Third/Tokusho_4_5.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T307',
        name: 'T307教室',
        description: 'N棟3階 T307教室(特別小教室6)',
        imagePath: 'assets/Third/T307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T308',
        name: 'T308教室',
        description: 'N棟3階 T308教室(特別小教室7)',
        imagePath: 'assets/Third/T308.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Seibutsu_Experiment',
        name: '生物実験室',
        description: 'S棟3階 生物実験室',
        imagePath: 'assets/Third/Seibutsu_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Kyotsu_Experiment',
        name: '理科共通実験室',
        description: 'S棟3階 理科共通実験室',
        imagePath: 'assets/Third/Kyotsu_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Kagaku_Experiment',
        name: '化学実験室',
        description: 'S棟3階 化学実験室',
        imagePath: 'assets/Third/Kagaku_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Butsuri_Experiment',
        name: '物理実験室',
        description: 'S棟3階 物理実験室',
        imagePath: 'assets/Third/Butsuri_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Saho',
        name: '作法室',
        description: 'S棟3階 作法室',
        imagePath: 'assets/Third/Saho.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Daikaigi',
        name: '大会議室',
        description: 'S棟3階 大会議室',
        imagePath: 'assets/Third/Daikaigi.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      //ここまで3階フロア

      // 他の団体を追加...
    ],
  ),
  //ここまで紫紺賞
  VoteCategory(
    id: 'Kyoshitsu_Tenji', // システム内部で使用するID
    name: '教室展示賞', // 表示名
    description: '教室展示のなかで、「最後にもう一回行くならこれだ！」という展示を選んでください。', // 説明文
    groups: [
      //ここから1階フロア
      Group(
        id: 'S101',
        name: 'S101教室',
        description: 'S棟1階 S101教室',
        imagePath: 'assets/First/S101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S102',
        name: 'S102教室',
        description: 'S棟1階 S102教室',
        imagePath: 'assets/First/S102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S103',
        name: 'S103教室',
        description: 'S棟1階 S103教室',
        imagePath: 'assets/First/S103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S104',
        name: 'S104教室',
        description: 'S棟1階 S104教室',
        imagePath: 'assets/First/S104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S101',
        name: 'S105教室',
        description: 'S棟1階 S105教室',
        imagePath: 'assets/First/S105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N101',
        name: 'N101教室',
        description: 'N棟1階 N101教室',
        imagePath: 'assets/First/N101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N102',
        name: 'N102教室',
        description: 'N棟1階 N102教室',
        imagePath: 'assets/First/N102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N103',
        name: 'N103教室',
        description: 'N棟1階 N103教室',
        imagePath: 'assets/First/N103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N104',
        name: 'N104教室',
        description: 'N棟1階 N104教室',
        imagePath: 'assets/First/N104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N105',
        name: 'N105教室',
        description: 'N棟1階 N105教室',
        imagePath: 'assets/First/N105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'T101',
        name: 'T101教室',
        description: 'N棟1階 T101教室(特別教室1)',
        imagePath: 'assets/First/T101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'T102',
        name: 'T102教室',
        description: 'N棟1階 T102教室(特別教室2)',
        imagePath: 'assets/First/T102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Music_Room',
        name: '音楽室',
        description: 'S棟1階 音楽室',
        imagePath: 'assets/First/Music_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Technology_Room',
        name: '技術室',
        description: 'S棟1階 技術室',
        imagePath: 'assets/First/Technology_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Art_Room_1',
        name: '美術室1',
        description: 'S棟1階 美術室1',
        imagePath: 'assets/First/Art_Room_1.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Art_Room_2',
        name: '美術室2',
        description: 'S棟1階 美術室2',
        imagePath: 'assets/First/Art_Room_2.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Hifuku_Room',
        name: '家庭科被服室',
        description: 'S棟1階 家庭科被服室',
        imagePath: 'assets/First/Hifuku_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Chori_Room',
        name: '家庭科調理室',
        description: 'S棟1階 家庭科調理室',
        imagePath: 'assets/First/Chori_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      //ここまで1階フロア
      //ここから2階フロア
      Group(
        id: 'S201',
        name: 'S201教室',
        description: 'S棟2階 S201教室',
        imagePath: 'assets/Second/S201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S202',
        name: 'S202教室',
        description: 'S棟2階 S202教室',
        imagePath: 'assets/Second/S202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S203',
        name: 'S203教室',
        description: 'S棟2階 S203教室',
        imagePath: 'assets/Second/S203.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S204',
        name: 'S204教室',
        description: 'S棟2階 S204教室',
        imagePath: 'assets/Second/S204.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S205',
        name: 'S205教室',
        description: 'S棟2階 S205教室',
        imagePath: 'assets/Second/S205.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S206',
        name: 'S206教室',
        description: 'S棟2階 S206教室',
        imagePath: 'assets/Second/S206.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S207',
        name: 'S207教室',
        description: 'S棟2階 S207教室',
        imagePath: 'assets/Second/S207.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N201',
        name: 'N201教室',
        description: 'N棟2階 S201教室',
        imagePath: 'assets/Second/N201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N202',
        name: 'N202教室',
        description: 'N棟2階 S202教室',
        imagePath: 'assets/Second/N202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N203',
        name: 'N203教室',
        description: 'N棟2階 S203教室',
        imagePath: 'assets/Second/N203.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N204',
        name: 'N204教室',
        description: 'N棟2階 S204教室',
        imagePath: 'assets/Second/N204.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N205',
        name: 'N205教室',
        description: 'N棟2階 S205教室',
        imagePath: 'assets/Second/N205.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'T201',
        name: 'T201教室',
        description: 'S棟2階 T201教室(特別教室3)',
        imagePath: 'assets/Second/T201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'T202',
        name: 'T202教室',
        description: 'N棟2階 T202教室(特別教室4)',
        imagePath: 'assets/Second/T202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'Computer_Room_1',
        name: 'コンピュータ教室1',
        description: 'S棟2階 コンピュータ教室1',
        imagePath: 'assets/Second/Computer_Room_1.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'Computer_Room_2',
        name: 'コンピュータ教室2',
        description: 'S棟2階 コンピュータ教室2',
        imagePath: 'assets/Second/Computer_Room_2.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'CALL_1',
        name: 'CALL教室1',
        description: 'S棟2階 CALL教室1',
        imagePath: 'assets/Second/CALL_1.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'CALL_2',
        name: 'CALL教室2',
        description: 'S棟2階 CALL教室2',
        imagePath: 'assets/Second/CALL_2.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'lib',
        name: '図書館',
        description: '2階 図書館',
        imagePath: 'assets/Second/lib.jpg',
        floor: 2,
      ),
      //ここまで2階フロア
      //ここから3階フロア
      Group(
        id: 'S301',
        name: 'S301教室',
        description: 'S棟3階 S301教室',
        imagePath: 'assets/Third/S301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S302',
        name: 'S302教室',
        description: 'S棟3階 S302教室',
        imagePath: 'assets/Third/S302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S303',
        name: 'S303教室',
        description: 'S棟3階 S303教室',
        imagePath: 'assets/Third/S303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S303',
        name: 'S303教室',
        description: 'S棟3階 S303教室',
        imagePath: 'assets/Third/S303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S304',
        name: 'S304教室',
        description: 'S棟3階 S304教室',
        imagePath: 'assets/Third/S304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S305',
        name: 'S305教室',
        description: 'S棟3階 S305教室',
        imagePath: 'assets/Third/S305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S306',
        name: 'S306教室',
        description: 'S棟3階 S306教室',
        imagePath: 'assets/Third/S306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S307',
        name: 'S307教室',
        description: 'S棟3階 S307教室',
        imagePath: 'assets/Third/S307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N301',
        name: 'N301教室',
        description: 'N棟3階 N301教室',
        imagePath: 'assets/Third/N301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N302',
        name: 'N302教室',
        description: 'N棟3階 N302教室',
        imagePath: 'assets/Third/N302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N303',
        name: 'N303教室',
        description: 'N棟3階 N303教室',
        imagePath: 'assets/Third/N303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N304',
        name: 'N304教室',
        description: 'N棟3階 N304教室',
        imagePath: 'assets/Third/N304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N305',
        name: 'N305教室',
        description: 'N棟3階 N305教室',
        imagePath: 'assets/Third/N305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N306',
        name: 'N306教室',
        description: 'N棟3階 N306教室',
        imagePath: 'assets/Third/N306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N307',
        name: 'N307教室',
        description: 'N棟3階 N307教室',
        imagePath: 'assets/Third/N307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      //特小1～3を別々に扱うコード
      /*Group(
        id: 'T301',
        name: 'T301教室',
        description: 'S棟3階 T301教室(特別小教室1)',
        imagePath: 'assets/Third/T301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T302',
        name: 'T302教室',
        description: 'S棟3階 T302教室(特別小教室2)',
        imagePath: 'assets/Third/T302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T303',
        name: 'T303教室',
        description: 'S棟3階 T303教室(特別小教室3)',
        imagePath: 'assets/Third/T303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      */
      //特小1～3をまとめて扱うコード
      Group(
        id: 'Tokusho_1_2_3',
        name: 'T301・T302・T303教室',
        description: 'S棟3階 T301教室(特別小教室1)\nS棟3階 T302教室(特別小教室2)\nS棟3階(特別小教室3)',
        imagePath: 'assets/Third/Tokusho_1_2_3.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T304',
        name: 'T304教室',
        description: 'S棟3階 T304教室(特別教室5)',
        imagePath: 'assets/Third/T304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Tokusho_4_5',
        name: 'T305・T306教室',
        description: 'N棟3階 T305教室(特別小教室4)\nN棟3階 T306教室(特別小教室5)',
        imagePath: 'assets/Third/Tokusho_4_5.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T307',
        name: 'T307教室',
        description: 'N棟3階 T307教室(特別小教室6)',
        imagePath: 'assets/Third/T307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T308',
        name: 'T308教室',
        description: 'N棟3階 T308教室(特別小教室7)',
        imagePath: 'assets/Third/T308.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Seibutsu_Experiment',
        name: '生物実験室',
        description: 'S棟3階 生物実験室',
        imagePath: 'assets/Third/Seibutsu_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Kyotsu_Experiment',
        name: '理科共通実験室',
        description: 'S棟3階 理科共通実験室',
        imagePath: 'assets/Third/Kyotsu_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Kagaku_Experiment',
        name: '化学実験室',
        description: 'S棟3階 化学実験室',
        imagePath: 'assets/Third/Kagaku_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Butsuri_Experiment',
        name: '物理実験室',
        description: 'S棟3階 物理実験室',
        imagePath: 'assets/Third/Butsuri_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Saho',
        name: '作法室',
        description: 'S棟3階 作法室',
        imagePath: 'assets/Third/Saho.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Daikaigi',
        name: '大会議室',
        description: 'S棟3階 大会議室',
        imagePath: 'assets/Third/Daikaigi.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      //ここまで3階フロア
    ],
  ),
  VoteCategory(
    id: 'Gakunen_Tenji',
    name: '学年展示賞',
    description: '学年展示のなかで、「最後にもう一回行くならこれだ！」という学年を選んでください。',
    groups: [
      Group(
        id: 'S305',
        name: '中学1年',
        description: 'S棟3階 S305教室(この教室番号はダミーです。)',
        imagePath: 'assets/Third/S305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S306',
        name: '中学2年',
        description: 'S棟3階 S306教室',
        imagePath: 'assets/Third/S306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S307',
        name: '中学3年',
        description: 'S棟3階 S307教室',
        imagePath: 'assets/Third/S307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
    ],
  ),
  VoteCategory(
    id: 'Kyoshitsu_Moyoshi',
    name: '教室催し物賞',
    description: '教室催し物のなかで、「最後にもう一回行くならこれだ！」という学年を選んでください。',
    groups: [
      //ここから1階フロア
      Group(
        id: 'S101',
        name: 'S101教室',
        description: 'S棟1階 S101教室',
        imagePath: 'assets/First/S101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S102',
        name: 'S102教室',
        description: 'S棟1階 S102教室',
        imagePath: 'assets/First/S102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S103',
        name: 'S103教室',
        description: 'S棟1階 S103教室',
        imagePath: 'assets/First/S103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S104',
        name: 'S104教室',
        description: 'S棟1階 S104教室',
        imagePath: 'assets/First/S104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'S101',
        name: 'S105教室',
        description: 'S棟1階 S105教室',
        imagePath: 'assets/First/S105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N101',
        name: 'N101教室',
        description: 'N棟1階 N101教室',
        imagePath: 'assets/First/N101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N102',
        name: 'N102教室',
        description: 'N棟1階 N102教室',
        imagePath: 'assets/First/N102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N103',
        name: 'N103教室',
        description: 'N棟1階 N103教室',
        imagePath: 'assets/First/N103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N104',
        name: 'N104教室',
        description: 'N棟1階 N104教室',
        imagePath: 'assets/First/N104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N105',
        name: 'N105教室',
        description: 'N棟1階 N105教室',
        imagePath: 'assets/First/N105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'T101',
        name: 'T101教室',
        description: 'N棟1階 T101教室(特別教室1)',
        imagePath: 'assets/First/T101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'T102',
        name: 'T102教室',
        description: 'N棟1階 T102教室(特別教室2)',
        imagePath: 'assets/First/T102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Music_Room',
        name: '音楽室',
        description: 'S棟1階 音楽室',
        imagePath: 'assets/First/Music_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Technology_Room',
        name: '技術室',
        description: 'S棟1階 技術室',
        imagePath: 'assets/First/Technology_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Art_Room_1',
        name: '美術室1',
        description: 'S棟1階 美術室1',
        imagePath: 'assets/First/Art_Room_1.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Art_Room_2',
        name: '美術室2',
        description: 'S棟1階 美術室2',
        imagePath: 'assets/First/Art_Room_2.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Hifuku_Room',
        name: '家庭科被服室',
        description: 'S棟1階 家庭科被服室',
        imagePath: 'assets/First/Hifuku_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'Chori_Room',
        name: '家庭科調理室',
        description: 'S棟1階 家庭科調理室',
        imagePath: 'assets/First/Chori_Room.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      //ここまで1階フロア
      //ここから2階フロア
      Group(
        id: 'S201',
        name: 'S201教室',
        description: 'S棟2階 S201教室',
        imagePath: 'assets/Second/S201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S202',
        name: 'S202教室',
        description: 'S棟2階 S202教室',
        imagePath: 'assets/Second/S202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S203',
        name: 'S203教室',
        description: 'S棟2階 S203教室',
        imagePath: 'assets/Second/S203.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S204',
        name: 'S204教室',
        description: 'S棟2階 S204教室',
        imagePath: 'assets/Second/S204.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S205',
        name: 'S205教室',
        description: 'S棟2階 S205教室',
        imagePath: 'assets/Second/S205.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S206',
        name: 'S206教室',
        description: 'S棟2階 S206教室',
        imagePath: 'assets/Second/S206.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'S207',
        name: 'S207教室',
        description: 'S棟2階 S207教室',
        imagePath: 'assets/Second/S207.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N201',
        name: 'N201教室',
        description: 'N棟2階 S201教室',
        imagePath: 'assets/Second/N201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N202',
        name: 'N202教室',
        description: 'N棟2階 S202教室',
        imagePath: 'assets/Second/N202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N203',
        name: 'N203教室',
        description: 'N棟2階 S203教室',
        imagePath: 'assets/Second/N203.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N204',
        name: 'N204教室',
        description: 'N棟2階 S204教室',
        imagePath: 'assets/Second/N204.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'N205',
        name: 'N205教室',
        description: 'N棟2階 S205教室',
        imagePath: 'assets/Second/N205.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'T201',
        name: 'T201教室',
        description: 'S棟2階 T201教室(特別教室3)',
        imagePath: 'assets/Second/T201.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'T202',
        name: 'T202教室',
        description: 'N棟2階 T202教室(特別教室4)',
        imagePath: 'assets/Second/T202.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'Computer_Room_1',
        name: 'コンピュータ教室1',
        description: 'S棟2階 コンピュータ教室1',
        imagePath: 'assets/Second/Computer_Room_1.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'Computer_Room_2',
        name: 'コンピュータ教室2',
        description: 'S棟2階 コンピュータ教室2',
        imagePath: 'assets/Second/Computer_Room_2.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'CALL_1',
        name: 'CALL教室1',
        description: 'S棟2階 CALL教室1',
        imagePath: 'assets/Second/CALL_1.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'CALL_2',
        name: 'CALL教室2',
        description: 'S棟2階 CALL教室2',
        imagePath: 'assets/Second/CALL_2.jpg', // 画像パス
        floor: 2, // フロア番号
      ),
      Group(
        id: 'lib',
        name: '図書館',
        description: '2階 図書館',
        imagePath: 'assets/Second/lib.jpg',
        floor: 2,
      ),
      //ここまで2階フロア
      //ここから3階フロア
      Group(
        id: 'S301',
        name: 'S301教室',
        description: 'S棟3階 S301教室',
        imagePath: 'assets/Third/S301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S302',
        name: 'S302教室',
        description: 'S棟3階 S302教室',
        imagePath: 'assets/Third/S302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S303',
        name: 'S303教室',
        description: 'S棟3階 S303教室',
        imagePath: 'assets/Third/S303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S303',
        name: 'S303教室',
        description: 'S棟3階 S303教室',
        imagePath: 'assets/Third/S303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S304',
        name: 'S304教室',
        description: 'S棟3階 S304教室',
        imagePath: 'assets/Third/S304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S305',
        name: 'S305教室',
        description: 'S棟3階 S305教室',
        imagePath: 'assets/Third/S305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S306',
        name: 'S306教室',
        description: 'S棟3階 S306教室',
        imagePath: 'assets/Third/S306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'S307',
        name: 'S307教室',
        description: 'S棟3階 S307教室',
        imagePath: 'assets/Third/S307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N301',
        name: 'N301教室',
        description: 'N棟3階 N301教室',
        imagePath: 'assets/Third/N301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N302',
        name: 'N302教室',
        description: 'N棟3階 N302教室',
        imagePath: 'assets/Third/N302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N303',
        name: 'N303教室',
        description: 'N棟3階 N303教室',
        imagePath: 'assets/Third/N303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N304',
        name: 'N304教室',
        description: 'N棟3階 N304教室',
        imagePath: 'assets/Third/N304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N305',
        name: 'N305教室',
        description: 'N棟3階 N305教室',
        imagePath: 'assets/Third/N305.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N306',
        name: 'N306教室',
        description: 'N棟3階 N306教室',
        imagePath: 'assets/Third/N306.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'N307',
        name: 'N307教室',
        description: 'N棟3階 N307教室',
        imagePath: 'assets/Third/N307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      //特小1～3を別々に扱うコード
      /*Group(
        id: 'T301',
        name: 'T301教室',
        description: 'S棟3階 T301教室(特別小教室1)',
        imagePath: 'assets/Third/T301.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T302',
        name: 'T302教室',
        description: 'S棟3階 T302教室(特別小教室2)',
        imagePath: 'assets/Third/T302.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T303',
        name: 'T303教室',
        description: 'S棟3階 T303教室(特別小教室3)',
        imagePath: 'assets/Third/T303.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      */
      //特小1～3をまとめて扱うコード
      Group(
        id: 'Tokusho_1_2_3',
        name: 'T301・T302・T303教室',
        description: 'S棟3階 T301教室(特別小教室1)\nS棟3階 T302教室(特別小教室2)\nS棟3階(特別小教室3)',
        imagePath: 'assets/Third/Tokusho_1_2_3.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T304',
        name: 'T304教室',
        description: 'S棟3階 T304教室(特別教室5)',
        imagePath: 'assets/Third/T304.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Tokusho_4_5',
        name: 'T305・T306教室',
        description: 'N棟3階 T305教室(特別小教室4)\nN棟3階 T306教室(特別小教室5)',
        imagePath: 'assets/Third/Tokusho_4_5.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T307',
        name: 'T307教室',
        description: 'N棟3階 T307教室(特別小教室6)',
        imagePath: 'assets/Third/T307.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'T308',
        name: 'T308教室',
        description: 'N棟3階 T308教室(特別小教室7)',
        imagePath: 'assets/Third/T308.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Seibutsu_Experiment',
        name: '生物実験室',
        description: 'S棟3階 生物実験室',
        imagePath: 'assets/Third/Seibutsu_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Kyotsu_Experiment',
        name: '理科共通実験室',
        description: 'S棟3階 理科共通実験室',
        imagePath: 'assets/Third/Kyotsu_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Kagaku_Experiment',
        name: '化学実験室',
        description: 'S棟3階 化学実験室',
        imagePath: 'assets/Third/Kagaku_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Butsuri_Experiment',
        name: '物理実験室',
        description: 'S棟3階 物理実験室',
        imagePath: 'assets/Third/Butsuri_Experiment.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Saho',
        name: '作法室',
        description: 'S棟3階 作法室',
        imagePath: 'assets/Third/Saho.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      Group(
        id: 'Daikaigi',
        name: '大会議室',
        description: 'S棟3階 大会議室',
        imagePath: 'assets/Third/Daikaigi.jpg', // 画像パス
        floor: 3, // フロア番号
      ),
      //ここまで3階フロア
    ],
  ),
  VoteCategory(
    id: 'Stage',
    name: '部活ステージ賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がった部活ステージを選んでください。',
    groups: [
      Group(
        id: '01',
        name: 'ステージ団体A',
        description: '',
        imagePath: 'assets/Stage/Stage01.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '02',
        name: 'ステージ団体B',
        description: '',
        imagePath: 'assets/Stage/Stage02.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '03',
        name: 'ステージ団体C',
        description: '',
        imagePath: 'assets/Stage/Stage03.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '04',
        name: 'ステージ団体D',
        description: '',
        imagePath: 'assets/Stage/Stage04.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '05',
        name: 'ステージ団体E',
        description: '',
        imagePath: 'assets/Stage/Stage05.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '06',
        name: 'ステージ団体F',
        description: '',
        imagePath: 'assets/Stage/Stage06.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '07',
        name: 'ステージ団体G',
        description: '',
        imagePath: 'assets/Stage/Stage07.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '08',
        name: 'ステージ団体H',
        description: '',
        imagePath: 'assets/Stage/Stage08.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
    ],
  ),
  VoteCategory(
    id: 'Band',
    name: 'バンド賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がったバンドを選んでください。',
    groups: [
      Group(
        id: '09',
        name: 'バンドA',
        description: '',
        imagePath: 'assets/Stage/Band01.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '10',
        name: 'バンドB',
        description: '',
        imagePath: 'assets/Stage/Band02.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '11',
        name: 'バンドC',
        description: '',
        imagePath: 'assets/Stage/Band03.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '12',
        name: 'バンドD',
        description: '',
        imagePath: 'assets/Stage/Band04.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '13',
        name: 'バンドE',
        description: '',
        imagePath: 'assets/Stage/Band05.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '14',
        name: 'バンドF',
        description: '',
        imagePath: 'assets/Stage/Band06.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
    ],
  ),
  VoteCategory(
    id: 'Roten',
    name: '露店賞',
    description: '露店の装飾が魅力的で接客における笑顔が最も素敵であった露店を選んでください。',
    groups: [
      Group(
        id: 'N101',
        name: 'N101教室',
        description: 'N棟1階 N101教室(教室番号はダミーです。)',
        imagePath: 'assets/First/N101.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N102',
        name: 'N102教室',
        description: 'N棟1階 N102教室',
        imagePath: 'assets/First/N102.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N103',
        name: 'N103教室',
        description: 'N棟1階 N103教室',
        imagePath: 'assets/First/N103.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N104',
        name: 'N104教室',
        description: 'N棟1階 N104教室',
        imagePath: 'assets/First/N104.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'N105',
        name: 'N105教室',
        description: 'N棟1階 N105教室',
        imagePath: 'assets/First/N105.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
    ],
  ),
  VoteCategory(
    id: 'Performance',
    name: 'パフォーマンス賞',
    description: '「もう一度行きたい、見たい！」と思える最も盛り上がったパフォーマンス団体を選んでください。',
    groups: [
      Group(
        id: '15',
        name: 'パフォA',
        description: '',
        imagePath: 'assets/Stage/Performance01.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '16',
        name: 'パフォB',
        description: '',
        imagePath: 'assets/Stage/Performance02.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '17',
        name: 'パフォC',
        description: '',
        imagePath: 'assets/Stage/Performance03.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '16',
        name: 'パフォD',
        description: '',
        imagePath: 'assets/Stage/Performance04.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
      Group(
        id: '17',
        name: 'パフォE',
        description: '',
        imagePath: 'assets/Stage/Performance05.jpg', // 画像パス
        floor: 4, // フロア番号
      ),
    ],
  ),
  // 他のカテゴリーを追加...
];
