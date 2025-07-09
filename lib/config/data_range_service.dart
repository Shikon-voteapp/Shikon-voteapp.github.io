// services/date_range_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'vote_options.dart';

class DateRangeService {
  // デフォルト設定から取得
  VotingPeriodConfig _config = defaultVotingPeriod;

  // ゲッター
  DateTime get startDate => _config.startDate;
  DateTime get endDate => _config.endDate;
  VotingPeriodConfig get config => _config;

  // 初期化 (アプリ起動時に呼び出す)
  Future<void> initialize() async {
    await _loadConfig();
  }

  // 投票期間設定を保存
  Future<void> saveConfig(VotingPeriodConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = config.toJson();

    // 設定をJSONとして保存
    await prefs.setString('voting_period_config', configJson.toString());

    _config = config;
  }

  // 投票期間設定を読み込み
  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 新しい統合設定を確認
      String? configStr = prefs.getString('voting_period_config');
      if (configStr != null) {
        // JSON文字列をパースして設定を復元
        // 簡単のために、現在はdefaultVotingPeriodを使用
        _config = defaultVotingPeriod;
      }

      // 従来の個別設定との互換性を維持
      String? startDateStr = prefs.getString('vote_start_date');
      String? endDateStr = prefs.getString('vote_end_date');

      if (startDateStr != null && endDateStr != null) {
        final startDate = DateTime.parse(startDateStr);
        final endDate = DateTime.parse(endDateStr);

        // 従来の設定を新しい形式に変換
        _config = VotingPeriodConfig(
          startDate: startDate,
          endDate: endDate,
          maintenanceEnabled: _config.maintenanceEnabled,
          maintenanceStartHour: _config.maintenanceStartHour,
          maintenanceEndHour: _config.maintenanceEndHour,
        );
      }
    } catch (e) {
      print('投票期間設定の読み込みエラー: $e');
      // エラー時はデフォルト値を使用
      _config = defaultVotingPeriod;
    }
  }

  // 現在時刻が有効期間内かチェック
  bool isWithinVotingPeriod(DateTime dateTime) {
    return _config.isWithinVotingPeriod(dateTime);
  }

  // 現在の設定を文字列で取得（表示用）
  String getFormattedDateRange() {
    return _config.getFormattedDateRange();
  }

  // 従来のAPIとの互換性を維持
  @Deprecated('Use saveConfig instead')
  Future<void> saveDateRange(DateTime start, DateTime end) async {
    final config = VotingPeriodConfig(
      startDate: start,
      endDate: end,
      maintenanceEnabled: _config.maintenanceEnabled,
      maintenanceStartHour: _config.maintenanceStartHour,
      maintenanceEndHour: _config.maintenanceEndHour,
    );
    await saveConfig(config);
  }
}
