// config/vote_options.dart
// 文化祭投票アプリの投票先設定ファイル
// ※このファイルのみ編集してください

// 投票カテゴリーのリスト
import 'package:shikon_voteapp/models/group.dart';

final List<VoteCategory> voteCategories = [
  VoteCategory(
    id: 'purple_award', // システム内部で使用するID
    name: '紫紺賞', // 表示名
    description: '最も印象に残った団体に投票してください', // 説明文
    groups: [
      Group(
        id: 'group_a1',
        name: '団体A',
        description: 'ここに説明文',
        imagePath: 'assets/images/group_a.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'group_b1',
        name: '団体B',
        description: 'ここに説明文',
        imagePath: 'assets/images/group_b.jpg',
        floor: 1,
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
        imagePath: 'assets/images/group_d.jpg', // 画像パス
        floor: 1, // フロア番号
      ),
      Group(
        id: 'group_jh2',
        name: '2年',
        description: 'ここに説明文',
        imagePath: 'assets/images/group_e.jpg',
        floor: 1,
      ),
      // 他の団体を追加...
    ],
  ), // 他のカテゴリーを追加...
];
