import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
// import 'package:hugeicons/hugeicons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/vote_options.dart';
import '../models/group.dart';
import '../widgets/main_layout.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/admin_category_results.dart';
import '../widgets/admin_chart.dart';
import '../widgets/admin_pie_chart.dart';
import '../widgets/admin_mode_selection.dart';
import '../widgets/admin_batch_vote_entry.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_invalidate_vote.dart';
import '../widgets/admin_results_overview.dart';
import '../widgets/admin_documents_view.dart';
import '../main.dart' show themeModeNotifier;
import '../widgets/custom_dialog.dart';
// import 'config_editor_screen.dart';
import '../services/export_service.dart';
import '../platform/platform_utils.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/gaknum_text.dart';


class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    'votes',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vote>? _votes;
  List<UserData> _adminUsers = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  int _selectedCategoryIndex = 0;
  bool? _excludeShikonTop2 = true;
  int? _detailedCategoryIndex;
  AdminMode _currentMode = AdminMode.menu;
  final GlobalKey<AdminBatchVoteEntryState> _batchVoteKey = GlobalKey<AdminBatchVoteEntryState>();
  bool _isBatchVoteSubmitting = false;

  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _excludeShikonTop2 = true;
    _checkLoginAndLoadData();
  }

  Future<void> _checkLoginAndLoadData() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomDialog(
            context: context,
            title: '認証が必要です',
            content: 'このページを表示するには管理者ログインが必要です。',
            closeButtonText: 'OK',
          ).then((_) {
            if (mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        });
      }
    } else {
      setState(() {
        _isLoggedIn = true;
      });
      _initializeControllers();
      await _loadAllData();
    }
  }

  void _initializeControllers() {
    _categoryTabController = TabController(
      length: voteCategories.length,
      vsync: this,
    );
    _categoryTabController.addListener(() {
      if (mounted && !_categoryTabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _categoryTabController.index;
          if (_detailedCategoryIndex != null) {
            _detailedCategoryIndex = _categoryTabController.index;
          }
        });
      }
    });
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await Future.wait([_loadVotes(), _loadAdminUsers()]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  Future<void> _loadVotes() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Vote> votes = [];

        data.forEach((key, value) {
          Map<String, String> selections = {};
          if (value['selections'] != null) {
            (value['selections'] as Map<dynamic, dynamic>).forEach((k, v) {
              selections[k.toString()] = v.toString();
            });
          }
          DateTime timestamp;
          try {
            timestamp = DateTime.parse(value['timestamp'] ?? '');
          } catch (e) {
            timestamp = DateTime.now();
          }
          votes.add(
            Vote(
              id: key.toString(),
              userId: value['uuid']?.toString() ?? '',
              timestamp: timestamp,
              selections: selections,
            ),
          );
        });
        setState(() => _votes = votes);
      } else {
        setState(() => _votes = []);
      }
    } catch (e) {
      print('投票データ読み込みエラー: $e');
      setState(() => _votes = []);
      if (mounted) {
        await showCustomDialog(
          context: context,
          title: 'エラー',
          content: '投票データの読み込みに失敗しました。',
          closeButtonText: '閉じる',
        );
      }
    }
  }

  Future<void> _loadAdminUsers() async {
    try {
      final snapshot = await _firestore.collection('admin_users').get();
      List<UserData> users =
          snapshot.docs
              .map(
                (doc) => UserData(
                  uid: doc.id,
                  email: doc['email'],
                  name: doc['name'] ?? '',
                  createdAt: (doc['createdAt'] as Timestamp).toDate(),
                ),
              )
              .toList();
      setState(() => _adminUsers = users);
    } catch (e) {
      print('管理者ユーザー読み込みエラー: $e');
      if (mounted) {
        await showCustomDialog(
          context: context,
          title: 'エラー',
          content: '管理者ユーザーの読み込みに失敗しました。',
          closeButtonText: '閉じる',
        );
      }
    }
  }

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

  int _getTotalCategoryVotes(String categoryId) {
    if (_votes == null) return 0;
    int count = 0;
    for (var vote in _votes!) {
      if (vote.selections.containsKey(categoryId) && vote.selections[categoryId]!.isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  Set<String> _getShikonTop2GroupIds() {
    if (_votes == null || _votes!.isEmpty) return {};
    final results = _getCategoryResults('Shikon_award');
    final shikonCat = voteCategories.firstWhere(
      (c) => c.id == 'Shikon_award',
      orElse: () => voteCategories.first,
    );
    List<MapEntry<Group, int>> shikonSorted = [];
    for (var group in shikonCat.groups) {
      shikonSorted.add(MapEntry(group, results[group.id] ?? 0));
    }
    shikonSorted.sort((a, b) => b.value.compareTo(a.value));

    // 票数を獲得している上位2団体IDを特定
    final top2 = shikonSorted
        .where((e) => e.value > 0)
        .take(2)
        .map((e) => e.key.id)
        .toSet();
    return top2;
  }

  List<MapEntry<Group, int>> _getSortedResults(
    String categoryId, {
    bool? applyShikonExclusion,
  }) {
    final results = _getCategoryResults(categoryId);
    final category = voteCategories.firstWhere((c) => c.id == categoryId);
    List<MapEntry<Group, int>> sortedResults = [];
    for (var group in category.groups) {
      sortedResults.add(MapEntry(group, results[group.id] ?? 0));
    }
    sortedResults.sort((a, b) => b.value.compareTo(a.value));

    // 紫紺賞1位・2位の除外集計処理
    final bool shouldExclude = (applyShikonExclusion ?? _excludeShikonTop2 ?? true) == true;
    if (shouldExclude && categoryId != 'Shikon_award') {
      final excludedIds = _getShikonTop2GroupIds();
      if (excludedIds.isNotEmpty) {
        sortedResults = sortedResults.where((e) => !excludedIds.contains(e.key.id)).toList();
      }
    }

    return sortedResults;
  }

  String get _appBarTitle {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth >= 720;

    switch (_currentMode) {
      case AdminMode.menu:
        return '管理者パネル';
      case AdminMode.results:
        if (isWide) {
          return '投票結果の確認';
        }
        if (_detailedCategoryIndex != null && _detailedCategoryIndex! < voteCategories.length) {
          return '${voteCategories[_detailedCategoryIndex!].name} の詳細結果';
        }
        return '投票結果サマリー';
      case AdminMode.userManagement:
        return '管理者ユーザー管理';
      case AdminMode.batchVote:
        return '投票の一括追加';
      case AdminMode.invalidateVote:
        return '投票番号の無効化';
      case AdminMode.documents:
        return 'ドキュメント';
    }
  }

  Widget _buildBody() {
    switch (_currentMode) {
      case AdminMode.menu:
        return AdminModeSelection(
          onSelectMode: (mode) {
            setState(() {
              _currentMode = mode;
              if (mode == AdminMode.results) {
                _detailedCategoryIndex = null;
              }
            });
          },
          voteCount: _votes?.length ?? 0,
          adminUserCount: _adminUsers.length,
        );
      case AdminMode.results:
        return _buildResultsTab();
      case AdminMode.userManagement:
        return _buildUserManagementTab();
      case AdminMode.batchVote:
        return AdminBatchVoteEntry(
          key: _batchVoteKey,
          onVotesSubmitted: _loadAllData,
          onSubmittingChanged: (submitting) {
            setState(() {
              _isBatchVoteSubmitting = submitting;
            });
          },
        );
      case AdminMode.invalidateVote:
        return AdminInvalidateVote(
          onDataChanged: _loadAllData,
        );
      case AdminMode.documents:
        return const AdminDocumentsView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isLoggedIn) {
      return const Scaffold(
        body: Center(
          child: M3ELoadingIndicator(
            variant: M3ELoadingIndicatorVariant.defaultStyle,
            elevation: 0,
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth >= 720;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isWide) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─ 左：管理者サイドバー ─────────────────
            AdminSidebar(
              currentMode: _currentMode,
              onSelectMode: (mode) {
                setState(() {
                  _currentMode = mode;
                  if (mode == AdminMode.results) {
                    _detailedCategoryIndex = null;
                  }
                });
              },
              onRefresh: _loadAllData,
              onToggleTheme: () {
                final isCurrentDark = Theme.of(context).brightness == Brightness.dark;
                themeModeNotifier.value = isCurrentDark ? ThemeMode.light : ThemeMode.dark;
              },
              onLogout: () async {
                await _auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              isDark: isDark,
            ),
            // ─ 中央：コンテンツ領域 ─────────────────
            Expanded(
              child: Column(
                children: [
                  // PC・大画面用の上部ヘッダー
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          _appBarTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _buildAppBarCircleButton(
                          icon: Icons.refresh,
                          onPressed: _loadAllData,
                        ),
                        if (_currentMode == AdminMode.results)
                          _buildAppBarCircleButton(
                            icon: Icons.file_download,
                            onPressed: _exportResults,
                          ),
                        _buildAppBarCircleButton(
                          icon: Icons.help,
                          onPressed: _showHelpDialog,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildAppBarCircleButton(
                            icon: Icons.logout,
                            onPressed: () async {
                              await _auth.signOut();
                              if (mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
            // ─ 右：縦型ナビゲーションレール（FoldやPC用） ─────────────
            VerticalNavBar(
              onBack: () {
                if (_currentMode != AdminMode.menu) {
                  setState(() {
                    _currentMode = AdminMode.menu;
                  });
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              onNext: _currentMode == AdminMode.batchVote
                  ? () => _batchVoteKey.currentState?.submitVotes()
                  : null,
              nextLabel: _currentMode == AdminMode.batchVote ? '登録' : '次へ',
              nextLoading: _isBatchVoteSubmitting,
              onHome: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
              onMenu: _showAdminMenu,
            ),
          ],
        ),
      );
    }

    // モバイル用表示（スマートフォン）
    return MainLayout(
      title: _appBarTitle,
      icon: Icons.admin_panel_settings,
      responsiveRail: false,
      onHome:
          () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/', (route) => false),
      onBack: () {
        if (_currentMode == AdminMode.results && _detailedCategoryIndex != null) {
          setState(() {
            _detailedCategoryIndex = null;
          });
        } else if (_currentMode != AdminMode.menu) {
          setState(() {
            _currentMode = AdminMode.menu;
          });
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      onNext: _currentMode == AdminMode.batchVote
          ? () => _batchVoteKey.currentState?.submitVotes()
          : null,
      nextLabel: _currentMode == AdminMode.batchVote ? '登録' : '次へ',
      nextLoading: _isBatchVoteSubmitting,
      onMenu: _showAdminMenu,
      child: _buildBody(),
    );
  }

  void _showAdminMenu() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    M3EBottomSheet.show(
      context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      '管理画面メニュー',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMenuModeTile(
                  sheetContext: sheetContext,
                  icon: Icons.home_rounded,
                  title: '管理者メニュートップ',
                  subtitle: 'モード選択画面に戻る',
                  isSelected: _currentMode == AdminMode.menu,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _currentMode = AdminMode.menu);
                  },
                ),
                _buildMenuModeTile(
                  sheetContext: sheetContext,
                  icon: Icons.bar_chart_rounded,
                  title: '投票結果の確認',
                  subtitle: '各賞の集計、グラフ、Excel出力',
                  isSelected: _currentMode == AdminMode.results,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() {
                      _currentMode = AdminMode.results;
                      _detailedCategoryIndex = null;
                    });
                  },
                ),
                _buildMenuModeTile(
                  sheetContext: sheetContext,
                  icon: Icons.playlist_add_check_rounded,
                  title: '投票の一括追加',
                  subtitle: '10件までの投票データを一括入力・登録',
                  isSelected: _currentMode == AdminMode.batchVote,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _currentMode = AdminMode.batchVote);
                  },
                ),
                _buildMenuModeTile(
                  sheetContext: sheetContext,
                  icon: Icons.manage_accounts_rounded,
                  title: '管理者ユーザー管理',
                  subtitle: '管理者アカウントの管理・追加',
                  isSelected: _currentMode == AdminMode.userManagement,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _currentMode = AdminMode.userManagement);
                  },
                ),
                _buildMenuModeTile(
                  sheetContext: sheetContext,
                  icon: Icons.block_rounded,
                  title: '投票番号の無効化',
                  subtitle: '紛失・汚損・不正利用等の番号無効化',
                  isSelected: _currentMode == AdminMode.invalidateVote,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _currentMode = AdminMode.invalidateVote);
                  },
                ),
                _buildMenuModeTile(
                  sheetContext: sheetContext,
                  icon: Icons.description_rounded,
                  title: 'ドキュメント',
                  subtitle: '各種マニュアル、セットアップ、各種情報',
                  isSelected: _currentMode == AdminMode.documents,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _currentMode = AdminMode.documents);
                  },
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: M3EButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _loadAllData();
                        },
                        style: M3EButtonStyle.tonal,
                        size: M3EButtonSize.sm,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 16),
                            SizedBox(width: 6),
                            Text('更新'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: M3EButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          final isCurrentDark = Theme.of(context).brightness == Brightness.dark;
                          themeModeNotifier.value = isCurrentDark ? ThemeMode.light : ThemeMode.dark;
                        },
                        style: M3EButtonStyle.tonal,
                        size: M3EButtonSize.sm,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            const Text('テーマ'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: M3EButton(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await _auth.signOut();
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          }
                        },
                        style: M3EButtonStyle.tonal,
                        size: M3EButtonSize.sm,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 16),
                            SizedBox(width: 6),
                            Text('ログアウト'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuModeTile({
    required BuildContext sheetContext,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportResults() async {
    try {
      final bytes = ExportService.buildResultsWorkbook(_getSortedResults);
      final now = DateTime.now();
      final filename =
          '投票結果_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';
      PlatformUtils.downloadBytes(
        bytes,
        filename,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      await showCustomDialog(
        context: context,
        title: 'エクスポート完了',
        content: 'Excelファイルを保存しました。',
        closeButtonText: 'OK',
      );
    } catch (e) {
      await showCustomDialog(
        context: context,
        title: 'エクスポート失敗',
        content: 'エクスポート中にエラー: ${e.toString()}',
        closeButtonText: '閉じる',
      );
    }
  }

  void _showHelpDialog() {
    showCustomDialog(
      context: context,
      title: 'ヘルプ',
      content: '管理者パネルの詳細な使用方法については、以下の詳細情報をご覧ください。',
      showWikiLink: true,
      wikiUrl: 'https://shikon-voteapp.github.io/guide/public/',
      closeButtonText: '閉じる',
    );
  }

  Widget _buildResultsTab() {
    _excludeShikonTop2 ??= true;
    final bool isExcludingShikon = (_excludeShikonTop2 ?? true) == true;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth >= 720;

    if (isWide) {
      // PC & タブレット: 2カラム表示（左: サマリー, 右: それぞれの結果）
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 左カラム（サマリー一覧）
          SizedBox(
            width: 410,
            child: AdminResultsOverview(
              votes: _votes,
              excludeShikonTop2: isExcludingShikon,
              selectedCategoryIndex: _selectedCategoryIndex,
              isCompact: true,
              onExcludeShikonTop2Changed: (val) {
                setState(() {
                  _excludeShikonTop2 = val;
                });
              },
              onSelectCategory: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                  _categoryTabController.index = index;
                });
              },
              getSortedResults: _getSortedResults,
              getTotalCategoryVotes: _getTotalCategoryVotes,
              getShikonTop2GroupIds: _getShikonTop2GroupIds,
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          // 右カラム（選択された賞の詳細結果）
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategoryTabs(),
                Expanded(
                  child: _votes == null || _votes!.isEmpty
                      ? const Center(child: Text('投票データがありません'))
                      : _buildCategoryResults(),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // スマートフォン: 1カラム表示（サマリー ⇄ 詳細ドリルダウン）
    if (_detailedCategoryIndex == null) {
      return AdminResultsOverview(
        votes: _votes,
        excludeShikonTop2: isExcludingShikon,
        selectedCategoryIndex: null,
        onExcludeShikonTop2Changed: (val) {
          setState(() {
            _excludeShikonTop2 = val;
          });
        },
        onSelectCategory: (index) {
          setState(() {
            _detailedCategoryIndex = index;
            _selectedCategoryIndex = index;
            _categoryTabController.index = index;
          });
        },
        getSortedResults: _getSortedResults,
        getTotalCategoryVotes: _getTotalCategoryVotes,
        getShikonTop2GroupIds: _getShikonTop2GroupIds,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildReturnToOverviewBar(),
        _buildCategoryTabs(),
        Expanded(
          child: _votes == null || _votes!.isEmpty
              ? const Center(child: Text('投票データがありません'))
              : _buildCategoryResults(),
        ),
      ],
    );
  }

  Widget _buildReturnToOverviewBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentCat = voteCategories[_selectedCategoryIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          M3EButton(
            onPressed: () {
              setState(() {
                _detailedCategoryIndex = null;
              });
            },
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 16),
                SizedBox(width: 6),
                Text('サマリー一覧に戻る'),
              ],
            ),
          ),
          const Spacer(),
          if (currentCat.id != 'Shikon_award') ...[
            Text(
              '紫紺賞除外: ',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Switch.adaptive(
              value: (_excludeShikonTop2 ?? true) == true,
              onChanged: (val) {
                setState(() {
                  _excludeShikonTop2 = val;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: TabBar(
        controller: _categoryTabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: voteCategories.map((category) => Tab(text: category.name)).toList(),
      ),
    );
  }

  Widget _buildCategoryResults() {
    final category = voteCategories[_selectedCategoryIndex];
    final results = _getSortedResults(category.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${category.name} の結果',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '部門有効投票数: '),
                gakNumSpan(
                  '${_getTotalCategoryVotes(category.id)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                TextSpan(text: '票（総投票者数: ${_votes?.length ?? 0}人）'),
              ],
            ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),
          AdminCategoryResults(results: results),
          SizedBox(height: 24),
          SizedBox(height: 300, child: AdminChart(results: results)),
          SizedBox(height: 24),
          SizedBox(height: 300, child: AdminPieChart(results: results)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: _buildGlassButton(
                label: '全投票データをクリア',
                icon: Icons.delete_sweep,
                color: Theme.of(context).colorScheme.error,
                onPressed: _showClearConfirmation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('管理者一覧', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _adminUsers.isEmpty
              ? const Center(child: Text('管理者がいません'))
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _adminUsers.length,
                itemBuilder: (context, index) {
                  final user = _adminUsers[index];
                  return _buildGlassCard(
                    child: ListTile(
                      tileColor: Colors.transparent,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${user.name.isNotEmpty ? user.name + ' • ' : ''}追加日: ${_formatDate(user.createdAt)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteUserConfirmation(user),
                      ),
                    ),
                  );
                },
              ),
          const SizedBox(height: 16),
          _buildGlassButton(
            label: '新規管理者を追加',
            icon: Icons.person_add,
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
    );
  }

  // 設定エディタ機能は管理画面から削除

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  void _showClearConfirmation() {
    showCustomDialog(
      context: context,
      title: '全投票データを削除',
      content: 'すべての投票データを削除します。この操作は元に戻せません。よろしいですか？',
      closeButtonText: 'キャンセル',
      primaryActionText: '削除する',
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        await _database.remove();
        _loadAllData();
      },
    );
  }

  void _showDeleteUserConfirmation(UserData user) {
    showCustomDialog(
      context: context,
      title: '管理者を削除',
      content: '${user.email} を管理者から削除しますか？\nこの操作は元に戻せません。',
      closeButtonText: 'キャンセル',
      primaryActionText: '削除する',
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        await _deleteAdminUser(user);
      },
    );
  }

  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showCustomDialog(
      context: context,
      title: '新規管理者を追加',
      contentWidget: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'メールアドレスを入力してください' : null,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード (6文字以上)'),
              obscureText: true,
              validator: (value) => value!.length < 6 ? '6文字以上で入力してください' : null,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: '名前 (任意)'),
            ),
          ],
        ),
      ),
      closeButtonText: 'キャンセル',
      primaryActionText: '追加',
      onPrimaryAction: () async {
        if (formKey.currentState!.validate()) {
          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(
                    child: M3ELoadingIndicator(
                      variant: M3ELoadingIndicatorVariant.defaultStyle,
                      elevation: 0,
                    ),
                  ),
            );

            await _createAdminUser(
              email: emailController.text.trim(),
              password: passwordController.text,
              name: nameController.text.trim(),
            );

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            await showCustomDialog(
              context: context,
              title: '完了',
              content: '管理者を追加しました',
              closeButtonText: 'OK',
            );
          } catch (e) {
            Navigator.of(context).pop();
            await showCustomDialog(
              context: context,
              title: 'エラー',
              content: 'エラーが発生しました: ${e.toString()}',
              closeButtonText: '閉じる',
            );
          }
        }
      },
    );
  }

  Future<void> _createAdminUser({
    required String email,
    required String password,
    String name = '',
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore
        .collection('admin_users')
        .doc(userCredential.user!.uid)
        .set({
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.email ?? 'unknown',
        });
    _loadAdminUsers();
  }

  Future<void> _deleteAdminUser(UserData user) async {
    if (_auth.currentUser?.uid == user.uid) {
      await showCustomDialog(
        context: context,
        title: '操作できません',
        content: '自分自身を削除することはできません',
        closeButtonText: 'OK',
      );
      return;
    }
    await _firestore.collection('admin_users').doc(user.uid).delete();
    _loadAdminUsers();
    await showCustomDialog(
      context: context,
      title: '完了',
      content: '${user.email} を削除しました',
      closeButtonText: 'OK',
    );
  }

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return M3EButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      style: color != null ? M3EButtonStyle.filled : M3EButtonStyle.tonal,
      size: M3EButtonSize.md,
      shape: M3EButtonShape.round,
    );
  }

  Widget _buildAppBarCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: M3EIconButton(
        icon: Icon(icon, size: 20.0),
        onPressed: onPressed,
        size: M3EIconButtonSize.sm,
        variant: M3EIconButtonVariant.tonal,
        shape: M3EIconButtonShapeVariant.round,
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: M3ECard(
        variant: M3ECardVariant.elevated,
        elevation: 1.5,
        borderRadius: BorderRadius.circular(16.0),
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}


class Vote {
  final String id;
  final String userId;
  final DateTime timestamp;
  final Map<String, String> selections;

  Vote({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.selections,
  });
}

class UserData {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  UserData({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });
}
