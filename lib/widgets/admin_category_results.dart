import 'package:flutter/material.dart';
import '../models/group.dart';

class AdminCategoryResults extends StatelessWidget {
  final List<MapEntry<Group, int>> results;

  AdminCategoryResults({required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'トップ 3',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: results.length > 3 ? 3 : results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            final group = entry.key;
            final voteCount = entry.value;

            return Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: _buildRankBadge(index),
                title: Text(
                  group.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(group.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$voteCount票',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    final colors = [
      Colors.amber,
      Colors.blueGrey.shade300,
      Colors.brown.shade300,
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[rank]),
      child: Center(
        child: Text(
          '${rank + 1}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
