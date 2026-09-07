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
final DateTime dataUpdateDate = DateTime(2026, 9, 8, 6, 16, 0); // 2025年1月15日 12:00

// デフォルトの投票期間設定
final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig(
  startDate: DateTime(2026, 8, 28, 0, 0), // 2026年8月28日 0:00
  endDate: DateTime(2026, 8, 29, 0, 0), // 2026年8月29日 0:00
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
    id: 'new_639235168757006575',
    name: 'Ⅲ-D',
    groupName: '３Death',
    description: '''廃校に・・・''',
    imagePath: 'assets/ⅠA.jpeg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'new_639235171275118219',
    name: 'Ⅲ-E',
    groupName: '客恋募',
    description: '''「私とかくれんぼ・・・''',
    imagePath: 'assets/ⅠB.jpg',
    floor: 0,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'new_639235172616773010',
    name: 'Ⅰ-B',
    groupName: 'B女とBスト',
    description: '''舞台は森の中の館・・・''',
    imagePath: 'assets/ⅠF.jpg',
    floor: 1,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'new_639235173048410287',
    name: '班会',
    groupName: '班会',
    description: '''班の活動報告''',
    imagePath: 'assets/youth.PNG',
    floor: 2,
    categories: [GroupCategory.Tenji],
  ),
  Group(
    id: 'new_639235173650287192',
    name: '吹奏楽班',
    groupName: '吹奏楽班',
    description: '''誰もが楽しめる・・・''',
    imagePath: 'assets/化学部.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'new_639235174224863239',
    name: 'ダンス部',
    groupName: 'ダンス部',
    description: '''総勢５４名の部員で踊ります・・・''',
    imagePath: 'assets/ⅠG.jpg',
    floor: 4,
    categories: [GroupCategory.Stage],
  ),
  Group(
    id: 'new_639235174708836927',
    name: 'ぐらふぃてぃ',
    groupName: 'ぐらふぃてぃ',
    description: '''高３の４人組によるナイスな・・・''',
    imagePath: 'assets/ⅢA.jpg',
    floor: 0,
    categories: [GroupCategory.Band],
  ),
  Group(
    id: 'new_639235175342128982',
    name: 'サッカー部',
    groupName: 'サッカー部',
    description: '''恵まれた環境のもと・・・''',
    imagePath: 'assets/ⅠF.jpg',
    floor: 0,
    categories: [GroupCategory.other],
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
