import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import '../models/vote_category.dart';
import '../models/group.dart' hide VoteCategory;
import '../config/vote_options.dart';
import '../services/database_service.dart';
import '../widgets/main_layout.dart';
import '../platform/platform_utils.dart';
import 'vote_screen.dart';
import '../widgets/custom_dialog.dart';
import '../config/special_ids.dart';

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
      title: '投票内容の確認',
      icon: Icons.verified,
      onHome: () => PlatformUtils.reloadApp(),
      helpTitle: '投票内容の確認について',
      helpContent:
          '表示されている内容で投票が確定されます。内容を修正したい場合は、左下の「戻る」矢印から投票画面に戻ることができます。投票を完了すると、内容の変更は一切できなくなりますのでご注意ください。',
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
                          restoreSelection: true,
                          returnToConfirm: true,
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
                return _buildGroupCard(index, category, group);
              } else {
                return _buildSkippedCard(index, category);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: NeumorphicButton(
            onPressed: _isLoading ? null : _showConfirmationDialog,
            style: NeumorphicStyle(
              color: _isLoading ? null : Colors.black,
              depth: _isLoading ? -4 : 6,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
            ),
            child: Center(
              child:
                  _isLoading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onSurface,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'この内容で投票する',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.check, size: 16, color: Colors.white),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(
    int categoryIndex,
    VoteCategory category,
    Group group,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Neumorphic(
      margin: const EdgeInsets.only(bottom: 16),
      style: NeumorphicStyle(
        color: colorScheme.surface,
        depth: 4,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                NeumorphicButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VoteScreen(
                                      uuid: widget.uuid,
                                      categoryIndex: categoryIndex,
                                      selections: widget.selections,
                                      isGridView: widget.isGridView,
                                      restoreSelection: true,
                                      returnToConfirm: true,
                                    ),
                              ),
                            );
                          },
                  style: const NeumorphicStyle(depth: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 6),
                      Text('編集'),
                    ],
                  ),
                ),
              ],
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
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
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

  Widget _buildSkippedCard(int categoryIndex, VoteCategory category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Neumorphic(
      margin: const EdgeInsets.only(bottom: 16),
      style: NeumorphicStyle(
        color: colorScheme.surface,
        depth: 2,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                NeumorphicButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VoteScreen(
                                      uuid: widget.uuid,
                                      categoryIndex: categoryIndex,
                                      selections: widget.selections,
                                      isGridView: widget.isGridView,
                                      restoreSelection: true,
                                      returnToConfirm: true,
                                    ),
                              ),
                            );
                          },
                  style: const NeumorphicStyle(depth: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 6),
                      Text('編集'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.do_not_disturb_on_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 40,
                ),
                const SizedBox(width: 16),
                Text(
                  '選択されていません',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
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
      primaryActionText: '投票する',
      enablePrimaryLoading: true,
      minLoadingMs: 6000,
      maxLoadingMs: 6000,
      onPrimaryAction: () {
        Navigator.of(context).pop();
        _submitVote();
      },
    );
  }

  void _showVoteCompletedDialog() {
    showCustomDialog(
      context: context,
      title: '投票完了',
      content: '投票が完了しました。ご協力ありがとうございました。',
      primaryActionText: 'トップへ戻る',
      onPrimaryAction: _resetToTop,
    );
  }

  Future<void> _submitVote() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 特別IDは重複確認・保存をスキップし完了ダイアログ表示のみ
      if (widget.uuid == specialBypassUuid) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _showVoteCompletedDialog();
        return;
      }

      bool hasAlreadyVoted = await _dbService.hasVoted(widget.uuid);
      if (hasAlreadyVoted) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'この投票券は既に使用されています。';
          _isLoading = false;
        });
        await showCustomDialog(
          context: context,
          title: 'エラー',
          content: 'この投票券は既に使用されています。',
          closeButtonText: '閉じる',
        );
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
      await showCustomDialog(
        context: context,
        title: 'エラー',
        content: '投票の保存に失敗しました。もう一度お試しください。',
        closeButtonText: '閉じる',
      );
    }
  }

  void _resetToTop() {
    PlatformUtils.reloadApp();
  }
}
