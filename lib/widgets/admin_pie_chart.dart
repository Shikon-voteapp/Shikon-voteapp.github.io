import 'package:flutter/material.dart';
import 'dart:math';
import '../models/group.dart';

class AdminPieChart extends StatelessWidget {
  final List<MapEntry<Group, int>> results;

  AdminPieChart({required this.results});

  @override
  Widget build(BuildContext context) {
    int totalVotes = results.fold(0, (sum, entry) => sum + entry.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投票割合',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Expanded(
          child:
              totalVotes == 0
                  ? Center(child: Text('投票データがありません'))
                  : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomPaint(
                          painter: PieChartPainter(results, totalVotes),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: _buildLegend(totalVotes)),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildLegend(int totalVotes) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        final group = entry.key;
        final voteCount = entry.value;
        final percentage =
            totalVotes > 0
                ? (voteCount / totalVotes * 100).toStringAsFixed(1)
                : '0.0';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 16, height: 16, color: _getColorForIndex(index)),
              SizedBox(width: 8),
              Expanded(
                child: Text(group.name, overflow: TextOverflow.ellipsis),
              ),
              Text('$voteCount票 ($percentage%)'),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
    ];

    return colors[index % colors.length];
  }
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<Group, int>> results;
  final int totalVotes;

  PieChartPainter(this.results, this.totalVotes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.8;

    var startAngle = -pi / 2; // Start from top

    for (int i = 0; i < results.length; i++) {
      final voteCount = results[i].value;
      if (voteCount <= 0) continue;

      final sweepAngle = 2 * pi * voteCount / totalVotes;

      final paint =
          Paint()
            ..color = _getColorForIndex(i)
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw labels if segment is large enough
      if (sweepAngle > 0.2) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7;
        final x = center.dx + labelRadius * cos(midAngle);
        final y = center.dy + labelRadius * sin(midAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${((voteCount / totalVotes) * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
    ];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
