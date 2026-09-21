import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import '../services/uuid_service.dart';
import '../services/database_service.dart';
import '../config/uuid_range.dart';
import 'custom_dialog.dart';

class AdminBatchVoteEntry extends StatefulWidget {
  final VoidCallback onVotesSubmitted;
  final ValueChanged<bool>? onSubmittingChanged;

  const AdminBatchVoteEntry({
    super.key,
    required this.onVotesSubmitted,
    this.onSubmittingChanged,
  });

  @override
  AdminBatchVoteEntryState createState() => AdminBatchVoteEntryState();
}

/// 各列のデータ保持モデル
class _BatchColumnData {
  final int index;
  final TextEditingController numberController = TextEditingController();
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
  final Map<String, ValueNotifier<String?>> categorySelections = {};

  _BatchColumnData({required this.index}) {
    for (final cat in voteCategories) {
      categorySelections[cat.id] = ValueNotifier<String?>(null);
    }
  }

  void dispose() {
    numberController.dispose();
    errorNotifier.dispose();
    for (final notifier in categorySelections.values) {
      notifier.dispose();
    }
  }

  void clear() {
    numberController.clear();
    errorNotifier.value = null;
    for (final notifier in categorySelections.values) {
      notifier.value = null;
    }
  }

  bool get hasData => numberController.text.trim().isNotEmpty;
}

class AdminBatchVoteEntryState extends State<AdminBatchVoteEntry> {
  static const int columnCount = 10;
  late final List<_BatchColumnData> _columns;
  final ScrollController _horizontalScrollController = ScrollController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('votes');
  final DatabaseService _dbService = DatabaseService();
  final UuidRangeService _rangeService = UuidRangeService();
  bool _isSubmitting = false;

  // パフォーマンス向上のためドロップダウンアイテムを事前キャッシュ
  static final Map<String, List<DropdownMenuItem<String?>>> _dropdownItemsCache = {};

  @override
  void initState() {
    super.initState();
    // 10件固定で列モデルを初期化
    _columns = List.generate(columnCount, (i) => _BatchColumnData(index: i));
    _initDropdownCache();
  }

  void _initDropdownCache() {
    if (_dropdownItemsCache.isNotEmpty) return;
    for (final category in voteCategories) {
      _dropdownItemsCache[category.id] = [
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
      ];
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

  void clearColumn(int index) {
    _columns[index].clear();
  }

  void clearAll() {
    for (var col in _columns) {
      col.clear();
    }
  }

  void _setSubmitting(bool value) {
    setState(() {
      _isSubmitting = value;
    });
    if (widget.onSubmittingChanged != null) {
      widget.onSubmittingChanged!(value);
    }
  }

  /// 外部（BottomBar等）から呼び出される一括登録処理
  Future<void> submitVotes() async {
    if (_isSubmitting) return;

    // 入力がある列を抽出
    final activeColumns = _columns.where((col) => col.numberController.text.trim().isNotEmpty).toList();

    if (activeColumns.isEmpty) {
      showCustomDialog(
        context: context,
        title: '入力エラー',
        content: '投票番号を入力した列がありません。\n10桁の投票番号を入力してください。',
        closeButtonText: '閉じる',
      );
      return;
    }

    _setSubmitting(true);

    try {
      final List<_BatchColumnData> validColumns = [];
      final List<String> rejectedMessages = [];
      final Set<String> seenInBatch = {};

      // 各列のエラー状態をリセット
      for (final col in _columns) {
        col.errorNotifier.value = null;
      }

      // 一般向けUIと同等の検証を各列ごとに実施
      for (final col in activeColumns) {
        final rawNumber = col.numberController.text.trim();

        // 1. 桁数チェック（10桁制限、9桁以下は弾く）
        if (rawNumber.length < 10) {
          col.errorNotifier.value = '10桁必要 (${rawNumber.length}桁)';
          rejectedMessages.add('列 ${col.index + 1} ($rawNumber): 9桁以下のため無効');
          continue;
        }

        if (!RegExp(r'^\d{10}$').hasMatch(rawNumber)) {
          col.errorNotifier.value = '数字10桁のみ';
          rejectedMessages.add('列 ${col.index + 1} ($rawNumber): 不正な文字が含まれています');
          continue;
        }

        // 2. 画面内重複チェック
        if (seenInBatch.contains(rawNumber)) {
          col.errorNotifier.value = '画面内で重複';
          rejectedMessages.add('列 ${col.index + 1} ($rawNumber): 画面内で重複入力されています');
          continue;
        }
        seenInBatch.add(rawNumber);

        // 3. 有効UUID範囲チェック（一般向けUIと同等）
        if (!_rangeService.isInValidRange(rawNumber)) {
          col.errorNotifier.value = '番号範囲外';
          rejectedMessages.add('列 ${col.index + 1} ($rawNumber): 有効な投票番号範囲外です');
          continue;
        }

        // 4. 重複投票チェック（Firebase / DatabaseService）
        final bool hasAlreadyVoted = await _dbService.hasVoted(rawNumber);
        if (hasAlreadyVoted) {
          col.errorNotifier.value = '投票済み';
          rejectedMessages.add('列 ${col.index + 1} ($rawNumber): 既に投票済みです');
          continue;
        }

        // すべての検証をパスした列
        validColumns.add(col);
      }

      // 適合したものが1件もない場合
      if (validColumns.isEmpty) {
        _setSubmitting(false);
        if (!mounted) return;
        await showCustomDialog(
          context: context,
          title: '登録できませんでした',
          content: '入力されたすべての番号が不適合だったため、登録されませんでした。\n\n【不適合の理由】\n' +
              rejectedMessages.join('\n'),
          closeButtonText: '確認',
        );
        return;
      }

      // 適合したもののみ Firebase Realtime Database に登録
      final now = DateTime.now();
      Map<String, dynamic> batchData = {};

      for (final col in validColumns) {
        final num = col.numberController.text.trim();
        Map<String, String> selectionsMap = {};

        col.categorySelections.forEach((catId, notifier) {
          final val = notifier.value;
          if (val != null && val.isNotEmpty) {
            selectionsMap[catId] = val;
          }
        });

        batchData[num] = {
          'uuid': num,
          'timestamp': now.toIso8601String(),
          'selections': selectionsMap,
        };
      }

      await _database.update(batchData);

      // 適合して登録された列のみクリア（不適合だった列はそのまま残し修正可能に）
      for (final col in validColumns) {
        col.clear();
      }

      _setSubmitting(false);
      if (!mounted) return;

      // 結果メッセージの作成
      String resultMessage = '${validColumns.length} 件の投票データを登録しました。';
      if (rejectedMessages.isNotEmpty) {
        resultMessage += '\n\n【以下の ${rejectedMessages.length} 件は不適合のため登録されませんでした】\n' +
            rejectedMessages.join('\n');
      }

      await showCustomDialog(
        context: context,
        title: rejectedMessages.isEmpty ? '登録完了' : '一部登録完了（不適合あり）',
        content: resultMessage,
        closeButtonText: 'OK',
      );

      widget.onVotesSubmitted();
    } catch (e) {
      if (!mounted) return;
      _setSubmitting(false);
      await showCustomDialog(
        context: context,
        title: '登録失敗',
        content: 'エラーが発生しました:\n${e.toString()}',
        closeButtonText: '閉じる',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ツールバー（ステータス表示・全クリア）
          Container(
            constraints: const BoxConstraints(maxWidth: 1060),
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
                  '投票先一括追加 (10件入力)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '10桁・重複自動判定',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: clearAll,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('全クリア'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // テーブルマトリックス（横スクロール対応）
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左側の固定見出し列
                    _buildRowLabelsColumn(),

                    // 右側の10列（各列を独立したウィジェットとして高速レンダリング）
                    for (int i = 0; i < columnCount; i++)
                      _BatchVoteColumnWidget(
                        key: ValueKey(i),
                        data: _columns[i],
                        borderColor: borderColor,
                        isDark: isDark,
                        dropdownItemsCache: _dropdownItemsCache,
                        onClear: () => clearColumn(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 左側の固定行見出し列
  Widget _buildRowLabelsColumn() {
    return Container(
      width: 130,
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 38),

          // 1行目: 投票番号
          const SizedBox(
            height: 68,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '投票番号',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2行目以降: 賞1 ... 賞n
          for (int catIdx = 0; catIdx < voteCategories.length; catIdx++) ...[
            SizedBox(
              height: 54,
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
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// 独立した1列ウィジェット（RepaintBoundaryにより局所描画され高速）
class _BatchVoteColumnWidget extends StatelessWidget {
  final _BatchColumnData data;
  final Color borderColor;
  final bool isDark;
  final Map<String, List<DropdownMenuItem<String?>>> dropdownItemsCache;
  final VoidCallback onClear;

  const _BatchVoteColumnWidget({
    super.key,
    required this.data,
    required this.borderColor,
    required this.isDark,
    required this.dropdownItemsCache,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          children: [
            // 列ヘッダー（列番号 + クリアボタン）
            SizedBox(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data.index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    tooltip: 'この列をクリア',
                    onPressed: onClear,
                  ),
                ],
              ),
            ),

            // 1行目: 投票番号入力欄（10桁制限・エラー通知監視）
            SizedBox(
              height: 68,
              child: ValueListenableBuilder<String?>(
                valueListenable: data.errorNotifier,
                builder: (context, errorText, _) {
                  final hasError = errorText != null;
                  return TextField(
                    controller: data.numberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10), // 10桁以上は入力不可
                    ],
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '数字10桁',
                      errorText: errorText,
                      errorStyle: const TextStyle(fontSize: 11, height: 0.9),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.withValues(alpha: 0.6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(
                          color: hasError ? Colors.red : borderColor,
                          width: hasError ? 2.0 : 1.6,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(
                          color: hasError ? Colors.red : Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? (hasError ? Colors.red.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.05))
                          : (hasError ? Colors.red.withValues(alpha: 0.05) : Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 2行目以降: 各賞のドロップダウン
            for (int catIdx = 0; catIdx < voteCategories.length; catIdx++) ...[
              _BatchDropdownCell(
                category: voteCategories[catIdx],
                selectionNotifier: data.categorySelections[voteCategories[catIdx].id]!,
                items: dropdownItemsCache[voteCategories[catIdx].id] ?? const [],
                borderColor: borderColor,
                isDark: isDark,
              ),
              if (catIdx < voteCategories.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// 独立したドロップダウンセルウィジェット（自分自身の値のみを監視し再描画を極小化）
class _BatchDropdownCell extends StatelessWidget {
  final VoteCategory category;
  final ValueNotifier<String?> selectionNotifier;
  final List<DropdownMenuItem<String?>> items;
  final Color borderColor;
  final bool isDark;

  const _BatchDropdownCell({
    required this.category,
    required this.selectionNotifier,
    required this.items,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 54,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: borderColor, width: 1.6),
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
          ),
          child: ValueListenableBuilder<String?>(
            valueListenable: selectionNotifier,
            builder: (context, selectedValue, _) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedValue,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: borderColor, size: 24),
                  hint: Text(
                    '選択なし',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  items: items,
                  onChanged: (newVal) {
                    selectionNotifier.value = newVal;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
