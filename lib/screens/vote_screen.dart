import '../models/group.dart' hide VoteCategory;
import '../config/vote_options.dart';
import '../widgets/main_layout.dart';
import '../platform/platform_utils.dart';
import 'confirm_screen.dart';
import '../widgets/custom_dialog.dart';
import '../services/accessibility_service.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../widgets/neumorphic_wrappers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
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
      extendBehindBottomBar: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildAnimatedGroupView(
              isOverlayFilter: true,
              forceList: isCompact || isZoomed,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 72.0),
                if (isCompact)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16, bottom: 12),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: category.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.brightness == Brightness.dark
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: 'に選びたい団体を選択してください',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isCompact) _buildGroupDetailHeader(isCompact: isCompact),
                if (!isCompact && !isZoomed) ...[
                  _buildViewToggle(),
                  const SizedBox(height: 12),
                ] else
                  const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            bottom: 88.0,
            left: 0,
            right: 0,
            child: _buildFloorFilter(),
          ),
        ],
      ),
    );
  }

  // 画面内のグリッド/リスト領域の切替・フィルタ変更にアニメーションを付与
  Widget _buildAnimatedGroupView({
    required bool isOverlayFilter,
    bool forceList = false,
  }) {
    final viewKey = ValueKey<String>(
      'view-${(forceList ? false : _isGridView) ? 'grid' : 'list'}-floor-${_selectedFloor ?? 'all'}',
    );
    final child =
        (forceList ? false : _isGridView)
            ? _buildGroupGridView(isOverlayFilter: isOverlayFilter)
            : _buildGroupListView(isOverlayFilter: isOverlayFilter);

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
    final isDark = theme.brightness == Brightness.dark;
    final category = voteCategories[currentCategoryIndex];

    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    Widget headerContent;
    if (_selectedGroup == null) {
      headerContent = SizedBox(
        height: isCompact ? 100 : 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'に選びたい団体を選択してください',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),
            const Expanded(
              child: Center(
                child: Text(
                  '投票先を選択してください',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      headerContent = SizedBox(
        height: isCompact ? 100 : 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'に選びたい団体を選択してください',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        _selectedGroup!.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedGroup!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _selectedGroup!.groupName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          _selectedGroup!.description,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedGroup!.floor == 4 ? '' : '${_selectedGroup!.floor}階・'}${groupCategoryNames[_selectedGroup!.categories.first]!}'
                          '${_selectedGroup!.pamphletPage != null ? '・パンフレット P${_selectedGroup!.pamphletPage}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: _selectedGroup == null
            ? null
            : () => _showGroupDetailDialog(_selectedGroup!),
        behavior: HitTestBehavior.opaque,
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            glassColor: glassColor,
            thickness: 15.0,
            blur: 20.0,
          ),
          child: LiquidGlass(
            shape: LiquidRoundedRectangle(
              borderRadius: 22.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: headerContent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            glassColor: glassColor,
            thickness: 15.0,
            blur: 20.0,
          ),
          child: LiquidGlass(
            shape: LiquidRoundedRectangle(
              borderRadius: 16.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(
                    icon: Icons.grid_view,
                    label: 'グリッド',
                    isSelected: _isGridView,
                    onPressed: () => setState(() => _isGridView = true),
                  ),
                  const SizedBox(width: 4),
                  _buildToggleButton(
                    icon: Icons.list,
                    label: 'リスト',
                    isSelected: !_isGridView,
                    onPressed: () => setState(() => _isGridView = false),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    final isDark = theme.brightness == Brightness.dark;
    final Color activeColor = theme.colorScheme.primary;
    final Color bg = isSelected
        ? activeColor.withValues(alpha: 0.35)
        : Colors.transparent;
    final Color textColor = isSelected
        ? (isDark ? Colors.white : activeColor)
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final Color iconColor = isSelected
        ? (isDark ? Colors.white : activeColor)
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final Border border = Border.all(
      color: isSelected
          ? activeColor.withValues(alpha: 0.5)
          : Colors.transparent,
      width: 1.0,
    );

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.0),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupGridView({required bool isOverlayFilter}) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
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
    // 画面幅に応じて列数を調整（iPhone SE相当で2列）
    final int crossAxisCount =
        width < 380
            ? 2
            : width < 650
            ? 3
            : 4;
    final double childAspectRatio = width < 380 ? 0.7 : 0.8;

    final height = MediaQuery.of(context).size.height;
    final bool isCompact = height < 700;
    return AnimationLimiter(
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(8),
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            isCompact ? 132.0 : 400.0,
            16,
            isOverlayFilter ? 240 : 16,
          ),
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
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      color: theme.colorScheme.surface,
                      depth: isSelected ? -6.0 : 6.0,
                      intensity: 0.7,
                      lightSource: LightSource.topLeft,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                      border: NeumorphicBorder(
                        isEnabled: isSelected,
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupListView({required bool isOverlayFilter}) {
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
    final height = MediaQuery.of(context).size.height;
    final bool isCompact = height < 700;
    return AnimationLimiter(
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(8),
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            isCompact ? 132.0 : 400.0,
            16,
            isOverlayFilter ? 240 : 16,
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        color: colorScheme.surface,
                        depth:
                            isSelected
                                ? -((Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 6.0
                                    : 10.0))
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 6.0
                                    : 10.0),
                        intensity: 0.8,
                        lightSource: LightSource.topLeft,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                        border: NeumorphicBorder(
                          isEnabled: isSelected,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : theme.dividerColor,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloorFilter() {
    final floors = [1, 2, 3, 4]; // 1,2,3階とステージ(4)
    final floorLabels = {1: '1階', 2: '2階', 3: '3階', 4: 'ステージ'};
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: glassColor,
          thickness: 15.0,
          blur: 20.0,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedRectangle(
            borderRadius: 20.0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildToggleButton(
                  label: 'すべて',
                  isSelected: _selectedFloor == null,
                  onPressed: () => _filterByFloor(null),
                ),
                ...floors.map(
                  (f) => _buildToggleButton(
                    label: floorLabels[f]!,
                    isSelected: _selectedFloor == f,
                    onPressed: () => _filterByFloor(f),
                  ),
                ),
              ],
            ),
          ),
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
