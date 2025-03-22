// screens/vote_screen.dart
import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../widgets/top_bar.dart';
import '../widgets/message_area.dart';
import '../widgets/group_selection_area.dart';
import '../widgets/bottom_bar.dart';
import 'confirm_screen.dart';

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

    // 既に選択済みの場合は復元
    String categoryId = voteCategories[currentCategoryIndex].id;
    if (currentSelections.containsKey(categoryId)) {
      selectedGroupId = currentSelections[categoryId];
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = voteCategories[currentCategoryIndex];

    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '投票画面 ${currentCategoryIndex + 1}/4'),
          MessageArea(message: category.description, title: category.name),
          Expanded(
            child: GroupSelectionArea(
              category: category,
              selectedGroupId: selectedGroupId,
              onSelect: (String groupId) {
                setState(() {
                  selectedGroupId = groupId;
                });
              },
            ),
          ),
          BottomBar(
            uuid: widget.uuid,
            showNextButton: selectedGroupId != null,
            onNext: () {
              _saveAndProceed();
            },
          ),
        ],
      ),
    );
  }

  void _saveAndProceed() {
    // 現在の選択を保存
    currentSelections[voteCategories[currentCategoryIndex].id] =
        selectedGroupId!;

    // 次のカテゴリーがあれば次へ、なければ確認画面へ
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
