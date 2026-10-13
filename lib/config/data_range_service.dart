import 'vote_options.dart';

/// 投票期間は起動時に Cloud Firestore から受け取る。
class DateRangeService {
  // Runtime configuration is loaded from Firestore before the app is shown.
  // Every screen may create its own service instance, so initialize each one
  // from the same cloud-loaded configuration instead of leaving it unassigned.
  late VotingPeriodConfig _config = defaultVotingPeriod;

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
