import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../config/vote_options.dart';
import '../models/group.dart';

class ExportService {
  /// 投票結果をExcelブックとして生成し、バイト列を返す
  /// 各カテゴリごとにシートを作成し、ヘッダ: 順位/団体名/票数 を出力
  static List<int> buildResultsWorkbook(
    List<MapEntry<Group, int>> Function(String categoryId) getSortedResults,
  ) {
    final excel = Excel.createExcel();

    // 既定の空シートを削除
    if (excel.sheets.isNotEmpty) {
      final first = excel.sheets.keys.first;
      excel.delete(first);
    }

    for (final category in voteCategories) {
      final sheet = excel['${category.name}'];
      // ヘッダ
      sheet.appendRow([
        TextCellValue('順位'),
        TextCellValue('団体名'),
        TextCellValue('票数'),
      ]);

      final results = getSortedResults(category.id);
      int rank = 1;
      for (final entry in results) {
        sheet.appendRow([
          IntCellValue(rank),
          TextCellValue(entry.key.name),
          IntCellValue(entry.value),
        ]);
        rank += 1;
      }
    }

    // Webで二重保存を避けるため、fileNameは指定せずバイト列のみ取得
    final bytes = excel.save();
    // package:excel returns Uint8List?
    if (bytes == null) {
      return Uint8List(0);
    }
    return bytes;
  }
}
