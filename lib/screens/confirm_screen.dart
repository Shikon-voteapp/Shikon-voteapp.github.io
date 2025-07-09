import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import '../services/database_service.dart';
import '../widgets/main_layout.dart';
import 'vote_screen.dart';
import '../widgets/custom_dialog.dart';
import '../screens/selection_screen.dart';
import 'scanner_screen.dart';

class ConfirmScreen extends StatefulWidget {
  final String uuid;
  final Map<String, String> selections;
  final bool isGridView;

  const ConfirmScreen({
    super.key,
    required this.uuid,
    required this.selections,
    required this.isGridView,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      icon: Icons.playlist_add_check,
      title: '投票内容の確認',
      helpTitle: '投票内容の確認について',
      helpContent:
          '表示されている内容で投票が確定されます。内容を修正したい場合は、左下の「戻る」矢印から投票画面に戻ることができます。投票を完了すると、内容の変更は一切できなくなりますのでご注意ください。',
      onHome: _resetToTop,
      onBack:
          _isLoading
              ? null
              : () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => VoteScreen(
                          uuid: widget.uuid,
                          categoryIndex: voteCategories.length - 1,
                          selections: widget.selections,
                          isGridView: widget.isGridView,
                          restoreSelection: false,
                        ),
                  ),
                );
              },
      child: _buildConfirmationView(),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      key: const ValueKey('confirmation'),
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: voteCategories.length,
            itemBuilder: (context, index) {
              final category = voteCategories[index];
              final groupId = widget.selections[category.id];
              if (groupId != null) {
                final group = allGroups.firstWhere(
                  (g) => g.id == groupId,
                  orElse: () {
                    // In case of data inconsistency
                    return Group(
                      id: 'not-found',
                      name: '団体が見つかりません',
                      groupName: '',
                      description: '',
                      imagePath: 'assets/Stage/No Select.jpg',
                      floor: 0,
                      categories: [],
                    );
                  },
                );
                return _buildGroupCard(category, group);
              } else {
                return _buildSkippedCard(category);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon:
                _isLoading ? Container() : const Icon(Icons.touch_app_outlined),
            label:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text('この内容で投票する'),
            onPressed: _isLoading ? null : _showConfirmationDialog,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF6A2C8F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(VoteCategory category, Group group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
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
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.groupName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkippedCard(VoteCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.do_not_disturb_on_outlined,
                  color: Colors.grey.shade500,
                  size: 40,
                ),
                const SizedBox(width: 16),
                const Text(
                  '選択されていません',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showCustomDialog(
      context: context,
      title: '投票を確定しますか？',
      content: 'この内容で投票すると、変更はできません。',
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('戻る'),
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('投票する'),
          onPressed: () {
            Navigator.of(context).pop();
            _submitVote();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A2C8F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ],
    );
  }

  void _showVoteCompletedDialog() {
    showCustomDialog(
      context: context,
      title: '投票完了',
      content: '投票が完了しました。ご協力ありがとうございました。',
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.home_outlined),
              label: const Text('トップへ戻る'),
              onPressed: _resetToTop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A2C8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitVote() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool hasAlreadyVoted = await _dbService.hasVoted(widget.uuid);
      if (hasAlreadyVoted) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'この投票券は既に使用されています。';
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

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showVoteCompletedDialog();
    } catch (e) {
      if (!mounted) return;
      print('投票処理中にエラーが発生しました: $e');
      setState(() {
        _errorMessage = '投票の保存に失敗しました。もう一度お試しください。';
        _isLoading = false;
      });
    }
  }

  void _resetToTop() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
      (route) => false,
    );
  }
}
