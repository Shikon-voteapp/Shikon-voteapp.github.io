import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../widgets/neumorphic_wrappers.dart';
import '../models/vote_category.dart';
import '../models/group.dart' hide VoteCategory;
import '../config/vote_options.dart';
import '../services/database_service.dart';
import '../widgets/main_layout.dart';
import '../widgets/liquid_glass.dart';
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
                          returnToConfirm: false,
                        ),
                  ),
                );
              },
      onNext: _isLoading ? null : _showConfirmationDialog,
      nextLabel: 'この内容で投票する',
      nextLoading: _isLoading,
      extendBehindBottomBar: true,
      child: _buildConfirmationView(),
    );
  }

  Widget _buildConfirmationView() {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('confirmation'),
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
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
    return neumorphicCard(
      context: context,
      margin: const EdgeInsets.only(bottom: 16),
      depth: 4,
      padding: EdgeInsets.zero,
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
                ElevatedButton.icon(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('編集'),
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
    return neumorphicCard(
      context: context,
      margin: const EdgeInsets.only(bottom: 16),
      depth: 2,
      padding: EdgeInsets.zero,
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
                ElevatedButton.icon(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('編集'),
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
    final theme = Theme.of(context);
    final BuildContext capturedContext = context;
    showCustomDialog(
      context: context,
      title: '投票完了',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '投票が完了しました',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ご協力ありがとうございました。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '別の投票券をお持ちの場合は、引き続き投票を行えます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            M3EButton.icon(
              onPressed: () {
                Navigator.of(capturedContext).pop();
                _resetToScanner();
              },
              style: M3EButtonStyle.filled,
              size: M3EButtonSize.md,
              shape: M3EButtonShape.round,
              icon: const Icon(Icons.confirmation_number_rounded, size: 18),
              label: const Text('続けて別の投票券を使う'),
            ),
            const SizedBox(height: 10),
            M3EButton.icon(
              onPressed: () {
                Navigator.of(capturedContext).pop();
                PlatformUtils.closeTab();
              },
              style: M3EButtonStyle.tonal,
              size: M3EButtonSize.md,
              shape: M3EButtonShape.round,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('閉じる（このタブを閉じる）'),
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

  void _resetToScanner() {
    // scanner_screen インポートによる循環依存を避けるため、リロードでトップから再開始
    PlatformUtils.reloadApp();
  }
}
