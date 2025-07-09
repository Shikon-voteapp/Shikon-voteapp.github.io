import 'dart:convert';
import 'package:shikon_voteapp/models/group.dart' hide VoteCategory;
import 'package:shikon_voteapp/models/vote_category.dart';
import 'package:shikon_voteapp/config/vote_options.dart';

// 投票設定全体を管理するクラス
class VoteConfig {
  final VotingPeriodConfig votingPeriod;
  final List<VoteCategory> categories;
  final List<Group> groups;
  final Map<GroupCategory, String> categoryNames;

  VoteConfig({
    required this.votingPeriod,
    required this.categories,
    required this.groups,
    required this.categoryNames,
  });

  // デフォルト設定を作成
  factory VoteConfig.createDefault() {
    return VoteConfig(
      votingPeriod: defaultVotingPeriod,
      categories:
          voteCategories.map((c) => VoteCategory.fromVoteCategory(c)).toList(),
      groups: allGroups,
      categoryNames: groupCategoryNames,
    );
  }

  // JSONシリアライゼーション
  Map<String, dynamic> toJson() {
    return {
      'version': '1.0',
      'votingPeriod': votingPeriod.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
      'categoryNames': categoryNames.map(
        (key, value) => MapEntry(key.toString().split('.').last, value),
      ),
    };
  }

  // JSONから作成
  factory VoteConfig.fromJson(Map<String, dynamic> json) {
    // カテゴリ名のマッピングを復元
    Map<GroupCategory, String> categoryNames = {};
    if (json['categoryNames'] != null) {
      (json['categoryNames'] as Map<String, dynamic>).forEach((key, value) {
        GroupCategory? category = GroupCategory.values.firstWhere(
          (e) => e.toString().split('.').last == key,
          orElse: () => GroupCategory.other,
        );
        categoryNames[category] = value;
      });
    }

    // まず団体をロード
    List<Group> groups =
        (json['groups'] as List).map((g) => Group.fromJson(g)).toList();

    return VoteConfig(
      votingPeriod: VotingPeriodConfig.fromJson(json['votingPeriod']),
      categories:
          (json['categories'] as List)
              .map((c) => VoteCategory.fromJson(c, groups))
              .toList(),
      groups: groups,
      categoryNames: categoryNames,
    );
  }

  // JSON文字列に変換
  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  // JSON文字列から作成
  factory VoteConfig.fromJsonString(String jsonString) {
    return VoteConfig.fromJson(json.decode(jsonString));
  }

  // コピーを作成
  VoteConfig copyWith({
    VotingPeriodConfig? votingPeriod,
    List<VoteCategory>? categories,
    List<Group>? groups,
    Map<GroupCategory, String>? categoryNames,
  }) {
    return VoteConfig(
      votingPeriod: votingPeriod ?? this.votingPeriod,
      categories: categories ?? this.categories,
      groups: groups ?? this.groups,
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }

  // 設定の検証
  bool validate() {
    // 基本的な検証
    if (categories.isEmpty) return false;
    if (groups.isEmpty) return false;
    if (votingPeriod.startDate.isAfter(votingPeriod.endDate)) return false;

    // カテゴリと団体の整合性チェック
    for (var category in categories) {
      if (category.groups.isEmpty) return false;
    }

    return true;
  }
}
