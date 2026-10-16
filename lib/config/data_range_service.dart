import 'vote_options.dart';

/// 投票期間は Cloud Firestore から読み込み、全画面で共有する。
class DateRangeService {
  // Keep every service instance connected to the shared cloud-loaded config.
  // A scanner can live longer than an admin edit, so caching a copy here can
  // leave login checks using an outdated period.
  VotingPeriodConfig get _config => defaultVotingPeriod;

  DateTime get startDate => _config.startDate;
  DateTime get endDate => _config.endDate;
  VotingPeriodConfig get config => _config;

  void initialize(VotingPeriodConfig config) {
    defaultVotingPeriod = config;
  }

  void updateConfig(VotingPeriodConfig config) {
    defaultVotingPeriod = config;
  }

  bool isWithinVotingPeriod(DateTime dateTime) =>
      _config.isWithinVotingPeriod(dateTime);
  String getFormattedDateRange() => _config.getFormattedDateRange();
}
