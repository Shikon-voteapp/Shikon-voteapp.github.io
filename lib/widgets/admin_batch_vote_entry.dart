import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import 'custom_dialog.dart';
import 'liquid_glass.dart';

class AdminBatchVoteEntry extends StatefulWidget {
  final VoidCallback onVotesSubmitted;

  const AdminBatchVoteEntry({
    super.key,
    required this.onVotesSubmitted,
  });

  @override
  State<AdminBatchVoteEntry> createState() => _AdminBatchVoteEntryState();
}

class _ColumnVoteData {
  final TextEditingController numberController = TextEditingController();
  // categoryId -> selected groupId (null represents "未選択")
  final Map<String, String?> selections = {};

  void dispose() {
    numberController.dispose();
  }

  void clear() {
    numberController.clear();
    selections.clear();
  }

  bool get hasData => numberController.text.trim().isNotEmpty;
}

class _AdminBatchVoteEntryState extends State<AdminBatchVoteEntry> {
  static const int _maxColumns = 10;
  final List<_ColumnVoteData> _columns = [];
  final ScrollController _horizontalScrollController = ScrollController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('votes');
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 初期状態で3列用意
    for (int i = 0; i < 3; i++) {
      _columns.add(_ColumnVoteData());
    }
  }

  @override
  void dispose() {
    for (var col in _columns) {
      col.dispose();
    }
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _addColumn() {
    if (_columns.length < _maxColumns) {
      setState(() {
        _columns.add(_ColumnVoteData());
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_horizontalScrollController.hasClients) {
          _horizontalScrollController.animateTo(
            _horizontalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _removeColumn(int index) {
    if (_columns.length > 1) {
      setState(() {
        _columns[index].dispose();
        _columns.removeAt(index);
      });
    } else {
      setState(() {
        _columns[0].clear();
      });
    }
  }

  void _clearAll() {
    setState(() {
      for (var col in _columns) {
        col.clear();
      }
    });
  }

  Future<void> _submitVotes() async {
    // 投票番号が入力されている列を抽出
    final validColumns = _columns.where((col) => col.numberController.text.trim().isNotEmpty).toList();

    if (validColumns.isEmpty) {
      showCustomDialog(
        context: context,
        title: '入力エラー',
        content: '少なくとも1つの「投票番号」を入力してください。',
        closeButtonText: '閉じる',
      );
      return;
    }

    // 画面内での投票番号重複チェック
    final enteredNumbers = <String>{};
    for (var col in validColumns) {
      final num = col.numberController.text.trim();
      if (enteredNumbers.contains(num)) {
        showCustomDialog(
          context: context,
          title: '重複エラー',
          content: '投票番号「$num」が複数入力されています。重複しない番号を指定してください。',
          closeButtonText: '閉じる',
        );
        return;
      }
      enteredNumbers.add(num);
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 既存投票との重複チェック
      List<String> alreadyVotedList = [];
      for (var col in validColumns) {
        final num = col.numberController.text.trim();
        final snapshot = await _database.child(num).get();
        if (snapshot.exists) {
          alreadyVotedList.add(num);
        }
      }

      if (alreadyVotedList.isNotEmpty) {
        setState(() {
          _isSubmitting = false;
        });
        if (!mounted) return;
        await showCustomDialog(
          context: context,
          title: '既に使用されている投票番号',
          content: '以下の投票番号は既に投票済みです：\n${alreadyVotedList.join(', ')}\n\n入力内容をご確認ください。',
          closeButtonText: '確認',
        );
        return;
      }

      // Firebase に一括登録
      final now = DateTime.now();
      Map<String, dynamic> batchData = {};

      for (var col in validColumns) {
        final num = col.numberController.text.trim();
        Map<String, String> selectionsMap = {};

        col.selections.forEach((catId, groupId) {
          if (groupId != null && groupId.isNotEmpty) {
            selectionsMap[catId] = groupId;
          }
        });

        batchData[num] = {
          'uuid': num,
          'timestamp': now.toIso8601String(),
          'selections': selectionsMap,
        };
      }

      // バッチ更新
      await _database.update(batchData);

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // 成功ダイアログ
      await showCustomDialog(
        context: context,
        title: '登録完了',
        content: '${validColumns.length} 件の投票データを一括登録しました。',
        closeButtonText: 'OK',
      );

      // 入力データをクリア
      _clearAll();

      // 親ウィジェットに通知して集計データなどをリフレッシュ
      widget.onVotesSubmitted();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      await showCustomDialog(
        context: context,
        title: '登録失敗',
        content: '投票データの登録中にエラーが発生しました:\n${e.toString()}',
        closeButtonText: '閉じる',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 添付画像の入力枠スタイル（黒または白のしっかりしたボーダー・角丸）
    final borderColor = isDark ? Colors.white70 : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ツールバー（件数情報・列追加・クリア）
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart_outlined,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '投票先一括追加 (最大10件)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_columns.length} / $_maxColumns 列',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (_columns.length < _maxColumns)
                  TextButton.icon(
                    onPressed: _addColumn,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('列を追加'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('全クリア'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // テーブルマトリックス（横スクロール可能）
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左側の固定ラベル列（投票番号、賞1...賞n）
                    _buildRowLabelsColumn(),

                    // 右側の各データ入力列
                    for (int i = 0; i < _columns.length; i++)
                      _buildDataColumn(
                        index: i,
                        data: _columns[i],
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // 添付画像の下部「登録」ボタン
          _buildSubmitButton(isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 左側の行見出し列
  Widget _buildRowLabelsColumn() {
    return Container(
      width: 130,
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 列ヘッダーの高さ合わせ用スペース
          const SizedBox(height: 36),

          // 1行目: 投票番号
          SizedBox(
            height: 56,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '投票番号',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2行目以降: 賞1 ... 賞n
          for (int catIdx = 0; catIdx < voteCategories.length; catIdx++) ...[
            SizedBox(
              height: 56,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  voteCategories[catIdx].name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (catIdx < voteCategories.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // 各データ列
  Widget _buildDataColumn({
    required int index,
    required _ColumnVoteData data,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14.0),
      child: Column(
        children: [
          // 列ヘッダー（列番号 + 削除ボタン）
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_columns.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    tooltip: 'この列を削除',
                    onPressed: () => _removeColumn(index),
                  ),
              ],
            ),
          ),

          // 1行目: 投票番号入力欄（添付画像の丸角枠を忠実に再現）
          SizedBox(
            height: 56,
            child: TextField(
              controller: data.numberController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '例: 0123456789',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(color: borderColor, width: 1.6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2行目以降: 各賞のドロップダウン（添付画像の ▼ 付き丸角枠を忠実に再現）
          for (int catIdx = 0; catIdx < voteCategories.length; catIdx++) ...[
            _buildCategoryDropdown(
              category: voteCategories[catIdx],
              data: data,
              borderColor: borderColor,
              isDark: isDark,
            ),
            if (catIdx < voteCategories.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // 各賞のドロップダウン枠
  Widget _buildCategoryDropdown({
    required VoteCategory category,
    required _ColumnVoteData data,
    required Color borderColor,
    required bool isDark,
  }) {
    final selectedGroupId = data.selections[category.id];

    return SizedBox(
      height: 56,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: borderColor, width: 1.6),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedGroupId,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: borderColor, size: 24),
            hint: Text(
              '選択なし',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  '(未選択)',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              ...category.groups.map((group) {
                return DropdownMenuItem<String?>(
                  value: group.id,
                  child: Text(
                    group.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                data.selections[category.id] = value;
              });
            },
          ),
        ),
      ),
    );
  }

  // 下部の添付画像のような「登録」ボタン
  Widget _buildSubmitButton(bool isDark) {
    return Center(
      child: SizedBox(
        width: 260,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitVotes,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                )
              : const Text(
                  '登録',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
        ),
      ),
    );
  }
}
