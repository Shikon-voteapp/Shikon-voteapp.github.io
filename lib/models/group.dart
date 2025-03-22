// models/group.dart

class Group {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int floor;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.floor,
  });

  get options => null;
}

// models/vote_category.dart
class VoteCategory {
  final String id;
  final String name;
  final String description;
  final List<Group> groups;

  VoteCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.groups,
  });
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
