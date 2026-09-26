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
      int currentRank = 1;
      for (int i = 0; i < results.length; i++) {
        final entry = results[i];
        if (i > 0 && entry.value < results[i - 1].value) {
          currentRank = i + 1;
        }
        sheet.appendRow([
          IntCellValue(currentRank),
          TextCellValue(entry.key.name),
          IntCellValue(entry.value),
        ]);
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

  /// 投票結果のテキスト出力を生成
  static String buildResultsText({
    required List<MapEntry<Group, int>> Function(String categoryId) getSortedResults,
    required int totalVotes,
    required bool excludeShikonTop2,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final header = '【紫紺祭　投票結果】「${now.year}/${now.month}/${now.day} ${now.hour}:$minuteStr現在」　 ';
    final totalLine = '総投票数：$totalVotes票 ';

    final categoryConfigs = <String, ({String label, int maxAwards})>{
      'Shikon_award': (label: '紫紺賞', maxAwards: 2),
      'Tenji': (label: '教室展示賞', maxAwards: 3),
      'Gakunen': (label: '学年展示賞', maxAwards: 1),
      'Moyoshi': (label: '教室催し物賞', maxAwards: 3),
      'Stage': (label: '部活ｽﾃｰｼﾞ賞', maxAwards: 1),
      'Band': (label: 'ﾊﾞﾝﾄﾞ賞', maxAwards: 1),
      'Performance': (label: 'ﾊﾟﾌｫｰﾏﾝｽ賞', maxAwards: 1),
    };

    final lines = <String>[
      header,
      totalLine,
    ];

    for (final category in voteCategories) {
      final config = categoryConfigs[category.id] ?? (label: category.name, maxAwards: 3);
      final sortedResults = getSortedResults(category.id);

      final items = <String>[];
      int currentRank = 1;
      for (int i = 0; i < sortedResults.length; i++) {
        final entry = sortedResults[i];
        if (entry.value <= 0) {
          break;
        }
        if (i > 0 && entry.value < sortedResults[i - 1].value) {
          currentRank = i + 1;
        }
        if (currentRank > config.maxAwards) {
          break;
        }
        items.add('${currentRank}位：${entry.key.name}(${entry.value}票)');
      }

      if (items.isNotEmpty) {
        lines.add('[${config.label}]${items.join('　')} ');
      } else {
        lines.add('[${config.label}]- ');
      }
    }

    if (excludeShikonTop2) {
      lines.add('※紫紺賞1位・2位を除いて集計');
    }

    return lines.join('\n');
  }
}
