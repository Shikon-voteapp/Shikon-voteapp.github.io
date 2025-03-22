// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../services/database_service.dart';
import '../models/group.dart';
import '../widgets/top_bar.dart';
import '../widgets/admin_category_results.dart';
import '../widgets/admin_chart.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Vote>? _votes;
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final votes = await _dbService.getAllVotes();
      setState(() {
        _votes = votes;
        _isLoading = false;
      });
    } catch (e) {
      print('投票データ読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 特定のカテゴリーの集計結果を取得
  Map<String, int> _getCategoryResults(String categoryId) {
    Map<String, int> results = {};

    if (_votes == null) return results;

    for (var vote in _votes!) {
      if (vote.selections.containsKey(categoryId)) {
        String groupId = vote.selections[categoryId]!;
        results[groupId] = (results[groupId] ?? 0) + 1;
      }
    }

    return results;
  }

  // 票数でソートしたグループリストを取得
  List<MapEntry<Group, int>> _getSortedResults(String categoryId) {
    final results = _getCategoryResults(categoryId);
    final category = voteCategories.firstWhere((c) => c.id == categoryId);

    List<MapEntry<Group, int>> sortedResults = [];

    for (var group in category.groups) {
      int votes = results[group.id] ?? 0;
      sortedResults.add(MapEntry(group, votes));
    }

    // 票数の多い順にソート
    sortedResults.sort((a, b) => b.value.compareTo(a.value));

    return sortedResults;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理画面'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadVotes),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showClearConfirmation,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildCategoryTabs(),
                  Expanded(
                    child:
                        _votes == null || _votes!.isEmpty
                            ? Center(child: Text('投票データがありません'))
                            : _buildCategoryResults(),
                  ),
                ],
              ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: voteCategories.length,
        itemBuilder: (context, index) {
          final category = voteCategories[index];
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryResults() {
    final category = voteCategories[_selectedCategoryIndex];
    final results = _getSortedResults(category.id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '${category.name} の結果',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '総投票数: ${_votes?.length ?? 0}票',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          SizedBox(height: 24),

          // 上位3位の結果表示
          AdminCategoryResults(results: results),

          SizedBox(height: 24),

          // チャート表示
          Expanded(child: AdminChart(results: results)),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('全投票データを削除'),
            content: Text('すべての投票データを削除します。この操作は元に戻せません。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _dbService.clearAllVotes();
                  _loadVotes();
                },
                child: Text('削除する', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
