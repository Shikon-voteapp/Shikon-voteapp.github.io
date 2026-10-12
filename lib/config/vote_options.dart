import 'package:shikon_voteapp/models/group.dart' hide VoteCategory;
import 'package:shikon_voteapp/models/vote_category.dart';

// Runtime data in this file is limited to cloud-loaded state.

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

  VotingPeriodConfig copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? maintenanceEnabled,
    int? maintenanceStartHour,
    int? maintenanceStartMinute,
    int? maintenanceEndHour,
    int? maintenanceEndMinute,
  }) {
    return VotingPeriodConfig(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
      maintenanceStartHour: maintenanceStartHour ?? this.maintenanceStartHour,
      maintenanceStartMinute:
          maintenanceStartMinute ?? this.maintenanceStartMinute,
      maintenanceEndHour: maintenanceEndHour ?? this.maintenanceEndHour,
      maintenanceEndMinute: maintenanceEndMinute ?? this.maintenanceEndMinute,
    );
  }
}

// Cloud Firestore から起動時にロードされる設定。
late VotingPeriodConfig defaultVotingPeriod;

// 表示名も Firestore の app_config/category_names からロードする。
final Map<GroupCategory, String> groupCategoryNames = <GroupCategory, String>{};

// 投票対象データは Firestore の groups / vote_categories からロードする。
final List<Group> allGroups = <Group>[];
final List<VoteCategory> voteCategories = <VoteCategory>[];
