import 'package:flutter/material.dart';
import '../models/group.dart';

class AdminChart extends StatelessWidget {
  final List<MapEntry<Group, int>> results;

  AdminChart({required this.results});

  @override
  Widget build(BuildContext context) {
    int totalVotes = results.fold(0, (sum, entry) => sum + entry.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投票分布',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Expanded(
          child:
              totalVotes == 0
                  ? Center(child: Text('投票データがありません'))
                  : _buildBarChart(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    int maxVotes =
        results.isNotEmpty
            ? results.map((e) => e.value).reduce((a, b) => a > b ? a : b)
            : 1;

    return Container(
      padding: EdgeInsets.only(left: 40, right: 16, top: 8, bottom: 24),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final entry = results[index];
          final group = entry.key;
          final voteCount = entry.value;
          double percentage = maxVotes > 0 ? voteCount / maxVotes : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getBarColor(index),
                          ),
                          minHeight: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '$voteCount票',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getBarColor(int index) {
    if (index == 0) return Colors.blue;
    if (index == 1) return Colors.green;
    if (index == 2) return Colors.purple;

    return Colors.grey.shade600;
  }
}
