import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../platform/platform_utils.dart';
import '../widgets/main_layout.dart';
import '../widgets/message_area.dart';
import '../widgets/group_selection_area.dart';
import 'confirm_screen.dart';
import '../widgets/custom_dialog.dart';

class VoteScreen extends StatefulWidget {
  final String uuid;
  final int categoryIndex;
  final Map<String, String> selections;

  VoteScreen({
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
  String? selectedGroupId;

  @override
  void initState() {
    super.initState();
    currentSelections = Map.from(widget.selections);
    currentCategoryIndex = widget.categoryIndex;
    String categoryId = voteCategories[currentCategoryIndex].id;
    if (currentSelections.containsKey(categoryId)) {
      selectedGroupId = currentSelections[categoryId];
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

  @override
  Widget build(BuildContext context) {
    final category = voteCategories[currentCategoryIndex];
    final bool canProceed = selectedGroupId != null || category.canSkip;

    // 新しいヘルプ本文を作成
    final helpContent =
        category.shortHelpText != null && category.shortHelpText!.isNotEmpty
            ? '${category.description}\n\n${category.shortHelpText}'
            : category.description;

    return MainLayout(
      title: '投票画面 ${currentCategoryIndex + 1}/${voteCategories.length}',
      helpTitle: '${category.name} について',
      helpContent: helpContent,
      onHome: () => PlatformUtils.reloadApp(),
      onBack:
          currentCategoryIndex == 0
              ? null
              : () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => VoteScreen(
                          uuid: widget.uuid,
                          categoryIndex: currentCategoryIndex - 1,
                          selections: currentSelections,
                        ),
                  ),
                );
              },
      onNext: canProceed ? () => _saveAndProceed() : null,
      child: Column(
        children: [
          MessageArea(message: category.description, title: category.name),
          Expanded(
            child: GroupSelectionArea(
              category: category,
              selectedGroupId: selectedGroupId,
              isVoted: selectedGroupId != null,
              onSelect: (String groupId) {
                setState(() {
                  selectedGroupId = groupId;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveAndProceed() {
    final category = voteCategories[currentCategoryIndex];
    if (selectedGroupId == null && !category.canSkip) {
      showCustomDialog(
        context: context,
        title: '選択エラー',
        content: '投票先が選択されていません。',
      );
      return;
    }
    if (selectedGroupId != null) {
      currentSelections[category.id] = selectedGroupId!;
    } else if (currentSelections.containsKey(category.id)) {
      currentSelections.remove(category.id);
    }

    if (currentCategoryIndex < voteCategories.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => VoteScreen(
                uuid: widget.uuid,
                categoryIndex: currentCategoryIndex + 1,
                selections: currentSelections,
              ),
        ),
      );
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
}
