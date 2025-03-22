// config/vote_options.dart
// 文化祭投票アプリの投票先設定ファイル
// ※このファイルのみ編集してください

// 投票カテゴリーのリスト
import 'package:shikon_voteapp/models/group.dart';

final List<VoteCategory> voteCategories = [
  VoteCategory(
    id: 'Shikon_award', // システム内部で使用するID
    name: '紫紺賞', // 表示名
    description: '最も印象に残った団体に投票してください', // 説明文
    groups: [
      Group(
        id: '01',
        name: '団体A',
        description: '※これはテスト用の団体名です。',
        imagePath: '../assets/images/group.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: '02',
        name: '団体B',
        description: 'ここに説明文',
        imagePath: '../assets/images/groupb.jpg',
        floor: 1,
      ),
      Group(
        id: '03',
        name: '団体C',
        description: 'ここに説明文',
        imagePath: '../assets/images/groupc.jpg',
        floor: 1,
      ),
      Group(
        id: '04',
        name: '団体D',
        description: 'ここに説明文',
        imagePath: '../assets/images/groupd.jpg',
        floor: 1,
      ),
      Group(
        id: '05',
        name: '団体D',
        description: '複数階設定できます',
        imagePath: '../assets/images/groupd.jpg',
        floor: 2,
      ),
      // 他の団体を追加...
    ],
  ),
  VoteCategory(
    id: 'gakunen_award', // システム内部で使用するID
    name: '学年展示賞', // 表示名
    description: '最も印象に残った団体に投票してください', // 説明文
    groups: [
      Group(
        id: 'group_jh1',
        name: '1年',
        description: 'ここに説明文',
        imagePath: '../assets/images/groupd.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'group_jh2',
        name: '2年',
        description: 'ここに説明文',
        imagePath: '../assets/images/groupb.jpg',
        floor: 1,
      ),
      // 他の団体を追加...
    ],
  ), // 他のカテゴリーを追加...
];
