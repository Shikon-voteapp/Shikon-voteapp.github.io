enum GroupCategory {
  Tenji, // 教室展示団体
  Moyoshi, //教室催し物団体
  Gakunen, //学年展示
  Roten, //露店
  Stage, //部活ステージ・公開練習
  Performance, //パフォーマンス
  Band, //バンド
  other, // その他
}

class Group {
  final String id;
  final String name; // 展示タイトル
  final String groupName; // 団体名
  final String description;
  final String imagePath;
  final int floor;
  final int? pamphletPage; // パンフレットページ
  final List<GroupCategory> categories; // 追加: カテゴリリスト

  Group({
    required this.id,
    required this.name,
    required this.groupName,
    required this.description,
    required this.imagePath,
    required this.floor,
    this.pamphletPage,
    this.categories = const [], // デフォルト値として空リストを設定
  });

  get options => null;

  bool hasCategory(GroupCategory category) {
    if (categories.isNotEmpty) {
      return categories.contains(category);
    }
    // 互換性のために既存のIDベースの判定も実装
    else {
      // 仮のロジック: IDの先頭数字でカテゴリを判断
      if (category == GroupCategory.Stage && id.startsWith('0')) {
        return true;
      } else if (category == GroupCategory.Tenji && id.startsWith('2')) {
        return true;
      } else if (category == GroupCategory.Moyoshi && id.startsWith('3')) {
        return true;
      } else if (category == GroupCategory.Gakunen && id.startsWith('4')) {
        return true;
      }
      return false;
    }
  }

  // JSONシリアライゼーション
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'groupName': groupName,
      'description': description,
      'imagePath': imagePath,
      'floor': floor,
      'pamphletPage': pamphletPage,
      'categories':
          categories.map((c) => c.toString().split('.').last).toList(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    List<GroupCategory> categories = [];
    if (json['categories'] != null) {
      categories =
          (json['categories'] as List).map((c) {
            return GroupCategory.values.firstWhere(
              (e) => e.toString().split('.').last == c,
              orElse: () => GroupCategory.other,
            );
          }).toList();
    }

    return Group(
      id: json['id'],
      name: json['name'],
      groupName: json['groupName'],
      description: json['description'],
      imagePath: json['imagePath'],
      floor: json['floor'],
      pamphletPage: json['pamphletPage'],
      categories: categories,
    );
  }
}

class VoteCategory {
  final String id;
  final String name;
  final String description;
  final List<Group> groups;
  final List<GroupCategory>? _eligibleCategories; // 内部用: 対象カテゴリのリスト
  final bool canSkip; // スキップ可能かどうかのフラグを追加
  final String? shortHelpText; // 短いヘルプテキスト

  VoteCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.groups,
    List<GroupCategory>? eligibleCategories,
    this.canSkip = false, // デフォルトは false (スキップ不可)
    this.shortHelpText,
  }) : _eligibleCategories = eligibleCategories;

  // eligibleCategoriesのゲッターを追加
  List<GroupCategory>? get eligibleCategories => _eligibleCategories;

  // 特定のカテゴリに所属する団体だけを取得するメソッド
  List<Group> getGroupsByCategory(GroupCategory category) {
    return groups.where((group) => group.hasCategory(category)).toList();
  }

  // 任意のカテゴリセットに基づいて対象団体を動的に取得するメソッド
  List<Group> getFilteredGroups() {
    if (_eligibleCategories == null || _eligibleCategories.isEmpty) {
      return groups; // カテゴリ指定がなければ全団体を返す
    }

    // 指定されたカテゴリのいずれかに該当する団体をフィルタリング
    return groups.where((group) {
      for (final category in _eligibleCategories) {
        if (group.hasCategory(category)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  // JSONシリアライゼーション
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'groups': groups.map((g) => g.id).toList(), // 団体はIDのみ保存
      'eligibleCategories':
          _eligibleCategories
              ?.map((c) => c.toString().split('.').last)
              .toList(),
      'canSkip': canSkip,
      'shortHelpText': shortHelpText,
    };
  }

  factory VoteCategory.fromJson(
    Map<String, dynamic> json,
    List<Group> allGroups,
  ) {
    List<Group> groups = [];
    if (json['groups'] != null) {
      groups =
          (json['groups'] as List).map((id) {
            return allGroups.firstWhere(
              (g) => g.id == id,
              orElse:
                  () => Group(
                    id: id,
                    name: 'Unknown Group',
                    groupName: '',
                    description: '',
                    imagePath: '',
                    floor: 1,
                  ),
            );
          }).toList();
    }

    List<GroupCategory>? eligibleCategories;
    if (json['eligibleCategories'] != null) {
      eligibleCategories =
          (json['eligibleCategories'] as List).map((c) {
            return GroupCategory.values.firstWhere(
              (e) => e.toString().split('.').last == c,
              orElse: () => GroupCategory.other,
            );
          }).toList();
    }

    return VoteCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      groups: groups,
      eligibleCategories: eligibleCategories,
      canSkip: json['canSkip'] ?? false,
      shortHelpText: json['shortHelpText'],
    );
  }
}

// models/vote.dart
class Vote {
  final String uuid;
  final Map<String, String> selections; // カテゴリーID -> 選択した団体ID
  final DateTime timestamp;

  Vote({required this.uuid, required this.selections, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'selections': selections,
    'timestamp': timestamp.toIso8601String(),
  };
}
