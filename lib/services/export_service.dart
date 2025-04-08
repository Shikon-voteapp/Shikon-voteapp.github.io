// lib/services/export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/group.dart';
import '../config/vote_options.dart';
import 'conectivility_service.dart';
import 'uuid_service.dart';

class ExportService {
  /// Export vote data to Excel file
  static Future<void> exportToExcel(List<Vote> votes) async {
    // Create a new Excel document
    final excel = Excel.createExcel();

    // Create a summary sheet
    final sheetSummary = excel['Summary'];

    // Summary header
    sheetSummary
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'カテゴリー';
    sheetSummary
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = 'グループ名';
    sheetSummary
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = '票数';
    sheetSummary
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        .value = '割合 (%)';

    int rowIndex = 1; // Start from second row

    // Process each category
    for (final category in voteCategories) {
      // Get results for this category
      final results = _getCategoryResults(category.id, votes);
      int totalVotes = 0;

      for (final groupId in results.keys) {
        totalVotes += results[groupId] ?? 0;
      }

      // Sort groups by vote count (descending)
      final sortedGroups =
          category.groups.toList()..sort(
            (a, b) => (results[b.id] ?? 0).compareTo(results[a.id] ?? 0),
          );

      // Add data for each group
      for (final group in sortedGroups) {
        final votes = results[group.id] ?? 0;
        final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;

        sheetSummary
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = category.name;
        sheetSummary
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            )
            .value = group.name;
        sheetSummary
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            )
            .value = votes;
        sheetSummary
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
            )
            .value = percentage.toStringAsFixed(1);

        rowIndex++;
      }

      // Add empty row between categories
      rowIndex++;
    }

    // Create a detail sheet with raw vote data
    final sheetDetails = excel['Raw Data'];

    // Headers for raw data
    sheetDetails
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'Vote ID';
    sheetDetails
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = 'User ID';
    sheetDetails
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = 'Timestamp';

    // Add category headers
    for (int i = 0; i < voteCategories.length; i++) {
      sheetDetails
          .cell(CellIndex.indexByColumnRow(columnIndex: i + 3, rowIndex: 0))
          .value = voteCategories[i].name;
    }

    // Add vote data
    for (int i = 0; i < votes.length; i++) {
      final vote = votes[i];

      sheetDetails
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = vote.uuid;
      sheetDetails
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = vote.timestamp.toString();

      // Add selected groups for each category
      for (int j = 0; j < voteCategories.length; j++) {
        final categoryId = voteCategories[j].id;
        final selectedGroupId = vote.selections[categoryId];

        if (selectedGroupId != null) {
          // Find the group name for the selected group ID
          final category = voteCategories[j];
          final group = category.groups.firstWhere(
            (g) => g.id == selectedGroupId,
            orElse:
                () => Group(
                  id: 'unknown',
                  name: 'Unknown',
                  description: 'Unknown',
                  imagePath: '',
                  floor: 0,
                ),
          );

          sheetDetails
              .cell(
                CellIndex.indexByColumnRow(columnIndex: j + 3, rowIndex: i + 1),
              )
              .value = group.name;
        }
      }
    }

    // Save the Excel file
    final bytes = excel.encode();
    if (bytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/vote_results.xlsx');
    await file.writeAsBytes(bytes);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: '投票結果');
  }

  /// Export vote data to CSV file
  static Future<void> exportToCSV(List<Vote> votes) async {
    // Create CSV data for summary
    List<List<dynamic>> summaryData = [];

    // Header row
    summaryData.add(['カテゴリー', 'グループ名', '票数', '割合 (%)']);

    // Process each category
    for (final category in voteCategories) {
      // Get results for this category
      final results = _getCategoryResults(category.id, votes);
      int totalVotes = 0;

      for (final groupId in results.keys) {
        totalVotes += results[groupId] ?? 0;
      }

      // Sort groups by vote count (descending)
      final sortedGroups =
          category.groups.toList()..sort(
            (a, b) => (results[b.id] ?? 0).compareTo(results[a.id] ?? 0),
          );

      // Add data for each group
      for (final group in sortedGroups) {
        final votes = results[group.id] ?? 0;
        final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;

        summaryData.add([
          category.name,
          group.name,
          votes,
          percentage.toStringAsFixed(1),
        ]);
      }

      // Add empty row between categories
      summaryData.add([]);
    }

    // Create CSV string
    final csvString = const ListToCsvConverter().convert(summaryData);

    // Save the CSV file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/vote_results.csv');
    await file.writeAsString(csvString);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: '投票結果');
  }

  // Helper method to get category results
  static Map<String, int> _getCategoryResults(
    String categoryId,
    List<Vote> votes,
  ) {
    Map<String, int> results = {};

    for (var vote in votes) {
      if (vote.selections.containsKey(categoryId)) {
        String groupId = vote.selections[categoryId]!;
        results[groupId] = (results[groupId] ?? 0) + 1;
      }
    }

    return results;
  }
}
