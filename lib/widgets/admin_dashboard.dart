import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../models/group.dart';

class AdminDashboard extends StatelessWidget {
  final List<Vote> votes;
  final Function(int) onCategorySelected;

  AdminDashboard({required this.votes, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: voteCategories.length,
      itemBuilder: (context, index) {
        final category = voteCategories[index];
        final results = _getCategoryResults(category.id);
        final topGroup = _getTopGroup(category, results);

        return GestureDetector(
          onTap: () => onCategorySelected(index),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child:
                        topGroup == null
                            ? Center(child: Text('投票データなし'))
                            : Row(
                              children: [
                                Icon(Icons.emoji_events, color: Colors.amber),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '1位: ${topGroup.name}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${results[topGroup.id] ?? 0}票',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                  ),
                  Divider(),
                  Text(
                    '総投票数: ${_getTotalVotesForCategory(category.id)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _getCategoryResults(String categoryId) {
    Map<String, int> results = {};

    for (var vote in votes) {
      if (vote.selections.containsKey(categoryId)) {
        String groupId = vote.selections[categoryId]!;
        results[groupId] = (results[groupId] ?? 0) + 1;
      }
    }

    return results;
  }

  Group? _getTopGroup(VoteCategory category, Map<String, int> results) {
    if (results.isEmpty) return null;

    String? topGroupId;
    int maxVotes = 0;

    results.forEach((groupId, voteCount) {
      if (voteCount > maxVotes) {
        maxVotes = voteCount;
        topGroupId = groupId;
      }
    });

    if (topGroupId == null) return null;

    try {
      return category.groups.firstWhere((g) => g.id == topGroupId);
    } catch (e) {
      return null;
    }
  }

  int _getTotalVotesForCategory(String categoryId) {
    int total = 0;
    for (var vote in votes) {
      if (vote.selections.containsKey(categoryId)) {
        total++;
      }
    }
    return total;
  }
}
