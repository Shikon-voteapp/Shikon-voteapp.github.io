// lib/widgets/admin_chart.dart
import 'package:flutter/material.dart';
import '../models/group.dart';

class AdminChart extends StatelessWidget {
  final List<MapEntry<Group, int>> results;

  AdminChart({required this.results});

  @override
  Widget build(BuildContext context) {
    // 合計票数を計算
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
    // 最大票数を取得
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

          // 投票割合を計算
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
                    // 棒グラフの棒
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
                    // 票数表示
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
    // トップ3には特別な色を使用
    if (index == 0) return Colors.blue;
    if (index == 1) return Colors.green;
    if (index == 2) return Colors.purple;

    // それ以外は標準色
    return Colors.grey.shade600;
  }
}
