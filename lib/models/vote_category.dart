// models/vote_category.dart
import 'group.dart';

class VoteCategory {
  final String id;
  final String name;
  final String description;
  final List<Group> groups;
  final List<GroupCategory>? _eligibleCategories;
  final bool canSkip;
  final String? helpUrl;
  final String? shortHelpText;

  VoteCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.groups,
    List<GroupCategory>? eligibleCategories,
    this.canSkip = false,
    this.helpUrl,
    this.shortHelpText,
  }) : _eligibleCategories = eligibleCategories;

  List<GroupCategory>? get eligibleCategories => _eligibleCategories;

  List<Group> getFilteredGroups() {
    if (_eligibleCategories == null || _eligibleCategories!.isEmpty)
      return groups;
    return groups
        .where((group) => _eligibleCategories!.any(group.hasCategory))
        .toList();
  }

  // 既存のVoteCategoryから新しいVoteCategoryを作成
  factory VoteCategory.fromVoteCategory(dynamic oldCategory) {
    return VoteCategory(
      id: oldCategory.id,
      name: oldCategory.name,
      description: oldCategory.description,
      groups: oldCategory.groups,
      canSkip: oldCategory.canSkip,
      helpUrl: oldCategory.helpUrl,
      shortHelpText: oldCategory.shortHelpText,
      eligibleCategories: oldCategory.eligibleCategories,
    );
  }

  // JSONシリアライゼーション
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'groups': groups.map((g) => g.id).toList(), // グループIDのみ保存
      'canSkip': canSkip,
      'helpUrl': helpUrl,
      'shortHelpText': shortHelpText,
      'eligibleCategories':
          _eligibleCategories?.map((category) => category.name).toList(),
    };
  }

  // JSONデシリアライゼーション
  factory VoteCategory.fromJson(
    Map<String, dynamic> json,
    List<Group> allGroups,
  ) {
    List<String> groupIds = List<String>.from(json['groups'] ?? []);
    List<Group> categoryGroups =
        allGroups.where((group) => groupIds.contains(group.id)).toList();

    return VoteCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      groups: categoryGroups,
      canSkip: json['canSkip'] ?? false,
      helpUrl: json['helpUrl'],
      shortHelpText: json['shortHelpText'],
      eligibleCategories:
          (json['eligibleCategories'] as List?)
              ?.map(
                (value) => GroupCategory.values.firstWhere(
                  (category) => category.name == value,
                  orElse: () => GroupCategory.other,
                ),
              )
              .toList(),
    );
  }

  // コピーを作成
  VoteCategory copyWith({
    String? id,
    String? name,
    String? description,
    List<Group>? groups,
    bool? canSkip,
    String? helpUrl,
    String? shortHelpText,
    List<GroupCategory>? eligibleCategories,
  }) {
    return VoteCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groups: groups ?? this.groups,
      canSkip: canSkip ?? this.canSkip,
      helpUrl: helpUrl ?? this.helpUrl,
      shortHelpText: shortHelpText ?? this.shortHelpText,
      eligibleCategories: eligibleCategories ?? _eligibleCategories,
    );
  }
}
