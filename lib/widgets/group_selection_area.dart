// widgets/group_selection_area.dart
import 'package:flutter/material.dart';
import '../models/group.dart';
//import '../models/vote_category.dart';
import 'group_tile.dart';

class GroupSelectionArea extends StatefulWidget {
  final VoteCategory category;
  final String? selectedGroupId;
  final Function(String) onSelect;

  GroupSelectionArea({
    required this.category,
    this.selectedGroupId,
    required this.onSelect,
  });

  @override
  _GroupSelectionAreaState createState() => _GroupSelectionAreaState();
}

class _GroupSelectionAreaState extends State<GroupSelectionArea> {
  int selectedFloor = 1;

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine grid columns
    final screenWidth = MediaQuery.of(context).size.width;
    // Left menu is 140px wide, so calculate available width
    final availableWidth = screenWidth - 140;

    // Determine number of columns based on available width
    // For wider screens show more columns
    int crossAxisCount = 2; // Default for smaller screens

    if (availableWidth >= 900) {
      crossAxisCount = 4; // Very large screens
    } else if (availableWidth >= 600) {
      crossAxisCount = 3; // Medium to large screens
    }

    // フロアでフィルタリングした団体のリスト
    List<Group> filteredGroups =
        widget.category.groups
            .where((group) => group.floor == selectedFloor)
            .toList();

    // 全フロアの取得（重複なし）
    Set<int> allFloors =
        widget.category.groups.map((group) => group.floor).toSet();

    return Row(
      children: [
        // 左側のフロア選択メニュー
        Container(
          width: 140,
          color: Color(0xFFEEEEEE),
          child: Column(
            children: [
              // フロアボタンの動的生成
              ...allFloors
                  .map((floor) => _buildFloorButton('${floor}階フロア', floor))
                  .toList(),

              /*if (widget.category.groups.any((g) => g.floor == 0))
                _buildStageButton('ステージ団体', 0),

              Spacer(),
              _buildNavButton('団体名から選ぶ', Icons.arrow_forward),
              _buildNavButton('パンフレットから選ぶ', Icons.arrow_forward),*/
            ],
          ),
        ),

        // 右側の団体選択グリッド
        Expanded(
          child: Container(
            color: Colors.white,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.5,
              padding: EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children:
                  filteredGroups
                      .map(
                        (group) => GroupTile(
                          group: group,
                          isSelected: group.id == widget.selectedGroupId,
                          onSelect: () => widget.onSelect(group.id),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloorButton(String title, int floor) {
    final isSelected = selectedFloor == floor;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFloor = floor;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
