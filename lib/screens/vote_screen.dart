import '../models/group.dart' hide VoteCategory;
import '../config/vote_options.dart';
import '../widgets/main_layout.dart';
import '../platform/platform_utils.dart';
import 'confirm_screen.dart';
import '../widgets/custom_dialog.dart';
import '../services/accessibility_service.dart';
import 'package:flutter/material.dart';
import '../widgets/neumorphic_wrappers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../widgets/liquid_glass.dart';

class VoteScreen extends StatefulWidget {
  final String uuid;
  final int categoryIndex;
  final Map<String, String> selections;
  final bool isGridView;
  final bool restoreSelection;
  // 確認画面から特定カテゴリのみ編集して戻るモード
  final bool returnToConfirm;

  const VoteScreen({
    super.key,
    required this.uuid,
    required this.categoryIndex,
    this.selections = const {},
    this.isGridView = true,
    this.restoreSelection = true,
    this.returnToConfirm = false,
  });

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  late Map<String, String> currentSelections;
  late int currentCategoryIndex;
  Group? _selectedGroup;
  List<Group> _filteredGroups = [];
  int? _selectedFloor;
  late bool _isGridView;
  late bool _returnToConfirm;

  @override
  void initState() {
    super.initState();
    currentSelections = Map.from(widget.selections);
    currentCategoryIndex = widget.categoryIndex;
    final category = voteCategories[currentCategoryIndex];
    _isGridView = widget.isGridView;
    _returnToConfirm = widget.returnToConfirm;

    // 初期グループリストを設定
    _filteredGroups = category.groups;

    // 画面復元時に選択状態を復元するかどうか
    if (widget.restoreSelection) {
      String? selectedId = currentSelections[category.id];
      if (selectedId != null) {
        try {
          _selectedGroup = category.groups.firstWhere(
            (g) => g.id == selectedId,
          );
        } catch (e) {
          // IDに対応するグループがない場合
          _selectedGroup = null;
        }
      }
    }

    // 初回表示時にヘルプを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showInitialHelp(context);
      }
    });
  }

  void _showInitialHelp(BuildContext context) {
    final category = voteCategories[currentCategoryIndex];
    final helpContent =
        category.shortHelpText != null && category.shortHelpText!.isNotEmpty
            ? '${category.description}\n\n${category.shortHelpText}'
            : category.description;

    showCustomDialog(
      context: context,
      title: '${category.name} について',
      content: helpContent,
      closeButtonText: '閉じる',
      showWikiLink: true,
      imagePath: 'resources/sho_setsumei.png',
    );
  }

  void _filterByFloor(int? floor) {
    setState(() {
      _selectedFloor = floor;
      final category = voteCategories[currentCategoryIndex];
      if (floor == null) {
        _filteredGroups = category.groups;
      } else {
        _filteredGroups =
            category.groups.where((g) => g.floor == floor).toList();
      }
      // フィルタリングで選択中のグループが消えた場合は選択を解除
      if (_selectedGroup != null &&
          !_filteredGroups.any((g) => g.id == _selectedGroup!.id)) {
        _selectedGroup = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = voteCategories[currentCategoryIndex];
    final helpContent =
        category.shortHelpText != null && category.shortHelpText!.isNotEmpty
            ? '${category.description}\n\n${category.shortHelpText}'
            : category.description;
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.height < 700;
    final bool isZoomed = AccessibilityService.isZoomed.value;

    // ─── 投票ボタンのラベルとアクション計算 ───────────────────────────
    VoidCallback? voteOnPressed;
    String voteButtonText;

    if (_returnToConfirm) {
      voteButtonText = 'この内容に変更する';
      voteOnPressed = () {
        if (_selectedGroup == null && !category.canSkip) {
          showCustomDialog(
            context: context,
            title: '選択してください',
            content: '${category.name} の投票先を選択してから実行してください。',
            closeButtonText: 'OK',
          );
          return;
        }
        final group = _selectedGroup;
        if (group != null) {
          showCustomDialog(
            context: context,
            imagePath: group.imagePath,
            title: '${category.name}の変更確認',
            content: '「${group.name}」に変更します。よろしいですか？',
            closeButtonText: '戻る',
            primaryActionText: '変更を反映する',
            enablePrimaryLoading: true,
            minLoadingMs: 1000,
            maxLoadingMs: 1400,
            onPrimaryAction: () {
              Navigator.of(context).pop();
              currentSelections[category.id] = group.id;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmScreen(
                    uuid: widget.uuid,
                    selections: currentSelections,
                    isGridView: _isGridView,
                  ),
                ),
              );
            },
          );
        } else {
          showCustomDialog(
            context: context,
            title: '${category.name} を未選択で反映しますか？',
            content: 'このカテゴリの投票先を未選択として確認画面に戻ります。',
            closeButtonText: '戻る',
            primaryActionText: '未選択で反映',
            enablePrimaryLoading: true,
            minLoadingMs: 800,
            maxLoadingMs: 1200,
            onPrimaryAction: () {
              Navigator.of(context).pop();
              currentSelections.remove(category.id);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmScreen(
                    uuid: widget.uuid,
                    selections: currentSelections,
                    isGridView: _isGridView,
                  ),
                ),
              );
            },
          );
        }
      };
    } else if (_selectedGroup != null) {
      voteButtonText = '投票する';
      voteOnPressed = () => _showConfirmationDialog(_selectedGroup!);
    } else {
      if (category.canSkip) {
        voteButtonText = 'スキップする';
        voteOnPressed = () {
          showCustomDialog(
            context: context,
            title: '${category.name} をスキップしますか？',
            content: 'このカテゴリの投票先を選択せずに次へ進みます。',
            closeButtonText: '戻る',
            primaryActionText: 'スキップする',
            enablePrimaryLoading: true,
            minLoadingMs: 1300,
            maxLoadingMs: 1700,
            onPrimaryAction: () {
              Navigator.of(context).pop();
              _navigate(1);
            },
          );
        };
      } else {
        voteButtonText = '投票する';
        voteOnPressed = () {
          showCustomDialog(
            context: context,
            title: '選択してください',
            content: '${category.name} の投票先を選択してから「投票する」を押してください。',
            closeButtonText: 'OK',
          );
        };
      }
    }

    final bool isWide = MediaQuery.of(context).size.width >= 720;

    return MainLayout(
      title: '投票画面 ${currentCategoryIndex + 1}/${voteCategories.length}',
      icon: Icons.how_to_vote,
      helpTitle: '${category.name} について',
      helpContent: helpContent,
      onHome: () => PlatformUtils.reloadApp(),
      onBack:
          currentCategoryIndex > 0 && !_returnToConfirm
              ? () => _navigate(-1)
              : null,
      onNext: voteOnPressed,
      nextLabel: voteButtonText,
      extendBehindBottomBar: false,
      responsiveRail: true,
      child: isWide
          ? _buildWideTwoPaneLayout(isCompact: isCompact, isZoomed: isZoomed)
          : _buildMobileLayout(isCompact: isCompact, isZoomed: isZoomed),
    );
  }

  // ─── モバイル用 1ペインレイアウト ─────────────────────────────────
  Widget _buildMobileLayout({required bool isCompact, required bool isZoomed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGroupDetailHeader(isCompact: isCompact),
        _buildControlsToolbar(isCompact: isCompact, isZoomed: isZoomed),
        Expanded(
          child: _buildAnimatedGroupView(
            forceList: isCompact || isZoomed,
          ),
        ),
      ],
    );
  }

  // ─── Fold・タブレット・PC用 2ペインレイアウト ─────────────────────────
  Widget _buildWideTwoPaneLayout({required bool isCompact, required bool isZoomed}) {
    final width = MediaQuery.of(context).size.width;
    final double leftPaneWidth = (width * 0.33).clamp(320.0, 420.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─ 左ペイン：投票先詳細ウィンドウ ─────────────────
          SizedBox(
            width: leftPaneWidth,
            child: _buildLeftDetailPane(),
          ),

          const SizedBox(width: 16.0),

          // ─ 右ペイン：投票先一覧 ─────────────────────────
          Expanded(
            child: _buildRightCandidatePane(isCompact: isCompact, isZoomed: isZoomed),
          ),
        ],
      ),
    );
  }

  // ─── 左ペイン：投票先詳細ウィンドウ（2ペイン用） ─────────────────────
  Widget _buildLeftDetailPane() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = voteCategories[currentCategoryIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // カテゴリヘッダーバナー
        M3ECard(
          variant: M3ECardVariant.filled,
          borderRadius: BorderRadius.circular(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' の投票先詳細',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12.0),

        // 投票先詳細ウィンドウ
        Expanded(
          child: _selectedGroup == null
              ? M3ECard(
                  variant: M3ECardVariant.elevated,
                  elevation: 1.0,
                  borderRadius: BorderRadius.circular(20.0),
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.touch_app_outlined,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '投票先が未選択です',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '右側の一覧から投票したい団体をクリックすると、ここに詳細が表示されます。',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        M3EButton(
                          onPressed: () => _showInitialHelp(context),
                          style: M3EButtonStyle.tonal,
                          size: M3EButtonSize.sm,
                          shape: M3EButtonShape.round,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, size: 16),
                              SizedBox(width: 6),
                              Text('この賞の説明を見る', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : M3ECard(
                  variant: M3ECardVariant.elevated,
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(20.0),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ステータスバー（選択中 + 選択解除ボタン）
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: colorScheme.onPrimaryContainer),
                                const SizedBox(width: 6),
                                Text(
                                  '選択中',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedGroup = null),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('選択解除', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 画像
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Image.asset(
                            _selectedGroup!.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colorScheme.secondaryContainer,
                              child: const Center(child: Icon(Icons.broken_image, size: 40)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 団体名 & 企画名
                      Text(
                        _selectedGroup!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedGroup!.groupName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // チップ（階数、部門、パンフレット）
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildDetailTag(
                            icon: Icons.location_on_outlined,
                            label: _selectedGroup!.floor == 4 ? 'ステージ' : '${_selectedGroup!.floor}階',
                          ),
                          _buildDetailTag(
                            icon: Icons.category_outlined,
                            label: groupCategoryNames[_selectedGroup!.categories.first]!,
                          ),
                          if (_selectedGroup!.pamphletPage != null)
                            _buildDetailTag(
                              icon: Icons.menu_book_outlined,
                              label: 'P${_selectedGroup!.pamphletPage}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // 説明文（スクロール可能）
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            _selectedGroup!.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDetailTag({required IconData icon, required String label}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 右ペイン：投票先一覧（2ペイン用） ─────────────────────────────
  Widget _buildRightCandidatePane({required bool isCompact, required bool isZoomed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildControlsToolbar(isCompact: isCompact, isZoomed: isZoomed),
        const SizedBox(height: 4.0),
        Expanded(
          child: _buildAnimatedGroupView(forceList: isCompact || isZoomed),
        ),
      ],
    );
  }

  // 画面内のグリッド/リスト領域の切替・フィルタ変更にアニメーションを付与
  Widget _buildAnimatedGroupView({bool forceList = false}) {
    final viewKey = ValueKey<String>(
      'view-${(forceList ? false : _isGridView) ? 'grid' : 'list'}-floor-${_selectedFloor ?? 'all'}',
    );
    final child =
        (forceList ? false : _isGridView)
            ? _buildGroupGridView()
            : _buildGroupListView();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (widget, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: widget),
        );
      },
      child: KeyedSubtree(key: viewKey, child: child),
    );
  }

  Widget _buildGroupDetailHeader({required bool isCompact}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = voteCategories[currentCategoryIndex];
    // 縦型表示時、選択の有無に関わらず高さを固定して画面のガタつきを防止
    final double fixedHeaderHeight = isCompact ? 92.0 : 108.0;

    Widget headerContent;
    if (_selectedGroup == null) {
      headerContent = SizedBox(
        height: fixedHeaderHeight,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: ' に投票する団体を選択',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 15,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '一覧からタップして選択してください',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      headerContent = SizedBox(
        height: fixedHeaderHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' 選択中',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: theme.colorScheme.onPrimaryContainer),
                        const SizedBox(width: 3),
                        Text(
                          '詳細を見る',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 6, thickness: 0.8),
              Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _selectedGroup!.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.secondaryContainer,
                          child: const Icon(Icons.broken_image, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedGroup!.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _selectedGroup!.groupName,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${_selectedGroup!.floor == 4 ? 'ステージ' : '${_selectedGroup!.floor}階'}・${groupCategoryNames[_selectedGroup!.categories.first]!}'
                          '${_selectedGroup!.pamphletPage != null ? '・P${_selectedGroup!.pamphletPage}' : ''}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: _selectedGroup == null
            ? null
            : () => _showGroupDetailDialog(_selectedGroup!),
        behavior: HitTestBehavior.opaque,
        child: M3ECard(
          variant: M3ECardVariant.elevated,
          elevation: 1.0,
          borderRadius: BorderRadius.circular(16.0),
          padding: EdgeInsets.zero,
          child: headerContent,
        ),
      ),
    );
  }

  Widget _buildControlsToolbar({required bool isCompact, required bool isZoomed}) {
    final floors = [1, 2, 3, 4]; // 1,2,3階とステージ(4)
    final floorLabels = {1: '1階', 2: '2階', 3: '3階', 4: 'ステージ'};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFloorChip(
                    label: 'すべて',
                    isSelected: _selectedFloor == null,
                    onTap: () => _filterByFloor(null),
                  ),
                  const SizedBox(width: 6),
                  ...floors.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: _buildFloorChip(
                        label: floorLabels[f]!,
                        isSelected: _selectedFloor == f,
                        onTap: () => _filterByFloor(f),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCompact && !isZoomed) ...[
            const SizedBox(width: 8),
            _buildViewToggle(),
          ],
        ],
      ),
    );
  }

  Widget _buildFloorChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color bg = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    final Color fg = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return M3ECard(
      variant: M3ECardVariant.filled,
      elevation: 0,
      borderRadius: BorderRadius.circular(12.0),
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: Icons.grid_view,
            label: 'グリッド',
            isSelected: _isGridView,
            onPressed: () => setState(() => _isGridView = true),
          ),
          const SizedBox(width: 2),
          _buildToggleButton(
            icon: Icons.list,
            label: 'リスト',
            isSelected: !_isGridView,
            onPressed: () => setState(() => _isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final Color bg = isSelected
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;
    final Color textColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    final Color iconColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupGridView() {
    final theme = Theme.of(context);
    if (_filteredGroups.isEmpty) {
      return Center(
        child: Text(
          '該当する団体がありません',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 横幅に応じて動的に列数を決定（1列あたり約165px）
        const double horizontalPadding = 32.0; // 左右16px
        final double availableWidth = (constraints.maxWidth - horizontalPadding).clamp(100.0, 5000.0);
        final int crossAxisCount = (availableWidth / 165.0).floor().clamp(2, 10);
        final double itemWidth = availableWidth / crossAxisCount;
        final double childAspectRatio = (itemWidth / (itemWidth + 42.0)).clamp(0.74, 0.84);

        return AnimationLimiter(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4.0,
            radius: const Radius.circular(8),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: _filteredGroups.length,
              itemBuilder: (context, index) {
                final group = _filteredGroups[index];
                final isSelected = _selectedGroup?.id == group.id;
                final category = voteCategories[currentCategoryIndex];
                const String shikonId = 'Shikon_award';
                final filteredOtherVotedEntries =
                    currentSelections.entries
                        .where(
                          (entry) =>
                              entry.key != category.id &&
                              entry.value == group.id &&
                              entry.key != shikonId,
                        )
                        .toList();
                final bool isVotedInOtherCategory =
                    category.id == shikonId
                        ? false
                        : filteredOtherVotedEntries.isNotEmpty;

                return animatedItem(
                  index: index,
                  child: GestureDetector(
                    onTap: () {
                      if (isVotedInOtherCategory) {
                        final votedCategoryKey =
                            filteredOtherVotedEntries.first.key;
                        final votedCategory = voteCategories.firstWhere(
                          (cat) => cat.id == votedCategoryKey,
                        );
                        _showAlreadyVotedDialog(
                          group,
                          votedCategory.name,
                          category.name,
                        );
                      } else {
                        setState(() {
                          // 既に選択されている場合は選択を解除、そうでなければ選択
                          _selectedGroup = isSelected ? null : group;
                        });
                      }
                    },
                    child: Opacity(
                      opacity: isVotedInOtherCategory ? 0.5 : 1.0,
                      child: neumorphicCard(
                        context: context,
                        depth: isSelected ? 2.0 : 6.0,
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7),
                                ),
                                child: Image.asset(
                                  group.imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: theme.colorScheme.secondaryContainer,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.error_outline,
                                          color:
                                              theme
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text(
                                group.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupListView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_filteredGroups.isEmpty) {
      return Center(
        child: Text(
          '該当する団体がありません',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return AnimationLimiter(
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(8),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _filteredGroups.length,
          itemBuilder: (context, index) {
            final group = _filteredGroups[index];
            final isSelected = _selectedGroup?.id == group.id;
            final category = voteCategories[currentCategoryIndex];
            const String shikonId = 'Shikon_award';
            final filteredOtherVotedEntries =
                currentSelections.entries
                    .where(
                      (entry) =>
                          entry.key != category.id &&
                          entry.value == group.id &&
                          entry.key != shikonId,
                    )
                    .toList();
            final bool isVotedInOtherCategory =
                category.id == shikonId
                    ? false
                    : filteredOtherVotedEntries.isNotEmpty;

            return animatedItem(
              index: index,
              child: GestureDetector(
                onTap: () {
                  if (isVotedInOtherCategory) {
                    final votedCategoryKey =
                        filteredOtherVotedEntries.first.key;
                    final votedCategory = voteCategories.firstWhere(
                      (cat) => cat.id == votedCategoryKey,
                    );
                    _showAlreadyVotedDialog(
                      group,
                      votedCategory.name,
                      category.name,
                    );
                  } else {
                    setState(() {
                      // 既に選択されている場合は選択を解除、そうでなければ選択
                      _selectedGroup = isSelected ? null : group;
                    });
                  }
                },
                child: Opacity(
                  opacity: isVotedInOtherCategory ? 0.5 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: neumorphicCard(
                      context: context,
                      depth: isSelected ? 2.0 : 8.0,
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : theme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  group.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: colorScheme.secondaryContainer,
                                      ),
                                ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    group.groupName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    group.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${group.floor == 4 ? '' : '${group.floor}階・'}${groupCategoryNames[group.categories.first]!}'
                                    '${group.pamphletPage != null ? '・パンフレット P${group.pamphletPage}' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }


  void _showGroupDetailDialog(Group group) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showCustomDialog(
      context: context,
      title: group.name,
      imagePath: group.imagePath,
      contentWidget: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              group.groupName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(group.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (group.floor != 4)
                  Text(
                    '場所: ${group.floor}階',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                if (group.pamphletPage != null)
                  Text(
                    'パンフレット: P${group.pamphletPage}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      closeButtonText: '閉じる',
    );
  }

  void _showAlreadyVotedDialog(
    Group group,
    String votedCategoryName,
    String currentCategoryName,
  ) {
    showCustomDialog(
      context: context,
      title: '選択できません',
      content:
          'この団体はすでに$votedCategoryNameで投票先として選択したため、$currentCategoryNameでは投票先とすることはできません。',
      closeButtonText: 'OK',
    );
  }

  void _showConfirmationDialog(Group group) {
    final currentCategory = voteCategories[currentCategoryIndex];
    final isLastCategory = currentCategoryIndex == voteCategories.length - 1;

    showCustomDialog(
      context: context,
      imagePath: group.imagePath,
      title: '${currentCategory.name}の確認',
      content: '「${group.name}」に投票します。\nよろしいですか？',
      closeButtonText: '戻る',
      primaryActionText: isLastCategory ? '投票を完了する' : '次のカテゴリへ',
      enablePrimaryLoading: true,
      minLoadingMs: 1300,
      maxLoadingMs: 1700,
      onPrimaryAction: () {
        Navigator.of(context).pop();
        _vote(group);
      },
    );
  }

  void _vote(Group group) {
    if (currentCategoryIndex < voteCategories.length) {
      currentSelections[voteCategories[currentCategoryIndex].id] = group.id;
      _navigate(1);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmScreen(
                uuid: widget.uuid,
                selections: currentSelections,
                isGridView: _isGridView,
              ),
        ),
      );
    }
  }

  void _navigate(int direction) {
    if (direction == 0) return; // 画面遷移しない

    final nextIndex = currentCategoryIndex + direction;
    final bool isNavigatingForward = direction > 0;

    if (nextIndex >= 0 && nextIndex < voteCategories.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => VoteScreen(
                uuid: widget.uuid,
                categoryIndex: nextIndex,
                selections: currentSelections,
                isGridView: _isGridView,
                restoreSelection: isNavigatingForward,
              ),
        ),
      );
    } else if (nextIndex >= voteCategories.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmScreen(
                uuid: widget.uuid,
                selections: currentSelections,
                isGridView: _isGridView,
              ),
        ),
      );
    }
  }
}
