// models/vote_category.dart
import 'group.dart';

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
