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
  late int selectedFloor;

  @override
  void initState() {
    super.initState();
    // Get the minimum floor value from all groups
    selectedFloor =
        widget.category.groups.isNotEmpty
            ? widget.category.groups
                .map((group) => group.floor)
                .reduce((a, b) => a < b ? a : b)
            : 1; // Default to 1 if there are no groups
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the code remains the same...
    // フロアでフィルタリングした団体のリスト
    List<Group> filteredGroups =
        widget.category.groups
            .where((group) => group.floor == selectedFloor)
            .toList();

    // 全フロアの取得（重複なし）
    Set<int> allFloors =
        widget.category.groups.map((group) => group.floor).toSet();

    // 画面の幅を取得
    final screenWidth = MediaQuery.of(context).size.width;
    // 左側のフロア選択メニューの幅
    final menuWidth = 140.0;
    // 利用可能な幅からメニュー幅を引く
    final availableWidth = screenWidth - menuWidth;

    // 1アイテムの最小幅（500px）
    const minItemWidth = 500.0;

    // グリッドの列数を計算（利用可能な幅をminItemWidthで割って切り捨て）
    int crossAxisCount = (availableWidth ~/ minItemWidth);
    // 最低でも1列は表示
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    return Row(
      children: [
        // 左側のフロア選択メニュー
        Container(
          width: menuWidth,
          color: Color(0xFFEEEEEE),
          child: Column(
            children: [
              // フロアボタンの動的生成
              ...allFloors
                  .map(
                    (floor) =>
                        (floor == 0)
                            ? _buildFloorButton('ステージ・バンド等', floor)
                            : _buildFloorButton('${floor}階フロア', floor),
                  )
                  .toList(),
            ],
          ),
        ),

        // 右側の団体選択グリッド
        Expanded(
          child: Container(
            color: Colors.white,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              padding: EdgeInsets.all(16),
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];
                return GroupTile(
                  group: group,
                  isSelected: group.id == widget.selectedGroupId,
                  onSelect: () => widget.onSelect(group.id),
                );
              },
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
