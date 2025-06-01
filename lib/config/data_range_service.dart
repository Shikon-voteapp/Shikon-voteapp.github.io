// services/date_range_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class DateRangeService {
  // ここだけ編集する
  DateTime _startDate = DateTime(2025, 4, 1, 9, 0); // 開始時間(年,月,日,時,分)
  DateTime _endDate = DateTime(2025, 9, 21, 15, 0); // 終了時間(年,月,日,時,分)

  // ゲッター
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // 初期化 (アプリ起動時に呼び出す)
  Future<void> initialize() async {
    await _loadDateRange();
  }

  // 有効期間の日時範囲を保存
  Future<void> saveDateRange(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();

    // 開始日時と終了日時をISOフォーマットで保存
    await prefs.setString('vote_start_date', start.toIso8601String());
    await prefs.setString('vote_end_date', end.toIso8601String());

    _startDate = start;
    _endDate = end;
  }

  // 有効期間の日時範囲を読み込み
  Future<void> _loadDateRange() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存されている日時を取得
      String? startDateStr = prefs.getString('vote_start_date');
      String? endDateStr = prefs.getString('vote_end_date');

      // 保存されている場合は値を設定
      if (startDateStr != null && endDateStr != null) {
        _startDate = DateTime.parse(startDateStr);
        _endDate = DateTime.parse(endDateStr);
      }
    } catch (e) {
      print('日時範囲の読み込みエラー: $e');
      // エラー時はデフォルト値を使用
    }
  }

  // 現在時刻が有効期間内かチェック
  bool isWithinVotingPeriod(DateTime dateTime) {
    return dateTime.isAfter(_startDate) && dateTime.isBefore(_endDate);
  }

  // 現在の設定を文字列で取得（表示用）
  String getFormattedDateRange() {
    return '${_formatDateTime(_startDate)} から ${_formatDateTime(_endDate)} まで';
  }

  // 日時のフォーマット
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
