import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import '../platform/platform_utils.dart';
import '../services/database_service.dart';
import '../widgets/main_layout.dart';
import '../widgets/message_area.dart';
import 'complete_screen.dart';

class ConfirmScreen extends StatefulWidget {
  final String uuid;
  final Map<String, String> selections;

  ConfirmScreen({required this.uuid, required this.selections});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '投票内容の確認',
      onHome: () => PlatformUtils.reloadApp(),
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          MessageArea(
            title: '確認',
            titleColor: Colors.green,
            message: '以下の内容で投票します。よろしければ「投票する」を押してください。\n投票後の修正はできません。',
            icon: Icons.check_circle,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: widget.selections.length,
                itemBuilder: (context, index) {
                  String categoryId = widget.selections.keys.elementAt(index);
                  String groupId = widget.selections[categoryId]!;
                  VoteCategory category = voteCategories.firstWhere(
                    (c) => c.id == categoryId,
                    orElse:
                        () => VoteCategory(
                          id: 'unknown',
                          name: '不明なカテゴリー',
                          description: '',
                          groups: [],
                        ),
                  );
                  var group = category.groups.firstWhere(
                    (g) => g.id == groupId,
                    orElse:
                        () => Group(
                          id: 'unknown',
                          name: '不明な団体',
                          description: '',
                          imagePath: '',
                          floor: 0,
                        ),
                  );
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              group.imagePath,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                  child: Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  group.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  group.description,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _submitVote(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        '投票する',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitVote(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool hasAlreadyVoted = await _dbService.hasVoted(widget.uuid);
      if (hasAlreadyVoted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('すでに投票済みです。')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Vote vote = Vote(
        uuid: widget.uuid,
        selections: widget.selections,
        timestamp: DateTime.now(),
      );

      await _dbService.saveVote(vote);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteScreen(uuid: widget.uuid),
          ),
        );
      }
    } catch (e) {
      print('投票処理中にエラーが発生しました: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('投票の保存に失敗しました。もう一度お試しください。')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
