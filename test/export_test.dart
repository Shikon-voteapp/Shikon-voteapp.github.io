import 'package:flutter_test/flutter_test.dart';
import 'package:shikon_voteapp/services/export_service.dart';
import 'package:shikon_voteapp/models/group.dart';

void main() {
  test('ExportService.buildResultsWorkbook succeeds', () {
    final bytes = ExportService.buildResultsWorkbook((categoryId) {
      return [
        MapEntry(
          Group(id: '1', name: 'A', groupName: 'A', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Tenji]),
          100,
        ),
        MapEntry(
          Group(id: '2', name: 'B', groupName: 'B', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Tenji]),
          80,
        ),
        MapEntry(
          Group(id: '3', name: 'C', groupName: 'C', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Tenji]),
          80,
        ),
        MapEntry(
          Group(id: '4', name: 'D', groupName: 'D', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Tenji]),
          50,
        ),
      ];
    });

    expect(bytes.isNotEmpty, true);
    print('Excel bytes length: ${bytes.length}');
  });

  test('ExportService.buildResultsText formats correctly', () {
    final text = ExportService.buildResultsText(
      getSortedResults: (categoryId) {
        if (categoryId == 'Shikon_award') {
          return [
            MapEntry(Group(id: '1', name: 'ダンス部', groupName: 'ダンス部', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Stage]), 118),
            MapEntry(Group(id: '2', name: '歴史研究部', groupName: '歴史研究部', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Tenji]), 100),
          ];
        } else if (categoryId == 'Moyoshi') {
          return [
            MapEntry(Group(id: 'm1', name: 'F1-COASTER', groupName: 'F1-COASTER', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Moyoshi]), 71),
            MapEntry(Group(id: 'm2', name: 'ナットウウォーズ', groupName: 'ナットウウォーズ', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Moyoshi]), 43),
            MapEntry(Group(id: 'm3', name: '冥慈総合病院', groupName: '冥慈総合病院', description: '', imagePath: '', floor: 1, categories: [GroupCategory.Moyoshi]), 43),
          ];
        }
        return [];
      },
      totalVotes: 678,
      excludeShikonTop2: true,
      timestamp: DateTime(2026, 9, 26, 19, 12),
    );

    print('Generated text:\n$text');
    expect(text.contains('【紫紺祭　投票結果】「2026/9/26 19:12現在」　 '), true);
    expect(text.contains('総投票数：678票 '), true);
    expect(text.contains('[紫紺賞]1位：ダンス部(118票)　2位：歴史研究部(100票) '), true);
    expect(text.contains('[教室催し物賞]1位：F1-COASTER(71票)　2位：ナットウウォーズ(43票)　2位：冥慈総合病院(43票) '), true);
    expect(text.contains('※紫紺賞1位・2位を除いて集計'), true);
  });
}
