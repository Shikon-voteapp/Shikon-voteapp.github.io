import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import '../services/config_service.dart';

/// 管理者パネル「設定管理モード」
/// C# GUI ツール (ShikonSettingApp) の3タブ構成・UIを踏襲した高速Web版エディター
class AdminConfigManager extends StatefulWidget {
  const AdminConfigManager({super.key});

  @override
  State<AdminConfigManager> createState() => _AdminConfigManagerState();
}

class _AdminConfigManagerState extends State<AdminConfigManager>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 読み込み・保存状態
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isMigrating = false;
  bool _isUploadingImage = false;
  String _statusMessage = 'データを読み込んでいます...';
  bool _hasUnsavedChanges = false;

  // 編集用データ
  List<_EditableGroup> _groups = [];
  int? _selectedGroupIndex;

  List<_EditableCategory> _categories = [];
  int? _selectedCategoryIndex;

  late VotingPeriodConfig _periodConfig;

  // 詳細編集用コントローラー
  final TextEditingController _groupIdCtrl = TextEditingController();
  final TextEditingController _groupNameCtrl = TextEditingController();
  final TextEditingController _groupGroupNameCtrl = TextEditingController();
  final TextEditingController _groupFloorCtrl = TextEditingController();
  final TextEditingController _groupDescCtrl = TextEditingController();
  final TextEditingController _groupPamphletCtrl = TextEditingController();

  final TextEditingController _catIdCtrl = TextEditingController();
  final TextEditingController _catNameCtrl = TextEditingController();
  final TextEditingController _catDescCtrl = TextEditingController();
  final TextEditingController _catShortHelpCtrl = TextEditingController();
  final TextEditingController _catHelpUrlCtrl = TextEditingController();

  // カテゴリ定義
  static const List<GroupCategory> _allCategories = [
    GroupCategory.Tenji,
    GroupCategory.Moyoshi,
    GroupCategory.Gakunen,
    GroupCategory.Roten,
    GroupCategory.Stage,
    GroupCategory.Performance,
    GroupCategory.Band,
    GroupCategory.other,
  ];

  static const Map<GroupCategory, String> _categoryLabels = {
    GroupCategory.Tenji: 'Tenji (展示)',
    GroupCategory.Moyoshi: 'Moyoshi (催し物)',
    GroupCategory.Gakunen: 'Gakunen (学年展示)',
    GroupCategory.Roten: 'Roten (露店)',
    GroupCategory.Stage: 'Stage (部活ステージ)',
    GroupCategory.Performance: 'Performance (パフォーマンス)',
    GroupCategory.Band: 'Band (バンド)',
    GroupCategory.other: 'other (その他)',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _periodConfig = defaultVotingPeriod;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupIdCtrl.dispose();
    _groupNameCtrl.dispose();
    _groupGroupNameCtrl.dispose();
    _groupFloorCtrl.dispose();
    _groupDescCtrl.dispose();
    _groupPamphletCtrl.dispose();
    _catIdCtrl.dispose();
    _catNameCtrl.dispose();
    _catDescCtrl.dispose();
    _catShortHelpCtrl.dispose();
    _catHelpUrlCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // データ読み込み / 初期化
  // ─────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Firestore から設定データを読み込んでいます...';
    });

    try {
      final loadedGroups = await ConfigService.loadGroups();
      final loadedCategories =
          await ConfigService.loadVoteCategories(loadedGroups);
      final loadedPeriod = await ConfigService.loadVotingPeriod();

      final effectiveGroups =
          loadedGroups.isNotEmpty ? loadedGroups : allGroups;
      final effectiveCategories = loadedCategories.isNotEmpty
          ? loadedCategories
          : voteCategories;
      final effectivePeriod = loadedPeriod ?? defaultVotingPeriod;

      setState(() {
        _groups = effectiveGroups
            .map((g) => _EditableGroup(
                  id: g.id,
                  name: g.name,
                  groupName: g.groupName,
                  description: g.description,
                  imagePath: g.imagePath,
                  floor: g.floor,
                  pamphletPage: g.pamphletPage,
                  categories: List.from(g.categories),
                ))
            .toList();

        _categories = effectiveCategories
            .map((c) => _EditableCategory(
                  id: c.id,
                  name: c.name,
                  description: c.description,
                  shortHelpText: c.shortHelpText ?? '',
                  helpUrl: c.helpUrl ?? '',
                  canSkip: c.canSkip,
                  groupIds: c.groups.map((g) => g.id).toList(),
                ))
            .toList();

        _periodConfig = effectivePeriod;
        _selectedGroupIndex = _groups.isNotEmpty ? 0 : null;
        _selectedCategoryIndex = _categories.isNotEmpty ? 0 : null;
        _syncGroupControllers();
        _syncCategoryControllers();
        _hasUnsavedChanges = false;
        _isLoading = false;
        _statusMessage = loadedGroups.isEmpty
            ? 'ローカル既定データを読み込みました（Firestore 未保存）'
            : 'Firestore データを読み込みました（${_groups.length} 団体 / ${_categories.length} 賞）';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '読み込み失敗: $e';
      });
    }
  }

  // ─────────────────────────────────────────
  // コントローラー同期
  // ─────────────────────────────────────────

  void _syncGroupControllers() {
    if (_selectedGroupIndex != null &&
        _selectedGroupIndex! >= 0 &&
        _selectedGroupIndex! < _groups.length) {
      final g = _groups[_selectedGroupIndex!];
      _groupIdCtrl.text = g.id;
      _groupNameCtrl.text = g.name;
      _groupGroupNameCtrl.text = g.groupName;
      _groupFloorCtrl.text = g.floor.toString();
      _groupDescCtrl.text = g.description;
      _groupPamphletCtrl.text = g.pamphletPage?.toString() ?? '';
    } else {
      _groupIdCtrl.clear();
      _groupNameCtrl.clear();
      _groupGroupNameCtrl.clear();
      _groupFloorCtrl.clear();
      _groupDescCtrl.clear();
      _groupPamphletCtrl.clear();
    }
  }

  void _syncCategoryControllers() {
    if (_selectedCategoryIndex != null &&
        _selectedCategoryIndex! >= 0 &&
        _selectedCategoryIndex! < _categories.length) {
      final c = _categories[_selectedCategoryIndex!];
      _catIdCtrl.text = c.id;
      _catNameCtrl.text = c.name;
      _catDescCtrl.text = c.description;
      _catShortHelpCtrl.text = c.shortHelpText;
      _catHelpUrlCtrl.text = c.helpUrl;
    } else {
      _catIdCtrl.clear();
      _catNameCtrl.clear();
      _catDescCtrl.clear();
      _catShortHelpCtrl.clear();
      _catHelpUrlCtrl.clear();
    }
  }

  // ─────────────────────────────────────────
  // 重複チェック
  // ─────────────────────────────────────────

  bool _isGroupIdDuplicate(String id, int currentIndex) {
    if (id.trim().isEmpty) return false;
    for (int i = 0; i < _groups.length; i++) {
      if (i != currentIndex && _groups[i].id.trim() == id.trim()) {
        return true;
      }
    }
    return false;
  }

  bool _isCategoryIdDuplicate(String id, int currentIndex) {
    if (id.trim().isEmpty) return false;
    for (int i = 0; i < _categories.length; i++) {
      if (i != currentIndex && _categories[i].id.trim() == id.trim()) {
        return true;
      }
    }
    return false;
  }

  // ─────────────────────────────────────────
  // 保存・データクリア・移行
  // ─────────────────────────────────────────

  Future<void> _saveAll() async {
    for (int i = 0; i < _groups.length; i++) {
      if (_isGroupIdDuplicate(_groups[i].id, i)) {
        _showSnackbar('団体の ID「${_groups[i].id}」が重複しています。', isError: true);
        return;
      }
    }
    for (int i = 0; i < _categories.length; i++) {
      if (_isCategoryIdDuplicate(_categories[i].id, i)) {
        _showSnackbar('賞の ID「${_categories[i].id}」が重複しています。', isError: true);
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _statusMessage = 'Firestore に保存中...';
    });

    try {
      final List<Group> groupsToSave = _groups.map((eg) {
        return Group(
          id: eg.id.trim(),
          name: eg.name.trim(),
          groupName: eg.groupName.trim(),
          description: eg.description.trim(),
          imagePath: eg.imagePath.trim(),
          floor: eg.floor,
          pamphletPage: eg.pamphletPage,
          categories: eg.categories,
        );
      }).toList();
      await ConfigService.saveAllGroups(groupsToSave);

      final List<VoteCategory> categoriesToSave = _categories.map((ec) {
        final assignedGroups = groupsToSave
            .where((g) => ec.groupIds.contains(g.id))
            .toList();
        return VoteCategory(
          id: ec.id.trim(),
          name: ec.name.trim(),
          description: ec.description.trim(),
          shortHelpText: ec.shortHelpText.trim().isEmpty ? null : ec.shortHelpText.trim(),
          helpUrl: ec.helpUrl.trim().isEmpty ? null : ec.helpUrl.trim(),
          canSkip: ec.canSkip,
          groups: assignedGroups,
        );
      }).toList();
      await ConfigService.saveAllVoteCategories(categoriesToSave);

      await ConfigService.saveVotingPeriod(_periodConfig);

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
        _statusMessage = 'すべての設定を Firestore に保存しました（${DateFormat('HH:mm:ss').format(DateTime.now())}）';
      });
      _showSnackbar('設定を正常に保存しました');
    } catch (e) {
      setState(() {
        _isSaving = false;
        _statusMessage = '保存失敗: $e';
      });
      _showSnackbar('保存に失敗しました: $e', isError: true);
    }
  }

  Future<void> _clearFirestoreData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Firestore 設定データの全削除'),
        content: const Text(
          'Firestore に保存されている団体・賞の設定データをすべて削除します。\n'
          'ローカルの vote_options.dart や画像ファイル自体は削除されません。\n\n本当に実行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('全削除を実行'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Firestore のデータをクリアしています...';
    });

    try {
      await ConfigService.clearAllGroups();
      await ConfigService.clearAllCategories();
      _showSnackbar('Firestore の設定データをクリアしました');
      await _loadData();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'クリア失敗: $e';
      });
      _showSnackbar('クリアに失敗しました: $e', isError: true);
    }
  }

  Future<void> _migrateFromCode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('初期データの投入 (Migration)'),
        content: const Text(
          '既存の vote_options.dart に定義されている団体・賞・投票期間を Firestore に投入します。\n\n'
          '既に Firestore に存在するデータはスキップされ、新規分のみ追加されます。実行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('投入を実行'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isMigrating = true;
      _statusMessage = 'vote_options.dart から Firestore へ初期データを投入中...';
    });

    try {
      final result = await ConfigService.migrateFromVoteOptions(
        sourceGroups: allGroups,
        sourceCategories: voteCategories,
        sourcePeriod: defaultVotingPeriod,
        overwrite: false,
      );

      setState(() {
        _isMigrating = false;
        _statusMessage =
            '移行完了: 団体 +${result.groupsAdded}件, 賞 +${result.categoriesAdded}件, 期間: ${result.periodSet ? "新規設定" : "既存維持"}';
      });
      _showSnackbar('初期データ投入完了: 団体 +${result.groupsAdded}件, 賞 +${result.categoriesAdded}件');
      await _loadData();
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _statusMessage = '移行失敗: $e';
      });
      _showSnackbar('移行に失敗しました: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─────────────────────────────────────────
  // UI 描画
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF7C3AED)),
            const SizedBox(height: 16),
            Text(_statusMessage, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTopToolbar(theme, isDark),
        Container(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF7C3AED),
            labelColor: const Color(0xFF7C3AED),
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(icon: Icon(Icons.groups_rounded, size: 20), text: '団体設定'),
              Tab(icon: Icon(Icons.emoji_events_rounded, size: 20), text: '賞の設定'),
              Tab(icon: Icon(Icons.access_time_rounded, size: 20), text: '投票期間設定'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGroupsTab(theme, isDark),
              _buildCategoriesTab(theme, isDark),
              _buildPeriodTab(theme, isDark),
            ],
          ),
        ),
        _buildStatusBar(theme, isDark),
      ],
    );
  }

  // ─────────────────────────────────────────
  // 上部ツールバー
  // ─────────────────────────────────────────

  Widget _buildTopToolbar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF7C3AED), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '設定管理 (VoteApp Editor)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (_hasUnsavedChanges) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '未保存',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                'Firestore / Cloud Storage の設定データを管理します',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const Spacer(),

          // データ全クリアボタン
          M3EButton(
            onPressed: (_isSaving || _isMigrating) ? null : _clearFirestoreData,
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_sweep_rounded, size: 16, color: Colors.red),
                SizedBox(width: 6),
                Text('データクリア', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 初期データ投入ボタン
          M3EButton(
            onPressed: (_isSaving || _isMigrating) ? null : _migrateFromCode,
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isMigrating)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.upload_file_rounded, size: 16),
                const SizedBox(width: 6),
                const Text('初期データ投入'),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // リロードボタン
          M3EButton(
            onPressed: (_isSaving || _isMigrating) ? null : _loadData,
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 16),
                SizedBox(width: 6),
                Text('リロード'),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 保存ボタン
          M3EButton(
            onPressed: (_isSaving || _isMigrating) ? null : _saveAll,
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSaving)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.save_rounded, size: 16),
                const SizedBox(width: 6),
                const Text('変更を保存'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // タブ 1: 団体設定
  // ─────────────────────────────────────────

  Widget _buildGroupsTab(ThemeData theme, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 768;

    return isCompact
        ? Column(
            children: [
              SizedBox(
                height: 220,
                child: _buildGroupListPanel(theme, isDark),
              ),
              const Divider(height: 1),
              Expanded(
                child: _buildGroupDetailPanel(theme, isDark),
              ),
            ],
          )
        : Row(
            children: [
              SizedBox(
                width: 340,
                child: _buildGroupListPanel(theme, isDark),
              ),
              VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: _buildGroupDetailPanel(theme, isDark),
              ),
            ],
          );
  }

  Widget _buildGroupListPanel(ThemeData theme, bool isDark) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _addGroup,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('＋ 団体を追加', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _selectedGroupIndex != null ? _removeSelectedGroup : null,
                  tooltip: '選択中の団体を削除',
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _groups.isEmpty
                ? const Center(child: Text('団体が登録されていません'))
                : ListView.separated(
                    itemCount: _groups.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    itemBuilder: (ctx, index) {
                      final g = _groups[index];
                      final isSelected = _selectedGroupIndex == index;
                      final isDuplicate = _isGroupIdDuplicate(g.id, index);

                      // Material 3 準拠のカスタムコンテナ（InkWell による安定タップ）
                      return Material(
                        color: isSelected
                            ? const Color(0xFF7C3AED).withOpacity(0.12)
                            : Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_selectedGroupIndex != index) {
                              setState(() {
                                _selectedGroupIndex = index;
                                _syncGroupControllers();
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isSelected
                                      ? const Color(0xFF7C3AED)
                                      : theme.colorScheme.surfaceContainerHighest,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              g.name.isEmpty ? '(無名の団体)' : g.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                color: isSelected ? const Color(0xFF7C3AED) : null,
                                              ),
                                            ),
                                          ),
                                          if (isDuplicate)
                                            Container(
                                              margin: const EdgeInsets.only(left: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.red.shade400),
                                              ),
                                              child: Text(
                                                '⚠️ 重複',
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'ID: ${g.id.isEmpty ? "-" : g.id}  •  ${g.floor}F',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupDetailPanel(ThemeData theme, bool isDark) {
    if (_selectedGroupIndex == null ||
        _selectedGroupIndex! < 0 ||
        _selectedGroupIndex! >= _groups.length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              '← 左のリストから団体を選択してください',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.outline),
            ),
          ],
        ),
      );
    }

    final g = _groups[_selectedGroupIndex!];
    final isDuplicate = _isGroupIdDuplicate(g.id, _selectedGroupIndex!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldHeader('ID', required: true),
          TextField(
            controller: _groupIdCtrl,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '例: 001, 101, T01',
            ),
            onChanged: (val) {
              g.id = val;
              _markDirty();
            },
          ),
          if (isDuplicate) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID「${g.id}」は既に他の団体で使用されています。一意のIDを指定してください。',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          _buildFieldHeader('団体名 (name) - 展示企画名', required: true),
          TextField(
            controller: _groupNameCtrl,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '例: 喫茶シコン',
            ),
            onChanged: (val) {
              g.name = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          _buildFieldHeader('グループ名 (groupName) - クラス・部活動名', required: true),
          TextField(
            controller: _groupGroupNameCtrl,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '例: 3年A組 / 茶道部',
            ),
            onChanged: (val) {
              g.groupName = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldHeader('階 (floor)', required: true),
                    TextField(
                      controller: _groupFloorCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        hintText: '例: 1, 2, 3',
                      ),
                      onChanged: (val) {
                        g.floor = int.tryParse(val) ?? 1;
                        _markDirty();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldHeader('パンフレットページ (pamphletPage)'),
                    TextField(
                      controller: _groupPamphletCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        hintText: '例: 12 (任意)',
                      ),
                      onChanged: (val) {
                        g.pamphletPage = int.tryParse(val);
                        _markDirty();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildFieldHeader('説明 (description)'),
          TextField(
            controller: _groupDescCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '団体の詳細説明を入力してください',
            ),
            onChanged: (val) {
              g.description = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          // 画像設定（アップロードと選択を分離）
          _buildFieldHeader('画像 (imagePath)'),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(
                    g.imagePath.isEmpty ? '（画像未設定）' : g.imagePath,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: g.imagePath.isEmpty
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 画像アップロードボタン
              FilledButton.tonalIcon(
                onPressed: _isUploadingImage ? null : () => _uploadNewImage(g),
                icon: _isUploadingImage
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined, size: 16),
                label: const Text('新規UP'),
              ),
              const SizedBox(width: 6),
              // 既存画像から選択ボタン
              OutlinedButton.icon(
                onPressed: () => _openImageSelectDialog(g),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('選択'),
              ),
              if (g.imagePath.isNotEmpty) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: '画像クリア',
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    setState(() {
                      g.imagePath = '';
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          _buildFieldHeader('カテゴリ (categories)'),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _allCategories.map((cat) {
              final isChecked = g.categories.contains(cat);
              return FilterChip(
                label: Text(_categoryLabels[cat] ?? cat.toString()),
                selected: isChecked,
                selectedColor: const Color(0xFF7C3AED).withOpacity(0.18),
                checkmarkColor: const Color(0xFF7C3AED),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (!g.categories.contains(cat)) {
                        g.categories.add(cat);
                      }
                    } else {
                      g.categories.remove(cat);
                    }
                    _hasUnsavedChanges = true;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _addGroup() {
    setState(() {
      final newIndex = _groups.length + 1;
      final newGroup = _EditableGroup(
        id: 'group_$newIndex',
        name: '新しい団体 $newIndex',
        groupName: '新しい企画',
        description: '',
        imagePath: '',
        floor: 1,
        categories: [GroupCategory.Tenji],
      );
      _groups.add(newGroup);
      _selectedGroupIndex = _groups.length - 1;
      _syncGroupControllers();
      _hasUnsavedChanges = true;
    });
  }

  void _removeSelectedGroup() {
    if (_selectedGroupIndex == null) return;
    final g = _groups[_selectedGroupIndex!];

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('団体の削除'),
        content: Text('団体「${g.name}（ID: ${g.id}）」を削除しますか？\nこの操作は「変更を保存」を押すまで Firestore には反映されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('削除'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() {
          final removedId = g.id;
          _groups.removeAt(_selectedGroupIndex!);
          for (final cat in _categories) {
            cat.groupIds.remove(removedId);
          }
          if (_groups.isEmpty) {
            _selectedGroupIndex = null;
          } else if (_selectedGroupIndex! >= _groups.length) {
            _selectedGroupIndex = _groups.length - 1;
          }
          _syncGroupControllers();
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  // ─────────────────────────────────────────
  // 画像アップロード & 選択ダイアログ
  // ─────────────────────────────────────────

  Future<void> _uploadNewImage(_EditableGroup group) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        _showSnackbar('画像データを読み込めませんでした', isError: true);
        return;
      }

      final ext = file.extension?.toLowerCase() ?? 'jpg';
      String mime = 'image/jpeg';
      if (ext == 'png') mime = 'image/png';
      if (ext == 'webp') mime = 'image/webp';
      if (ext == 'gif') mime = 'image/gif';

      setState(() {
        _isUploadingImage = true;
        _statusMessage = 'Cloud Storage に画像をアップロードしています...';
      });

      final targetId = group.id.trim().isNotEmpty ? group.id.trim() : 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final storagePath = await ConfigService.uploadGroupImage(
        groupId: targetId,
        fileName: file.name,
        bytes: bytes,
        mimeType: mime,
      );

      setState(() {
        group.imagePath = storagePath;
        _isUploadingImage = false;
        _hasUnsavedChanges = true;
        _statusMessage = '画像をアップロードしました: $storagePath';
      });
      _showSnackbar('画像を正常にアップロードしました');
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
        _statusMessage = '画像アップロード失敗: $e';
      });
      _showSnackbar('画像アップロード失敗: $e\n（Storage の権限・ルールを確認してください）', isError: true);
    }
  }

  Future<void> _openImageSelectDialog(_EditableGroup group) async {
    // 既存のアップロード済み画像リストと、ローカル assets/ 候補を収集
    final existingPathsInUse = _groups
        .map((g) => g.imagePath.trim())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    showDialog<String>(
      context: context,
      builder: (ctx) {
        final manualPathCtrl = TextEditingController(text: group.imagePath);
        return FutureBuilder<List<String>>(
          future: ConfigService.listUploadedImages(),
          builder: (context, snapshot) {
            final storageImages = snapshot.data ?? [];
            final allCandidates = {...existingPathsInUse, ...storageImages}.toList();

            return AlertDialog(
              title: const Text('画像パスの選択・指定'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('パスを直接入力、または一覧から選択してください:', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: manualPathCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        hintText: '例: groups/001/image.jpg または assets/wind.jpg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('登録済み・利用中の画像一覧:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (allCandidates.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('利用可能な画像パスがありません。「新規UP」から画像をアップロードしてください。', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListView.separated(
                          itemCount: allCandidates.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (c, idx) {
                            final path = allCandidates[idx];
                            return ListTile(
                              dense: true,
                              title: Text(path, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                              leading: const Icon(Icons.image_outlined, size: 18),
                              onTap: () {
                                Navigator.of(ctx).pop(path);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(manualPathCtrl.text.trim()),
                  child: const Text('確定'),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedPath) {
      if (selectedPath != null && mounted) {
        setState(() {
          group.imagePath = selectedPath;
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  // ─────────────────────────────────────────
  // タブ 2: 賞の設定
  // ─────────────────────────────────────────

  Widget _buildCategoriesTab(ThemeData theme, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 768;

    return isCompact
        ? Column(
            children: [
              SizedBox(
                height: 220,
                child: _buildCategoryListPanel(theme, isDark),
              ),
              const Divider(height: 1),
              Expanded(
                child: _buildCategoryDetailPanel(theme, isDark),
              ),
            ],
          )
        : Row(
            children: [
              SizedBox(
                width: 340,
                child: _buildCategoryListPanel(theme, isDark),
              ),
              VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: _buildCategoryDetailPanel(theme, isDark),
              ),
            ],
          );
  }

  Widget _buildCategoryListPanel(ThemeData theme, bool isDark) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _addCategory,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('＋ 賞を追加', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _selectedCategoryIndex != null ? _removeSelectedCategory : null,
                  tooltip: '選択中の賞を削除',
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _categories.isEmpty
                ? const Center(child: Text('賞が登録されていません'))
                : ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    itemBuilder: (ctx, index) {
                      final c = _categories[index];
                      final isSelected = _selectedCategoryIndex == index;
                      final isDuplicate = _isCategoryIdDuplicate(c.id, index);

                      return Material(
                        color: isSelected
                            ? const Color(0xFF7C3AED).withOpacity(0.12)
                            : Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_selectedCategoryIndex != index) {
                              setState(() {
                                _selectedCategoryIndex = index;
                                _syncCategoryControllers();
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isSelected
                                      ? const Color(0xFF7C3AED)
                                      : theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.emoji_events_rounded,
                                    size: 14,
                                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.name.isEmpty ? '(無名の賞)' : c.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                color: isSelected ? const Color(0xFF7C3AED) : null,
                                              ),
                                            ),
                                          ),
                                          if (isDuplicate)
                                            Container(
                                              margin: const EdgeInsets.only(left: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.red.shade400),
                                              ),
                                              child: Text(
                                                '⚠️ 重複',
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'ID: ${c.id.isEmpty ? "-" : c.id}  •  ${c.groupIds.isEmpty ? "全団体対象" : "${c.groupIds.length}団体"}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailPanel(ThemeData theme, bool isDark) {
    if (_selectedCategoryIndex == null ||
        _selectedCategoryIndex! < 0 ||
        _selectedCategoryIndex! >= _categories.length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              '← 左のリストから賞を選択してください',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.outline),
            ),
          ],
        ),
      );
    }

    final c = _categories[_selectedCategoryIndex!];
    final isDuplicate = _isCategoryIdDuplicate(c.id, _selectedCategoryIndex!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldHeader('ID', required: true),
          TextField(
            controller: _catIdCtrl,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '例: grand_prize, stage_prize',
            ),
            onChanged: (val) {
              c.id = val;
              _markDirty();
            },
          ),
          if (isDuplicate) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID「${c.id}」は既に他の賞で使用されています。一意のIDを指定してください。',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          _buildFieldHeader('賞名 (name)', required: true),
          TextField(
            controller: _catNameCtrl,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '例: 志魂大賞',
            ),
            onChanged: (val) {
              c.name = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          _buildFieldHeader('説明 (description)'),
          TextField(
            controller: _catDescCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '投票者に表示する賞の説明',
            ),
            onChanged: (val) {
              c.description = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          _buildFieldHeader('補足・ヘルプ文 (shortHelpText)'),
          TextField(
            controller: _catShortHelpCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '短い注意書きや案内',
            ),
            onChanged: (val) {
              c.shortHelpText = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          _buildFieldHeader('ヘルプURL・パス (helpUrl)'),
          TextField(
            controller: _catHelpUrlCtrl,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '例: https://... または /help (任意)',
            ),
            onChanged: (val) {
              c.helpUrl = val;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),

          // Material 3 準拠のカスタム Checkbox 行
          InkWell(
            onTap: () {
              setState(() {
                c.canSkip = !c.canSkip;
                _hasUnsavedChanges = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: c.canSkip,
                    activeColor: const Color(0xFF7C3AED),
                    onChanged: (val) {
                      setState(() {
                        c.canSkip = val ?? false;
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('この賞の投票をスキップ可能にする (canSkip)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('チェックを入れると、投票者が未選択のまま次の賞へ進むことができます', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildFieldHeader('対象団体 (${c.groupIds.isEmpty ? "未選択: すべての団体が対象" : "${c.groupIds.length} 団体選択中"})'),
          Text(
            'チェックを入れた団体のみがこの賞の投票候補になります。何も選択しない場合は全団体が対象になります。',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    c.groupIds = _groups.map((g) => g.id).toList();
                    _hasUnsavedChanges = true;
                  });
                },
                icon: const Icon(Icons.select_all_rounded, size: 16),
                label: const Text('全団体を選択'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    c.groupIds.clear();
                    _hasUnsavedChanges = true;
                  });
                },
                icon: const Icon(Icons.deselect_rounded, size: 16),
                label: const Text('選択をクリア (全対象)'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 高速仮想化スクロール付き団体選択リスト
          Container(
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              itemCount: _groups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final g = _groups[idx];
                final isSelected = c.groupIds.contains(g.id);
                return CheckboxListTile(
                  dense: true,
                  value: isSelected,
                  activeColor: const Color(0xFF7C3AED),
                  title: Text('${g.name} (${g.id})', style: const TextStyle(fontSize: 13)),
                  subtitle: Text('${g.groupName} • ${g.floor}F', style: const TextStyle(fontSize: 11)),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        c.groupIds.add(g.id);
                      } else {
                        c.groupIds.remove(g.id);
                      }
                      _hasUnsavedChanges = true;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _addCategory() {
    setState(() {
      final newIndex = _categories.length + 1;
      final newCat = _EditableCategory(
        id: 'category_$newIndex',
        name: '新しい賞 $newIndex',
        description: '',
        shortHelpText: '',
        helpUrl: '',
        canSkip: false,
        groupIds: [],
      );
      _categories.add(newCat);
      _selectedCategoryIndex = _categories.length - 1;
      _syncCategoryControllers();
      _hasUnsavedChanges = true;
    });
  }

  void _removeSelectedCategory() {
    if (_selectedCategoryIndex == null) return;
    final c = _categories[_selectedCategoryIndex!];

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('賞の削除'),
        content: Text('賞「${c.name}（ID: ${c.id}）」を削除しますか？\nこの操作は「変更を保存」を押すまで Firestore には反映されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('削除'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() {
          _categories.removeAt(_selectedCategoryIndex!);
          if (_categories.isEmpty) {
            _selectedCategoryIndex = null;
          } else if (_selectedCategoryIndex! >= _categories.length) {
            _selectedCategoryIndex = _categories.length - 1;
          }
          _syncCategoryControllers();
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  // ─────────────────────────────────────────
  // タブ 3: 投票期間設定
  // ─────────────────────────────────────────

  Widget _buildPeriodTab(ThemeData theme, bool isDark) {
    final hours = List.generate(24, (i) => i);
    final minutes = List.generate(60, (i) => i);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldHeader('投票開始日時', required: true),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: true),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(DateFormat('yyyy/MM/dd').format(_periodConfig.startDate)),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _periodConfig.startDate.hour,
                  items: hours.map((h) => DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0')))).toList(),
                  onChanged: (newHour) {
                    if (newHour == null) return;
                    setState(() {
                      _periodConfig = _periodConfig.copyWith(
                        startDate: DateTime(
                          _periodConfig.startDate.year,
                          _periodConfig.startDate.month,
                          _periodConfig.startDate.day,
                          newHour,
                          _periodConfig.startDate.minute,
                        ),
                      );
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
                const Text(' 時 '),
                DropdownButton<int>(
                  value: _periodConfig.startDate.minute,
                  items: minutes.map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0')))).toList(),
                  onChanged: (newMin) {
                    if (newMin == null) return;
                    setState(() {
                      _periodConfig = _periodConfig.copyWith(
                        startDate: DateTime(
                          _periodConfig.startDate.year,
                          _periodConfig.startDate.month,
                          _periodConfig.startDate.day,
                          _periodConfig.startDate.hour,
                          newMin,
                        ),
                      );
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
                const Text(' 分'),
              ],
            ),
            const SizedBox(height: 24),

            _buildFieldHeader('投票終了日時', required: true),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: false),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(DateFormat('yyyy/MM/dd').format(_periodConfig.endDate)),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _periodConfig.endDate.hour,
                  items: hours.map((h) => DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0')))).toList(),
                  onChanged: (newHour) {
                    if (newHour == null) return;
                    setState(() {
                      _periodConfig = _periodConfig.copyWith(
                        endDate: DateTime(
                          _periodConfig.endDate.year,
                          _periodConfig.endDate.month,
                          _periodConfig.endDate.day,
                          newHour,
                          _periodConfig.endDate.minute,
                        ),
                      );
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
                const Text(' 時 '),
                DropdownButton<int>(
                  value: _periodConfig.endDate.minute,
                  items: minutes.map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0')))).toList(),
                  onChanged: (newMin) {
                    if (newMin == null) return;
                    setState(() {
                      _periodConfig = _periodConfig.copyWith(
                        endDate: DateTime(
                          _periodConfig.endDate.year,
                          _periodConfig.endDate.month,
                          _periodConfig.endDate.day,
                          _periodConfig.endDate.hour,
                          newMin,
                        ),
                      );
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
                const Text(' 分'),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            InkWell(
              onTap: () {
                setState(() {
                  _periodConfig = _periodConfig.copyWith(
                    maintenanceEnabled: !_periodConfig.maintenanceEnabled,
                  );
                  _hasUnsavedChanges = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _periodConfig.maintenanceEnabled,
                      activeColor: const Color(0xFF7C3AED),
                      onChanged: (val) {
                        setState(() {
                          _periodConfig = _periodConfig.copyWith(
                            maintenanceEnabled: val ?? false,
                          );
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('定期メンテナンスを有効にする', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('毎日決まった時間帯に投票受付を一時停止します', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Opacity(
              opacity: _periodConfig.maintenanceEnabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !_periodConfig.maintenanceEnabled,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldHeader('メンテナンス開始時刻'),
                      Row(
                        children: [
                          DropdownButton<int>(
                            value: _periodConfig.maintenanceStartHour,
                            items: hours.map((h) => DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0')))).toList(),
                            onChanged: (h) {
                              if (h == null) return;
                              setState(() {
                                _periodConfig = _periodConfig.copyWith(maintenanceStartHour: h);
                                _hasUnsavedChanges = true;
                              });
                            },
                          ),
                          const Text(' 時 '),
                          DropdownButton<int>(
                            value: _periodConfig.maintenanceStartMinute,
                            items: minutes.map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0')))).toList(),
                            onChanged: (m) {
                              if (m == null) return;
                              setState(() {
                                _periodConfig = _periodConfig.copyWith(maintenanceStartMinute: m);
                                _hasUnsavedChanges = true;
                              });
                            },
                          ),
                          const Text(' 分'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildFieldHeader('メンテナンス終了時刻'),
                      Row(
                        children: [
                          DropdownButton<int>(
                            value: _periodConfig.maintenanceEndHour,
                            items: hours.map((h) => DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0')))).toList(),
                            onChanged: (h) {
                              if (h == null) return;
                              setState(() {
                                _periodConfig = _periodConfig.copyWith(maintenanceEndHour: h);
                                _hasUnsavedChanges = true;
                              });
                            },
                          ),
                          const Text(' 時 '),
                          DropdownButton<int>(
                            value: _periodConfig.maintenanceEndMinute,
                            items: minutes.map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0')))).toList(),
                            onChanged: (m) {
                              if (m == null) return;
                              setState(() {
                                _periodConfig = _periodConfig.copyWith(maintenanceEndMinute: m);
                                _hasUnsavedChanges = true;
                              });
                            },
                          ),
                          const Text(' 分'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _periodConfig.startDate : _periodConfig.endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _periodConfig = _periodConfig.copyWith(
          startDate: DateTime(
            picked.year,
            picked.month,
            picked.day,
            _periodConfig.startDate.hour,
            _periodConfig.startDate.minute,
          ),
        );
      } else {
        _periodConfig = _periodConfig.copyWith(
          endDate: DateTime(
            picked.year,
            picked.month,
            picked.day,
            _periodConfig.endDate.hour,
            _periodConfig.endDate.minute,
          ),
        );
      }
      _hasUnsavedChanges = true;
    });
  }

  // ─────────────────────────────────────────
  // 下部ステータスバー
  // ─────────────────────────────────────────

  Widget _buildStatusBar(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _hasUnsavedChanges ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
            size: 16,
            color: _hasUnsavedChanges ? Colors.amber.shade700 : Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '団体: ${_groups.length}  |  賞: ${_categories.length}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 編集用ローカルエンティティ
// ─────────────────────────────────────────

class _EditableGroup {
  String id;
  String name;
  String groupName;
  String description;
  String imagePath;
  int floor;
  int? pamphletPage;
  List<GroupCategory> categories;

  _EditableGroup({
    required this.id,
    required this.name,
    required this.groupName,
    required this.description,
    required this.imagePath,
    required this.floor,
    this.pamphletPage,
    required this.categories,
  });
}

class _EditableCategory {
  String id;
  String name;
  String description;
  String shortHelpText;
  String helpUrl;
  bool canSkip;
  List<String> groupIds;

  _EditableCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.shortHelpText,
    required this.helpUrl,
    required this.canSkip,
    required this.groupIds,
  });
}
