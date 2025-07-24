import 'package:flutter/material.dart';
import '../models/group.dart';
import './group_selection_area.dart'; // group_selection_area.dart をインポート

// enum DisplayMode { grid, list } // こちらのDisplayModeの定義を削除

class GroupTile extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final VoidCallback onSelect;
  final DisplayMode displayMode;

  GroupTile({
    required this.group,
    required this.isSelected,
    required this.onSelect,
    this.displayMode = DisplayMode.grid,
  });

  @override
  Widget build(BuildContext context) {
    bool showImage = displayMode == DisplayMode.grid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onSelect,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? colorScheme.primary : theme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment:
                  displayMode == DisplayMode.list
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start, // リスト表示の場合は子を中央寄せ
              children: [
                if (showImage) // グリッド表示の場合のみ画像
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: Image.asset(
                        group.imagePath,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                // リスト表示時はこのContainerが主要コンテンツ
                // グリッド表示時は画像の下
                Padding(
                  // テキストエリアの上下に少しパディングを追加（リスト表示時も見栄え良くするため）
                  padding: EdgeInsets.symmetric(
                    vertical: showImage ? 0 : 8.0,
                    horizontal: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Columnが必要な分だけの高さを取るようにする
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: showImage ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        group.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: showImage ? 2 : 3, // リスト表示の場合は3行に制限
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: colorScheme.onSecondary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// enum TileType { grid, list } // もし GroupTile 内部で表示タイプを切り替えるなら使用
