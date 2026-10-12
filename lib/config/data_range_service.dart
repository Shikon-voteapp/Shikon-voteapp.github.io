import 'vote_options.dart';

/// 投票期間は起動時に Cloud Firestore から受け取る。
class DateRangeService {
  late VotingPeriodConfig _config;

  DateTime get startDate => _config.startDate;
  DateTime get endDate => _config.endDate;
  VotingPeriodConfig get config => _config;

  void initialize(VotingPeriodConfig config) {
    _config = config;
  }

  void updateConfig(VotingPeriodConfig config) {
    _config = config;
  }

  bool isWithinVotingPeriod(DateTime dateTime) =>
      _config.isWithinVotingPeriod(dateTime);
  String getFormattedDateRange() => _config.getFormattedDateRange();
}
