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
    String categoryId = voteCategories[currentCategoryIndex].id;
    if (currentSelections.containsKey(categoryId)) {
      selectedGroupId = currentSelections[categoryId];
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = voteCategories[currentCategoryIndex];
    final bool canProceed = selectedGroupId != null || category.canSkip;

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: '投票画面 ${currentCategoryIndex + 1}/${voteCategories.length}',
          ),
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
          BottomBar(
            uuid: widget.uuid,
            showNextButton: canProceed,
            showBackButton: true,
            onBack: () {
              if (currentCategoryIndex == 0) {
                Navigator.pop(context);
              } else {
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
              }
            },
            onNext: () {
              _saveAndProceed();
            },
          ),
        ],
      ),
    );
  }

  void _saveAndProceed() {
    final category = voteCategories[currentCategoryIndex];
    if (selectedGroupId == null && !category.canSkip) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラー：投票先が選択されていません。')));
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
