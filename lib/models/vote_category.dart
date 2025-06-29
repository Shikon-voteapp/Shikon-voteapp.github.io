// models/vote_category.dart
import 'group.dart';

class VoteCategory {
  final String id;
  final String name;
  final String description;
  final List<Group> groups;
  final bool canSkip;
  final String? helpUrl;
  final String? shortHelpText;

  VoteCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.groups,
    this.canSkip = false,
    this.helpUrl,
    this.shortHelpText,
  });
}
