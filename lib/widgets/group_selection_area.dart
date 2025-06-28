import 'package:flutter/material.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import 'group_tile.dart';

enum DisplayMode { grid, list }

class GroupSelectionArea extends StatefulWidget {
  final VoteCategory category;
  final String? selectedGroupId;
  final Function(String) onSelect;
  final bool isVoted;

  GroupSelectionArea({
    required this.category,
    this.selectedGroupId,
    required this.onSelect,
    this.isVoted = false,
  });

  @override
  _GroupSelectionAreaState createState() => _GroupSelectionAreaState();
}

class _GroupSelectionAreaState extends State<GroupSelectionArea> {
  late int selectedFloor;
  bool showAllGroups = true;
  DisplayMode _displayMode = DisplayMode.grid;

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
        showAllGroups
            ? widget.category.groups
            : widget.category.groups
                .where((group) => group.floor == selectedFloor)
                .toList();
    Set<int> allFloors =
        widget.category.groups.map((group) => group.floor).toSet();
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth;
    const minItemWidth = 500.0;
    int crossAxisCount = (availableWidth ~/ minItemWidth);
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFloorButton('すべて表示', -1, true),
                      ...allFloors
                          .map(
                            (floor) => _buildFloorButton(
                              (floor == 4) ? 'ステージ等' : '${floor}階',
                              floor,
                              false,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              ToggleButtons(
                isSelected: [
                  _displayMode == DisplayMode.grid,
                  _displayMode == DisplayMode.list,
                ],
                onPressed: (index) {
                  setState(() {
                    _displayMode =
                        index == 0 ? DisplayMode.grid : DisplayMode.list;
                  });
                },
                children: [Icon(Icons.grid_view), Icon(Icons.list)],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildGroupDisplay(filteredGroups, crossAxisCount),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDisplay(List<Group> groups, int crossAxisCount) {
    if (_displayMode == DisplayMode.grid) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        padding: EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupTile(
            group: group,
            isSelected: group.id == widget.selectedGroupId,
            onSelect: () => widget.onSelect(group.id),
            displayMode: _displayMode,
          );
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GroupTile(
              group: group,
              isSelected: group.id == widget.selectedGroupId,
              onSelect: () => widget.onSelect(group.id),
              displayMode: _displayMode,
            ),
          );
        },
      );
    }
  }

  Widget _buildFloorButton(
    String title,
    int floorOrAll,
    bool isSelectAllButton,
  ) {
    final bool isEffectivelySelected =
        isSelectAllButton
            ? showAllGroups
            : (!showAllGroups && selectedFloor == floorOrAll);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(title),
        selected: isEffectivelySelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              if (isSelectAllButton) {
                showAllGroups = true;
              } else {
                showAllGroups = false;
                selectedFloor = floorOrAll;
              }
            });
          }
        },
        selectedColor: Colors.blue.withOpacity(0.2),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: isEffectivelySelected ? Colors.blue : Colors.black,
        ),
      ),
    );
  }
}
