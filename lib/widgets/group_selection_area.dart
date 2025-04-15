import 'package:flutter/material.dart';
import '../models/group.dart';
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
    selectedFloor =
        widget.category.groups.isNotEmpty
            ? widget.category.groups
                .map((group) => group.floor)
                .reduce((a, b) => a < b ? a : b)
            : 1;
  }

  @override
  Widget build(BuildContext context) {
    List<Group> filteredGroups =
        widget.category.groups
            .where((group) => group.floor == selectedFloor)
            .toList();
    Set<int> allFloors =
        widget.category.groups.map((group) => group.floor).toSet();
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = 140.0;
    final availableWidth = screenWidth - menuWidth;
    const minItemWidth = 500.0;
    int crossAxisCount = (availableWidth ~/ minItemWidth);
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    return Row(
      children: [
        Container(
          width: menuWidth,
          color: Color(0xFFEEEEEE),
          child: Column(
            children: [
              ...allFloors
                  .map(
                    (floor) =>
                        (floor == 4)
                            ? _buildFloorButton('ステージ・バンド等', floor)
                            : _buildFloorButton('${floor}階フロア', floor),
                  )
                  .toList(),
            ],
          ),
        ),
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
