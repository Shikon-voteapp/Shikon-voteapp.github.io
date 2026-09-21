import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../services/database_service.dart';
import '../config/uuid_range.dart';
import 'custom_dialog.dart';

class AdminInvalidateVote extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const AdminInvalidateVote({
    super.key,
    this.onDataChanged,
  });

  @override
  State<AdminInvalidateVote> createState() => _AdminInvalidateVoteState();
}

class _AdminInvalidateVoteState extends State<AdminInvalidateVote> {
  final DatabaseService _dbService = DatabaseService();
  final UuidRangeService _rangeService = UuidRangeService();

  final TextEditingController _singleIdController = TextEditingController();
  final TextEditingController _bulkIdController = TextEditingController();
  final TextEditingController _customReasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedReasonPreset = '紛失';
  final List<String> _reasonPresets = [
    '紛失',
    '汚損・破損',
    '誤配布・再発行',
    '不正利用・盗難',
    'テストデータ',
    'その他',
  ];

  bool _deleteExistingVote = true;
  bool _isLoadingList = true;
  bool _isProcessing = false;

  // 単一番号のステータス確認
  String? _checkedStatus; // 'invalidated', 'voted', 'unused', 'out_of_range', 'invalid_format'
  bool _isCheckingStatus = false;

  List<Map<String, dynamic>> _invalidatedList = [];
  String _searchQuery = '';
  int _activeTabIndex = 0; // 0: 個別無効化, 1: 一括無効化

  @override
  void initState() {
    super.initState();
    _loadInvalidatedList();
    _singleIdController.addListener(_onSingleIdChanged);
  }

  @override
  void dispose() {
    _singleIdController.removeListener(_onSingleIdChanged);
    _singleIdController.dispose();
    _bulkIdController.dispose();
    _customReasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSingleIdChanged() {
    final text = _singleIdController.text.trim();
    if (text.length == 10) {
      _checkStatusForId(text);
    } else {
      if (_checkedStatus != null) {
        setState(() {
          _checkedStatus = null;
        });
      }
    }
  }

  Future<void> _checkStatusForId(String id) async {
    if (id.length != 10 || !RegExp(r'^\d{10}$').hasMatch(id)) {
      setState(() {
        _checkedStatus = 'invalid_format';
      });
      return;
    }

    if (!_rangeService.isInValidRange(id)) {
      setState(() {
        _checkedStatus = 'out_of_range';
      });
      return;
    }

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final status = await _dbService.checkUuidStatus(id);
      if (mounted) {
        setState(() {
          _checkedStatus = status;
          _isCheckingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkedStatus = 'unknown';
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _loadInvalidatedList() async {
    setState(() {
      _isLoadingList = true;
    });

    final list = await _dbService.getInvalidatedUuids();
    if (mounted) {
      setState(() {
        _invalidatedList = list;
        _isLoadingList = false;
      });
    }
  }

  String _getEffectiveReason() {
    if (_selectedReasonPreset == 'その他') {
      final custom = _customReasonController.text.trim();
      return custom.isNotEmpty ? custom : 'その他';
    }
    return _selectedReasonPreset;
  }

  // 単一番号の無効化実行
  Future<void> _executeSingleInvalidation() async {
    final id = _singleIdController.text.trim();
    if (id.length != 10 || !RegExp(r'^\d{10}$').hasMatch(id)) {
      showCustomDialog(
        context: context,
        title: '入力エラー',
        content: '10桁の数字を入力してください。',
        closeButtonText: '閉じる',
      );
      return;
    }

    if (!_rangeService.isInValidRange(id)) {
      showCustomDialog(
        context: context,
        title: '範囲外エラー',
        content: '入力された番号は有効な投票番号範囲外です。',
        closeButtonText: '閉じる',
      );
      return;
    }

    final reason = _getEffectiveReason();
    final isVoted = _checkedStatus == 'voted';

    // 確認ダイアログ
    await showCustomDialog(
      context: context,
      title: '投票番号の無効化',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('以下の投票番号を無効化しますか？\n無効化された番号は以後投票に使用できなくなります。'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('番号: $id', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('理由: $reason', style: const TextStyle(fontSize: 14)),
                if (isVoted) ...[
                  const SizedBox(height: 6),
                  Text(
                    _deleteExistingVote ? '※ 既存の投票データも削除されます' : '※ 既存の投票データは保持されます',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      closeButtonText: 'キャンセル',
      primaryActionText: '無効化する',
      enablePrimaryLoading: true,
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        setState(() => _isProcessing = true);

        final success = await _dbService.invalidateUuid(
          id,
          reason: reason,
          deleteExistingVote: _deleteExistingVote,
        );

        if (mounted) {
          setState(() => _isProcessing = false);
          if (success) {
            _singleIdController.clear();
            _checkedStatus = null;
            await _loadInvalidatedList();
            widget.onDataChanged?.call();
            await showCustomDialog(
              context: context,
              title: '無効化完了',
              content: '投票番号 $id を無効化しました。',
              closeButtonText: 'OK',
            );
          } else {
            await showCustomDialog(
              context: context,
              title: 'エラー',
              content: '無効化処理に失敗しました。通信環境をご確認ください。',
              closeButtonText: '閉じる',
            );
          }
        }
      },
    );
  }

  // 複数一括無効化の実行
  Future<void> _executeBulkInvalidation() async {
    final rawText = _bulkIdController.text;
    final lines = rawText
        .split(RegExp(r'[\n,、\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      showCustomDialog(
        context: context,
        title: '入力エラー',
        content: '無効化する投票番号を入力してください。\n（改行またはカンマ区切り）',
        closeButtonText: '閉じる',
      );
      return;
    }

    // 重複除去とバリデーション
    final Set<String> targetIds = {};
    final List<String> invalidFormatIds = [];

    for (final id in lines) {
      if (id.length == 10 && RegExp(r'^\d{10}$').hasMatch(id)) {
        targetIds.add(id);
      } else {
        invalidFormatIds.add(id);
      }
    }

    if (targetIds.isEmpty) {
      showCustomDialog(
        context: context,
        title: 'フォーマットエラー',
        content: '有効な10桁の数字が1件も見つかりませんでした。',
        closeButtonText: '閉じる',
      );
      return;
    }

    final reason = _getEffectiveReason();

    await showCustomDialog(
      context: context,
      title: '${targetIds.length}件の番号を一括無効化',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${targetIds.length} 件の投票番号を一括で無効化しますか？'),
          if (invalidFormatIds.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '※ 10桁でない ${invalidFormatIds.length} 件はスキップされます',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('理由: $reason', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      closeButtonText: 'キャンセル',
      primaryActionText: '一括無効化する',
      enablePrimaryLoading: true,
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        setState(() => _isProcessing = true);

        int successCount = 0;
        for (final id in targetIds) {
          final ok = await _dbService.invalidateUuid(
            id,
            reason: reason,
            deleteExistingVote: _deleteExistingVote,
          );
          if (ok) successCount++;
        }

        if (mounted) {
          setState(() => _isProcessing = false);
          _bulkIdController.clear();
          await _loadInvalidatedList();
          widget.onDataChanged?.call();

          await showCustomDialog(
            context: context,
            title: '一括無効化完了',
            content: '$successCount / ${targetIds.length} 件の番号を無効化しました。',
            closeButtonText: 'OK',
          );
        }
      },
    );
  }

  // 無効化解除（復元）
  Future<void> _restoreUuid(String uuid) async {
    await showCustomDialog(
      context: context,
      title: '無効化の解除（復元）',
      content: '投票番号 $uuid の無効化を解除しますか？\n解除後は再びこの番号での投票が可能になります。',
      closeButtonText: 'キャンセル',
      primaryActionText: '解除（有効に戻す）',
      enablePrimaryLoading: true,
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        setState(() => _isProcessing = true);

        final ok = await _dbService.restoreUuid(uuid);

        if (mounted) {
          setState(() => _isProcessing = false);
          if (ok) {
            await _loadInvalidatedList();
            widget.onDataChanged?.call();
            await showCustomDialog(
              context: context,
              title: '解除完了',
              content: '投票番号 $uuid の無効化を解除しました。',
              closeButtonText: 'OK',
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    final filteredList = _invalidatedList.where((item) {
      final uuid = (item['uuid'] ?? '').toString();
      final reason = (item['reason'] ?? '').toString();
      if (_searchQuery.isEmpty) return true;
      return uuid.contains(_searchQuery) || reason.contains(_searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左ペイン：無効化入力フォーム
                SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: _buildInputFormCard(theme),
                  ),
                ),
                const SizedBox(width: 16),
                // 右ペイン：無効化済み番号一覧
                Expanded(
                  child: _buildListCard(theme, filteredList),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputFormCard(theme),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 520,
                    child: _buildListCard(theme, filteredList),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputFormCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return M3ECard(
      variant: M3ECardVariant.elevated,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(20.0),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.block_rounded, color: colorScheme.error, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                '無効化の登録',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // モード切替タブ（個別 / 一括）
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    label: '個別無効化',
                    icon: Icons.pin_outlined,
                    isSelected: _activeTabIndex == 0,
                    onTap: () => setState(() => _activeTabIndex = 0),
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    label: '複数一括無効化',
                    icon: Icons.list_alt_rounded,
                    isSelected: _activeTabIndex == 1,
                    onTap: () => setState(() => _activeTabIndex = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 入力部（個別または一括）
          if (_activeTabIndex == 0) ...[
            Text('投票番号（10桁）', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _singleIdController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: '例: 0123456789',
                counterText: '${_singleIdController.text.length}/10',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusIndicator(theme),
          ] else ...[
            Text('複数の投票番号（改行・カンマ区切り）', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _bulkIdController,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, letterSpacing: 1.5),
              decoration: InputDecoration(
                hintText: '0123456789\n9876543210\n1122334455',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // 無効化理由
          Text('無効化の理由', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasonPresets.map((preset) {
              final isSelected = _selectedReasonPreset == preset;
              return ChoiceChip(
                label: Text(preset),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedReasonPreset = preset);
                },
                selectedColor: colorScheme.errorContainer,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.onErrorContainer : colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          if (_selectedReasonPreset == 'その他') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customReasonController,
              decoration: InputDecoration(
                hintText: '具体的な理由を入力してください',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // 投票データ削除オプション
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('既存の投票データも削除する', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('対象番号で既に投票が存在する場合、集計から取り消します', style: TextStyle(fontSize: 11)),
              value: _deleteExistingVote,
              onChanged: (val) => setState(() => _deleteExistingVote = val ?? true),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          ),
          const SizedBox(height: 20),

          // 実行ボタン
          SizedBox(
            width: double.infinity,
            height: 48,
            child: M3EButton(
              onPressed: _isProcessing
                  ? null
                  : (_activeTabIndex == 0 ? _executeSingleInvalidation : _executeBulkInvalidation),
              style: M3EButtonStyle.filled,
              size: M3EButtonSize.md,
              shape: M3EButtonShape.round,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: M3ELoadingIndicator(variant: M3ELoadingIndicatorVariant.defaultStyle),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.block_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          _activeTabIndex == 0 ? 'この番号を無効化する' : '一括無効化を実行',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    if (_isCheckingStatus) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: M3ELoadingIndicator(
                variant: M3ELoadingIndicatorVariant.defaultStyle,
              ),
            ),
            SizedBox(width: 8),
            Text('ステータス確認中...', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if (_checkedStatus == null) return const SizedBox.shrink();

    Color bg;
    Color fg;
    IconData icon;
    String text;

    switch (_checkedStatus) {
      case 'invalidated':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        icon = Icons.cancel;
        text = '⚠ 既に無効化されている番号です';
        break;
      case 'voted':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        icon = Icons.how_to_vote;
        text = '⚠ 投票済みの番号です（無効化時に投票データが削除されます）';
        break;
      case 'unused':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        icon = Icons.check_circle;
        text = '✔ 有効な未投票の番号です（無効化可能）';
        break;
      case 'out_of_range':
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
        icon = Icons.warning_amber;
        text = '✖ 有効な投票券の番号範囲外です';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: fg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(ThemeData theme, List<Map<String, dynamic>> items) {
    final colorScheme = theme.colorScheme;

    return M3ECard(
      variant: M3ECardVariant.elevated,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(20.0),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // リストヘッダー
          Row(
            children: [
              Text(
                '無効化済み番号一覧',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_invalidatedList.length} 件',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.error),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'リストを更新',
                onPressed: _loadInvalidatedList,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 検索バー
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: '番号または理由で絞り込み...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          // 一覧コンテンツ
          Expanded(
            child: _isLoadingList
                ? const Center(child: M3ELoadingIndicator(variant: M3ELoadingIndicatorVariant.defaultStyle))
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 48, color: colorScheme.outline),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty ? '該当する無効化番号がありません' : '無効化された投票番号はありません',
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final uuid = (item['uuid'] ?? '').toString();
                          final reason = (item['reason'] ?? '理由なし').toString();
                          final time = (item['invalidatedAt'] ?? '').toString();
                          final hadVote = item['hadVote'] == true;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            child: Row(
                              children: [
                                // 番号と詳細
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            uuid,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: colorScheme.errorContainer,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              reason,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onErrorContainer,
                                              ),
                                            ),
                                          ),
                                          if (hadVote) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '投票データ取消済',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (time.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '無効化日時: ${_formatTime(time)}',
                                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // 解除ボタン
                                M3EButton(
                                  onPressed: _isProcessing ? null : () => _restoreUuid(uuid),
                                  style: M3EButtonStyle.tonal,
                                  size: M3EButtonSize.sm,
                                  shape: M3EButtonShape.round,
                                  child: const Text('有効に戻す', style: TextStyle(fontSize: 11.5)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}
