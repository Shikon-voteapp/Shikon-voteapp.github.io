import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shikon_voteapp/models/group.dart';
import 'package:shikon_voteapp/config/vote_options.dart';
import 'package:shikon_voteapp/platform/platform_utils.dart';
import 'package:shikon_voteapp/widgets/main_layout.dart';
import 'package:shikon_voteapp/screens/confirm_screen.dart';
import 'package:shikon_voteapp/widgets/custom_dialog.dart';
import 'package:shikon_voteapp/services/database_service.dart';
import 'package:shikon_voteapp/widgets/bottom_bar.dart';
import 'package:shikon_voteapp/widgets/top_bar.dart';
import 'package:shikon_voteapp/theme.dart';

class VoteScreen extends StatefulWidget {
  final String uuid;
  final int categoryIndex;
  final Map<String, String> selections;

  const VoteScreen({
    super.key,
    required this.uuid,
    required this.categoryIndex,
    this.selections = const {},
  });

  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  late Map<String, String> currentSelections;
  late int currentCategoryIndex;
  Group? _selectedGroup;
  List<Group> _filteredGroups = [];
  int? _selectedFloor;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    currentSelections = Map.from(widget.selections);
    currentCategoryIndex = widget.categoryIndex;
    final category = voteCategories[currentCategoryIndex];

    // 初期グループリストを設定
    _filteredGroups = category.groups;

    // 前の画面から渡された選択状態を復元
    String? selectedId = currentSelections[category.id];
    if (selectedId != null) {
      try {
        _selectedGroup = category.groups.firstWhere((g) => g.id == selectedId);
      } catch (e) {
        _selectedGroup = null;
      }
    }

    // 初回描画後にヘルプを自動表示
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showInitialHelp(context),
    );
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
    final bool canProceed = _selectedGroup != null || category.canSkip;
    final helpContent =
        category.shortHelpText != null && category.shortHelpText!.isNotEmpty
            ? '${category.description}\n\n${category.shortHelpText}'
            : category.description;

    return MainLayout(
      title: '投票画面 ${currentCategoryIndex + 1}/${voteCategories.length}',
      icon: Icons.how_to_vote_outlined,
      helpTitle: '${category.name} について',
      helpContent: helpContent,
      onHome: () => PlatformUtils.reloadApp(),
      onBack: currentCategoryIndex > 0 ? () => _navigate(-1) : null,
      onNext: null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontFamily: 'IBMPlexSansJP'),
                children: [
                  TextSpan(
                    text: category.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const TextSpan(
                    text: 'に選びたい団体を選択してください',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          _buildGroupDetailHeader(),
          _buildViewToggle(),
          Expanded(
            child: _isGridView ? _buildGroupGridView() : _buildGroupListView(),
          ),
          _buildFloorFilter(),
          _buildVoteButton(),
        ],
      ),
    );
  }

  Widget _buildGroupDetailHeader() {
    if (_selectedGroup == null) {
      return Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            '投票先を選択してください',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        if (_selectedGroup != null) {
          _showGroupDetailDialog(_selectedGroup!);
        }
      },
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _selectedGroup!.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedGroup!.floor == 4 ? '' : '${_selectedGroup!.floor}階・'}${groupCategoryNames[_selectedGroup!.categories.first]!}'
                    '${_selectedGroup!.pamphletPage != null ? '・パンフレット P${_selectedGroup!.pamphletPage}' : ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => setState(() => _isGridView = !_isGridView),
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          label: Text(_isGridView ? 'リスト表示' : 'グリッド表示'),
        ),
      ),
    );
  }

  Widget _buildGroupGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredGroups.length,
      itemBuilder: (context, index) {
        final group = _filteredGroups[index];
        final isSelected = _selectedGroup?.id == group.id;
        final category = voteCategories[currentCategoryIndex];
        final otherVotedEntries = currentSelections.entries.where(
          (entry) => entry.key != category.id && entry.value == group.id,
        );
        final isVotedInOtherCategory = otherVotedEntries.isNotEmpty;

        return GestureDetector(
          onTap: () {
            if (isVotedInOtherCategory) {
              final votedCategoryKey = otherVotedEntries.first.key;
              final votedCategory = voteCategories.firstWhere(
                (cat) => cat.id == votedCategoryKey,
              );
              _showAlreadyVotedDialog(group, votedCategory.name, category.name);
            } else {
              setState(() => _selectedGroup = group);
            }
          },
          child: Opacity(
            opacity: isVotedInOtherCategory ? 0.5 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
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
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.error_outline,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Text(
                      group.id,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGroups.length,
      itemBuilder: (context, index) {
        final group = _filteredGroups[index];
        final isSelected = _selectedGroup?.id == group.id;
        final category = voteCategories[currentCategoryIndex];
        final otherVotedEntries = currentSelections.entries.where(
          (entry) => entry.key != category.id && entry.value == group.id,
        );
        final isVotedInOtherCategory = otherVotedEntries.isNotEmpty;

        return GestureDetector(
          onTap: () {
            if (isVotedInOtherCategory) {
              final votedCategoryKey = otherVotedEntries.first.key;
              final votedCategory = voteCategories.firstWhere(
                (cat) => cat.id == votedCategoryKey,
              );
              _showAlreadyVotedDialog(group, votedCategory.name, category.name);
            } else {
              setState(() => _selectedGroup = group);
            }
          },
          child: Opacity(
            opacity: isVotedInOtherCategory ? 0.5 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
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
                            (context, error, stackTrace) =>
                                Container(color: Colors.grey.shade200),
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
                        if (group.groupName != null)
                          Text(
                            group.groupName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          group.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${group.floor == 4 ? '' : '${group.floor}階・'}${groupCategoryNames[group.categories.first]!}'
                          '${group.pamphletPage != null ? '・パンフレット P${group.pamphletPage}' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
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
    );
  }

  Widget _buildFloorFilter() {
    final floors = [1, 2, 3, 4]; // 1,2,3階とステージ(4)
    final floorLabels = {1: '1階', 2: '2階', 3: '3階', 4: 'ステージ'};

    int initialIndex = 0;
    if (_selectedFloor != null) {
      final index = floors.indexOf(_selectedFloor!);
      if (index != -1) {
        initialIndex = index + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: DefaultTabController(
        initialIndex: initialIndex,
        length: 5,
        child: TabBar(
          onTap: (index) {
            if (index == 0) {
              _filterByFloor(null);
            } else {
              _filterByFloor(floors[index - 1]);
            }
          },
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            const Tab(text: 'すべて'),
            ...floors.map((floor) => Tab(text: floorLabels[floor]!)),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton() {
    final category = voteCategories[currentCategoryIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: const Color(0xFF6A2C8F),
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          if (_selectedGroup == null && !category.canSkip) {
            showCustomDialog(
              context: context,
              title: '選択エラー',
              content: '投票先を選択してください。',
            );
          } else {
            _showConfirmationDialog(_selectedGroup!);
          }
        },
        child: const Text('投票する', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  void _showGroupDetailDialog(Group group) {
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                if (group.pamphletPage != null)
                  Text(
                    'パンフレット: P${group.pamphletPage}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          label: const Text('戻る'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF333333),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _vote(group);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A2C8F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isLastCategory ? '投票を完了する' : '次のカテゴリへ'),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ],
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
              ),
        ),
      );
    }
  }

  void _navigate(int direction) {
    if (direction == 0) return; // 画面遷移しない

    final nextIndex = currentCategoryIndex + direction;
    if (nextIndex >= 0 && nextIndex < voteCategories.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => VoteScreen(
                uuid: widget.uuid,
                categoryIndex: nextIndex,
                selections: currentSelections,
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
              ),
        ),
      );
    }
  }
}
